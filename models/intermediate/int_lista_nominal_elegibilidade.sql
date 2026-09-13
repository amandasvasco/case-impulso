{{ config(
    materialized='incremental',
    unique_key='id_cidadao',
    incremental_strategy='delete+insert'
) }} -- incremental strategy delete+insert para atualizar registros diferentes por cidadao

with atendimentos_relevantes as (

    -- Só os eventos que podem alterar a elegibilidade (entrada ou saida)
    select
        id_cidadao,
        data_transmissao
    from {{ ref('stg_atendimento_individual') }}
    where classificacao in ('HIPERTENSÃO', 'HIPERTENSÃO - CONDIÇÃO RESOLVIDA')

),

watermark as (

    -- transmissão mais recente entre os eventos relevantes por cidadao
    select
        c.id_cidadao,
        greatest(
            coalesce(max(a.data_transmissao), date '1900-01-01'),
            c.data_transmissao
        ) as data_transmissao_referencia -- dt transmissao mais recente entre atendimentos relevantes por cidadao

    from {{ ref('stg_cidadao_pec') }} c
    left join atendimentos_relevantes a on a.id_cidadao = c.id_cidadao
    group by c.id_cidadao, c.data_transmissao

),

atendimentos_hipertensao as (

    select distinct id_cidadao
    from {{ ref('stg_atendimento_individual') }}
    where classificacao = 'HIPERTENSÃO'

),

atendimentos_condicao_resolvida as (

    select distinct id_cidadao
    from {{ ref('stg_atendimento_individual') }}
    where classificacao = 'HIPERTENSÃO - CONDIÇÃO RESOLVIDA'

),

cidadaos as (

    select id_cidadao, st_faleceu
    from {{ ref('stg_cidadao_pec') }}

),

final as (

    select
        h.id_cidadao,
        w.data_transmissao_referencia, -- mais recente
        not (coalesce(c.st_faleceu, false) or r.id_cidadao is not null) as elegivel,
        case
            when c.st_faleceu then 'FALECEU'
            when r.id_cidadao is not null then 'CONDICAO_RESOLVIDA'
        end as motivo_exclusao -- relevante pra analise posteriores de elegibilidade

    from atendimentos_hipertensao h
    left join cidadaos c on c.id_cidadao = h.id_cidadao
    left join atendimentos_condicao_resolvida r on r.id_cidadao = h.id_cidadao
    left join watermark w on w.id_cidadao = h.id_cidadao

)

select * from final

{% if is_incremental() %}
-- Watermark por cidadao, nao global: um cidadao cuja atualizacao mais
-- recente tenha data_transmissao menor que o maximo ja visto na tabela
-- (por causa de outro cidadao processado antes) nao pode ser ignorado.
where not exists (
    select 1 from {{ this }} t
    where t.id_cidadao = final.id_cidadao
      and t.data_transmissao_referencia >= final.data_transmissao_referencia
)
{% endif %}
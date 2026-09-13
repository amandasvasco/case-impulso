{{ config(
    materialized='incremental',
    unique_key='id_cidadao',
    incremental_strategy='delete+insert'
) }}

with cidadaos as (

    select * from {{ ref('stg_cidadao_pec') }}

),

telefones as (

    -- Telefone padronizado pra (XX) XXXXX-XXXX. Nesta base os 1200
    -- registros já vêm nesse formato, mas a validação fica pronta pra
    -- proteger contra cargas futuras mais sujas.
    select
        id_cidadao,
        regexp_replace(telefone_celular, '[^0-9]', '', 'g') as digitos
    from cidadaos

),

todas_grafias as (

    select ine_vinculo as ine, nome_equipe_vinculo as nome_equipe, data_transmissao
    from cidadaos

    union all

    select ine_ultimo_atendimento, nome_equipe_ultimo_atendimento, data_transmissao
    from cidadaos

    union all

    select ine_atendimento, nome_equipe_atendimento, data_transmissao
    from {{ ref('stg_atendimento_individual') }}

    union all

    select ine_procedimento, nome_equipe_procedimento, data_transmissao
    from {{ ref('stg_procedimentos') }}

),

grafias_normalizadas as (

    -- Padroniza pra "ESF <número>": trata o número por extenso observado
    -- ("ESF QUATRO" -> 4), extrai só o dígito (ignora pontuação como
    -- "E.S.F.", zero à esquerda como "ESF 03", e sufixos como
    -- "ESF 2 - UBS 2"), e remonta no formato canônico. O ine (chave
    -- estável) já separa os times de verdade — essa normalização só
    -- arruma a grafia de exibição por ine, não redefine identidade de
    -- equipe.
    --
    -- Achado adicional: os ines 0001234571 e 0001234572 — dois times
    -- distintos — aparecem ambos como grafia "ESF 5" no dado bruto.
    -- Colisão de digitação na fonte, não corrigida aqui (ine continua
    -- distinguindo os dois times corretamente); reportar ao time de
    -- dados como mais um item de qualidade a investigar/corrigir na
    -- origem.
    select
        ine,
        data_transmissao,
        'ESF ' || cast(
            cast(
                regexp_extract(
                    replace(upper(trim(nome_equipe)), 'QUATRO', '4'),
                    '[0-9]+'
                ) as integer
            ) as varchar
        ) as nome_equipe_normalizado
    from todas_grafias
    where ine is not null and nome_equipe is not null

),

equipe_canonica as (

    select
        ine,
        mode(nome_equipe_normalizado) as nome_equipe_canonico,
        -- Watermark da equipe: transmissão mais recente entre TODOS os
        -- registros que alimentam a grafia canônica dela — não só os
        -- deste cidadão.
        max(data_transmissao) as data_transmissao_equipe
    from grafias_normalizadas
    group by ine

),

watermark as (

    select
        c.id_cidadao,
        greatest(
            c.data_transmissao,
            coalesce(eq.data_transmissao_equipe, date '1900-01-01')
        ) as data_transmissao_referencia
    from cidadaos c
    left join equipe_canonica eq on eq.ine = c.ine_vinculo

),

final as (

    select
        c.id_cidadao,
        w.data_transmissao_referencia,

        upper(trim(c.nome_cidadao)) as nome_cidadao,
        c.cns,
        c.cpf,
        c.dt_nascimento,

        extract(year from cast('{{ var("data_referencia") }}' as date)) - extract(year from c.dt_nascimento)
            - case
                when extract(month from cast('{{ var("data_referencia") }}' as date)) < extract(month from c.dt_nascimento)
                  or (
                        extract(month from cast('{{ var("data_referencia") }}' as date)) = extract(month from c.dt_nascimento)
                        and extract(day from cast('{{ var("data_referencia") }}' as date)) < extract(day from c.dt_nascimento)
                     )
                then 1
                else 0
              end as idade,

        case
            when regexp_matches(t.digitos, '^[0-9]{11}$')
                then '(' || substr(t.digitos, 1, 2) || ') ' || substr(t.digitos, 3, 5) || '-' || substr(t.digitos, 8, 4)
            else null
        end as telefone_celular,

        c.ine_vinculo as ine_equipe,
        eq.nome_equipe_canonico as nome_equipe

    from cidadaos c
    left join telefones t on t.id_cidadao = c.id_cidadao
    left join equipe_canonica eq on eq.ine = c.ine_vinculo
    left join watermark w on w.id_cidadao = c.id_cidadao

)

select * from final

{% if is_incremental() %}
where data_transmissao_referencia > (
    select coalesce(max(data_transmissao_referencia), date '1900-01-01') from {{ this }}
)
{% endif %}

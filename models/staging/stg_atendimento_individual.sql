{{ config(materialized='view') }} -- pra ser mais rapido no teste

with base as (

    select * from {{ ref('atendimento_individual') }} --referencia seed, se fosse uma tabela poderiamos usar source

),

deduplicado as (

    -- Achado #1: o mesmo atendimento se repete em até 4 transmissões mensais (reportar eng)
    -- Mantem so o registro da transmissão mais recente por PK
    select
        *,
        row_number() over (
            partition by co_seq_fat_atd_ind
            order by data_transmissao desc
        ) as rn

    from base

),

final as (

    select
        co_seq_fat_atd_ind                     as id_atendimento,
        co_fat_cidadao_pec                     as id_cidadao,
        trim(atend_ind_classificacao)          as classificacao,
        nu_ciap                                as ciap,
        trim(no_ciap)                          as nome_ciap,
        nu_cid                                 as cid,
        trim(no_cid)                           as nome_cid,
        trim(no_profissional)                  as nome_profissional,
        nu_cbo                                 as cbo,
        left(nu_cbo, 4)                        as cbo_familia,
        trim(no_cbo)                           as nome_cbo,
        trim(ds_local_atendimento)             as local_atendimento,
        trim(nu_ine)                           as ine_atendimento,
        trim(no_equipe)                        as nome_equipe_atendimento,
        dt_registro                            as dt_atendimento,
        data_transmissao,
        propriedades,
        versao

    from deduplicado
    where rn = 1
        -- Achado #2: nao contem so atendimento de med/enf (reportar eng)
        -- CBO conforme regra de negócio (med = 2231,2251,2252,2253 | enf = 2235)
        and left(nu_cbo, 4) in ('2231', '2251', '2252', '2253', '2235')

)

select * from final
{{ 
    config(
        materialized='view' 
        ) 
}} -- pra ser mais rapido no teste

with base as (

    select * from {{ ref('cidadao_pec') }} -- referencia seed, se fosse uma tabela poderiamos usar source

),

final as (

    select
        co_fat_cidadao_pec                             as id_cidadao,
        trim(no_cidadao)                               as nome_cidadao,
        dt_registro_nascimento                         as dt_nascimento,
        trim(ds_sexo)                                  as sexo,
        nu_cns                                         as cns,
        nu_cpf_cidadao                                 as cpf,
        nu_telefone_celular                            as telefone_celular,
        cast(st_faleceu as boolean)                    as st_faleceu,
        dt_ultima_atualizacao_cidadao                  as dt_ultima_atualizacao,
        cast(st_diabetes_diagnosticada as boolean)     as st_diabetes_diagnosticada_flag,
        cast(st_hipertensao_diagnosticada as boolean)  as st_hipertensao_diagnosticada_flag,
        trim(nu_ine)                                   as ine_vinculo,
        trim(no_equipe)                                as nome_equipe_vinculo,
        data_ultimo_atend_individual                   as dt_ultimo_atendimento,
        trim(equipe_ine_atendimento)                   as ine_ultimo_atendimento,
        trim(equipe_nome_atendimento)                  as nome_equipe_ultimo_atendimento,
        nu_atend_ubs_ultimos_12_meses                  as qt_atend_ubs_12m,
        data_transmissao

    from base

)

select * from final

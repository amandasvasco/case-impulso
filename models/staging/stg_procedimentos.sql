{{ config(materialized='view') }} -- pra ser mais rapido no teste

with base as (

    select * from {{ ref('procedimentos') }} -- referencia seed, se fosse uma tabela poderiamos usar source

),

deduplicado as (

    -- Achado #1: mesmo padrão de atendimento_individual — o mesmo
    -- Manter só o registro da transmissão mais recente por PK
    select
        *,
        row_number() over (
            partition by co_seq_fat_proced
            order by data_transmissao desc
        ) as rn

    from base

),

final as (

    select
        tabela                                                             as origem,
        co_seq_fat_proced                                                  as id_procedimento,
        co_fat_cidadao_pec                                                 as id_cidadao,
        co_proced,
        trim(ds_proced)                                                    as tipo_procedimento,
        trim(nu_ine)                                                       as ine_procedimento,
        trim(no_equipe)                                                    as nome_equipe_procedimento,
        trim(no_profissional)                                              as nome_profissional,
        nu_cbo                                                             as cbo,
        left(nu_cbo, 4)                                                    as cbo_familia,
        trim(no_cbo)                                                       as nome_cbo,
        dt_registro                                                        as dt_procedimento,
        -- Achado #3: qt_afericao_pressao_arterial vem sempre vazia
        -- o valor real está dentro do JSON `propriedades`
        json_extract_string(propriedades, '$.pressao_arterial')           as pressao_arterial,
        -- Achado #4: peso e altura já vêm juntos no mesmo registro/JSON.
        try_cast(json_extract_string(propriedades, '$.peso') as double)   as peso_kg,
        try_cast(json_extract_string(propriedades, '$.altura') as double) as altura_cm,
        data_transmissao,
        propriedades,
        versao

    from deduplicado
    where rn = 1

)

select * from final
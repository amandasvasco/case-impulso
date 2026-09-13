{{ config(materialized='table') }}

with elegiveis as (

    select id_cidadao
    from {{ ref('int_lista_nominal_elegibilidade') }}
    where elegivel

),

cidadaos as (

    select * from {{ ref('int_cidadao') }}

),

status as (

    select * from {{ ref('int_status_boas_praticas') }}

),

final as (

    select
        c.id_cidadao,
        c.nome_cidadao,
        c.cns,
        c.cpf,
        c.dt_nascimento,
        c.idade,

        c.telefone_celular,
        c.ine_equipe,
        c.nome_equipe,

        -- Gap de dado: nenhuma das 3 fontes brutas traz microárea.
        -- Coluna mantida (sempre nula) pra deixar a ausência visível no
        -- schema, não só documentada em texto (ver decisões/limitações).
        cast(null as varchar) as microarea,

        s.status_consulta,
        s.dt_ultima_consulta,

        s.status_afericao_pa,
        s.dt_ultima_afericao_pa,
        s.valor_ultima_afericao_pa,

        s.status_peso_altura,
        s.dt_ultima_peso_altura,
        s.valor_ultimo_peso_kg,
        s.valor_ultima_altura_cm

    from elegiveis e
    inner join cidadaos c on c.id_cidadao = e.id_cidadao
    left join status s on s.id_cidadao = e.id_cidadao

)

select * from final

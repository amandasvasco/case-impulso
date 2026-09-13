{{ config(materialized='table') }} -- materializa os status das boas praticas dos elegiveis

with elegiveis as (
    -- apenas elegiveis por regra de negocio aplicada na int
    select id_cidadao
    from {{ ref('int_lista_nominal_elegibilidade') }}
    where elegivel

),

consultas as (

    -- Consulta: qualquer classificação, 6 meses. CBO já filtrado no staging.
    select
        id_cidadao,
        max(dt_atendimento) as dt_ultima_consulta
    from {{ ref('stg_atendimento_individual') }}
    group by 1

),

afericoes_pa as (

    -- Aferição de PA: médico, enfermeiro, técnico de enfermagem. 6 meses.
    -- O protótipo da tela mostra o valor da última aferição junto do
    -- status/data (ex.: "110/90 mmHg") — arg_max traz o valor de
    -- pressao_arterial casado com o registro mais recente por cidadão.
    select
        id_cidadao,
        max(dt_procedimento) as dt_ultima_afericao_pa,
        arg_max(pressao_arterial, dt_procedimento) as valor_ultima_afericao_pa
    from {{ ref('stg_procedimentos') }}
    where tipo_procedimento = 'AFERIÇÃO DE PRESSÃO ARTERIAL'
      and cbo_familia in ('2231', '2251', '2252', '2253', '2235', '3222')
    group by 1

),

peso_altura as (

    -- Peso e altura: médico, enfermeiro, técnico de enfermagem, ACS. 12 meses.
    -- Peso e altura sempre vêm juntos no mesmo registro de procedimento
    -- (Achado: um único JSON por medição), então um arg_max por
    -- dt_procedimento já traz os dois valores consistentes entre si.
    select
        id_cidadao,
        max(dt_procedimento) as dt_ultima_peso_altura,
        arg_max(peso_kg, dt_procedimento) as valor_ultimo_peso_kg,
        arg_max(altura_cm, dt_procedimento) as valor_ultima_altura_cm
    from {{ ref('stg_procedimentos') }}
    where tipo_procedimento = 'MEDIÇÃO PESO E ALTURA'
      and cbo_familia in ('2231', '2251', '2252', '2253', '2235', '3222', '5151')
    group by 1

),

final as (

    select
        e.id_cidadao,

        c.dt_ultima_consulta,
        -- data_referencia definida no dbt_project.yml com base da documentacao ('2026-08-01')
        case
            when c.dt_ultima_consulta is null then 'NUNCA_REALIZADA'
            when c.dt_ultima_consulta >= cast('{{ var("data_referencia") }}' as date) - interval '6 months' then 'EM_DIA'
            else 'ATRASADA'
        end as status_consulta,

        p.dt_ultima_afericao_pa,
        p.valor_ultima_afericao_pa,
        case
            when p.dt_ultima_afericao_pa is null then 'NUNCA_REALIZADA'
            when p.dt_ultima_afericao_pa >= cast('{{ var("data_referencia") }}' as date) - interval '6 months' then 'EM_DIA'
            else 'ATRASADA'
        end as status_afericao_pa,

        a.dt_ultima_peso_altura,
        a.valor_ultimo_peso_kg,
        a.valor_ultima_altura_cm,
        case
            when a.dt_ultima_peso_altura is null then 'NUNCA_REALIZADA'
            when a.dt_ultima_peso_altura >= cast('{{ var("data_referencia") }}' as date) - interval '12 months' then 'EM_DIA'
            else 'ATRASADA'
        end as status_peso_altura

    from elegiveis e
    left join consultas c on c.id_cidadao = e.id_cidadao
    left join afericoes_pa p on p.id_cidadao = e.id_cidadao
    left join peso_altura a on a.id_cidadao = e.id_cidadao

)

select * from final

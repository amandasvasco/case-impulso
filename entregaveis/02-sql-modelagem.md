# 2. SQL da modelagem + números

## Dialeto

**DuckDB**, via um projeto dbt (models).
## Onde está o código

O SQL completo que produz `marts.lista_nominal_hipertensao` a partir dos 3 CSVs
está neste repositório, em `models/`:

- `models/staging/` — `stg_cidadao_pec`, `stg_atendimento_individual`,
  `stg_procedimentos`: 1 view por fonte bruta com tipagem e filtros estruturais.
- `models/intermediate/` — `int_lista_nominal_elegibilidade` (regra de
  entrada/saída da lista), `int_cidadao` (limpeza de nome/telefone/idade/
  equipe), `int_status_boas_praticas` (status + valores das 3 boas práticas).
- `models/marts/lista_nominal_hipertensao.sql` — junção final, 1 linha por
  cidadão elegível.

Roda sobre os 3 CSVs fornecidos via `dbt seed` + `dbt build` (ver `README.md`
na raiz do repositório para o passo a passo do ambiente).

## Números produzidos

**312 cidadãos** ficaram na lista nominal de hipertensão, de 341 que em algum
momento tiveram um atendimento classificado como HIPERTENSÃO por médico ou enfermeiro:

| Situação | Cidadãos |
|---|---|
| Elegíveis (na lista) | 312 |
| Excluídos — óbito | 6 |
| Excluídos — condição resolvida | 23 |
| **Total com histórico de HIPERTENSÃO** | **341** |

Distribuição de status das 3 boas práticas, entre os 312 elegíveis:

| Boa prática | EM_DIA | ATRASADA | NUNCA_REALIZADA |
|---|---|---|---|
| Consulta (6 meses) | 182 | 130 | 0 |
| Aferição de PA (6 meses) | 161 | 108 | 43 |
| Peso e Altura (12 meses) | 133 | 109 | 70 |

> Nenhum elegível está em `NUNCA_REALIZADA` para Consulta pois o próprio critério de entrada na lista exige um
> atendimento por médico/enfermeiro, então todo elegível já teve pelo menos
> uma consulta que conta pra essa boa prática.

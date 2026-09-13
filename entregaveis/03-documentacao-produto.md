# 3. Documentação para o time de produto — Lista Nominal de Hipertensão

## O que essa lista faz:
A Lista Nominal de Hipertensão traz, numa única linha por pessoa, todo cidadão
que a Equipe de Saúde da Família precisa acompanhar por hipertensão — com o
status de cada uma das 3 boas práticas de cuidado (Consulta, Aferição de
Pressão Arterial, Peso e Altura), pra equipe saber quem está em dia e quem
precisa de ação (ligar, agendar, priorizar visita do ACS).

**312 pessoas** estão na lista hoje, calculada com referência ao dia
01/08/2026.

## Regras de negócio adotadas:

**Quem entra na lista:** qualquer cidadão que já teve, em qualquer momento do
histórico, um atendimento classificado como hipertensão, registrado por
médico ou enfermeiro. Uma vez diagnosticado, o cidadão entra e só sai da lista mediante critérios abaixo. 


**Quem sai da lista:** o cidadão é removido se faleceu, ou se em algum
atendimento posterior a hipertensão foi marcada como condição resolvida. Das
341 pessoas com histórico de hipertensão, 6 saíram por óbito e 23 por
condição resolvida — sobrando as 312 da lista atual.

**As 3 boas práticas**, cada uma com sua própria janela de tempo e seu
próprio grupo de profissionais que podem realizá-la:

| Boa prática | Janela | Quem pode realizar |
|---|---|---|
| Consulta | 6 meses | Médico ou enfermeiro |
| Aferição de Pressão Arterial | 6 meses | Médico, enfermeiro ou técnico de enfermagem |
| Peso e Altura | 12 meses | Médico, enfermeiro, técnico de enfermagem ou agente comunitário de saúde |

Pra cada uma, o status é **Em dia** (feita dentro da janela), **Atrasada**
(feita, mas fora da janela) ou **Nunca realizada**.

## Decisões ambíguas — o que escolhi e o que descartei

**Equipe responsável pelo cidadão.** O cadastro traz duas equipes possíveis
por pessoa: a equipe de vínculo (quem é oficialmente responsável) e a equipe
do último atendimento (que pode ser diferente). Escolhi a **equipe de vínculo**, por ser quem de fato vai agir
sobre essa lista no dia a dia. Descartei usar a equipe do último atendimento
porque ela mudaria a lista de "minha equipe" a cada atendimento eventual em
outro lugar, o que não faz sentido operacionalmente.

**Nomes e telefones ausentes na origem.** Optei por **não inventar ou
mascarar** esses dados — quando o cadastro não tem nome ou o telefone não
tem formato válido, o campo fica vazio na lista, em vez de exibir um
placeholder que passaria a falsa impressão de dado completo. Ver limitação
abaixo.

**Grafia do nome da equipe.** As equipes aparecem grafadas de formas
diferentes ao longo do tempo (ex. "E.S.F. 1", "ESF 03", "ESF QUATRO"). Optei
por **padronizar a grafia de exibição pelo texto observado** (extraindo o
número e remontando como "ESF N"), mantendo o código interno da equipe (INE)
como identificador confiável por trás disso, caso exista uma futura possibilidade de criação de uma stage pras equipes.

**Peso e altura na lista, mesmo sem aparecer na tela do protótipo.** O
protótipo validado com produto mostra o valor da aferição de PA, mas não os
valores de peso e altura — só o status. Mesmo assim, mantive os valores
numéricos de peso e altura na tabela (não exibidos na tela hoje), por
considerar um dado clinicamente relevante que o produto pode querer exibir
no futuro sem precisar de mudança na modelagem.

## Limitações conhecidas

- **Sem microárea.** Nenhuma das 3 fontes de dados recebidas contém essa
  informação. A coluna existe na tabela final (sempre vazia) pra deixar a lacuna
  visível, mas o filtro por microárea previsto no protótipo não pode ser
  implementado com os dados disponíveis hoje.
- **18 cidadãos sem nome cadastrado** (9 deles estão entre os 312 da lista
  atual) — o cadastro de origem não tem o nome preenchido. Sem nome, a
  equipe não consegue identificar a pessoa pra agir sobre esses casos.

## Recomendações

- Priorizar, junto ao time de dados, a correção do cadastro de nome dos 18
  cidadãos afetados (ideal: cruzar por CPF ou CNS com outra base), revisando informações de contato.
- Avaliar se vale a pena capturar microárea na origem, já que o protótipo da
  tela já prevê esse filtro.
- Considerar exibir peso e altura na tela, já que o dado está disponível e é
  clinicamente relevante pro acompanhamento de hipertensão.

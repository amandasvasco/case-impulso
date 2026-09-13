# 5. Nota sobre uso de IA

Usei o Claude (Cowork) como par de trabalho durante todo o case: construção
do pipeline dbt (camadas staging/intermediate/marts, modelos incrementais,
testes), geração de documentação (`dbt docs`), e rascunho inicial dos 5
entregáveis escritos.

## O que aceitei

- A estrutura de camadas (staging → intermediate → marts) e a separação de
  responsabilidades entre `int_lista_nominal_elegibilidade`
  e `int_status_boas_praticas` — sugeridas pela IA, mas validadas e
  ajustadas por mim a cada passo (materialização, granularidade, quais
  campos ficam em qual camada).
- A redação inicial dos 5 entregáveis, revisando e aprovando cada um antes
  de salvar.

## O que rejeitei ou corrigi

- **Referenciar `stg_cidadao_pec` direto na mart**, em vez de criar o
  `int_cidadao`. A primeira proposta da IA levava os campos cadastrais do
  cidadão (nome, telefone, idade, equipe) direto da staging pra mart, já
  que só essa lista precisava deles naquele momento. Rejeitei: dado
  cadastral de cidadão vindo bruto tem problemas reais (nome/telefone
  sujos, grafia de equipe inconsistente) que qualquer lista nominal futura
  — não só a de hipertensão — vai precisar resolver do mesmo jeito. Isolar
  essa limpeza num `int_cidadao` próprio evita duplicar a mesma lógica em
  cada mart nova, e mantém a mart de hipertensão focada só na sua própria
  regra de negócio (elegibilidade e boas práticas).
- **O item "dedup por transmissão" na mensagem ao time de engenharia**
  (entregável 4). A IA sugeriu reportar como achado o fato de a camada
  bruta acumular múltiplas transmissões do mesmo registro ao longo do
  tempo. Corrigi: o próprio dicionário de dados, mantido pelo time de
  engenharia, já documenta esse comportamento como esperado (camada bruta
  tipo append-only, com uma carga completa seguida de cargas incrementais
  mensais). Lidar com isso — pegar a versão mais recente por entidade — é
  trabalho padrão de quem consome o dado (resolvido via modelagem
  incremental nos meus próprios modelos), não um defeito a reportar.
  Troquei esse item por um achado real: o valor de pressão arterial vem
  sempre vazio na coluna estruturada dedicada, escondido dentro de um
  campo JSON de texto livre.
- **Decisões de materialização** (ephemeral → table/incremental) em mais
  de um modelo, e a inclusão de dados que a IA havia deixado de fora nas
  primeiras versões (valores de PA, peso e altura) — pedi explicitamente
  antes de aplicar qualquer mudança no projeto.

# 4. Mensagem para o time de engenharia de dados

Oi, pessoal! Construí a Lista Nominal de Hipertensão a partir dos 3
extracts do e-SUS PEC e encontrei alguns problemas na origem que valem
correção. Os 3 que eu priorizaria:

**1. O valor da pressão arterial não vem na coluna dedicada para isso.**
Em `procedimentos`, a coluna estruturada `qt_afericao_pressao_arterial` vem
sempre vazia — o valor real (ex. "150/70") está escondido dentro do JSON de
`propriedades`, misturado com outros campos livres. Seria interessante que esses valores
estivessem mais visíveis para evitar passar despercebido por outros analistas.

**2. 18 dos 1.200 cidadãos (1,5%) estão sem nome cadastrado** — 9 deles
estão na lista de hipertensão ativa. Sem nome, fica difícil para a equipe identificar o cidadão
e agir sobre esses casos (ligar, identificar na visita). Sugiro
investigar se dá pra recuperar o nome cruzando por CPF ou CNS com outra
base cadastral, já que os dois costumam estar preenchidos mesmo quando o
nome não está.

**3. Nenhuma das 3 fontes traz microárea do cidadão.** A tela de produto já
prevê um filtro por microárea (confirmado no protótipo validado), mas esse
dado simplesmente não existe em nenhum dos extracts atuais. Sem isso, a
funcionalidade não pode ser implementada — vale entender se a microárea
está corretamente preenchida no PEC e-SUS e só não está sendo extraída, ou se
realmente não é capturada em nenhum lugar.

Posso detalhar qualquer um desses com mais contexto técnico se for útil.
Valeu! 
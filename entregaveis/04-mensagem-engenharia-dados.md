# 4. Mensagem para o time de engenharia de dados

**Canal: #dados-esus-pec**

Oi, pessoal! 👋 Construí a Lista Nominal de Hipertensão a partir dos 3
extracts do e-SUS PEC e encontrei alguns problemas na origem que valem
correção. Os 3 que eu priorizaria:

**1. Falta deduplicar por transmissão antes de consumir os dados.**
Os extracts trazem múltiplas transmissões do mesmo registro ao longo do
tempo, sem indicação de "última versão válida" — quem consome precisa saber
descartar transmissões antigas na mão (usei o campo de data de transmissão
como watermark). Isso é fácil de fazer errado silenciosamente: um consumidor
que não souber disso conta pessoas ou eventos em duplicidade sem perceber.
Sugiro documentar esse comportamento no dicionário de dados, ou já entregar
os extracts deduplicados na origem.

**2. 18 dos 1.200 cidadãos (1,5%) estão sem nome cadastrado** — 9 deles
estão na lista de hipertensão ativa. Sem nome, a equipe de saúde não
consegue agir sobre esses casos (ligar, identificar na visita). Sugiro
investigar se dá pra recuperar o nome cruzando por CPF ou CNS com outra
base cadastral, já que os dois costumam estar preenchidos mesmo quando o
nome não está.

**3. Nenhuma das 3 fontes traz microárea do cidadão.** A tela de produto já
prevê um filtro por microárea (confirmado no protótipo validado), mas esse
dado simplesmente não existe em nenhum dos extracts atuais. Sem isso, a
funcionalidade não pode ser implementada — vale entender se a microárea
existe em algum sistema de origem e só não está sendo extraída, ou se
realmente não é capturada em nenhum lugar.

**Bônus, rápido:** encontrei duas equipes com códigos (INE) diferentes —
portanto times distintos de verdade — mas que aparecem com o mesmo nome de
exibição "ESF 5" no cadastro. Não afeta a lista (uso o INE, não o nome, pra
diferenciar), mas vale corrigir na origem porque confunde quem olha o dado
bruto diretamente.

Posso detalhar qualquer um desses com mais contexto técnico se for útil.
Valeu! 🙏

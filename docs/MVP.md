# O MVP (Minimum Viable Product)

## Público inicial do MVP

O MVP seria direcionado ao microcultivador individual, entendido como uma pessoa que administra sozinha um cultivo pequeno e precisa substituir anotações dispersas, planilhas, galerias de fotos e lembretes improvisados por uma ferramenta única.

Esse usuário pode cultivar:
- Uma ou poucas plantas.
- Em ambiente interno, externo ou misto.
- De forma contínua ou ocasional.
- Com diferentes métodos, materiais e genéticas.
- Sem equipe, operação empresarial ou estrutura administrativa.

O aplicativo não precisa começar tentando administrar fazendas inteiras, associações, laboratórios e a estação agrícola da Lua. Primeiro ele precisa ser excelente para uma pessoa, algumas plantas e um celular.

## Proposta de valor do MVP

O MVP deve resolver sete problemas centrais:

### 1. Memória do cultivo
O cultivador consegue acompanhar tudo o que aconteceu com cada planta:
- Quando foi cadastrada.
- Em qual fase estava.
- Quando recebeu água ou alimentação.
- Quais materiais foram utilizados.
- Quais alterações foram observadas.
- Quais problemas ocorreram.
- Quais decisões foram tomadas.
- Qual foi o resultado final do ciclo.

O aplicativo transforma anotações soltas em um histórico pesquisável e comparável.

### 2. Organização diária
O usuário visualiza:
- Plantas ativas.
- Tarefas pendentes.
- Últimos registros.
- Próximos acompanhamentos.
- Materiais disponíveis.
- Eventos recentes.
- Alertas definidos pelo próprio usuário.

O app não deve tentar controlar automaticamente a planta como se biologia fosse um cron job. Ele organiza informações e auxilia decisões; o cultivador mantém o controle.

### 3. Conhecimento offline
O aplicativo inclui uma biblioteca local que pode ser acessada sem internet:
- Conceitos sobre fases da planta.
- Glossário.
- Organização do cultivo.
- Registro de condições ambientais.
- Segurança no uso e armazenamento de materiais.
- Identificação e documentação de ocorrências.
- Checklists personalizáveis.
- Conteúdo salvo pelo próprio usuário.

Essa biblioteca deve funcionar como referência, não como autoridade infalível.

### 4. Privacidade real
O usuário não precisa criar uma conta para utilizar as funções locais.
Os dados permanecem no aparelho e podem ser protegidos por:
- Senha ou PIN.
- Biometria.
- Banco de dados criptografado.
- Bloqueio automático.
- Backup criptografado.
- Remoção de metadados das fotografias.
- Exportação protegida por senha.
- Sincronização opcional, nunca obrigatória.

### 5. Aprendizado por dados próprios
O sistema apresenta estatísticas construídas exclusivamente a partir do histórico do usuário:
- Duração dos ciclos.
- Tempo em cada fase.
- Frequência de regas e registros.
- Consumo de materiais.
- Custos registrados.
- Ocorrências recorrentes.
- Comparação entre plantas.
- Comparação entre ciclos.
- Evolução ao longo do tempo.

O objetivo não é criar um ranking público de cultivadores. É permitir que cada pessoa aprenda com a própria experiência sem entregar seu histórico para alimentar publicidade, modelos externos ou algum dashboard corporativo faminto.

### 6. Motivo para registrar
Os cinco itens acima têm um pré-requisito silencioso: o usuário precisa registrar. Um diário abandonado na terceira semana não tem memória, não tem estatística e não tem o que analisar.

O MVP trata isso como funcionalidade, não como esperança:
- XP por evento registrado, com bônus por cada campo opcional preenchido.
- Nível e conquistas calculados sobre o histórico local.
- Completude por planta, com os campos faltantes nomeados um a um.
- Sequência de dias com registro, guardada como marca pessoal.

Tudo solitário, tudo local, nada que expire ou cobre. Sem ranking, sem competição, sem recurso preso atrás de nível — as restrições completas estão em [[Gamificacao]].

### 7. Análise sem entregar o cofre
O que o item 5 mostra em números, esta camada interpreta — no aparelho:
- Rega atrasada frente à cadência que a própria planta vinha tendo.
- Fase durando mais que o usual nas plantas anteriores do usuário.
- Medição que destoa da linha de base dele.
- Perfil incompleto, problema sem desfecho, ausência de fotografias recentes.
- Janela de colheita projetada dos ciclos que ele mesmo já fechou.

A camada determinística funciona em qualquer aparelho, sem baixar nada. Modelos maiores — visão para triagem de sintoma foliar, linguagem para perguntar ao próprio diário — são download opcional e removível. Nenhuma inferência remota, em nenhuma hipótese, detalhado em [[IA]].

Veja também: [[Funcionalidades]]

# Gerência de estado

Decisão tomada em 2026-08-23, antes de quebrar `quick_log_forms.dart` (1.236 linhas)
e `plant_wizard_screen.dart` (1.097 linhas).

## Decisão

**Nenhuma biblioteca de gerência de estado.** O projeto continua em Flutter puro:

| Necessidade | Ferramenta | De onde vem |
|---|---|---|
| Injeção de dependência (repositório, `RouteObserver`) | `AppScope`, um `InheritedWidget` | SDK |
| Estado efêmero de uma tela (passo atual, texto digitado, "salvando…") | `State` + `setState` | SDK |
| Regra que decide o que a tela mostra | classe Dart pura, sem `import` de Flutter | — |
| Recarregar uma lista ao voltar para ela | `RouteAware` + `RouteObserver` | SDK |

O que muda com esta decisão não é a ferramenta, é **onde a regra mora**: sai de dentro
do `State` e vira código puro (`WizardMachine`, `QuickLogInput`), que a tela consulta.
`setState` volta a ser o que deveria ser — o aviso de "redesenhe" — em vez do lugar
onde a lógica do produto acontece.

## Por quê

**1. O app não tem o problema que essas bibliotecas resolvem.**
Riverpod, BLoC e afins existem para coordenar estado assíncrono compartilhado entre
telas distantes: cache de rede, invalidação, race condition de request, sessão de
usuário. O GrowCipher é offline-first, sem conta e sem rede (`docs/Principios.md`):
a única fonte de dados é o SQLite local, sempre disponível, sempre coerente, acessado
por telas que já recarregam sozinhas ao voltar ao topo da pilha. Não há estado global
compartilhado além do próprio repositório — e esse já é injetado pelo `AppScope`.

**2. F-Droid cobra por dependência.**
A distribuição alvo compila a partir do fonte e audita a árvore de dependências. Hoje
o `pubspec.lock` tem 51 pacotes, dos quais 6 são dependências diretas de produção
(`cupertino_icons`, `flutter_localizations`, `intl`, `path`, `sqflite` e o próprio
`flutter`). Cada pacote novo é mais superfície para revisar, mais chance de um
`flutter pub get --enforce-lockfile` quebrar na CI e mais uma peça a acompanhar.
Bibliotecas com geração de código (`riverpod_generator`, `freezed`) trazem junto o
`build_runner` e um passo de build que precisaria virar verificação na CI — o
equivalente ao que o job "Localização em dia" já faz pelo `flutter gen-l10n`, mas
para milhares de linhas geradas em vez de rótulos.

**3. Mantenedor solo.**
Uma pessoa mantém 36 arquivos Dart. O custo de uma biblioteca de estado não é
instalá-la: é aprender o modelo mental, migrar o que existe, e conviver com a
migração pela metade quando a próxima fase do roadmap chegar. `setState` +
código puro não tem versão maior quebrando, não tem lint próprio, não tem
`ref.watch` chamado no lugar errado.

**4. O tamanho dos arquivos não vinha da falta de biblioteca.**
Este é o ponto que decidiu. As 1.236 linhas de `quick_log_forms.dart` são 12 formulários
no mesmo arquivo; as 1.097 de `plant_wizard_screen.dart` são 10 passos no mesmo `State`.
Riverpod não separaria nenhum dos dois — só trocaria `setState` por `ref.watch` dentro
dos mesmos arquivos gigantes. O que separa é **contrato + um arquivo por peça**, e isso
é decisão de arquitetura, não de dependência.

## O que foi implementado com essa decisão

- `lib/features/quick_log/forms/quick_log_input.dart` — contrato comum: uma entrada de
  formulário (`QuickLogInput`) sabe dizer o que falta (`validate()`) e materializar a
  gravação (`build(stamp)` → `QuickLogSubmission`). Puro: nenhum `import` de Flutter.
- `lib/features/quick_log/forms/*.dart` — um arquivo por tipo de acontecimento, cada um
  com a entrada pura daquele tipo e o widget que a preenche.
- `lib/features/plant_wizard/wizard_machine.dart` — a máquina dos 9 passos: índice atual,
  transições (`selectStartingPoint`, `answerGenetics`, `selectIrrigationMode`…) e as
  regras que dependem do ponto de partida (origens oferecidas, datas extras, pergunta do
  passo de datas). Puro: nenhum `import` de Flutter.
- `lib/features/plant_wizard/steps/*.dart` — um arquivo por passo, só renderização.

## Quando revisitar

Esta decisão não é permanente. Os gatilhos que a invalidariam, em ordem de proximidade
com o roadmap:

- **Sincronização entre aparelhos ou backup em nuvem.** Aí existe estado assíncrono
  compartilhado de verdade, com conflito e retry, e `setState` deixa de bastar.
- **Estado global que muda fora de uma tela** — por exemplo, o cofre criptografado
  (Phase 2) bloqueando por inatividade e obrigando toda tela aberta a reagir. Um
  `ValueNotifier` no `AppScope` resolve o primeiro caso desses; do terceiro em diante,
  vale reabrir a conversa.
- **Mais de um mantenedor.** Convenção compartilhada passa a valer mais do que
  economia de dependência.

Se chegar a hora, o caminho mais barato a partir daqui é `ValueNotifier`/`ChangeNotifier`
com `ListenableBuilder` — ainda SDK, zero pacotes — e só depois uma biblioteca. Como a
regra já está em código puro, trocar quem chama `setState` não toca em nenhuma delas.

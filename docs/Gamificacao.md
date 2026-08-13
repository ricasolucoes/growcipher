# Gamificação

Pilar do produto, não enfeite: a qualidade de tudo que o GrowCipher entrega — estatísticas, comparação entre ciclos, análise no aparelho — depende de quanto o usuário registra. A gamificação existe para tornar o registro detalhado um hábito.

As restrições que a mantêm honesta estão em [[Principios]] → *Progressão local*: sem ranking, sem urgência artificial, sem funcionalidade travada, derivada da linha do tempo e premiando honestidade. O que segue é o desenho.

---

## 1. A tese

Um diário de cultivo falha por um motivo previsível: o usuário registra bem por duas semanas, depois só rega e esquece o resto. Seis meses depois o histórico é uma lista de regas sem contexto, e nenhuma estatística tira conclusão disso.

A camada de progressão ataca isso em três frentes:

1. **XP por detalhe** — cada campo opcional preenchido vale pontos. Registrar "reguei" vale menos que registrar "reguei 1,5 L de solução com pH 6,2".
2. **Completude por planta** — cada planta tem um retrato de quanto do perfil está preenchido, com o que falta listado nominalmente.
3. **Sequência de dias** — registrar hoje mantém a sequência. Perdê-la não punir nada; a sequência mais longa fica guardada como marca pessoal.

## 2. XP

### Fontes

| Fonte | Quando | Valor |
|---|---|---|
| `eventLogged` | Qualquer evento na linha do tempo | Base por tipo (tabela abaixo) |
| `fieldDetail` | Por campo opcional preenchido no evento | 4 XP cada |
| `noteWritten` | Nota livre não vazia no evento | 3 XP |
| `profileCompleted` | Marcos de completude do perfil (50%, 80%, 100%) | 40 / 60 / 100 XP |
| `streakDay` | Primeiro registro de um dia novo | 10 XP + 2 por dia de sequência, teto de 50 |
| `achievement` | Conquista destravada | Definido por conquista |

### Base por tipo de evento

| Evento | XP | Evento | XP |
|---|---|---|---|
| `plantCreated` | 50 | `phaseChanged` | 25 |
| `germinated` | 20 | `photoAdded` | 15 |
| `watered` | 8 | `observationAdded` | 10 |
| `fed` | 10 | `problemReported` | 15 |
| `treatmentApplied` | 12 | `taskCompleted` | 8 |
| `measurementAdded` | 12 | `harvested` | 80 |
| `transplanted` | 20 | `plantEnded` | 30 |

`problemReported` e `plantEnded` valem bem de propósito. O usuário que registra a planta que morreu está entregando o dado mais valioso do histórico dele, e o aplicativo não vai punir isso com silêncio.

Um `measurementAdded` com temperatura, umidade, pH, EC, VPD e DLI preenchidos vale 12 + 6×4 = **36 XP** contra os 12 de um registro vazio. É aí que a agulha se move.

### Níveis

XP acumulado para alcançar o nível L: **25 × (L−1) × L**.

| Nível | XP total | Nível | XP total |
|---|---|---|---|
| 1 | 0 | 6 | 750 |
| 2 | 50 | 7 | 1.050 |
| 3 | 150 | 8 | 1.400 |
| 4 | 300 | 10 | 2.250 |
| 5 | 500 | 20 | 9.500 |

Curva quadrática: o começo é rápido o suficiente para o primeiro cadastro já subir dois níveis, e a progressão desacelera sem nunca travar. Não há nível máximo.

## 3. Completude do perfil

Cada planta recebe uma pontuação de 0 a 100% sobre um conjunto de itens ponderados. O que falta aparece nomeado — "falta a genética", "falta o volume do vaso" — porque uma barra de progresso sem lista de pendências é decoração.

| Item | Peso | Item | Peso |
|---|---|---|---|
| Nome ou apelido | 1 | Local do ambiente | 1 |
| Fotografia | 2 | Nome do ambiente | 1 |
| Genética / variedade | 2 | Substrato | 2 |
| Tipo genético | 1 | Tipo de recipiente | 1 |
| Origem | 1 | Volume do recipiente | 1 |
| Detalhe da origem | 1 | Modo de irrigação | 1 |
| Data de início | 2 | Sistema de irrigação | 1 |
| Ambiente | 2 | Fase atual definida | 2 |

Itens condicionais entram conforme o ponto de partida: semente pede data de obtenção; clone pede data de enraizamento.

Marcos em 50%, 80% e 100% pagam XP uma única vez por planta.

## 4. Conquistas

Catálogo em seis famílias, com níveis bronze/prata/ouro onde faz sentido. Todas avaliadas sobre contadores locais.

**Cadastro** — primeira planta · 3 plantas · 10 plantas · 25 plantas · primeiro perfil 100% completo · 5 perfis 100% completos.

**Registro** — primeiro evento · 10 · 100 · 500 · 1.000 eventos · 50 eventos com todos os campos opcionais preenchidos.

**Consistência** — sequência de 3 · 7 · 30 · 100 dias · sequência recuperada depois de quebrada.

**Cuidado** — 5 · 25 · 100 fotografias · 10 · 50 · 200 medições · 10 tratamentos registrados.

**Ciclo** — primeira mudança de fase · todas as fases registradas em uma mesma planta · primeira colheita · 5 colheitas · primeiro ciclo encerrado com peso seco informado.

**Curadoria** — 5 problemas registrados (honestidade) · um problema com foto e desfecho registrado · uma planta com mais de 100 eventos · 3 ciclos completos comparáveis entre si.

Conquistas destravadas nunca são removidas, nem quando o dado que as gerou é editado. O que foi conquistado, foi.

## 5. O que está proibido

Registro explícito, para não reabrir a discussão a cada nova ideia de engajamento:

- Ranking, liga, comparação entre usuários, perfil público, compartilhamento automático de conquista.
- Notificação de cobrança ("você não registra há 3 dias"), contagem regressiva, sequência que expira, XP que decai.
- Moeda virtual, loja, item cosmético pago, recurso destravável por nível.
- Barra de progresso sem lista do que falta.
- Recompensa por abrir o aplicativo sem registrar nada.
- Qualquer métrica de progresso enviada para fora do aparelho.

## 6. Arquitetura

A camada é **derivada e reconstruível**. O ledger de XP guarda cada concessão com origem (`event_id`, `plant_id`, fonte, valor), o que permite recalcular o estado inteiro a partir da linha do tempo se o esquema mudar.

- `lib/domain/gamification/` — regras puras: tabela de XP, curva de nível, completude, catálogo de conquistas, motor de avaliação. Sem I/O, sem Flutter, testável direto.
- `lib/data/sqlite_gamification_repository.dart` — persistência (estado, ledger, contadores, conquistas) no mesmo banco local, esquema v2.
- Textos de conquista e de insight ficam em ARB, como todo o resto da interface: o domínio emite identificador tipado, a interface traduz.

Ver também: [[IA]] (a análise no aparelho consome a mesma densidade de histórico que a gamificação incentiva), [[Funcionalidades]] e [[Principios]].

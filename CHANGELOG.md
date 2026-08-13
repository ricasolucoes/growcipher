# Release Notes

---

## [Futuro]

### ✨ Novidades

- [ ] **Cofre criptografado** — SQLite com SQLCipher, chave mestra no Keystore/Secure Enclave, bloqueio por PIN e biometria (Phase 2)
- [ ] **Fotos privadas** — captura, remoção de EXIF offline e armazenamento fora da galeria do sistema (Phase 4)
- [ ] **Exportação e relatórios** — estatísticas locais e backup criptografado por senha (Phase 5)

## [Unreleased](https://github.com/ricardosierra/growcipher/compare/main...develop)

> 🌱 **Phase 1 — Setup e infraestrutura base:** bootstrap do projeto Flutter, documentação e planejamento versionados, e limpeza dos placeholders deixados pelo `flutter create`.
>
> 🪴 **Phase 3 — Onboarding de planta e registro rápido:** primeiro fluxo real do produto — cadastrar uma planta e registrar o que acontece com ela, tudo offline e em português.

### ✨ Novidades

- [x] **Bootstrap do projeto Flutter** — scaffold Dart com targets Android, iOS, macOS, Linux, Windows e web, sob o identificador `com.growcipher.growcipher`
- [x] **Home do aplicativo** — `GrowCipherApp` com temas light e dark em Material 3 e `HomeScreen` como placeholder do painel diário
- [x] **Idioma pt-BR** — internacionalização oficial do Flutter com ARB (`lib/l10n/app_pt.arb`), `Locale('pt', 'BR')` como padrão e nenhum texto de interface fora da camada de localização
- [x] **Wizard de cadastro de planta** — 9 passos curtos com uma decisão por tela, ramificando por ponto de partida (semente, muda, clone, planta em andamento); origem, datas e fase se adaptam à resposta e quase todo campo aceita "Não sei"
- [x] **Código local de privacidade** — identificador discreto `GC-XXXX` gerado no aparelho com `Random.secure` e alfabeto sem caracteres ambíguos, para uso sem identificação nominal
- [x] **Tela de revisão e criação** — mostra apenas o que foi preenchido, cada seção volta ao passo correspondente, e a confirmação grava planta e evento inicial na mesma transação
- [x] **Registro rápido** — menu "O que aconteceu?" com 12 ações (rega, alimentação, tratamento, medição, transplante, mudança de fase, foto, observação, problema, tarefa, colheita e encerramento), cada uma salvável em segundos
- [x] **Linha do tempo da planta** — perfil com dados estáveis e histórico cronológico por tipo de evento, com ícone e resumo próprios
- [x] **Banco local** — SQLite via `sqflite` com esquema versionado por migrations aditivas (`plants` e `plant_events`)

### 🎨 Melhorias

- [x] **Identidade visual provisória** — seed color verde sóbria (`#2E6B4F`) substitui o `deepPurple` do template; `theme_color` do manifest web deixa de ser o azul do Flutter. A paleta definitiva é entregável de design (`docs/Design.md` §5.3)
- [x] **Nome de exibição** — "GrowCipher" nas cinco plataformas nativas e no web, no lugar do `growcipher` minúsculo gerado pelo scaffold

### 🔧 Técnico

**Documentação:** vault Obsidian em `docs/` (visão, posicionamento, princípios, funcionalidades, MVP e consolidação de design) e planejamento GSD em `.planning/` (`PROJECT.md` e `ROADMAP.md` com as 5 fases).

**Design:** design system **Sovereign Vault** gerado no Google Stitch a partir de `docs/Design.md` e exportado para `docs/design/` — v1 final (`DESIGN.md` + 7 telas: onboarding, wizard de cadastro em 4 passos, menu de registro rápido e rega) e ideias de telas em dois temas (home, perfil com linha do tempo, galeria privada e variação de onboarding), com proposta de logo 1024×1024. Índice e mapeamento para as telas do MVP em `docs/design/README.md`.

**Toolchain:** projeto fixado no Flutter 3.44.9 / Dart 3.12.2 via `.tool-versions`, vindo do 3.19.6 (abril/2024) que travava 24 pacotes em versões antigas. Com o SDK novo, `flutter_lints` sobe de 3 para 6 e as dependências passam a resolver nas versões atuais — pré-requisito para escolher os plugins de SQLCipher e biometria da Phase 2.

**Modelo de domínio:** `Plant` guarda só os dados estáveis; os acontecimentos vivem em `PlantEvent`, uma hierarquia `sealed` com payload tipado por subtipo (nada de `Map<String, dynamic>` solto). `phase` e `status` permanecem no `Plant` como snapshot de leitura, mas só mudam pelo repositório, que grava `phaseChanged`/`plantEnded` na mesma transação — o histórico nunca é sobrescrito e morte ou colheita não apagam nada.

**Estado do wizard:** as respostas ficam em um `PlantDraft` em memória, materializado em `Plant` apenas na confirmação; nenhuma planta incompleta chega ao banco. Campo não respondido (`null`) e "não sei" (`unknown`) são representações distintas.

**Persistência:** `AppDatabase` versiona o esquema em migrations aditivas aplicadas por `onCreate`/`onUpgrade` a partir da mesma lista, sem recriação destrutiva. Enum desconhecido em registro gravado por versão futura cai em fallback em vez de estourar.

**Fotos:** o domínio referencia imagens por um `photoRef` opaco emitido pelo contrato `PhotoStore`, sem implementação nem chamada de rede — a captura entra na Phase 4 sem tocar nas telas.

- [x] Versão inicial `0.1.0+1` (o `flutter create` gera `1.0.0+1`)
- [x] `description` do pubspec, do manifest web e do `index.html` descrevem o produto
- [x] Injeção de dependências por `InheritedWidget` (`AppScope`) e navegação por rotas nomeadas — sem biblioteca de state management
- [x] 85 testes cobrindo domínio, persistência (roundtrip dos 14 tipos de evento) e os caminhos do wizard, do registro rápido e das telas pequenas

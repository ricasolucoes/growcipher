# Release Notes

---

## [Futuro]

### ✨ Novidades

- [ ] **Cofre criptografado** — SQLite com SQLCipher, chave mestra no Keystore/Secure Enclave, bloqueio por PIN e biometria (Phase 2)
- [ ] **Fotos privadas** — captura, remoção de EXIF offline e armazenamento fora da galeria do sistema (Phase 4)
- [ ] **Exportação e relatórios** — estatísticas locais e backup criptografado por senha (Phase 5)

## [Unreleased](https://github.com/ricardosierra/growcipher/compare/v0.2.0...master)

> ⚙️ **Primeira CI do projeto.** Até aqui o repositório caminhava para distribuição pública — `fastlane/metadata` pronto, receita de F-Droid escrita — sem nenhuma verificação automática rodando.

### ✨ Novidades

- [x] **Pipeline de integração** — `.github/workflows/ci.yml` roda em push na `master` e em todo pull request: formatação, conferência de que o l10n gerado está em dia com o ARB, `flutter analyze --fatal-infos`, `flutter test --coverage` com o lcov publicado como artifact, e o build do APK de release num job paralelo
- [x] **Release por tag** — `.github/workflows/release.yml` dispara em tag SemVer completa, gera o `app-release.apk` (nome que a receita F-Droid espera) e publica o SHA256 no corpo da release e num anexo `.sha256`
- [x] **Verificação de reprodutibilidade** — `.github/workflows/reprodutibilidade.yml` compila duas vezes do zero, compara os SHA256 e, se divergirem, lista quais entradas do APK mudaram
- [x] **Assinatura opcional no release** — havendo os secrets da keystore o APK sai assinado; sem eles a release nasce como rascunho, porque o Android recusa instalar APK sem assinatura

### 🎨 Melhorias

- [x] **`tool/check_format.sh`** — o mesmo checador que a CI roda, com `--fix` para consertar no lugar; `lib/l10n/generated` fica de fora por ser código gerado
- [x] **Trava de tag** — o release confere que a tag bate com o `version:` do `pubspec.yaml` antes de compilar, e só aceita `vX.Y.Z`
- [x] **Toolchain fixo na CI** — Flutter 3.44.9 e `flutter pub get --enforce-lockfile`, iguais aos da receita F-Droid e do `.tool-versions`

### 🐛 Correções

- [x] Receita F-Droid sem o `commit: 0000…` placeholder — os builds `0.1.0` e `0.2.0` apontam para os commits reais das tags correspondentes
- [x] Tag `v1.0` fora do SemVer, apontando para um commit de bookkeeping cujo `pubspec.yaml` estava em `0.1.0+1` — arquivada como `arquivo/marco-v1.0`
- [x] 11 arquivos Dart fora do `dart format`, que reprovariam a CI no primeiro pull request
- [x] `coverage/` deixa de ficar solto como arquivo não rastreado depois de `flutter test --coverage`

### 🔧 Técnico

**Reprodutibilidade:** medida, não estimada — o resultado está em `docs/reprodutibilidade.md`. Dois builds limpos no mesmo caminho produzem o mesmo APK byte a byte. Em caminhos diferentes, não: o snapshot AOT do Dart embute o `file://` absoluto do projeto, e 1.536.586 dos 6.292.368 bytes do `libapp.so` arm64 mudam. `--split-debug-info` com `--obfuscate` também não resolve. Os timestamps do ZIP não são fonte de variação — o AGP já normaliza tudo para `1981-01-01`.

**F-Droid:** como o buildserver do F-Droid e o runner do GitHub compilam em caminhos diferentes por construção, `Binaries:` nunca passaria na verificação de reprodutibilidade. A receita passou a compilar **a partir do fonte**, e com isso saíram `Binaries:` e o `AllowedAPKSigningKeys: 0000…`, que também estava com placeholder. O `UpdateCheckMode` foi de `Tags ^v.*$` para `Tags ^v\d+\.\d+\.\d+$`, que ignora tags malformadas. O build `0.1.0` entrou com `disable:`: o commit da tag `v0.1.0` só existe na branch local `release/mvp` e nunca foi enviado ao `origin`.

## [v0.2.0 (2026-08-22)](https://github.com/ricardosierra/growcipher/releases/tag/v0.2.0)

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
- [x] **Progressão local** — domínio de conquistas e níveis calculado no próprio aparelho, alimentado pela linha do tempo da planta e persistido no esquema v2 do banco local
- [x] **IA no aparelho (camada 1)** — `InsightEngine` determinístico que lê apenas o histórico local e devolve observações acompanhadas da evidência que as sustenta, sem nenhuma chamada de rede

### 🎨 Melhorias

- [x] **Identidade visual provisória** — seed color verde sóbria (`#2E6B4F`) substitui o `deepPurple` do template; `theme_color` do manifest web deixa de ser o azul do Flutter. A paleta definitiva é entregável de design (`docs/Design.md` §5.3)
- [x] **Nome de exibição** — "GrowCipher" nas cinco plataformas nativas e no web, no lugar do `growcipher` minúsculo gerado pelo scaffold
- [x] **Identidade do aplicativo** — `applicationId` e `namespace` passam de `com.growcipher.growcipher` para `com.sierratecnologia.growcipher`, com o mesmo identificador refletido em Android, iOS, macOS, Linux e Windows
- [x] **Material de loja** — ícones do launcher, feature graphic, capturas de tela em `assets/store/` e metadados fastlane em pt-BR (`fastlane/metadata/android/pt-BR/`) para publicação em lojas de código aberto
- [x] **README público** — reescrito com posicionamento, o que já funciona hoje e o que ainda é roadmap, sem anunciar recurso futuro como pronto
- [x] **Backup do sistema desligado** — `android:allowBackup="false"` impede que o histórico local saia do aparelho pelo backup automático do Android

### 🐛 Correções

- [x] Home recarrega a lista quando uma rota empilhada é fechada
- [x] Trocar o ponto de partida no wizard descarta o detalhe de origem que deixou de fazer sentido
- [x] Botão de salvar volta a ficar disponível quando a gravação local falha
- [x] Menu do registro rápido não corta mais o rótulo em tela estreita

### 🔧 Técnico

**Documentação:** vault Obsidian em `docs/` (visão, posicionamento, princípios, funcionalidades, MVP e consolidação de design) e planejamento GSD em `.planning/` (`PROJECT.md` e `ROADMAP.md` com as 5 fases).

**Design:** design system **Sovereign Vault** gerado no Google Stitch a partir de `docs/Design.md` e exportado para `docs/design/` — v1 final (`DESIGN.md` + 7 telas: onboarding, wizard de cadastro em 4 passos, menu de registro rápido e rega) e ideias de telas em dois temas (home, perfil com linha do tempo, galeria privada e variação de onboarding), com proposta de logo 1024×1024. Índice e mapeamento para as telas do MVP em `docs/design/README.md`.

**Toolchain:** projeto fixado no Flutter 3.44.9 / Dart 3.12.2 via `.tool-versions`, vindo do 3.19.6 (abril/2024) que travava 24 pacotes em versões antigas. Com o SDK novo, `flutter_lints` sobe de 3 para 6 e as dependências passam a resolver nas versões atuais — pré-requisito para escolher os plugins de SQLCipher e biometria da Phase 2.

**Modelo de domínio:** `Plant` guarda só os dados estáveis; os acontecimentos vivem em `PlantEvent`, uma hierarquia `sealed` com payload tipado por subtipo (nada de `Map<String, dynamic>` solto). `phase` e `status` permanecem no `Plant` como snapshot de leitura, mas só mudam pelo repositório, que grava `phaseChanged`/`plantEnded` na mesma transação — o histórico nunca é sobrescrito e morte ou colheita não apagam nada.

**Estado do wizard:** as respostas ficam em um `PlantDraft` em memória, materializado em `Plant` apenas na confirmação; nenhuma planta incompleta chega ao banco. Campo não respondido (`null`) e "não sei" (`unknown`) são representações distintas.

**Persistência:** `AppDatabase` versiona o esquema em migrations aditivas aplicadas por `onCreate`/`onUpgrade` a partir da mesma lista, sem recriação destrutiva. Enum desconhecido em registro gravado por versão futura cai em fallback em vez de estourar.

**Fotos:** o domínio referencia imagens por um `photoRef` opaco emitido pelo contrato `PhotoStore`, sem implementação nem chamada de rede — a captura entra na Phase 4 sem tocar nas telas.

- [x] Versão `0.2.0+2` no `pubspec.yaml` — `versionName` 0.2.0 e `versionCode` 2 no APK (o `flutter create` gera `1.0.0+1`)
- [x] `description` do pubspec, do manifest web e do `index.html` descrevem o produto
- [x] Injeção de dependências por `InheritedWidget` (`AppScope`) e navegação por rotas nomeadas — sem biblioteca de state management
- [x] 85 testes cobrindo domínio, persistência (roundtrip dos 14 tipos de evento) e os caminhos do wizard, do registro rápido e das telas pequenas

**Licença:** o projeto passa a declarar licença explícita — arquivo `LICENSE` com o texto MIT completo, Copyright (c) 2026 Ricardo Sierra. Até aqui o repositório era público mas sem licença, o que impedia redistribuição (e a inclusão em repositórios de software livre).

**Assinatura de release:** o buildType `release` deixa de usar a keystore de debug. A `signingConfig` de release só é criada quando existe `android/key.properties`; sem ela o APK sai não assinado, e a assinatura fica a cargo de quem publica. Isso torna `flutter build apk --release` reproduzível em ambiente sem keystore, como o buildserver do F-Droid.

**Higiene do repositório:** `graphify-out/` (saída de ferramenta de análise) entra no `.gitignore` em vez de ser versionado. Keystore e `key.properties` continuam fora do controle de versão por `android/.gitignore`.

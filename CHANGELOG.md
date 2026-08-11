# Release Notes

---

## [Futuro]

### ✨ Novidades

- [ ] **Cofre criptografado** — SQLite com SQLCipher, chave mestra no Keystore/Secure Enclave, bloqueio por PIN e biometria (Phase 2)
- [ ] **Gestão de plantas** — cadastro, genética, linha do tempo de eventos e registro rápido de rega e nutrição (Phase 3)
- [ ] **Fotos privadas** — captura, remoção de EXIF offline e armazenamento fora da galeria do sistema (Phase 4)
- [ ] **Exportação e relatórios** — estatísticas locais e backup criptografado por senha (Phase 5)

## [Unreleased](https://github.com/ricardosierra/growcipher/compare/main...develop)

> 🌱 **Phase 1 — Setup e infraestrutura base:** bootstrap do projeto Flutter, documentação e planejamento versionados, e limpeza dos placeholders deixados pelo `flutter create`.

### ✨ Novidades

- [x] **Bootstrap do projeto Flutter** — scaffold Dart com targets Android, iOS, macOS, Linux, Windows e web, sob o identificador `com.growcipher.growcipher`
- [x] **Home do aplicativo** — `GrowCipherApp` com temas light e dark em Material 3 e `HomeScreen` como placeholder do painel diário

### 🎨 Melhorias

- [x] **Identidade visual provisória** — seed color verde sóbria (`#2E6B4F`) substitui o `deepPurple` do template; `theme_color` do manifest web deixa de ser o azul do Flutter. A paleta definitiva é entregável de design (`docs/Design.md` §5.3)
- [x] **Nome de exibição** — "GrowCipher" nas cinco plataformas nativas e no web, no lugar do `growcipher` minúsculo gerado pelo scaffold

### 🔧 Técnico

**Documentação:** vault Obsidian em `docs/` (visão, posicionamento, princípios, funcionalidades, MVP e consolidação de design) e planejamento GSD em `.planning/` (`PROJECT.md` e `ROADMAP.md` com as 5 fases).

**Design:** design system **Sovereign Vault** gerado no Google Stitch a partir de `docs/Design.md` e exportado para `docs/design/` — v1 final (`DESIGN.md` + 7 telas: onboarding, wizard de cadastro em 4 passos, menu de registro rápido e rega) e ideias de telas em dois temas (home, perfil com linha do tempo, galeria privada e variação de onboarding), com proposta de logo 1024×1024. Índice e mapeamento para as telas do MVP em `docs/design/README.md`.

**Toolchain:** projeto fixado no Flutter 3.44.9 / Dart 3.12.2 via `.tool-versions`, vindo do 3.19.6 (abril/2024) que travava 24 pacotes em versões antigas. Com o SDK novo, `flutter_lints` sobe de 3 para 6 e as dependências passam a resolver nas versões atuais — pré-requisito para escolher os plugins de SQLCipher e biometria da Phase 2.

- [x] Versão inicial `0.1.0+1` (o `flutter create` gera `1.0.0+1`)
- [x] `description` do pubspec, do manifest web e do `index.html` descrevem o produto
- [x] Testes de widget cobrem o boot do app e a configuração de tema

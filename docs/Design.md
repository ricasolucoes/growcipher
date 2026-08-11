# GrowCipher — Consolidação de Design

Documento único de contexto para geração de design (Claude Design). Consolida: identidade do produto, público, inventário completo de todas as imagens existentes no projeto, assets que precisam ser criados e o mapa de telas do MVP.

> **Estado atual:** o projeto é um scaffold Flutter recém-criado. **Não existe nenhuma arte própria ainda** — todas as 36 imagens do repositório são placeholders padrão do Flutter (logo do Flutter como ícone). Todo o design visual está por ser criado.

---

## 1. O Produto

**Pitch de uma frase:** O cofre digital do cultivador de cannabis: privado, offline, criptografado e sob controle exclusivo do usuário.

**Versão curta:** Um diário de cultivo mundial, offline e criptografado para produtores de cannabis. Registre plantas, ciclos, regas, alimentação, ambiente, materiais, custos e resultados com controle total sobre seus dados.

**Landing page:**
- Título: *Seu cultivo. Seus dados. Suas decisões.*
- Subtítulo: *Registre e acompanhe suas plantas em um aplicativo mundial, offline-first e criptografado, desenvolvido para proteger a autonomia e a privacidade do cultivador.*

**Conceito central:** não é um app de cultivo com criptografia adicionada depois — é **um cofre criptografado construído ao redor da experiência de cultivar**.

## 2. Público-alvo

Microcultivador individual: uma pessoa administrando sozinha um cultivo pequeno (uma ou poucas plantas, indoor/outdoor/misto), que quer substituir anotações dispersas, planilhas, galeria de fotos e lembretes improvisados por uma ferramenta única. Sem equipe, sem operação empresarial. "Primeiro ele precisa ser excelente para uma pessoa, algumas plantas e um celular."

## 3. Identidade e Tom

**Três fundamentos:** autonomia individual · funcionamento offline · criptografia real.

**Atributos que o design deve comunicar:**
- **Cofre / segurança** — dados criptografados no dispositivo, chaves no Keystore/Secure Enclave, backups protegidos por senha.
- **Discrição** — modo sem identificação nominal (códigos aleatórios), fotos ocultas da galeria do aparelho, remoção de EXIF. O app não deve "gritar cannabis" — sobriedade acima de estética canábica clichê.
- **Autonomia** — o usuário decide o que registrar, exportar e compartilhar; o app organiza, não controla.
- **Offline-first** — tudo funciona sem internet e sem conta; a rede é opcional, nunca pré-requisito.
- **Neutralidade global** — sem jurisdição específica; idiomas, unidades (métrico/imperial) e formatos de data configuráveis.
- **Leveza no uso** — registro de um evento em poucos segundos; "campos excessivos tornam o aplicativo burocrático".

**O que o produto NÃO é (evitar no design):** marketplace, rede social, plataforma de anúncios, sistema de vigilância, ranking público de cultivadores. Nada de gamificação social, feeds, perfis públicos ou linguagem comercial.

## 4. Inventário Completo de Imagens Existentes

Todas as imagens do repositório, por plataforma. **Status de todas: placeholder padrão do Flutter — substituir.**

### Android — ícone do launcher (`android/app/src/main/res/`)

| Arquivo | Dimensões | Tamanho |
|---|---|---|
| `mipmap-mdpi/ic_launcher.png` | 48×48 | 442 B |
| `mipmap-hdpi/ic_launcher.png` | 72×72 | 544 B |
| `mipmap-xhdpi/ic_launcher.png` | 96×96 | 721 B |
| `mipmap-xxhdpi/ic_launcher.png` | 144×144 | 1,0 KB |
| `mipmap-xxxhdpi/ic_launcher.png` | 192×192 | 1,4 KB |

Splash Android: `drawable/launch_background.xml` e `drawable-v21/launch_background.xml` — atualmente **fundo branco sólido, sem imagem** (slot de bitmap comentado no XML).

### iOS — AppIcon (`ios/Runner/Assets.xcassets/AppIcon.appiconset/`)

| Arquivo | Dimensões | Uso |
|---|---|---|
| `Icon-App-20x20@1x/@2x/@3x.png` | 20/40/60 px | Notificações |
| `Icon-App-29x29@1x/@2x/@3x.png` | 29/58/87 px | Ajustes |
| `Icon-App-40x40@1x/@2x/@3x.png` | 40/80/120 px | Spotlight |
| `Icon-App-60x60@2x/@3x.png` | 120/180 px | App (iPhone) |
| `Icon-App-76x76@1x/@2x.png` | 76/152 px | App (iPad) |
| `Icon-App-83.5x83.5@2x.png` | 167 px | iPad Pro |
| `Icon-App-1024x1024@1x.png` | 1024 px | App Store |

Splash iOS: `LaunchImage.imageset/LaunchImage.png` + `@2x` + `@3x` — atualmente **pixels 1×1 transparentes** (tela de lançamento vazia).

### macOS — AppIcon (`macos/Runner/Assets.xcassets/AppIcon.appiconset/`)

| Arquivo | Dimensões |
|---|---|
| `app_icon_16.png` | 16×16 |
| `app_icon_32.png` | 32×32 |
| `app_icon_64.png` | 64×64 |
| `app_icon_128.png` | 128×128 |
| `app_icon_256.png` | 256×256 |
| `app_icon_512.png` | 512×512 |
| `app_icon_1024.png` | 1024×1024 |

### Web (`web/`)

| Arquivo | Dimensões | Uso |
|---|---|---|
| `favicon.png` | 16×16 | Favicon |
| `icons/Icon-192.png` | 192×192 | PWA |
| `icons/Icon-512.png` | 512×512 | PWA |
| `icons/Icon-maskable-192.png` | 192×192 | PWA maskable (safe zone circular) |
| `icons/Icon-maskable-512.png` | 512×512 | PWA maskable (safe zone circular) |

### Windows / Linux

- `windows/runner/resources/app_icon.ico` — ícone padrão Flutter (formato .ico multi-resolução).
- Linux: sem asset de ícone no scaffold.

### Cores atualmente configuradas (todas padrão, a substituir)

| Onde | Valor atual |
|---|---|
| `lib/main.dart` — `ColorScheme.fromSeed` | `Colors.deepPurple` (Material 3) |
| `web/manifest.json` — `theme_color` / `background_color` | `#0175C2` (azul Flutter) |
| Splash Android | branco `@android:color/white` |
| `web/manifest.json` — name/description | "growcipher" / "A new Flutter project." (a atualizar) |

## 5. Assets a Criar (entregáveis de design)

1. **Ícone do app** — máster 1024×1024, exportável para todos os tamanhos das tabelas acima (Android mipmaps, iOS appiconset, macOS, web, `.ico` Windows). Precisa funcionar de 16×16 a 1024×1024 e na variante **maskable** (conteúdo dentro da safe zone circular). Considerar variantes adaptive icon Android (foreground + background).
2. **Splash / launch screen** — Android (`launch_background.xml` + bitmap) e iOS (`LaunchImage` 1x/2x/3x), coerente com o tema. Deve ser **discreta** (é o que aparece ao abrir o app em público).
3. **Paleta de cores** — seed color Material 3 (substituir deepPurple), variantes light/dark, `theme_color` do manifest. Dark mode é prioritário (uso noturno em grow room é cenário real).
4. **Tipografia e escala** — base Material 3.
5. **Iconografia interna** — eventos da linha do tempo (rega, alimentação, fase, medição, foto, observação, tarefa, ocorrência, ciclo encerrado), materiais, ambiente.
6. **Ilustrações de estados vazios** — sem plantas, sem eventos, sem materiais, sem fotos (tom sóbrio, não infantil).

## 6. Mapa de Telas do MVP

Derivado de `Funcionalidades.md` + `ROADMAP.md`:

1. **Onboarding / criação do cofre** — sem conta; define senha/PIN, oferece biometria. Explica privacidade em 2–3 passos.
2. **Tela de bloqueio** — PIN/senha/biometria; bloqueio automático. Visual neutro e discreto.
3. **Home / painel diário** — plantas ativas, tarefas pendentes, últimos registros, próximos acompanhamentos, alertas do usuário.
4. **Lista de plantas** — ativas / concluídas / arquivadas; foto, nome ou código, fase atual, idade.
5. **Perfil da planta** — foto, genética/variedade, origem, data inicial, tipo de cultivo, ambiente, fase atual, notas privadas, etiqueta/QR code local.
6. **Linha do tempo** *(núcleo do produto)* — eventos cronológicos com ícone por tipo: cadastro, mudança de fase, rega, alimentação, material, medição, foto, observação, tarefa concluída, ocorrência, ciclo encerrado.
7. **Registro rápido** — fluxo de segundos: planta → tipo de evento → dados → foto/nota opcional → salvar offline. Candidato a FAB/bottom sheet.
8. **Ambiente** — entrada manual de temperatura, umidade, iluminação, ventilação, local, condições externas.
9. **Materiais** — inventário: substratos, recipientes, ferramentas, insumos; quantidade, unidade, custo opcional; uso associado a planta/evento.
10. **Tarefas e lembretes** — únicas e recorrentes, por planta, checklists personalizados, notificações locais.
11. **Galeria privada** — fotos por planta em ordem cronológica, **comparação entre datas** (lado a lado), ocultas da galeria do sistema, EXIF removido.
12. **Estatísticas** — plantas ativas, idade, tempo por fase, frequência de registros, consumo de materiais, custos, comparação entre ciclos, linha do tempo visual. Só dados do próprio usuário.
13. **Biblioteca offline** — referência local: fases da planta, glossário, segurança de materiais, checklists, conteúdo salvo pelo usuário.
14. **Exportação e backup** — backup integral criptografado, exportação seletiva (planta/período), relatório legível, senha definida pelo usuário.
15. **Configurações** — idioma, unidades (métrico/imperial), segurança (PIN/biometria/auto-lock), backup, apagar tudo.

## 7. Restrições Técnicas

- **Flutter / Dart, Material 3** (`useMaterial3: true`, `ColorScheme.fromSeed`) — mobile-first (Android/iOS), com targets web/desktop no scaffold.
- **Offline-first:** nenhuma tela pode depender de rede; sem estados de "carregando do servidor" no fluxo principal.
- **Sem conta, sem telemetria, sem anúncios, sem rastreamento** — não desenhar telas de login social, feeds ou notificações promocionais.
- **SQLite + SQLCipher, chaves no Keystore/Secure Enclave** — fluxos de senha/biometria são parte central da UX (Fase 2 do roadmap).
- Ordem de implementação (roadmap): 1 Setup → 2 Banco e segurança → 3 Gestão de plantas → 4 Fotos e privacidade → 5 Exportação e relatórios.

## 8. Fontes

- [[GrowCipher]] — visão geral e pitch
- [[MVP]] — público e proposta de valor
- [[Funcionalidades]] — detalhamento funcional
- [[Principios]] — local-first, privacidade, criptografia, autonomia, neutralidade
- [[Posicionamento]] — o que não é, textos institucionais e de landing page
- `.planning/PROJECT.md` e `.planning/ROADMAP.md` — stack e fases

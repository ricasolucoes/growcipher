# Reprodutibilidade do APK e distribuição no F-Droid

Este documento registra uma medição, não uma intenção. Os números abaixo saíram de
builds reais feitos em 2026-08-23 sobre `master` no commit `1333c58`.

## Resumo

| Pergunta | Resposta |
|---|---|
| Dois builds limpos, mesmo caminho, mesmo toolchain, dão o mesmo APK? | **Sim**, byte a byte |
| Dois builds limpos em **caminhos diferentes** dão o mesmo APK? | **Não** |
| Dá para usar `Binaries:` na receita F-Droid hoje? | **Não** — ver "Decisão" |

## O que foi medido

Três clones limpos do repositório (sem `android/key.properties`, para reproduzir
o ambiente da CI e do buildserver do F-Droid), Flutter 3.44.9 / Dart 3.12.2,
AGP 9.0.1, Gradle 9.1.0, `TZ=UTC`, `LC_ALL=C`, `SOURCE_DATE_EPOCH` fixo,
`flutter build apk --release`.

O JDK não foi escolhido à mão: é o que o `flutter build` usa por padrão nesta
máquina — o JetBrains Runtime 21.0.4 que vem no Android Studio, o mesmo que o
`flutter doctor -v` reporta. A CI fixa Temurin 21 no `actions/setup-java`.
Nenhuma medição aqui compara os dois JDKs, então leia "mesmo APK" como "mesmo
toolchain, mesma máquina".

| build | diretório | SHA256 do `app-release.apk` |
|---|---|---|
| A1 | `.../repro/a/growcipher` | `cb869a0742f3a7751d404a74e8e51337d31babd152cea9e8068dfdba0decd090` |
| A2 | `.../repro/a/growcipher` (após `flutter clean`) | `cb869a0742f3a7751d404a74e8e51337d31babd152cea9e8068dfdba0decd090` |
| B1 | `.../repro/bbbbbbbbbbbb/nested/growcipher` | `8164474f7905e2e89f2809fd042141834b535ce57ca0e79d73f32ab48ff038fc` |

**A1 == A2.** O build é determinístico: mesma entrada, mesmo caminho, mesma saída.
É isso que o workflow `Reprodutibilidade` (`.github/workflows/reprodutibilidade.yml`)
vigia a cada execução.

**A1 != B1.** Mudou só o caminho absoluto do projeto e o APK mudou.

## Por que o caminho muda o APK

Das 67 entradas do APK, exatamente 3 divergem entre A1 e B1:

```
lib/arm64-v8a/libapp.so
lib/armeabi-v7a/libapp.so
lib/x86_64/libapp.so
```

Todo o resto — `classes.dex`, recursos, `libflutter.so`, `flutter_assets/` — é
idêntico. O `libapp.so` é o snapshot AOT do Dart, e ele carrega o caminho absoluto
do projeto:

```
$ strings -a lib/arm64-v8a/libapp.so | grep 'file:///'
file:///.../repro/a/growcipher/.dart_tool/flutter_build/dart_plugin_registrant.dart
```

Não é um detalhe cosmético. O caminho tem tamanho diferente, o que desloca
offsets e realinha o snapshot inteiro — quanto muda depende de quais dois
caminhos você comparar: **1.536.586 dos 6.292.368 bytes** do snapshot arm64
neste par (~24%), **1.853.419** (~30%) num par mais distante, medido na
reconferência abaixo. Não há como corrigir isso com um patch de bytes.

`--split-debug-info` + `--obfuscate` **não resolve** — foi testado:

| build | SHA256 |
|---|---|
| caminho A, `--split-debug-info=./sym --obfuscate` | `223d185375b1e6e13e36e80e5615d4ab7d25d26bed70fc2015b6a5d66b558d8a` |
| caminho B, mesmas flags | `ce179e4c61b586a1fd3179843da15148ccc680f7f94616e9f48d4f1f012286c8` |

Divergem exatamente nos mesmos três `libapp.so`.

### O que já é estável (e por quê)

Os timestamps do ZIP **não** são fonte de variação: o AGP normaliza todas as
entradas para `1981-01-01 01:01`. É por isso que `SOURCE_DATE_EPOCH` não muda o
resultado aqui — ele está exportado nos workflows por higiene, para qualquer etapa
futura que o respeite, não porque seja o que segura a determinismo hoje.

## Reconferência (2026-08-23)

Tudo acima foi remedido do zero, em clones novos, para separar medição de
lembrança.

Recompilando **o mesmo commit `1333c58` no mesmo caminho**, o SHA256 saiu
idêntico ao da tabela: `cb869a07…`. Os números deste documento são
reproduzíveis, não estimados.

Na branch da CI (`679bf8b`, que já traz o `dart format` do commit `0361f25`) o
padrão se repete:

| build | SHA256 |
|---|---|
| caminho A | `caacbcfb87062eade4ee07af62f58e788fcb6776c98210c431fad3157ba0fb32` |
| caminho A, após `flutter clean` | `caacbcfb87062eade4ee07af62f58e788fcb6776c98210c431fad3157ba0fb32` |
| caminho B | `ac77d89dece4e6200400429625c7d163658fc1accdb1ba17756d13bfbd7e4a5b` |

Mesmo caminho, mesmo APK; caminho diferente, APK diferente — e de novo
exatamente **3 das 67 entradas** divergem, os três `libapp.so`, cada um com o
caminho do seu próprio clone visível no `strings`.

Um detalhe que só apareceu aqui: os dois builds **ofuscados**
(`--split-debug-info --obfuscate`) dão o mesmo SHA256 nos dois commits,
`1333c58` e `679bf8b`, apesar de o `dart format` ter reescrito 8 arquivos de
`lib/` entre eles. Faz sentido — a ofuscação descarta justamente as posições de
código-fonte que a reformatação deslocou. Reformatar código muda o APK normal e
não muda o ofuscado: o que entra no snapshot é a tabela de posições, não a
lógica. Continua sem resolver o problema do caminho, que é o que interessa aqui.

## Decisão: `Binaries:` sai da receita F-Droid

O F-Droid verifica `Binaries:` recompilando o app no buildserver dele e comparando
com o APK publicado. O buildserver compila num diretório próprio, derivado do
applicationId; o GitHub Actions compila em `/home/runner/work/growcipher/growcipher`.
Os dois caminhos nunca vão coincidir, logo os APKs nunca vão bater, logo a
verificação reprova — sempre, por construção. Não é questão de ajustar flags.

Havia ainda dois bloqueios independentes:

- `AllowedAPKSigningKeys` estava com placeholder `0000…`, e `Binaries:` exige a
  impressão digital real do certificado que assina o APK publicado;
- o APK que sai sem `android/key.properties` é **não assinado** — confirmado com
  `apksigner verify`: *"DOES NOT VERIFY — Missing META-INF/MANIFEST.MF"*. O F-Droid
  não aceita binário sem assinatura, e o Android não instala.

Por isso a receita passou a **compilar a partir do fonte**: `Binaries:` e
`AllowedAPKSigningKeys` foram removidos e o F-Droid assina com a chave dele. Isso
elimina de uma vez a exigência de reprodutibilidade entre máquinas, a necessidade
de expor a keystore e o placeholder do certificado.

### Estado da receita

A receita mora fora deste repositório, em `~/Dev/Projetos/com.sierratecnologia.growcipher.yml`
(o destino final dela é um merge request no `fdroiddata`). Hoje ela está assim:

| campo | valor |
|---|---|
| `Binaries` | removido |
| `AllowedAPKSigningKeys` | removido (só fazia sentido com `Binaries`) |
| build `0.1.0` / code 1 | `commit: 23d88a1…`, **`disable:`** — o commit está só na branch local `release/mvp`, não foi para o `origin`, então o F-Droid não conseguiria clonar |
| build `0.2.0` / code 2 | `commit: 1333c58…` — a tag `v0.2.0`, a única que existe no `origin` |
| `UpdateCheckMode` | `Tags ^v\d+\.\d+\.\d+$` (era `^v.*$`, que casava com a tag malformada `v1.0`) |
| `CurrentVersion` | `0.2.0` / `2` |

Para reativar o build `0.1.0`, basta empurrar a branch `release/mvp` e a tag
`v0.1.0` para o `origin` e apagar a linha `disable:`.

### Quando reconsiderar

Vale voltar a `Binaries:` se o upstream do Flutter parar de embutir o caminho
absoluto no snapshot AOT (ou passar a aceitar um prefixo de remapeamento tipo
`-ffile-prefix-map`). O teste para refazer está em duas linhas: compilar o mesmo
commit em dois diretórios de nomes diferentes e comparar o SHA256.

## Conferindo um APK de release por conta própria

Toda release publicada pelo `release.yml` traz o SHA256 no corpo e num anexo
`app-release.apk.sha256`:

```sh
echo "<sha>  app-release.apk" | sha256sum -c -
```

Para refazer o APK e comparar, use o mesmo Flutter (`3.44.9`), o mesmo commit e
aceite que o SHA256 só vai bater se o diretório de build tiver o mesmo caminho
absoluto do runner. Na prática, a reconstrução independente hoje é feita
comparando as 64 entradas do APK que não são `libapp.so`.

## Higiene de tags

O `release.yml` só dispara em tags SemVer completas (`v[0-9]+.[0-9]+.[0-9]+`), e
antes de compilar confere que a tag bate com o `version:` do `pubspec.yaml`.

Isso fecha o buraco que produziu a antiga tag `v1.0`: nome fora do SemVer (dois
componentes), apontando para um commit de bookkeeping do `.planning/` cujo
`pubspec.yaml` estava em `0.1.0+1`. Ela nunca chegou ao `origin` e foi arquivada
como `arquivo/marco-v1.0`; o commit continua alcançável pela branch `release/mvp`.

Lembrando a regra de versionamento do projeto: `v1.0.0` é reservado para maturidade
em produção. Até lá o projeto anda em `v0.MINOR.PATCH`.

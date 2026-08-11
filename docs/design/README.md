# GrowCipher — Exports de Design (Stitch)

Exports do Google Stitch do design **Sovereign Vault**. Cada tela tem `code.html` (protótipo HTML/Tailwind) e `screen.png` (imagem renderizada). Cada versão tem um `DESIGN.md` com o design system completo (cores Material 3, tipografia, espaçamento, componentes).

Origem: `stitch_growcipher_vault_management.zip` (v1) e `stitch_growcipher_vault_management2.zip` (v2), na raiz do projeto.

---

## `v1-final/` — Versão final do design

Design system **Sovereign Vault** definitivo: fundo slate profundo `#0b1326`, primária "Cipher Teal" `#57f1db`/`#2dd4bf`, tipografia Hanken Grotesk (títulos) + Inter (corpo) + JetBrains Mono (dados/metadados).

Telas (fluxo de onboarding + registro rápido):

| Tela | Mapa do MVP (Design.md) |
|---|---|
| `onboarding_bem_vindo` | 1. Onboarding / criação do cofre |
| `wizard_identificacao` | 5. Perfil da planta (cadastro) |
| `wizard_inicio_do_cultivo` | 5. Perfil da planta (cadastro) |
| `wizard_fase_atual` | 5. Perfil da planta (cadastro) |
| `wizard_sucesso` | Fim do cadastro |
| `registro_rapido_menu` | 7. Registro rápido |
| `registro_rega` | 7. Registro rápido (evento de rega) |

## `v2-ideias-telas/` — Outras ideias de tela

Quatro telas adicionais do MVP, exploradas em **duas direções de tema** (no export original, sufixos `_1` e `_2`):

- **`tema-final-slate/`** (sufixo `_2` no export) — usa o **mesmo design system da v1 final** (`DESIGN.md` idêntico ao de `v1-final/`). São as ideias de tela na direção escolhida.
- **`tema-alternativo-verde/`** (sufixo `_1` no export) — direção alternativa não escolhida: fundo verde-escuro `#0e1513`, tipografia só Hanken Grotesk, estilo mais minimalista (agrupamento por superfície, sem bordas).

Telas em ambos os temas:

| Tela | Mapa do MVP (Design.md) |
|---|---|
| `home_dashboard` | 3. Home / painel diário |
| `plant_profile_timeline` | 5. Perfil da planta + 6. Linha do tempo |
| `private_gallery` | 11. Galeria privada |
| `onboarding_welcome` | 1. Onboarding (variação da v1) |

Extra: `growcipher_primary_logo.png` — proposta de logo principal.

---

**Referência de contexto:** [Design.md](../Design.md) (identidade, público, mapa completo das 15 telas do MVP).

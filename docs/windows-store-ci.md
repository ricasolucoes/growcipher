# Publicação automática na Microsoft Store

O workflow `.github/workflows/windows-store-package.yml` publica uma versão
Windows quando uma tag `vX.Y.Z` é criada. Ele roda em `windows-latest`, executa
análise e testes, compila o runner Windows, gera o MSIX com a identidade
reservada do Partner Center e envia o pacote para certificação.

## Configuração única no GitHub

Em **Settings → Secrets and variables → Actions**, cadastre estes Repository
Secrets:

- `AZURE_AD_TENANT_ID`
- `AZURE_AD_APPLICATION_CLIENT_ID`
- `AZURE_AD_APPLICATION_SECRET`
- `SELLER_ID`

O aplicativo Entra ID precisa estar associado ao Partner Center e ter o papel
Manager para submissões. O produto GrowCipher já reservado no Partner Center
usa o ID `9P147STG46XL`.

## Primeiro envio

Antes da primeira tag automática, é necessário criar e concluir a primeira
submissão no Partner Center, incluindo disponibilidade, propriedades,
classificação etária, listagem e screenshots. Depois que a aplicação estiver
publicada, as tags seguintes podem enviar atualizações automaticamente.

## Versionamento

Uma tag como `v0.3.0` gera:

- versão de produto: `0.3.0`;
- version code Android: `300000`;
- versão MSIX: `0.3.0.0`.

O mesmo padrão é usado pelos workflows Android e Windows.

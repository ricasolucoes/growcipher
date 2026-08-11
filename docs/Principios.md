# Princípios do Produto

## Local-first
O aplicativo funciona integralmente sem servidor:
- Instalar
- Criar um cofre local
- Cadastrar plantas
- Registrar eventos
- Consultar materiais
- Visualizar estatísticas
- Criar backup

A internet serve para recursos opcionais, não para autorizar o usuário a acessar os próprios dados.

## Privacidade por padrão
O padrão deve ser:
- Sem conta
- Sem telemetria
- Sem anúncios
- Sem rastreamento
- Sem localização
- Sem upload automático
- Sem integração obrigatória

Cada permissão deve ser justificada no momento em que for necessária.

## Criptografia verificável
A descrição técnica poderia assumir os seguintes compromissos:
- Banco local criptografado.
- Chaves armazenadas no cofre seguro do sistema operacional.
- Derivação de senha com Argon2id.
- Criptografia autenticada com bibliotecas consolidadas.
- Backups sempre criptografados.
- Sincronização futura com criptografia ponta a ponta.
- Servidor incapaz de ler o conteúdo sincronizado.
- Código criptográfico documentado.
- Formato de exportação aberto.
- Possibilidade futura de auditoria independente.

O aplicativo não deve inventar um algoritmo chamado CannabisSecure256. A criptografia já tem problemas suficientes sem branding botânico.

## Autonomia
O usuário escolhe:
- Quais informações registrar.
- Quais campos utilizar.
- Onde armazenar os dados.
- Quando realizar backup.
- Se deseja sincronizar.
- O que compartilhar.
- Com quem compartilhar.
- Quando apagar tudo.

## Neutralidade mundial
O produto é global e não depende de uma jurisdição específica.

Isso significa:
- Idiomas e unidades configuráveis.
- Sistema métrico e imperial.
- Datas e horários locais.
- Conteúdo regional opcional.
- Nenhuma localização obrigatória.
- Nenhum bloqueio geográfico por padrão.
- Nenhuma classificação automática do usuário.
- Nenhuma coleta destinada a inferir onde ou por que ele cultiva.

A plataforma fornece ferramentas privadas de organização. Ela não atua como comerciante, intermediária, fiscal ou autoridade.

## Compartilhamento futuro
O compartilhamento pode existir, mas deve nascer como recurso privado e seletivo.

O usuário poderá criar um pacote contendo apenas:
- Plantas escolhidas.
- Eventos selecionados.
- Fotografias autorizadas.
- Período definido.
- Estatísticas específicas.
- Notas permitidas.

Antes da exportação, o aplicativo remove:
- Localização.
- Dados EXIF.
- Identificação do dispositivo.
- Identificadores internos.
- Caminhos de arquivos.
- Metadados não necessários.

O pacote pode ser protegido por senha, chave pública ou QR Code. Compartilhar uma informação não deve significar abrir o cofre inteiro, conceito aparentemente revolucionário para boa parte da indústria de software.

Veja também: [[Posicionamento]]

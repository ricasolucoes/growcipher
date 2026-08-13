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

## Progressão local
O aplicativo recompensa quem registra. Quanto mais completo o histórico, mais o cofre devolve ao dono: nível, conquistas, sequências e um retrato de completude por planta.

A regra que separa isso de manipulação barata:

- A progressão é **solitária**. Não existe ranking, feed, perfil público, comparação com outros cultivadores nem competição social. O usuário compete com o próprio histórico.
- A progressão **não cria urgência artificial**. Nada expira, nada é perdido por inatividade, nenhuma moeda some, nenhuma notificação cobra. Uma sequência interrompida é um fato registrado, não uma punição.
- A progressão **nunca condiciona funcionalidade**. Nenhum recurso do aplicativo fica atrás de nível, conquista ou pontuação. XP não compra nada porque não há nada para comprar.
- A progressão **é derivada, nunca fonte**. Pontos e conquistas são calculados a partir da linha do tempo; apagar a camada de progressão inteira não perde um único dado de cultivo.
- A progressão **premia honestidade**. Registrar um problema, uma perda ou o fim de uma planta vale tanto quanto registrar uma colheita. Um diário que só admite sucesso é um diário inútil.

O objetivo é um só: transformar o registro detalhado em hábito, porque histórico denso é o que torna as estatísticas e a análise no aparelho úteis. Ver [[Gamificacao]].

## Inteligência no aparelho
A análise acontece no aparelho ou não acontece.

- **Nenhuma inferência remota.** Nenhum dado de cultivo, texto, medição ou fotografia é enviado a qualquer serviço para ser processado — nem anonimizado, nem agregado, nem "só para melhorar o modelo".
- **Nenhum treino com dados do usuário.** O histórico não alimenta modelo nenhum, nem local nem externo.
- **Degradação graciosa.** A camada determinística funciona em qualquer aparelho, sem baixar nada. Modelos opcionais são download explícito do usuário, removíveis a qualquer momento, e a ausência deles nunca quebra uma tela.
- **Análise sobre os próprios dados.** As conclusões saem do histórico do próprio usuário — a cadência que *ele* pratica, as faixas que *ele* mede, os ciclos que *ele* fechou. Não há verdade agronômica universal embutida.
- **Sugestão, nunca ordem.** O aplicativo aponta o que mudou e o que está faltando; a decisão é sempre do cultivador. Ele organiza informações e auxilia decisões, e biologia continua não sendo um cron job.

Ver [[IA]].

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

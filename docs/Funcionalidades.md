# Funcionalidades do MVP

## Cadastro de plantas
Cada planta possui um perfil individual:
- Nome ou código.
- Fotografia.
- Genética ou variedade informada pelo usuário.
- Origem opcional.
- Data inicial.
- Tipo de cultivo.
- Ambiente.
- Fase atual.
- Notas privadas.
- Etiqueta ou QR Code local.
- Status ativo, concluído ou arquivado.

O sistema também pode permitir o uso sem identificação nominal, com códigos aleatórios gerados localmente.

## Linha do tempo
Toda ação gera um evento cronológico:
- Planta cadastrada
- Fase alterada
- Rega registrada
- Alimentação registrada
- Material utilizado
- Medição adicionada
- Fotografia adicionada
- Observação registrada
- Tarefa concluída
- Ocorrência registrada
- Ciclo encerrado

Essa linha do tempo seria o núcleo do produto.

## Registros rápidos
O usuário deve conseguir registrar uma ação em poucos segundos:
- Selecionar a planta.
- Escolher o tipo de evento.
- Informar os dados desejados.
- Adicionar uma fotografia ou nota.
- Salvar offline.

Campos excessivos tornam o aplicativo burocrático. E burocracia para regar uma planta seria uma contribuição especialmente humana ao sofrimento digital.

## Ambiente
Registros opcionais de:
- Temperatura.
- Umidade.
- Iluminação.
- Ventilação.
- Local.
- Condições externas.
- Observações livres.

O MVP pode começar com entrada manual. Integrações com sensores pertencem a uma fase posterior.

## Materiais
Cadastro simples de:
- Substratos.
- Recipientes.
- Ferramentas.
- Equipamentos.
- Insumos.
- Materiais de manutenção.
- Quantidade disponível.
- Unidade.
- Custo opcional.
- Observações.

O uso de um material pode ser associado a uma planta ou evento.

## Tarefas e lembretes
- Tarefas únicas.
- Tarefas recorrentes.
- Lembretes por planta.
- Checklists personalizados.
- Notificações locais.
- Registro da conclusão no histórico.

Nenhum lembrete precisa passar pelo servidor.

## Fotografias privadas
- Imagens associadas a plantas e eventos.
- Organização cronológica.
- Comparação entre datas.
- Armazenamento local criptografado.
- Remoção automática de EXIF.
- Exportação seletiva.
- Opção de ocultar fotografias da galeria geral do aparelho.

## Estatísticas básicas
- Número de plantas ativas.
- Idade de cada planta.
- Tempo em cada fase.
- Quantidade de eventos registrados.
- Frequência de acompanhamentos.
- Consumo de materiais.
- Custos opcionais.
- Linha do tempo visual.
- Comparação entre ciclos concluídos.

## Exportação e backup
- Backup integral criptografado.
- Exportação de uma planta específica.
- Exportação de um intervalo de datas.
- Relatório em formato legível.
- Arquivo estruturado para restauração.
- Chave ou senha definida pelo usuário.
- Nenhum dado exportado sem ação explícita.

Veja também: [[Principios]] e [[MVP]]

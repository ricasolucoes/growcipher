/// Esquema v2 — progressão local.
///
/// Camada derivada: nada aqui é fonte de verdade de cultivo. O ledger guarda
/// cada concessão com sua chave estável, o que permite reconstruir o estado
/// a partir da linha do tempo se o esquema mudar
/// (`docs/Gamificacao.md` §6).
const List<String> gamificationMigrationV2 = [
  '''
  CREATE TABLE gamification_state (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    total_xp INTEGER NOT NULL DEFAULT 0,
    current_streak INTEGER NOT NULL DEFAULT 0,
    longest_streak INTEGER NOT NULL DEFAULT 0,
    last_activity_day INTEGER,
    updated_at INTEGER NOT NULL DEFAULT 0
  )
  ''',
  '''
  INSERT INTO gamification_state (id, updated_at) VALUES (1, 0)
  ''',
  // `key` é a chave de idempotência: a mesma concessão nunca paga duas vezes.
  '''
  CREATE TABLE xp_ledger (
    key TEXT PRIMARY KEY,
    source TEXT NOT NULL,
    amount INTEGER NOT NULL,
    plant_id TEXT,
    awarded_at INTEGER NOT NULL
  )
  ''',
  '''
  CREATE INDEX idx_xp_ledger_time ON xp_ledger(awarded_at DESC)
  ''',
  '''
  CREATE TABLE gamification_counters (
    metric TEXT PRIMARY KEY,
    value INTEGER NOT NULL
  )
  ''',
  '''
  CREATE TABLE achievement_unlocks (
    id TEXT PRIMARY KEY,
    unlocked_at INTEGER NOT NULL
  )
  ''',
];

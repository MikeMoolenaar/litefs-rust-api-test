PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE _sqlx_migrations (
    version BIGINT PRIMARY KEY,
    description TEXT NOT NULL,
    installed_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN NOT NULL,
    checksum BLOB NOT NULL,
    execution_time BIGINT NOT NULL
);
INSERT INTO _sqlx_migrations VALUES(20240205192254,'users','2024-02-05 19:25:22',1,X'658b88ff79989a06e578880ff9b48bd5370356e541af0e724357b6dcbd33492422b4a5254aadefc11d339b3a897cd533',6767819);
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  hair_color TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO users VALUES(1,'idk@idk.com','Mike M','blond','2024-02-05 19:26:52');
INSERT INTO users VALUES(2,'sup@sup.com','Barry Pooter','black','2024-02-05 19:26:52');
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('users',2);
COMMIT;

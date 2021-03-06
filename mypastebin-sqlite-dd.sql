-- MyPastebin: Databáze
-- Definice tabulek SQLite databáze.
-- Autor: Petr Vojkovský
PRAGMA foreign_keys=ON;
BEGIN TRANSACTION;
CREATE TABLE pastes (
ID TEXT DEFAULT (hex(randomblob(2))) NOT NULL,
TITLE TEXT,
CONTENT TEXT NOT NULL,
CREATED INTEGER DEFAULT (strftime('%s','now')) NOT NULL,
MODIFIED INTEGER DEFAULT (strftime('%s','now')) NOT NULL,
IS_DELETED INTEGER DEFAULT '0' NOT NULL,
PRIMARY KEY (ID)
);
CREATE TABLE tags (
ID TEXT DEFAULT (hex(randomblob(1))) NOT NULL,
LABEL TEXT NOT NULL,
DESCRIPTION TEXT NOT NULL,
REMARK TEXT,
PRIMARY KEY (ID)
);
CREATE TABLE paste_tag (
ID TEXT DEFAULT (hex(randomblob(2))) NOT NULL,
PASTE TEXT NOT NULL,
TAG TEXT NOT NULL,
PRIMARY KEY (ID),
FOREIGN KEY (PASTE) REFERENCES pastes(ID),
FOREIGN KEY (TAG) REFERENCES tags(ID)
);
COMMIT;

## ADDED Requirements

### Requirement: Persist the raw session transcript

When a chat session ends, the tool SHALL copy the Claude Code session JSONL produced for that session into the session folder as `transcript.jsonl`, preserving it as the source of truth.

#### Scenario: Session ends normally

- **WHEN** the user exits an interactive chat session
- **THEN** the tool locates the session JSONL under `~/.claude/projects/<cwd-slug>/` and copies it into the session folder as `transcript.jsonl`

#### Scenario: No transcript JSONL is found

- **WHEN** the session ends but no matching JSONL can be located
- **THEN** the tool prints a warning naming the session folder and exits without failing the whole command, leaving the session folder intact

### Requirement: Generate a clean greppable markdown transcript

When a chat session ends, the tool SHALL render the raw JSONL into a human-readable `transcript.md` inside the session folder, containing the exchanged user and assistant text turns in order.

#### Scenario: Markdown transcript is produced

- **WHEN** `transcript.jsonl` is successfully archived
- **THEN** the tool writes `transcript.md` containing each user prompt and assistant reply as plain text in conversational order, suitable for full-text search

#### Scenario: Markdown turn formatting is stable and machine-friendly

- **WHEN** `transcript.md` is generated
- **THEN** each turn is delimited with a consistent, parseable marker (e.g. a heading line identifying speaker and timestamp) so a later indexer can split turns without re-parsing the JSONL

### Requirement: Record session metadata

When a chat session ends, the tool SHALL write a `meta.json` into the session folder capturing at least the topic, the slug, the creation timestamp, and the resolved source JSONL path.

#### Scenario: Metadata accompanies the transcript

- **WHEN** a session is archived
- **THEN** `meta.json` exists in the session folder and records the topic, folder slug, ISO-8601 creation timestamp, and the path of the source JSONL it was derived from

### Requirement: Layout is amenable to future indexing

The on-disk layout and transcript format SHALL be stable enough that a future SQLite FTS5 index can be built by scanning session folders, without reformatting existing transcripts.

#### Scenario: Future indexer scans archived sessions

- **WHEN** a later indexing process walks the chats root
- **THEN** it can discover every session by its folder, read `meta.json` for attributes, and ingest `transcript.md` turn-by-turn using the stable delimiter, with no change required to already-archived sessions

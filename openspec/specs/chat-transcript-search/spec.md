# chat-transcript-search Specification

## Purpose

Search across the markdown transcripts of all archived chat sessions and report matches attributable to their originating session folders.

## Requirements

### Requirement: Search across all archived transcripts

The `cchat search <query>` subcommand SHALL search the markdown transcripts of all sessions under the chats root and report which sessions match, with surrounding context.

#### Scenario: Query matches one or more sessions

- **WHEN** the user runs `cchat search "tax deadline"`
- **THEN** the tool runs a ripgrep search across every `transcript.md` under the chats root and prints each matching session's folder along with the matching lines and surrounding context

#### Scenario: Query matches nothing

- **WHEN** the user runs `cchat search` with a query that appears in no transcript
- **THEN** the tool reports that no sessions matched and exits zero

#### Scenario: No query provided

- **WHEN** the user runs `cchat search` with no query argument
- **THEN** the tool prints usage for the search subcommand and exits non-zero

#### Scenario: ripgrep is missing

- **WHEN** the user runs `cchat search` and the `rg` executable is not found on `PATH`
- **THEN** the tool prints an actionable error explaining that ripgrep is required for search and exits non-zero

### Requirement: Results identify the originating session

Search results SHALL be attributable to a specific session so the user can open the full transcript or session folder to recall context.

#### Scenario: Result points back to a session

- **WHEN** a search produces matches
- **THEN** each match is grouped under, or labeled with, the session folder path so the user can open `transcript.md` or the folder directly

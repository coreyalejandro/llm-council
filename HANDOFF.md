# HANDOFF

Last updated: 2025-12-18

## What this repo is

LLM Council is a local web app (FastAPI + React/Vite) that runs a 3‑stage deliberation:
Stage 1 = parallel first opinions, Stage 2 = anonymized peer ranking, Stage 3 = chairman synthesis.

## Current status

- Backend runs on `http://localhost:8001`
- Frontend runs on `http://localhost:5173`
- OpenRouter key is required (`OPENROUTER_API_KEY`)

## Key recent changes

- **Accessibility: key entry without editing files**
  - `./start.sh` will open a **macOS secure prompt** (hidden input) when the key is missing and create `.env` automatically (gitignored).
- **Context injection (for governance / OS review)**
  - The backend can inject a bounded “context bundle” into prompts (Stage 1/2/3).
  - Supports both:
    - In-repo docs (e.g. `zero-shot-build-os/`)
    - External absolute path (opt-in) (e.g. `upos7vs_multiplatform`)
- **Configuration via `.env`**
  - Models can be overridden with env vars (`COUNCIL_MODELS`, `CHAIRMAN_MODEL`, `TITLE_MODEL`).

## How to run (macOS recommended path)

1) From repo root:

```bash
./start.sh
```

2) If prompted, enter your OpenRouter API key in the secure dialog.

## Recommended `.env` settings for reviewing zero-shot-build-os

```bash
COUNCIL_CONTEXT_ENABLED=true
COUNCIL_CONTEXT_DIR=zero-shot-build-os
COUNCIL_CONTEXT_MAX_CHARS=25000
```

## Recommended `.env` settings for reviewing external UPOS7VS repo (opt-in)

```bash
COUNCIL_CONTEXT_ENABLED=true
COUNCIL_CONTEXT_ALLOW_ABSOLUTE=true
COUNCIL_CONTEXT_DIR=/Users/coreyalejandro/Library/Mobile\ Documents/com~apple~CloudDocs/Repos/upos7vs_multiplatform
COUNCIL_CONTEXT_FILES=HANDOFF.md,openmemory.md,README.md
COUNCIL_CONTEXT_MAX_CHARS=25000
```

## Open questions / next actions

- Confirm which key you want active (wrong key fix = delete `.env`, re-run `./start.sh` to re-prompt).
- Run the council’s first governance review using the “conversation starter” prompt you drafted.

## Verification & Truth Statement

- **Produced**: This `HANDOFF.md` file (handoff protocol artifact) and documented current run/config paths.
- **Not produced**: Automated UI display of `HANDOFF.md` inside the LLM Council frontend.
- **Not verified**: That your OpenRouter key is valid (I cannot see your key and won’t ask you to paste it).
- **Assumptions**: You are running on macOS (Darwin) when using the secure key prompt.
- **Functional status**: Runnable (unverified)


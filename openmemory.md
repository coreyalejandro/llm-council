# LLM Council - OpenMemory Guide

## Project Overview

LLM Council is a local web app that runs a 3-stage deliberation pipeline over multiple OpenRouter-hosted models:

- **Stage 1**: Collect first-pass answers from multiple models in parallel.
- **Stage 2**: Anonymize Stage 1 responses and have models evaluate + rank each other (strict parseable format).
- **Stage 3**: A chairman model synthesizes a final answer from Stage 1 + Stage 2.

The repo also includes `zero-shot-build-os/`, a documentation “operating system” (UPOS‑7‑VS, REASONS, etc.) that can be injected into prompts as local context.

## Architecture

### Backend (`backend/`)

- **Entry**: `backend/main.py` (FastAPI)
  - API runs on **port 8001**
  - Key routes:
    - `POST /api/conversations` create
    - `POST /api/conversations/{id}/message/stream` SSE streaming (Stage 1/2/3 events)
- **Core orchestration**: `backend/council.py`
  - `stage1_collect_responses()`
  - `stage2_collect_rankings()` (anonymized labels + strict `FINAL RANKING:` parsing)
  - `stage3_synthesize_final()`
  - `calculate_aggregate_rankings()`
- **OpenRouter client**: `backend/openrouter.py` (async httpx)
- **Config**: `backend/config.py` (loads `.env` via python-dotenv)
- **Local context injection**: `backend/context.py`
  - Loads bounded context from a repo subdirectory (default: markdown files)
  - Used to inject `zero-shot-build-os` docs into prompts when enabled

### Frontend (`frontend/`)

- React + Vite
- Backend base URL is `http://localhost:8001` in `frontend/src/api.js`
- Main orchestration is in `frontend/src/App.jsx` (uses SSE streaming endpoint)
- Stages are rendered in `frontend/src/components/Stage1.jsx`, `Stage2.jsx`, `Stage3.jsx`

## Running Locally

1. Install deps:
   - Backend: `uv sync`
   - Frontend: `cd frontend && npm ci`
2. Create `.env` (gitignored) based on `env.example` and set `OPENROUTER_API_KEY`.
3. Run: `./start.sh` (starts backend + frontend)

## Model Configuration

Defaults are in `backend/config.py`, but can be overridden in `.env`:

- `COUNCIL_MODELS` (comma-separated)
- `CHAIRMAN_MODEL`
- `TITLE_MODEL`

## Zero‑Shot‑Build OS Context Injection

To inject `zero-shot-build-os/*.md` into model prompts:

- `COUNCIL_CONTEXT_ENABLED=true`
- `COUNCIL_CONTEXT_DIR=zero-shot-build-os`
- `COUNCIL_CONTEXT_MAX_CHARS=25000` (bound to avoid token blowups)

To inject an external UPOS7VS repo (absolute path), also set:

- `COUNCIL_CONTEXT_ALLOW_ABSOLUTE=true`

If the folder is large, set `COUNCIL_CONTEXT_FILES` (comma-separated) to limit to key docs like `HANDOFF.md,openmemory.md,README.md`.

When enabled, backend responses include `metadata.context` with which files were injected and whether it was truncated.

## User Defined Namespaces

- [Leave blank - user populates]

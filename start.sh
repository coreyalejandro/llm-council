#!/bin/bash

# LLM Council - Start script

echo "Starting LLM Council..."
echo ""

# Upsert KEY=VALUE into .env without requiring editing.
# Preserves other lines and avoids printing secrets.
upsert_env_var() {
  local key="$1"
  local val="$2"
  local tmp
  tmp="$(mktemp)"

  umask 077

  if [[ -f ".env" ]]; then
    awk -v k="$key" -v v="$val" '
      BEGIN { found = 0 }
      $0 ~ "^" k "=" {
        print k "=" v
        found = 1
        next
      }
      { print }
      END {
        if (found == 0) print k "=" v
      }
    ' .env > "$tmp"
  else
    echo "${key}=${val}" > "$tmp"
  fi

  mv "$tmp" .env
}

# macOS helper: if key is missing and .env doesn't exist, prompt via native secure dialog
ensure_env_key() {
  # Only attempt GUI prompt on macOS
  if [[ "$(uname -s)" != "Darwin" ]]; then
    return 1
  fi

  if [[ -n "${OPENROUTER_API_KEY}" || -f ".env" ]]; then
    return 0
  fi

  # Use AppleScript for a hidden-answer dialog (no sticky editor, no cursor alignment)
  KEY="$(osascript <<'APPLESCRIPT'
tell application "System Events"
  activate
  try
    set dlg to display dialog "Enter your OpenRouter API key (it will be saved to this project’s .env):" default answer "" with hidden answer buttons {"Cancel", "Save"} default button "Save"
    set theKey to text returned of dlg
    return theKey
  on error
    return ""
  end try
end tell
APPLESCRIPT
)"

  if [[ -z "${KEY}" ]]; then
    return 1
  fi

  # Write .env with restrictive permissions. (File is gitignored.)
  upsert_env_var "OPENROUTER_API_KEY" "${KEY}"

  # Avoid leaving the key in a shell variable longer than needed.
  unset KEY
  return 0
}

ensure_context_config() {
  # Only attempt GUI prompt on macOS
  if [[ "$(uname -s)" != "Darwin" ]]; then
    return 0
  fi

  # If context already configured, don't force anything.
  if [[ -f ".env" ]] && grep -qE '^COUNCIL_CONTEXT_ENABLED=' .env; then
    return 0
  fi

  # Ask whether to configure context injection (non-secret) now.
  WANT_CFG="$(osascript <<'APPLESCRIPT'
tell application "System Events"
  activate
  try
    set dlg to display dialog "Set up Context Injection? (Recommended so the Council can read UPOS7VS / zero-shot-build-os docs.)" buttons {"Skip", "Set up"} default button "Set up"
    return button returned of dlg
  on error
    return "Skip"
  end try
end tell
APPLESCRIPT
)"

  if [[ "${WANT_CFG}" != "Set up" ]]; then
    return 0
  fi

  # Let user choose the context source.
  CHOICE="$(osascript <<'APPLESCRIPT'
tell application "System Events"
  activate
  try
    set choices to {"UPOS7VS external repo (recommended)", "zero-shot-build-os (in this repo)", "No context"}
    set picked to choose from list choices with prompt "Choose what docs to inject into the Council prompts:" default items {"UPOS7VS external repo (recommended)"}
    if picked is false then return ""
    return item 1 of picked
  on error
    return ""
  end try
end tell
APPLESCRIPT
)"

  if [[ -z "${CHOICE}" ]]; then
    return 0
  fi

  # Apply chosen config (non-secret).
  if [[ "${CHOICE}" == "No context" ]]; then
    upsert_env_var "COUNCIL_CONTEXT_ENABLED" "false"
    return 0
  fi

  upsert_env_var "COUNCIL_CONTEXT_ENABLED" "true"
  upsert_env_var "COUNCIL_CONTEXT_MAX_CHARS" "25000"

  if [[ "${CHOICE}" == "zero-shot-build-os (in this repo)" ]]; then
    upsert_env_var "COUNCIL_CONTEXT_ALLOW_ABSOLUTE" "false"
    upsert_env_var "COUNCIL_CONTEXT_DIR" "zero-shot-build-os"
    # Clear explicit file list so markdown files in folder are used.
    upsert_env_var "COUNCIL_CONTEXT_FILES" ""
    return 0
  fi

  # Default: UPOS7VS external repo.
  upsert_env_var "COUNCIL_CONTEXT_ALLOW_ABSOLUTE" "true"
  upsert_env_var "COUNCIL_CONTEXT_DIR" "\"/Users/coreyalejandro/Library/Mobile Documents/com~apple~CloudDocs/Repos/upos7vs_multiplatform\""
  upsert_env_var "COUNCIL_CONTEXT_FILES" "HANDOFF.md,openmemory.md,README.md,cursor/rules/upos-7-vs-core.mdc"
  return 0
}

# Fail fast if no API key is available.
# Note: backend loads .env automatically via python-dotenv.
if [[ -z "${OPENROUTER_API_KEY}" && ! -f ".env" ]]; then
  ensure_env_key || true
fi

if [[ -z "${OPENROUTER_API_KEY}" && ! -f ".env" ]]; then
  echo "✗ OPENROUTER_API_KEY is not set and .env is missing."
  echo "  macOS: run ./start.sh again and allow the secure key prompt, or create .env manually (see README / env.example)."
  echo "  Non-macOS: create .env manually (see README / env.example)."
  echo ""
  exit 1
fi

# Optional: set up context injection without editing files (macOS).
ensure_context_config || true

# Start backend
echo "Starting backend on http://localhost:8001..."
uv run python -m backend.main &
BACKEND_PID=$!

# Wait a bit for backend to start
sleep 2

# Start frontend
echo "Starting frontend on http://localhost:5173..."
cd frontend
npm run dev &
FRONTEND_PID=$!

echo ""
echo "✓ LLM Council is running!"
echo "  Backend:  http://localhost:8001"
echo "  Frontend: http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for Ctrl+C
trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit" SIGINT SIGTERM
wait

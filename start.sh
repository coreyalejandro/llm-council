#!/bin/bash

# LLM Council - Start script

echo "Starting LLM Council..."
echo ""

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
  umask 077
  cat > .env <<EOF
OPENROUTER_API_KEY=${KEY}
EOF

  # Avoid leaving the key in a shell variable longer than needed.
  unset KEY
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

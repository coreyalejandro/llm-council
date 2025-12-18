#!/bin/bash

# LLM Council - Start script

echo "Starting LLM Council..."
echo ""

# Fail fast if no API key is available.
# Note: backend loads .env automatically via python-dotenv.
if [[ -z "${OPENROUTER_API_KEY}" && ! -f ".env" ]]; then
  echo "✗ OPENROUTER_API_KEY is not set and .env is missing."
  echo "  Create a .env file in the project root (see README / env.example)."
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

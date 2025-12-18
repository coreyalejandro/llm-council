"""Configuration for the LLM Council."""

import os
from dotenv import load_dotenv

load_dotenv()

# OpenRouter API key
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")

def _env_bool(name: str, default: bool = False) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    return raw.strip().lower() in {"1", "true", "yes", "y", "on"}


def _env_int(name: str, default: int) -> int:
    raw = os.getenv(name)
    if raw is None or raw.strip() == "":
        return default
    try:
        return int(raw)
    except ValueError:
        return default


def _env_csv(name: str) -> list[str] | None:
    raw = os.getenv(name)
    if raw is None or raw.strip() == "":
        return None
    parts = [p.strip() for p in raw.split(",")]
    return [p for p in parts if p]


# If true, use a free-only council configuration to avoid OpenRouter 402 errors.
COUNCIL_FREE_MODE = _env_bool("COUNCIL_FREE_MODE", default=False)

# Known free model IDs (OpenRouter ":free" suffix). These are safe defaults when credits are limited.
FREE_COUNCIL_MODELS_DEFAULT = [
    "moonshotai/kimi-k2:free",
    "google/gemini-2.0-flash-exp:free",
    "mistralai/mistral-small-3.1-24b-instruct:free",
    "qwen/qwen3-coder:free",
    "openai/gpt-oss-20b:free",
]
FREE_CHAIRMAN_MODEL_DEFAULT = "meta-llama/llama-3.3-70b-instruct:free"
FREE_TITLE_MODEL_DEFAULT = "google/gemini-2.0-flash-exp:free"

# Council members - list of OpenRouter model identifiers
COUNCIL_MODELS_DEFAULT = [
    "openai/gpt-5.1",
    "google/gemini-3-pro-preview",
    "anthropic/claude-sonnet-4.5",
    "x-ai/grok-4",
    # MoonshotAI Kimi family (user called this "Kim3"; verified via OpenRouter models list)
    "moonshotai/kimi-k2",
]
COUNCIL_MODELS = _env_csv("COUNCIL_MODELS") or (FREE_COUNCIL_MODELS_DEFAULT if COUNCIL_FREE_MODE else COUNCIL_MODELS_DEFAULT)

# Chairman model - synthesizes final response
CHAIRMAN_MODEL_DEFAULT = "google/gemini-3-pro-preview"
CHAIRMAN_MODEL = os.getenv(
    "CHAIRMAN_MODEL",
    (FREE_CHAIRMAN_MODEL_DEFAULT if COUNCIL_FREE_MODE else CHAIRMAN_MODEL_DEFAULT),
).strip()

# Model used for title generation
TITLE_MODEL_DEFAULT = "google/gemini-2.5-flash"
TITLE_MODEL = os.getenv(
    "TITLE_MODEL",
    (FREE_TITLE_MODEL_DEFAULT if COUNCIL_FREE_MODE else TITLE_MODEL_DEFAULT),
).strip()

# Optional prompt context injection (e.g. zero-shot-build-os docs)
COUNCIL_CONTEXT_ENABLED = _env_bool("COUNCIL_CONTEXT_ENABLED", default=False)
COUNCIL_CONTEXT_DIR = os.getenv("COUNCIL_CONTEXT_DIR", "").strip()
COUNCIL_CONTEXT_MAX_CHARS = _env_int("COUNCIL_CONTEXT_MAX_CHARS", default=25_000)
COUNCIL_CONTEXT_ALLOW_ABSOLUTE = _env_bool("COUNCIL_CONTEXT_ALLOW_ABSOLUTE", default=False)
COUNCIL_CONTEXT_FILES = _env_csv("COUNCIL_CONTEXT_FILES")

# OpenRouter API endpoint
OPENROUTER_API_URL = "https://openrouter.ai/api/v1/chat/completions"

# Data directory for conversation storage
DATA_DIR = "data/conversations"

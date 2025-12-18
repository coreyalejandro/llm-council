"""Helpers for loading local project context into LLM prompts.

This is intentionally conservative:
- Only reads from within the repository root
- Only includes a bounded amount of text (to avoid token blowups)
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional


@dataclass(frozen=True)
class ContextBundle:
    """A bounded context payload to inject into prompts."""

    source_dir: str
    included_files: List[str]
    truncated: bool
    content: str


def _repo_root() -> Path:
    # backend/context.py -> backend/ -> repo root
    return Path(__file__).resolve().parents[1]


def _is_within(child: Path, parent: Path) -> bool:
    try:
        child.resolve().relative_to(parent.resolve())
        return True
    except Exception:
        return False


def _iter_context_files(dir_path: Path, exts: Iterable[str]) -> List[Path]:
    files: List[Path] = []
    for ext in exts:
        files.extend(dir_path.rglob(f"*{ext}"))
    # Stable ordering: filename, then path
    files.sort(key=lambda p: (p.name.lower(), str(p).lower()))
    return files


def load_context_bundle(
    context_dir: str,
    *,
    max_chars: int = 25_000,
    exts: Optional[List[str]] = None,
    allow_absolute: bool = False,
    explicit_files: Optional[List[str]] = None,
) -> ContextBundle:
    """Load a bounded text bundle from a directory under the repo root.

    Args:
        context_dir: Path relative to repo root (e.g. "zero-shot-build-os") OR an absolute path (opt-in).
        max_chars: Maximum characters of combined context to include
        exts: File extensions to include (defaults to [".md"])
        allow_absolute: When True, allows reading from an absolute path outside the repo root.
        explicit_files: Optional list of specific file paths to include (relative to context dir).

    Returns:
        ContextBundle
    """
    if exts is None:
        exts = [".md"]

    repo_root = _repo_root()

    raw_path = Path(context_dir)
    if raw_path.is_absolute():
        if not allow_absolute:
            raise ValueError("Absolute context paths are disabled (set COUNCIL_CONTEXT_ALLOW_ABSOLUTE=true).")
        dir_path = raw_path.expanduser().resolve()
        source_dir = str(dir_path)
        security_root = dir_path  # prevent explicit_files escaping
    else:
        dir_path = (repo_root / context_dir).resolve()
        source_dir = context_dir
        security_root = repo_root

    # Security: never allow path traversal outside intended root.
    if not _is_within(dir_path, security_root):
        raise ValueError("Context directory must be within the allowed root.")
    if not dir_path.exists() or not dir_path.is_dir():
        raise ValueError(f"Context directory not found: {context_dir}")

    if explicit_files:
        files: List[Path] = []
        for rel in explicit_files:
            p = (dir_path / rel).resolve()
            if not _is_within(p, dir_path):
                continue
            if p.exists() and p.is_file():
                files.append(p)
    else:
        # Prefer high-signal handoff + guide files first, then fill with remaining markdown.
        priority_names = [
            "HANDOFF.md",
            "NEW_REPO_HANDOFF.md",
            "openmemory.md",
            "README.md",
        ]
        priority: List[Path] = []
        for name in priority_names:
            candidate = (dir_path / name).resolve()
            if candidate.exists() and candidate.is_file() and _is_within(candidate, dir_path):
                priority.append(candidate)

        all_md = _iter_context_files(dir_path, exts)
        # De-dup priority from remainder
        priority_set = {p.resolve() for p in priority}
        remainder = [p for p in all_md if p.resolve() not in priority_set]
        files = priority + remainder

    included_files: List[str] = []

    parts: List[str] = []
    remaining = max(0, int(max_chars))
    truncated = False

    for file_path in files:
        if remaining <= 0:
            truncated = True
            break

        try:
            text = file_path.read_text(encoding="utf-8")
        except Exception:
            # Skip unreadable files
            continue

        try:
            display_path = str(file_path.relative_to(dir_path))
        except Exception:
            display_path = str(file_path)

        header = f"--- FILE: {display_path} ---\n"
        chunk = header + text.strip() + "\n\n"

        if len(chunk) > remaining:
            # Include a truncated chunk marker to avoid mid-file confusion.
            parts.append(chunk[: max(0, remaining - 80)])
            parts.append("\n\n--- CONTEXT TRUNCATED ---\n")
            included_files.append(display_path)
            truncated = True
            break

        parts.append(chunk)
        included_files.append(display_path)
        remaining -= len(chunk)

    content = "".join(parts).strip()

    return ContextBundle(
        source_dir=source_dir,
        included_files=included_files,
        truncated=truncated,
        content=content,
    )


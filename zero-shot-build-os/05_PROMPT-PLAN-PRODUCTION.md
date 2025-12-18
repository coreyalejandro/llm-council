# Prompt‑Plan‑Production™

Prompt‑Plan‑Production (PPP) is the documentation artefact that accompanies
every project in the Zero‑Shot‑Build OS.  It turns work into an auditable
story: from intent to decisions to finished artefacts.  A PPP document is not
a nice‑to‑have; it is required for anything to be considered “done.”

## 1. Prompt — Capture the Intent

The prompt section expresses the original request in a way that is both
human‑readable and machine‑actionable.  It contains:

- **Role / Persona**
- **Objective**
- **Scenario / Context**
- **Task**
- **Format**
- **Constraints**
- **Verification criteria**

This aligns with UPOS‑7‑VS.  The prompt must be free of ambiguity and should
include any relevant inputs (snippets, links, diagrams).  If information is
missing, the agent must call it out here and seek clarification before
proceeding.

## 2. Plan — Record the Decisions

The plan section captures how the agent navigates the REASONS loop.  It
includes:

- The options explored and why some were discarded.
- Trade‑offs considered during analysis.
- The chosen path (retrieve, refactor or create) and why.
- Assumptions made due to missing information.
- Known risks, edge cases and failure modes.

This section turns invisible reasoning into an explicit decision record.  It
enables another professional to understand the rationale without reading the
agent’s private chain‑of‑thought.

## 3. Production — Show the Reality

The production section presents the final outputs along with their
verification status.  It should include:

- The artefacts themselves: code files, design assets, configuration, etc.
- Usage examples and variant matrices (for components).
- Validation evidence (tests, accessibility checks, error handling).
- The **Verification & Truth Statement** (see the Truth & Quality Guarantee).
- Unsupported use cases and known limitations.
- The status label: Conceptual, Partial, Runnable (unverified), Runnable
  (verified) or Production‑ready (audited scope stated).

If the work is partial or unverified, say so plainly.  The goal of this
section is to reveal reality, not to sell it.  Anything not shown here does
not exist.

## Why PPP Matters

PPP prevents silent failures and broken knowledge transfer.  It makes sure
that every project has a durable record of intent, decisions and outcomes.
This is invaluable for auditing, teaching and scaling.  Without PPP, work
cannot be trusted; with it, creative energy is preserved and professionalism
is enforced.
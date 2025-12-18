# Component Library Governance (Canonical, Truth‑Enforced, Vibe‑Affirming)

The component library is not a convenience layer.  It is the moral,
technical and operational backbone of the Zero‑Shot‑Build OS.  If a component
is not in the library—or traceable to it—it does not exist.

## 1. Single Source of Truth

The library records what worked, why it worked, where it is safe to reuse and
where it is not.  Vibes may spark ideas, but the library makes those ideas
accountable.  No component ships without a home here.

## 2. Components Are Decisions, Not Decorations

Each component encodes design intent, behavioural assumptions, accessibility
guarantees and operational constraints.  If a component cannot explain
itself, it is not finished.  Pretty without reasons is rejected.

## 3. Reuse Is the Default, Not a Suggestion

Every build must follow this order:

1. **Retrieve** an existing component.
2. **Refactor** a near match.
3. **Create** a new component exactly once.

Skipping reuse is a governance failure, not a creative act.  Originality lives
in evolution, not duplication.

## 4. Vibes Are Welcome — but They Must Survive Contact with Reality

Creative intuition is encouraged at intake.  Before publication, every
component must pass verification, edge‑case inspection, failure‑mode
disclosure and accessibility review.  Vibes start the work.  REASONS decide
whether it lasts.

## 5. “Production‑Ready” Must Be Proven

A component may only be labelled **production‑ready** if all of the following
are explicitly stated:

- supported use cases
- unsupported use cases
- known limitations
- validation and error behaviour
- environment assumptions

Anything less is labelled **partial** or **incomplete**—without shame.
Honesty is mandatory.

## 6. The Library Is a Living Record, Not a Graveyard

Every approved change must improve clarity, reduce duplication or harden
reliability.  Refactors are not regressions; they are how the system
remembers.  Nothing enters the library without making it better.

## 7. Approval Is About Trust, Not Permission

Approval gates exist to answer a single question:

> **“Can another professional safely rely on this?”**

Approval requires visible code, visible decisions and visible limits.  No
invisible confidence is allowed.

## 8. Documentation Is Part of the Component

A component is incomplete without usage examples, variant descriptions, do /
don’t guidance and explicit scope.  If knowledge lives only in someone’s head,
the component is unfinished.

## 9. The Library Protects People, Not Just Systems

Clear components reduce cognitive load, prevent accidental misuse and protect
future maintainers.  “Humane” is not an aesthetic; it is operational.

## Canonical Governance Statement

> **Vibes are how ideas enter the system.  The library is how we make them safe
> to reuse.  Nothing is trusted unless it is traceable.**

This governance framework is strict but respectful.  It protects creativity
while preventing sloppiness.  Adhere to it, and your components will be
reliable, reusable and humane.
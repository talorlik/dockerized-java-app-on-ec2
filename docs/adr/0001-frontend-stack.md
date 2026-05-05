# ADR 0001 - Frontend stack: vanilla HTML/CSS/JS

## Status
Accepted

## Context
The PRD lists frontend implementation as an open decision (plain HTML/CSS/JS
vs React/Vite). The frontend is intentionally thin; it only consumes the
backend API.

## Decision
Use plain HTML/CSS/vanilla JS served by Nginx. No framework, no build step.

## Consequences
- Smaller image, no node build dependency, faster CI.
- Lower attack surface (no transitive npm dependency tree at runtime).
- Cost: more boilerplate for routing/state. Mitigated by a tiny in-repo
  router (~50 LOC) and per-page render functions.

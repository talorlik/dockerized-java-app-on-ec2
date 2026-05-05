# ADR 0002 - Auth model: JWT bearer

## Status
Accepted

## Context
PRD allowed JWT or cookie+CSRF.

## Decision
JWT bearer in `Authorization` header. Stateless, SPA-friendly, no CSRF
surface to defend.

## Consequences
- Backend is fully stateless; ASG instances are interchangeable.
- Tokens cannot be invalidated server-side without an extra denylist or
  short TTL. Mitigated by a 60-minute expiry.
- HMAC signing key is stored in `/java-app/prod/jwt` and read once at
  startup. Rotation requires a rolling restart (instance refresh).

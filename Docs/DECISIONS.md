# Decisions

## DEC-001 — Project registration

- **Status:** accepted
- **Context:** This repository is governed by the App Factory standards.
- **Decision:** Use `.factory/project-context.json` as the authoritative project classification marker.
- **Consequences:** Agents must read the registration and quality files before coding.

## DEC-002 — Capture depth

- **Status:** proposed
- **Context:** The four mandatory steps create excessive friction before value.
- **Decision:** Support a compact quick capture and treat alternatives, detailed trade-offs, and predictions as optional enrichment.
- **Consequences:** A worker must define minimum fields and behavior for partial decisions before implementation.

## DEC-003 — Demo data

- **Status:** accepted
- **Context:** Empty Insights and zero-count dashboards do not explain the product.
- **Decision:** Recommend an explicit removable demo during onboarding; allow it alongside user data and remove only tagged demo records.
- **Consequences:** Demo data must remain distinguishable, idempotent, and excluded from user exports unless clearly disclosed.

## DEC-004 — Insights purpose

- **Status:** accepted
- **Context:** A long metric stack is less useful than a clear lesson or next action.
- **Decision:** Prioritize review backlog, calibration, recurring patterns, and sample-aware explanations.
- **Consequences:** Every displayed claim requires deterministic statistics coverage.

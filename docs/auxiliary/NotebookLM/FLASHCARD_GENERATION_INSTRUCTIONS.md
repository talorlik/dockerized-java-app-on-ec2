# Flashcard Generation Instructions

Generate a high-quality flashcard set in NotebookLM from this repository's
architecture, infrastructure, and operations documentation.

## Objective

Create flashcards that help a learner retain the most important technical
concepts in this project, including AWS architecture, security boundaries,
CI/CD workflows, Terraform state strategy, runtime flow, and operational
procedures.

## Audience

- Platform engineers
- DevOps engineers
- Cloud architecture learners

## Source Grounding

Use only facts from this repository's source material. Prefer these files:

- `README.md`
- `CLAUDE.md`
- `docs/auxiliary/planning/PROJECT_OVERVIEW.md`
- `docs/auxiliary/planning/PRODUCT_REQUIREMENTS_DOCUMENT.md`
- `docs/auxiliary/planning/TECHNICAL_REQUIREMENTS_REFERENCE.md`
- `docs/auxiliary/planning/ENGINEERING_EXECUTION_BACKLOG.md`
- `docs/auxiliary/architecture/ARCHITECTURE.md`
- `docs/auxiliary/operations_guide/00-prerequisites.md` to
  `docs/auxiliary/operations_guide/05-security-model.md`
- Relevant files in `.github/workflows/`
- `infra/envs/prod/*.tf`

Do not invent details. If a fact is uncertain, skip it.

## Flashcard Coverage Requirements

Ensure the deck includes cards from all categories below:

- Terraform foundation and remote state strategy
- VPC, subnet, security group, and traffic flow boundaries
- ALB to EC2 to container request path
- RDS usage, persistence model, and data lifecycle
- Secrets and identity model (OIDC, IAM roles, Secrets Manager)
- CI/CD workflow responsibilities and release mechanics
- Observability and operational controls
- Hard security constraints and "never do" rules

## Card Count and Mix

Generate 40-60 cards with this approximate distribution:

- 50% core concept cards (definitions and architecture intent)
- 30% applied cards (how/why decisions)
- 20% operational cards (runbooks, guardrails, troubleshooting)

Include a mix of easy, medium, and hard cards.

## Card Quality Rules

- Keep prompts precise and unambiguous.
- Make one testable idea per card.
- Prefer "why" and "when" understanding over pure memorization.
- Use project-specific terminology and exact resource names when relevant.
- Keep answers concise: usually 1-3 sentences.
- Avoid yes/no questions unless they test a strict rule.
- Avoid duplicate or near-duplicate cards.

## Output Format

For each flashcard, use this exact structure:

```text
Q: <question>
A: <answer>
Category: <one category>
Difficulty: <easy|medium|hard>
Source: <file path or workflow name>
```

## Question Style Targets

Use diverse question types:

- Concept: "What is X in this architecture?"
- Rationale: "Why was X chosen over Y?"
- Flow: "What happens after X step in deployment?"
- Constraint: "What is explicitly forbidden and why?"
- Troubleshooting: "If X fails, what should be checked first?"

## Validation Pass

Before finalizing, verify:

- Every answer is grounded in a real project source.
- No answer contradicts documented architecture or security policy.
- All mandatory categories are represented.
- Card phrasing is concise and technically accurate.

## Final Deliverable

Return one complete flashcard set that is immediately importable or manually
copyable, with no extra commentary between cards.

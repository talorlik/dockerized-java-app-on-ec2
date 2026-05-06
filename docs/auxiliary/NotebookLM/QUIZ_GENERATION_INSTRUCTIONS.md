# Quiz Generation Instructions

Generate a high-quality quiz in NotebookLM from this repository's
architecture, infrastructure, security, and operations documentation.

## Objective

Create a technically accurate quiz that measures understanding of how this
project is designed, deployed, secured, and operated on AWS.

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

## Quiz Coverage Requirements

Ensure the quiz includes questions from all categories below:

- Terraform foundation and remote state strategy
- VPC, subnet, security group, and traffic flow boundaries
- ALB to EC2 to container request path
- RDS usage, persistence model, and data lifecycle
- Secrets and identity model (OIDC, IAM roles, Secrets Manager)
- CI/CD workflow responsibilities and release mechanics
- Observability and operational controls
- Hard security constraints and "never do" rules

## Question Count and Mix

Generate 25-35 questions with this approximate distribution:

- 50% multiple choice (single correct answer)
- 20% multiple select (2-3 correct answers)
- 20% true/false (strict policy and constraints)
- 10% short answer (one concise expected response)

Include easy, medium, and hard questions.

## Question Quality Rules

- Keep each question focused on one testable concept.
- Prefer architecture reasoning and operational judgment over memorization.
- Use exact project terms, resource names, and workflow names when relevant.
- Avoid ambiguous distractors in multiple choice questions.
- Ensure only one unambiguously correct answer for single-choice items.
- Keep explanations concise: usually 1-3 sentences.
- Avoid duplicate or near-duplicate questions.

## Output Format

For each question, use this exact structure:

```text
Q: <question text>
Type: <mcq|multi-select|true-false|short-answer>
Options:
- A) <option text>
- B) <option text>
- C) <option text>
- D) <option text>
Answer: <correct option letter(s) or expected short answer>
Explanation: <1-3 sentence rationale>
Difficulty: <easy|medium|hard>
Category: <one category>
Source: <file path or workflow name>
```

Formatting notes:

- For `true-false`, use exactly two options: `A) True`, `B) False`.
- For `multi-select`, indicate all correct letters in `Answer`.
- For `short-answer`, omit `Options` and provide `Answer` as a concise phrase.

## Scoring and Review Mode

After listing all questions, add:

```text
Scoring Guide:
- 1 point per correct answer
- No partial credit unless explicitly specified
- Suggested passing score: 80%
```

Then add an answer key section:

```text
Answer Key:
1) <answer>
2) <answer>
...
```

## Validation Pass

Before finalizing, verify:

- Every answer is grounded in a real project source.
- No answer contradicts documented architecture or security policy.
- All mandatory categories are represented.
- Difficulty labels are balanced and realistic.
- Distractors are plausible but clearly incorrect.

## Final Deliverable

Return one complete quiz package that is immediately usable in NotebookLM,
with no extra commentary between question blocks.

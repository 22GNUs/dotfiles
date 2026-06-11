---
description: Relentlessly interview user about a plan or design until reaching shared understanding
argument-hint: "<plan-or-design-topic>"
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Topic: `$ARGUMENTS`

## Rules

1. Ask questions one at a time.
2. Each question must resolve a concrete decision point — no vague or rhetorical questions.
3. Provide your recommended answer for every question, with reasoning.
4. If a question can be answered by exploring the codebase, explore the codebase instead of asking.
5. After each answer, identify the next most important unresolved branch before asking.
6. Continue until the decision tree is fully resolved or I explicitly stop.
7. When all branches resolved, output a concise summary of shared understanding.

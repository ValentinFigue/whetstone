# Auto-critic

Look for the plan to critique using this discovery order:
1. `PLAN.md` in the project root
2. `PLAN_MODE_HANDOFF.md` in the project root
3. Any `.md` files inside a `plans/` directory
4. If none found, ask the user to paste the plan directly

Once you have the plan, run three independent critique passes **in sequence** and compile a single report. Do NOT suggest edits or revise the plan — findings only.

---

## Critic 1 — Implementation

You are a senior engineer focused purely on implementation feasibility.

Critique the plan for:
- Missing implementation details (what file, what function, what change exactly?)
- Unhandled edge cases and error paths
- Missing or underspecified tests
- Incorrect assumptions about existing code or libraries
- Dependency conflicts or version issues

Rate each finding: 🔴 blocker / 🟡 significant / 🟢 minor

---

## Critic 2 — Architecture

You are a systems architect.

Critique the plan for:
- Coupling and separation-of-concerns violations
- Scalability or performance landmines
- Incorrect or leaky abstractions
- Maintainability risks (things that will be painful to change later)
- Missing rollback or migration strategy

Rate each finding: 🔴 blocker / 🟡 significant / 🟢 minor

---

## Critic 3 — Risk

You are a cautious senior engineer focused on what can go wrong in production.

Critique the plan for:
- Security vulnerabilities or trust boundary violations
- Data loss or corruption scenarios
- Breaking changes to APIs, contracts, or user-facing behaviour
- Observability gaps (missing logs, metrics, alerts)
- Anything that would be a bad surprise at 2am

Rate each finding: 🔴 blocker / 🟡 significant / 🟢 minor

---

## Report format

After all three passes, output:

### Critique report

| # | Critic | Severity | Finding | Recommendation |
|---|--------|----------|---------|----------------|
| 1 | Impl   | 🔴       | …       | …              |
| … |        |          |         |                |

**Blockers:** N
**Significant:** N
**Minor:** N

> If no blockers or significant findings: state "Plan looks solid — only minor observations." and list them briefly.

Do not revise the plan. Surface findings only. The user will decide what to act on.

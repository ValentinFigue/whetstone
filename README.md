# whetstone

**Find the flaws in your plan before your code does.**

A Claude Code custom command that runs three adversarial critics against your plan before a single line of code is written — catching implementation gaps, architectural risks, and production landmines at the moment they're cheapest to fix.

---

## Why

Claude Code's plan mode is powerful. But a plan written by one perspective has blind spots.

`/autocritic` runs three independent passes against your plan:

- An **implementation critic** that asks *"how exactly would this be built?"* — and flags what's missing
- An **architecture critic** that looks for coupling, leaky abstractions, and things that will be painful to change
- A **risk critic** that hunts for security holes, data loss scenarios, and 2am surprises

Each finding is rated by severity. No revisions, no rewrites — just a clear table of what needs attention before you commit to building.

---

## Install

Drop the command file into your project:

```bash
mkdir -p .claude/commands
curl -o .claude/commands/autocritic.md \
  https://raw.githubusercontent.com/ValentinFigue/whetstone/main/.claude/commands/autocritic.md
```

Or clone and copy:

```bash
git clone https://github.com/ValentinFigue/whetstone
cp whetstone/.claude/commands/autocritic.md your-project/.claude/commands/
```

Restart Claude Code. The `/autocritic` command is immediately available.

**No dependencies. No MCP server. No configuration.**

---

## Usage

In Claude Code, enter plan mode as usual, then:

```
/autocritic
```

Whetstone will look for a `PLAN.md`, `PLAN_MODE_HANDOFF.md`, or any planning files in a `plans/` directory. If none exist, it will ask you to paste the plan directly.

---

## What you get

```
### Critique report

| # | Critic | Severity | Finding                                      | Recommendation                          |
|---|--------|----------|----------------------------------------------|-----------------------------------------|
| 1 | Impl   | 🔴       | No rollback path if migration fails mid-run  | Add a dry-run flag and a revert script  |
| 2 | Arch   | 🟡       | UserService now owns both auth and billing   | Split into two services or use a facade |
| 3 | Risk   | 🔴       | API keys logged in plain text on error paths | Redact before passing to the logger     |
| 4 | Impl   | 🟢       | Missing test for the empty-list edge case    | Add a unit test for results = []        |

Blockers: 2
Significant: 1
Minor: 1
```

Whetstone does not rewrite your plan. It surfaces findings. You decide what to act on.

---

## Works well with

[**bonsai**](https://github.com/ValentinFigue/bonsai) — AST-powered refactoring tools for Claude Code. Whetstone sharpens the plan; bonsai executes the cuts with precision.

---

## The three critics

| Critic | Looks for |
|--------|-----------|
| **Implementation** | Missing details, unhandled edge cases, untested paths, wrong assumptions about existing code, dependency conflicts |
| **Architecture** | Coupling violations, scalability landmines, leaky abstractions, maintainability risks, missing migration strategy |
| **Risk** | Security vulnerabilities, data loss scenarios, breaking changes, observability gaps, anything that would be a bad surprise in production |

Each finding is rated:
- 🔴 **Blocker** — fix this before building
- 🟡 **Significant** — worth addressing; will cause pain if ignored
- 🟢 **Minor** — good to know; fix when convenient

---

## License

MIT — see [LICENSE](LICENSE).

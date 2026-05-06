# whetstone

**Find the flaws in your plan before your code does.**

A Claude Code custom command that runs adversarial critics against your plan before a single line of code is written — catching implementation gaps, architectural risks, and production landmines at the moment they're cheapest to fix.

---

## Why

Claude Code's plan mode is powerful. But a plan written by one perspective has blind spots.

`/autocritic` runs independent passes against your plan:

- An **implementation critic** that asks *"how exactly would this be built?"* — and flags what's missing
- An **architecture critic** that looks for coupling, leaky abstractions, and things that will be painful to change
- A **risk critic** that hunts for security holes, data loss scenarios, and 2am surprises

Each finding is rated by severity. No revisions, no rewrites — just a clear table of what needs attention before you commit to building.

---

## Install

**Local** — available in this project only:

```bash
mkdir -p .claude/commands
curl -o .claude/commands/autocritic.md \
  https://raw.githubusercontent.com/ValentinFigue/whetstone/main/.claude/commands/autocritic.md
```

**Global** — available in every project:

```bash
mkdir -p ~/.claude/commands
curl -o ~/.claude/commands/autocritic.md \
  https://raw.githubusercontent.com/ValentinFigue/whetstone/main/.claude/commands/autocritic.md
```

**Or use the install script:**

```bash
curl -fsSL https://raw.githubusercontent.com/ValentinFigue/whetstone/main/install.sh | bash
# Global install:
curl -fsSL https://raw.githubusercontent.com/ValentinFigue/whetstone/main/install.sh | bash -s global
```

Restart Claude Code. The `/autocritic` command is immediately available.

**No dependencies. No MCP server. No configuration required.**

---

## Usage

In Claude Code, enter plan mode as usual, then:

```
/autocritic
```

Whetstone will look for a `PLAN.md`, `PLAN_MODE_HANDOFF.md`, or any planning files in a `plans/` directory. If none exist, it will ask you to paste the plan directly.

**Focus mode** — run only specific critics:

```
/autocritic impl,risk
/autocritic arch
/autocritic testing,complexity
```

Valid critic names: `impl`, `arch`, `risk`, `testing`, `complexity`, `api`, `cost`

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

The critique is also written to `CRITIQUE.md` in your project root — an audit trail that accumulates across sessions and pairs naturally with git history.

See [plans/](plans/) for a real-world example plan and its critique output.

---

## Make it automatic

Copy [templates/CLAUDE.md](templates/CLAUDE.md) into your project's `CLAUDE.md` to make the critic run automatically after every plan — no manual invocation needed:

```bash
curl -o CLAUDE.md \
  https://raw.githubusercontent.com/ValentinFigue/whetstone/main/templates/CLAUDE.md
```

With this in place, Claude Code will run `/autocritic` after presenting any plan and will not proceed to implementation if blockers are found.

---

## The critics

**Default critics** (always run unless focus mode is used):

| Critic | Looks for |
|--------|-----------|
| **Implementation** | Missing details, unhandled edge cases, untested paths, wrong assumptions about existing code, dependency conflicts |
| **Architecture** | Coupling violations, scalability landmines, leaky abstractions, maintainability risks, missing migration strategy |
| **Risk** | Security vulnerabilities, data loss scenarios, breaking changes, observability gaps, anything that would be a bad surprise in production |

**Optional critics** (activated via `$ARGUMENTS`):

| Critic | Invocation | Looks for |
|--------|------------|-----------|
| **Testing** | `/autocritic testing` | Test strategy gaps, untestable designs, missing edge case coverage, CI/prod divergence |
| **Complexity** | `/autocritic complexity` | Over-engineering, premature abstractions, YAGNI violations, simpler alternatives |
| **API Contract** | `/autocritic api` | Breaking changes, missing versioning, implicit consumer contracts, deprecation paths |
| **Cost / Ops** | `/autocritic cost` | Surprise cloud costs, query load, missing rate limiting, manual ops steps |

Each finding is rated:
- 🔴 **Blocker** — fix this before building
- 🟡 **Significant** — worth addressing; will cause pain if ignored
- 🟢 **Minor** — good to know; fix when convenient

---

## Project-specific configuration

Create a `whetstone.config.md` file in your project root to customize critic behavior:

```markdown
# whetstone config

## Project context
This project uses event sourcing. Flag any plan that bypasses the event log.
All writes must go through the `EventStore` service — direct DB writes are a blocker.

## Severity overrides
Treat all observability gaps as 🔴 blockers (this team is on-call).
```

Whetstone reads this file before critiquing and applies your instructions to all passes.

---

## Works well with

[**bonsai**](https://github.com/ValentinFigue/bonsai) — AST-powered refactoring tools for Claude Code. Whetstone sharpens the plan; bonsai executes the cuts with precision.

---

## License

MIT — see [LICENSE](LICENSE).

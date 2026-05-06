# Planning discipline

After presenting any plan (in plan mode or otherwise), automatically run `/autocritic`
on that plan without waiting for a prompt. Surface blockers before asking the user to approve.

After every user-requested change or modification to a plan — including feedback, scope changes, or added constraints — update the plan file and immediately re-run `/autocritic` on the revised plan before presenting it for approval.

## Post-critique gate

If blockers are found, do NOT proceed to implementation. Ask the user to resolve
blockers or explicitly say `override blockers` before continuing. Only proceed if all
findings are 🟡 or 🟢.

# whetstone

## Planning discipline

After presenting any plan (in plan mode or otherwise), automatically run `/autocritic`
on that plan without waiting for a prompt. Surface blockers before asking the user to approve.

## Post-critique gate

If blockers are found, do NOT proceed to implementation. Ask the user to resolve
blockers or explicitly say `override blockers` before continuing. Only proceed if all
findings are 🟡 or 🟢.

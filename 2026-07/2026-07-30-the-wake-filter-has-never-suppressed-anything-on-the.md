# 2026-07-30 — The wake filter has never suppressed anything on the architect seat, because ownership was read from a LOCAL registry while the branch namespace is GLOBAL

**The wake filter has never suppressed anything on the architect seat, because ownership
was read from a LOCAL registry while the branch namespace is GLOBAL.** `wake_filter` prefix-matches a
branch against declared runner names; `arch1/…` is correctly prefixed under the convention and still
unattributable on the implementer box, because `arch1` was declared on the other one — so it fails
open and wakes every watch. Measured, and the boxes are **not symmetric**: the implementer box
declares `r1`–`r4` and suppresses 5 PRs, while the arch box declares `arch1` alone, so
`other_runner_names` returns **empty** and the guard there is a documented no-op. Every PR of one
overnight run woke the architect's watch. **The fix is a committed seat list that is authoritative
rather than advisory**: `forge-watch runner set` **refuses** a name absent from `.claude/seats`, so a
new seat cannot declare itself without appearing in it and the drift becomes a refusal at
declaration, one PR wide — the same argument quince#200 and quince#256 make about lists nobody is
forced to update. Additive throughout: no list means no refusal, and the refusal is at *declaration*
only, so a session already running does not break when the list is briefly behind. An unknown prefix
still wakes every watch, deliberately and unchanged (quince#88: five losses of a watch came from not
arming, none from arming when nothing needed it). `status` now names **which source** attributed a
branch, because a stale registry entry is a dead session the box can clear and a wrong committed name
is a PR. **Two existing suites had to become hermetic, and that is the durable half:**
`forge-watch-composition-test` declares `ra`/`rb`/`c1`…`c8` and broke at once — fixtures, not seats,
and the wrong fix would have been to add them to the real file to make a test pass. The ownership
suite would have passed *today* and started failing the day the real list is edited. **`owed` was
deliberately not folded in**: it inherits the same locality bug in a different currency — author, not
branch prefix — so the fix does not reach it, noted on quince#227 instead. **A bashism was caught
before it shipped:** `grep -f <(…)` in a `#!/bin/sh` script that BusyBox `ash` runs, which
`gates-sh` now executes *inside* Alpine — a parse-time syntax error on both boxes, and shellcheck
then caught the replacement's `A && B || C` too, which was genuinely wrong.
([quince#265](https://github.com/novkostya/quince/issues/265),
[quince#276](https://github.com/novkostya/quince/pull/276),
[quince#227](https://github.com/novkostya/quince/issues/227),
[quince#88](https://github.com/novkostya/quince/issues/88))

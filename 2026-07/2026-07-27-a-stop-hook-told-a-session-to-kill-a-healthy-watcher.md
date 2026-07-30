# 2026-07-27 — A `Stop` hook told a session to kill a healthy watcher, and the fix is a fifth liveness class — but the record keeps the two instances nobody could explain

**A `Stop` hook told a session to kill a healthy watcher, and the fix is a fifth
liveness class — but the record keeps the two instances nobody could explain.**
`.watch` was written only at the END of a tick, so between arming and the first tick landing the
state still named the PREVIOUS, dead watcher. `status` said `dead`, `owed` said OWED, and the
hook's remedy for `dead` is *arm another one* — handing a session
[quince#50](https://github.com/novkostya/quince/issues/50)'s race **by obeying a guard rather than
ignoring one**. [quince#126](https://github.com/novkostya/quince/pull/126) makes `starting` a class
with its own exit (**9**), written at arm time, and
[quince#120](https://github.com/novkostya/quince/pull/120) fixes the rule the refusal sends you to.
**Three consumers, not two, and the third is the guard everyone trusted.** `status`,
`owed_classify` **and `watch_preflight`** read the identical `.watch.pid`, so during the window the
tool's own refusal — the check quince#88's ruling calls *"the only one atomic with the act it
guards"* — is atomically reading a stale fact and would let a second watcher onto one state file.
One arm-time write corrects all three.
**The ordering inside the fix is the whole of its safety, and it is measured rather than asserted.**
`wedged` is `alive AND (age > STALE_TICKS×interval **OR** last_watcher_tick == null)` — the null arm
needs no elapsed time, and `watch_arm` writes exactly that record on purpose. Against the
pre-change classifier it yields `watch=wedged … note: … Run \`forge-watch stop\``: **every
freshly-armed watcher instructing its session to kill it**, the issue's destructive face shipped as
its fix, prevented only by evaluating `starting` first. Pinned by a fixture named for the arm that
was actually the hazard.
**The measured record, from the implementer box:** eight `Stop`-hook blocks in one session, **eight
false positives, zero true**, caught by reading `status` and the process table rather than by the
hook being right. Six reported `dead` (remedy: arm a duplicate); **two reported `wedged`** (remedy:
`forge-watch stop` — destructive, not duplicative).
**That number is one box's, and the other seat's reads the opposite way: the architect recorded TWO
TRUE positives in the same window**, both with no watcher process at all and the state's pid
genuinely gone — and reports nearly pattern-matching the eighth as another false positive before
checking anyway. **So the check is not ceremony**, and this record must not be read as *the hook is
always wrong*: a session that stops checking will eventually skip a real one and end a turn
unwatched, which is [quince#62](https://github.com/novkostya/quince/issues/62) arriving through a
record instead of through a tool. The principle this entry cites against a *procedure* — that it
carries the box it was written on — applies to this measurement first. **Those two remain UNEXPLAINED and the entry
says so**: no write path on `main` sets `pid` without `last_watcher_tick`, the staleness arithmetic
fit neither candidate state, and pid reuse was refuted by measurement (`pid_max` 4194304 against
current pids ~717831, so ~3.5 M allocations to wrap). The fix removes the window; it does not
explain those two, and *a fix that removes a window may land without a full account of every past
instance — what is not allowed is the account quietly disappearing because the fix arrived.*
A choice was reversed by building it: refusing a too-small `--interval` was proposed and weakly
preferred, and its first casualty was **this repo's own fixture suite**, which drives `watch` at
`--interval 2` so fixtures need not sleep. The bound became `max(interval, 5 + declared_count)` —
correct where the refusal was merely safe. Sizing measured on the runner: ≈ 4 s + 0.65 s per
declared issue, 16–18 s at twenty.
([quince#126](https://github.com/novkostya/quince/pull/126),
[quince#120](https://github.com/novkostya/quince/pull/120),
[quince#95](https://github.com/novkostya/quince/issues/95),
[quince#88](https://github.com/novkostya/quince/issues/88),
[quince#50](https://github.com/novkostya/quince/issues/50),
[quince#111](https://github.com/novkostya/quince/issues/111))

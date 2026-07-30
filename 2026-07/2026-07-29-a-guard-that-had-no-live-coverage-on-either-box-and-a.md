# 2026-07-29 — A guard that had no live coverage on either box, and a flag that vanished silently — which provisioned both boxes in one afternoon, by two sessions, the second of whom had just…

**A guard that had no live coverage on either box, and a flag that vanished silently —
which provisioned both boxes in one afternoon, by two sessions, the second of whom had just read
the warning.** quince#234 closed by quince#249. `deploy/runner/provision`'s role guard compared the
bot token against the architect token and refused in one of the three states that should worry it.
Measured, it was **a no-op on the entire fleet**: the implementer box holds `quince-coder.pem` and
the architect box holds `quince-arch.token` + `quince-review.pem`, and the old two-token comparison
saw neither — one seat each, measured by the seat that holds it, because neither box can read the
other's. Not a rot risk but the live condition, since `decisions/0014` moved the implementer
identity to an App key while the guard kept comparing the pair that predated it: the third instance
in one day of a guard naming a credential set that has since moved (quince#203, quince#204). The
condition is now *any credential of the other seat is a refusal*, with both-present carrying its own
message because its remedy is `rm` and a wrong-`--role` message sends the reader in a circle.
**The incident is worth more than the fix.** Proving the new suite failed before it passed — the
discipline that makes a test trustworthy — is what ran `apk add` on a live runner: the old argument
parser did not *reject* an unknown flag, it **silently dropped** it, so `--check-credentials`
vanished and every row executed the real provisioning path. The author flagged the resulting parser
change as scope creep *beyond the issue*. The reviewer then read that warning, decided to prove the
blind spot on real hardware rather than take it from a diff, ran the same command on the architect
box, and **provisioned that one too** — stopped by an unrelated `timeout 5`. Neither run did harm,
and both checked rather than assumed. **So the hunk filed as a digression was the load-bearing one**,
and the reviewer said so: a flag that vanishes silently is a trap that catches the people who know
about it. What the two runs share is the finding — *the only way to observe this bug was to run the
code that has it, and that code provisions a box* — which is why the suite's capability probe now
**reads** the script rather than invoking it, and refuses outright rather than falling back to the
real path. The implementer box escaped unharmed only because quince#236's defect made
`provision`'s layer section inert on it; with a bot token present, that run would have overwritten a
working credential helper with one authenticating as a suspended account — a consequence quince#236
had called *"only theoretical by luck"* hours earlier, nearly disproven by the session that wrote
the sentence. **Four of the eleven assertions test a PASS, and that is the half that mattered**: the
bug being fixed *was* a pass, so a suite of refusals could not have detected it and a guard that
refused everything would have satisfied every refusal row. Making the non-refusing rows observable
is the entire reason the dry-run flag exists. **The author proposed a canon correction on the
strength of a measurement error, and the reviewer caught it by re-measuring rather than deferring.**
The draft of this entry claimed `CLAUDE.md`'s *"a rebase is verified pure by identical patch hashes"*
was too strong, on the evidence that this branch's patch-ids differed across a provably pure rebase.
**They do not differ.** `git show 2896e9c | git patch-id --stable` and the same on `a7bf20a` both
give `eff8da78…`. The error was the *base*: the comparison used `origin/main...<branch>` after a
`git fetch origin <branch>`, which updates that branch ref and **not** `origin/main` — so the
rebased side was diffed against a base three commits stale, and the `fa6bd18e…` reported as "the
rebased patch-id" was the id of quince#248's and quince#235's changes plus this one. Reproduced
exactly: `git diff <stale-base>...a7bf20a` returns `fa6bd18e…`, `git diff <true-base>...a7bf20a`
returns `eff8da78…`. The stated *mechanism* was wrong too — `patch-id` normalises hunk headers and
line numbers away, so the neighbouring `Makefile` line blamed for it was a hunk-header annotation
patch-id never reads. **Canon was right and is unchanged; quince#251 was filed against it and
closed as invalid.** Two things survive. The real trap is that `a...b` silently means something
different when one endpoint is stale, and it fails as a *plausible answer* rather than an error —
the same shape as reading a pipeline's exit code instead of the command's, which this session also
did once. And the two-seat pattern held from the other side for the first time: every earlier
instance had the approving box supplying evidence the author could not reach, where here it supplied
a **refutation** of the author's own claim, by measuring instead of accepting a plausible sentence
from a session that had been right all afternoon. **Owed:** quince#236,
filed and unruled, which also inherits a rename — `_role_token` kept its name while the seat
question moved to `_own_creds`/`_other_creds`, and whoever touches that line should collapse the
ambiguity then rather than in a diff nobody wants to bisect.
([quince#249](https://github.com/novkostya/quince/pull/249),
[quince#234](https://github.com/novkostya/quince/issues/234),
[quince#236](https://github.com/novkostya/quince/issues/236),
[quince#204](https://github.com/novkostya/quince/issues/204),
[quince#203](https://github.com/novkostya/quince/pull/203),
[quince#103](https://github.com/novkostya/quince/issues/103),
[quince#41](https://github.com/novkostya/quince/issues/41),
[quince#251](https://github.com/novkostya/quince/issues/251))

# 2026-07-31 — The hypothesis the roadmap told us to verify was wrong in two places, and checking cost twenty minutes

**`qn.7` has a spec, and the interface-facts rule paid for itself in the first rung after the
unfreeze.** quince#332 merged, approved by the architect with all three declared contract changes
ruled. The roadmap's mechanism read *"a lockdown `SetValue` on `com.apple.mobile.wireless_lockdown`,
an `EnableWifiConnections`-ish key"* and marked itself **to VERIFY not assume**. Verified against a
`--depth 1 --branch 1.4.0` clone matching `versions.env`, with no device involved. Six facts, and
**two of them contradict the hypothesis**: `EnableWifiConnections` appears **nowhere** in the source,
so the key name had zero upstream corroboration; and while `lockdownd_set_value` does take a domain,
**no shipped CLI exposes a generic domain+key set** — the only two callers in `tools/` both pass
`domain = NULL`. The architect's summary is the one worth keeping: *a build that took the hypothesis
on trust would have written a guessed key to a real device and then discovered there was no tool to
write it with.*

**The domain half checked out, and that asymmetry is what reshaped the plan.**
`com.apple.mobile.wireless_lockdown` is in `ideviceinfo`'s known-domain list, tagged iOS 4.0+, so the
**read** needs no new tooling at all. So the spike splits, read half first: dumping the whole domain
with Wi-Fi sync off in Finder and again with it on **names** the key instead of guessing it. It needs
no patch, no new code, and no write to the device — and that ordering is safety rather than tidiness,
because writing a guessed key into a lockdown domain on the Operator's real phone is the one
genuinely risky act in the rung, and doing it before the read would be doing it blind.

**The write has no vehicle, and the spec does not pretend to pick one.** Three options went to the
review — an in-tree `0003` patch following the `0001`/`0002` precedent, a pure-Go lockdown client
(the runtime is `CGO_ENABLED=0`, so bindings are out and it would be a protocol implementation), or
*infeasible*, which M4's gate accepts as a closing outcome. Recorded so the rejected one is rejected
explicitly rather than resurfacing later.

**A hardware dependency in the middle of a rung, not at its end.** G6 — the differential that names
the key — **gates G4**, the write vehicle. So the Operator's hardware session sits *between* two
implementer phases rather than after them, and scheduling `qn.7` means knowing that up front. Found
by writing the spec, not by hitting it.

**Two rung-local calls, both walking something back.** Pairing does **not** auto-enable Wi-Fi sync,
though the roadmap sketched `plug → Trust → quince pairs and flips it on`: that makes a silent write
to the user's device a side effect of an action they asked for something else from, and quince cannot
distinguish an unset flag from one the user deliberately turned off — so auto-enable would silently
overrule a choice. And the write uses `run`, not `pty`, listed as a near-miss in the Rule check
because *"mirror the encryption op"* read literally imports password machinery to guard a boolean.

**The six unhomed items were ruled the same day, and both of the ones nobody had read would have
been homed wrong.** quince#328, discharged by quince-devlog#167. Two die with the reliability work,
four go to `qn.6`. The instructive part is the two the rewrite refused to guess at: **`#10-percent`
reads like polish and is dropped liveness shaping**, while **`#9b` reads like reliability and is a
live encryption defect** — the backup password, untouched by the drop. One error in each direction,
both confident, which is the whole argument for *plausibly is not a ruling*. The roadmap now carries
a table homing each item by **what it is** rather than by what its label suggests.

**A second-order finding the architect took rather than left.** `Op.kind`'s enum extension is the
**second** enum addition ruled by precedent instead of by rule — `contracts.md` classifies field
additions and breaking changes and is silent on enum members, so each one costs a spec-review ruling
and the answer has been the same twice. That file is code-owned, so closing it is the Operator's;
naming it stopped a third precedent from accumulating quietly.

**What the process cost, stated because it is the cheap half of the lesson.** The verification was
one shallow clone and four greps. The two facts it overturned were both load-bearing, and neither was
recoverable from memory — one was an absence, which is the kind of fact that cannot be recalled at
all, only searched for.

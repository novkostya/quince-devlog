# 2026-07-24 — (dj) ARCHITECT REVIEW of qn.6b ((df)): APPROVED + LANDED (rebased onto (dh) main, PR #2 CI fully green — gates/image/e2e — then ff-only to main `3720f84`)

(dj) **ARCHITECT REVIEW of qn.6b ((df)): APPROVED + LANDED (rebased onto (dh) main,
PR #2 CI fully green — gates/image/e2e — then ff-only to main `3720f84`).** The image job's green
is itself a milestone: the first fresh-clone CI proof of the from-source patched libimobiledevice
stage. Verified in the diff, not the report: patch `0001` touches exactly the two default-timeout
call sites with rationale comments; `0002`'s gate wait sits inside the Backup-request success
branch after the passcode observe, `quit_flag` breaks it, empty-arg guarded — and `git apply
--verbose` at image build makes the patches fail loudly on upstream drift. The gated-seed engine
flow is careful where it matters: the stale gate file is removed BEFORE launch (a crashed
attempt's leftover would silently disarm the pause), the gate lives in the device dir out of the
clone's `rm -rf` reach, an early tool exit hands off to the sampler loop so the TOOL's error
surfaces (not a synthetic seed error), `abort()` reaps fully, and the Info.plist read is
stabilized against partial writes. The `PrepareWork`/`SeedWork` split PRESERVES the Finding B
guard exactly (`seed_in_progress` written in the fast phase before the tool touches the tree,
cleared only after a successful clone; `WorkDir = PrepareWork + SeedWork` so the qn.5b tests
still bind). Amendment A landed thoughtfully (`deviceOpTimeout` 30 s on the one unbounded
`Validate`; the interactive ops' longer bounds explained, not blindly capped; wedged-read test).
Amendments B/C folded; privacy sweep clean; the soname-overwrite quirk (apk lib via usbmuxd's
dep, patched COPY wins by layer order, `1.4.0-dirty` fingerprint) surfaced honestly. **One (dh)
item was NOT folded — the pcap attribution parenthetical — fixed by the architect in this
commit** (spec now credits the qn.5b hardware implementer's wire dive, ratified (cv)). Rebase
note: the predicted trivial case (both-appended log entries; resolved chronologically
(dg)/(dh)/(df)). Declared-untested error branches accepted as debt (each maps to terminal shapes
the non-gated paths already test). **Owed from here: lab stories 9/10/11 on the Operator's
patched-image redeploy** — story 11 (gate vs the real 34 GB device over the real zfs hook) is
the candidate-C/B decision point; story 9 (does the patch actually ride out the captured `-4`?)
is the rung's honest heart. The story-4 e2e flake fix ((di)) is in review on its own branch.
**After the lab legs: the CODE FREEZE + PROCESS REVAMP.**

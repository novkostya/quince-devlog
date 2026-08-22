# quince — progress dashboard

**One-line state.** ⚑ **THREE RUNGS ARE IN FLIGHT AT ONCE: `qn.13` is the frontier — a device-scoped
passkey issued by QR, every slice of its table merged and its end-to-end walk still unrun — beside
`qn.8` (the vault: unlock, browse lazily, download, lock) and `qn.9`/`qn.10` (overview, then the
vault as a `backup.FS`).** The multi-storage epic and the external-muxer work beneath `qn.6` are
complete. The product is UNFROZEN (Operator ruling 2026-07-30, lifted on **risks, not on gates**: the
ladder was assessed grade by grade, quince-devlog#141/#146, and nothing on it blocked the decision).
It was hardware-proven over USB and Wi-Fi at `qn.6b` and runs under real daily use on staging.

**Owed to hardware, and nothing else can discharge these:** `qn.6c`'s **G9**, `qn.6p`'s **G8**,
`qn.4b`'s **lab gate 12c**, `qn.13`'s **end-to-end walk**, and `qn.12`'s three unseen notification
behaviours ([quince#1271](https://github.com/novkostya/quince/issues/1271)). Each is named in its row
below.

**Live risks, carried into the unfreeze rather than gating it.** None is a gate. Each is something a
session meets and works around, named here so meeting one is recognised rather than rediscovered.

- **quince#1235 — a run of failed trunk reads does not escalate.** `fetch_trunk`'s failure is
  consumed by its caller, the tick returns 0, and the consecutive-failure counter is reset, so a
  trunk nobody can read is indistinguishable from clean ticks and `main` can be red behind a
  healthy-looking watch. The structural blindness quince#202 named is fixed; this is the residue.
- **quince-devlog#56** — a watch event names the last commenter and counts the rest.
- **G5 (watchdog) is unbuilt** — `stalled` is specified and not implemented; a gate that cannot be
  run cannot hold a door.
- **quince#32's proof is owed to an Operator re-provision window** — starting the arch service from
  a clean `conf.d` cannot be proven from a session the service hosts. **quince#33** wants a re-file.
  Both are unreadable to every identity (`quince-bot` is suspended, quince#173).

**Where the rest of this file went.** The narrative journal — 177 entries, and everything this
paragraph used to summarise — is now **one file per entry on the
[`journal` branch](https://github.com/novkostya/quince-devlog/tree/journal)**, which is never merged
into `main` and never protected. A default clone checks out `main` and the web UI shows `main`, so
that link is the only way to find it. Decisions live in [decisions/](decisions/), one file each. The
267-line state block that stood here until 2026-07-31 is preserved **verbatim** as a journal entry
rather than deleted — its own text argues that removing a criteria section on the day it is
satisfied leaves a ruling with no stated basis, and that argument is for keeping it citable, not for
keeping it here (quince-devlog#152, quince-devlog#30).

**What stays here is current state only:** the paragraphs above, the per-rung dashboard below, and
the open questions. History does not. `bin/dashboard-size` fails when this file grows past the
threshold, so curation is forced rather than remembered.

**A DONE RUNG COMPRESSES; IT DOES NOT ROTATE OUT** (architect ruling, quince-devlog#303). A
multi-line row is earned by being something a reader needs **now**, so: done and owing nothing → one
line, because the journal holds the narrative, `roadmap.md` the scope and git the PRs; **done but a
GATE IS OWED → one line plus the sentence naming what is owed and to whom**, which must never be
compressed away, and where it is unclear a rung stays in this tier because over-keeping is
recoverable and dropping an owed gate is not; active → the full row. **No row is ever deleted
outright** — a rung that vanishes reads as one that never existed, which is what quince-devlog#291
recorded when this dashboard did not know `qn.6r` existed.

| Rung | Title | State |
| --- | --- | --- |
| qn.0 | Floor: scaffold, gates, CI, image | **done** 2026-07-19 |
| qn.1 | Core daemon skeleton + demo mode + UI shell | **done** 2026-07-19 |
| qn.2 | muxd client + live device table | **done** 2026-07-20 |
| qn.2b | Muxer lifecycle + hardware proof | **done** 2026-07-20 — lab gate 7 passed on hardware |
| qn.3 | Device ops: pair, validate, encryption | **done** 2026-07-20 — lab gate 8 passed on hardware |
| qn.4a | Backup engine | **done** — gate 15 fully hardware-proven |
| qn.4b | Transport `auto` resolution + verify CLI | **built (CI-proven)** — **lab gate 12c is still owed to hardware** |
| qn.4c | Hardware ladder | **done** — lab gate 11 run: 6/8 legs passed; **(f)'s unencrypted half declared UNRUNNABLE with a reason**, not passed |
| qn.5 | `internal/storage`: backends, commit, retention | **done** — CI-proven, `285c40b`..`3ce5bb1` |
| qn.5b | One lifecycle across all backends | **done** 2026-07-24 |
| qn.6 | v0.1 release shape (the M5 umbrella over qn.6a–qn.6r) | **outlined** — the epic beneath it is complete; the release shape itself is unscoped |
| qn.6a | Config service | **done** 2026-07-24 |
| qn.6b | Seed + commit on hardware | **done** 2026-07-25 — stories 9/10/11 validated on real hardware |
| qn.6c | Multi-storage: the list | **CODE COMPLETE** 2026-08-02, 23 PRs — **NOT CLOSED: G9 is owed to hardware** ([quince#378](https://github.com/novkostya/quince/issues/378)) |
| qn.6d | Storage cards | **CODE COMPLETE** 2026-08-03, 12 PRs — **not closed while open question 4 stands**; Forget was never exercised on the stand |
| qn.6e | Onboarding: any zero-storage start | **done** 2026-08-07 — 19 PRs |
| qn.6f | HTTPS onboarding | **done** 2026-08-02 — G7 passed on hardware the same evening; **G1 has no runnable form** ([quince#571](https://github.com/novkostya/quince/issues/571)) |
| qn.6g | Live config apply | **done** 2026-08-07 — 7 PRs, no hardware gate owed |
| qn.6h | zfs in place | **done** 2026-08-08 — proven on hardware |
| qn.6i | Scheduled reconciliation | **done** 2026-08-09 — 6 PRs, no hardware gate owed |
| qn.6j | `config.yml` carries only what the user set | **done** 2026-08-09 — 7 PRs, verified on the staging stand |
| qn.6p | External muxer, one profile | **CODE COMPLETE** 2026-08-16, 10 PRs — **NOT `done`: G8 is owed to hardware**. Three of its eight gates were superseded by later rungs and are struck ([quince#1480](https://github.com/novkostya/quince/issues/1480)) |
| qn.6r | The muxer owns the lockdown store | **done** 2026-08-20 — 9 PRs, spec through final slice in one day |
| qn.7 | Wi-Fi backup | **done** 2026-07-31 — story 8 passed on hardware. Reliability was **DROPPED, not owed** (Apple-side; the remedy is `qn.12`); the netmuxd-USB audition is split to [quince#326](https://github.com/novkostya/quince/issues/326), **open** |
| qn.8 | Vault: unlock a version, browse lazily, download one file, lock | **ACTIVE** — tracker [quince#270](https://github.com/novkostya/quince/issues/270), spec `docs/specs/qn.8/qn.8.md`. Slices 1–7 merged, including the vault UI. D10.3's three-clause memory bar is **Operator-confirmed** (2026-08-20, [quince#1344](https://github.com/novkostya/quince/issues/1344)) and clause (c)'s retention measurement is owed to slice 2's harness. Live: [quince#1415](https://github.com/novkostya/quince/issues/1415) — a wrong backup password answers `500 io`, not `403 bad_password`, measured on hardware |
| qn.9 | Overview: what is IN a backup, not which files it holds | **ACTIVE** — tracker [quince#1432](https://github.com/novkostya/quince/issues/1432). Spec merged and amended four times; the capability report (four states, four remedies) and overview-as-the-version's-page have landed |
| qn.10 | The vault becomes a `backup.FS`; messages is its first consumer | **ACTIVE** — tracker [quince#1483](https://github.com/novkostya/quince/issues/1483); spec merged ([quince#1491](https://github.com/novkostya/quince/pull/1491)). The seam shipped at `qn.9`, so this rung is the viewer |
| qn.11 | Photos viewer | **parked, lowest priority** (icloudpd+Immich cover photos; Apple-thumbnails spike first if revived) |
| qn.12 | PWA + push + schedules | **partly built** — Web Push landed ([quince#1124](https://github.com/novkostya/quince/pull/1124)) and the VAPID home is ruled (the app DB, 2026-08-17), so **nothing here is blocked on a ruling**. Three notification behaviours have never been seen on a real device ([quince#1271](https://github.com/novkostya/quince/issues/1271)), and a backup that retries then succeeds still leaves the lock screen saying it failed ([quince#1213](https://github.com/novkostya/quince/issues/1213), `needs-operator`) |
| qn.13 | A device-scoped passkey, issued by QR, whose holder sees one device and nothing else | **ACTIVE — the frontier.** Tracker [quince#1342](https://github.com/novkostya/quince/issues/1342). **Every row of the spec's slice table is merged**, plus 8d, 8e and 8f. What is left is not a slice: **(1) the end-to-end walk is still unrun** — no QR scanned, no ceremony on a phone, no scoped session obtained end to end, and it is the rung's oldest debt; (2) [quince#1472](https://github.com/novkostya/quince/issues/1472)'s last clause, ruled and not built — the refusal when a chosen storage becomes unreachable between the pick and the job; (3) [quince#1468](https://github.com/novkostya/quince/issues/1468), the storage pages reachable by URL |


**Open questions for the Operator** (tracked here until resolved):
1. LAN registry port + creds (address recorded in `local/environment.md`; env-only,
   never committed).

*Question 2 — **where the VAPID keypair lives** — was **RULED on 2026-08-17: the app DB**
([quince#1128](https://github.com/novkostya/quince/issues/1128)), and the ruled text is in
`docs/quince.design.md` §6. It stood here as open for five days after it was answered, which is the
same staleness quince-devlog#303 filed about the rung rows. **It no longer blocks `qn.12` slices 3
and 4.** What `qn.12` still owes is hardware, not a ruling —
[quince#1271](https://github.com/novkostya/quince/issues/1271).*

*`qn.6d`'s two gaps stood here as questions 2 and 3 for nine hours on 2026-08-02/03. **Both were
ruled on 2026-08-03** — relayed by the architect seat on
[quince#443](https://github.com/novkostya/quince/issues/443) — and the ruled text is in canon
(`contracts.md` §1 and §2, both flipped from `PROPOSED (gap)` by the PR that also retired the
rung-ruled decision the ruling invalidated). **Gap A**: the fields land as proposed, all four
sub-questions as recommended — and the **card renders no filesystem caveat at all**, because equal
byte counts cannot prove a shared filesystem and both fields that would have carried filesystem
identity were declined. Two storages on one disk each show the same figure with nothing saying it is
the same space: a **ruled acceptance**, not a bug to file. **Gap B**: Forget is a **config
mutation** — `DELETE /api/config/storage/{name}` — with no live deregistration, the restart
surfaced, and recheck reporting runtime truth marked pending. **General config live-apply became its
own rung** out of the same reading —
[quince#577](https://github.com/novkostya/quince/issues/577), project-wide config→runtime
propagation with storage as its first consumer. The recommendations that stood here are not the
rulings; both were taken, which is not the same as being the record.*

*`qn.6f`'s three gaps stood here as questions 2–4 for six hours on 2026-08-02, and **all three were
ruled the same day they were filed** — relayed by architect session `arch1` on
[quince#446](https://github.com/novkostya/quince/issues/446). Plain HTTP is an explicit,
off-by-default, non-dismissibly-surfaced opt-in, and it **wins over the redirect**; one port serves
both protocols routed by the first byte, **vendored rather than `cmux`**; the default becomes
**`8968`**. A fourth question nobody had written down — **is onboarding step 1 pre-auth?** — was
found by an Operator question on quince#462, filed, and ruled inside the hour: yes, a fifth
`authExempt` route, **by exact path**. The ruled text is in canon (`design.md` §6, flipped by
quince#507; `contracts.md` §6's two blocks flip in the slices that build them) and is summarised in
the `qn.6f` row above. **The recommendations that stood here are not the rulings** — every one was
taken, which is not the same as being the record.*

*`qn.6c`'s four gaps stood here as questions 2–5 until 2026-08-02. **All four were ruled on
2026-07-31/08-01** — relayed by architect session `arch1` on
[quince#378](https://github.com/novkostya/quince/issues/378) — and seventeen PRs implemented them.
The ruled text is in canon (`contracts.md` §1/§2/§6, `design.md` §5, each flipped from `PROPOSED
(gap)` by the PR that built it) and summarised in the `qn.6c` row above; the recommendations that
stood here are NOT the rulings, and gap 3's was overruled outright.*

*Resolved questions, and the project-name/licence/owner rulings that stood here, are in the journal
entry for 2026-07-31 — a resolved question is history the moment it is answered.*

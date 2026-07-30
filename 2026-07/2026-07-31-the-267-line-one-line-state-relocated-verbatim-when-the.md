# 2026-07-31 — The 267-line "one-line state" is relocated here verbatim, because the block's own text says why deleting it would be wrong

**The 267-line "one-line state" is relocated here verbatim, because the block's own text says why
deleting it would be wrong.** devlog#152 ruling 6 asks for the one-line state to be trimmed — it was
measured at 61 lines when devlog#30 was filed and at **267** when this ran, and it is called "one
line". Trimming it is a judgement about what a cold session needs in order to resume, and almost all
of it is not that: it is the provenance of decisions already taken.

**What is owed, and it is the reason this file exists rather than a deletion.** The unfreeze-criteria
section inside the block argues for its own retention: *"a criteria section removed on the day it is
satisfied leaves a ruling with no stated basis."* That argument is correct and it is not an argument
for keeping it in `progress.md` — it is an argument for keeping it **somewhere citable**. Moving it
preserves the basis; deleting it would not. So the trim relocates rather than discards, and the
reduced `progress.md` points here.

**What was proven:** nothing was rewritten. Everything below is the text as it stood on `main` at
`ad62fb3`, lines 3–269 and 292–312, character for character. The pointer in `progress.md` and this
file are the same claim from two ends.

What was cut from the live file and preserved below:

- the full state narrative — the coroutine-loop history, the `pr.0`–`pr.5` record, the `qn.1`–`qn.6b`
  build summaries, and the five unfreeze-criteria grades with their evidence;
- open questions **2** and **3**, both struck through and marked `RESOLVED` in place, and the
  `*Resolved:*` paragraph. A resolved question is history the moment it is answered.

What stayed in `progress.md`: a short state paragraph, the per-rung dashboard, and open question
**1**, which is the only one still open.

([quince-devlog#152](https://github.com/novkostya/quince-devlog/issues/152),
[quince-devlog#30](https://github.com/novkostya/quince-devlog/issues/30))

---

## The state block, verbatim — `progress.md` lines 3–269 at `ad62fb3`

**One-line state.** ⚑ **The product is UNFROZEN as of 2026-07-30 — Operator ruling — and `qn.7`
(Wi-Fi reliability hardening) resumes the product chain; the PROCESS REVAMP is complete through
`pr.5`, with `pr.6` reduced to its identity half and that half discharged.** The freeze is lifted on
**risks, not on gates**: the ladder was assessed grade by grade on 2026-07-30 (quince-devlog#141,
quince-devlog#146) and nothing on it blocked the decision. The risk list below rides *into* the
unfreeze rather than gating it, and **quince#202 is the largest** — `forge-watch` is structurally
blind to the trunk, so `main` can be red with a healthy watch running, which costs more once product
merges resume. quince itself is unchanged since `qn.6b` landed and
its lab legs passed — hardware-proven over USB and Wi-Fi, running under real daily use on staging.
What changed is how the project is built: PRs are how agents communicate, an approval is a literal
PR approval, issues are the tracker, and branch protection is the authority model. **`pr.0`–`pr.5`
landed** — machine identity (`quince-bot`) + branch protection; this journal split out of the
product repo; `deploy/devct/` (a dev-container toolkit that builds its own template and hands out
disposable boxes on a scoped Proxmox token); the skills (`/onboard`, `/architect`, `/kickoff`,
`/report`, `/review-pr`, `/land`, `/qa`); deploy-by-default QA (`devct deploy` puts a clickable demo
URL in every PR, fetched before it is claimed); and two persistent session hosts —
**`quince-runner`** (implementer identity) and **`quince-arch`** (architect), each of whose
preflight asserts the *other's* credential is absent, so approver ≠ author is a property of machines
rather than a habit. Both now hold live Remote Control sessions.
**The coroutine loop is BUILT** — [quince#43](https://github.com/novkostya/quince/issues/43) and
[#16](https://github.com/novkostya/quince-devlog/issues/16) landed in six PRs, taking
[#4](https://github.com/novkostya/quince-devlog/issues/4) (the implementer half) and
[#13](https://github.com/novkostya/quince-devlog/issues/13) (the silent watch death) — both **awaiting
the owner's closure**, because #4's original story 8 asked for `--loop` flags on `/kickoff` and
`/review-pr` and what was built instead is a background watcher plus an always-on §6, which is a
supersession rather than a completion and is not the implementer's to declare. Delivered: an unenumerated
`updated` backstop that names WHO as well as WHEN, mergeability watching, restart survival with four
liveness classes and a `stop` verb that verifies a pid before signalling it, a declared watch set that
hard-fails rather than shrinking, both skills, and three new canon corollaries. **None of it is live in
either session until both boxes pull the launchpad and restart** — and the pull alone flips
`bin/forge-watch` while the skills need the restart, so those are two moments rather than one.
**It went live on 2026-07-26 and immediately delivered three defects of its own**
([quince#62](https://github.com/novkostya/quince/issues/62),
[#65](https://github.com/novkostya/quince/issues/65)): the armed loop never terminated so nothing it
detected could wake anybody; the implementer half armed nothing at all; and an approved PR waiting on
CI was invisible, which is where PRs spend most of their life. All three are fixed
([quince#63](https://github.com/novkostya/quince/pull/63),
[#66](https://github.com/novkostya/quince/pull/66),
[#67](https://github.com/novkostya/quince/pull/67)) — the loop is now the tool's own **terminating
verb**, arming is a **`Stop` hook** a session cannot silently skip, and a PR **becoming landable** is
an event. **What that proves and does not, counted rather than summarised.** Every *review* in the run
was delivered by the loop — four PRs went open → reviewed → fixed → approved with nobody typing
"review posted". **The merges are a different question, and the first version of this line elided
it:** quince#63's sixteen minutes ended only when **a human asked why it had not merged** (which is what
produced quince#65), and quince#66 and #67 were merged 92 s and 47 s after the *implementer* commented
that they were landable — a relay by another name, and one the loop should have made unnecessary. Only
**quince#68 went from approved to merged on the mechanism alone**, unprompted, and it is the first PR
after the landability fix landed. One clean merge, with a before and an after, is the honest result.
And the implementer half was **one long-lived session**, not a fresh one per event, so the rung's
founding property — *auto-resume wakes a FRESH session against the PR thread* — is still **unproven**.
**Unfreeze criteria — DISCHARGED 2026-07-30 by Operator ruling; kept below as the record of what was
assessed and what was accepted.** Nothing here gates anything now. It is retained rather than deleted
because the risk list is live and the grades are the provenance of the decision — a criteria section
removed on the day it is satisfied leaves a ruling with no stated basis.
**Originally REWRITTEN 2026-07-30, because the old list could not be used** (quince-devlog#141).
Three of its four items were defects in the criteria rather than in the work. Grades below are **MET**,
**MET — DEVIATION: …**, **GAP: …**, **NOT MET**, or **CANNOT BE MET**, so a qualifier always carries its
reason. Assessed against the ladder itself (`docs/specs/rung-loop/rung-loop.md:843-889`) for the first
time — that its status lived in no document is the defect which let the other three go unnoticed.
**G1 (fixtures) — MET.** 47 fixtures under `make forge-watch-test`, invoked by `gates-sh`, green in CI.
**G2 (live, one PR) — MET.** The old line called G2 *"a real session killed mid-watch"*; the ladder says
*"arm on a real PR, push a commit, observe the `checks` event; post a review, observe the `review` event."*
The killed-session run was a U4 experiment named after an existing gate, so **an unfreeze criterion was
held open by a naming collision**; it stays on the record as a **risk**, not a gate — the ladder never
asked for respawn. **Review half: met, by an armed watcher** — the U4 debrief logs one at `13:30:07`
catching `event=review pr=104 APPROVED`, emitting, and exiting into a dead session's mailbox. **Checks
half: met** — `event=checks pr=275 conclusion=FAILURE name=gates`, 2026-07-30 `06:44Z`, on a PR whose
`gates` genuinely went red; observed by a foreground `tick`, same code path. **What is NOT structural,
and an earlier draft of this line wrongly said was:** a watcher is not blind to reviews. The narrow true
claim is about **timing** — `/architect` §6 drains with a foreground tick *before* arming, so transitions
that accrued *before* the arm are consumed by the drain and never reach the watcher; one landing *during*
the watch is seen, which is what the U4 log shows and what the drain is for.
**G3 (the coroutine, end to end) — MET.** quince-devlog#133, quince-devlog#135, quince#255, quince#271
and quince#272 each ran review posted → implementer woke cold → fix pushed → reviewer woke on the push →
approved, **with nobody typing "review posted"**. The waking event on the implementer side is
`updated … kind=review` rather than `review`; both are loop-delivered, and naming which one matters
because G2's timing claim above is about `review` specifically. Its fresh-session leg is proven further
than asked: a cold session given only `/onboard` reconstructed a dead session's work from the forge
alone, declined to act unauthorized, then finished and merged without touching the scratch clone (U4).
**Its merge leg, counted rather than asserted:** **55 PRs merged by `app/quince-review` across
2026-07-29/30** (44 in quince, 11 in the devlog, of 62 merged in that window by any seat) — a count of
*merges by the reviewer App in a window*, which is **not** the measure quince-devlog#41 used. **#41's
nine stands for its own window and is the number in the record**; this is a later, wider window, and the
loop-delivered subset of the 55 is not separately measured. The old line's *"exactly one"* was the
understatement #41 filed, and #41 closes with this.
**G4 (stop, don't guess) — MET, both halves, on evidence gathered AFTER this section was first written.**
quince#232, quince#260 and quince#268 proved *"does not guess"*, and the earlier grade correctly refused
the gate, because the ladder's trigger is *a review comment requiring a ruling* and every instance was the
implementer's **own** judgement. **That half is now proven repeatedly, and the trigger in each case was a
reviewer artifact rather than self-initiative.** On quince#242 the implementer measured the architect's
ruled design, found it collided with quince#222, **stopped, named the question, made no commit**, and
asked whether the design may depend on that misattribution being wrong; on the same issue it found the
ruled count guard unimplementable from where it has to run and stopped rather than substituting one; and
on quince#294, quince#297 and quince#301 it took blocking review findings, on the last **improving the
finding** rather than merely applying it. **Three ruled designs declined, each with a measurement, each
correct** — which is the gate's harder direction, since refusing a superior's design costs the refuser
something.
**One of the two issues cited as evidence of a broken channel is CLOSED, and something worse was found and
fixed the same day.** quince#273 (a newly filed issue enters no watch) is closed; quince-devlog#56 (a
watch event names the last commenter and counts the rest) remains open and rides as a risk. Against that,
**quince#292**: `wake_filter` silenced *every* implementer PR event on the architect seat, so the reviewer
could not be woken by the work it exists to review — invisible because issue events still woke it. Fixed
in quince#295 and proven end to end on the architect box. And `review-answered`, the turn-flip this gate
is about — *a PR you blocked that the author has since answered* — was built (quince#288), shipped with
two defects found by running rather than reading, fixed (quince#291), and has since **fired live**.
**G5 (watchdog) — CANNOT BE MET; the mechanism is not implemented.** `bin/forge-watch:278`: *"`stalled` is
specified … and NOT implemented — it needs a wall clock, which the pure half deliberately does not have …
a tool that lists an event it cannot emit is making the same kind of claim this tool exists to stop."*
Deferred with its reason. **A gate that cannot be run cannot hold a door.**
**The two remaining named blockers were unreadable to every identity.** quince#32 and quince#33 return
`Not Found` — to `novkostya` and to both Apps — because `quince-bot` authored them and a suspended
account's issues are hidden (quince#173). A criterion nobody can open is not a criterion. **#32's
substance, restated so it survives**: the arch service could not start from a clean `conf.d` because a
temporary export sat on that box; its proof leg — start the service from a clean `conf.d` and assert it
comes up — **cannot be run from a session hosted by the service `provision` restarts**, so it is owed to an
**Operator re-provision window**, structurally, rather than blocked on anyone's work. **#33** (three
undocumented ceremony gates, plus the pull-before-arm ordering) is likewise unreadable and wants
re-filing before it can gate anything.
**`pr.6` is reduced to its identity half, and that half is discharged.** The revamp record prices it as two
items under one name and finds the credential-concentration half substantially achieved by `pr.0`–`pr.5`;
the identity half's two named blockers — quince#47 (architect and Operator share a login) and quince#136
(the architect can only author as the Operator) — are **both CLOSED**, resolved by moving each seat to its
own GitHub App (`decisions/0014`, quince#134).
**So nothing on the ladder blocks the unfreeze, and the one gap that rode with it has closed.** The risk
list carried *into* the unfreeze rather than gating it: quince-devlog#56, the surviving half of what G4's
gap cited; the killed-session behaviour above; G5 unbuilt; #32's proof owed to a re-provision window; and
#33 needing a re-file.
**The largest of them is quince#202, and it grows at the unfreeze rather than shrinking.** `forge-watch`
is structurally blind to the trunk — it observes the PR queue and a declared issue set, and a push to
`main` is neither — so `main` was red for **4h40m** with a healthy watch re-arming throughout, found by
accident. The merge that broke it went through this loop and was approved by this seat. Ruled
2026-07-30 (a `trunk-*` family inside `forge-watch`, wake on `SUCCESS → FAILURE` only, never entering
`owed`) and **not built**. Named first because product work resuming makes an unobserved red trunk more
expensive, not less.
**And quince#54 is now evidenced rather than dormant**: nothing detects drift between the normative
`loop-protocol.md` and the commands inline, its own 2026-07-29 measurement found no live drift, and two
instances appeared on 2026-07-30 — both **claim-level**, so the gate that issue proposes would have
passed both. A re-scope input, not a re-scope.
**None is a gate. Each is something a session meets and works around, named here so that meeting one is
recognised rather than rediscovered.**
**The first post-unfreeze deliverable is a SPEC, not code.** `docs/specs/qn.7/` does not exist, and
`CLAUDE.md` is explicit that a rung starts from one: if the frontier rung has none, the spec is the first
PR, reviewed before any code exists. qn.7 is M4 (Wi-Fi reliability hardening), whose scope was already
sharpened by the qn.6b lab session's banked hardware evidence.
**The unfreeze decision is the Operator's, and it is now a decision about risks rather than
about gates.**
[quince#9](https://github.com/novkostya/quince/issues/9)'s reservation as the first post-freeze
item was **discharged on the Operator's instruction** (confirmed on the issue, 2026-07-26
11:16:25Z) and the dress rehearsal has been run — #9 and
[quince#31](https://github.com/novkostya/quince/issues/31) both landed test-only; the four items
above are unchanged and still gate the unfreeze, after which `qn.7` (Wi-Fi auto-resume) resumes
the product chain. Architect handoff notes:
[devlog#10](https://github.com/novkostya/quince-devlog/issues/10).

Prior state: **`qn.5b` was BUILT (CI-proven, 2026-07-24 (cp)).** `qn.5b` made the `latest` swap **atomic**
(`renameat2(RENAME_EXCHANGE)`) + reworked the per-job `working/` lifecycle unified across backends
((cg)/(co)) — `make gates`/image green; only the real-rpool lab legs (G-snapshot/G-rclone/
G-exchange-live + syncoid) remain, owned by an Operator hardware day. `qn.6a` = soak-ready UI —
**mobile is the precondition for daily use**, plus offline devices and backup-list labels ((ch)); it
is the **last rung under the current process** and feeds the revamp friction evidence. Deferred past
the freeze: gate **12c**, the DSM/alpha-tester prerequisites, the rest of qn.7, and qn.6+. **The
PROCESS REVAMP is in flight** (product code frozen, app soaking): the GitHub substrate is live —
branch protection, labels, templates, the machine account — and the journal moved to this repo
([quince#4](https://github.com/novkostya/quince/pull/4),
[quince#5](https://github.com/novkostya/quince/pull/5)); **pr.3 is LANDED** — the standing agent
instructions, the six workflow skills (`/onboard`, `/kickoff`, `/report`, `/review-pr`, `/land`,
`/qa`), and the layered permission allowlist
([quince#6](https://github.com/novkostya/quince/pull/6)–[#8](https://github.com/novkostya/quince/pull/8),
`main` at `6df2461`), so a session now self-onboards from a command instead of a hand-written
kickoff. **`pr.2` is LANDED too** — `devct`, the dev-container toolkit, in
[quince#10](https://github.com/novkostya/quince/pull/10)–[#16](https://github.com/novkostya/quince/pull/16):
`devct onboard` binds a machine, `devct-template build` builds a template from scratch on any
Proxmox host, and `devct create|list|destroy` hands out disposable containers that reach a green
gate ladder in ~3 minutes. **The whole permanent root surface is one four-command block at
`versions.env` cadence** — everything else runs on a scoped API token, proven from a session with
no root path at all and reproduced independently. **`pr.4` is LANDED too** — `dev-deploy`, in
[quince#17](https://github.com/novkostya/quince/pull/17)–[#19](https://github.com/novkostya/quince/pull/19):
`devct deploy` builds a ref's **production** image on a dev container, serves it in `--demo` mode,
and reports a URL only after fetching it (222 s cold, 5 s warm); `/report` runs it by default, `/qa`
is replaced rather than a placeholder, and the DoD names both non-URL outcomes so *not applicable*
cannot absorb *unavailable*. The deploy URL is the **convention name** — an address never enters PR
text. **`pr.5`'s CODE IS LANDED and its GATES ARE OWED** — the runner container exists, is
provisioned from a signed repository, and reports honestly that it has no session yet
([quince#21](https://github.com/novkostya/quince/pull/21)–[#23](https://github.com/novkostya/quince/pull/23)).
What remains is the Operator's five minutes — `claude auth login` (measured: a token credential
*cannot* establish Remote Control, so there is no headless path), workspace trust, the two `/config`
push toggles — after which G2/G3/G5/G6 become runnable, G6 being an implementer loop run entirely
*from* the runner. **Next: that ceremony**, then pr.6 (lockout), which inherits a written
constraint — the root-capable path reaches the runner only as a forced-command wrapper, never a
general root key. Recent history follows.

**`qn.4c` is BUILT + HARDWARE-PROVEN — the DAILY-DRIVER bar is MET ((cd)/(ce)).**
Both transports drive real encrypted backups from the browser on **supervised** muxers: a 33.3 GB
first-ever full backup and a cabled incremental both committed, verified and snapshotted; live
updates arrive with no page refresh; devices show their real last backup; iMazing opens a committed
`latest/` tree (which also retires qn.4a gate 15's last leg). The hardware day found — and fixed
in-session — a **gate-blocking** bug in landed qn.4a code: the backup target stub lived on the cache
filesystem, so `idevicebackup2` reported the wrong free space and the DEVICE refused any backup
larger than it ((cd)). **Two legs are not clean:** a Wi-Fi drop lands safely but is labelled
`failed` instead of `connection_lost` (interface fact 2 is incomplete — a drop has two shapes), and
(f)'s unencrypted half is **declared unrunnable** on this hardware with a stated reason. Seven
findings are filed with diagnoses, none blocking. **Remaining before the code freeze: nothing
session-buildable** — the open items are post-freeze work. History below.

**qn.1 is BUILT — the app frame stands.** `make gates` (go + vault +
ui), `make gates-ui-e2e` (Playwright stories 1–2), and `make image` are green inside
`quince-dev`. The daemon now has typed config over `config.yml`, SQLite + migrations,
cookie auth with a first-run set-password flow, the event bus, the `/api/ws` socket, the
web-security baseline (CSRF, WS Origin, cookie flags, rate limit, audit), and a `--demo`
mode that scripts fixture devices + a job exercising every WS event; the UI ships the auth
flow, a WS bridge feeding Zustand stores, and the Dashboard / device-details / Settings
pages bound to live demo data. A post-build review of qn.0+qn.1 (see decisions log
`qn1-review`) landed the top minors (no blocker/major). **qn.2 is BUILT + CLOSED** — the
`internal/muxd` plist protocol client + the `internal/device` registry (merge N muxers →
per-transport, per-source table keyed by UDID; reset-on-reconnect reconcile clears
detached-while-away phantoms; `device.*` events), wired into non-demo `quince serve` as the
live `DeviceReader`; full `make gates` + `make image` + `make gates-ui-e2e` green. **CI
stories 1–5 done; lab gates 6–7 (plug/unplug ≤1 s, netmuxd-USB audition) DEFERRED** — the
muxer-startup gap has since been RULED (decisions log (ar)): supervision + rescan + those
lab gates all land in **`qn.2b`**. **qn.2b is now BUILT (CI)** — the `internal/muxsup` muxer
supervisor (spawns the in-container usbmuxd `-f -S <socket>` in its own process group,
restart-w/-backoff, refuse-loudly on an already-served socket, crash-loop → `/api/health`
degraded), `POST /api/devices/rescan → 202|409` reusing the muxd reconnect→Reset→replay
reconcile, the `devices.manage_muxer` config key, and a UI **Rescan** control; `make gates` +
`make image` + `make gates-ui-e2e` green, and the supervisor was smoke-tested against the
**real** usbmuxd in the built image (`/api/health` → `muxer:{managed,state:"running"}`). **qn.2b
is now DONE** — **lab gate 7 (managed USB + Rescan) PASSED on real hardware** (Operator-confirmed on
staging; it surfaced + fixed a "live `/dev/bus/usb`" deploy-config gap, (av)); gate 8 (netmuxd-USB
audition) was **re-homed to qn.7** with a named owner (not a silent defer, (aw)). **qn.3 is BUILT +
CLOSED** — `internal/deviceops` (pair/validate/info wrappers + backup-encryption management over a **pty**,
never argv/env) + registry lockdown enrichment + the four frozen device-op endpoints + the `Op` lifecycle
+ pairing-record persistence + UI pair/encryption dialogs; full `make gates`/image/e2e green (spec-approved
with the architect's three amendments + two Operator acks). **Lab gate 8 PASSED on real hardware
(2026-07-20)** — fresh container → pair (UI) → recreate-still-paired (amendment 1) → change_password +
disable→enable, secrets proven absent from argv/env/log; four findings caught + fixed + CI-validated
(incl. a real enrichment auto-pair-on-locked-device bug). **qn.5 is DONE (CI-proven; landed
`285c40b`..`3ce5bb1`)** — the version store: `internal/storage` (4 backends + auto-probe +
journaled commit + `quince-version.json` markers + startup-reconciliation kill-matrix + adopted
discovery + encryption-branched structural `Verify` + `RepairWorkingCopy` + retention + the
(bi)/(bk) **mirror ladder**) + `clonetree` + a `versions` registry (the real `VersionReader`) +
`DELETE /api/versions/{id}` + `version.*` events + reconcile-before-serve + `deploy/storage.md`;
full `make gates`/image/e2e green ((bd), (bl)). A five-round mirror investigation ((bf)→(bk))
proved block cloning works at the POOL level but EPERMs in the unprivileged userns — the mirror
ladder clones from `working/` (never `.zfs`) via a host-side hook `mirror` verb / in-container
reflink / hardlink / copy. **Lab gate 12's remaining hardware legs (host-side mirror verb,
iMazing, syncoid, 12c destructive matrix) RE-HOMED to qn.4a** ((bm) — named owner, not a silent
defer). **qn.4a is now BUILT (CI-proven)** — the `internal/backup` job engine drives `idevicebackup2`
through the state machine into qn.5 storage (per-UDID single-flight, streaming supervisor with the
`<target>/<UDID>` symlink adapter, transcript-grounded parser, activity-sampler liveness + A3
disk-low, startup job reconciliation), the `jobs` store + command surface (`POST /api/jobs`, cancel,
`job.*`), and the `quince backup` CLI; `make gates`/image/e2e green, CI stories 1–14 (incl.
wifi-torn→`connection_lost`, verify-gate→`failed`, single-flight→409). **Lab gate 15 (real
encrypted USB backup e2e + kill-matrix + the re-homed gate-12 legs) is the remaining hardware step,
owned by qn.4a** ((bp)). **qn.4b is now BUILT (CI-proven)** — transport **`auto` resolution**
(`StartBackup` resolves against current presence — prefer USB when plugged, else Wi-Fi — stores the
CONCRETE transport on the `Job`, never `"auto"`; a device on neither transport → actionable **422**,
no job minted, design §4/(bp)), the **`quince versions verify`** + **`device repair-working-copy`**
CLI escape hatches (thin `buildStorage` + `storage.VerifyVersion`/`VerifyLatest`, browseRoot-resolved,
no new backend surface), the **live demo `JobControl`** (scripts on-demand jobs + a seeded failed job
for the retry affordance; single-flight shared with the ambient loop — reversing qn.4a's 503), and
the **UI** (live "Back up now" w/ transport override, one-tap **Retry** on failed intent groups,
**Cancel** on the running job — details page + dashboard card); `make gates`/image/e2e green, e2e
**story 4** (Back up now → cancel → retry) + the qn.4a Wi-Fi-success coverage finding retired (a
`wifi-incremental-success` story). **Lab gate 11 (both-transports UI-driven backup + honest Wi-Fi
disconnect) + gate 12c (destructive hardlink-safety matrix) — the consolidated hardware day with
qn.4a's gate 15 — remain the hardware step**, owned by qn.4b. Frontier is **qn.4b** until the
hardware day; **M3 closes then.**

## Open questions 2 and 3, and the `*Resolved:*` paragraph — verbatim, lines 294-312

   never committed).
2. ~~Who starts the muxer in the SIMPLE profile?~~ **RESOLVED 2026-07-20** — ruled
   option (a): quince-supervised in-container muxer behind `devices.manage_muxer`
   (refuse-loudly on an already-served socket) + `POST /api/devices/rescan`; landed as
   rung **qn.2b** together with qn.2's deferred lab gates. Full ruling: decisions log
   (ar); contracts §1/§6 + design §2 updated; the design capture stays in the qn.2 spec
   appendix.
3. ~~`Device.last_backup.job_id` → nullable?~~ **RESOLVED 2026-07-21 ((bz))** — approved and
   landed in contracts §2 ahead of the rung (the qn.2b precedent): `last_backup` derives from
   the newest **committed version** (survives restarts, covers adopted versions, which have no
   job → `null`), and means the last **successful** backup; a failed last attempt lives in the
   intent-grouped job history. Built by **qn.4c** (finding (v)).

*Resolved:* **project name = quince** (Operator, 2026-07-18, after due diligence — see
decisions log (y); repo `github.com/novkostya/quince`, images
`ghcr.io/novkostya/quince`, binaries `quince` / `quince-vault`, rung prefix `qn.`).
License = MIT. `@mercury-fx/ui` = not consumed; mainstream vendored-component stack
instead (decisions log (u)). GitHub owner = `github.com/novkostya` (org transfer only
on real traction).

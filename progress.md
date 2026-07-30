# quince — progress dashboard

**One-line state.** ⚑ **The product is FROZEN and soaking; the PROCESS REVAMP is complete through
`pr.5`, and only `pr.6` (the lockout) remains.** quince itself is unchanged since `qn.6b` landed and
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
**Unfreeze criteria — REWRITTEN 2026-07-30, because the old list could not be used** (quince-devlog#141).
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
**G4 (stop, don't guess) — GAP: the reviewer-triggered half is unproven.** quince#232, quince#260 and
quince#268 each show the implementer stopping, naming the question, and making no commit — so
**"does not guess" is proven**. But the ladder's trigger is *a review comment requiring a ruling*, and
every instance above was the implementer's **own** judgement. So **"hears the reviewer" is not proven**,
and that is not a technicality: quince#273 (a newly filed issue enters no watch) and quince-devlog#56 (a
watch event names the last commenter and counts the rest) are live evidence that the reviewer→implementer
channel drops signal. Recorded as a gap rather than a deviation, because the untested half is the half
those two issues say is broken.
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
**So nothing on the ladder blocks the unfreeze, and one gap rides with it.** The risk list carried *into*
the unfreeze rather than gating it: G4's unproven reviewer-triggered half (quince#273, quince-devlog#56);
the killed-session behaviour above; G5 unbuilt; #32's proof owed to a re-provision window; #33 needing a
re-file. **The unfreeze decision is the Operator's, and it is now a decision about risks rather than
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

| Rung | Title | State |
| --- | --- | --- |
| qn.0 | Floor: scaffold, gates, CI, image | **done** — gates + image green in quince-dev (2026-07-19) |
| qn.1 | Core daemon skeleton + demo mode + UI shell | **done** — full gates + e2e + image green in quince-dev (2026-07-19) |
| qn.2 | muxd client + live device table | **done** — muxd client + registry + UI; `make gates`/image/e2e green (2026-07-20); lab gates 6–7 → owned by qn.2b |
| qn.2b | Muxer lifecycle + hardware proof (supervision, rescan, lab gate 7) | **done** — `internal/muxsup` supervisor + `POST /api/devices/rescan` + `devices.manage_muxer` + `/api/health` muxer + UI Rescan; `make gates`/image/e2e green + real-usbmuxd smoke test (2026-07-20); **lab gate 7 (managed USB + Rescan) PASSED on hardware**; gate 8 (netmuxd-USB audition) re-homed to qn.7 (aw) |
| qn.3 | Device ops + Devices page | **done** — `internal/deviceops` (pair/validate/`ideviceinfo` + encryption via **pty**, never argv/env) + registry `Enrich` + enrichment driver + 4 frozen endpoints + `Op` lifecycle + audit + **pairing-record persistence** (amendment 1) + UI pair/encryption dialogs; `make gates`/image/e2e green (e2e story 3); coverage deviceops 80.2%, device 97.6%, httpapi 71.8%. **Lab gate 8 PASSED on hardware (2026-07-20)** — fresh container → **pair** (via UI, record persisted) → **recreate → still paired** (amendment 1 proven twice) → **change_password + disable→enable** cycle, all succeeding; **secrets proven** (`idevicebackup2 -i … {changepw,encryption off,encryption on}` — no password in argv, `BACKUP_PASSWORD` env count 0, clean logs). **4 findings fixed + CI-validated** (enrichment auto-pair on locked device; 3 UI) |
| qn.5 | Storage backends (zfs snapshot-native / reflink / hardlink / copy) + reconciliation | **done (CI-proven; landed `285c40b`..`3ce5bb1`)** — `internal/storage` (4 backends + auto-probe + journaled commit + `quince-version.json` markers + startup-reconciliation kill-matrix + adopted-version discovery + structural `Verify` (encryption-branched, A1) + `RepairWorkingCopy` + retention + the (bi)/(bk) **mirror ladder**: clone-from-`working/`, hook `mirror` verb → in-container reflink → hardlink-under-matrix → copy, surfaced/UNVERIFIED reporting) + `clonetree` (FICLONE/hardlink/copy) + `versions` registry + `DELETE /api/versions/{id}` + `version.*` events + reconcile-before-serve + `deploy/storage.md`; `make gates`/image/e2e green. **Proven in CI** (11 stories + reconciliation matrix + D5a anchored-filter contract) + **real-zfs commit/Verify on hardware** during the gate-12 investigation ((bf)→(bk)). **Lab gate 12's remaining hardware legs (host-side `mirror` verb, iMazing, syncoid, 12c destructive matrix) RE-HOMED to qn.4a** ((bm); named owner, legs preserved in the qn.5 spec). Ran BEFORE qn.4 (order ruled (ar)) |
| qn.4a | Backup engine + supervisor + minimal CLI (USB gate) | **built + landed (CI); gate 15 **FULLY hardware-proven** — ENGINE legs (bs) + zfs half (bw) + **iMazing-opens PASSED (cf)**** — `internal/backup` (state-machine engine + per-UDID single-flight + `idevicebackup2` streaming supervisor w/ the `<target>/<UDID>` **symlink adapter** + transcript-grounded parser + activity-sampler liveness w/ **A3** free-space watch + preflight + Seed→Verify→Commit/Discard + **startup job-row reconciliation**) + a `jobs` table/registry (real `JobReader`) + the job command surface (`POST /api/jobs` 202/409/422, `POST …/cancel`, `job.*` events) + the `quince backup` CLI (shared `buildLiveStack`); 6 lab transcripts extracted+scrubbed. `make gates`/image/e2e green; CI stories 1–14 incl. **wifi-torn→`connection_lost`** (a stall, not an error — sampler catches it), **verify-gate→`failed`**, **single-flight→409**, **startup-reconcile→`connection_lost`/rolled-forward-`succeeded`**. Coverage backup **83.2%** / store 80.8% / httpapi 72.2%. **Gate 15 split (clarified (bv)):** the ENGINE legs PASSED on real hardware (iPad, hardlink `/backups`) — CLI-USB backup both encryption variants (A1 encrypted `Verify` on real data), version rotation, interface facts 1+5, kill-matrix `backing_up`. The **zfs half is PROVEN ((bw))**: **engine→commit on the real zfs-hook backend** (encrypted, verified, version snapshot cut), host **`mirror` verb** + **`bclonesaved`** moving live (+~3 GB), **syncoid** mid-write (both `@quince-*` restore points + dirty `working/` replicated offsite) — the constrained forced-command hook key + `rbind,rslave` host→LXC→container propagation stood up on the real rpool; three deploy-doc hook bugs found+fixed (`$2`→last-arg, image-ssh-client, create-chown). Only **iMazing-opens** (Operator GUI) is unverified. **Landed on main.** |
| qn.4b | Wi-Fi first-class + transport policy + job-history UI (closes M3) | **built (CI-proven); lab gate 11/12c (hardware) pending** — transport **`auto` resolution** (prefer-USB-when-plugged, absent→**422** no job, concrete transport stored) + httpapi passes `auto` through; **`quince versions verify <id>\|--udid`** + **`device repair-working-copy <udid>`** CLI escape hatches (`storage.VerifyVersion`/`VerifyLatest`, browseRoot-resolved, no new backend surface); **live demo `JobControl`** (on-demand scripted jobs + seeded failed job for retry; single-flight; reverses qn.4a's 503); **UI** live Back up now (auto + transport override) / one-tap Retry on failed intent groups / Cancel on running job (details page + dashboard card). `make gates`/image/e2e green (e2e **story 4**: Back up now → cancel → retry). Retired the qn.4a Wi-Fi-success coverage finding (`wifi-incremental-success` story). Coverage backup **83.4%** / demo **55.3%** (was 0) / storage **78.2%** / httpapi 72.2% / cmd/quince 8.5% (CLI wiring hw-exercised). NOT a Wi-Fi demotion ((h) stands). **Lab gate 11 (both-transports UI-driven + honest Wi-Fi disconnect) + 12c (destructive hardlink matrix) = the consolidated hardware day with qn.4a gate 15**. **CLOSED (CI) 2026-07-20 ((by)):** its CI half is landed and complete; **gate 11 is RE-HOMED to `qn.4c`** (named owner — its Wi-Fi leg should run on SUPERVISED netmuxd, the shape actually deployed, not a hand-started one), **gate 12c is DEFERRED past the code freeze** (the destructive hardlink matrix gates a backend the Operator doesn't run — zfs deployment; the hardlink tier stays disabled-to-copy, surfaced), and findings (i)/(iv)/(v) **move to qn.4c**. No session work remains here. |
| qn.4c | **netmuxd supervision + usability fixes (the DAILY-DRIVER target)** | **DONE — CI-proven + LAB GATE 11 run on hardware ((ce)): 6/8 legs passed, (d) landed safely but mislabelled, (f)'s unencrypted half declared unrunnable with a reason.** Hardware: 33.3 GB full + cabled incremental committed over supervised netmuxd/usbmuxd, `auto`→USB proven, secrets clean on both transports, iMazing opened the committed `latest/` (retires qn.4a gate 15's last leg), cancel clean, verify+commit of 33 GB in 36 s, `bclonesaved` 46.5→80.1 GiB. A **gate-blocking** bug in landed qn.4a code was found AND fixed in-session ((cd)): the target stub on the cache filesystem made the device refuse any backup bigger than it. Seven findings filed. — `internal/muxsup` generalized to a daemon **`Spec`** (name/role/argv/probe-network/address) + **`Group`** (two daemons, one rescan) + the `plannedMuxers` resolution table; **netmuxd supervised** as `--host/--port --socket-path <private> --disable-usb` (every flag verified live; the private socket path is a SAFETY flag — netmuxd deletes and rebinds whatever socket it names, and its default is usbmuxd's: a silent USB blackout, reproduced then designed out, (bz)); `/api/health` **clean break** to `muxers:[{name,role,managed,state,detail,rescan}]`; rescan stays **USB-only**. Findings fixed: **(i)-A** `willEncrypt` exit-0-empty → `off` (`unknown` now means a real read failure), **(i)-B** preflight **re-reads encryption live** before refusing (cold-lockdown hard-fail gone; still-unknown refuses with the honest reason), **(v)** `last_backup` derived from the newest committed **version** (survives restarts, covers adopted, null `job_id`) + `AnnounceBackup` on commit success, **(iv)** verified **subsumed by running** (a new `DeviceCard` test proves the card already narrates verifying/committing). `make gates`/image/**e2e 6/6** green; **image smoke: both muxers `running`, `kill -9`d netmuxd respawned, usbmuxd socket intact**. Coverage muxsup **86.9%** / device 97.8% / backup 83.8% / cmd/quince 20.9%. Deploy: the **Wi-Fi mDNS constraint** is now first-class in `compose.nas.yml` (host-networking answer + honest security tradeoff + macvlan alternative), and P1b records the Wi-Fi twin of P1 ((ca)). **Lab gate 11 = the remaining hardware day.** History: inserted 2026-07-20 ((by)) to reach the Operator's "personally usable" bar before a planned code freeze. Scope: generalize the hardware-proven `internal/muxsup` to **co-supervise netmuxd** (config-gated, TCP probe vs its unix-socket one, restart-with-backoff, health surfaced — without it nothing starts netmuxd on `compose up`, so Wi-Fi dies silently after any restart: the qn.2b-for-usbmuxd reason, pulled forward from qn.7) + fix qn.4a findings **(i)** `willEncrypt`→`unknown` mis-map + the cold-lockdown race that hard-fails a legitimate encrypted backup at preflight, **(v)** the engine never writing `device.last_backup` (→ "No backups yet" on a device with real versions), **(iv)** the card lingering at "Backing up 100%" (likely subsumed by (v)). **Inherits qn.4b gate 11** — both transports UI-driven, live progress observed on a real backup, Wi-Fi over SUPERVISED netmuxd surviving a container restart, + the iMazing glance. Gate 12c stays deferred past the freeze. |
| qn.5b | **Atomic `latest` + `working/` lifecycle redesign** | **BUILT (CI-proven) 2026-07-24 ((cp)); spec approved-with-amendments ((co)).** `make gates` + `make image` green in `quince-dev` (backup 85.2% / storage 78.9% / httpapi 73.2%). **Atomic `latest`** via in-container `renameat2(RENAME_EXCHANGE)` (RENAME_EXCHANGE confirmed working on the CI tmpfs by the primitive test); **per-job `working/<udid>`** seeded from `latest/` via the backend's SAFE strategy (hardlink→copy, amendment A), kept dirty on FAILURE (retry resumes, proven no-re-transfer), removed on success; **commit reordered** verify→exchange→snapshot (marker-guarded resume across the non-idempotent exchange — kill-matrix green); **symlink dance DROPPED** (idevicebackup2 target = the storage `working/` parent → free-space bug 28b97de structurally impossible); **snapshot rename** `quince-<YYYY-MM-DDTHH-MM>-<ULID>` (amendment B: ULID kept); **honest internal `kind`** from the seed decision (finding #9(a)); **Reset** REST + CLI (accepted contract proposal). The two-observer gate is a CI concurrent-reader proof (`latest/` never missing/torn across a commit, both models). Hook `mirror`→`seed` verb; offsite filter drops `work/**`; canon (stack D5/D5a, design §4/§5, contracts §1/§2/§6, deploy/storage.md) updated. **Lab legs PROVEN on hardware 2026-07-24 ((ct)):** G-exchange-live/G-snapshot/G-rclone on the real rpool, Reset, keep-dirty-working, resume-without-re-seed, and **both** iPad (3 GB) + iPhone (34 GB) full cycles — plus a hardware-found seed-timeout bug fixed ((cs), branch `claude/qn5b-seed-timeout-fix`). Follow-ups RULED ((cv)): missing-versions UI ((cr)(a)) + seeding phase ((cu) opt 1) → qn.6a; continuous-reconcile ((cr)(b)) → epic (cl) constraint #7; **Finding B CLOSED ((cw), reviewed+landed (cy))** — `seed_in_progress` guard, legacy-safe, shared `prepareWorkDir` across both models; Wi-Fi failures are qn.7 (not qn.5b). **qn.5b FULLY closed**; latency mechanisms for (cu) parked evidence-gated ((cx)/(cz): gate patch dominates stand-in; in-process declined). Inserted 2026-07-22 ((cg)); ran **before the B2 cron is trusted**. Fixes the stack-D5 `PROPOSED (gap)`: both swap paths do `mv latest→latest.old; mv latest.new→latest`, so `latest/` briefly **doesn't exist** — an rclone sync crossing it **deletes the remote copy**. Scope: **exchange-rename** (`renameat2(RENAME_EXCHANGE)`, verified live on ZFS first; hook keeps the FICLONE reflink, quince does the privilege-free exchange); **per-job `working/`** seeded as a reflink clone of `latest/` at job start (between backups the dataset holds only `latest/` — snapshots structurally clean), **keeping the dirty `working/` on FAILURE so a retry resumes**; **commit reordered** to verify→exchange→snapshot so the version IS `latest/`; **the `<target>/<UDID>` symlink dance dropped** (it caused the free-space bug 28b97de); post-failure **Retry / Reset (± Retry-clean)** UX — 2-vs-3 actions is the implementer's call, landed as a contract proposal for review (`Reset` = the landed `RepairWorkingCopy`, CLI-only today). Collapses D5's two version models toward one. **Also inherits gate-11 finding #9(a) ((cj)): honest `full`-vs-`incremental` `kind` derived from whether `working/` was seeded from an existing `latest/` — the authoritative signal, replacing the unreliable `IsFullBackup` flag — and re-confirms the server single-`is_latest` invariant holds after the commit reorder.** |
| qn.6a | **Soak-ready UI (mobile + offline devices)** | **DONE — BUILT (CI-proven) 2026-07-24 ((da)), REVIEWED + LANDED ((db), main `3a7b068`); the `seeding`-as-STATE call ratified ((db) ruling 1); two process deviations recorded as revamp evidence.** `make gates` + `make image` + `make gates-ui-e2e` green in `quince-dev` (backup 85.2% / device 97.2% / store 81.3% / demo; UI 46 vitest + 5 e2e stories, mobile leg at 390×844). Delivered: **both ruled contract changes landed** — `missing: bool` on `wire.Version` (§2) + a `seeding` state between `preflight`/`backing_up` (§2, chosen as a STATE not a bare phase — the engine models lifecycle stages as states and the card labels off `job.state`); the engine emits `seeding` around storage Seed (preflight split into checks-only + a seeding step), demo scripts it; **offline devices** (migration `0004_device_identity`, persisted identity + last-seen, `Registry.Devices()` unions live presence with `KnownUDIDs()` = distinct UDIDs with versions, offline shell has no transports + a disabled-with-reason "Back up now", and a live online→offline card transition on last-transport detach); **dead versions rendered dead** (no size/Unlock, "artifact gone — remove?" on `DELETE`, never omitted); **gate-11 findings** — #6 failed-newest "needs attention · Retry" card line, #7 client single-`is_latest` invariant in the versions store, #10-byte honest "current file" labelling, (ck) `kind` dropped from the version card; **the log-blob `SplitFunc`** (split on `\r` so progress redraws are per-frame → latest bytes, clean pane, and pure-redraw frames dropped from the log = the bloat fix); **mobile-first pass** (responsive shell: sidebar→top-bar, touch targets, no horizontal overflow, log/dialog/version-list/history reflow). Friction notes recorded (`docs/specs/qn.6a/friction-notes.md`). Original scope below. **queued after qn.5b** — inserted 2026-07-22 ((ch)) so the app is genuinely usable *before* the freeze and **soaks under real daily use on staging while the process revamp runs** (the revamp is process work; the codebase is idle, and soak time can't be backfilled). **Mobile is the precondition, not polish** — desktop-only means the daily use never happens. Scope: **responsive/touch pass over the EXISTING IA** (not an IA redesign — the desktop-shaped job-log pane, version lists, dialogs and history table are the work); **offline devices listed** (union live muxd presence with UDIDs already in the versions registry + persist the identity already fetched at enrichment; same card shape with **disabled-but-explained** "Back up now", last-seen, version count); **device labels in the backup list**; gate-11 findings #6 (**failed newest attempt gets a "needs attention · Retry" line — CORE to the soak: invisible failures make the soak worthless, (cj)**), #7 (client single-`latest` invariant), #10-byte (honest byte labelling); **from the qn.5b hardware session ((cv)):** dead versions rendered **explicitly dead** (`missing: bool` on `wire.Version`, no size/`Unlock`, "artifact gone — remove?") + a **`seeding` job phase** narrating "Preparing — cloning from your last backup…" (both contract shapes ruled); and the gate-11 **log-blob `SplitFunc`** fix if it stays small (one fix clears the mangled pane + stale byte counter + log bloat — directly on the soak path). **NOT in scope:** storage onboarding (qn.6, beside P1/P1b), the Synology/alpha prerequisites (DSM feasibility spike + **12c**, which un-defers the moment a non-zfs tester appears). Forward note: **"Wake up"** via Web Push is a post-qn.12 **spike**, not this rung. **Last rung under the current process** — its friction notes feed the revamp as evidence. |
| qn.6 | v0.1 release shape (after qn.7) | outlined |
| qn.6b | **Transport patience (LAST pre-freeze insert, (de))** | **LANDED 2026-07-24 ((df) build, (dj) review, main `3720f84`); LAB LEGS RUN 2026-07-25 ((dm)) — stories 9/10/11 validated on real hardware: candidate C (fast passcode + seed-during-gate on the zfs hook), the liveness patience (rode through a multi-minute device-side pause, no false kill), and kept-dirty-working RESUME-TO-COMPLETION all PROVEN; the bad-link `-4` (band-roam-induced TLS reset, unrescuable in-flight) is a well-scoped qn.7 item (auto-resume + `-4`→connection_lost). qn.6b lab debt CLEARED. Spec approved-with-amendments ((dg)/(dh)).** `make gates` + `make image` + `make gates-ui-e2e` green in `quince-dev` (backup 83.5% / deviceops 81.5% / storage 78.1%). **(1) Patched libimobiledevice built FROM SOURCE** at pinned `LIBIMOBILEDEVICE_REF=1.4.0` with two in-tree patches (`deploy/patches/libimobiledevice/`): `0001` raises the 30 s service receive timeouts → 15 min (#1413; `property_list_service.c`+`service.c`); `0002` adds `idevicebackup2 --gate <path>`. Only libimobiledevice is built (Alpine 3.24 ships the deps incl. the undocumented `libtatsu`); runtime `idevicebackup2 --help` lists `--gate`, the on-disk lib is `1.4.0-dirty` (the patched build wins over usbmuxd's soname-pulled apk copy), `-progs` dropped. **(2) Gate patch (candidate C):** the engine launches idevicebackup2 gated (passcode fires ~1–2 s), captures the fresh `Info.plist`, seeds `working/` in parallel (storage `Seed` split into `PrepareWork`/`SeedWork`), restores the `Info.plist` over the clone, opens the gate — proven end-to-end (`TestStoryGatedSeedOverlap`: committed version carries the FRESH `Info.plist`, passcode narrated during seeding; resume bypasses the gate). **(3) Liveness retune:** `LivenessTimeout` 15m → **18m** (= `toolReceiveTimeout` 15m + 3m margin) with a mechanical coupling guard — the sampler out-waits the tool's patience so a flap the tool rides out is never SIGKILLed, and (spike) a cleanly-idle dead link (tool loops `-5` forever) is classified only by the sampler. **Amendment A ((dg)):** the one unbounded non-backup tool op (`Manager.Validate`) bounded by `deviceOpTimeout` 30 s (interactive pair/encryption keep 2m/5m, both < 15m). **Item-4 verdict:** the captured Wi-Fi hang (`Could not receive (-4)`) was the tool's own exit (`outcomeProcErr` at ~44 s), NOT a sampler miss — a tool-patience defect item 1 targets; quince behaved correctly (kept dirty working). Contract changes: **NONE** (enum/state reused). Canon updated (stack D2, design §4 + the `seeding` state added to the state diagram, missing since qn.6a). Privacy swept clean (pcap fixtures local-only; patches infra-free). **Lab legs (were owed, now RUN — (dm)):** story 9 characterized (the `-4` boundary), stories 10/11 passed; candidate B not needed. Branch `claude/qn6b-*`, not pushed; architect lands ff-only via PR-CI. |
| qn.7 | Wi-Fi reliability hardening (before v0.1) + **the netmuxd-USB audition (re-homed from qn.2b, (aw))** | outlined — **netmuxd co-supervision MOVED to qn.4c** ((by)); qn.7 keeps the patched-timeout libimobiledevice build, restart-policy tuning, the chaos suite, liveness thresholds, and the audition. Deferred past the code freeze |
| qn.8 | Vault: unlock, lazy browse, conformance suite | outlined |
| qn.9–10 | Domain viewers (overview / messages) | outlined |
| qn.11 | Photos viewer | **parked, lowest priority** (icloudpd+Immich cover photos; Apple-thumbnails spike first if revived) |
| qn.12 | PWA + push + schedules | outlined |

**Open questions for the Operator** (tracked here until resolved):
1. LAN registry port + creds (address recorded in `local/environment.md`; env-only,
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

**Decisions log.** *(Newest entries append at the bottom.)*
- 2026-07-18: full planning pass (this docs set) from the feasibility lab
  (`../local/chatgpt-original-idea-chat.md`); Go core + Python vault + React/mercury-style UI;
  USB primary / Wi-Fi experimental; ZFS first-class with hardlink portable fallback.
- 2026-07-18 (Operator review): (a) vault seam made explicitly swappable — a future
  all-Go vault is a drop-in behind `vault.Vault` + the conformance suite; (b) host
  auto-snapshot tooling rejected — quince relies only on snapshots it creates; (c) the
  never-mutate-latest layout (`versions/` + `latest` + `work/`) adopted — dataset is
  crash/replication-consistent at any instant (sanoid/syncoid-safe), rollback machinery
  deleted; (d) persistent backup-content indexing rejected in favor of lazy
  session-scoped reads; sole exception = fingerprint-validated derived caches
  (thumbnails, qn.11). Side effect of (d): no secrets at rest in v1.
- 2026-07-18 (Operator review 2): (e) photos parked at lowest priority — Operator's photo
  pipeline is icloudpd + Immich; if revived, spike Apple's prebuilt in-backup thumbnails
  (`Media/PhotoData/Thumbnails`) before any generation/cache machinery — likely moots the
  derived-cache exception entirely; (f) operations UX fixed as a core value (stack D12):
  Plex-grade setup (compose up → onboard in UI, everything configurable in-app) with
  OpenWrt/PVE-grade config — one tidy hand-editable `config.yml` as source of truth,
  atomic validated writes, no secrets in it, UI is an editor over the file.
- 2026-07-18 (external crosscheck review, `../local/chatgpt-planning-crosscheck-feedback.md`,
  adjudicated with the Operator): **Operator rulings** — (g) zfs backend is
  snapshot-native (in-place `current/`, versions = quince's own snapshots, no hardlinks
  under ZFS; consistency guarantee restated per-backend: on zfs it lives in the
  snapshots, the head is a working buffer); (h) Wi-Fi is the PRIMARY use case —
  first-class transport from qn.4, hardening rung (qn.7) moved BEFORE v0.1, experimental
  flag removed (rejects the crosscheck's Wi-Fi demotion). **Crosscheck adopted** —
  journaled commit + first-class startup reconciliation with on-disk
  `quince-version.json` markers; two-level verification (structural at commit, content
  canary at next unlock); vault RPC hardening (framed `initialize`, `materialize` with
  opaque handles — no paths cross the boundary, scratch-jailed vault); web security
  baseline pulled into qn.1 + audit trail + tmpfs scratch honesty; hardened deployment
  profile (muxd split) as a qn.6 compose example; domain APIs envelope-frozen only,
  fields after research spikes; D12 config staged (core in qn.1, live-reload/comments in
  qn.6); headless CLI added to qn.4; destructive hardlink-safety matrix replaces the
  single-file inode check. **Crosscheck rejected** — per-version/clone ZFS datasets
  (don't propagate into container bind mounts; fragile hook chains), CLI-first roadmap
  restructure (parallel tracks already decouple UI; CLI lands inside qn.4), Wi-Fi
  demotion (see h).
- 2026-07-18 (Operator clarification, second pass): the offsite model is **whole-tree
  file-level sync** — one rclone job over the entire storage parent (e.g.
  `/rpool/userdata`), walking live mounts; per-dataset `.zfs` paths don't fit it. Design
  restated as D5a: each zfs device dataset holds `current/` (in-place working copy,
  excluded by one static rclone filter) + `latest/` (verified mirror rebuilt at commit —
  reflink clone preferred, probed fallbacks hardlink/copy — atomic swap); flow =
  `zfs snapshot -r && rclone sync /rpool/userdata b2:…`, remote history via B2
  versioning/`--backup-dir`. **Operator ruling: one child dataset per device**
  (independent snapshot streams; snapshot list = version list), so the constrained hook
  gains `zfs create` scoped to children of the parent; dataset destroy stays
  human-only. PVE bind-mount propagation gotcha (new child = empty stub in a running
  LXC) handled by probe + printed `pct set` instructions; Docker via `:rshared`;
  single-dataset fallback mode documented.
- 2026-07-18 (Operator Q&A, third pass): (k) PVE propagation — recommended mount is a
  raw `lxc.mount.entry … rbind,rslave` (+ `propagation: rslave` on the nested OCI bind),
  making new child datasets appear live without restart; probe verifies, `pct set`
  instructions remain the fallback; (l) FICLONE works through container bind mounts
  (syscall reaches the real fs) — cloning implemented in-process in Go, so busybox `cp`
  is irrelevant; host OpenZFS must have block cloning (2.2+, probed); (m) **`reflink`
  promoted to a first-class backend and the auto-default** wherever the FICLONE probe
  passes (Btrfs/Synology, XFS, hookless ZFS) — `zfs` backend selected only on explicit
  config intent (`storage.zfs.*`), per the Operator's proposal; hardlink-safety matrix
  now applies only where hardlinks are actually used.
- 2026-07-18 (crosscheck v2 adjudication + Operator's passcode correction): **the
  product model is ASSISTED backup** — Operator established that modern iOS demands
  on-device passcode entry for every backup, so unattended backups are impossible;
  auto-retry ladder deleted (failed → `user action required` + one-tap manual retry
  with `retry_of`; run/attempt grouping thereby unnecessary); Shortcut becomes a dumb
  opportunity signal with ALL policy server-side (`/api/automation/backup-opportunity`,
  staleness + cooldown config); v0.1 gate rewritten to a week of real UI-driven Wi-Fi
  backups, qn.12 gate = the assisted acceptance list. Crosscheck v2 refinements
  adopted: zfs `latest/` built from the snapshot's `.zfs` path (snapshot = canonical
  version, latest = materialized view; FICLONE-from-snapshot probed with lock-guarded
  fallback); "self-heals" softened to candidate-plus-verification with
  `repair-working-copy` escape hatch; liveness = activity sampler with staged states
  (`active → silent_but_connected → suspected_stall`) + `waiting_for_passcode` pause;
  **`latest/` is a real directory on all backends, never a symlink** (namespace commit
  = journaled rotation, offsite filter excludes `versions/` too); roll-forward
  principle — post-verify artifacts are never destroyed by recovery, reconciliation
  completes commits instead of unwinding them.
- 2026-07-18 (crosscheck v3 + Operator): (p) **Intent model adopted lightweight** —
  `intent_id` (retry-chain root) + `attempt` on Job; UI groups history by intent
  ("Backup completed after 1 retry"); full server-side Intent entity parked as future
  evolution (Operator liked the concept; ChatGPT itself rated it non-essential for v1).
  (q) **`current/` renamed `working/`** (Operator ruling: names must be readable
  without context — `working`/`latest` self-explains, `current`/`latest` doesn't).
  While renaming, the offsite filter examples were fixed to **anchored** rules — an
  unanchored `**/working/**` exclude would silently drop same-named dirs inside backup
  content (corrupted offsite copy, no error); deploy docs must ship the exact anchored
  filter block.
- 2026-07-18 (Operator concern → process + first gap): (r) **the gap protocol** —
  CLAUDE.md's "everything is decided" softened to canon-so-far; the program doc now
  defines what an agent does at a gap: rung-local → decide in-spec + log (*rung-ruled*);
  architectural → `PROPOSED (gap)` block in the canon doc + open question + STOP for
  Operator ruling; silent deviation and silent doc-vs-reality "fixes" forbidden.
  (s) **first gap processed — backup-encryption management** (Operator-spotted):
  `Device.backup_encryption` from `WillEncrypt`; `POST /api/devices/{udid}/encryption`
  (enable/change_password/disable; passwords via pty or `BACKUP_PASSWORD` env, argv
  forbidden; on-device passcode step narrated); `backup.require_encryption: true`
  policy enforced actionably at preflight; unencrypted devices get a persistent warning
  (no Health/Keychain/passwords) and unencrypted versions carry `encrypted: false`
  badges; one-password-two-uses documented (device backup password == vault unlock
  password; quince sets it, never stores it). Landed in qn.3 scope.
- 2026-07-18 (Operator rulings, product/UX round): (t) **device-centric IA** — one
  primary area (`Devices` + `Settings`); home = Devices dashboard (device cards,
  `Back up now`, inline job progress, N most recent backups across devices — composed
  to look alive for small fleets); backups live inside their device's details page;
  phone-first entry point (PWA opened from a backed-up device lands on that device)
  parked for qn.12. (u) **frontend stack finalized** (revision of D7): Tailwind v4 +
  vendored shadcn-style components on Radix + Zustand + TanStack Query/Virtual; Effector
  dropped and `@mercury-fx/ui` not consumed (Operator wants maximally mainstream,
  maintainable, lightweight, LLM-fluent; mercury stays a taste reference). (v) license
  = MIT. (w) GitHub owner = Operator's personal account (org transfer only on real
  traction); handle pending — later confirmed as `novkostya`. (x) the original codename
  `compote` ruled out as the production name — naming brainstorm opened.
- 2026-07-18 (naming, final): (y) **the project is named `quince`.** Vetted: GitHub
  exact-name sweep (nothing above 31★; runner-ups sunduk/coffret/cargohold recorded in
  chat), npm/PyPI hits are dead micro-packages, Docker Hub clear, no dev-tool product
  conflict (QuinCe the oceanography QC tool is a distinct stylization in a distant
  field; the Quince fashion brand is retail-class — negligible confusion for a free
  self-hosted tool; re-check trademarks properly before any commercialization). All
  docs, rung IDs (`cp.` → `qn.`), env prefixes (`QUINCE_`), snapshot names
  (`@quince-*`), and marker files renamed from the `compote` codename this day.
- 2026-07-18 (post-rename completeness audit, Operator-requested): (z) full doc sweep
  against the conversation's decision history. Fixed: a stale D3 paragraph still
  describing the deleted auto-retry backoff ladder (contradicted D13; replaced with
  assisted-model wording); `reflink` missing from the `Version.backend` enum and two
  "hardlink/copy"-only phrasings; a leftover pre-reflink auto-probe sentence in design
  §5; qn.1 roadmap wrongly including file-watch (staged to qn.6 per D12); lab
  deployment note updated to the `rbind,rslave` recommendation; `dirty-current` →
  `dirty-working` leftovers; stale module-path rename note in qn.0. Gap closed: pair/
  encryption ops returned `op_id` with no way to observe them — added `Op` object,
  `GET /api/ops/{op_id}`, and `op.updated` WS event (the "tap Trust"/"enter passcode"
  narration channel). All other rulings verified present and correctly stated.
- 2026-07-19: (aa) repo root = `~/iphone-backup-app` as-is (git init in place, qn.0);
  the `chatgpt-*.md` planning transcripts and the generated `quince-planning-pack.md`
  stay on disk but are **gitignored** — private lab material never enters the public
  repo; committed transcript fixtures are the durable extract.
- 2026-07-19: (ab) device scope widened in wording (Operator): iPhone AND iPad are
  first-class (same pairing/MobileBackup2 protocol, no extra code); Vision Pro
  untested/unpromised (visionOS may be iCloud-only); Apple Watch out of scope (no
  backup protocol). No iPhone-string-specific code allowed.
- 2026-07-19: (ac) **dev environment ruled** (Operator, after the first qn.0 session
  correctly stopped at the undocumented gap): the driving workstation is a thin client —
  no toolchains or container runtime on it, ever; all gates/builds/pushes run in a
  dedicated `quince-dev` LXC on the Operator's local PVE host (same LAN as the
  test iPhone and the LAN registry); the remote big-iron host is NOT in the dev loop —
  heavy repeatable CI is GitHub Actions. Concrete hosts/addresses/sizing live in
  `local/environment.md` (gitignored Operator-local layer, created this day). Program
  doc gained "Where work runs"; qn.0 gained story 0.
- 2026-07-19: (ad) **public/private doc split** (Operator-spotted: the dev-env edit was
  about to push homelab internals to the public repo): `local/` (gitignored) now holds
  all Operator-specific facts — hosts, LAN addresses, container sizing, lab details;
  public canon states rules generically and references `local/environment.md` by path
  only. Personal identifiers scrubbed from public docs (example device names, private
  design-system paths). Standing rule: hostnames, IPs, topology, and hardware specifics
  never enter committed files.
- 2026-07-19: (ae) **dev box is Alpine + nerdctl via the house template flow** (Operator
  overruling the architect's Debian suggestion; the glibc-for-Playwright concern is
  solved the Alpine way — containerized Playwright runner, or system chromium; qn.1
  verifies and records). Template built by the Operator's template-factory script with
  buildkit enabled (the existing template lacks it); the clone is **resized up front**
  (cores/RAM/swap/rootfs) because template defaults will OOM/ENOSPC on builds — never
  wait for the OOM to size a build box. `TMPDIR` moved off the small tmpfs `/tmp`.
  Multi-arch images stay in GitHub Actions; local builds are amd64-only. Full sequence
  with exact commands: `local/environment.md`.
- 2026-07-19: (af) **the dev host is a container host, not a toolchain host** (Operator
  ruling, superseding the apk-toolchain part of (ae)): no language toolchains install
  on any host, ever — every gate target runs inside a pinned toolchain container
  (nerdctl/docker autodetect in the Makefile), using the same base images as the
  production Dockerfile stages; `versions.env` pins image references in exactly one
  place; named cache volumes keep it fast; Playwright runs in its official image
  (musl question mooted); CI runs the identical containerized `make gates`.
  Contributor requirement collapses to `make` + a container runtime.
- 2026-07-19: (ag) **the qn.0 usbmuxd `PROPOSED` gap is dissolved, not chosen between**:
  the architect verified live that `usbmuxd` IS packaged in Alpine community on every
  branch v3.21–v3.24 — the session's probe was faulty. Runtime ships it via `apk add`;
  profiles unchanged (simple = in-container daemon + USB mapping, hardened = host
  socket). Operator's netmuxd-only question ruled alongside: netmuxd alone fully serves
  **pre-paired, Wi-Fi-sync-enabled** devices, so netmuxd-first sequencing inside
  qn.2/qn.3 is encouraged — but initial pairing and enabling Wi-Fi sync are USB-only at
  the protocol level, so USB stays in scope with hardware validation in the lab CT, and
  fresh-device USB pairing must work by the qn.6 gate. Lesson added to D2: verify
  package existence with `apk search` against the target repo, never assume.
- 2026-07-19: (ah) **netmuxd is the single muxer for BOTH transports** (Operator-
  identified, README-verified, superseding the two-daemon halves of (ag) and D2's
  original wording): netmuxd v0.4+ handles USB natively via `nusb` — "no dependency on
  a separate usbmuxd daemon"; the project outgrew its network-only name. Core's muxd
  client targets N configured sockets with N=1 default; classic usbmuxd stays in the
  image as a config-only fallback because netmuxd's USB path is young (v0.4.3 released
  2026-07-14) vs usbmuxd's decades — lab gates in qn.2 (presence + fresh USB pairing)
  and qn.4/qn.5 (sustained USB backup) decide whether the fallback is ever needed.
  Protocol floor unchanged: fresh-device adoption requires a USB connection regardless
  of which daemon serves it.
- 2026-07-19: (ai) **Operator recalled hard evidence against netmuxd-USB** — an initial
  USB backup through netmuxd died with a "packet too big"-style error at the 64 MiB
  boundary + 1 byte (hardcoded-guard signature; unreported in netmuxd's tracker as of
  today; observed version unknown). Ruling amended: **default USB topology = usbmuxd,
  netmuxd serves Wi-Fi** until qn.2's netmuxd-USB audition (presence + fresh pairing +
  a >64 MiB transfer on pinned v0.4.3) passes clean, whereupon the default flips to
  single-muxer; a reproduction gets filed upstream with the signature, with a
  patched-pinned-build option (the qn.7 libimobiledevice pattern). N-socket client
  design makes the flip config-only either way.
- 2026-07-19: (aj) **the (ai) signature corrected against the lab log** (Operator found
  the exact line, dated 2026-07-13): it's the **64 KiB u16 boundary**, not 64 MiB —
  `netmuxd::usb::mux … asyncReadComplete, message was too large (65536 bytes,
  max = 65535)` — i.e. netmuxd HAD USB support during the lab and its mux read path
  choked one byte over `0xFFFF` on real backup traffic; plausibly a one-line fix.
  v0.4.3 shipped the NEXT DAY noting "Fixes iTunes on the Apple mux" — possibly this
  bug, unconfirmed; the qn.2 audition (real backup traffic on pinned v0.4.3) decides.
  Exact line quoted in stack D2; default topology ruling from (ai) unchanged.
- 2026-07-19: (ak) **RETRACTION of the "faulty probe" accusation in (ag)/(ah)**: the
  authoritative per-branch APKINDEX check shows `usbmuxd` in **Alpine 3.24 community
  ONLY** (absent 3.21–3.23) — the qn.0 session's original finding was CORRECT for its
  3.21 base; the architect's all-branches "verification" was the flawed one (apk's
  `--repository` appends to configured repos; all four queries were answered by the dev
  box's own 3.24 repo). The build session's `ALPINE_VERSION=3.21 → 3.24` bump is
  ratified — additionally right because 3.21 (Nov 2024) nears EOL while 3.24 is current
  stable and matches the dev/lab CT line. Follow-up (non-blocking): align toolchain
  images to 3.24-based tags where published. Lesson upgraded in D2: verify package
  claims against the branch APKINDEX or a clean container of that branch.
- 2026-07-19: (al) **new hard rule: "version pins are looked up, never remembered"**
  (Operator-proposed after tracing the 3.21 pin to LLM training-data staleness — a
  model's "current" is its training cutoff's current; third staleness incident today
  incl. two of the architect's). Every pin introduction/bump queries the live source at
  pin time, prefers the newest stable with support runway, and comments any deviation
  from newest with its reason. Landed in the program doc's hard rules.
- 2026-07-19: (am) **the private layer is now version-controlled** (Operator concern:
  gitignored = untracked, unbacked-up, unsynced — quince-dev had no `local/` at all):
  `local/` is a nested git repo pushed to a **private GitHub repo only** (Operator
  choice over self-hosted bare / hybrid), privacy verified; the four `chatgpt-*.md`
  lab/review logs MOVED into it (public doc references updated to `local/chatgpt-*`);
  clone landed on quince-dev (sync gap closed) with a deploy key awaiting the
  Operator's read-only registration; convention added to the program doc — sessions
  editing `local/**` commit in the nested repo. Root `/chatgpt-*.md` gitignore patterns
  retained as belt-and-braces.
- 2026-07-19: (an) **privacy incident + new hard rule**: early qn.0 commits carried LAN
  IPs/hostnames in docs and commit messages; the Operator had the implementer rewrite
  history to scrub them (history verified clean post-rewrite). Cemented in the program
  doc: privacy is a **commit-time gate** — private facts never enter committed files,
  commit messages, branch names, or fixtures; `make privacy-check` (new target) greps
  every staged diff against `local/privacy-patterns.txt` (private repo; no-ops for
  contributors/CI); leak-reaches-history = incident = rewrite + pattern added.
- 2026-07-19: (ao) **Go rewrite of the decryption library greenlit as a parallel
  independent project** (Operator-proposed; scope verified small+frozen — reference lib
  last released 2024, format stable since iOS 10.2, all primitives have mature Go
  counterparts). Repo `github.com/novkostya/ios-backup-crypt` (name vetted 2026-07-19 — 0 GitHub
  collisions, module path + pkg.go.dev free; public MIT; seed CLAUDE.md/README/LICENSE
  authored, awaiting kickoff); includes a test-only encrypt/builder that
  doubles as qn.8's synthetic-fixture generator. **Subprocess boundary kept** (Operator
  ruling): quince-vault becomes a thin Go binary on the unchanged stdio RPC; key
  isolation preserved. qn.8's vault implementation is now conditional — Go if the
  library passes the conformance + real-backup differential gates by rung start,
  Python otherwise. Zero coupling: quince contracts and schedule unaffected either way.
- 2026-07-19: (ap) **improvement-proposal channel added** (Operator-proposed, designed
  with the architect): a non-blocking sibling of the gap protocol — implementers may
  file at most ONE proposal per rung, at rung end only, never pre-implemented, meeting
  a material-value bar (correctness/reliability/security/UX/maintenance; anti-bikeshed
  clause), into `docs/quince.proposals.md`; Operator triages accepted/declined(+why)/
  parked, and decline reasons accumulate as readable taste. Rationale: implementers
  have repeatedly out-seen the canon (Alpine 3.24, Tailwind pin, Makefile design) but
  had no legitimate outlet; the cap + timing + no-prototype rules keep the
  no-improvising discipline intact. quince-only (Operator: ios-backup-crypt is
  near-complete — no value installing process there).
- 2026-07-19: (ag) **qn.0 BUILT — the floor stands.** Provisioned `quince-dev`
  on the PVE host per the `local/environment.md` sequence verbatim (Alpine+nerdctl+buildkit
  template → clone → sized → `<lan-ip>`); recorded the exact `pct` commands back into that
  file. Scaffolded `core/` (Go: `serve`+`version`, `/api/health`, `go:embed` UI, slog,
  race-tested), `vault/` (uv `quince-vault` with `selftest` importing
  `iphone_backup_decrypt`), `ui/` (Vite+React+TS+Tailwind v4 sidebar shell, vitest), the
  containerized `Makefile`, multi-stage `deploy/Dockerfile` (netmuxd built from source),
  CI, compose examples, `deploy/dev.md`, transcript-README. **Proven in-container:** full
  `make gates` green, `make image` green, and the image's runtime gates
  (`version`/`health`/`selftest`/embedded-UI) all pass. Rung-ruled bootstrapping fixes
  (in the qn.0 spec + `versions.env`): uv image `-alpine` tag, Tailwind `4.1.18` (4.0.0
  crashes), Rust `1.88` (netmuxd needs edition 2024), pnpm `overrides.vite`, mypy
  stub-override, vault venv built at its final path against the runtime python.
  **`.gitignore` bug caught by testing**: trailing inline comments silently disabled the
  private-file rules — rewritten with column-0 comments; private lab logs now verified
  `!!` ignored. **Registry push proven**: `make push REGISTRY=<lan-registry>` pushed
  `quince:local` to the LAN registry (endpoint in `local/environment.md`) and it pulls
  back. Per (ak)'s follow-up the toolchain images were then migrated to a single
  Alpine-3.24 line (Go 1.26.5 / Node 22.23.1 / Rust 1.97.1 / golangci-lint v2), re-proven
  green; the `usbmuxd` daemon (Alpine 3.24 community) now ships in the runtime — so the
  old D2 `PROPOSED` gap is closed, not open. Before any push, one privacy incident
  (Operator infra in commit messages + an earlier version of this entry) was scrubbed by a
  full `git` history rewrite — the origin of the "Privacy is a commit-time gate" hard
  rule. Next frontier: **qn.1** (spec to be written).
- 2026-07-19: (ah-qn1) **qn.1 BUILT — the app frame stands.** Full `make gates`
  (go + vault + ui), `make gates-ui-e2e` (Playwright stories 1–2), and `make image` green
  in `quince-dev`. **Core** (`core/internal/{wire,config,store,auth,bus,ws,demo}` +
  expanded `httpapi` + `id`): typed schema-v0 config with atomic canonical writes /
  last-good-on-invalid / `quince config validate`; modernc SQLite (WAL) with embedded
  migrations (`settings`/`sessions_auth`/`audit`); argon2id auth with first-run
  set-password (one-shot **409** guard), session rotation, idle/absolute timeouts, per-IP
  login rate limit, and double-submit CSRF; a race-clean event bus (drop-on-slow) + the
  `/api/ws` handler (pre-upgrade auth + strict Origin, `hello` frame, ping keepalive); the
  full REST read surface (devices/jobs/versions/config) golden-tested against contracts §2;
  a security middleware chain (recover, CSP + frame denial, body limit, auth guard, CSRF
  guard); and a `--demo` provider scripting device churn + a backup with a
  silent-stall→recovery arc + every WS event type. **UI**: react-router auth-gated shell,
  a WS bridge feeding Zustand stores with reconnect-backoff + GET-refresh, vendored
  shadcn-style components on Radix, Dashboard / device-details / Settings pages on live
  demo data, and a shared humanizer. **Operator rulings this rung** (also in the spec's
  rung-ruled section + contracts §1): the auth endpoints (`/api/auth/status`, `/api/auth/setup`
  with the 409 guard, double-submit CSRF) and adopting `react-router-dom`. Rung-local calls:
  library set looked up live (yaml.v3 / modernc / coder-websocket / x/crypto / oklog-ulid;
  zustand / TanStack Query / Radix), embedded-SQL migration runner, Secure-cookie-off in
  demo (so http e2e/localhost login works), hardcoded admin-session timeouts (future
  `auth:` config noted for qn.6), slog JSON/TTY, config exchanged as structured JSON,
  golden fixtures via `make gen-golden`, and a two-container Playwright e2e target
  (`gates-ui-e2e`, CI `e2e` job) using the official Playwright image. Not yet committed
  (awaiting Operator). Next frontier: **qn.2**.
- 2026-07-19: (aq) **domain parsing goes to a standalone sibling library —
  `ios-backup-parser` — and the repo-naming policy is ruled.** Naming (Operator, after
  discussion): `quince-*` prefixes only app satellites (the private local layer today;
  helm/docs/demo someday); standalone libraries carry descriptive names — the
  `ios-backup-*` family (`-crypt`, now `-parser`). Rationale: the brand lives in the
  owner segment (a future org would follow the `immich-app` pattern — the bare `quince`
  account is taken), descriptive names win search discoverability, and Go module paths
  make renames expensive. Name picked from a vetted-unique shortlist
  (parser/records/content/data; `-artifacts` rejected on taste). The library: pure-Go,
  MIT, typed *streaming* records for messages/contacts/call-history/calendar/notes
  from already-decrypted backups; zero coupling to quince OR ios-backup-crypt (host
  supplies a `BackupFS` accessor); schema detection by introspection + per-backup
  capability reports (state honesty ported); license-hygiene rule — iLEAPP (MIT) is
  translatable with attribution and a differential oracle, imessage-exporter (GPL-3)
  is a black-box oracle ONLY (its typedstream/`attributedBody` ground is the known
  hard part); milestones: schema spike → contacts → calls → messages → calendar →
  notes → v0.1. Ecosystem verified live this day: no reusable Go artifact-parsing
  library exists. Quince side: qn.10's research spike is subsumed by the library's M0
  (off the critical path); qn.9/qn.10 consume the library iff the Go vault (D4/(ao)
  chain) landed at qn.8 AND the domain is covered — else in-vault adapters as specced.
  Roadmap M7 + design §7 updated; §7's adapter keying refined from "iOS major version"
  to "detected schema" (introspection, never a trusted version string). Photos remain
  parked. Charter seeded at the sibling repo (CLAUDE.md/README/LICENSE); separate
  implementer to be spun up by the Operator.
- 2026-07-19: (qn1-review) **qn.0/qn.1 post-build review + fixes.** A read-only conformance
  review (specs + frozen contracts §1–§6 + design §6) found **no blocker/major** — both rungs
  conform and the security baseline is sound — plus a tail of minors. Top items fixed this
  pass (full `make gates` + `make image` + `make gates-ui-e2e` re-green): (1) `GET
  /api/jobs/{id}/log` (frozen in contracts §1) was unrouted — now served `text/plain` via
  `JobReader.JobLog`, demo-backed by a per-job log ring buffer, and the UI recovers a running
  job's log tail on WS reconnect (the `job.log` stream isn't replayable — closes the story-2
  hole); (2) the demo now emits `device.updated` on backup success (refreshing `last_backup`),
  so every §3 WS event type fires end to end and the device card no longer goes stale; (3) a
  demo fixture set `last_backup.job_id` to a version id, not the job id (golden regenerated);
  (4) auth hardening — `verifyPassword` now rejects an empty-key hash (was fail-open via
  `ConstantTimeCompare` of two empty slices) and the login rate-limiter sweeps stale per-IP
  buckets so the map can't grow unbounded; tests cover all three. **Deferred (logged, not
  blocking):** WS session re-validation on logout/idle-expiry, DSN-scoped SQLite pragmas, a
  `.dockerignore`, and assorted nits. Frontier unchanged: **qn.2**.
- 2026-07-19: (qn2-build) **qn.2 code built.** The `internal/muxd` plist protocol client
  (`howett.net/plist v1.0.1`, Listen handshake, per-connection DeviceID→UDID map, reconnecting
  dialer) and the `internal/device` **registry** (N-muxer merge, per-transport/per-source
  presence keyed by UDID, **reset-on-(re)connect reconcile** clearing detached-while-away
  phantoms, `device.*` events), wired into non-demo `quince serve` as the live `DeviceReader`
  (default topology usbmuxd-USB + netmuxd-Wi-Fi; single-muxer flip is config-only). CI stories
  1–5 green under full `make gates`; lab gates 6–7 (plug/unplug ≤1 s + the netmuxd-USB
  audition) remain a hardware step. `muxd.Client.Run` now takes a `Sink{Reset,Apply}`;
  rung-ruled details in `specs/qn.2/qn.2.md`. The no-flicker snapshot-debounce reconcile
  (idle-debounce + `testing/synctest`) is the documented refinement if reconnect churn bites.
- 2026-07-20: (qn2-close) **qn.2 closed; muxer-startup gap surfaced + documented.** qn.2's
  deliverables (muxd client + `internal/device` registry + UI; `make gates`/image/e2e green) are
  complete; a post-build review + UI polish (empty-state copy, state-driven device card — disabled
  `Pair`/`Back up now` reflecting muxd-minimal presence) landed alongside. Its **lab gates 6–7 are
  deferred** to a future hardware session (they need a real device AND the muxer-startup gap
  resolved). During staging testing an architectural gap was surfaced — **nothing starts the
  in-container muxer, breaking D12 for USB** — and captured as **open question 2** (`PROPOSED
  (gap)`, for the Architect; not decided/built here). A staging stand was stood up on the PVE host
  (CT 113, `quince:staging` from the private registry, HTTPS via the CT-102 Caddy) for manual
  testing; its USB path uses a **temporary usbmuxd-in-CT + socket-bind workaround** (hotplug needs
  the `/root/redetect.sh` helper), rebuilt onto the house template's `/root/compose.yml` autostart
  convention (specifics in `local/environment.md`). Frontier → **qn.3**.
- 2026-07-20: (ar) **qn.2 cleanup package: muxer gap ruled, qn.2b inserted, qn.5↔qn.4
  swapped, worktree-init fixed** (Architect adjudication + Operator rulings). (1) Open
  question 2 RULED as option (a): quince supervises the in-container muxer — Go subprocess
  in its own process group under the serve context, restart-on-crash with capped backoff,
  killed on shutdown, **refuse-loudly if the socket is already served** (no silent
  adoption) — behind `devices.manage_muxer` (true = simple profile; false =
  hardened/external, making the staging socket-bind topology a supported mode), plus
  `POST /api/devices/rescan → 202|409` + UI Rescan reusing the reset/replay reconcile.
  Contracts §1/§6 and design §2 updated (the architect landed the contract-change ahead of
  the rung, per program rule). (2) **New rung `qn.2b`** (M1, before qn.3): MINIMAL
  supervision scope + rescan + **ownership of qn.2's deferred lab gates 6–7** (plug/unplug
  ≤1 s + the netmuxd-USB audition) — one physical-presence session; FULL muxer work stays
  qn.6/qn.7. Deferred-without-owner is how gates evaporate; qn.3's "fresh container via UI
  only" gate also depends on this. (3) **New hard rule: "a rung's goal is provable at rung
  close"** (program doc) — the Operator-requested self-containment audit of qn.3–qn.12
  found exactly one more violation: qn.4's `succeeded` needs qn.5's `Commit()` → **order
  swapped, qn.5 before qn.4** (qn.5 proven on fixture trees + a manually-produced
  `idevicebackup2` tree; qn.4 closes M3 with the true e2e gate); rung numbers stay
  (labels, not order — qn.7-before-qn.6 precedent). (4) **Worktree init**: worktrees
  materialize only tracked files, so sessions there lacked the private `local/` layer —
  mandatory first step now documented: `ln -s ../../../local local` (symlink sits on the
  gitignored path, uncommittable; privacy-check + environment.md pointers work unchanged).
  Also noted: qn.2's out-of-scope moment was handled correctly by the gap protocol (code
  scope held; design captured as PROPOSED, not built) — the process worked. Frontier →
  **qn.2b** (spec to be written by its session from the roadmap outline + the qn.2 spec
  appendix).
- 2026-07-20: (as) **plan-time discipline made structural** (Operator correction to the
  (ar) framing: qn.2's rule-adherence was largely Operator-ENFORCED — the implementer's
  proposed plan drifted from canon until manually pointed at the rules it was about to
  break; supervision-as-guardrail doesn't scale). Two program-doc changes: (1) the spec
  shape gains a mandatory **Rule check** section — every hard rule / canon boundary the
  rung touches or comes near, one compliance line each, written before building (a plan
  about to break a rule can't fill it truthfully, so violations surface as text); (2) the
  build loop gains a **pre-build spec review gate** — spec incl. Rule check → Operator
  routes it through the architect → explicit go, only then code (formalizes what
  happened ad hoc for qn.2's spec, which picked up five amendments in review).
  Repositions Operator supervision from hunting unflagged violations to adjudicating
  flagged edges. Applies from qn.2b onward.
- 2026-07-20: (at) **coverage made a declared artifact; handoff review gets named
  dimensions** (Operator-driven — third vigilance→structure conversion: the qn.2b
  handoff review found untested qn.2 cases only because the Operator explicitly
  prompted for coverage). (1) Rung reports now DECLARE coverage: the `go test -cover`
  summary + an explicit **known-untested list** (one line + reason each); declared =
  accepted debt, undeclared-found-later = a finding — state honesty applied to tests.
  (2) The rung handoff review runs four named dimensions: seams / coverage (verify the
  declaration, then hunt untested branches in consumed code) / state honesty /
  contracts. Process-budget note (Architect, Operator-acked): the program's gate set is
  now considered FULL — the next process addition should displace something, not
  append. The current coverage findings route through the existing triage: tests for
  consumed code land as `qn.2 review fix:` commits; the rest becomes declared debt or
  ledger entries.
- 2026-07-20: (au) **qn.2b BUILT (CI) — the in-container muxer has a lifecycle.** Cleared the
  new pre-build spec-review gate ((as)): spec + Rule check → **architect APPROVED with four
  amendments** (all folded in). Shipped: `internal/muxsup` supervisor (`exec.Command` usbmuxd
  `-f -S <socket>` in its own process group, restart-w/-backoff 500 ms→×2→30 s, SIGTERM→grace→
  SIGKILL on shutdown, **refuse-loudly** probe on an already-served socket, **crash-loop →
  `/api/health` degraded** with the last exit reason); `POST /api/devices/rescan → 202|409`
  reusing the muxd reconnect→`Reset()`→replay reconcile (no new device-table code), incl.
  rescan-as-recovery from degraded (takeover once the socket frees); the `devices.manage_muxer`
  config key (default true, first in `DevicesConfig`); `/api/health` `muxer:{managed,state,
  detail}`; and a UI **Rescan** control (202 in-progress / 409-explains, never a dead button).
  Wiring: managed → supervisor; external/`--demo` → `UnmanagedMuxer` (409). `make gates` +
  `make image` + `make gates-ui-e2e` green; **supervisor additionally smoke-tested against the
  REAL usbmuxd in the built image** — `/api/health` → `muxer:{managed:true,state:"running"}`,
  `usbmuxd v1.1.1_git20250201 starting up`. **Amendment 1 (verify interface facts, not just
  versions) paid off:** `usbmuxd --help` showed the daemon owns `-S/--socket` — so
  `devices.usbmuxd_socket` is authoritative via the daemon's flag, NOT the client-side
  `USBMUXD_SOCKET_ADDRESS` env the draft guessed. **Handoff review of qn.2** (four dimensions,
  (at)): gates green; `internal/device` 97.2%, but `internal/muxd` was **44%** — the entire
  `Client.Run` reconnect/backoff/dial loop and the `readPlist`/`listen` guards were untested,
  exactly the seam qn.2b's rescan consumes. Landed as a `qn.2 review fix` (`muxd/client_test.go`,
  real-socket reconnect-reconcile over unix+tcp + codec-guard cases) → muxd **85.7%**. **Coverage
  declaration ((at)):** `muxsup` 82.7%, `httpapi` 70.6%; known-untested = the SIGTERM-grace→SIGKILL
  escalation branch, the 30 s backoff-cap arithmetic, and the dial-timeout / ctx-cancel-mid-dial
  paths (timing plumbing, low-risk). **Lab gates 7–8 (plug/unplug ≤ 1 s, netmuxd-USB audition)
  remain the hardware session**, owned by this rung. `.gitignore` `local`-symlink hole surfaced
  via the qn.2b Rule check and landed on `main` (`a057783`) — rebased in. Frontier → **qn.3**
  (inherits "enrich muxd devices with lockdown identity").
- 2026-07-20: (av) **qn.2b lab finding — managed-muxer USB needs a LIVE `/dev/bus/usb`, not
  `devices:`** (surfaced testing Rescan on staging with a real iPhone; "Rescan didn't work"). Not a
  code defect — the supervisor + rescan behaved correctly. A static `devices:` mapping (runc
  `--device`) SNAPSHOTS the device-node list at container start, so a device plugged/re-enumerated
  later never appears in the container; usbmuxd restarted by Rescan then hits
  `LIBUSB_ERROR_NO_DEVICE` (`/sys` live, `/dev` node missing) — restarting the muxer can't surface
  it. Fix (deploy-only): bind `/dev/bus/usb` as a **volume** (live) + grant char-device access
  (`device_cgroup_rules: ['c 189:* rmw']` on Docker; `privileged: true` on nerdctl/podman/unpriv-LXC
  which lack device-cgroup-rules). Validated in a throwaway then deployed to staging — the
  in-container usbmuxd connected to the iPhone. `deploy/compose.nas.yml` corrected; captured in the
  qn.2b spec's Lab finding. The lab gate did its job: a real device found a deploy gap CI fakes
  can't. Rescan's "re-detect a missed device" value now correctly depends on a live container `/dev`.
- 2026-07-20: (aw) **qn.2b CLOSED; netmuxd-USB audition re-homed to qn.7** (Operator ruling). Lab
  gate 7 (managed in-container usbmuxd brings USB up via `compose up` + UI **Rescan** re-detects a
  re-plugged device) **PASSED on hardware** (Operator-confirmed on staging, after the (av) deploy
  fix). Lab gate 8 (the netmuxd-USB audition on v0.4.3) is **moved to qn.7** — it answers a
  netmuxd-viability question that pairs with qn.7's netmuxd co-supervision, qn.2b's goal doesn't
  depend on it (default topology stays usbmuxd-for-USB; the single-muxer flip is config-only either
  way), and it's the risky one (`idevicepair unpair` destroys the pairing record). **Re-assignment
  with a named owner, NOT a silent defer** — the audition procedure is preserved verbatim in the
  qn.2b spec (gate 8) for the qn.7 session to inherit, and the qn.7 roadmap row now lists it, so the
  no-orphan-gate rule qn.2b was created to enforce stays intact. qn.2b's goal (managed usbmuxd
  supervision + rescan) is proven end-to-end (CI + hardware); the rung closes. Frontier → **qn.3**.
- 2026-07-20: (ax) **P1 accepted → qn.6** (first proposal through the channel; Operator ruling,
  architect-recommended): the broken-container-USB onboarding/health check joins qn.6's §9
  guided checks (ledger + roadmap M5 updated). Post-landing architect review of qn.2b: clean —
  (aw) ratified; one docs-part-of-diff slip swept (stale audition references in stack D2 +
  roadmap M1/M4, fixed on main).
- 2026-07-20: (ay) **one project, one dev host** (Operator-ruled after an incident: a sibling
  library's gates ran on the shared dev container alongside an active quince rung — cache/
  container/memory contention got messy enough to force an emergency second box mid-rung).
  Program doc updated: sibling projects never share a dev container with quince or each other;
  per-project boxes under the same pure-container-host rules; registry + provisioning in the
  Operator-local env doc; idle boxes are stopped, not deleted. Knock-on fixes: the parser's M0
  study-data bind re-pointed from quince-dev to the parser's own (to-be-provisioned) box, and
  the sibling repos' `privacy-check` pattern lookup extended (`../quince-local/…`) so the
  commit gate stays armed on boxes that have no quince checkout next door.
- 2026-07-20: (az) **qn.3 BUILT (CI) — device ops + Devices page.** Cleared the pre-build
  spec-review gate: spec + Rule check → **architect APPROVED with three amendments + two
  rulings**, all folded in (Operator acks: hardware encryption coverage = `change_password` +
  a disable→enable cycle; keep the freshly-paired container standing). **Interface facts verified
  live** in the built image (libimobiledevice 1.4.0) — the STOP-gap cleared: `idevicebackup2`
  supports interactive `-i` (pty getpass) **and** `BACKUP_PASSWORD`/`_NEW` env; per the spec's
  pty-preference qn.3 uses the **pty** (password never in argv/env/log); `idevicepair pair` is
  **error-and-retry** (not blocking) so `waiting_for_user` is a poll-until-`SUCCESS` loop;
  `USBMUXD_SOCKET_ADDRESS` = `UNIX:<path>`/`host:port`; `ideviceinfo -x` keys + `-q
  com.apple.mobile.backup -k WillEncrypt`. Shipped: **`internal/deviceops`** (argv wrappers with
  the muxsup subprocess hygiene + a `GO_WANT_HELPER_PROCESS` fake-CLI harness; the pty-driven
  encryption path via `creack/pty v1.1.24`); **`device.Enrich`** (lockdown identity overlaid on
  the muxd-minimal shell, `device.updated` on change) + a bus-driven **enrichment driver**
  (attach → `ideviceinfo`/`idevicepair validate`, per-UDID debounced, off the request path);
  the **four frozen endpoints** (`POST …/pair` 202|404|409, `…/pair/validate`, `…/encryption`
  202|422, `GET /api/ops/{id}`) behind a consumer-defined `DeviceOps` interface; the **`Op`
  lifecycle** manager (running→waiting_for_user→succeeded|failed, `op.updated`); **audit** rows
  for pair/encryption (no secret; design §6 list updated — amendment 3); **pairing-record
  persistence** (whole-dir copy of `/var/lib/lockdown` ↔ `$QUINCE_DATA/lockdown`, amendment 1 —
  survives a container recreate); non-demo wiring + a demo `DeviceOps` scripting the op flow;
  and **UI** pair + encryption dialogs (assisted narration, unencrypted-banner CTA, USB-only 409
  explained, passwords never in URL/log). **`make gates` + `make image` + `make gates-ui-e2e`
  green** (added e2e **story 3**: encryption op narrates the assisted flow to success). **Story 5
  headline gate proven** — a test asserts the password is in no argv/env/log/audit and only
  reaches the child over the pty. **Coverage declared:** deviceops **80.2%**, device **97.6%**,
  httpapi **71.8%**; **known-untested** (accepted debt, all low-risk error/edge or trivial
  helpers): the enrichment-driver subscription-overflow `refreshAll` recovery, the ctx-cancel
  process-group SIGKILL branch, the ops-map `pruneLocked` eviction (needs 200+ ops), the
  lockdown mkdir-error warn branches, and the trivial `SetLockdown`/`encStartMsg`/`encDoneMsg`
  defaults. **Lab gate 8 (fresh container → paired → encryption on real hardware) is the
  remaining physical-presence step** — owned by this rung, not deferred. Not yet committed
  (awaiting Operator).
- 2026-07-20: (ba) **qn.3 CLOSED — lab gate 8 PASSED on real hardware.** Deployed the qn.3
  build to the staging CT (managed usbmuxd, live `/dev/bus/usb`) and drove the gate with a real
  iPhone: **(1) pair** via the quince UI on a fresh container → `paired: yes`, with the record
  written to `$QUINCE_DATA/lockdown` (proves `Backup()` fired = a real pair op, not enrichment);
  **(2) persistence** (amendment 1) → `nerdctl compose down && up` → `lockdown: restored …
  count:2` → still `SUCCESS: Validated`, no re-Trust — **proven twice** (a second redeploy for
  the UI fix repeated it); **(3) encryption** → `change_password` then a full `disable → enable`
  cycle, all succeeding, ending encryption **ON** with an Operator-held password; **(4) secrets
  (story 5) on hardware** → the capture caught `idevicebackup2 -i -u <udid> {changepw,encryption
  off,encryption on}` — **no password in argv**, `BACKUP_PASSWORD` env count **0**, clean logs —
  the password reached the child only over the pty. **Four findings caught by the gate, all fixed
  + CI-validated + committed as `qn.3 lab finding:`** — the substantive one: **enrichment
  auto-paired a locked device** (`idevicepair validate` returns "passcode is set" for ANY locked
  device regardless of pairing — observed on a fresh host with no record — so mapping it to
  `paired: yes` + then doing the auto-pairing full `ideviceinfo` could silently trigger Trust;
  fixed → locked ⇒ `paired: "unknown"`, and the full/auto-pairing read runs only for a confirmed
  `validatePaired`, everything else uses the no-auto-pair simple read); plus three UI fixes (the
  dashboard card's stale disabled Pair now routes to the details flow; the encryption mode
  switcher reset after a completed op; a persistent "confirm on the device with its passcode"
  hint; mode frozen at open + dialog auto-closes on success so the title no longer mismatches the
  result). The lab gate did its job — a real device found a real code bug the CI fakes could not.
  The paired staging container is **kept standing** as the qn.4/qn.5 base (Operator ack).
  Frontier → **qn.5** (storage; qn.5-before-qn.4 per (ar)).
- 2026-07-20: (bb) **qn.3 post-landing architect review: clean; docs-drift swept.** All three
  amendments + both rulings verified in the landed code (pty-only secret path spot-checked;
  coverage declared with an honest debt list; lab findings committed as labeled fixes). Sweep
  (same class as qn.2b's): contracts §1 now records the implemented error codes
  (pair 404/409-USB-only, encryption 422) and the RESOLVED password channel (pty `-i` verified,
  env fallback deliberately unused — the stale "qn.3 verifies which" comment closed); design §3
  gains the locked-device rule (`paired: unknown` on locked; full lockdown read only after a
  confirmed validate — the accidental-auto-pair guard, since qn.4's preflight consults the same
  path). qn.3 worktree + branch removed post-landing.
- 2026-07-20: (bc) **canon fix found by the qn.5 spec review: structural verification branches
  on encryption.** Design §4's checklist ("`Manifest.db` opens read-only + record sample
  resolves") is impossible passwordless on ENCRYPTED backups — the product default — because
  since iOS 10.2 the manifest itself is encrypted; CI fixtures (unencrypted) would have passed
  while gate 11's real encrypted tree failed. Ruled: `Manifest.plist.IsEncrypted` selects the
  variant — encrypted: exists + non-trivial size + NOT-plaintext-SQLite-magic + blob-shard
  sanity, with record-sampling deferred to the content level (qn.8's unlock, which now owns it
  for encrypted versions); unencrypted: the full checklist. Design §4 amended; qn.5's spec
  folds the branch + an encrypted fixture variant (amendment A1).
- 2026-07-20: (bd) **qn.5 BUILT (CI) — the version store stands.** Cleared the pre-build
  spec-review gate: spec + Rule check → **architect APPROVED with three amendments (A1 encrypted
  `Verify` branch, A2 a `RepairWorkingCopy` story, A3 name `Prune`'s trigger) + five rulings**, all
  folded in. Shipped: **`internal/storage`** — the `Backend` interface with two genuinely
  different models (`zfs` snapshot-native via a validated exec/hook `zfsCLI`, dataset-destroy never
  issued; `reflink`/`hardlink`/`copy` namespace-versioned), the **auto-selection probe** (FICLONE
  independence / `link()`+inode on the real `/backups`; `copy` degraded mode surfaced), **journaled
  commit** with on-disk `quince-version.json` markers + an explicit per-device commit journal,
  **first-class startup reconciliation** (roll-forward matrix: kill at every phase → defined
  repair; adopt on-disk versions with no row = `job_id` null protected; row with no artifact →
  `missing`, never dropped; orphaned `work/` swept only after), structural **`Verify`** branching
  on `Manifest.plist.IsEncrypted` (A1), **`RepairWorkingCopy`**, and retention **`Prune`**
  (post-commit + explicit, no scheduler); **`internal/storage/clonetree`** (one FICLONE/hardlink/
  copy cloner; hardlink copies `MutatesInPlace` classes); a **`versions` table + registry** in
  `internal/store` (the real `VersionReader`); **`DELETE /api/versions/{id}` → 202|404|503** + a
  `VersionAdmin` consumer interface + audit + `version.created`/`version.deleted` events; non-demo
  wiring that **reconciles before serving**; a `--demo` delete path; and **`deploy/storage.md`**
  (the constrained `quince-zfs-helper` forced-command + the anchored rclone filter block).
  **`make gates` + `make image` + `make gates-ui-e2e` green.** `-cover` wired into `gates-go`
  (the "when first needed" moment). **Coverage declared:** storage **78.3%**, clonetree **71.4%**,
  store **80.1%**, httpapi **71.8%**; **known-untested** (accepted debt, all low-risk or
  environment-gated): the reflink/FICLONE leaf (`clonetree` reflink path + the zfs reflink-mirror
  branch) — proven for-real in lab gate 12, skipped-with-a-log in CI (tmpfs has no FICLONE); the
  zfs reflink-from-snapshot copy-fallback branch; a few reconcile/adopt error-log branches; the
  `zfsCLI` list/destroy not-found guards. **Build finding fixed:** `WriteMarker` now replaces
  (remove-then-write) rather than truncates, so a hardlink-seeded `work/` can't rewrite a committed
  version's marker. **Lab gate 12 (real zfs on the host + iMazing-opens + syncoid-mid-write + the
  destructive hardlink-safety matrix) is the remaining physical/host step** — owned by this rung,
  not deferred. Not yet committed (awaiting Operator). Frontier stays **qn.5** until gate 12; then
  → **qn.4a** (engine; qn.4 split into qn.4a/qn.4b per (be)).
- 2026-07-20: (be) **qn.4 split into qn.4a / qn.4b** (Operator-ruled after a plan-shape review:
  the rung was three heterogeneous concerns wide — engine, Wi-Fi, CLI — unlike qn.5's
  one-subsystem depth). **qn.4a** = the transport-AGNOSTIC job engine + supervisor + the minimal
  headless CLI as the rung's own lab harness; CI replays ALL lab transcripts including the Wi-Fi
  torn sessions (the engine is Wi-Fi-shaped from day one); hardware gate = an encrypted USB
  backup driven from the CLI ending as a committed verified version + the engine kill matrix.
  **qn.4b** = Wi-Fi first-class + `transport: auto` + the intent-grouped job history API/UI +
  CLI completion (`versions verify`, `repair-working-copy` surface), closing M3 with the
  both-transports UI-driven gate incl. an injected Wi-Fi mid-backup disconnect landing honestly.
  **Explicitly NOT a Wi-Fi demotion** — ruling (h) stands: Wi-Fi keeps its own rung + hardware
  gate inside M3, before qn.7 and far before v0.1. The CLI was ruled NOT a separate milestone:
  standalone it is thin plumbing with no goal sentence, and splitting it would rob the engine
  rung of its driving interface (its bulk IS the engine working). Roadmap M3 + dashboard
  restructured; numbers stay labels (qn.2b precedent). The updated frontier chain: qn.5 gate 12
  → qn.4a → qn.4b.
- 2026-07-20: (bf) **gate-12 gap RULED: the zfs mirror probes for MEASURED sharing, not FICLONE
  success.** The gate's Operator-run core PASSED on real ZFS 2.4.3 (throwaway child dataset;
  create → snapshot → mirror → registry → `RepairWorkingCopy`, twice; **A1's encrypted `Verify`
  proven on the real ~34G encrypted tree** — committed without opening `Manifest.db`, exactly
  the CI-blind bug the amendment predicted) and surfaced two definitive findings: (1)
  reflink-from-snapshot = `EXDEV` (interface fact 2 answered; the designed clone-from-`working/`
  fallback stands); (2) **FICLONE succeeds WITHOUT sharing blocks on the real pool**
  (`block_cloning` active, `zfs_bclone_enabled=1`; verified three independent ways) — the
  "zero extra space" reflink premise is false there. Ruling: option (c) sharpened — the mirror
  strategy chain stays reflink → hardlink → copy, but the probe measures real physical-usage
  sharing; ineffective reflink is demoted, the hardlink strategy is the space candidate GATED
  on the 12c destructive matrix, and copy is the always-correct floor with its cost SURFACED
  (no silent fallback). Option (b) — offsite sync from `.zfs` paths — REJECTED: `snapdir=hidden`
  hides them from rclone, `snapdir=visible` uploads every snapshot at full size; D5a stands.
  Option (d) — root cause — demoted to a non-blocking side quest; first check: `zfs get
  encryption` on the pool datasets (BRT + native encryption has documented no-share
  restrictions — this may be known behavior, not a 2.4.x bug), then an upstream issue if it
  reproduces on an unencrypted dataset. Stack D5 amended.
- 2026-07-20: (bg) **the (bf) no-share verdict is PROVISIONAL — Operator challenged it, and
  there is a specific accounting trap that could fully explain the evidence.** ZFS charges
  BRT-cloned blocks like dedup: full size per reference at dataset level (`zfs list used`,
  `du`); the savings are visible ONLY at pool level (`zpool get
  bcloneused,bclonesaved,bcloneratio` / pool ALLOC delta). All three gate-12 measurements are
  consistent with WORKING clones misread through dataset accounting. Discriminator protocol
  (host-side, zero container layers, ~10 min): on the PVE host — `zfs create` a throwaway,
  `dd` a test file, `zpool sync`, note `bclonesaved` + pool ALLOC, GNU `cp --reflink=always`,
  `zpool sync`, re-read both. `bclonesaved` grows ~file-size → cloning WORKS, reflink
  reinstated, (bf)'s demotion reverses (the probe still moves to pool-level measurement —
  that part of the ruling stands regardless). Flat → the no-share finding is real; then `zfs
  get encryption` (BRT × native-encryption restriction) before any upstream filing. Also
  eliminate stack layers while at it: the original harness ran through container/bind paths —
  the re-measure runs on the host with GNU cp; note `zfs_bclone_wait_dirty=0` makes clones of
  UNSYNCED data fail (a Go fallback chain could silently copy) — hence the `zpool sync`
  before cloning. The EXDEV-from-snapshot finding is unaffected (cross-superblock FICLONE is
  kernel behavior no mount option changes; the clone-from-`working/` fallback stands). Remaining gate-12 legs: iMazing-opens
  (Operator GUI), syncoid mid-write (needs a replication target), the 12c matrix — with the
  iOS-upgrade leg marked OPPORTUNISTIC (runs at the next real update; a named trigger, not a
  blocker), the rest forceable now.
- 2026-07-20: (bh) **(bg)'s discriminator RUN by the Operator on the host — CLONING WORKS;
  reflink REINSTATED.** `bcloneused` 388M→788M (+400M = the test file), `bclonesaved`
  695M→1.07G, pool ALLOC flat at 391G; the baseline itself proves prior clones were already
  sharing on this pool. (bf)'s demotion reverses per (bg)'s pre-registered branch: the zfs
  `latest/` mirror keeps reflink (near-instant, zero extra pool space; the ~34G-per-commit
  copy price evaporates). What stands from (bf): the EXDEV-from-snapshot finding + the
  clone-from-`working/` fallback (the operative path), and the probe measuring REAL sharing
  at the POOL level — rung-local pick for qn.5: the `avail`-delta method needs only the
  hook's existing `list` verb, or extend the helper with read-only `zpool get bclone*`.
  Dataset-level `used` is documented as the trap (BRT bills like dedup). Option (d) side
  quest CLOSED: root cause = accounting semantics, nothing is broken, no upstream issue.
  Chain of custody worth recording: the gap protocol caught canon-vs-reality, and Operator
  skepticism then caught evidence-vs-instrumentation — without (bg), a dataset-`used` probe
  would have silently demoted a working reflink on every pool, forever.
- 2026-07-20: (bi) **the Operator's layer ladder caught the THIRD layer: unprivileged userns
  blocks FICLONE (`EPERM`) — mirror strategy RULED as a ladder with a host-side hook verb.**
  The qn.5 session's mandated re-verification (OCI → LXC → host, exact production mount shape)
  established: host shares fully (+4.3G bcloneused/saved, ALLOC flat); unprivileged LXC and
  the OCI container inside it get `EPERM` — so in-container reflink is unavailable in the
  recommended secure topology, and the session's original practical outcome (mirror costs a
  copy) was RIGHT for the wrong reason, twice removed. Its confirmations were exemplary:
  recomputed dataset-`used` predictions match all three original readings (the accounting trap
  fully explains finding #2), EXDEV-from-snapshot reproduces at every layer. RULING (option 1
  + option 2 as fallback; 3 rejected on security posture — privileged topologies simply fall
  out of the ladder naturally; 4 stays rejected per (bf)): the mirror ladder = (i) hook
  present → new constrained **`mirror` verb** rebuilds `latest/` HOST-side where FICLONE
  works (`cp -a --reflink=always` from `working/` under the job lock + atomic swap; children
  of the parent only; touches only the derived `latest/`, never snapshots — bounded blast
  radius since `latest/` is rebuildable); (ii) hookless → in-container reflink attempt with
  the pool-level probe; (iii) hardlink-under-matrix; (iv) copy, surfaced. Stack D5 amended;
  deploy/storage.md + the helper reference gain the verb (qn.5 folds); interface facts 1–2
  close with the full three-layer evidence. Investigation arc complete: canon-vs-reality →
  evidence-vs-instrumentation → layer-privilege; each round caught by a different mechanism
  (gap protocol / Operator skepticism / the Operator's layer ladder).
- 2026-07-20: (bj) **probe semantics refined (fourth Operator challenge: "how can a
  hookless container run a pool-level probe?"): the sharing measurement governs REPORTING,
  never selection.** A non-sharing FICLONE is functionally a copy (same correctness, same
  cost), so FICLONE-works suffices to select reflink — the EPERM case self-selects down the
  ladder; the measurement only decides the honest claim (zero-space verified / unverifiable
  in this topology / copy cost). Measurement channels, best-available: hook `list`
  avail-delta → delegated `zfs list -o avail` (exec mode) → syscall-only `statfs(2)`
  `f_bavail` delta around an incompressible test clone (no zfs binary needed; sync-and-settle
  for txg accounting lag) → none ⇒ report UNVERIFIED, never claim zero-space. Stack D5
  amended. This closes the reflink investigation: selection is now trivially safe, and
  honesty degrades gracefully with the deployment's observability.
- 2026-07-20: (bk) **(bj) corrected on the fifth Operator challenge ("hardlink seems
  better"): the measurement DOES inform selection — in exactly one direction.** (bj)'s
  "never worse than the fallback" compared only against copy and forgot hardlink sits above
  it. Corrected rule: the ladder orders by RISK dominance (reflink clones are independent;
  hardlinks alias — in-place mutation of `working/` would silently corrupt a hardlinked
  `latest/`, which is why hardlink is matrix-gated and why reflink outranks it wherever both
  share); the one selection edge is **measured-not-sharing reflink → fall through to
  hardlink-under-matrix** (downgrade-for-space allowed; blind upgrade into aliasing risk
  never). Channel-less deployments still prefer reflink on the risk asymmetry: worst case =
  copy COST reported "unverified" vs hardlink's worst case = silent latest/ corruption.
  Stack D5 amended. Investigation tally: five Operator challenges, five outcome changes.
- 2026-07-20: (bl) **qn.5 folds the mirror-ladder ruling into code + docs.** Implemented the
  stack D5 (bi)/(bj)/(bk) ladder in `internal/storage`: the zfs `latest/` mirror now ALWAYS
  clones from `working/` (never `.zfs` — EXDEV every layer), via **(i) hook `mirror` verb
  (host-side reflink + atomic swap, touches only the derived `latest/`, reports SHARED/COPIED)
  → (ii) in-container reflink → (iii) hardlink-under-matrix → (iv) copy**, self-selecting by
  risk dominance; an in-container reflink reports **UNVERIFIED** (no channel yet — statfs
  `f_bavail` is a documented follow-up) and never takes the risky measured-not-sharing→hardlink
  downgrade absent a channel; every mode + honest claim is surfaced (`MirrorReport` / logs /
  `LastMirror()` for health). `deploy/storage.md` + the `quince-zfs-helper` reference gain the
  `mirror` verb. Interface facts 1–2 closed with the three-layer evidence (block cloning works
  at the POOL level but EPERMs in the unprivileged userns; FICLONE-from-snapshot is EXDEV).
  `make gates-go` green (0 lint, race-clean; storage 78.7%); CI proves the fallthrough + the
  hook-verb argv (fake hook), the reflink-shares + host-side-hook paths prove on the lab (gate
  12). **Still uncommitted pending the Operator's ask** (the two CI-half commits stand). Remaining
  gate-12 legs (Operator-driven): the host-side `mirror` verb on the real rpool, iMazing-opens,
  syncoid mid-write, and the 12c destructive matrix (which validates the hardlink tier).
- 2026-07-20: (bm) **qn.5 CLOSED (CI-proven); lab gate 12's remaining hardware legs RE-HOMED to
  qn.4a** (Operator ruling — session cut off after the five-round mirror investigation). Landed on
  `main` in four commits: `285c40b` (storage backends + reconciliation) + `9a4511b` (docs (bd)/(be))
  + `7e34034` (mirror ladder + lab harness) + `3ce5bb1` (docs (bf)→(bl)). **Proven at close:** the
  whole storage subsystem in CI (11 stories + the reconciliation kill-matrix + the D5a anchored-
  filter contract; `make gates`/image/e2e green; coverage storage 78.7% / clonetree 71.4% / store
  80.1% / httpapi 71.8%), plus the real-zfs commit + encrypted `Verify` + the reflink/EPERM/EXDEV
  facts exercised on hardware during the gate-12 investigation ((bf)→(bk)). **NOT proven on
  hardware (re-homed, NOT silently dropped — the qn.2b→qn.7 no-orphan-gate precedent):** the
  host-side `mirror` verb on the real rpool, iMazing-opens, syncoid mid-write, and the 12c
  destructive hardlink-safety matrix. **Owner = qn.4a**, whose first real-backup hardware session
  runs qn.5's storage `Commit` on real traffic (the natural home); the legs are preserved verbatim
  in the qn.5 spec's gate-12 section. Interim note: the `hardlink` mirror/backend tier is
  matrix-unproven until 12c runs (the Operator's rpool uses the reflink hook path, so it isn't hit
  there); the pushed staging image is pre-mirror-ladder and needs a re-push before the qn.4a
  hardware session. Frontier → **qn.4a**.
- 2026-07-20: (bn) **gate-12 legs REDISTRIBUTED by affinity (Operator-ruled, amending (bm)'s
  all-to-qn.4a; a separate qn.4c was considered and rejected as a hollow-goal rung):**
  iMazing-opens + syncoid-mid-write + the live `mirror`-verb proof (`bclonesaved` observed
  moving) → **qn.4a's existing gate** — they are measurements taken during the backup that gate
  already produces, zero added sessions; the **12c destructive hardlink-safety matrix →
  qn.4b's gate** — its transitions (full→incremental, interrupted+next, encryption change;
  iOS-upgrade opportunistic) are engine products of qn.4b's repeated-backup session, where
  driving them costs nothing versus qn.4a's single-backup outing forcing manual rituals.
  Interim safety stands: the hardlink mirror/backend tier is disabled-to-copy (surfaced) until
  the matrix passes — the Operator's rpool runs the hook path and never hits it; ext4-NAS
  deployments get honest copy-mode meanwhile. Roadmap qn.4a/qn.4b gates updated.
- 2026-07-20: (bo) **`rpool/userdata` DECLASSIFIED (Operator ruling), closing the qn.4a-reported
  pattern hit.** The qn.4a build's privacy self-check surfaced that a pattern-list string sat in
  committed public files (a contracts §6 config example + two planning-era decisions-log entries)
  — missed by the (ad) scrub and invisible to the commit-time gate, which greps staged DIFFS
  only. Ruled: the dataset path is acceptable-public (default-pool naming, already implied by the
  public offsite-model narrative); the pattern is removed from the private list; docs and history
  stand; no incident. Standing lesson kept: the gate cannot see pre-existing lines — a
  whole-tree `privacy-scan-all` target remains available as a future hardening if a genuinely
  sensitive pattern is ever added. Bare hostnames/IPs/MACs remain firmly private.
- 2026-07-20: (bt) **qn.4a BUILT (CI) — the backup engine drives idevicebackup2 end-to-end.**
  *(Letter fix 2026-07-20: this entry was originally mislabeled (bp), colliding with the qn.4b
  spec-approval entry below. Every `(bp)` cross-reference in canon + code means that auto-absent
  ruling, so THIS build record was renumbered — to (bt), since (bs) was legitimately taken by the
  gate-15 hardware entry that landed meanwhile — rather than churn 20 references. Out of strict
  alpha order by design; a terminal build record.)*
  Cleared the pre-build spec-review gate: spec + Rule check → **architect APPROVED with three
  amendments (1 startup job-row reconciliation story + explicit two-reconciler order; 2 the
  `waiting_for_device` bound named `const`; 3 the sampler free-space / `disk_low` leg — the
  implementer's "A3", ACCEPTED) + two ratifications (the double-`Verify` stands; `transport:auto`
  stays deferred to qn.4b) + one correction (no rung numbers in the `auto` 422 API string)**, all
  folded in. Shipped: **`internal/backup`** — the `Job` state machine (per-UDID single-flight),
  the `idevicebackup2` streaming supervisor (argv/`setpgid`/group-kill), a transcript-grounded
  tolerant parser, the activity-sampler liveness (staged, passcode-paused, startup-grace, + A3
  free-space `disk_low` warning surfaced via `job.log`/`slog`, never a silent kill), preflight
  (presence + pairing + encryption policy + disk headroom + Seed), the Seed→`Verify`→`CommitJob`/
  `Discard` handoff, and **startup job-row reconciliation** (crash-orphans → `connection_lost`, a
  rolled-forward commit → `succeeded`, run AFTER storage reconciliation); a **`jobs` table +
  registry** in `internal/store` (real `JobReader`, cursor pagination); the **job command surface**
  (`POST /api/jobs` 202/409/422/404/503, `POST …/cancel`, `JobControl` consumer interface, `job.*`
  events) + contracts §1 error codes recorded; the **`quince backup` CLI** (`DriveToCompletion`)
  via a shared `cmd/quince` `buildLiveStack` (serve + CLI); and the **six lab transcripts** +
  meta + a fake-`idevicebackup2` replayer. `make gates`/image/e2e green. **Two RULINGS that drove
  the build (both rung-local, in the qn.4a spec):** (1) *the Wi-Fi torn session is a STALL, not an
  error line* — the lab's `Heartbeat(SleepyTime)` freezes output; the sampler's tree-activity
  timeout produces `connection_lost` (the discriminator vs a survivable silence is tree churn, not
  output); (2) *`idevicebackup2 backup <target>` writes into `<target>/<UDID>/`* while qn.5 expects
  the tree at the work dir — bridged by an engine-side **symlink adapter** (`<UDID>` → work dir),
  no qn.5 change, no tree copy, no committed-state mutation (verify-live on lab gate 15).
  **Coverage:** backup **83.2%**, store 80.8%, httpapi 72.2%, cmd/quince 11.0% (the CLI wiring is
  hardware-exercised); known-untested = the real-`idevicebackup2` argv/symlink-follow + `statfsFree`
  leaf (fake-covered in CI) + `buildLiveStack`/`backupCmd`. **Handoff review of qn.5: clean** (one
  minor — `CommitJob`'s verify-fail branch, now covered by story 6). **Lab gate 15 (real encrypted
  USB backup + kill-matrix + the re-homed gate-12 legs) owned by this rung** — the hardware
  session; NOT proven yet. **Landed on `main` (CI half); gate-15 findings land later as labeled
  commits** (Operator relaxed the usual land-after-hardware order for this rung). Frontier stays
  **qn.4a** until lab gate 15, then → **qn.4b**.
- 2026-07-20: (bp) **qn.4b spec APPROVED; the `auto`-when-absent edge RULED: refuse actionably.**
  Architect ratification of the spec's flagged proposal, encoded into design §4: `auto` resolves
  against current presence only; a device on neither transport → actionable 422, no job minted
  (a guessed transport would persist a dishonest `Job.transport` — the contract stores only
  concrete values; the frozen automation contract's `device_not_visible` no-go shows canon
  already thinks this way; and default-wifi-and-wait would contradict "prefers USB when
  plugged" the moment a cable appears). Explicit `usb`/`wifi` keeps start-then-connect. One
  spec amendment: design §4 DOES change (the absent clause was silent canon — now explicit;
  the spec's "nothing changes" docs line updates accordingly). Everything else approved as
  written, incl. the demo JobControl flip (its own qn.4a-named condition met), the CLI-only
  escape hatches, and the netmuxd started-not-supervised split (the qn.2→qn.2b precedent).
  The consolidated hardware day closes M3: qn.4a gate 15 (CLI USB + kill matrix +
  mirror/iMazing/syncoid) then qn.4b gate 11 (UI both-transports + honest Wi-Fi disconnect) +
  gate 12c (the destructive matrix) in one Operator session.
- 2026-07-20: (bq) **BUG (Operator-found, assigned to qn.4b): Dashboard DeviceCard "Pair"
  navigates without opening the pairing dialog.** Clicking Pair on a dashboard device card
  routes to `/devices/{udid}` (`ui/.../DeviceCard.tsx:88`, a bare `<Link>`) and stops there —
  the user must find + click Pair again. Root cause: qn.3 correctly moved pairing to the
  details page (USB-only, narrated Trust + passcode) but wired the card as a plain navigation,
  not an intent. Expected: clicking Pair *initiates* pairing. Fix (assigned to qn.4b — it is
  already rewiring this exact action row for the live "Back up now" affordance): deep-link the
  navigation with a pair intent (query param or router state) that the details page reads to
  **auto-open the pair dialog** on arrival — keeps qn.3's "narrated flow lives on details"
  decision, just makes the click deliver on its label. Same pattern applies to any future
  card action that lives as a dialog on details. Small; no contract change.
- 2026-07-20: (br) **qn.4b BUILT (CI) — Wi-Fi first-class + transport policy + job-history UI; M3's
  CI half closed.** Cleared the pre-build spec-review gate ((bp)): spec + Rule check → architect
  APPROVED, with the flagged `auto`-when-absent edge **ratified as canon** (refuse actionably, design
  §4). **Handoff review of qn.4a: CLEAN** (no blocker/major; `make gates` green on the inherited tip,
  the consumed seams re-run verbose; one minor coverage finding — the shipped-unexercised
  `wifi-incremental-success`/`encryption-changed` transcripts — **retired** here by a Wi-Fi-success
  story). Shipped: **transport `auto` resolution** in `backup.Engine` (`resolveTransport` — prefer
  USB when present else Wi-Fi, store the CONCRETE `usb`/`wifi` on the `Job` never `"auto"`, absent →
  actionable **422** with no job minted; explicit `usb`/`wifi` keep the start-then-connect wait) +
  httpapi passes `auto` through; the **`quince versions verify <id>|--udid`** + **`quince device
  repair-working-copy <udid>`** CLI escape hatches (design §4; CLI-only, no REST/contract) on a
  factored-out **`buildStorage`** (storage-only, no muxer/registry/engine goroutines) + a thin
  same-track **`storage.Manager.VerifyVersion`/`VerifyLatest`** (resolves the tree via the existing
  `browseRoot` — works for latest/archived/zfs-snapshot, **no new backend method**); the **live demo
  `JobControl`** (`StartBackup`/`CancelJob` scripting on-demand jobs through the real state names, a
  Run()-seeded stable spare device + a seeded failed job so the retry affordance is exercisable,
  per-UDID single-flight shared with the ambient loop) — **reversing qn.4a's demo-503** (its own
  named condition — an e2e that posts jobs — is now met); and the **UI** (live "Back up now" with a
  transport override when on both, one-tap **Retry** on failed intent groups carrying `retry_of`,
  **Cancel** on the running job; details page + dashboard card; assisted narration, honest disabled
  states, no fabricated progress). **Folded the (bq) DeviceCard bug fix** (Operator-found, assigned
  to this rung): the dashboard card's **Pair** now deep-links a pair *intent* (react-router state)
  that **auto-opens the pairing dialog** on the details page — the click delivers on its label, and
  qn.3's narrated-flow-on-details decision stands (no contract change; a Run()-seeded unpaired demo
  device + an e2e assertion prove card Pair → dialog visible). **`make gates` + `make image` +
  `make gates-ui-e2e` green**; new
  e2e **story 4** (Back up now → live cancel → retry a failed backup, all against `--demo`). CI Go
  stories: `auto`→concrete + both→USB, `auto`-absent→422-no-job, Wi-Fi success replay (retires the
  finding), retry-chain, cancel, demo single-flight/cancel/retry, `versions verify` good/torn/unknown.
  **Coverage:** backup **83.4%**, demo **55.3%** (was 0), storage **78.2%**, httpapi 72.2%,
  cmd/quince 8.5%; **known-untested** (accepted debt): the `cmd/quince` CLI command wiring
  (`versions`/`device` verbs + `buildStorage` — the storage/engine logic they call is tested; the
  verbs are hardware/integration-exercised), the demo `waitStep` shutdown-`stop` branch, and the
  storage reflink leaf (unchanged from qn.5). Contracts §1's `auto` note updated to "implemented"
  (docs-part-of-the-diff). **NOT proven on hardware — the consolidated hardware day (architect note,
  (bp)):** qn.4a gate 15 (CLI USB + kill-matrix + mirror/iMazing/syncoid) → **qn.4b gate 11**
  (UI-driven backup over **both** transports + an injected Wi-Fi mid-backup disconnect landing
  `connection_lost`) + **gate 12c** (the destructive hardlink-safety matrix), one Operator session;
  the Wi-Fi legs need netmuxd *running* (started for the session — the binary ships since qn.0;
  co-supervision stays qn.7). Frontier stays **qn.4b** until the hardware day; **M3 closes then.**
  **Landed on `main` (CI half)** per the qn.4a relaxed-order precedent; the lab gate 11/12c findings land later as labeled commits.
- 2026-07-20: (bs) **qn.4a LAB GATE 15 — the engine legs PASSED on real hardware (iPad15,7, iOS 26.5).**
  The CLI-USB + kill-matrix half of gate 15 (the UI-driven both-transports backup moved to qn.4b
  gate 11 per (br); the mirror/iMazing/syncoid zfs legs deferred, below). Driven on the qn.2b/qn.3
  staging CT (managed usbmuxd, live `/dev/bus/usb`, `hardlink` `/backups`); the qn.4a image
  re-pushed as `quince:staging` + redeployed. **Proven end-to-end, both encryption variants:** (1)
  an UNENCRYPTED `quince backup` → committed structure-verified version — qn.5's **unencrypted
  `Verify` branch ran on a real 102 MB plaintext `Manifest.db`** (opened read-only, tables + sampled
  records → blobs), which CI had only faked; (2) after enabling encryption via the pty CLI, an
  ENCRYPTED backup → **A1's encrypted `Verify` branch on real encrypted data** (`Manifest.db` header
  is NOT SQLite-magic + 256 blob shards, verified WITHOUT opening the DB), `encrypted:true`;
  **version rotation** proven (encrypted → `latest/`, unencrypted → `versions/<ts>/`). **Interface
  fact 1 CONFIRMED live** — the real `idevicebackup2` follows the `<target>/<UDID>` **symlink
  adapter** into the qn.5 work dir (2.8 GB landed through it). **Interface fact 5 CONFIRMED** — the
  `backup` child argv/env carries NO password; the device's keybag encrypts (the password set once
  over the `encryption on` pty stayed masked — never in argv/env/logs/context; secrets discipline
  held). **Kill-matrix (backing_up) PASSED:** a hard `SIGKILL` of quince mid-`backing_up` left the
  committed versions **untouched** (never-mutate invariant held under a real crash); on restart,
  reconciliation **swept the orphaned 3.1 GB work dir + flipped the job → `connection_lost`, no
  phantom version** (storage `Scan` → engine job-row, the two-reconciler order). `verifying` is
  equivalent (pre-commit); the `committing` **roll-forward** is CI-proven (story 13) and impractical
  to time on the sub-second hardlink commit — declared, not hardware-run.
  **DEFERRED (named, not dropped) — the zfs legs** (host `mirror` verb / `bclonesaved` moving /
  iMazing-opens / syncoid mid-write): they need the rpool **hook-mode** topology (a forced-command
  SSH credential + a CT mount reconfig with `rbind,rslave`) — disproportionate production-host setup
  for incremental value, since the core zfs facts (reflink/EPERM/EXDEV, `bclonesaved` sharing) are
  already hardware-proven on this exact rpool in gate-12 ((bf)→(bk)). Operator ruling: wind down +
  record; run the zfs legs in a later dedicated session. The **syncoid receive target is prepped**
  on the offsite PVE host (specifics in `local/environment.md`; reachable from the workstation + the
  lab host over the existing inter-host path — no new key needed). (Aside: that host currently runs
  its pools DEGRADED on a known-dropped NVMe — Operator-accepted, to be fixed in person.)
  **FOUR lab findings surfaced + filed as tasks** (invisible to the CI fakes — the gate did its
  job): (i) `deviceops.willEncrypt` maps an ABSENT `WillEncrypt` key (exit-0, empty — a device that
  never set a backup password) to `"unknown"` not `"off"`, so the Manage-encryption UI asks for a
  *current* password on an unencrypted device + the off-warning banner never shows; (ii) **[FIXED 2026-07-20]** `quince
  backup <udid> --transport usb` failed — Go's `flag` stopped at the positional udid, so `--transport`
  was dropped → usage error (CI called `StartBackup()` directly, bypassing arg parsing). Fixed:
  extracted a pure `parseBackupArgs` with a multi-parse loop that honours flags before OR after the
  positional; red→green `TestParseBackupArgs` in `cmd/quince` (coverage 8.5%→14.9%); (iii) the
  version card's `Unlock` button (`ui/src/features/versions/VersionList.tsx:31-33` — a `disabled` qn.8
  placeholder) renders on EVERY version incl. unencrypted ones, implying a password gate an
  unencrypted backup doesn't have; fix = encryption-aware on `version.encrypted` (already used for the
  `unencrypted` badge, contracts §2 / `ui/src/lib/types.ts`): encrypted → `Unlock` (password → browse),
  unencrypted → `Browse` (direct read, no password), per design §7 (unlock is encrypted-only) — inert
  today so UI-polish / qn.8-area, not a functional defect; (iv) the device card lingers on "Backing up 100%" through verify+commit and doesn't
  reflect `device.last_backup` (check the engine sets it on success). (iii)/(iv) may be subsumed by
  qn.4b's landed job-history/backup UI (br) — dedup at fix time. **(v) CONFIRMED + root-caused
  (2026-07-20 zfs session):** `device.last_backup` is populated **only in the `demo` provider**
  (`internal/demo/{script,jobcontrol,fixtures}.go` `refreshLastBackup`) — the REAL path (engine
  `Commit` success + `wire.Device` serialization from the live registry/store) never writes it, so a
  paired device with committed versions shows **"No backups yet"** on the card while the version list
  right below shows them (Operator screenshot: 5 versions — 3 `zfs incremental · structure verified`,
  2 `hardlink` — under a "No backups yet" card). This proves (iv)'s hypothesis; fix = the engine sets
  `device.last_backup {at,job,status}` on commit success (or the device DTO derives it from the latest
  committed version) — dedup with qn.4b's backup UI (br). **(vi) GitHub Actions CI RED on `main` —
  root-caused + fixed (2026-07-20).** Only the `e2e` job failed (`gates`+`image` green), on bu+bv+a
  re-run: the two qn.4b **story4** Playwright tests time out waiting for the demo devices
  `spare-iphone` + `new-iphone` to appear. Root cause: `demo.deviceChurn` reset `p.order` to a
  hardcoded `[phone]`/`[phone,pad]` every 20 s, wiping the on-demand devices `seedOnDemandDevice`
  had appended at `Run()` — so story4 passed only if it ran inside the first 20 s (green at bq on a
  fast runner; reliably red once the runner scheduled story4 later). NOT a code regression (main
  unchanged since bq) — a latent demo bug CI timing finally exposed. **Fix:** churn toggles only the
  pad in `p.order` (new `removeUDID` helper), preserving phone + on-demand devices; stories 1–3 only
  assert phone/pad so they're unaffected. Verified by reading (no local Go toolchain) — CI confirms on
  the next push. **Observations (not bugs):** both
  runs came out `kind:incremental` — `idevicebackup2` did device-relative differentials, and the
  encryption change did NOT force a full backup on this iPad (unlike the lab-log iPhone) → a real
  product question (should the engine pass `--full` on the first backup / after an encryption
  change?); an unencrypted backup on an already-paired, unlocked device needed **no on-device
  passcode** (a D13 nuance — the "every backup" claim looks encryption/Trust-specific); startup
  reconciliation took **~7 s** (storage `Scan` walks `/backups`) — a scaling note for large stores.
  **qn.4a's engine goal — the M3 engine half — is hardware-proven.**
- 2026-07-20: (bu) **decisions-log letter hygiene (two collisions in one review — a process fix).**
  Concurrent appenders (architect + a hardware session + a build session) each guessed "next
  letter" and produced duplicate `(bp)` then `(bs)`. Rule going forward: **letters are cross-reference
  anchors, not sequence guarantees** — on a collision, the *unreferenced* side renumbers to the next
  free letter (grep `^- 2026-07-20: (b?)` first) and leaves a one-line breadcrumb; the *referenced*
  side never moves (churns canon + code). A build/close record out of strict alpha order is fine — a
  reader follows references, not the alphabet. (Fixes this session: (bp)-dup → the qn.4a build record
  became (bt); (bs) stayed the gate-15 entry that owns it.)
- 2026-07-20: (bv) **ownership resolved: qn.4a owns the deferred zfs-hook legs — and the plan
  ambiguity that caused the dispute is fixed.** Operator-flagged: qn.4a's session read the zfs work
  as "deferred to a later session, not mine," while the architect read gate 15(a) ("commit on the
  real zfs backend") as qn.4a-owned. **Both defensible — the plan conflated two things:** gate
  15(a) demanded a zfs-backend commit, but the session validly proved the engine on the `hardlink`
  backend and bundled everything zfs-specific into a deferred pile that enumerated only the
  mirror/iMazing/syncoid extras — never listing **engine→commit-on-zfs** itself, leaving it in a
  seam owned by no named rung ("a later dedicated session" ≠ a rung). **Ruling (Operator): qn.4a
  owns the whole zfs half** (it already holds the topology details — cheaper than re-teaching a
  fresh session); deferred ≠ reassigned, the rung finishes its own gate. **Ambiguity fixed:** the
  pending zfs half is now enumerated explicitly — **engine→commit on the real zfs-hook backend**
  (the implicit item) + host `mirror` verb + `bclonesaved` live + iMazing + syncoid — in the qn.4a
  spec status, the dashboard row, and here. Low risk (both halves independently hardware-proven —
  qn.5's lab harness committed a real 34 GB backup through the zfs backend, qn.4a proved the
  engine→backend handoff on hardlink; only their composition on zfs is unrun). Blocks nothing;
  runs when the Operator stands up the rpool hook topology (likely with qn.4b's gate 11/12c —
  one hook-topology setup serves both). Also fixed en route: the qn.4a dashboard row was stale
  ("Not committed") — reconciled to reflect the landed CI half + the hardware-proven engine legs.
- 2026-07-20: (bw) **qn.4a zfs half PROVEN on real hardware — the engine drives a committed,
  verified version on the real zfs-hook backend, end-to-end.** Stood up the deferred (bv) topology on
  the lab rpool: a throwaway parent dataset, a constrained `quince-zfs-helper` forced-command SSH key
  (create/snapshot/destroy/list/mirror; dataset-destroy + parent-escape both refused, verified), the
  per-device child dataset `rbind,rslave`-propagated host→LXC→container (a host-side `zfs create`
  appears live at `/backups/<udid>`), `storage.backend: zfs, mode: hook`. **The zfs legs (gate
  15(a)+(d), (bv) enumeration):** (a) **engine→commit on zfs** — `quince backup` drove
  `queued→…→succeeded` on the zfs backend; an ENCRYPTED backup (on-device keybag; Manifest carries
  `ManifestKey`+`BackupKeyBag`), the `verifying` state ran A1's Verify on the committed tree,
  `committing` cut the version snapshot `<ds>@quince-<versionID>` (~3.1 GB refer), `latest/`
  reflink-mirrored. (d) **host `mirror` verb + `bclonesaved` live** — the verb ran on the real rpool
  (`mode: hook-reflink`, "zero-space verified"); pool `bclonesaved` moved **+~3 GB** (measured `zpool
  get bclonesaved`, the pool-level way — [[zfs-reflink-clone-facts]], never dataset `used`). (d)
  **syncoid mid-write** — while a second backup was actively writing `working/`, a syncoid pass
  replicated the child dataset to the offsite PVE host: both committed `@quince-*` restore points
  intact (refer matched, working+latest trees present) + a sync-snap captured the dirty in-flight
  `working/`. Offsite replication is safe during an active backup. (d) **iMazing-opens** stays an
  Operator-GUI leg — flagged, not agent-verifiable. **Deploy-doc bugs (surface only once hook mode is
  actually stood up — nobody had; all fixed in `deploy/storage.md`):** (1) the reference helper read
  `target="$2"`, but quince sends the dataset LAST (`create -p <ds>`, `list … -r <ds>`) → it REFUSED
  create+list; now last-arg. (2) the stock image ships no ssh client that `hook_cmd` needs; documented.
  (3) a host-created dataset is root-owned → the unprivileged-userns container can't write `working/`;
  the `create` verb now chowns to the container's mapped uid. Documented the two-hop (LXC + OCI)
  `rbind,rslave` propagation too. **willEncrypt finding strengthened (backlog (bs)-(i)):** `unknown`
  also arises from a COLD-lockdown enrichment race, not only an absent key → preflight hard-fails
  `encryption_required` with no retry even on a device that WILL encrypt; the storage legs set
  `require_encryption: false` (device still encrypts) to test storage, not re-litigate pairing.
  **qn.4a zfs half CLOSED — only iMazing-opens (Operator GUI) remains.** M3's engine goal is now
  hardware-proven on BOTH backends: hardlink engine legs (bs), zfs half (bw).
- 2026-07-20: (bx) **qn.4a close review (architect): clean + strong — two real bugs given a rung
  home.** Verified the (bw) close: zfs half genuinely proven (the (bv) engine→commit-on-zfs seam
  discharged — mirror verb `bclonesaved` +~3 GB pool-level, syncoid mid-write), three deploy-doc
  hook bugs found+fixed on the first real hook-mode stand-up, letters unique, privacy clean, CI
  green on main (the (vi) e2e fix landed). The gap: two of the six lab findings are genuine v0.1-
  quality defects in landed code but were only task-chips with no rung owner — now **assigned to
  qn.4b** (its gate-11 real backup re-exercises both, and (v) already pointed there): **(i)** the
  `willEncrypt`→`unknown` mis-map on unencrypted devices (asks for a non-existent current password,
  no unencrypted-warning banner) + the cold-lockdown enrichment race that hard-fails a legitimate
  encrypted backup at preflight; **(v)** `device.last_backup` written only by the demo provider, so
  a device with real committed versions shows "No backups yet". Findings (iii)/(iv) stay UI-polish
  (subsumed by (v)/qn.4b's UI); (ii)/(vi) already fixed+landed. iMazing-opens rides the qn.4b
  hardware day (30-second Operator GUI check).
- 2026-07-20: (by) **DAILY-DRIVER TARGET set; qn.4b closed (CI); `qn.4c` inserted; netmuxd
  supervision pulled forward; gate 12c deferred past a planned code freeze** (Operator ruling).
  The Operator is heading for a **code freeze + process revamp**, but wants a *personally
  usable* quince first, defined as: **full backup cycle over BOTH transports + live progress
  without a page refresh + the major bugs fixed.** Mapping that to work exposed one unassigned
  piece — **netmuxd co-supervision**. It is genuinely required for *usable* (not merely for the
  proof): nothing starts netmuxd on `compose up`, so Wi-Fi is silently dead after every restart
  and unrecovered on any crash — precisely the qn.2b-for-usbmuxd situation. It is also a modest
  lift: `internal/muxsup` is hardware-proven and structurally generic, needing its hardcoded
  `usbmuxd -f -S <socket>` + **unix-socket** probe generalized to netmuxd's argv + **TCP** probe.
  **Ruled:** (1) **qn.4b CLOSED (CI half landed, complete)** — no session work remains; its
  **gate 11 re-homes to qn.4c** with a named owner (the qn.2b-gate-8→qn.7 pattern), which is
  *more correct*, not merely convenient: gate 11's Wi-Fi leg then runs on **supervised** netmuxd
  — the shape actually deployed — instead of a hand-started one proving a topology nobody runs.
  (2) **New rung `qn.4c`** = netmuxd co-supervision (moved out of qn.7) + qn.4a findings
  (i)/(iv)/(v) (re-pointed from qn.4b), inheriting gate 11. (3) **Gate 12c DEFERRED past the
  freeze** — the destructive hardlink matrix gates a backend the Operator does not run (zfs
  deployment); the hardlink tier stays disabled-to-copy and surfaced, which is already the safe
  interim ((bn)). (4) qn.7 keeps the patched-timeout build, restart-policy tuning, chaos suite,
  liveness thresholds, and the audition — all deferred past the freeze. **No handover session
  was needed for qn.4b:** its worktree was verified to hold ZERO uncommitted work and its branch
  was identical to `main` — the repo (spec + rung report + dashboard + log) *is* the handover,
  which is what the documentation discipline was for. Remaining path to the freeze point:
  **one fresh session (qn.4c) + one hardware day.**
- 2026-07-20: (bz) **qn.4c spec APPROVED; three architect rulings + the netmuxd socket hazard.**
  The spike's headline is a landmine caught by running the shipped binary (the "interface facts
  are looked up" rule earning its keep **again**): with its default `--socket-path`, **netmuxd
  DELETES a live usbmuxd's unix socket and binds its own** — reproduced in the built image
  (`Deleting old Unix socket`, usbmuxd still running with its inode gone = **silent USB
  blackout**). Naive supervision would have made enabling Wi-Fi kill USB. Ruled argv:
  `netmuxd --host <h> --port <p> --socket-path <private> --disable-usb`, with a **loud refusal**
  if that path collides with `devices.usbmuxd_socket`; the session's choice of a private socket
  over `--disable-unix` is **ratified** — the latter puts netmuxd in host mode where it depends
  on usbmuxd being alive, coupling Wi-Fi health to USB health, which is exactly backwards for
  two independent transports. **Rulings:** (1) **`last_backup.job_id` → NULLABLE: APPROVED**,
  landed in contracts §2 ahead of the rung (the qn.2b precedent). Deriving `last_backup` from
  the newest committed VERSION rather than job history is *more correct*: versions are the source
  of truth for "has this device been backed up", so it survives restarts and covers **adopted**
  versions (restored/replicated dataset — the case where "No backups yet" is most insulting),
  which honestly have no job. Semantic shift recorded: `last_backup` now means the last
  SUCCESSFUL backup; a failed last attempt lives in the job history, not here. (2) **One config
  flag: APPROVED** — D12 says config tidiness is a feature, and a second flag would serve a
  topology nobody has asked for while the mixed case still degrades *honestly* via refuse-loudly.
  If a real user ever needs it, one bool splits into two as a compatible migration
  (`manage_muxer: true` → both). (3) **Health shape: CLEAN BREAK recommended** — a `muxers`
  array (each entry naming its role/transport, managed state, and whether rescan applies)
  INSTEAD of keeping the singular `muxer` alongside it. Two overlapping representations rot
  (which is truth when they disagree?), and a top-level `muxer` is now *ambiguous* with two
  daemons; `/api/health` is not frozen and we are the only consumer, so this is the cheapest
  moment. Update any `local/` tooling that greps `.muxer.` in the same pass. **Affirmed:**
  rescan stays USB-only (restarting netmuxd would tear a live Wi-Fi backup — and rescan always
  existed for USB hotplug). **Flagged for the build:** verify finding (iv) is *genuinely*
  subsumed by (v) — if the card has no branch rendering the `verifying`/`committing` phases it
  will still read "Backing up 100%" after `last_backup` is fixed, which would be a small but
  real UI change contradicting "ui/ needs no changes".
- 2026-07-20: (ca) **mDNS-across-the-container-bridge named as an unproven dependency (qn.4c) —
  and it is the Wi-Fi twin of accepted proposal P1.** netmuxd discovers Wi-Fi devices ONLY by
  mDNS; both shipped compose examples run bridged with a published port, multicast does not
  cross that bridge, and **no gate has ever proven Wi-Fi device presence inside the container**.
  So supervising netmuxd may be **necessary but not sufficient** on the shipped deployment shape.
  The session named it rather than assuming it (host networking as the deploy answer, macvlan as
  the alternative) and gate 11(b) settles it on hardware in minutes — the right call. Two
  additions: (a) whatever the gate finds, the Wi-Fi networking requirement is a **first-class
  deployment constraint** in `deploy/`, not a footnote — and if host networking is the answer,
  its security tradeoff (shared network namespace vs. the hardened-profile story) is documented
  honestly; (b) "netmuxd running" ≠ "Wi-Fi works" — a netmuxd that runs while multicast never
  reaches it sees zero devices forever, which is **exactly the shape of accepted proposal P1**
  (a muxer that runs but cannot open devices → actionable onboarding/health warning). The Wi-Fi
  twin should land with P1 in qn.6, or at minimum be recorded beside it.
- 2026-07-21: (cb) **qn.4c BUILT (CI) — netmuxd is co-supervised, and the three "it looks broken"
  defects are gone.** The rung's CI half is complete; only the inherited hardware day (gate 11)
  remains. **Supervision:** `internal/muxsup` now describes any muxer daemon as a `Spec`
  (name/role/argv/probe-network/address/rescan-applies) and a `Group` runs the two-daemon topology;
  `cmd/quince`'s pure `plannedMuxers` resolves `devices.manage_muxer` + the two addresses into
  supervise/dial/refuse decisions (table-tested). The qn.2b guarantees — own process group,
  restart-with-capped-backoff, crash-loop → degraded, refuse-loudly on an already-served address,
  killed on shutdown — are now **parameterized over a unix-socket AND a TCP daemon**, so netmuxd
  inherits proof rather than just code. **The argv is load-bearing** ((bz)): `--host/--port` from
  `devices.netmuxd_addr`, a **private `--socket-path`** (netmuxd deletes and rebinds whatever socket
  it names — with the default that is the live usbmuxd's, i.e. a silent USB blackout), and
  `--disable-usb` (D2's USB anchor until qn.7's audition); a derived path colliding with
  `devices.usbmuxd_socket` makes quince **refuse to supervise netmuxd** loudly while still dialing
  it. **Health took the clean break**: `muxers:[{name,role,managed,state,detail,rescan}]` replaces
  the singular `muxer`; rescan stays **USB-only** (restarting netmuxd would tear a live Wi-Fi
  backup). **Findings:** (i)-A `willEncrypt` maps exit-0-with-empty-output to **`off`** (an absent
  key IS the device saying it will not encrypt; `unknown` now means a genuine read failure);
  (i)-B **preflight re-reads the encryption state live** (`deviceops.RefreshEncryption`, reusing
  qn.3's non-auto-pairing `Info`) whenever the cached value is not `on` — the cold-lockdown
  hard-fail is gone, a fresh `off` still refuses actionably, and a still-`unknown` refuses with the
  TRUE reason instead of implying the user disabled encryption (proceeding-on-unknown was
  considered and rejected: discovering it after writing GBs is worse); (v) **`last_backup` derives
  from the newest non-missing committed version** through an injected source read at merge time
  (no cache to go stale — right after a restart, right for adopted versions, right after a delete),
  plus `AnnounceBackup` on commit success for the live card update; (iv) **verified subsumed by
  running, not assumed** (the architect's build flag) — a new `DeviceCard` test drives
  backing_up(100%) → verifying → committing and shows the card already narrates each, so the only
  missing piece was the last-backup line. **Gates:** `make gates` + `make image` +
  `make gates-ui-e2e` green in quince-dev (e2e 6/6, incl. a new story: a dashboard-card backup runs
  to success and the card lands on its real last-backup line **with no reload**). **Image smoke
  test (the CI-side proof of the rung's promise):** `quince serve` in the image built this rung
  reports both daemons `running` with the exact ruled argv, **both sockets coexisting**, TCP 27015
  listening; a `kill -9` of the netmuxd child was **respawned by the supervisor** while usbmuxd
  kept its original pid and a live socket (`idevice_id -l` exit 0). Coverage: muxsup **86.9%**,
  device 97.8%, backup 83.8%, cmd/quince 20.9% (was 14.9), httpapi 72.0%, deviceops 80.3%.
  **Deploy ((ca) discharged in advance of the gate):** the Wi-Fi/mDNS requirement is a first-class
  header section in `compose.nas.yml` (host-networking answer, its honest isolation tradeoff, and
  macvlan as the isolation-preserving alternative); `compose.lab.yml` documents the host-run netmuxd
  equivalent incl. the `--socket-path` warning; **P1b** records the Wi-Fi twin of P1 in the
  proposals ledger for qn.6. **One pre-existing finding filed (out of scope, has a home):** a job's
  row goes terminal before its work is discarded and the single-flight slot released, so an instant
  Retry can hit a 409 that says "a backup is already running" — correct refusal, misleading words;
  the smallest fix is a distinct reason string. **Remaining: lab gate 11 (a)–(h), one Operator
  hardware day** — both transports UI-driven with live progress, Wi-Fi on SUPERVISED netmuxd
  surviving a container restart, honest mid-backup disconnect, the real last-backup line on a
  device with pre-existing versions, encryption honesty, secrets absence, iMazing-opens. It also
  settles whether the deployed bridged shape sees Wi-Fi devices at all, or needs host networking.
- 2026-07-21: (cc) **qn.4c close review (architect): approved — and the terminal/slot-release race
  gets a rung home.** The build discharged both review flags honestly: (iv) was *checked* rather
  than assumed (a `DeviceCard` test drives `backing_up(100%)→verifying→committing`; the card
  already narrates each, so `ui/` genuinely needed no component change — the session noted it
  would have claimed that wrongly without the check), and (ca) landed in the deploy docs ahead of
  the gate. Ruling 3 was taken as recommended (clean-break `muxers` array, no singular `muxer`;
  `local/environment.md`'s runbook line swept in the same pass). **The standout: the netmuxd
  takeover hazard is verified ABSENT in the shipped image** — both sockets coexisting, `kill -9`
  netmuxd respawning while usbmuxd keeps its pid and a live socket (`idevice_id -l` exit 0). That
  is proof, not design-around. **Pre-existing defect, NOT fixed here (correctly — out of scope),
  now OWNED:** a job's row goes terminal *before* its work is discarded and the per-UDID
  single-flight slot is released, so an instant one-tap **Retry can get 409 "a backup is already
  running"** — a correct refusal wearing misleading words, sitting exactly under qn.4b's Retry
  button (D13's core flow). It is a **state-honesty** bug (the truth is "the previous run is still
  cleaning up"), but narrow: the window is the `Discard`, which is near-nil on zfs (dirty
  `working/` is left in place) and only long on namespace backends removing a big work dir.
  **Ruled: NOT daily-driver-blocking** (intermittent and below the Operator's stated bar of
  constant visible wrongness) → **owner = qn.7** (hardening, post-freeze), **with a pull-forward
  trigger: if it bites during gate 11, fix it there as a labeled lab-finding commit** (the
  established pattern). The session's handling was exemplary — it surfaced the race by making a
  test flaky under load, then made the test *wait the window out with a comment naming the cause*
  rather than hiding it.
- 2026-07-21: (cd) **qn.4c GATE-11 LAB FINDING — the backup target stub must live on the storage
  filesystem; fixed as a lab-finding commit.** The first real full backup (iPhone, ~40 GB, USB via
  USB-over-IP) failed three times in ~30–60 s with zero bytes and `idevicebackup2 failed: exit
  status 151`, phase `waiting_for_passcode`, despite the passcode being entered every time — while
  the iPad's Wi-Fi incremental had just succeeded, so it read as "USB is broken". **Root cause,
  proven both directions on the device within minutes:** mobilebackup2 asks the HOST for its free
  space, and `idevicebackup2` answers with a `statfs` of **the target directory it was handed** —
  it does NOT follow the `<UDID>` symlink into the work dir. quince passed
  `$QUINCE_CACHE/backup-targets/<jobID>` (a 26 GB filesystem on staging), so the phone was told
  26 GB, needed ~40 GB, and refused with `ErrorCode 105: Insufficient free disk space
  (MBErrorDomain/105)` → **exit 151**. A raw run with the target on the storage filesystem (546 GB)
  went straight into `Receiving files`. The iPad passed only because an incremental's delta fits in
  26 GB. **Gate-blocking, in landed qn.4a code:** any device whose backup exceeds the cache
  filesystem could never be backed up — every real iPhone. **Fix:** the stub is derived from the
  work dir (`<dir of workDir>/.quince-targets/<jobID>`), quince-writable on every backend and
  always on the storage filesystem; `ToolConfig.TargetRoot` REMOVED (a knob whose wrong value
  silently breaks large backups should not exist). Note the engine's old `<backups>/…` default would
  ALSO have failed under the zfs hook profile — the parent dataset root is root-owned, only
  per-device children are chowned. **Second fix, same finding:** a failed job now reports the tool's
  own last error line (`backup failed: Insufficient free disk space…`) instead of the exit status —
  the bare code made three identical failures indistinguishable, and 151==105 is documented
  nowhere upstream. **Fixtures first (hard rule):** `disk-full-105.{txt,meta.json}` (scrubbed real
  capture) + `TestPrepareTargetLivesBesideTheWorkDir` + `TestFailedBackupReportsTheDeviceReason`.
  **Process note:** the Operator predicted this failure mode from the `/cache` path before the run
  ("I'm afraid there might be a faulty free-space probe inside ibackup2 because /cache is on
  rootfs") — the diagnosis was then run-anchored, not argued: a raw `idevicebackup2` into a
  throwaway scratch dir on each filesystem, which is the qn.2b raw-run guard doing its job.
  **Session backlog (filed, not blocking):** crash-orphaned stub dirs unswept by reconciliation;
  the passcode narration unreachable in practice (the phase is learned in the same breath as the
  failure); two `latest` badges until reload (client-side staleness, server verified correct).
- 2026-07-22: (ce) **qn.4c LAB GATE 11 — the DAILY-DRIVER bar is met on real hardware; 6 of 8 legs
  passed, 1 mislabelled, 1 declared unrunnable.** One Operator hardware day on the staging CT
  (managed profile, zfs hook backend, real iPhone 16 Pro + iPad). **PASSED:** **(b) Wi-Fi from the
  browser on SUPERVISED netmuxd** — `compose up` alone brought both muxers up; a pre-flight proved
  the only netmuxd on the box was the container's supervised child with the ruled argv (a
  hand-started leftover was found squatting on 27015 and retired first — refuse-loudly would
  otherwise have made the gate prove nothing, exactly the (by) concern). An encrypted incremental
  committed, then a device's **first-ever full backup — 33.3 GB — committed over the same path** at
  a measured **16–24 MiB/s**; Wi-Fi beat the Operator's USB path, which was VirtualHere USB-over-IP
  across the same Wi-Fi. **(a) USB from the browser** — a cabled incremental committed, with
  `transport: auto` **resolving to USB because the cable was plugged** (qn.4b policy, first hardware
  proof), no `-n`, the supervised usbmuxd socket, and the lab-finding target fix live in argv.
  **(c) survives a restart** (the redeploy: both daemons back unaided, device back on `wifi`,
  backup immediately after). **(e) real last-backup line** on a device with pre-existing versions.
  **(g) secrets** — `BACKUP_PASSWORD` count 0 and no password in argv, captured live on BOTH
  transports. **(h) iMazing-opens** — the committed `latest/` tree (the reflink mirror) shared over
  SMB opened natively in iMazing: device info, `Current Backup Encrypted: Yes`, and decrypted photo
  enumeration. **That also retires the last unverified leg of qn.4a's gate 15 ((bw)).** **CANCEL**
  passed too: `cancelled`, child reaped, stub cleaned, honest discard note naming the fallback
  version, no phantom, slot released. **Storage held throughout:** verify+commit of 33 GB took
  **36 s** (A1 is structural, the commit is a snapshot + block clone — neither scales with the
  tree); `bclonesaved` **46.5 → 80.1 GiB** across two consecutive commits, i.e. `latest/` genuinely
  reflinked, never copied; version rotation exact (one `is_latest` per device, always).
  **NOT TICKED — (d) mid-backup Wi-Fi disconnect: landed SAFELY but MISLABELLED.** Everything
  protective held (work discarded, `latest/` untouched, no phantom), but the job ended
  `failed`/`backup_failed` rather than `connection_lost`/`device_disconnected`, because taking the
  device off the LAN produced an immediate receive error (`Could not receive from mobilebackup2
  (-256)`, terminal in 2.5 min, `liveness: active` throughout) instead of a stall — the sampler
  never participated. **Interface fact 2 is INCOMPLETE, not wrong:** a Wi-Fi loss has two shapes
  (the lab's frozen `Heartbeat(SleepyTime)` stall, which quince handles correctly, and this clean
  error exit, which it mislabels). Filed with a fixture-first fix direction. **DECLARED UNRUNNABLE
  — (f)'s unencrypted half:** finding (i)-A needs a device that has NEVER had a backup password (no
  `WillEncrypt` key at all); both lab devices have had one, so disabling encryption yields a
  *present* `false` — the branch that already worked — while changing the Operator's real device
  state and producing a permanently-incomplete version. Declared CI-covered only (story 7 +
  `enc_never_set`), accepted debt with a stated reason; a factory-fresh device belongs to qn.6's
  onboarding gate anyway. **Live progress: PARTIAL** — the WS path updates card and details with no
  reload (confirmed repeatedly), but the percentage moves in jumps and the byte pair beside it is
  wrong, so the leg is recorded honestly rather than ticked clean. **SEVEN findings filed, all
  diagnosed, none blocking:** the gate-blocking target-filesystem bug (fixed in-session, (cd)); a
  Wi-Fi drop mislabelled `failed`; the dashboard card staying silent when the newest attempt failed
  (the most daily-driver-relevant UI gap — `last_backup` semantics are right, the card needs a
  companion affordance); 12 KB progress blobs that mangle the log pane AND make the parser read the
  oldest frame (measured: UI showed `1.6 KB / 2.9 GB` while the tool was at `2.5 GB/2.7 GB` of a
  different file); current-file bytes presented as overall; every version reading `incremental`
  because the device writes `IsFullBackup: false` even for a first 33 GB backup; two `latest` badges
  until reload (client-side staleness, server verified correct); crash-orphaned target stubs unswept.
  **Operational note for the deployment:** the host's `zfs-auto-snap` is snapshotting quince's
  datasets (mid-backup snapshots pinned 15.7 → 67.6 GB), which contradicts stack decision (b)
  ("quince relies only on snapshots it creates") and sits outside quince's retention model — the
  Operator will exclude the parent dataset. **M3's daily-driver goal is met:** both transports
  UI-driven, live updates without a refresh, real last-backup lines, and the major bugs fixed.
- 2026-07-22: (cf) **iMazing-opens PASSED — qn.4a's gate 15 is now FULLY hardware-proven.** The
  Operator opened a quince-committed backup in iMazing (Windows) and it parsed **completely**, not
  merely "opened": device info (`Current Backup Encrypted: Yes`, iPadOS 26.5.2, 2.93 GB, snapshot
  count 1) read from the `…\latest` mirror, the **19-app inventory** enumerated, and the **full
  23-domain File System tree** browsable (`CameraRollDomain`, `HomeDomain`, `KeychainDomain`,
  `MediaDomain`, …). The reference tool declaring a quince **encrypted** commit wholly intelligible
  is the strongest external validation the storage + engine path can get — it exercises qn.5's
  `latest/` mirror, the journaled commit, and A1's encrypted structure end-to-end from outside our
  own code. **qn.4a is now complete on every leg** (engine (bs) + zfs (bw) + iMazing (cf)).
  **Parity observation from the same screenshots (Operator):** iMazing also surfaces *Apps*, *File
  System*, *Profiles* and *Voice Memos*. Triaged — nothing is missing from the **product**: the
  **app list** is already planned in **qn.9**'s overview ("device summary, app list, sizes"), and
  **File System** browsing is **qn.8**'s vault (unlock → browse → download). *Profiles* (MDM/config
  profiles) is niche for a personal backup browser — not planned, no demand. **Voice Memos**,
  however, is a genuine gap in the *parser's* domain parity review (user-created audio + a
  recordings DB — unlike voicemail the Operator certainly has data, and unlike whatsapp it is not
  app-encrypted); recorded in the ios-backup-parser backlog without reopening its settled scope.
- 2026-07-22: (cg) **`PROPOSED (gap)`: the `latest` swap is NOT atomic — the D5a offsite promise is
  broken today. `qn.5b` inserted (Operator-found).** The Operator re-derived the requirement from
  first principles — *a `zfs snapshot` at ANY instant captures a solid `latest/`; the directory
  `idevicebackup2` writes into is rclone-excluded; changes to `latest/` are ATOMIC* — and asked the
  architect to check it rather than accept the prose. **Constraint 3 fails.** Both paths do
  `mv latest → latest.old; mv latest.new → latest` — the in-container Go path
  (`storage/zfs.go:203`) and the host-side hook `mirror` verb (`deploy/storage.md`) — **each
  commented "atomic swap," neither atomic.** Between the renames `latest/` **does not exist**, so
  (1) an `rclone sync` crossing the window sees it missing and **DELETES the remote B2 copy** (sync
  mirrors deletions — a wipe + 33 GB re-upload, not the "briefly mixes two valid versions" stack D5
  claimed), and (2) a `zfs snapshot` there captures a version with no `latest/`. Canon had *named*
  the window but **understated it**, and the fix it already gestured at (exchange-rename) was never
  built. **Architect correction owed:** the earlier claim that `working/` must persist "for
  incrementals" was **wrong** — MobileBackup2 increments from a reflink clone of `latest/` exactly
  as from a persistent directory; the "Seed is a no-op" elegance predates knowing block cloning was
  cheap, which gate 11 has since measured (`bclonesaved` +33.6 GiB). **So the Operator's proposal is
  adopted:** per-job `working/`, seeded as a clone at job start, so between backups the dataset holds
  **only `latest/`** and every snapshot structurally contains exactly one complete backup — the
  requirement satisfied by construction instead of by careful sequencing. **Preserved: resume** —
  on FAILURE the dirty `working/` is KEPT so a retry resumes (a 33 GB Wi-Fi backup dying at 90% must
  not restart); on success it *becomes* `latest/`. **Also folded in (Operator):** the
  `<target>/<UDID>` **symlink dance is dropped** — it exists only because `idevicebackup2` writes to
  `<target>/<UDID>/`, and it *caused* the gate-blocking free-space bug (28b97de) by putting the stub
  on the wrong filesystem; choosing the staging path so the tool's own convention lands correctly
  makes that bug class structurally impossible. **Post-failure UX** (Retry / Reset / possibly
  Retry-clean) is **delegated to the qn.5b implementer** — 2-vs-3 actions, landed as a **contract
  proposal reviewed here** (`Reset` is the landed `RepairWorkingCopy`, CLI-only today, so a UI
  surface is a REST addition). **Interface fact to verify live, never assumed: does ZFS implement
  `RENAME_EXCHANGE`** (a VFS flag); the symlink workaround stays forbidden (D5a). Privilege split
  favours us — only FICLONE needs the host, so the hook keeps the reflink and quince does the
  exchange in-container. Commit reorders to verify → exchange → snapshot, making the version
  `latest/` and `browse_root` point at the real latest backup. Bonus: D5's **two version models
  collapse toward one** (namespace backends already seed-from-latest and rotate).
  **Alternative considered + REJECTED (same day, recorded in the qn.5b roadmap entry so the
  implementer doesn't re-explore it):** an all-ZFS-primitives design — `zfs clone` the working
  area into its own dataset, back it up there, then `zfs send workdir@ready | zfs receive -F
  …/latest`. The clone half is genuinely clever (instant, zero-space, and it would sidestep the
  FICLONE-`EPERM` problem entirely, being a `zfs` command rather than a syscall) but loses on
  three counts: the seed is already cheap and measured, a clone **pins its origin snapshot**
  (retention entanglement), and making `working` a *dataset* is exactly what forces the fatal
  half. The `send | receive -F` publish step is a **full 33 GB copy** (no block sharing) and,
  because the destination is rolled back and applied progressively (typically unmounted for the
  operation), it turns a **microsecond** missing-`latest/` window into a **minutes-long** one —
  strictly worse than the bug being fixed. **Generalizable principle recorded:** the requirement
  is that a *filesystem path stay continuously valid for a walker*, and every dataset-level
  operation (send/receive/rename/promote) involves a **mount transition**, so none can satisfy
  it — only a directory-level atomic exchange can. send/receive remains exactly right for what
  it already does here: **replication** (syncoid offsite, proven at gate 11).
- 2026-07-22: (ch) **`qn.6a` inserted before the freeze — soak-ready UI. Sequence: qn.5b → qn.6a →
  freeze + revamp (app soaking).** The Operator broadened the goal from "usable for me" toward "a
  first alpha tester," and — decisively — gave the reason: **they want the app in real-world use on
  staging *while the process revamp runs*.** The architect had argued for freeze-first and
  **conceded**: that argument assumed the revamp and the soak compete for time, and they don't. The
  revamp is *process* work, so the codebase is idle throughout; a usable app converts that idle
  stretch into **soak time, which cannot be compressed or backfilled**. And **mobile is the
  precondition, not polish** — if you must be at a desktop, the daily use (hence the soak) never
  happens at all. **Three architect challenges, all accepted:** (1) **don't conflate "my soak" with
  "ready for a friend"** — the soak justifies mobile + offline devices + labels; it does NOT justify
  the DSM feasibility spike, storage onboarding, or gate **12c** (which un-defers the moment a
  non-zfs tester appears, since a Synology lands on btrfs/ext4 → reflink or the **currently
  disabled-to-copy hardlink tier**). Those wait for after the revamp. (2) **5b runs first** — it
  changes the `working/` lifecycle and Retry semantics, i.e. precisely the behaviour a soak
  observes; soaking on a model about to change wastes the findings. (3) **"offline devices" needs
  its shape pinned or it silently becomes the biggest item** — minimal form is a union of live muxd
  presence with UDIDs already in the versions registry, plus persisting the identity already
  fetched at enrichment, not a new subsystem. **Operator-specified offline-card behaviour:** same
  card shape with a **disabled "Back up now"** so layout stays aligned with online cards — the
  architect added the one constraint that it be **disabled *with a reason***, never a dead button
  (the qn.4b pattern and the (bq) lesson). **Forward note recorded, explicitly NOT scope:** a
  post-qn.12 **"Wake up"** spike — an offline device may just be *asleep on the same LAN*, and a Web
  Push to its PWA might rouse it so mDNS resumes and netmuxd rediscovers it. Fits the assisted model
  (quince cannot back up unattended but may *nudge*) and needs no new infrastructure beyond a push
  kind, but it is unproven that waking the screen restores Wi-Fi-sync visibility and it can only
  work on the same network — so it stays a spike with honest UI ("wake attempt sent"), never a
  success claim. **qn.6a is the LAST rung under the current process:** its implementer records
  process friction as it goes (letter collisions, doc drift, gate-ownership seams, spec overhead)
  and hands it to the revamp as evidence, so the process isn't redesigned from memory.
- 2026-07-22: (ci) **gate-11 findings — DURABLE disposition + rung distribution (bookkeeping).**
  The seven gate-11 findings were narrated in (ce) and filed as UI task chips, but **task chips do
  not survive an app restart** — so this entry is their durable home, each with a named owner, so
  none is orphaned (the no-orphan-finding discipline). The Operator's qn.5b/qn.6a insertion already
  absorbed several; this records the full map and flags the two that need an architect/Operator
  ruling rather than deciding them here.
  | # | Finding | Owner | Why |
  |---|---|---|---|
  | 1 | target stub on the cache filesystem → device refuses large backups | **FIXED** `28b97de` ((cd)) | gate-blocking; fixed in-session, fixture-first |
  | 2 | 409 "already running" on instant Retry (terminal-before-slot-release) | **qn.7** ((cc)) | state-honesty, narrow window; pull-forward trigger if it bites |
  | 3 | 12 KB progress-bar blobs mangle the log pane AND make the parser read the *oldest* frame (stale bytes) | **qn.6a** ((ch) row) | one `SplitFunc` clears pane + stale byte counter + log bloat; on the soak path |
  | 4 | crash-orphaned `/cache` target stubs unswept by reconciliation | **SUBSUMED by qn.5b** ((cg)) | qn.5b drops the `<target>/<UDID>` symlink dance entirely → the stub class ceases to exist; nothing to sweep. **Chip dismissed as superseded.** |
  | 5 | "Backup directory is /cache/…" job-log line reads as alarming | **SUBSUMED by qn.5b** ((cg)), residual clarity nit → **qn.6a** log work | no more `/cache` target: the path the tool reports becomes the real staging dir. Only the wording nit (if any) remains, and folds into qn.6a's log pass |
  | 6 | dashboard card stays silent when the newest attempt FAILED (shows only last *success*) | **qn.6a** *(PROPOSED — confirm)* | `last_backup` semantics are correct ((bz)); the card needs a "needs attention + Retry" companion line. Most daily-driver-relevant UI gap — a soak tester who can't see failures defeats the soak, so it fits qn.6a's soak-usability charter |
  | 7 | two "latest" badges until reload (client keeps the demoted version's flag) | **qn.6a** *(PROPOSED — timing)* | cheap client-side fix (mirror the server's single-latest invariant in the versions store). **But qn.5b reorders commit + reshapes the `version.*`/`latest` surface** — confirm whether the fix rides qn.5b (where that surface changes) or qn.6a (pure UI) |
  | 8 | a Wi-Fi drop mid-transfer lands `failed`, not `connection_lost` (interface fact 2 incomplete — a drop has TWO shapes: stall vs clean receive-error exit) | **qn.7** *(PROPOSED)* | it IS a Wi-Fi transport-loss classification + interface-fact-2 correction, squarely qn.7's chaos-suite/liveness domain; the parser now captures the tool's reason, so the classification hook already exists. Fixture-first (`wifi-dropoff-receive-error`) beside the existing stall fixture |
  | 9 | every version reads `incremental` — device writes `IsFullBackup:false` even for a first 33 GB backup | **NEEDS A RULING** (ties to open product question (bs)) | two halves: (a) derive `kind` honestly (`BackupState=="new"` / no prior version → `full`) — a small storage/`verify.go` fix; (b) whether to pass `idevicebackup2 --full` on a first backup / after an encryption change — a **product decision** ((bs)). (a) makes qn.5's full-only shard check actually run. Architect to assign a rung; not decided here |
  | 10 | progress percent freezes then jumps (driven only by sparse "NN% Finished") + current-file bytes shown as the *backup* total | **SPLIT: qn.6a** (byte labelling, rides #3's `SplitFunc`) **+ qn.7** (percent/liveness shaping) *(PROPOSED)* | the honest-byte relabel is soak-path UI; smoother percent-from-cumulative-bytes + the liveness note firing during active large-file receives is progress/liveness *shaping* = qn.7 |
  Net: **#1 fixed, #2/#8 → qn.7, #3/#5/#6/#7 → qn.6a, #4 obsolete (qn.5b), #9 unassigned pending a ruling, #10 split.** The four PROPOSED rows and #9 want an architect glance; the rest are settled. P1/P1b (the muxer-runs-but-blind onboarding/health warnings) remain qn.6 in the proposals ledger — distinct from these, not re-homed.
- 2026-07-22: (cj) **architect rulings on (ci)'s four PROPOSED rows + #9 (the audit itself: approved,
  and the #4/#5 "a redesign deletes the bug" subsumption is the model catch).** **#6 (failed newest
  attempt is invisible — card shows only last *success*) → qn.6a, and UPGRADED to CORE, not
  optional.** This is the direct consequence of the (bz) decision to make `last_backup` mean last
  *success*: correct, but it *created* the duty to surface a failed newest attempt elsewhere or
  failures go invisible — and **a soak whose failures are invisible is a worthless soak**, so it is
  load-bearing for qn.6a's charter. Shape: a "needs attention · Retry" companion line, not a
  mutation of `last_backup`. **#7 (two `latest` badges until reload) → qn.6a** (client-store fix:
  mirror the server's single-`is_latest`-per-device invariant when applying `version.*` events —
  pure UI). **qn.5b re-confirms the SERVER invariant still holds after its commit reorder**, but
  the client fix is UI and stays out of the storage rung. **#8 (Wi-Fi drop → `failed` not
  `connection_lost`) → qn.7 CONFIRMED** — it is transport-loss *classification* + the interface-fact-2
  correction (a drop has two shapes: the stall quince handles, and the clean receive-error exit it
  mislabels), squarely qn.7's chaos-suite/liveness domain, fixture-first beside the stall fixture.
  **Soak guard:** qn.6a's UI pass must present whatever terminal state honestly so a *bare* "failed"
  doesn't read as data loss during the soak — the outcome was SAFE (work discarded, `latest/`
  untouched); the label is what's wrong. **#10 SPLIT CONFIRMED** — honest byte-labelling (current-file
  bytes shown as the *backup* total is a lie) → qn.6a, riding #3's `SplitFunc`; percent-from-cumulative
  smoothing + the liveness note firing during a large-file receive → qn.7 (progress/liveness shaping).
  **#9 RULED (the substantive one): SPLIT.** **(a) honest `kind` (full vs incremental) → qn.5b** —
  don't heuristic it in `verify.go` off the unreliable `IsFullBackup` flag; under qn.5b's per-job
  `working/` model quince *authoritatively knows* full-vs-incremental, because it IS whether `working/`
  was seeded from an existing `latest/` (incremental) or started with none (a first/full backup). The
  honest signal falls out of the seed decision qn.5b already makes — more correct AND cheaper than a
  Status.plist heuristic; a genuine tightening, not scope creep. **(b) force `--full` after an
  encryption change → qn.7 (correctness/hardening), with a SOAK CAVEAT recorded now:** an incremental
  built on a prior version encrypted under a *different* keybag can be inconsistent, so during the soak
  either avoid changing the backup password, or **Reset** (the landed `RepairWorkingCopy`, surfaced by
  qn.5b) after an encryption change to force the next backup full. qn.7 automates the force; the interim
  mitigation already exists. That (b) is real correctness, not cosmetics, is why it is flagged rather
  than parked silently.
- 2026-07-22: (ck) **#9(a) REFRAMED by an Operator challenge ("does the `incremental` label bring
  any user value?") — it doesn't, and it mildly MISLEADS: drop it from the UI, keep it internal.**
  The `full`/`incremental` label describes the *transfer* (idevicebackup2 sent deltas), not the
  *result* — and **every quince version is a complete, independently-restorable backup** (a zfs
  snapshot is the whole tree; a namespace version is a complete dir). So "incremental" imports the
  fragile-chain mental model from Time Machine/Borg/restic/Veeam — "delete the full and it breaks"
  — which is FALSE here and undercuts D5's central guarantee that versions are independent, never a
  chain. Verified: displayed at `VersionList.tsx:24`, a frozen `Version.kind` (§2), and internally
  it gates the encrypted-verify shard check (assert "all 256 shards present" only on a full
  transfer, where absence is definitely a bug — on a small incremental it could false-fail). So it
  has real INTERNAL value and near-zero USER value. **Ruling:** (1) **qn.6a drops `kind` from the
  version card** — show what the user acts on instead: date, size, the **delta size** ("added 1.2
  GB" is genuinely useful, unlike "incremental"), encrypted, verified. (2) **`kind` stays internal +
  in the contract** (non-breaking; CLI/power-user/debug), derived honestly per #9(a)'s qn.5b home —
  which the verify shard-check still needs (a first backup mislabeled `incremental` today means the
  full-only check silently never runs, so a broken first backup could pass). The Operator's
  challenge thus flipped the user-facing half of #9(a) from "make the label accurate" to "stop
  showing a label that misleads," while preserving the internal-honesty half for verification
  correctness.
- 2026-07-22: (cl) **Post-freeze EPIC captured: storage as a first-class entity (multi-storage).**
  Operator direction, recorded so it lives in the docs not just their head; full write-up in the
  roadmap ("Post-freeze EPIC — Storage as a first-class entity"). **The core insight is correct and
  names a real modeling error:** a backend (`zfs`/`reflink`/…) is a property of a **storage**, not a
  backup — and today's per-version `Version.backend` (contracts §2) is the *symptom*. Target: storage
  as a first-class UI entity (created in onboarding Plex-style, on the dashboard with space/count
  stats), one immutable backend per storage selected at creation, a device backing up to multiple
  storages, **incremental scoped to (device, storage)** (so `latest/`/`working/` becomes per-storage
  and the first backup to a NEW storage is always full), and offline storages shown-not-errored.
  **Architect endorsed the direction and challenged six points** (all in the roadmap): storage
  identity must be a UUID written *into* the storage (not path-based, for the removable/offline case);
  the "pre-backup probe" reframed as a reachability/sanity health-check while backend *selection*
  stays at creation; **offsite/B2 is probably a REPLICATION of a storage, not a storage** (open fork);
  the iMazing case splits into **external-readonly** (browse foreign backups in place — a natural fit
  for the sibling libraries, which read *any* backup) vs **import/migration** (copy in); offline
  storage does NOT queue unattended backups (fights D13); and a storage `mode` (`managed` |
  `external-readonly`). **Near-term:** qn.5b's mechanics are storage-agnostic (only the path prefix
  changes), so it is safe to build now provided it doesn't hard-bake single-storage assumptions —
  paths storage-scopeable, `last_backup` derivation tolerant of going per-storage. **Not a rung — an
  epic, scoped into rungs post-freeze under the revamped process** (exactly the large, contract-
  touching, multi-surface work the revamp should improve).
- 2026-07-22: (cm) **Later idea banked: scoped per-device view + QR/link device enrollment.** Full
  note in the roadmap Later/parked. An admin issues a **scoped token** (view/backup/restore-later) so
  the *device owner* (not the admin) runs their own backups and browses their own data; onboarding via
  a link/QR from the admin's device page that auto-authorizes the opening device. **Well-motivated,
  not just convenience:** it is the delegated-access dimension qn.12's phone-first assisted model
  assumes away (admin ≠ phone owner in a household) → natural home is after/with qn.12. **Security
  notes banked now so a naive later build doesn't get it wrong:** the link carries a **one-time
  short-TTL enrollment secret that mints a device-bound session, NOT a bearer token in the URL**;
  **restore is a dangerous scope** (admin-only or re-auth even here); it is a real **auth subsystem**
  (capability tokens, per-device sessions, enrollment, revocation UI, audit) that reopens the qn.1
  security baseline. Later, not soon.
- 2026-07-22: (cn) **Spike banked: enable/disable Wi-Fi discoverability ("Wi-Fi sync") from inside
  quince** (Operator-raised; full note on the qn.7 roadmap entry). **Why it's bigger than it looks:**
  Wi-Fi is the PRIMARY transport (ruling (h)), but enabling Wi-Fi sync currently requires
  **Finder/iTunes** ("Show this device when on Wi-Fi") — so today's self-contained onboarding (D12
  "everything in quince") is **broken for the primary transport**: a fresh user pairs over USB in
  quince, then must reach for a Mac to turn Wi-Fi backups on. **Likely mechanism — to VERIFY, not
  assume (interface-facts rule):** a lockdown `SetValue` on `com.apple.mobile.wireless_lockdown`
  (`EnableWifiConnections`-ish), which libimobiledevice's `lockdownd_set_value` supports; it is a
  USB-trusted op, and since pairing is USB-only anyway (D2) the natural moment is *during the qn.3
  USB pair* — plug → Trust → pair **and** enable Wi-Fi sync → unplug → Wi-Fi works. Read-back yields a
  `wifi_sync: on|off|unknown` device property to show + toggle beside pairing/encryption. Spike
  answers: exact key, whether SetValue takes effect (reboot/respring?), USB-required, unlock/Trust
  needed. Home: qn.7 (Wi-Fi) or a small device-ops add folded into qn.6 onboarding; if infeasible,
  onboarding documents the Finder step honestly. Post-freeze.
- 2026-07-22: (co) **qn.5b spec APPROVED with amendments — two Operator-caught issues + the seven
  gate forks ruled.** The spec is strong (it found a THIRD non-atomic window — namespace
  `finishRotation`, missed by (cg) — and the non-idempotent-exchange marker guard is exactly the
  right first-class treatment). **Amendment A — "reflink seed" is loose prose hiding a real hazard
  (Operator-caught).** The seed-split *table* is correct (`clonetree.Clone` picks per-backend
  strategy, so hardlink seeds by hardlink) but the NARRATIVE (goal line 7, §unified-model line 169,
  decision 1) says "seeded as a reflink clone" universally. That is not just wording: **seeding the
  hardlink backend means `working/<udid>` shares inodes with `latest/`, so an in-place write by
  `idevicebackup2` corrupts the committed `latest/` through the alias — the exact class the deferred
  12c matrix governs.** The spec even says "must not rely on hardlink correctness it doesn't prove"
  (line 111) while doing precisely that. **Ruling:** the seed clone must use the SAME
  hardlink-safety discipline as qn.5's version promotion — i.e. the hardlink tier stays
  **disabled-to-copy** for the *seed* too until 12c proves it (a hardlink seed is only safe if every
  file `idevicebackup2` may mutate in place is copied-not-linked, which is 12c's whole matrix). So
  on the hardlink backend, **seed = copy (surfaced), not hardlink**, until 12c. reflink (independent
  clones) and copy are safe; hardlink is not, and the prose must say "clone via the backend's safe
  strategy," never "reflink," everywhere. Fix the narrative + gate the hardlink-seed path.
  **Amendment B — keep the ULID in the snapshot name; do NOT drop it (Operator floated dropping it).**
  The ULID *is* `versionID` (the marker/journal/`Version.id`/`browse_root` key) — embedding it is
  what maps a `zfs list` line back to its version/logs; and two same-minute backups (failed→retry, or
  rapid gate testing — the Operator's own `zfs list` shows three same-day snapshots) would collide on
  a date-only name and **fail `zfs snapshot`**. ULIDs are lexically time-sortable, so
  `quince-<date>-<ULID>` already sorts chronologically AND stays collision-free. If time-of-day
  readability is wanted, **widen the date to `YYYY-MM-DDTHH-MM`** and keep the ULID tail — never drop
  it. **Gate forks (§"decisions for the architect") ruled:** (1) full per-job model — YES; (2)
  exchange in-container with a host-hook fallback gated on the in-container `exch` probe — YES; (3)
  `mirror`→`seed` hook verb, deployed helper updated — YES (real one-time deploy cost, ship the
  migration note); (4) pre-qn.5b snapshots treated as disposable lab data, `Scan` skips gracefully —
  YES (pre-v0.1, throwaway; the perf-budget reasoning is sound); (5) 2-action Retry/Reset — YES; (6)
  `storage.zfs.mirror`→`seed` config rename — YES (no alias, pre-freeze single-user); (7) unify
  `Discard` to keep-dirty-working on all backends incl. cancel — YES (the namespace-deletes-work
  asymmetry is the (cj) #4/#5 bug). **The Reset contract proposal** (`POST /api/devices/{udid}/
  reset-working` → 202|404|409) is **accepted** — clean, audited, never touches committed state; land
  it in contracts §1 during build (the qn.2b/qn.3 pattern). Build on the ruling.
- 2026-07-24: (cp) **qn.5b BUILT (CI-proven) — atomic `latest` + the `working/` lifecycle redesign
  landed per the (co) ruling + both amendments.** `make gates` (go + vault + ui) + `make image` green
  in `quince-dev`; coverage backup **85.2%** / storage **78.9%** / httpapi **73.2%** / demo 54.9% /
  cmd 20.7%. **What landed:** (1) an `exchange(a,b)` primitive over `unix.Renameat2(…, RENAME_EXCHANGE)`
  (`exchange_linux.go` + a `!linux` stub for macOS tooling) — and its **primitive test doubles as the
  in-CI proof that the test filesystem supports RENAME_EXCHANGE** (the "test the layer you run in"
  lesson; it passes on the container tmpfs). (2) A **unified per-job lifecycle** across all four
  backends: `WorkDir` returns the idevicebackup2 TARGET (the `working/` parent) after seeding
  `working/<udid>` from `latest/` (**safe strategy — hardlink→copy, amendment A**) or RESUMING a dirty
  one; commit does verify → **atomic exchange** working/<udid> ⇄ latest/ → snapshot (zfs) / archive to
  `versions/<prev>` (namespace); `Discard` KEEPS the dirty working on every terminal (unified — the
  (cj) #4/#5 namespace-deletes-work asymmetry is gone); `RepairWorkingCopy` is now **Reset** (discard).
  (3) The **`<target>/<UDID>` symlink dance is deleted** (`supervisor.go` lost `prepareTarget`) — the
  target is the storage `working/` parent, always on the storage fs, so **bug 28b97de is structurally
  impossible**; the free-space regression test was rewritten to assert that. (4) **browse_root** moves
  `…/working` → `…/latest`; **snapshot name** `quince-<YYYY-MM-DDTHH-MM>-<ULID>` (amendment B — ULID
  kept, minute-widened; `snapDateLayout`). (5) **Honest internal `kind`** from a `.quince-work.json`
  seed sentinel (`Verify(tree, kind)` no longer trusts `IsFullBackup`) — a first backup is now
  authoritatively `full`, so the encrypted blob-shard check actually runs (finding #9(a)); a stale
  engine assertion that expected `incremental` for a first Wi-Fi backup was flipped to `full` (the fix
  working). (6) **Reset**: `POST /api/devices/{udid}/reset-working` → 202|404|409|503 (engine-owned for
  single-flight) + `quince device reset-working` CLI + contracts §1. (7) Hook **`mirror`→`seed` verb**
  (host-side reflink clone latest→working/<udid> + chown; migration note in `deploy/storage.md`);
  config **`storage.zfs.mirror`→`seed`** (enum auto|reflink|copy — hardlink dropped); `MirrorReport`→
  `SeedReport`; offsite filter drops the obsolete `work/**` rule. **Gate proof:** the two independent
  observers are a CI concurrent-reader test (`latest/` marker is NEVER missing/torn across a running
  commit, both models — the exact failure the two-rename swap caused) + the marker-guarded kill-matrix
  (prepared/exchanged/archived|snapshot_created) + resume-without-re-transfer. **Docs are part of the
  diff:** stack D5/D5a (the `PROPOSED (gap)` flipped to RESOLVED; the commit-mirror block marked
  SUPERSEDED), design §4/§5 (layout, interface, commit phases, escape hatch), contracts §1/§2/§6, and
  `deploy/storage.md` all updated; the demo fixtures show the new model. **Owed to a hardware day
  (named, not silently deferred):** the real-rpool lab legs — **G-snapshot** (probe-snapshot loop
  during a running backup + at commit → always a complete `latest/`), **G-rclone** (continuous sync
  never deletes/tears the remote), **G-exchange-live** (the in-container `exch` probe on the deployed
  dataset — the go/no-go for the in-container exchange) — plus a syncoid mid-write pass, preserved
  verbatim in the qn.5b spec's Gates + the `//go:build lab` harness. **12c stays deferred** (hardlink
  disabled-to-copy, now including the seed). Frontier → **qn.6a**.
- 2026-07-24: (cq) **qn.5b post-build architect review: APPROVED + LANDED on main (`fc45ae7`,
  ff-only, pushed).** Verified in code, not the report: **both (co) amendments** (the seed ladder is
  reflink→copy-NEVER-hardlink with a surfaced warn — `seedreport.go` states the aliasing hazard;
  `snapNameFor` emits `quince-<YYYY-MM-DDTHH-MM>-<ULID>`); the **exchange primitive** is the named
  `unix.Renameat2(..., unix.RENAME_EXCHANGE)` symbols with the same-filesystem constraint documented
  at the definition; the **marker guard** for the non-idempotent exchange is present on both models;
  the **two-observer CI proof** exists (`atomic_test.go`: a concurrent reader loops on `latest/`'s
  marker across a full commit — always v1 or v2, never missing — the exact assertion the old
  two-rename swap fails); canon flipped (the stack `PROPOSED (gap)` → RESOLVED; contracts carry
  Reset + the new snapshot example); letters unique ((cp) build entry); whole-branch privacy sweep
  clean. The build's honest flags stand as recorded: **owed to a hardware day** — G-snapshot +
  G-rclone + **G-exchange-live** (the in-container `exch` probe on the deployed dataset = the
  go/no-go for keeping the exchange in-container; fallback = a hook `exchange` verb) + a syncoid
  mid-write regression, all on the real rpool with the **updated `seed`-verb helper deployed first**
  (the one real operational step). **Operator to-dos for that day:** re-install `quince-zfs-helper`
  from `deploy/storage.md` (the `mirror` verb is gone), and `zfs destroy` the pre-qn.5b test
  snapshots (their content sits at `…/working`; the new reader correctly reports them `missing` —
  decision 4's disposable-lab-data ruling, not a bug). qn.5b's hardware legs can ride the same
  session as qn.6a's soak start.
- 2026-07-24: (cr) **FINDING (Operator-caught on the staging UI, 2026-07-24): versions whose artifact
  is GONE are still listed as normal backups — `missing` is tracked everywhere except the one place
  the user looks.** Surfaced by the qn.5b snapshot migration: after destroying the pre-qn.5b
  snapshots, startup reconciliation correctly marked their 6 rows `missing` ("kept, not dropped" —
  roll-forward), yet the Devices page still renders them in *Recent backups* with full size +
  `structure verified`, visually identical to live versions. **Verified in code, and the mechanism is
  narrow: `store.VersionRow.Missing` exists and is honoured by `LastBackup` (skips), `recomputeLatest`
  (skips), `Delete` (skips the artifact op) and `VerifyVersion` (reports honestly) — but
  `wire.Version` has NO `missing` field at all (contracts §2), and `Manager.Versions()` maps every row
  through `toWire` unfiltered/unflagged.** So the drift is detected and recorded faithfully; it simply
  never crosses the wire. That is a **state-honesty violation** (hard rule: the UI never claims more
  than is proven) — quince currently asserts backups that do not exist, with sizes, and offers
  `Unlock` on them.
  **Operator's framing, and the refinement:** the Operator noted this is the DB-vs-disk mismatch they
  flagged from the start, having originally proposed "no DB, the data IS the source of truth."
  Recorded honestly: canon *did* adopt disk-as-source-of-truth (stack D3 / design §5 — "on startup
  the disk is the source of truth", first-class reconciliation, identity carried in on-disk
  `quince-version.json` markers); the DB is an INDEX over that, and it exists because the version-list
  read has a <100 ms perf budget a per-request fs/snapshot walk cannot meet. The index did its job
  here. So this is **not** the model being wrong — it is the *last mile* missing. Two distinct
  defects fall out, and they want different fixes:
  **(a) `missing` is invisible (the screenshot).** Fix = surface it: add `missing` to `wire.Version`
  (contracts §2 addition — needs an architect ruling) and have the UI either omit such versions or
  render them explicitly dead (no size claim, no `Unlock`, an actionable "artifact gone — remove?").
  Deleting the row already works for missing artifacts (`DELETE /api/versions/{id}`). **Proposed owner:
  qn.6a** — same family as its CORE finding #6 (invisible failures make a soak worthless, (cj)): a
  soak that displays phantom backups is equally worthless.
  **(b) reconciliation is STARTUP-ONLY** — the Operator's "regular sync job." An artifact vanishing
  while quince runs (exactly this case: snapshots destroyed under a live daemon) goes unnoticed until
  restart; here the redeploy masked it. Fix candidates: a periodic reconcile, or cheap
  revalidation-on-read for the listed set. **Deliberately NOT auto-assigned** — it interacts with the
  multi-storage epic (cl), where a storage can be legitimately OFFLINE (removable HDD unplugged):
  marking its versions `missing` would be exactly the wrong answer, so "unreachable" and "gone" must
  become distinguishable *before* a background sweep is allowed to mark anything. Architect to route;
  do not build a sweep that cannot tell those two apart.
- 2026-07-24: (cs) **HARDWARE FINDING + FIX (branch `claude/qn5b-seed-timeout-fix`): the 60 s ZFS
  metadata timeout was applied to the qn.5b `seed`, which is O(file count) — it SIGKILLed the real
  34 GB iPhone seed mid-clone and made the primary device un-backup-able.** First real qn.5b iPhone
  backup on the lab box failed at *exactly* 60 s with `seed work area: … zfs seed …: signal: killed`.
  Root cause: `zfsOpTimeout = 60s` was written for the metadata verbs (`snapshot`/`create`/`list`/
  `destroy`, all O(1)) and qn.5b reused it to bound the `seed` verb — which reflink-clones an ENTIRE
  backup tree. **Measured on the real pool:** an iOS backup is ~133 k files (256 blob shards); reflink
  is **per-FILE**, so cost is O(file count), NOT O(bytes) — ~7 600 files/s → 34 GB/133 k-file seed =
  **17.5 s clone alone, ~32 s warm / >60 s cold**; the 3 GB/94 k-file iPad seed = 5.3 s (which is why
  the iPad sailed through and the iPhone died). Reflink buys SPACE, not syscalls. **Fix (this branch,
  gates-green):** a distinct `zfsSeedTimeout = 30 min` (generous backstop only — the JOB context
  already cancels, the liveness sampler owns stall detection) via a new `seedCtx()`, leaving the 60 s
  bound for the metadata verbs; regression test `TestSeedUsesItsOwnGenerousTimeout` inspects the
  deadline the hook verb actually receives and fails if it is ≤ the metadata timeout (discriminates:
  the old code gives *exactly* 60 s). **Also (2):** dropped a redundant `chown -R` from the hook
  `seed` verb — `cp -a` already preserves `latest/`'s (container-uid) ownership, so only the mkdir'd
  parent needs chowning; re-timed on hardware **70 s → 22.9 s**, no file left mis-owned. `deploy/
  storage.md` carries the sizing note (budget minutes for large devices). Extends memory
  [[zfs-reflink-clone-facts]] (mirror→seed; seed timing). Precedent for an in-session hardware fix:
  the qn.4a free-space bug (cd).
- 2026-07-24: (ct) **qn.5b HARDWARE-VALIDATED end-to-end on the real pool + real iPhone/iPad over
  Wi-Fi — every owed lab leg now proven.** Session on the lab box: the deployed hook was upgraded
  (`mirror`→`seed` verb) and the `seed` proven live (verdict `SHARED`, pool `bclonesaved` +3.07 GB on
  the 3 GB iPad tree). Legs: **G-exchange-live PASS** — the in-container `renameat2(RENAME_EXCHANGE)`
  works in the *deployed* nested-OCI/unprivileged-LXC shape, and a SAME-layer contrast showed FICLONE
  still `EPERM`s there → the (co) privilege split is now proven **empirically** (exchange in-container,
  seed host-side), no host-side fallback verb needed. **G-snapshot PASS** (775 probe-snapshots, 0 with
  a missing/torn `latest/`) — with the honest caveat that a ~0.1 Hz probe loop has little power to
  catch a microsecond window, so this proves real-pool integration, NOT atomicity (the atomicity proof
  stays the exchange primitive + the CI concurrent-reader test). **G-rclone PASS** (continuous sync
  across commits; the remote `latest/` never deleted or torn). **Reset op PASS** (discarded a 34 GB
  orphan cleanly). **keep-dirty-working-on-FAILURE PASS** (a failed backup left a resumable 37 GB
  `working/`, `latest/` untouched, exactly one snapshot — no partial commit). **resume-without-re-seed
  PASS** (`"resuming dirty working (zfs)"`, no re-clone). **iPad 3 GB full cycle PASS** and — after the
  (cs) fix + moving the phone closer to the AP — **iPhone 34 GB full cycle PASS** (version
  01KY970TC…, honest `incremental` kind, clean `latest/`-only baseline). Both devices proven.
  **Wi-Fi failure root-cause dive (owner = qn.7, NOT qn.5b, NOT netmuxd).** Early iPhone attempts
  failed `Could not receive from mobilebackup2 (-4/-256)` / netmuxd `Heartbeat(Timeout)`. A deep
  pcap + `ss -tinoe` + netmuxd-DEBUG dive (tcpdump via `nsenter` into the CT netns; `RUST_LOG=debug`
  via a compose env override — quince honours it, `muxsup` only injects `info` when unset) established:
  **(1)** real Wi-Fi packet loss + link drops (exponential-backoff retransmits into a silent phone);
  **(2)** netmuxd EXONERATED — no backpressure (0 real zero-window), nothing logged even at DEBUG, the
  phone stopped ACKing raw TCP *below* netmuxd; **(3)** NOT a message-size/64 KiB bug (failure timing
  varied). **Honest correction recorded (the implementer over-concluded a root cause TWICE under live
  pressure):** a multi-minute `app_limited` idle window — iOS doing its own local snapshot/file-prep,
  socket legitimately idle — was misread as a "deterministic deadlock at ~264 MB"; the backup actually
  SUCCEEDED. **Durable lesson for qn.7:** iOS Wi-Fi backups have long LEGITIMATE idle pauses, so
  quince's liveness thresholds must not panic on them, and the real fix is qn.7's planned patched
  libimobiledevice timeout (30 s → 15 min, upstream #1413) so a backup rides out BOTH the pause and a
  transient Wi-Fi flap. Two real-world captures preserved as qn.7 chaos-suite fixtures (a genuine
  Wi-Fi failure + a success-with-pause) — **local-only on the lab host; they contain LAN IPs and must
  NEVER enter git** (privacy gate). **Finding B (open, architect to route): a partial/killed seed
  leaves an orphaned `working/` that the next `WorkDir` silently RESUMES into** — because the seed
  sentinel (`.quince-work.json`) is written only AFTER a successful seed. Today it only bit us because
  the (cs) timeout SIGKILLed a seed mid-clone, but any crash mid-seed reproduces it, and the failure
  mode is a version that could pass structural verify while missing blobs. Proposed fix: write the
  sentinel BEFORE seeding with `seed_complete:false`, flip true on success; `WorkDir` refuses to
  resume anything not marked complete (re-seeds). Small, but a state-honesty/correctness fix.
- 2026-07-24: (cu) **DEGRADED UX regression (Operator-caught on hardware): qn.5b made the gap between
  tapping "Back up now" and the on-device passcode prompt MUCH longer — proportional to device size.**
  Cause is structural to qn.5b's per-job `working/`: **pre-qn.5b the zfs `Seed` was a no-op** (a
  persistent `working/` was already in place), so `idevicebackup2` launched within the same second and
  the phone prompted almost immediately. **Now `WorkDir` reflink-clones `latest/` → `working/<udid>`
  synchronously inside preflight, BEFORE `idevicebackup2` starts** — and that seed is ~23 s+ for the
  34 GB iPhone (O(files); (cs)). So the passcode prompt (which is triggered by idevicebackup2's device
  handshake) can't appear until the seed finishes → ~20+ s of dead air where the UI shows nothing
  happening. The *real* complaint is the dead air, not the raw latency. **Mitigation options for the
  architect (roughly cheapest → biggest):** **(1)** surface a distinct **"preparing / seeding" job
  phase** between `preflight` and `backing_up` (quince already models phases) so the UI shows
  "Preparing — cloning from your last backup…" with progress instead of a frozen button; fixes the
  PERCEPTION (the actual gripe) without touching latency — **natural fit for qn.6a's soak-UX charter,
  recommended first.** **(2)** overlap the device handshake with the seed so the passcode prompt fires
  immediately while the seed runs in the background — but idevicebackup2 does handshake+read in one
  process, so this needs either a lightweight pre-handshake or a lazily-seeding tool (more complex,
  transport-adjacent). **(3)** keep a **warm pre-seeded `working/`** between backups (or pre-seed
  proactively right after a commit / on the qn.12 opportunity signal) so "Back up now" finds it ready
  → instant start; cost is it **breaks "between backups the dataset holds only `latest/`"** (snapshot
  bloat — rclone still excludes it), a direct trade-off against qn.5b's clean-snapshot invariant, so
  architect-only and probably a config toggle. **(4)** faster seed — inherently O(files) (~133 k
  reflinks); the (cs) chown fix already trimmed it and there is no big win left short of the REJECTED
  zfs-clone-as-dataset approach ((cg)). **Recommendation: (1) now (cheap, soak-path), (2)/(3) only if
  the raw latency — not just its visibility — must drop.** Sent to architect for routing.
- 2026-07-24: (cv) **ARCHITECT REVIEW of the qn.5b hardware session: branch approved + landed
  (main → `0f9eaff`, ff-only); all four routed findings adjudicated.** Code verified, not just the
  report: the (cs) fix's mechanism (a distinct `zfsSeedTimeout` via `seedCtx()`; the metadata verbs
  keep 60 s), the regression test's discrimination (it inspects the deadline the hook verb actually
  receives and the old code gives *exactly* 60 s), and the hook `chown` reasoning (`cp -a` preserves
  ownership; only the mkdir'd parent needs it). (cr)'s mechanism confirmed in code (`wire.Version`
  has no `missing` field; `toWire` never maps `store.VersionRow.Missing`), as was Finding B's
  (`WorkDir` resumes ANY non-empty `working/<udid>`; `writeWorkState` runs only after the seed).
  Privacy sweep clean (no LAN IPs in the diff; the pcap fixtures stay local-only). **Rulings:**
  **(1) (cr)(a) → qn.6a, CONFIRMED,** with the contract shape ruled: add `missing: bool` to
  `wire.Version` (contracts §2) and render dead versions **explicitly dead, NOT omitted** — no size
  claim, no `Unlock`, an "artifact gone — remove?" action on the existing `DELETE`. Omission would
  silently shrink history and mask exactly the drift a soak exists to surface; the dead row is also
  the user's only record the backup ever existed. **(2) (cr)(b) → banked as constraint #7 on the
  multi-storage epic (cl),** not qn.6a, not a near-term patch: no background sweep or
  revalidate-on-read until "storage unreachable" and "artifact gone" are distinguishable states —
  the implementer's do-not-build-a-sweep-that-cannot-tell-them-apart caution is adopted as a hard
  sequencing rule. **(3) (ct) Finding B → a qn.5b CLOSEOUT PATCH (owner: the qn.5b implementer),
  CI-provable, no hardware needed — before or alongside qn.6a.** It is a gap in qn.5b's own design
  (sentinel timing), and the soak makes mid-seed crashes realistic (restarts, OOM, power). Spec
  accepted with three refinements verified against the code: **(a)** the sentinel already lives in
  the device dir OUTSIDE `working/<udid>` (survives the hook's `rm -rf` + `cp -a`), so
  write-before-seed needs no restructuring; **(b)** the completeness flag must be **legacy-safe**:
  an EXISTING sentinel without the new field was written post-seed under the old code and is
  therefore COMPLETE — absent-field must read as valid, or the patch would discard a resumable
  34 GB `working/` on the soak box's first restart after upgrade (shape it accordingly, e.g.
  `seed_in_progress: true` written pre-seed and cleared on success, absent = complete); **(c)** the
  guard applies to BOTH models (`zfs.go` and `namespace.go` share the resume-any-non-empty
  pattern), and the discard path re-seeds with a log line. CI leg: a partial tree with an
  in-progress/absent-complete sentinel must be discarded and re-seeded, never resumed; a dirty
  working from a FAILED BACKUP (complete seed, real sentinel) must still resume — the guard has to
  discriminate the two. **(4) (cu) → option (1) in qn.6a, CONFIRMED,** with the contract shape
  ruled: a `seeding` job phase between `preflight` and `backing_up` (contracts phase-enum
  addition); UI narrates "Preparing — cloning from your last backup…". **Options (3) and (2)
  DECLINED for now:** (3) trades away the clean-snapshot invariant qn.5b just paid for — revisit
  only with soak evidence that the RAW latency, not its visibility, is the complaint; (2) is
  transport-adjacent complexity that would belong near qn.7's audition if ever. (4)-faster-seed is
  already harvested by (cs). **(5) qn.7 evidence — accepted as banked** (roadmap block reviewed);
  the legitimate-idle-pause finding is load-bearing for the liveness-threshold tuning, and the
  session's own on-the-record correction of its two live misreads (a pause is not a deadlock) is
  the process working as designed. Roadmap updated: qn.6a homings flipped to confirmed with the
  ruled contract shapes; epic (cl) gains constraint #7.
- 2026-07-24: (cw) **Finding B CLOSED — the qn.5b `seed_in_progress` guard: a seed killed mid-clone
  is no longer silently resumed into (branch `claude/qn5b-finding-b-seed-guard`, gates-green).** Per
  the (cv) ruling, `workState` gains `seed_in_progress bool` written **true before the seed clone**
  and cleared to **false on success**. A non-empty `working/<udid>` whose sentinel still says
  in-progress is a partial clone (a seed SIGKILLed by the old (cs) timeout, or any crash mid-seed) —
  `WorkDir` now **discards it and re-seeds** instead of resuming (resuming a partial could commit a
  version missing blobs, since the encrypted verify only shard-checks a *full*). **Legacy-safe by Go's
  zero value (the architect's refinement):** an old-code sentinel — written *post*-seed, so complete —
  has no `seed_in_progress` field → decodes to `false` → **resume**, so the first restart after upgrade
  never throws away a resumable 34 GB `working/`. Implemented as a **shared `prepareWorkDir`** both
  backends now call (the two WorkDirs were duplicate lifecycles) so the guard is provably identical
  across models — a small dedup that fell out of "applies to both." CI leg `TestSeedInProgressGuard`
  proves the guard **discriminates** on BOTH models: killed seed → re-seed (a planted TAG is gone),
  completed seed → resume (TAG survives), legacy sentinel → resume (TAG survives). No hardware; storage
  coverage 78.9→79.3%. This closes the last qn.5b-owed item; the remaining routed findings are qn.6a's
  ((cr)/(cu)) and the multi-storage epic's (constraint #7).
- 2026-07-24: (cx) **(cu) ELABORATED with the Operator — the raw-latency mechanisms banked as a
  parked, evidence-gated roadmap block (Later/parked).** The Operator proposed a concrete scheme for
  (cu) option (2): a cheap stand-in target so idevicebackup2 handshakes (and fires the passcode
  prompt) immediately, the real seed running in parallel, `RENAME_EXCHANGE` swapping the seeded tree
  in when ready. Architect checked the idevicebackup2 source rather than guessing: the facts are
  FAVORABLE (pre-request it only stat/reads+rewrites `Info.plist`, remove-then-create so
  alias-safe; manifests are read post-request via `DownloadFiles`; the iOS 16.1+ passcode wait
  fires before the message loop; no long-lived fds — per-message `fopen`, so a mid-run exchange is
  coherent). The Operator's "probing rw too early" caveat mostly dissolves, and "mark it readonly"
  is the wrong tool (it breaks the legitimate Info.plist rewrite; the safe shape is a stand-in with
  copies of the four control files and NO shard aliases). **The real hazard is the LOST RACE:** a
  swap landing after the first write-class device message discards device-uploaded data into the
  doomed stand-in — a version missing blobs, Finding B's failure mode by another road; plausible on
  a tiny incremental (seconds of transfer vs ~23 s seed). So: a dedicated rung with a spike leg, if
  ever. **Architect's challenge, accepted into the bank:** option (3) pre-seed-after-commit achieves
  the same ideal UX with ZERO concurrency — the staleness objection is empty (`latest/` never
  changes between commits), costs are the clean-snapshot invariant (bought for cleanliness, not
  correctness) + copy-backend disk (gate to `SHARED` seeds) — and dominates the stand-in scheme on
  risk-per-UX; the stand-in wins only if the invariant is ruled non-negotiable. **Ruling
  (Operator-agreed): sequence unchanged** — qn.6a `seeding` phase now → soak → only if the raw wait
  (not its visibility) is the complaint, rule between (3) [architect's lean] and the stand-in rung.
  Both candidates + the source-verified facts live in the roadmap's Later/parked block so nothing is
  re-derived from scratch. Interface-facts rule applies: re-verify against the VENDORED build before
  building either.
- 2026-07-24: (cy) **ARCHITECT REVIEW of the Finding B closeout ((cw), branch
  `claude/qn5b-finding-b-seed-guard`): APPROVED + LANDED (main → `b0a859a`, ff-only).** Verified in
  code: the sentinel is written `seed_in_progress:true` BEFORE tree creation and cleared on success;
  the guard discards-and-re-seeds only on a present sentinel still saying in-progress; the (cv)
  legacy-safety refinement is implemented by Go's zero value AND proven by a hand-planted
  legacy-JSON test case; the shared `prepareWorkDir` makes the guard provably identical across both
  models (a real dedup — the two WorkDirs were duplicate lifecycles). Crash-window walk: every kill
  point resolves safely — a crash mid-write of the FIRST sentinel leaves an empty/absent tree that
  bypasses the guard and re-runs; a crash mid-write of the CLEARING sentinel leaves a corrupt
  sentinel only beside a COMPLETE tree, where the read-failure→resume fallback is correct (and the
  torn-write exposure of the sentinel predates this patch, unchanged). `TestSeedInProgressGuard`'s
  TAG discrimination is the exact CI leg (cv) demanded (killed→re-seed, completed→resume,
  legacy→resume, both backends). Privacy sweep clean. **qn.5b is now FULLY closed** — built (cp),
  hardware-proven (ct), all follow-ups routed (cv), Finding B fixed (cw). Chain: **qn.6a (soak UI) →
  freeze**.
- 2026-07-24: (cz) **(cu) latency bank AMENDED after a second Operator discussion — the GATE PATCH
  becomes candidate C and DOMINATES the stand-in scheme; in-process integration assessed and
  declined as a candidate.** The Operator asked whether the dead air is a consequence of running
  idevicebackup2 as a subprocess and whether tighter integration is the ideal fix. Diagnosis
  sharpened: the cause is BLACK-BOX-ness, not subprocess-ness — idevicebackup2's sequence has
  exactly one point where waiting is free (after the `Backup` request = passcode already fired,
  before the message loop), and every workaround is a contortion around not controlling that point.
  **Candidate C (new): patch a `--gate <path>` pause into idevicebackup2 at that point** — quince
  launches immediately (prompt ~1–2 s), seeds in parallel, touches the gate file; deterministic, no
  stand-in, clean-snapshot invariant kept, and it RIDES THE FORK qn.7 ALREADY CARRIES (the #1413
  receive-timeout patch), while every subprocess-supervision property (crash isolation, kill
  matrix, liveness, cancel, transcript parsing) survives untouched. It strictly dominates candidate
  A (stand-in + `exch`): the same overlap with none of the lost-race machinery — A demoted to a
  historical note, resurfacing only if carrying the patched build becomes untenable. **In-process
  (cgo libimobiledevice / Go mobilebackup2) declined as a candidate:** crash isolation lost (the
  kill-matrix hardening assumes a disposable external process), protocol correctness becomes ours
  (against the ruled "hope idevicebackup2 does its job well" posture), and **go-ios verified NOT to
  implement mobilebackup2** — no pure-Go crib exists, we would be first. If ever, it is a
  post-freeze epic justified by accumulated soak + qn.7 chaos evidence that subprocess supervision
  is a persistent tax, never by (cu) alone. **Live fork if the soak indicts the raw wait: B
  (pre-seed — zero external code, costs the clean-snapshot invariant) vs C (gate patch — keeps the
  invariant, costs one more patch on an existing fork). Settle THEN, on soak evidence.** Roadmap
  Later/parked block restructured accordingly (live candidates first, A demoted, in-process note).
- 2026-07-24: (da) **qn.6a BUILT (CI-proven) — soak-ready UI (mobile + offline devices), the LAST rung
  under the current process.** Branch `claude/qn6a-soak-ready-ui`; `make gates` + `make image` +
  `make gates-ui-e2e` green in `quince-dev`; awaiting architect review + land. Spec + friction notes in
  `docs/specs/qn.6a/`. **Both ruled contract changes landed with the build (qn.5b Reset precedent):**
  (1) `missing: bool` on `wire.Version` (§2) — `store.VersionRow.Missing` already existed and was
  honoured everywhere EXCEPT the wire (`toWire` never mapped it), so a gone artifact rendered as a
  normal backup; now crossed to the wire and the UI renders it explicitly dead (no size, no Unlock,
  "artifact gone — remove?" on the existing `DELETE`), never omitted ((cr)(a)/(cv)). (2) `seeding` added
  to the `Job.state` enum between `preflight` and `backing_up` ((cu) opt 1/(cv)). **Rung-local ruling
  recorded (friction #4):** (cv) called it a "phase … (contracts phase-enum addition)", but the contract
  has two candidates — the `Job.state` enum and the open `progress.phase` string. Landed as a **state**
  (with `progress.phase` mirroring): the engine models every lifecycle stage as a state, and the card +
  details panel label off `job.state`, so only a state makes the ruled "Preparing — cloning from your
  last backup…" the headline instead of leaving it at "Preflight" for the ~23 s clone. Non-breaking add.
  **Engine:** `preflight` split into checks-only + a `seeding` step that wraps `storage.Seed`; a seed
  failure terminates `failed` (the qn.5b Finding B sentinel guard owns any partial). **Offline devices
  ((ch), minimal — not a subsystem):** migration `0004_device_identity` + `store` upsert/list, persisted
  identity + last-seen; `Registry.Devices()` unions live presence with `KnownUDIDs()` (= `SELECT DISTINCT
  udid FROM versions`) and returns an offline shell (no transports, persisted name + last-seen +
  last_backup) for a backed-up-but-absent device; `Enrich` persists; a live online→offline card
  transition fires on last-transport detach of a backed-up device (emit `device.detached` then
  `device.updated`), so unplugging a phone mid-session turns its card offline instead of vanishing.
  `Device(udid)` returns the offline shell too (audited: `StartBackup`/`resolveTransport`/preflight all
  gate on `presentOn`, so no behaviour regressed; deviceops/reset now answer "needs connection" instead
  of 404 for a known-offline device — strictly more honest). Version count is derived client-side from
  the versions store (no new field). **Gate-11 findings:** #6 failed-newest "needs attention · Retry"
  companion line on the card (NOT a `last_backup` mutation — the (cj) CORE item; a soak whose failures
  are invisible is worthless); #7 client single-`is_latest`-per-device invariant folded into the versions
  store `upsert` (demote the prior latest on a new `version.created` — kills the two-badges-until-reload
  bug); #10-byte honest labelling — the tool's `(X/Y)` is the CURRENT file, not the backup total, so the
  UI leads with percent + files and labels the pair "current file" (no contract change, the `wire`
  comment pins the meaning); (ck) `kind` dropped from the version card (kept internal/API). **Log-blob
  `SplitFunc` (#3):** a custom `bufio.SplitFunc` splits idevicebackup2's `\r`-redrawn progress into
  per-frame tokens (parser reads the LATEST bytes, not the oldest in a 12 KB blob), and pure-redraw
  frames are dropped from the log ring/WS — one fix for the mangled pane + stale byte counter + bloat.
  **Mobile-first pass ((ch), NOT an IA redesign):** responsive shell (sidebar → phone top-bar), taller
  touch targets on phones, no horizontal overflow, and the log pane / dialogs / version list / history
  reflow; proven at 390×844 by e2e story 5. **Demo** gained an offline device (`attic-ipad`, no
  transport, a live + a DEAD version) so offline + dead-version render are demoable and e2e-provable.
  Coverage: backup 85.2% / device 97.2% / store 81.3%; UI 46 vitest + 5 e2e stories. **Contract
  discipline:** items 5/6 were the only two contract changes, both pre-ruled in (cv); no `PROPOSED (gap)`
  needed. Privacy sweep clean (demo fixtures only — synthetic UDIDs, no serials/LAN IPs). Friction notes
  handed to the revamp (`docs/specs/qn.6a/friction-notes.md`): scattered scope surface, manual
  letter allocation, absent `local/`, the phase-vs-state contract ambiguity. Chain from here: **land qn.6a
  → freeze + process revamp (app soaking on staging).**
- 2026-07-24: (db) **ARCHITECT REVIEW of qn.6a ((da)): APPROVED + LANDED (main → `3a7b068`,
  ff-only). The rung chain is COMPLETE — the frontier is now the CODE FREEZE + PROCESS REVAMP, with
  the app soaking on staging.** Verified in code, not just the report: both contract changes are
  exactly the (cv) shapes (`missing` mapped in `toWire`, dead row = no size/no Unlock/Remove-on-
  DELETE/never omitted; `seeding` between `preflight`/`backing_up` with `progress.phase` mirroring);
  the engine split kept the load-bearing ordering (every preflight REFUSAL still precedes Seed —
  nothing to discard on refusal); startup job-row reconciliation is complement-of-terminal, so a
  daemon killed mid-`seeding` reconciles to `connection_lost` with no enumeration to update and the
  Finding B guard owns the partial tree; `scanFrames` handles the `\r\n`-split-across-reads edge;
  the client single-`is_latest` fix is correctly scoped per-device; `UDIDsWithVersions` includes
  missing-only devices (history rendered dead, not forgotten) and a failed lookup degrades to empty
  rather than blanking the live table; e2e story 5 asserts the real soak claims (overflow ≤ 1 px,
  disabled-with-reason, seeding narration, dead row) at 390×844. Architect re-ran the privacy sweep
  over the full branch diff (warranted — see deviation 1): clean, synthetic demo constants only.
  **Ruling 1 — the state-vs-phase judgment call is ENDORSED and now canon:** (cv)'s "phase-enum
  addition" wording was ambiguous between the `Job.state` enum and the open `progress.phase` string;
  the implementer's reading — `seeding` as a full STATE — is ratified, for the implementer's own
  reason (the card headline reads `job.state`; only a state makes the ruled narration the headline
  during the ~23 s clone) plus one the report didn't claim: the state machine's running states are
  consumed complement-of-terminal throughout, so the add is structurally free. **Two process
  deviations recorded as REVAMP EVIDENCE, not blame:** (1) the branch was pushed to the PUBLIC
  remote before architect review — the landing protocol has the architect land; a pre-review push
  makes an unreviewed privacy leak irreversible in principle (this one was clean; the remote branch
  is deleted post-land). The implementer flagged the push itself as unexplained ("wasn't in
  protocol"), which is exactly the honesty the process wants. (2) The contract diffs were landed
  with the build rather than proposed early for sign-off as the kickoff asked — functionally
  mitigated here (the shapes were pre-ruled and the ONE ambiguity was flagged for review, which is
  what early sign-off exists to catch), but the mitigation relied on the implementer's judgment,
  not the process. Both join the friction pile: the revamp should make the landing/proposal
  protocol MECHANICAL (a checklist the session can't drift past), not narrative. **Observation
  banked for qn.7 (no action now):** `storage.Seed` takes no context — a cancel during a hung seed
  waits on the 30-min backstop, not the job cancel; pre-existing shape (unchanged since qn.5b),
  belongs with qn.7's liveness/chaos work. **Soak notes for the Operator:** redeploy staging from
  main `3a7b068` (staging still runs the hardware-day build — it predates the Finding B guard AND
  qn.6a); migration 0004 applies on first start; avoid changing the backup password mid-soak
  (#9b, qn.7). **The daily-driver arc that began at (by) is DONE — qn.4c, qn.5, qn.5b, qn.6a all
  landed; the app is soak-ready. Next session under a NEW process.**
- 2026-07-24: (dc) **CORRECTION to (db) deviation 1 (Operator clarified): the qn.6a push was NOT
  unprompted.** The implementer initially did not push; the push followed the Operator's
  instruction "Now commit and I'll send it to architect for review. Then deploy to staging." So the
  accurate account: an instruction ambiguous about TRANSPORT — "send it to architect" (the
  architect reviews the local branch in the shared checkout; no push needed) and "deploy to
  staging" (implies publishing somewhere) — was silently resolved toward the IRREVERSIBLE reading
  (push to the public remote) instead of the reversible one, with no note of the interpretation
  taken. The report inconsistency ("not pushed — ready for review" at top, a PR link at bottom) is
  the same event: the report was drafted pre-push and not reconciled after the late push — state
  honesty applies to reports too; a report whose facts change after drafting gets reconciled, not
  appended to. **The revamp lesson sharpens rather than softens:** this was a REASONABLE
  instruction and a PLAUSIBLE interpretation — which is exactly why the fix is structural, not
  behavioral. The mechanical landing protocol should pin who pushes and when (the architect
  pushes, at landing; the implementer never pushes), so a casual "send it" cannot be read as
  authorization to publish, and on a public repo the default resolution of any transport ambiguity
  is the reversible one. (db)'s "the implementer flagged the push as unexplained" is also
  corrected: that flag was the OPERATOR's, in relay.
- 2026-07-24: (dd) **qn.6a SOAK-POLISH BATCH reviewed + landed (9 commits, main → `ef897eb`) — the
  soak's first real yield, delivered OUT of process and adjudicated honestly.** The Operator used
  the app from a phone immediately after qn.6a landed and worked a polish batch directly with the
  implementer — no spec, no report, no letter, scope beyond the ruled qn.6a items. Architect review
  (code-level, every commit): **all nine are genuine soak findings, approved.** Highlights: **the
  iOS PWA dead-socket fix** (a suspended PWA's WebSocket dies WITHOUT `onclose`, so the old
  reconnect skipped the non-null socket forever — resume listeners now drop the stale socket, reset
  backoff, and revalidate auth after long suspensions); **the SPA cache policy** (`no-cache` on
  `index.html`/non-hashed assets, `immutable` on hashed `assets/` — without it a redeploy is
  invisible behind Safari's cache, which would have silently corrupted the soak's own evidence);
  **exactly one primary action per card** (Retry REPLACES "Back up now" when the newest attempt
  failed, failure text as context — an improvement on the landed #6 shape, semantics preserved);
  Retry only on the LATEST intent in history (an old failed intent's "retry" is just "back up now"
  with extra confusion); capped history + Show-all; live-ticking relative times (`useNow`);
  the disabled qn.8 "Unlock" placeholder → a quiet chevron (honest for unencrypted versions too);
  PWA manifest + wordmark icons (architect inspected the PNGs); mobile scroll-region architecture +
  standalone/landscape safe-areas; login layout. **Verification:** the branch had no gates run and
  this batch shipped no report — architect pushed it and opened PR #1 solely to run the CI ladder:
  gates + image + e2e ALL GREEN in the pinned toolchain; whole-diff privacy sweep clean. **Process
  adjudication (revamp evidence, not blame):** the Operator self-reported the deviation ("not
  quite by the process… a lot out of scope") and the batch is exactly what post-freeze soak
  maintenance will look like — the CURRENT process has no lane for "small verified polish under
  soak" short of a full rung, which is WHY it happened out of process. The revamp should design
  that lane (a lightweight verified-batch flow: CI-green + architect review + letter, no
  spec/report ceremony), rather than pretend every change is a rung. Also formalized here: with no
  local toolchain on the architect's machine, **PR-triggered CI is now the architect's standing
  verification route for unverified branches** (the PR is a CI vehicle; landing stays ff-only from
  the CLI). Soak note: the staging redeploy should now come from `ef897eb`, and thanks to the cache
  fix THIS is the last redeploy the phone might need a manual cache-clear to pick up.
- 2026-07-24: (de) **qn.6b "transport patience" INSERTED pre-freeze — the LAST pre-freeze insert,
  with the bar made explicit.** Chain: the Operator proposed pulling ALL of qn.7 pre-freeze (two
  reasons from the first soak day: a Wi-Fi backup hang — "probably WiFi drop, I don't know" — and
  the Backup-now→passcode wait being "really annoying" even WITH the seeding narration); architect
  counter-proposed a split (full qn.7 = weeks of chaos-suite/audition/tuning work that delays the
  overdue revamp — today alone produced three letters of process-deviation evidence); Operator
  ruled the split and named the pre-freeze half **qn.6b** (consistent with the insert convention;
  qn.7 keeps its name and stays post-freeze). **Why pre-freeze at all:** the soak's premise is
  daily use; a hanging Wi-Fi backup is what makes the Operator quietly stop using the app, killing
  the soak and the freeze plan with it. **qn.6b scope (small, coherent):** (1) the patched
  libimobiledevice build — 30 s → 15 min receive timeout (upstream #1413), as an IN-TREE PATCH
  FILE applied to the pinned upstream tag at image build (no hosted fork); (2) **the gate patch —
  candidate C — on the same fork**, which SETTLES the (cx)/(cz) evidence gate (the Operator's
  complaint is the raw wait despite the narration = exactly the evidence the gate demanded);
  spike-first per (cz), with candidate B (pre-seed) as the in-rung fallback so the rung cannot
  stall; (3) liveness thresholds retuned to the 15-min reality — inseparable from (1), else "fails
  too fast" becomes "looks hung forever"; both (ct) sides held: no panic on legitimate pauses,
  honest eventual dead-link classification; (4) **the 6a-soak hang as the acceptance case** —
  Operator to capture the job row/log/wait duration BEFORE a redeploy loses it; whether the
  sampler fired decides tuning-vs-bug. **qn.7 keeps:** chaos suite, netmuxd-USB audition,
  restart-policy tuning, #2, full #8, #9b, #10-percent, UX copy. **The last-insert rule:** a
  pre-freeze insert is justified ONLY by a defect that stops daily use; qn.6b is the fourth insert
  ((by)/(cg)/(ch)/(de)) and the final one — nothing else on the books meets the bar. Roadmap: qn.6b
  block added before M4; qn.7 block amended; the Later/parked seed-latency block flipped to
  GATE-MET/SETTLED→C (decision record retained).
- 2026-07-24: (dg) **qn.6b SPEC REVIEWED — APPROVED WITH AMENDMENTS; build may start once they are
  folded in (no re-review needed pre-build).** Spec at `docs/specs/qn.6b/qn.6b.md` ((df) reserved
  for the build entry). The spike's two corrections to the kickoff brief are ACCEPTED and the
  looked-up rule vindicated against the architect's own stale figures: Alpine 3.24 ships
  libimobiledevice `1.4.0-r0` (pin `LIBIMOBILEDEVICE_REF=1.4.0`), and `configure.ac` requires the
  undocumented 4th dep `libtatsu` (≥1.0.3; Alpine has 1.0.5). The spike's `-5 RECEIVE_TIMEOUT`
  finding is ENDORSED as the rung's load-bearing fact: idevicebackup2 never exits on pure silence
  (the retry is PRINT_VERBOSE(2), suppressed), so quince's sampler is the SOLE authority for a
  cleanly-idle dead link — and note the corollary: the UNPATCHED tool also loops `-5` forever (at
  30 s intervals), so the 6a-soak hang was likely already this shape; the Operator's capture still
  decides tuning-vs-bug exactly as item 4 forks. The 18-min `LivenessTimeout` (= tool's 15 m + 3 m
  margin) + `toolReceiveTimeout` mirror constant + the mechanical guard test are approved as
  specified. Candidate-C engine sequencing (gate → Info.plist capture/seed/restore → release)
  approved; lab-owed device-tolerance leg + candidate-B fallback per (de) confirmed.
  **AMENDMENT A (substantive): the 15-min default must not leak into non-backup device ops.**
  Patch `0001` raises the DEFAULT receive timeout for every libimobiledevice-backed binary in the
  image — and item 1 replaces the apk tools with the patched build, so pairing, enrichment reads,
  and the live encryption re-read ((i)-B) all inherit 15-min patience. A wedged lockdown read
  during preflight/pairing would then sit 15 minutes where it used to fail in 30 s — a UX
  regression hiding inside a reliability rung. Required: an audit story asserting every non-backup
  tool invocation runs under a Go-side context bound (≲60 s); any unbounded call found is bounded
  IN THIS RUNG (direct consequence of item 1, in scope). CI-provable.
  **Amendment B (minor, prose):** item 2 step-3 lists the Info.plist write after the `Backup`
  request, but the spec's own line numbers (2242/2243 write < 2261 request) put it BEFORE — which
  is *better* for the engine (the seed-wait target appears within ~1 s of launch, not gated on the
  user's passcode); make the prose match the lines so the seed-wait timeout rationale is grounded.
  **Amendment C (minor, one sentence):** state that a quince-daemon crash mid-gate cannot orphan a
  forever-polling tool — the tool is a child in the same container and dies with it (container
  lifecycle); the in-tool `quit_flag` covers the supervised-cancel path.
  Item 4's capture remains the Operator's (staging is his box); stories 8–10 sequencing as
  proposed. Contract stance (NONE) confirmed. Letters: (df) build, (dg) this review.
- 2026-07-24: (dh) **qn.6b spec DELTA reviewed after a relay-ordering slip — the capture-driven
  item-3/item-4 edits are now ACTUALLY approved; the (dg) build-go stands.** What happened: the
  Operator relayed the (dg) approval into the implementer session mid-turn, and it landed AFTER the
  implementer had folded the incident capture into the spec (+35/−13 on items 3/4) — so the
  approval appeared to cover text it had never reviewed. The Operator caught and reported the slip
  himself. Architect has now reviewed the delta directly in the worktree: **approved.** The item-3
  edits fold the (dg) corollary faithfully and sharpen it into the two-hang-shapes taxonomy (`-4`
  SSL/reset → tool exits `failed` fast; `-5`-forever clean idle → only the sampler ends it). The
  item-4 rewrite is endorsed, ESPECIALLY its honest residual: the captured `-4` fired at ~10 s of
  silence — faster than even the unpatched 30 s timeout would cleanly expire — because `-4` is an
  SSL-layer error on a mid-record stall, so the patch's cure for `-4` is EMPIRICALLY-BACKED
  (upstream #1413 reports + (ct)), not mechanically proven; story 9 is genuinely decisive; a
  story-9 failure is pre-classified as a qn.7 finding (retry-on-`-4` / #8 reclassification), not a
  qn.6b blocker. **Incident verdict ratified:** job 01KY95VPJ8WW9ESN3EFMRGMRFZ died at ~44 s via
  `outcomeProcErr` (the tool's own `-4` exit, verified at the engine call site) — the sampler never
  fired, quince behaved correctly (dirty `working/` kept, resume-no-re-seed worked). Item 4 = tool
  patience, item 1 is the fix. **Perception reconciled (no new work):** the Operator EXPERIENCED a
  hang, but the job failed in 44 s — the missing layer is plausibly the pre-(dd) PWA dead-socket UI
  staleness (the phone showed a frozen "backing up" over a dead WebSocket; fixed and landed in the
  (dd) polish batch). The full user-visible incident is thus covered by (dd) [already landed] +
  item 1 [this rung]. **Contingency pre-ruled to protect the last-insert rule ((de)):** if story 9
  shows the patch does NOT cure this `-4`, finishing the SAME defect is a CONTINUATION of the (de)
  insert's mandate (the defect still stops daily use), scoped to the minimal bounded retry or
  reclassification — it is not a new insert and does not reopen the bar. Nit for the spec: item 4
  credits the pcap root-cause "(architect, ratified (ct))" — the wire dive was the qn.5b hardware
  implementer's, ratified by the architect in (cv); fix the parenthetical. Amendments A/B/C from
  (dg) stand unchanged. **Revamp evidence (the third relay artifact after (dc)/(dd)):**
  cross-session relay has no ordering guarantee, so an approval can silently drift onto newer text
  — the revamped protocol should make approvals reference WHAT was approved (a spec revision
  marker/section list), so a mistimed relay cannot widen a ruling's coverage.
- 2026-07-24: (df) **qn.6b BUILT (CI-proven) — transport patience: patched-from-source
  libimobiledevice + the `--gate` candidate-C seed overlap + the liveness retune + amendment A.**
  Branch `claude/quince-qn6b-wifi-backup-64162c`; **not pushed** (architect lands ff-only via PR-CI,
  (dd)). `make gates` + `make image` + `make gates-ui-e2e` green in `quince-dev`; coverage backup
  83.5% / deviceops 81.5% / storage 78.1%. Spike facts all verified against upstream `1.4.0`
  (`docs/specs/qn.6b/spike-libimobiledevice.md`); the two kickoff-brief corrections it forced (Alpine
  ships `1.4.0` not `1.1.1_git20250201`; the undocumented `libtatsu` build dep) held. **(1) Patched
  build:** `LIBIMOBILEDEVICE_REF=1.4.0` in `versions.env`, built from source in a new Dockerfile
  stage (only libimobiledevice — Alpine 3.24 ships every dep); two in-tree patch files
  (`deploy/patches/libimobiledevice/`, applied via `git apply`, verified to apply against a pristine
  tag): `0001` `30000`→`900000` in `property_list_service.c`+`service.c` (#1413), `0002` the `--gate`
  flag at `idevicebackup2.c`'s single free point (post-Backup-request/pre-loop, spike C11). Runtime
  `idevicebackup2 --help` lists `--gate`; the on-disk lib is `1.4.0-dirty` (the COPY overwrites the
  apk copy that usbmuxd's soname dep pulls in — same soname, so everything links the patched lib);
  `-progs` dropped; `-Werror` sed'd off `configure.ac:88` for the vendored build; `--without-cython`.
  **(2) Candidate C:** the storage `Seed` split into `PrepareWork` (fast: resume-or-prepare, reports
  `seedPending`) + `SeedWork` (the clone; `finishSeed` clears `working/<udid>` first so the clone
  sees a clean dst after the tool created it). Engine `superviseGatedSeed`: launch gated → capture
  the fresh `Info.plist` (stability-checked read) → clone → restore it over `latest`'s → open the
  gate → run the sampler loop; `supervise` refactored into `startTool`+`runToolLoop` shared with the
  non-gated resume path. Source-verified the sequencing is race-free (Info.plist written before the
  request/passcode; tool holds no fd into the target; the engine orders capture→clone→restore
  strictly). `TestStoryGatedSeedOverlap` proves the committed version keeps the FRESH `Info.plist`
  across the clone and the passcode is narrated during seeding; `TestStoryResumeSkipsTheGate` proves
  a resume bypasses the gate. **(3) Liveness retune:** `LivenessTimeout` 15m→**18m** with a
  `toolReceiveTimeout=15m` mirror constant + `TestLivenessBackstopExceedsToolTimeout` guarding
  `backstop > tool`. The load-bearing spike finding reshaped this: a cleanly-idle dead link makes
  idevicebackup2 loop `MOBILEBACKUP2_E_RECEIVE_TIMEOUT` (-5) FOREVER without exiting
  (`idevicebackup2.c:2504`), so the sampler is the SOLE authority there — the retune out-waits the
  tool's own patience so a flap the tool would ride out is never SIGKILLed. `-4` (SSL/reset)
  classification stays qn.7 (#8). **Amendment A ((dg)):** audited `deviceops`/`device` — the only
  unbounded non-backup tool call (`Manager.Validate`) is now bounded by `deviceOpTimeout=30s`; the
  interactive ops (pair 2m / encryption 5m) already cap the child < 15m; enrichment reads already
  20s. `TestValidateBoundedGoSide` proves a wedged read returns in the bound, not 15 min.
  **Item-4 verdict (the captured Wi-Fi hang):** the DB error `backup_failed | backup failed: Could
  not receive from mobilebackup2 (-4)` at ~44 s is `engine.go`'s `outcomeProcErr` — the tool's OWN
  exit, NOT the sampler (`outcomeTimeout`). So it is neither a quince tuning miss nor a liveness bug;
  it is idevicebackup2 giving up too fast on a ~10 s recoverable drop — exactly what item 1 targets —
  and quince behaved correctly (kept the dirty `working/`, clean discard-for-retry). Whether the
  timeout raise fixes THIS `-4` is empirically-backed-not-mechanically-proven (the `-4` fires faster
  than a clean timeout; some `-4` are device resets a timeout can't cure), so **story 9 is genuinely
  decisive**, not a formality. **Contract changes: NONE** (enum values/states reused; the `Storage`
  Go seam gained methods, an internal interface, not a frozen contract). **Docs:** stack D2 (patched
  build + gate + the amendment-A note), design §4 (18-min backstop rationale + the `seeding` state
  added to the state diagram — a qn.6a drift fixed here). **Privacy:** swept clean (`make
  privacy-check` + explicit UDID/IP scan); the (ct) pcap fixtures stay LOCAL-ONLY and were never
  referenced. **Known-untested (declared debt):** the gated-seed ERROR branches (SeedWork fails
  mid-gate, tool exits before Info.plist, gate-write fails, cancel during the gated seed) are not
  exercised — the happy path + resume-bypass are, and each error maps to the same terminal shapes the
  non-gated paths already test. **Lab-owed (declared, sequenced with the Operator):** story 9 (re-run
  the `-4` hang on the patched build), story 10 (15-min patience across a real flap → succeeded or an
  honest eventual terminal), story 11 (gate vs a real device: ~1–2 s passcode + ~20 s tolerance;
  candidate B is the in-rung fallback if the tolerance leg fails). Friction notes: the letter/rebase
  reconciliation (main advanced to (dh) while this built on a (de) base — code untouched, only the
  decisions-log append reconciles); `make fmt` needed after struct-comment edits ([[quince-dev-loop]]).
- 2026-07-24: (dj) **ARCHITECT REVIEW of qn.6b ((df)): APPROVED + LANDED (rebased onto (dh) main,
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
- 2026-07-24: (di) **e2e story-4 FLAKE fixed under the soak-maintenance lane ((dd)) — a test-only
  change; two distinct bugs, diagnosed honestly, neither a UI defect.** CI run `30108238903` (job
  `e2e`, on main `c5a7776` — a DOCS-ONLY commit; the prior run on identical code was green → flake,
  not regression) failed `story4-backup-now.spec.ts:22` two different ways across the attempt + its
  Playwright retry. **Bug 1 — strict-mode violation at the second cancel assertion:**
  `getByText(/backup cancelled/i)` resolved to 2 elements. Traced to source, NOT a double-render:
  both are legitimate `JobHistory` intent-group summaries (`groupByIntent` → "Backup cancelled"),
  and by that point the test has cancelled TWO jobs — the retried seed-intent and the fresh
  backup-now intent — so two groups honestly read cancelled (DeviceCard, the other suspect, isn't
  even mounted on the details page). It flaked rather than always-failed because `wire.Now()` is
  second-precision RFC3339, so the assertion sometimes fired in the window before the 2nd cancel
  re-rendered (1 match) and sometimes after (2 → strict violation). **Fix:** assert on the COUNT
  delta of an EXACT-text locator (`getByText("Backup cancelled", { exact: true })` — the capital-B
  summary, excluding the lowercase "backup cancelled" job-log line) via `toHaveCount(before+1)`.
  Count-delta is (a) immune to the newest-first ordering tie on a shared whole-second timestamp,
  (b) never trips strict mode with >1 cancelled group, (c) transient-tolerant (it polls to the
  settled value rather than hard-failing on a momentary 2, which is exactly what bare `toBeVisible`
  could not do). **Bug 2 — `retry-backup` absent on Playwright retry #1:** test-idempotence. The e2e
  demo server is SHARED and never reseeds per test, so the failed primary attempt already advanced
  spare-iphone's latest intent past the one-shot seeded `connection_lost` backup; Retry (latest-
  intent-only since qn.6a) is gone by the retry. **Fix:** guard the retry leg on
  `testInfo.retry === 0` — the primary attempt always runs against a fresh container (pristine seed)
  so it HARD-asserts the Retry affordance (regression guard preserved, coverage undiminished on
  every normal run); a genuine Playwright retry skips the now-invalid precondition and still
  exercises the backup-now/cancel leg. **Surface:** `ui/e2e/story4-backup-now.spec.ts` only (+30/−10);
  no engine/httpapi/ui-src/internal-demo change — deliberately, since qn.6b builds the engine/deploy
  surface in a parallel worktree (its uncommitted `internal/backup/backup.go` + `deploy/Dockerfile`
  were confirmed untouched). **Verification** (isolated dev CT `pct clone`d off qn.6b's box, per the
  one-project-one-CT rule): story4-test1 ×10 against a fresh seed with `--retries=0` → **10/10**
  (bug 1 gone under the strictest setting, no retry masking); a forced primary-fail against a
  consumed seed with `--retries=1` → primary fails on the absent Retry, Playwright retry recovers →
  **exit 0** (bug 2 guard proven end to end — old code would fail both attempts); full e2e suite ×3
  fresh containers → **9/9** each (no collateral breakage); **`make gates` green** (go `-race` all
  ok + golangci 0 issues, vault ruff/`mypy --strict`/pytest, ui typecheck/eslint/vitest 55·55/build).
  The run's 429 action-download backoff annotations were infra noise (recovered), not the failure —
  ignored per the brief. **Process:** soak-maintenance ((dd)) — CI-green + architect review + this
  letter, no spec/report ceremony; branch `claude/e2e-story4-flake`, NOT pushed (architect verifies
  via PR-triggered CI and lands ff-only); whole-diff privacy sweep clean. **Friction / revamp
  evidence:** (1) the shared long-lived `--demo` server is a good fidelity choice but has no per-test
  reset, so any test that CONSUMES a one-shot seeded precondition is non-idempotent under a
  Playwright retry — the clean fix (a demo reseed endpoint the e2e can call in `beforeEach`) was
  out of surface here (needs httpapi, which qn.6b owns); the revamp should decide whether the demo
  provider grows a test-only reset so retry-idempotence stops living in per-test guards. (2) Two
  parallel sessions sharing one dev box is a real hazard — `quince-dev` (CT 110) held qn.6b's
  uncommitted engine diff, so a whole-tree rsync would have clobbered it; the lane needs an explicit
  "which CT is mine" rule for concurrent work (this fix used a throwaway clone, CT 116).
- 2026-07-24: (dk) **ARCHITECT REVIEW of the story-4 flake fix ((di)): APPROVED + LANDED (PR #3 CI
  green, ff-only to main `a45a307`).** Reviewed on the diff: bug 1's diagnosis traced to source
  (two legitimate intent-group summaries; DeviceCard not even mounted; the second-precision
  timestamp explains WHY it flaked) and the count-delta fix is strictly STRONGER than the bare
  `toBeVisible` it replaces (which could pass vacuously against a pre-existing cancelled group).
  Bug 2's `testInfo.retry === 0` guard accepted with the trade-off NAMED: a genuine
  Retry-affordance regression would surface as persistent fail-then-pass-on-retry (CI green,
  flake-annotated) rather than red — acceptable because the affordance has direct unit coverage
  (`JobHistory.test.tsx`, (dd)), so the e2e leg is defense-in-depth, not the only guard; the
  per-test-reseed alternative needs demo-server app code and stays a candidate for qn.7's chaos
  work if the guard ever bites. Repeat-proof verified as demanded by the kickoff (story 4 ×10 at
  zero retries, forced-primary-fail recovery, suite ×3). **The pre-freeze board is now clear of
  everything except the qn.6b LAB LEGS (stories 9/10/11, Operator's patched-image redeploy) —
  then the CODE FREEZE + PROCESS REVAMP.**
- 2026-07-24: (dl) **SPACE SCARE resolved — the reflink accounting trap's SECOND ambush, this time
  via the snapshot columns; no space is being wasted.** The Operator saw `zfs list -o space` bill
  ~177 GB for the two lab devices (three iPhone snapshots at ~33.9 GB "unique" each, `USEDDS`
  68.2 GB) and reasonably read it as a design failure. Pool ledger says otherwise: `bclonesaved
  122G` / `bcloneused 37.0G` → **actual physical spend ≈ 55 GB** (one shared tree of blocks + real
  per-generation deltas). **The signature, now canon (stack D5):** under the reclone-per-generation
  lifecycle, the NEWEST snapshot bills ~0 unique (the head shares its block pointers) and EVERY
  OLDER generation bills ~the full tree (the next seed's exchange replaced all pointers, making the
  old snapshot sole referent of its pointer set while the physical blocks stay BRT-shared) — so
  `USEDSNAP` grows ~full-size per generation *by construction*, and the listing looks like N full
  copies. It is the (bf) trap wearing a new column. Diagnosis rule unchanged and re-vindicated:
  pool ledger (`zpool get bcloneused,bclonesaved`), never `zfs list`/`du`. The lab listing's
  newest-snapshot values (548K iPhone / 15.6M iPad) were the tell — real duplication cannot produce
  a free newest snapshot. **Two real items extracted:** (1) the pre-qn.5b 07-22 snapshots (ruled
  disposable in (cv)'s hardware-day list) are STILL alive — Operator to `zfs destroy`; (2) NEW,
  previously unbanked: **`zfs send` does not preserve block cloning**, so a syncoid/replication
  target pays every `@quince-*` snapshot at FULL rematerialized size — snapshot retention is a real
  capacity knob on replicas (origin pool: ~free), and retention policy should be set before a
  daily-soak year of generations meets an offsite pool. Routed: the retention/replication-cost note
  lives in stack D5; a retention default is qn.7-or-freeze-exit material, not urgent (the origin
  pool is unaffected; the Operator's syncoid replica is the only exposure and is his to watch until
  then).
- 2026-07-25: (dm) **qn.6b LAB LEGS RUN on real hardware — stories 9/10/11 validated; candidate C +
  liveness patience + kept-dirty-working RESUME-TO-COMPLETION all PROVEN; the bad-link `-4` resilience
  characterized live and routed to qn.7. qn.6b's lab debt is CLEARED.** Session on staging (zfs HOOK
  mode, the lab iPhone over Wi-Fi/netmuxd), redeployed to the qn.6b image; two full committed backups
  produced. **Story 11 (candidate C / gate) PASS:** the on-device passcode fired in ~1–2 s (Operator-
  confirmed), the seed ran DURING the gate hold (`hook-reflink`, verdict `SHARED`, zero-space), and the
  device tolerated the ~20 s gate hold on the real hook backend — the zfs-hook candidate-C path (only
  proven-by-equivalence in CI, its input to the hook being identical to the landed non-gated seed) works
  for real. **Story 10 (15-min patience) PASS, twice:** (a) a near-AP backup rode out an app_limited
  pause → committed; (b) the winning resume rode through a MULTI-MINUTE DEVICE-SIDE pause — the tool
  blocked with zero transfer while the device recomputed the delta of a 61 % partial against the
  ~133 k-file base (netmuxd heartbeats stayed healthy → device alive, just busy) — and quince held
  `active`, NO false kill, then it resumed. Strongest liveness demonstration yet: a 30 s tool timeout
  (pre-patch) during that device-side pause is exactly what would have tripped a spurious `-4`.
  **Story 9 (the bad-link `-4`) — the HONEST BOUNDARY, characterized:** in a marginal bedroom spot the
  backup `-4`'d repeatedly with WILD variance (48 s/0 %, 31 min/61 %, 34 s/0 %) — the variance itself is
  the tell (an unstable link, not a deterministic bug; (ct)'s "failure timing varied" again). The patched
  receive timeout does NOT cure a `-4` from a genuine connection drop (a `-4` is an SSL-layer error that
  fires immediately on the reset, independent of the timeout) — BUT it dramatically extended survival
  (48 s → 31 min) AND the kept-dirty-working RESUME accumulated progress ACROSS attempts to a complete,
  committed 13-min backup once the phone was stationary. **Resume-to-completion proven end-to-end** (fail
  → resume → 61 % → resume → success), dataset clean (`latest/` only) after. **Root cause diagnosed live
  (Operator + implementer): band roaming.** The bedroom sits at the 2.4/5 GHz range boundary, so band-
  steering FLAPS the phone between bands (confirmed BOTH directions via the router's client list — band +
  a ~2-min reconnect age coinciding with each failure); each flap resets the mux TLS connection → `-4`.
  Corroborated by netmuxd reconnect bursts at each failure and `Heartbeat(SleepyTime→Timeout)`. Phone-
  sleep (`SleepyTime`, the nightstand doze) is a secondary contributor. **THE PROTOCOL FLOOR (analyzed,
  canon for qn.7):** a dropped mobilebackup2 session CANNOT be rescued in-flight at ANY layer — TLS
  session state is bound to the dead connection (netmuxd re-announces but a fresh mux channel can't carry
  the old TLS session; TLS has no mid-stream reconnect), and mobilebackup2 has no session-reattach.
  Recovery is ALWAYS a new backup request that resumes the on-disk snapshot (kept-dirty-working, no
  re-transfer) + an iOS per-backup passcode re-prompt. "Survive a roam in-flight" is off the table for
  everyone (us, libimobiledevice, netmuxd); "auto-resume after it" is the only path. **quince behaved
  correctly throughout:** honest `-4` messages (never "exit status"), kept-dirty-working with the
  last-good version noted, `active` liveness through every legitimate pause (no false kill), clean commit
  → `latest/`-only. **qn.7 items surfaced, now well-characterized:** (1) AUTO-retry on drop/reconnect so
  the accumulate-to-completion is automatic, not babysat; (2) `-4`→`connection_lost` reclassification
  (#8) so a Wi-Fi drop reads honestly, not as a hard `failed`; (3) the passcode-window question — does a
  retry inside iOS's recent-unlock window skip the prompt? (decides seamless-vs-one-tap for auto-retry);
  (4) a definitive netmuxd-DEBUG + pcap of roam-vs-signal-vs-sleep as qn.7 chaos input (offered, not
  taken tonight); (5) network mitigation (stable band for backups) documented HONESTLY as a workaround,
  NOT the primary answer (band-steering is standard; the product must survive it via auto-resume). **NET:
  qn.6b delivers on real hardware** — fast passcode (C), pause-tolerance + extended survival (the
  timeout), device-pause patience (the retune), and resume-to-completion (kept-dirty-working). The
  bad-link `-4` is a well-scoped qn.7 problem, not a qn.6b defect. Lab debt CLEARED; next is the CODE
  FREEZE + PROCESS REVAMP, with qn.7 (Wi-Fi hardening) carrying the auto-resume + reclassification work.
- 2026-07-25: (dn) **ARCHITECT REVIEW of the qn.6b lab session ((dm)): validated and landed
  (`5e92a7b`); the (dh) story-9 contingency is formally DISCHARGED — the freeze is unblocked.**
  The session proved everything qn.6b built (candidate C on the real hook with a `SHARED` seed
  during the gate hold; the 18-min patience holding `active` through a multi-minute device-side
  delta-recompute — the strongest liveness demonstration to date; resume-to-completion
  accumulating a committed backup across `-4` attempts) and — the part that earns the "tough
  season" — characterized the one thing the patch was NEVER mechanically proven to fix. **The
  spec's honest-residual framing is vindicated exactly as written ((dh)):** the `-4` from a
  genuine connection drop is not cured by patience (an SSL-layer reset fires regardless of
  timeout), and the session went further than the spec asked — root-causing it live to band
  roaming at the 2.4/5 GHz boundary and establishing the PROTOCOL FLOOR (no in-flight rescue
  exists at any layer; recovery is always resume). **The (dh) contingency ruling — "if story 9
  fails, finishing the same defect continues the (de) insert" — is DISCHARGED, not invoked, on
  its own premise:** the insert bar is a defect that STOPS DAILY USE, and the session showed the
  residual defect no longer does — it is location-conditional (a marginal band-boundary spot),
  survival extended ~40× (48 s → 31 min), every failure lands honestly with a one-tap Retry
  ((dd) UI) that accumulates to completion, and two clean commits happened the same night from a
  normal spot. What remains is a HARDENING gap (babysat retries in marginal spots), which is
  qn.7's charter by definition — and the soak will measure its real frequency, which is exactly
  the evidence qn.7's auto-resume design wants. qn.7's sharpened scope (auto-retry-on-reconnect +
  resume, `-4`→`connection_lost`, the passcode-window question, the roam-vs-sleep chaos capture,
  network workaround documented as workaround) is ratified as banked in the roadmap. Dashboard
  row tidied (two stale "owed" phrases). **The pre-freeze board is CLEAR — the next act is the
  CODE FREEZE + PROCESS REVAMP**, with the app soaking on a build whose transport story is now
  hardware-proven end to end.
- 2026-07-25: (do) **The 2026-07-24 storage-thread discussion BANKED (the space-scare's productive
  tail): the `zfs-native` lifecycle is now epic-(cl) candidate mode #8; the clone-promote/
  snapshot-as-latest alternative recorded beside it; the cp-would-not-help/births-not-sharing
  fact added to the (dl) stack note.** Chain of the discussion, for the record: the (dl) send-cost
  finding → Operator asked whether a genuine `cp` seed would spare the replica (NO — send size is
  driven by block births, not physical sharing; both cp and reflink mint newborn trees per
  generation; reflink is origin-side-win, send-neutral; levers = retention / replica-side
  `dedup=on` / content-addressed channel — now in stack D5) → Operator asked whether the newest
  snapshot could BE the mounted read surface (possible; clone-promote is the full form; rejected
  for THIS topology: per-backup privileged mount choreography through host→LXC→OCI, EXDEV seeding
  from snapshot mounts (gate-12 measured), unprivileged `.zfs` automount minefield — recorded in
  the epic block as the harder-rejected sibling) → Operator proposed the straightforward
  backup-over-live-dataset model (SOUND on zfs: no seed latency, delta sends, honest accounting,
  Finding-B-moot, CoW-free version isolation; costs: re-splits the unified lifecycle — the
  portable exchange model stays the floor for non-snapshotting backends and the qn.6b gate stays
  THEIR answer; `.zfs` browse becomes load-bearing (probe); epic-scale) → ruled ((dn) confirming
  the discussion): does NOT meet the insert bar, home = the multi-storage epic as a first-class
  MODE, with a btrfs-native twin noted for DSM. Nothing pre-freeze changes; the soak + qn.7's
  chaos work feed the mode decision with real evidence.
- 2026-07-25: **pr.3 LANDED — the agent instructions, the six workflow skills, and the layered
  permission allowlist, as three bot-authored PRs reviewed and rebase-merged the same day
  ([#7](https://github.com/novkostya/quince/pull/7) → `637bf06`,
  [#8](https://github.com/novkostya/quince/pull/8) → `52adf48`+`b1d607c`,
  [#6](https://github.com/novkostya/quince/pull/6) → `6df2461`; `main` linear,
  `43136ec..6df2461`). This is the FIRST date-anchored entry: letters
  are retired from here on** — `(a)`–`(do)` stay forever as citations, and new entries cite PR/issue
  numbers, which GitHub allocates race-free. #6 rewrites `CLAUDE.md` into the standing instructions
  (project shape; the forge-as-substrate workflow — fresh clone per unit of work, small PRs with one
  reviewable claim, approver-never-author, the DoD; issue homes; the durable hard rules, now
  including *interface facts and version pins are looked up live, never remembered*; the
  resurrection test). #7 adds `/onboard` (the resurrection test as a command, and the only
  model-invocable one, so "continue quince" self-onboards), `/kickoff`, `/report`, `/review-pr`
  (with `all`), `/land`, and `/qa` — the last a labelled placeholder, since the ruled dev-container
  deploy needs pr.2/pr.4 and inventing a deploy URL is exactly the lie state honesty forbids. #8
  commits the generic allowlist plus the reference environment under convention names only
  (`quince-pve`, `quince-dev-N`), with real addresses binding per-machine in the gitignored local
  layer; denies mirror branch protection and keep credential-file contents out of transcripts. Two
  self-corrections during the build, both from checking instead of remembering: the bot DOES have
  push on this repo (R1's recorded one-repo scope had decayed once the devlog existed), and a
  blanket force-push deny would have fought the routine amend-a-PR-branch flow. **The architect
  review caught one blocking regression that the self-corrections did not**: #6's product-shape
  summary described the pre-qn.5b reflink-*mirror* storage model and carried a stale `work/<job>`
  path plus a "browse never reads the head" line that qn.5b falsified — written by summarising the
  OLD `CLAUDE.md` instead of reading design §5, on the very rung whose thesis is that agents read
  canon. Fixed against §5 as landed (one lifecycle; per-job `working/<udid>` seeded reflink→copy,
  never hardlink; commit = verify → `renameat2(RENAME_EXCHANGE)` → snapshot/archive; `latest/` as
  both offsite surface and the browse root of the newest version; dirty-working kept on failure;
  seed sentinel; roll-forward) with an explicit §5 citation so the next editor is pointed at the
  source, not the summary. Two rulings folded in during review: **`quince-bot` now has write on
  quince-devlog** (journal entries are implementer output by design, so the journal is part of the
  bot's workspace — `/report`'s access probe absorbs it with no skill change), and the
  suggestion-turned-amendment steering runtime-equipped workstations to move the broad
  docker/nerdctl grants into their local layer. Owed: a cleanup PR here stripping this repo's
  program doc of the retired process loop (worktrees / rsync / commit-when-asked — `CLAUDE.md` wins
  on process meanwhile), Operator-approved since it is architect-authored; the flake filed as
  [quince#9](https://github.com/novkostya/quince/issues/9) (`TestStorySingleFlight` leaves its
  second job running, so `t.TempDir` cleanup races a live writer — found by CI on a docs-only diff,
  deliberately not fixed inside a process PR). Friction notes: nine items in
  [devlog#1](https://github.com/novkostya/quince-devlog/issues/1) — token scope vs `gh pr edit`, the
  decayed access record, the program-doc contradiction, a proposed DoD refinement naming the two
  legitimate non-URL deploy outcomes, identity separation being discipline rather than structure
  until pr.5, and the strict-checks + dismiss-stale-reviews tax that makes a stack of N sibling PRs
  cost N re-approvals.
- 2026-07-26: **pr.2 LANDED — `devct`, the dev-container toolkit, as six bot-authored PRs across one
  night ([#10](https://github.com/novkostya/quince/pull/10) spec →
  [#12](https://github.com/novkostya/quince/pull/12) API core + `doctor` →
  [#13](https://github.com/novkostya/quince/pull/13) `bin/gh-bot` →
  [#14](https://github.com/novkostya/quince/pull/14) template generator →
  [#15](https://github.com/novkostya/quince/pull/15) lifecycle →
  [#16](https://github.com/novkostya/quince/pull/16) onboard + the allowlist swap). A stranger with a
  Proxmox box now runs `devct onboard`, `devct-template build`, `devct create`, and has a container
  that reaches a green gate ladder in ~3 minutes.** The rung's thesis was the spec's token-first
  amendment — attempt everything on the scoped token, take root only where the API demonstrably
  refuses — and the measured verdict is sharper than either side predicted: **the entire permanent
  root surface of the system is one four-command block at `versions.env` cadence.** Create,
  provision, convert, destroy and the whole everyday path are scoped-token; G2 was run from a
  session holding no root path to the hypervisor at all, so "no root" there is structural rather
  than promised, and reproduced independently by the architect (181 s vs 194 s to a green ladder).
  **The privilege model, measured rather than recalled:** `SDN.Use` on the bridge; `Datastore.Audit`
  *and* `AllocateTemplate` on the **vztmpl** storage (downloading a template and consuming one at
  create are different permissions, and neither belongs on the rootfs storage — a zfspool cannot
  hold `vztmpl` at all, which invalidated the first grant and the check that blessed it);
  conversion needs **no additional privilege**; `Pool.Allocate` remains masked-not-measured and is
  labelled as such in the code. **Two things forced root, both discovered by running:** `keyctl` is
  `root@pam` by design, so no ACL can ever grant it; and the Alpine appliance ships no sshd, which
  **falsifies R3's "the box is born reachable"** — born with a key is not born reachable. `pct exec`
  joined the standing root class by Operator ruling (bounded to pool-verified vmids during template
  builds), keeping Alpine everywhere for dev/staging parity. A verified no-root alternative was
  recorded rather than taken: `termproxy` answers 200 on the scoped token. **Interface facts banked:**
  `api_host` must be a name the API certificate carries (`api_addr` binds it via `--resolve`;
  an address there fails verification, and `-k` is mechanically banned by the shell gate); Alpine's
  `buildkit` ships only the daemon, `buildctl` is its own package; the container-to-template flag
  lands asynchronously, so verification polls. **The recurring defect of the rung, worth naming:**
  *a claim printed without checking the thing it claims* — a refusal handler that dropped the API's
  own message, a `done.` after one command of four ran, a verify that failed on a template it had
  just built, an ssh-include write that reported a path it had left empty, and — the sharpest —
  `no root was used.` as an unconditional `printf` on runs where root ran four commands. Each fix
  turned an assertion into a measurement; the last one now generates G1's evidence itself.
  **`make gates-sh` earned its place on its maiden run** (shellcheck + a `curl -k` ban), catching an
  `eval`-based config parser and, later, three separate prose-backtick bugs — one of which was
  *live*, executing `apk info -L buildkit` on the session host from inside an unquoted heredoc.
  **`bin/gh-bot` closed the last escalation class**: `Bash(gh pr *)` was allowlisted yet every
  bot-authored `gh` call still prompted, because an allow rule never matches past a leading
  `VAR=value` — and each escalation lost its result on the way back, which produced one stale
  "still open" claim about work already done. The wrapper opened its own PR as its own proof.
  **Owed, each cheap and each needing architect access:** the `--skip-keyctl` measurement (if the
  toolchain does not need the flag, half the root block disappears), `Pool.Allocate`'s
  revoke-and-retest, registry-credential injection (G4), the stamp-mismatch branch, and a
  systematic POSIX-prefix pass over shell helpers (the shared-namespace clobber was fixed where it
  bit, not eliminated). Next: pr.4 (the `/report` deploy hook, which retires the `/qa` placeholder),
  pr.5 (runner host), pr.6 (lockout).
- 2026-07-26: **pr.4 LANDED — `dev-deploy`: a PR now carries a working demo URL and a walked
  click list without anyone asking, as three PRs
  ([#17](https://github.com/novkostya/quince/pull/17) spec →
  [#18](https://github.com/novkostya/quince/pull/18) the `devct deploy` verb →
  [#19](https://github.com/novkostya/quince/pull/19) `/report` by default, `/qa` replaced, the DoD
  naming both non-URL outcomes).** `devct deploy` fetches a ref onto a disposable dev container,
  builds **the production image** there (QA against a different artifact is QA of something nobody
  ships), serves it in `--demo` mode replacing any previous deploy, and **polls `/api/health` until
  it answers before printing anything**. Measured: **222 s** for a first deploy on a fresh container
  (cold image build), **5 s** for a warm re-deploy. **The URL question was ruled before code
  existed** — R5 wants the URL in the PR, privacy forbids an address in PR text — and the answer is
  the convention name (`http://quince-dev-N:8080/`), which carries no site information and is
  satisfied *by construction* rather than by a reviewer catching a leak. **Amended after the first
  implementation (Operator):** the address the tool prints leads, because on the LAN it needs no
  setup and **`ssh -L` is the one path that does not scale to parallel rungs** — every container has
  its own `8080`, so N deploys are N addresses while N tunnels collide on the local port; the tunnel
  is the address-free fallback for a reader who has the alias but not the LAN, never a requirement.
  **Four defects found by running rather than reading, none of which review would have caught:**
  `ssh -n` — the pr.2 fix for "ssh eats a loop's stdin" — applied to the two calls whose stdin *is*
  the payload, so the remote shell got nothing, exited 0, and the image build silently never
  happened; `localhost` resolving to `::1` past nerdctl's IPv4-only port proxy, which reported a
  dead demo that was serving perfectly **and would have broken the ruled `ssh -L` command from the
  other side**; Alpine's sshd shipping `AllowTcpForwarding no`, so the ruled click path was **broken
  at the daemon on every container** (fixed in the template, and `devct create` retrofits containers
  cloned from an older one, saying which it did); and `SC2087` — an unquoted ssh heredoc expands
  every `$` client-side, which works by luck until the remote script wants a variable. **The rung's
  own signature defect recurred and was promoted to canon:** a container resolver that returned
  empty for both "none running" and "several running", so `deploy` printed *no running dev
  container* while two were up and offered a fix that would have created a third. That is the sixth
  instance across pr.2/pr.4 of **a message naming a condition nobody checked**, and it is now a
  program-doc rule with its four earned corollaries and the test that makes it usable — *could this
  message print unchanged in a situation where it is untrue?*
  ([devlog#5](https://github.com/novkostya/quince-devlog/pull/5)). **G3 made the rung prove itself:**
  #19 carried a URL produced by the machinery, with every click-list line walked
  (`needs_setup` → setup 200 → the demo device with its real model/OS → `POST /api/jobs` 202,
  `auto` resolving to `usb` → job `backing_up` at 52%), and stated plainly that the demo behind it
  is byte-identical to `main`'s because the PR changes no product code — the URL is evidence about
  the *machinery*, not about a change to click. **Owed:** nobody has looked at rendered pixels (every
  step went through the API over a tunnel); `--hosts` is unexercised; `deploy: unavailable —
  <reason>` has never been emitted by a real `/report` run; and pr.2's four measurements still need
  architect access (`--skip-keyctl`, `Pool.Allocate`, registry injection, the stamp-mismatch branch).
  Next: pr.5 (runner host — where this loop stops depending on a laptop staying awake), then pr.6
  (lockout).
- 2026-07-26: **pr.5 CODE LANDED — the runner exists, is provisioned, and reports honestly that it
  is waiting for the one thing no script can do
  ([#21](https://github.com/novkostya/quince/pull/21) spec →
  [#22](https://github.com/novkostya/quince/pull/22) preflight + service + provisioning →
  [#23](https://github.com/novkostya/quince/pull/23) stand it up). The GATES ARE OWED:** G2/G3/G5/G6
  all need a live Remote Control session, which needs the Operator's `claude auth login` — measured,
  not assumed: a `setup-token`/`CLAUDE_CODE_OAUTH_TOKEN` credential **cannot establish Remote
  Control at all** ("requires a full-scope login token"), so the interactive step is the only path
  and there is no headless variant to find. **Re-checking R6 against the live docs before speccing
  confirmed three facts and corrected three**, one of which would have shipped a runner unable to do
  the only thing it exists for: `ANTHROPIC_BASE_URL` pointing anywhere but `api.anthropic.com`
  disables Remote Control (so the structural guard needed a third assertion R6 never named); the
  token-credential fact above; and a ~10-minute network outage **exits the process**, which makes
  supervision a correctness requirement and means a restart registers a **new** session — agreeing
  with rung-loop's fresh-session resume *by construction* rather than by reconciliation. **Two more
  corrections came from the box rather than the docs:** Alpine ships **OpenRC with no systemd**, so
  the spec's "systemd unit" would have been a file nothing on that host could run (`rc-service`
  present, `systemctl` absent, `supervise-daemon` available); and Alpine is a supported platform
  with a **signed apk repository**, so provisioning verifies the signing key against its published
  checksum and refuses on mismatch instead of `curl | bash`, with `USE_BUILTIN_RIPGREP=0` set
  because on musl the bundled ripgrep is unused and its absence surfaces later as search silently
  returning nothing. **The rung's own defect class recurred twice more, both caught by running:**
  `rc-service status` reported `started` while the supervised process crash-looped on *"You must be
  logged in"* — true of the supervisor, false of the question anyone is asking — so the service now
  overrides `status` (supervisor-up-but-NO-SESSION, exit 1; stopped, exit 3); and then the fix for
  that **failed to reach the box it fixed**, because `provision` installs the service from the
  launchpad clone, which tracks `main`. A fix on a branch cannot reach a box on `main`, so
  `provision` now prints `service installed from <sha> (<branch>)` and warns when the installed file
  predates the override. That second one was surfaced by an architect incident worth recording: the
  runner was destroyed by testing its own destroy-guard **from `main`, where the guard does not
  exist** — a mistake that produced a defect nobody would otherwise have found, because nobody
  re-provisions an already-working box. Protocol fix owned by the architect: `/review-pr` must say
  *run the head under review*. **Owed:** the ceremony (`claude auth login`, workspace trust, the two
  `/config` push toggles), then G2 (session reachable from a phone), G3 (restart registers a new
  session — **and count the picker entries before and after**, still unmeasured), G5 (`--force`
  destroy, unexercised because the only instance is the real runner), and G6, which closes the rung:
  an implementer loop run entirely **from** the runner, which is also the moment identity separation
  stops being discipline and becomes the machine. Next: pr.6 (lockout), which now inherits a written
  constraint — the root-capable path reaches the runner **only** as a forced-command wrapper, two
  command shapes, pool-verified, never a general root key.
- 2026-07-26: **The architect gets its own box, and the loop gets its event source — six PRs after
  pr.5's first three ([quince#25](https://github.com/novkostya/quince/pull/25) spec,
  [#26](https://github.com/novkostya/quince/pull/26) the arch role,
  [#27](https://github.com/novkostya/quince/pull/27) tag-based guards,
  [#29](https://github.com/novkostya/quince/pull/29) `gh-arch`,
  [#30](https://github.com/novkostya/quince/pull/30) spec drift, and
  [#28](https://github.com/novkostya/quince/pull/28) `forge-watch` for
  [devlog#4](https://github.com/novkostya/quince-devlog/issues/4)). Both boxes exist and refuse each
  other's identity; the ceremony is still the only thing left in pr.5.** [devlog#7](https://github.com/novkostya/quince-devlog/issues/7)'s
  finding was a boundary rather than a symmetry: pr.5's win is that the *implementer* identity
  becomes structural by living on a machine, and an architect session needs a credential that can
  **approve** — one box holding both means `approver ≠ author` degrades from a property into a
  convention about which token a session picks up. **The mechanism is an inversion:** `preflight`
  asserts the bot token is PRESENT on the runner and ABSENT on `quince-arch`, enforced where the
  service starts rather than where someone provisioned it, and proven by the refusal (a planted
  token → exit 1) rather than by the pass. `devct create --role arch` injects nothing;
  `devct destroy` protects persistent boxes by a **PVE tag** rather than a hard-coded name, because
  a name list drifts the moment a third box exists and reading a role over ssh fails exactly when a
  box is down — which is when a destroy is most likely to be the mistake. **Defects found by
  running, several inside the mechanism built to prevent them:** `create` injected the bot token
  onto the arch box and that box's own preflight refused to start (the guard worked, the path
  feeding it did not); the drift reporter added one PR earlier **invented drift**, announcing a
  newer version on a box already ahead of it, so the comparison now belongs to `apk`, which owns the
  version scheme; the first destroy guard protected *everything*, including disposable containers,
  because role and persistence are different axes I had conflated; and `forge-watch`'s truncation
  warning fired **every tick**, which is the silent cap re-created through boredom — a consumer
  learns to filter an unconditional warning, so it now fires only when the window's oldest row is
  still open. **`forge-watch` itself is a pure `step(state, observation) → events` with a thin
  fetch**, which is what finally makes a monitor testable: five fixtures, including the two recorded
  regressions from the night the monitors failed. Its own worst bug was the class it exists to
  prevent — a failed fetch was indistinguishable from a legitimate observation, because piping `gh`
  into `jq` yields *jq's* exit status, so a missing wrapper emitted `first-observation count=`
  forever while looking healthy. It now emits `fetch-failed` with a reason and writes no state.
  **Also fixed: the specs named a service manager the boxes do not have** — six places across two
  specs still said systemd after the build correctly landed OpenRC, including a gate telling a
  reader to run `systemctl status` on a host without it, and rung-loop's supervision design, which
  would have reached code. **Owed:** the ceremony (both boxes, one sitting), then G2/G3/G6/G8/G9;
  pr.0b is ruled and the arch credential is placed; [quince#31](https://github.com/novkostya/quince/issues/31)
  records a second timing flake, proven by the same commit failing and passing.

- 2026-07-26: **The revamp's session hosts are live, and the ceremony taught three gates the docs
  did not have.** Both boxes hold Remote Control sessions: `quince-runner` (implementer) and
  `quince-arch` (architect), each refusing the other's credential at service start. The Operator's
  login worked first time; everything that *looked* like an auth failure was a later gate —
  a respawning service fighting the interactive login, workspace trust presented by the TUI as a
  sign-in screen (auth was provably fine: `claude -p` answered from that same directory), and a
  one-time `Enable Remote Control? (y/n)` consent that a supervised daemon can never answer (it
  persists once accepted). All three are filed as
  [#33](https://github.com/novkostya/quince/issues/33). Completing the second box also found a real
  bug — [#32](https://github.com/novkostya/quince/issues/32): `provision --role arch` writes the
  role to conf.d but the init script never exports it, so preflight ran as the default role and
  demanded the bot token that box must never hold. Every component was correct; nothing told
  preflight what kind of box it was on, and the arch path had never been exercised. A temporary
  export is in place on that box and must be removed by the fix.
  ([#32](https://github.com/novkostya/quince/issues/32),
  [#33](https://github.com/novkostya/quince/issues/33),
  [devlog#10](https://github.com/novkostya/quince-devlog/issues/10))

- 2026-07-26: **The public docs stopped reading as a lab journal, and no decision left with the
  voice.** [quince#11](https://github.com/novkostya/quince/issues/11) part 1, in two slices. The
  README's status line and **Why** now address a visitor instead of the project — process-speak
  ("hardware-proven", "under real daily use") became what works, on what, and what is still
  missing, and the first Why bullet stopped being anchored on one maintainer's history with a
  desktop app over SMB ([quince#39](https://github.com/novkostya/quince/pull/39)). The canon docs
  state their reasons without citing a maintainer's homelab as design authority
  ([quince#42](https://github.com/novkostya/quince/pull/42)): `ui.design.md`'s `Taste references
  (Operator-supplied)` became a `Visual target` section describing the QUALITIES the named apps
  stood for, and stack.md's four framing spots — the lab-journal intro, D1's family argument,
  D5a's motivating case, D12's litmus test — lost the person and kept the argument. **The bar
  ("re-voice, never delete") caught two things the diff would not have:** every concrete spec the
  taste-reference list carried had to move into the qualities, because §4 and the Conventions
  gloss both point at that list; and `mercury` was DEFINED only in the bullet that went away
  while stack D7 still cites it as the `@mercury-fx/ui`-not-consumed record, so D7 took the gloss
  and keeps the name. Kept deliberately: the role-noun citations ("Operator ruling", "the
  Operator's lab box" for a non-CI gate), which name who decided and who owns a gate. Part 2 —
  the public README with screenshots and quickstart — stays with qn.6 per the issue's own ruling.
  **The privacy sweep is the one gate an implementer session cannot run here:** no private layer
  on the box, so `make privacy-check` exits 0 having grepped nothing, both PRs shipped with that
  box unticked and the sweep declared, and the supervisor ran it from the host that holds the
  pattern list. Filed rather than folded in:
  [quince#40](https://github.com/novkostya/quince/issues/40) — stack.md still tells an agent a
  decision is reopened by "the Operator saying so in chat", a channel that stopped carrying
  authority at `pr.0`.

- 2026-07-26: **One `internal/backup` flake fixed and landed; the other's category fix was found
  INCOMPLETE in review, by a reproduction the implementer could not get — and the load that
  reproduces them all turned up two findings that are not flakes.**
  [quince#9](https://github.com/novkostya/quince/issues/9) is done and merged
  ([quince#36](https://github.com/novkostya/quince/pull/36)): `TestStorySingleFlight` leaves a second
  device's job running, and **waiting for that job would not have closed it** — `run()` emits the
  terminal row, THEN discards `working/`, and only frees the per-UDID slot on its way out, so
  terminal state is not the quiescence signal. The file already half-knew this
  (`startWhenReleased`'s note about "the brief single-flight window between a job's terminal row and
  the release of its per-UDID slot"), so the fix went into the harness — drain the engine, fail
  loudly if it will not quiesce — closing the class rather than the instance. Reproduced at
  `-count 50` first attempt; green at 50, at 100 under contention. Review caught it working under
  fire: two tests died mid-story with jobs live and **no run produced `directory not empty`**.
  [quince#31](https://github.com/novkostya/quince/issues/31) took two passes. The implementer could
  not reproduce it (the CI load profile reproduced exactly — `deviceops` 34 s, `httpapi` 17 s — but
  the package finished in 9 s and the named test passed 20/20 at 3× oversubscription), shipped a
  category fix — waits measure a **no-progress window** rather than a wall clock — and declared in
  the PR that the mechanism was unconfirmed. **The architect then reproduced the original failure at
  that head, under load**: `no progress for 10.001s … phase=waiting_for_passcode`. The window is
  stronger than a budget only in phases that emit progress signals; `waiting_for_passcode` emits
  none by design, so there it degenerated back into the very budget being removed. The second pass
  mirrors the engine's own rule instead of inventing one — `sampler.sample` already grants grace
  "before the FIRST sign of life (a re-exec / process startup can take longer than a short timeout),
  or while paused for the passcode" — so the harness grants it in the same four phases and still
  guards `receiving`, the only phase where stillness is diagnostic
  ([quince#37](https://github.com/novkostya/quince/pull/37), merged `eb0150f`).
  **The process is the story:** the PR declared its own weakest link, the review aimed at exactly
  that link and broke it, and the result is better than either party had alone. **Two findings that
  are not flakes**, both filed rather than folded in, because the product is frozen and the branch
  was test-only: [quince#35](https://github.com/novkostya/quince/issues/35) — `CancelJob` cancels the
  job context, `cmd.Start()` then fails with `context canceled`, and `supervise` returns
  `outcomeProcErr` **without consulting `killReason`**, so a user who presses Cancel is told the
  backup *failed*, quoting an internal context; the engine checks kill-reason-first in both
  `awaitDevice` and `runToolLoop`, and this one path skips it. The **architect's** ruling on quince#35
  (2026-07-26 10:46:25Z — rulings post under the `novkostya` login, so the role is named here
  rather than inferred) confirmed it against source, found a **second** call site the report
  missed (`superviseGatedSeed`, the common path for a cold backup since qn.6b), and scheduled it
  to stay filed while the freeze holds and go early once it lifts. **The Operator then ruled it
  fixable during the freeze** ([#35 comment](https://github.com/novkostya/quince/issues/35#issuecomment-5084066861),
  2026-07-26 15:09:53Z): a cancel reported as a failure corrupts the soak's own record, so an
  instrument that miscounts failures during the measurement period damages the very thing the
  freeze protects — **a freeze concern rather than an exception to it**, product code by explicit
  authorisation, with the freeze otherwise standing, the four owed items still open, and the work
  sequenced after the process rungs (quince#43, quince#41/quince#44, quince#45). That reasoning
  was the authorisation for this whole day's work and it reached the session before it reached
  the forge; it is recorded here only now that it can be cited, which is the standard this entry
  set for itself. And
  [quince#38](https://github.com/novkostya/quince/issues/38) —
  a **third** instance of quince#9's shape: `succeed()` writes the terminal row and calls `AnnounceBackup`
  *after*, so a test reading the announce at terminal loses the race; measured pre-existing (`main`
  3/60 under load, the branch 1/20, the same rate). Three tests now caught assuming the terminal row
  means the work is finished — a pattern in the engine's shape, not three coincidences.
  **Ordering, discharged on the record:** quince#9's 2026-07-25 ruling reserved it as the first
  post-freeze item; the Operator confirmed on quince#9 at 11:16:25Z that today's `/kickoff` was his
  instruction and deliberately discharges that reservation, with the four unfreeze items
  ([quince#32](https://github.com/novkostya/quince/issues/32),
  [quince#33](https://github.com/novkostya/quince/issues/33), `pr.6`,
  [devlog#4](https://github.com/novkostya/quince-devlog/issues/4)) still open and still gating. The
  implementer declined to cure the gap by restating the instruction itself — a bot repeating an
  instruction is not a record of it being given — which is the state-honesty rule applied one step
  further than the protocol asked. **The privacy gate failed the same way here as in the docs pass
  above**, from the opposite end of the project: neither the runner nor the arch box holds the
  pattern list, so `make privacy-check` exits 0 having grepped nothing. quince#36's sweep was
  finally run from the private-layer host at approval, and quince#37's at its final head before
  landing — both clean, zero findings. Two sessions independently
  hitting the same wall on the same day is what moved it from a footnote to filed work
  ([quince#41](https://github.com/novkostya/quince/issues/41),
  [quince#44](https://github.com/novkostya/quince/issues/44)). **Also filed from this cycle:**
  [devlog#15](https://github.com/novkostya/quince-devlog/issues/15) — merging a parent PR
  auto-closes its stacked children and reopening is refused twice, which nearly cost quince#37's review
  thread; and [quince#43](https://github.com/novkostya/quince/issues/43) — the watch loop cannot see
  a push, green checks after a fix, a comment, an unchanged verdict, or a mergeability transition
  caused by someone else's merge, which is why both PRs sat unmergeable with neither author nor
  reviewer told. ([quince#36](https://github.com/novkostya/quince/pull/36),
  [quince#37](https://github.com/novkostya/quince/pull/37),
  [quince#35](https://github.com/novkostya/quince/issues/35),
  [quince#38](https://github.com/novkostya/quince/issues/38))
- 2026-07-26: **The loop's event model was itself the bug — an enumeration is a claim about what can
  matter, and this one deadlocked two agents on each other for over two hours while both watches
  reported healthy.** [quince#43](https://github.com/novkostya/quince/issues/43) and
  [#16](https://github.com/novkostya/quince-devlog/issues/16), in six PRs. Four blind spots meet on one
  transition — *changes requested → fixed → awaiting re-review*: a push is not an event, green checks
  were **deliberately** not an event, a comment is not an event, and `reviewDecision` does not move
  across a fix. The implementer waited for a re-review, the architect waited for an event, and no event
  existed or could exist. **The design note's own reasoning is preserved verbatim next to the fix**,
  because it is the transferable part: *"red is what changes who must act"* is true while a PR awaits
  its FIRST review and false the moment it awaits a RE-review, and the classifier has no notion of
  turns. The fix does not teach it turns — it adds a backstop that does not classify: **any movement of
  a PR's `updatedAt` emits `updated`, unconditionally and alongside whatever typed event also fired**,
  because a backstop that only fires when the classifier came up empty inherits the blindness it exists
  to cover. It names WHO as well as WHEN, attributed only from acts newer than the previous observation,
  and says `actor=unattributed` rather than naming a bystander
  ([quince#48](https://github.com/novkostya/quince/pull/48)).
  **A fifth blind spot is not covered by the backstop at all**, and saying so corrected the brief: a PR
  made `BEHIND` or `DIRTY` because something **else** merged has had nothing happen *to it*, so its own
  `updatedAt` never moves — the architect's own merges silently invalidate every other open PR. That
  needed its own typed signal, and review then found the mirror defect in it: `UNKNOWN` was treated as
  "no answer" for reporting and then **stored** as though it were a state, so `BEHIND → UNKNOWN →
  BEHIND` re-announced a condition that never changed. Pinning it needed a fixture shape that did not
  exist — three ticks through one state file — since **a pair whose `before` already holds the
  carried-forward value asserts the behaviour it was meant to test.**
  **The load-bearing assumption got measured rather than believed.** *A push moves `updatedAt`* is what
  carries the green-after-fix transition, and it is unobservable after the fact because a merged PR's
  `updatedAt` is pinned to its merge. The first two attempts were confounded by the author commenting
  ~40 s after pushing — including a watcher armed specifically to measure it independently, which
  printed a confident *"updatedAt MOVED with the push"* while its own caveat about checking for a
  comment in the window sat on the line below: **corollary (f) committed by the instrument built to
  check it.** It is now measured twice, in two repositories, by two methods, by two parties, with the
  channel that would have invalidated both — **a body edit moves `updatedAt` and produces no timeline
  event at all** — found and closed on both. The silence paid a dividend: three check runs started
  during it and `updatedAt` did not move, so the volume argument is an observation, and the commonest
  real source of `actor=unattributed` here is **an author ticking a checklist box**.
  **Restart safety, and a check that could only pass.** The requirement as first written said *detect a
  state file with no watcher and re-arm from it* — and the state lived in the **session scratchpad**,
  which the very failure it defends against destroys. It would have reported success by looking in an
  empty room. State moved to a session-independent path, and `status` grew from three cases to four:
  `live` · `dead` (nothing running — re-arm, do NOT reseed) · `absent` · `wedged` (a process **is**
  running and has stopped ticking). The fourth was a review finding against the PR's own stated
  principle — `dead` and `wedged` shared an exit code and an identical *"re-arm from this state"* note
  while needing opposite remedies, so the duplicate watcher was not an unlucky race but **the designed
  path, reached by doing what the tool printed** ([quince#49](https://github.com/novkostya/quince/pull/49)).
  Liveness takes two instruments because neither suffices alone: a heartbeat cannot see a watcher that
  died a moment ago, a pid cannot see a wedged one — and the first pid check grepped
  `/proc/<pid>/cmdline` for `forge-watch` and **reported success for the shell that had just run it**.
  **Then the same class produced the only defect that could have hurt something outside the repo.**
  `wedged` is *defined* by the heartbeat being stale — and the heartbeat was the only thing tying that
  pid to our watcher, so the one state where the tool issued an imperative to signal a process was the
  one state where its identity was unproven. Review demonstrated it by writing a foreign pid into the
  state: **the tool said "pid 1 IS STILL RUNNING … STOP IT FIRST" — it told the reader to kill init.**
  The watcher now records its process start time beside its pid, and `forge-watch stop` re-reads it at
  the moment of the signal; every branch that cannot prove the identity refuses and says which. It is a
  **verb rather than two steps joined by prose** for this unit's own reason: a session following *"stop
  that pid, then re-arm"* literally, on a box where the pid had been recycled, had no defence at all.
  And the fix **states its own limit** — verify-then-signal is two syscalls with a gap, the race cannot
  be closed from userspace, and what the verb buys is the window shrinking from *however long a session
  takes to read a sentence and act* to microseconds behind a refusal
  ([quince#56](https://github.com/novkostya/quince/pull/56)).
  **The watch set stopped being a habit.** *"Both repos, every time"* was right for a day and stale the
  moment a third mattered, so it is a versioned file that **hard-fails when missing, empty or
  malformed** rather than falling back to one repository — the exact shape of #3. Under `--all` every
  event names its repository, because PR numbers collide across repositories by construction. Review
  then found what the hard-fail cannot catch: **a stale set fails none of those tests** — it parses, it
  is non-empty, and it confidently describes yesterday — measured on a box whose launchpad predated the
  file entirely. So pulling the launchpad is part of arming the watch, not housekeeping
  ([quince#51](https://github.com/novkostya/quince/pull/51), ordering owned by
  [quince#33](https://github.com/novkostya/quince/issues/33)).
  **The skills were the other half.** `/kickoff` §5 was headed *"Plan, then stop"*; it said "otherwise
  start building" in its last line, and the heading is the instruction that landed — three Operator
  nudges across two models and two clients, which makes it the skill and not the model. It is now
  *"Plan, then proceed"*, with a new §6 for the half that never existed: after opening PRs the session
  does not end, and **"I finished a PR" is not a stop**. `/architect` §6 stopped specifying properties
  and named the mechanism — a background watcher over `forge-watch tick`, with `ScheduleWakeup` demoted
  to a ≥1200 s fallback whose first job on firing is a liveness assertion
  ([quince#52](https://github.com/novkostya/quince/pull/52), [quince#56](https://github.com/novkostya/quince/pull/56)).
  **Canon took three corollaries and a rule** ([#20](https://github.com/novkostya/quince-devlog/pull/20)):
  a ruling recorded on the forge is overridden only on the forge, by its owner, and is cited by
  **comment URL and self-declared role** rather than by login, since the architect and the Operator are
  one identity ([quince#47](https://github.com/novkostya/quince/issues/47)); **(e)** a watcher's event
  model is itself a claim about what can matter, so a parked PR is re-examined every tick; **(f)** a
  timestamp says WHEN and never WHO; **(g)** *a check whose positive answer can be produced by the act
  of asking is not a check*. That PR earned three citation defects of its own before it landed — a quote
  no reader could reach, a victim cited as if it were a finding, and an attribution to the wrong role,
  all inside the PR installing the rule about citations.
  **The tally is the argument, and it is stronger than any single defect: every party to this unit
  committed the class it was fixing, inside the instrument or the process they were using to fix it.**
  A measurement that named the actor it expected; a pid check that matched the act of asking; a re-arm
  check that could only look in an empty room; a reviewer who armed watchers on the two PRs he was
  driving and left the parked one unwatched; a queue watcher with an invisible approval; a shell
  pipeline read for the wrong command's exit status, **twice, by both parties**; an author who moved a
  head out from under a ruling and an approval. That is not carelessness — it is the evidence that this
  class is not defended by care, which is the whole thesis.
  **Owed, and declared rather than faked:** G2/G3 — a real session killed mid-watch, and the two-box
  coroutine end to end — because **both boxes must pull the launchpad and restart before any of this is
  live**, and the pull alone flips `bin/forge-watch` while the skills need the restart, so the runbook
  must treat those as two moments ([quince#33](https://github.com/novkostya/quince/issues/33)). Nothing
  in the unit was argued from either session's own behaviour: both ran the pre-#43 copies throughout.
  Filed for later: [quince#50](https://github.com/novkostya/quince/issues/50) (nothing stops two
  watchers on one state file; `dead` is a judgement),
  [quince#53](https://github.com/novkostya/quince/issues/53) (`/onboard` still enumerates by hand),
  [quince#54](https://github.com/novkostya/quince/issues/54) (nothing detects drift between the shared
  protocol and the commands inlined in the skills — the named cost of that trade, now tracked),
  [quince#55](https://github.com/novkostya/quince/issues/55) (retiring a session flushes to the forge,
  not to its successor), [quince#57](https://github.com/novkostya/quince/issues/57) (`waitCeiling`
  reached in CI: a job stalled in a grace phase is bounded only by the 2-minute backstop — a
  composition defect descended from quince#37, filed by the reviewer who approved it).
  *(Corrected 2026-07-26, in the entry immediately below: quince#57 is **not** a composition defect and
  quince#37 is not its ancestor — quince#37's grace-phase composition is correct, and its disputed
  assertion that reaching the ceiling is always a bug held. The cause is
  [quince#59](https://github.com/novkostya/quince/issues/59), a lost update that overwrites the
  terminal job row. Annotated rather than rewritten: this entry is citable, and a log that edits
  itself breaks the thing citations rest on.)*
- 2026-07-26: **The CI flake was the product lying about a failed backup, and reproducing it before
  fixing it is the only reason anyone knows that.**
  [quince#57](https://github.com/novkostya/quince/issues/57) reported
  `TestFailedBackupReportsTheDeviceReason` hitting the 2-minute `waitCeiling` on a docs-only PR, and
  offered two candidate mechanisms to choose between. It is neither. Under load — 16 CPU busy-loops,
  4 concurrent copies of the test binary, `-race`, on a 4-vCPU container host — it reproduced **4/4**,
  and three narrowing observations killed the guesswork: during the hang there is **no fake child
  process** and the engine's pipe fds are already closed; a SIGQUIT dump shows **no `Engine.run`
  goroutine at all**, only the test polling `store.GetJob`; and an `UpdateJob` write trace catches the
  terminal write succeeding (`rows=1`, `err=nil`) and then a stale `backing_up` write — which
  **entered 22 ms earlier and completed 1.3 ms later** — overwriting it. `Engine.progress` and
  `Engine.transition` copy the row under `lj.mu` but **persist outside it**, into a blind full-row
  `UPDATE` on a `SetMaxOpenConns(1)` store, so writes serialize in connection-acquisition order
  rather than mutation order; nothing joins the sampler goroutine, which `runToolLoop` only asks to
  stop. A failed backup then reports `backing_up` **permanently**, in the DB and on the event stream.
  Filed as [quince#59](https://github.com/novkostya/quince/issues/59) and **not fixed** — it is
  product code, the product is frozen, and there is no honest test-only alternative: every
  test-side workaround (poll the in-memory row, watch the bus, relax the assertion) works by making
  the test blind to a real durability bug. **quince#37's disputed assertion — "reaching the ceiling
  is always a bug, never load" — turns out to be exactly right**, and the grace-phase composition it
  was blamed for was never at fault; it only removed the *other* bound, which is why this surfaced
  here. A published blast-radius claim was **corrected in place after checking it**: `succeed` is
  buffered by the whole of verify+commit, so the damage concentrates on the failure/cancel/timeout
  terminals — the backup that fails is the one that lies about it.
  **Landed** ([quince#61](https://github.com/novkostya/quince/pull/61)) is the issue's separable
  second defect, test-only: a wait now names *which* bound ended it instead of reporting "no progress
  for 0s" while failing for a stall, and `describe` carries `engine_owns`, the one field that
  separates a stuck run goroutine from one that finished and left a row disagreeing with it — quince#59's
  fingerprint, previously obtainable only with a SIGQUIT dump. **The review is why it is worth
  anything:** the first version tested the message as a pure *formatter*, with the mechanism string
  handed in as a literal, while the code that *decides* which string reaches it was hand-threaded
  through two near-identical loops and guarded by nothing — undeclared debt, and therefore a finding.
  Discharged by deleting the duplication rather than declaring it: one `waitTracker` owns both bounds
  and the mechanism, and `awaitTerminal` takes the ceiling as a **parameter** (not the reviewer's
  suggested package `var`, which would be process-global mutable state in a file whose tests share a
  process — a correction the architect adopted), so a test drives the real loop to the ceiling in
  200 ms instead of two minutes. The reviewer's exact mutation now fails with exactly the text they
  predicted **while the formatter test still passes**, which is the finding made executable. 320 runs
  under the quince#57-reproducing load: zero failures.
  **Found on the way and filed, not folded in:**
  [quince#60](https://github.com/novkostya/quince/issues/60) — a cancel arriving during process
  startup terminates the job `failed` with Go's `context canceled` as the *user-facing* message,
  because `supervise` returns the start error without consulting `killReason` the way `runToolLoop`
  does; reproduced **18× on clean `main`**, so it predates this work.
  **Process:** [devlog#22](https://github.com/novkostya/quince-devlog/issues/22) — `/kickoff` §1's
  `issue view --comments` prints *nothing* and exits 0 on an issue with no comments, because
  `--comments` replaces the body rather than appending; a silent success that is indistinguishable
  from having read everything, warning about exactly the mistake it causes. And
  [devlog#23](https://github.com/novkostya/quince-devlog/issues/23) — `gh pr edit` is unusable for
  `quince-bot` (it resolves org-scoped reviewer fields even for a body-only edit); `gh api -X PATCH`
  needs only `repo`, and the narrow token scope is the point, not the bug.
  **[quince#44](https://github.com/novkostya/quince/issues/44) bit twice in one PR, on both boxes** —
  neither the implementer nor the architect can run `make privacy-check`, so the box stayed unticked
  and the supervisor swept from the host holding the pattern list, twice, the first claim expiring
  when the review fix moved the head.
- 2026-07-26: **The rewritten loop shipped a watch that could not wake anybody, and an arming step a
  session could simply skip — one mechanism defect and one honour-system defect, in the same hour, on
  opposite boxes.** [quince#62](https://github.com/novkostya/quince/issues/62). The architect armed the
  loop its own skill printed — `while :; do forge-watch tick --all; sleep 60; done` — and **a session is
  woken by a background task COMPLETING**, so a loop with no exit condition detects everything and
  delivers nothing. quince#61 opened at `19:07:16Z`; the session's last activity was `18:21:38Z` and a
  human ended the stall fifty minutes later. Every instrument was green throughout: fresh heartbeat,
  both state files rewritten every 60 s, `status --all` reporting `live`. Corollary (g) inside the
  mechanism built to eliminate it — and what it degraded to is the sharp part: **the twenty-minute poll
  this rung existed to replace, wearing the new mechanism's clothes.** A first correction claimed the
  fallback heartbeat had bounded the stall; the architect's own instruments then disproved that
  **three times, and a fourth after the count was published** — `ScheduleWakeup` armed and due at
  `18:41`, `19:40`, `20:03` (then `20:31`), session idle each time, invoked none of them — so there was
  no floor at all. An hour later the implementer half
  produced the complement: checked structurally against its transcript, **no watcher, no state file,
  no `ScheduleWakeup` — zero**, ending a turn on *"the ball is back with the reviewer"* four minutes
  before its verdict landed. Both stops were named illegitimate **by the skill the session was
  following**, the second in a section rewritten to prevent the first. **Landed:**
  [quince#63](https://github.com/novkostya/quince/pull/63) makes the loop the tool's own verb —
  `forge-watch watch` exits on the first wake-worthy event, treats the baseline (`first-observation`
  and the `queue-empty` beside it) and a lone `fetch-failed` as non-waking, prints every tick
  regardless (**the filter decides what wakes, never what is seen**), refuses to arm beside a `live` or
  `wedged` watch so §4c's four answers are enforced where they are acted on, and carries its own
  `--max-wait` floor because termination is now the only thing that wakes anything. Self-caused wakes —
  about a third of the architect's — are **not** suppressed, deliberately: a suppression rule would be
  a fresh claim about what cannot matter, which is §4b's defect again. **The fixture had to assert
  termination, not health**, because every health fixture in the directory passes on the deaf watcher;
  its teeth are stated oddly on purpose — against the hand-rolled shape the positive fixture does not
  *fail*, it **hangs**, so the harness bounds each loop fixture with `timeout` and says so when
  `timeout` is missing. **A defect in that PR was found by arming it for real rather than reading it:**
  re-arming from a `dead` watch emits `tick-overdue` *by definition*, so every re-arm woke once for
  nothing, reporting as news the gap the arming step had announced one line earlier — the fixtures the
  author had just written all passed while it was broken, and the reviewer's own live run had missed it
  too (a 35 s gap against a 60 s interval). **Then
  [quince#66](https://github.com/novkostya/quince/pull/66)**: a verb that terminates correctly does
  nothing for a session that never runs it, so `forge-watch owed` asks whether open PRs here have no
  live watch and a **`Stop` hook** runs it when a turn ends — **blocking once** with the exact command,
  then, on a second attempt, telling the *human* instead. The two rejected shapes were rejected on
  structure: *"opening a PR arms the watch"* **cannot work**, because only a task the session itself
  launched can wake it, so a process forked by a `gh` wrapper would be armed, ticking, `live` and deaf —
  the same bug one layer down; and *"a channel that needs no arming"* is right and is the **runner
  dispatcher already in the spec**, which needs the runner unit and is named rather than built. The
  general shape is worth keeping: **a rule that tells a session to do something is satisfied by a
  session that does not do it, and nothing observes the difference** — corollary (g) applied to arming
  instead of to checking. **What made both PRs trustworthy was running the harness, not reasoning about
  it:** the hook was proven by a headless session in a never-trusted workspace that was told *"reply
  with the single word PING and do not use any tools"* and **tried to arm a watch instead**; exits 6
  and 7 were confirmed to be rendered to a session as *"failed with exit code 6"* when 6 is the
  designed heartbeat; and two documented facts turned out wrong under test — the published `Stop` hook
  config example omits the nesting the real schema requires (the first probe silently never ran), and
  `"hooks": {"Stop": []}` does **not** disable a project hook because hooks merge (`disableAllHooks` is
  the switch, and it is all-or-nothing). **Found and filed, not folded in:**
  [quince#64](https://github.com/novkostya/quince/issues/64) — `forge-watch replay` is the spec's G1
  and is run by **no gate and no CI job**, so every round of this work has proven it by hand and pasted
  the output, which is the honour system this repository keeps filing issues about.

- 2026-07-26: **The loop's sixth blind spot was in a justification, not in code: an approved PR whose
  CI then finishes is invisible, and that is where PRs spend most of their waiting.**
  [quince#65](https://github.com/novkostya/quince/issues/65), filed by the architect against its own
  conduct after [quince#63](https://github.com/novkostya/quince/pull/63) sat **approved, green,
  mergeable and unmerged for sixteen minutes** behind a live, quiet watch. Both halves were then
  measured live on [quince#66](https://github.com/novkostya/quince/pull/66) rather than reasoned about,
  in a window with no push, comment or review: `updatedAt` **frozen** at `21:07:11Z` across fourteen
  samples while `image` and then `e2e` completed; and — after an approval landed at `21:14:47Z` with CI
  still running on a freshly pushed head — `ms=BLOCKED … BLOCKED … CLEAN at 21:19:39Z`, with
  `updatedAt` **never moving**. So the unenumerated `updated` backstop, built so that *nothing is
  invisible*, is **structurally blind** to the moment a PR becomes landable: nothing happens *to* the
  PR, which is exactly why its timestamp does not move. **The cause was not the rollup lag the issue
  named as its leading candidate.** `event=checks` fires only on `FAILURE`, deliberately, and the note
  justifying that narrowing read *"the push preceding those checks moves `updatedAt`, so `updated`
  carries the transition"* — true for changes-requested → fix → green, **false for approved → CI
  completes**, where the last mover was the approval and it happened first. Nothing malfunctioned;
  there was no fault to reproduce, which retired the issue's first ask and made the fix a one-line
  widening. **Landed:** `mergeability` — the channel already built for *"its own `updatedAt` did not
  move and its landability changed"* — now reports the transition **into `CLEAN`** beside `BEHIND` and
  `DIRTY`. Not a new event type, and deliberately **not** "emit on green": green is not *someone must
  act*, since every PR reaches it while still awaiting first review, and which of the two it means
  depends on whose turn it is. **A transition, not an every-tick re-examination**, because an author's
  own PR goes `CLEAN` and they cannot merge it — approver ≠ author — so a repeating signal would spin a
  watch that exits on detection into arm-exit-arm. **It does not retire corollary (e):** it mechanises
  the *CI* park, the only one where a field moves; a park on a human decision moves nothing and is
  still story 6 (`stalled`), unimplemented. **Two fixtures, because one is the trap:** a pure fixture in
  that area already passed while the live path delivered nothing for sixteen minutes, so a
  `"kind": "loop"` fixture drives the real verb across three ticks with `updatedAt` identical
  throughout. Teeth measured: against the classifier as it stood the pure one emits **nothing at all**
  and the loop one runs to its idle bound — the sixteen-minute silence, reproduced in twelve seconds.
  An existing fixture gained a third expected line, from recorded data rather than a new claim, and
  **suppressing it because `review` fired in the same tick was refused explicitly**: "the other event
  carries it" is the exact reasoning that caused this bug. **One near-miss recorded because it was
  nearly written into canon:** a mid-CI reading of `BLOCKED` on a green-looking PR briefly looked like
  proof that `CLEAN` is never reached — it was the *previous* head that was green, and *"the field says
  BLOCKED"* and *"the field will never say CLEAN"* are different claims.
  **It then proved itself twice, in isolation, on the PRs that carried it.** quince#67 was approved at
  `21:31:24Z` with all three checks queued; the implementer deliberately posted nothing afterwards, so
  nothing could move `updatedAt` and mask the result — and the watcher woke with **one line and no
  other**, `event=mergeability pr=67 status=CLEAN`, at `reviews=1 comments=0` with `updatedAt` still
  sitting on the approval. On `main` as it then stood, that tick was silence. quince#68 repeated it
  unprompted an hour later, from merged `main`, which makes the fix's first ordinary beneficiary the
  very next PR through the queue. **Four occurrences in one evening** — quince#63 (the sixteen
  minutes), #66 (captured by sampling), #67 and #68 (emitted) — is the honest measure of how common the
  state is: every code PR in this workflow passes through approved-and-waiting-on-CI.
  **Reviewed rather than rubber-stamped, in both directions.** The architect ran the leg the
  implementer declared owed — the architect half of the arming gate, on an architect box — and found
  the hook printing the *implementer's* `--repo` form to the architect: a hint written to be copied
  verbatim that would have armed a watch smaller than the declared set, and whose resulting state then
  **satisfies the gate**, a check passed by obeying its own remedy
  ([quince#66](https://github.com/novkostya/quince/pull/66)). And it corrected an over-broad caveat in
  the implementer's own spec text: a watch armed after a PR went `CLEAN` misses it only on a **cold
  start**, because a re-arm from `dead` diffs against the stored observation rather than reseeding —
  and the terminating watcher makes re-arms the normal path, so the caveat described the rare case in
  language that read like the common one ([quince#68](https://github.com/novkostya/quince/pull/68)).
  **Filed for a ruling rather than improvised:**
  [P2](https://github.com/novkostya/quince-devlog/blob/main/proposals.md) — five instances across two
  nights, by both parties, of reading a *derived* signal instead of the one carrying the answer (two
  pipelines read for the wrong exit status, a fixture's teeth verified through `tail`, a `status | head`
  that manufactured an error from SIGPIPE, and a `BLOCKED` read off a stale head that nearly became the
  canon claim *"CLEAN is never reached"*). It is quince#65's own shape one level up, and it has now been
  written up five times as five separate confessions rather than once as a corollary.

- 2026-07-27: **The privacy gate could report a clean sweep it had never performed, and the fix was
  not the three-line hardening but the twenty-seven fixtures that assert it now fails.**
  [quince#41](https://github.com/novkostya/quince/issues/41), landed as
  [quince#73](https://github.com/novkostya/quince/pull/73) (`ff955e1`). `make privacy-check` printed
  `no local/privacy-patterns.txt (contributor/CI box) — skipped` and **exited 0**; a checklist cannot
  tell that from clean, so the gate ticked itself on precisely the boxes unable to sweep — which,
  once work moved off the Operator's machine, was every box where work happens. Every PR in the
  2026-07-26 cycle had to hand-declare *"the sweep did not really run"* to stop that `0` being read
  as clean. **Now three exit codes**, because *nothing matched* and *I did not look* are different
  facts: `0` clean, `1` violation, **`2` DID NOT RUN**. Also landed: a **whole-branch mode** —
  `--ref` sweeps the diff, every **commit message** and the branch name, `--text` sweeps PR text —
  which is the command `/land`'s *"re-check the whole branch before a merge"* had been instructing
  people to run without one existing; a second, **case-sensitively** matched list, since run wholesale
  under `-i` a pattern relying on case discrimination is not merely noisy but meaningless (the
  device-name heuristic had matched ordinary product prose in two consecutive sweeps); and a matcher
  that is **named, versioned and proven to compile** every pattern, with an optional canary proving it
  *matches* rather than merely parses. The logic moved out of the Makefile, because a recipe of
  backslash continuations can be neither shellchecked nor tested and here **the untested path was the
  entire defect**. **The fixtures are the deliverable, not the hardening.** Twenty-seven, each
  asserting an exit code *and* its reason, every one synthetic — own throwaway git repos, own fake
  pattern lists — so the failure mode of a gate only some boxes can run is testable on **all** of
  them, including CI and a contributor's laptop. Mutation-tested rather than trusted, seven mutants
  and seven caught, one of which restores the original silent skip verbatim. That repairs
  [quince#64](https://github.com/novkostya/quince/issues/64)'s class for this gate; the issue **stays
  open**, because `bin/forge-watch replay` is still run by nothing (measured at 23.4 s for 28
  fixtures, host-side, which is the answer that issue was waiting for). **Five defects in the change
  were found by running it rather than reading it** — two by the author before review, two by the
  architect's, and one by writing the fixture for one of the architect's: busybox's `unrecognized
  option` error reported *as a version string*; an empty scope called `clean`; an unterminated final
  canary line silently skipped **while `canary ok` printed**; `git log A...B` being a *symmetric*
  difference, so one `$REF` handed to two commands that read three-dot notation differently swept
  commits **not on the branch** — safe direction, but it fires whenever `main` is ahead, the normal
  state of a queued PR under strict up-to-date protection and the state `/land` deliberately creates;
  and a canary of only comments testing zero probes and still announcing success. Every one is the
  PR's own thesis violated inside its own implementation. **The most useful finding was not a defect
  at all: an agent measuring its own environment with its own tooling.** Both sessions independently
  reported *"`grep` in PATH is ugrep 7.5.0, `/bin/grep` is busybox"* and concluded three
  implementations were in play across the workflow — the architect wrote it into
  [quince#44](https://github.com/novkostya/quince/issues/44) as a standing fact about the boxes.
  `type grep` says **function**: the harness installs a `grep` shell function routing through a binary
  that bundles ugrep, and **ugrep is installed on neither box**. Two implementations actually run the
  gate — busybox on the boxes, GNU grep 3.11 in CI — and the suite is now green under both, by hand
  and then by the ladder. `type` before `--version`, whenever the claim is about a box rather than
  about a session. **Owed and not advanced:** quince#44's requirement 1 is **blocked on a ruling**,
  because its stated premise is false as measured — the bot token resolves exactly `quince` and
  `quince-devlog`, and `quince-local` does not resolve at all, so `provision` cannot clone what the
  issue says it should; since the artifact is *the list of sensitive strings*, choosing another
  transport is a security decision and three options are filed there rather than one being invented.
  The Operator still owes the two pattern-list edits this PR can only **enable** — the case-sensitive
  split, and the private layer's own path, so the symlink that *enables* the sweep stops being
  invisible to it. ([quince#73](https://github.com/novkostya/quince/pull/73),
  [#41](https://github.com/novkostya/quince/issues/41),
  [#44](https://github.com/novkostya/quince/issues/44),
  [#64](https://github.com/novkostya/quince/issues/64))

- 2026-07-27: **G1 had been run by nobody but its author, and the gate that fixed that shipped
  unable to see the suite shrink.** [quince#64](https://github.com/novkostya/quince/issues/64),
  landed as [quince#74](https://github.com/novkostya/quince/pull/74) (`250cbd0`).
  `bin/forge-watch replay bin/testdata/forge/*.json` is the rung-loop spec's **G1**, and neither
  `gates-sh` nor CI ran it: every round of `forge-watch` work proved it by hand and pasted the
  output into the PR. Honest exactly as long as somebody keeps doing it, and three of the loop
  fixtures spend real seconds in sleeps, which is the kind of cost that quietly stops being paid.
  **Now `make forge-watch-test`, invoked by `gates-sh`**, so all 28 fixtures run on every PR —
  and the issue's open question (*where do the loop fixtures belong, since they need a subprocess
  and a clock and cannot run inside the shellcheck container*) is answered by measurement rather
  than preference: **host-side, beside the containerised shellcheck**, 23.4 s locally and 22 s in
  CI, the same placement `privacy-check-test` took in [#73](https://github.com/novkostya/quince/pull/73).
  **The review found the interesting defect, and it was in the fix rather than the thing being
  fixed:** `forge-watch: fixtures pass` is not countable, so a suite that has silently shrunk
  passes — the architect removed the ten `watch-*.json` loop fixtures and the remaining eighteen
  still printed `pass`, while this same PR was writing *"all 28 fixtures"* into the spec, asserted
  by nothing. That is quince#73's third finding one level down (a canary that tested zero probes
  printing `canary ok`), and the sharpest part is **which** fixtures demonstrate it: the loop ones,
  whose cost the PR's own body had just named as the thing that stops being paid. So the fixtures
  likeliest to be dropped were exactly the ones the new gate could not see leave. Fixed by a counter
  and a `%d` — `forge-watch: 28 fixtures pass` — and **the fix makes a shrink visible, not fatal**:
  18 of 28 still exits 0, stated plainly on the PR so the approval could not be over-read. A
  hardcoded floor was considered and **refused**: a second number that must be bumped with every
  fixture added drifts stale, and a stale floor reads as protection while permitting the very shrink
  it names — this unit's defect class wearing a different hat, installed by the PR closing it. A
  second finding retired an overstatement rather than a bug: the `jq` guard had been offered as
  *"quince#41's lesson applied"*, but `make` returns its generic recipe-failure code for **any**
  failed target, so *did not run* and *ran and failed* are indistinguishable through it — measured
  both ways, both `2`. The distinction lives in the message, and the recipe now says so where the
  code is rather than only in a PR body. **A third thing was deleted rather than shipped:** a
  `[ "$_ran" -gt 0 ]` guard written while fixing the count, then removed on discovering it is
  **unreachable** — the dispatcher refuses an empty argument list (exit 1) and a glob matching
  nothing arrives as its own literal and dies in jq (exit 2), both measured. A guard that cannot
  fire reads as a safety net in review while asserting nothing. **Scope was flagged, not assumed:**
  the fix touches `bin/forge-watch`, which the unit's kickoff had fenced off; ruled in scope because
  the whole non-comment delta is four lines inside `replay()` — a counter, an increment and a
  `printf` format — with no event, classifier, tick or watch path touched, and because the offered
  alternative (counting the glob in the Makefile) would have counted *files handed over, not
  fixtures executed*. Both merges tonight landed on **`event=mergeability status=CLEAN`** rather
  than on anyone noticing, which is [quince#65](https://github.com/novkostya/quince/issues/65)'s fix
  earning its keep twice in one evening. G1 was afterwards re-run **from `main`, on a box that did
  not build it**, because *"it worked on the branch"* and *"it works from main"* are different
  claims and only the second is what the next session inherits.
  ([quince#74](https://github.com/novkostya/quince/pull/74),
  [#64](https://github.com/novkostya/quince/issues/64))

- 2026-07-27: **A suite written to prove `preflight` refuses things was itself reading the box it ran
  on — and mutation testing, used three times that evening to earn confidence, could not have seen
  it.** [quince#32](https://github.com/novkostya/quince/issues/32)'s residue, landed as
  [quince#76](https://github.com/novkostya/quince/pull/76) (`26194a9`). Two halves: `name="${RC_SVCNAME:-quince-runner}"`,
  because one file is installed as **both** `/etc/init.d/quince-runner` and `/etc/init.d/quince-arch`
  and a literal name meant `rc-service quince-arch status` answered about a differently-named service
  — on a two-box design whose whole point is that the boxes are not interchangeable; and `make
  preflight-test`, invoked by `gates-sh`, so the runner spec's **G1** — *"`preflight` against a table
  of environments"* — stops being proven by whoever remembers. That is the **third** honour-system
  gate closed in one evening, after [quince#41](https://github.com/novkostya/quince/issues/41) and
  [#64](https://github.com/novkostya/quince/issues/64); the ladder now runs 27 + 28 + 17 cases that
  a day earlier ran on nobody's authority but their author's. The suite asserts the **refusals**,
  deliberately: preflight exists to stop a runner coming up unable to do Remote Control, billing
  against an API key, or holding the identity of the box it is meant to be separate from, so its
  failure paths are its product — and each case asserts the **message** as well as the exit code,
  since preflight returns `1` for every refusal and the code alone cannot tell *you set an API key*
  from *this box holds the wrong identity*. **The defect the review found was in the harness, not the
  code under test.** `env FOO=1 cmd` **adds** to the caller's environment rather than replacing it,
  so the one case asserting a variable was *absent* did so by omitting it — asserting a property of
  the shell running the suite. The implementer's reported `13 passed, 0 failed` was true only because
  that box happened to have `QUINCE_RUNNER_ROLE` unset; the architect box exports it, and there the
  suite went red immediately. Worse than a red suite: with `ANTHROPIC_API_KEY` exported four cases
  failed, and **that is the variable this gate exists to refuse**, so anyone working with Claude would
  have had `make gates` fail on their shell rather than on their change. **A claim the *test* could
  not support** — the same shape the evening had been removing, arriving one layer out. Fixed by
  unsetting every variable `preflight` reads; the review's suggested list held **four** and the
  correct number is **six**, the two omissions both being credentials, established by building the
  suggested list and running it rather than by reading it (either missing credential still failed
  three cases). Four new cases now pin the isolation itself, and a later tidy collapsed two copies of
  the unset list into one `$PF_UNSET`, because the comment said *"must be added here"* while there
  were two heres and the isolation suite could not have caught the divergence. **The durable lesson,
  and the reason this entry exists rather than a PR thread:** *mutation testing proves a suite reacts
  to changes in the **code under test**, and says nothing about what the suite reads from **outside**
  it* — ambient environment, filesystem state, clock, network. It is blind to that class **by
  construction**, since every mutant runs in the same context as the baseline. Three of four mutation
  runs that evening were sound; the fourth was measuring a shell. A sibling failure the same night:
  two mutants reported "no failure" because busybox `sed` does not read `\t` as a tab, so the
  mutation never applied — **a mutant that silently fails to mutate is a green light nobody earned**,
  and a mutation must now be verified to have changed the file before its result is believed.
  **quince#32 stays OPEN on purpose.** This is its code half, not its proof: the check the issue
  actually asks for — start the service on an arch box from a clean `conf.d` and assert it comes up —
  cannot be run from a session hosted by the service `provision` restarts, and `devct` is not
  onboarded on the runner, so there is no throwaway CT either. That, plus both boxes still running an
  installed file older than `main`, is owed to the Operator's re-provision window and was declared on
  the PR so the merge could not imply otherwise.
  ([quince#76](https://github.com/novkostya/quince/pull/76),
  [#32](https://github.com/novkostya/quince/issues/32))

- 2026-07-27: **A box that cannot run the privacy gate now refuses to start — and getting there took
  three review rounds, every one of which found a claim the change made about itself that it had not
  established.** [quince#44](https://github.com/novkostya/quince/issues/44) requirements 2 and 3,
  landed as [quince#79](https://github.com/novkostya/quince/pull/79) (`a03fd0d`). Ruled by the
  Operator: **hard-fail now** rather than waiting on requirement 1, accepting deliberately that a box
  rebuilt before `provision` can place the layer will refuse to start — hand-placement is a step a
  rebuild needs anyway, and *a box that starts and silently cannot gate* is the worse failure and the
  one the issue was filed about. Two constraints came with it, and both are now **pinned by
  fixtures rather than honoured by memory**: the message **names the fix that exists at the time**
  (hand-placement today; correcting it to name `provision` belongs to requirement 1's PR, and the
  fixture asserting today's wording is what will fail and force that), and it **does not claim to
  know why** — a private repository 404s identically for *does not exist* and *not granted*, so a
  guess sends the next reader to recreate a repo when the fix is a one-click grant. That second one
  is asserted by an unusual fixture: it greps the refusal for `does not exist`, `lack permission`,
  `access denied` and **fails if any appear** — a test for what a message must *not* claim.
  **Round 1 found the change failing its own title.** A pattern list of only comments has bytes, so
  `test -s` passed it: the box came up asserting *"the privacy gate can run on this box"* while
  `privacy-check` returned **2** on the identical file, so every sweep afterwards would say DID NOT
  RUN. The fix was structural rather than a third condition — `preflight` now **runs the gate's own
  validator and takes its exit code**, because two implementations of one predicate about one file
  is how the two answers diverge. **Round 2 corrected an assumption stated as fact in two places and
  never run:** the claim that exit `1` *"cannot occur here — no `--ref` means an empty scope"*. No
  `--ref` means the **staged diff of the current directory**, and `preflight` inherits the service's
  cwd — `runner_dir`, the launchpad, a real repo sessions work in. An interrupted commit there made
  `preflight` refuse while the gate had just run perfectly, and print a fix telling someone to
  replace a **healthy** pattern list; in `start_pre` that is a box that will not boot, pointing at
  the one artifact that must not be casually replaced. Fixed with `-ne 2`, which is exact rather
  than a workaround: `0` and `1` both prove the gate ran, and `2` is the only code meaning *did not
  look*, which is the only thing preflight asks — quince#41's three-code contract used as designed.
  **A leak was caught while writing that fixture, and it is the more serious of the two:** on exit
  `1` the gate's stderr carries **the matched lines**, and `preflight`'s output goes to
  `/var/log/quince-runner.log`, so printing it would have had preflight publish exactly what the
  gate exists to contain. A fixture now asserts the matched string never appears in its output.
  **Two further defects were found in the fixing, both in text written hours earlier by the people
  reading it:** `privacy-check`'s absent-list message said the layer *"is placed by
  `deploy/runner/provision`"* — naming a capability nobody had built, the exact thing the ruling's
  first constraint forbids, in the file that exists to close that class; and the `grep -c` trap
  (prints `0` **and** exits 1, so `|| echo 0` fires too) was re-implemented one directory away from
  the comment warning about it. The architect recorded reading that first message during an earlier
  review and pasting its output into an approval without noticing: **reading output for *whether it
  refused* is not the same as reading it for *whether what it said is true*.**
  **Requirement 1 remains blocked, and the block is a measurement rather than a preference.** The
  ruling's rationale — *"both boxes already hold this file, so cloning adds no new exposure"* — is
  false twice over: the bot holds **`write`**, not read, so the implementer identity can weaken the
  pattern list that constrains it; and the boxes hold exactly one 107-byte file while the repository
  holds eight, ~600 KB, including four `chatgpt-*.md` transcripts that `CLAUDE.md` names as
  Operator-private and `.gitignore` carries a dedicated rule to exclude. `git clone` takes all of it.
  A narrow clone (`--filter=blob:none --sparse`) was proposed and **neither variant built**;
  escalated as a credential-scope question, which is the Operator's.
  ([quince#79](https://github.com/novkostya/quince/pull/79),
  [#44](https://github.com/novkostya/quince/issues/44))

- 2026-07-27: **The private layer became a property of the box, and the control protecting it had to
  be built in a different repository than the one it protects.**
  [quince#44](https://github.com/novkostya/quince/issues/44) closed by
  [quince#81](https://github.com/novkostya/quince/pull/81) (`6594c0b`), completing the pr.7 unit's
  fifth PR. `deploy/runner/provision` now clones `quince-local` in full, so a rebuilt box no longer
  returns silently to the state where the privacy gate could not run — the founding defect, where
  sessions had learned to trust a file a rebuild removed and nothing announced the regression.
  **Two Operator rulings, and their coherence is the part worth keeping:** the implementer keeps
  **`write`** on the layer because it is a living document an agent must maintain without the
  Operator becoming a required hop; and the transport is a **full clone** rather than a narrow fetch,
  because an implementer that can *write* `environment.md` but cannot *see* it reintroduces exactly
  that hop. The implementer had argued for a single-file fetch on exposure grounds and was **wrong
  about the shape of the problem**, having treated the two questions as separable. **One decision was
  made inside the ruling rather than inferred past it:** the credential is **role-dependent**, which
  the ruling could not have said — the arch box must never hold the bot token, since `preflight`
  refuses to start if it does and that inversion *is* the separation mechanism (devlog#7), so each
  box clones with its own identity. **The accepted exposure is now written where it will be met:**
  both boxes carry the complete private record — ~610 KB across 8 files, including lab topology and
  the external review transcripts — not the 107-byte pattern list. `CLAUDE.md` had said the layer
  *"exists only on the Operator's machines"*; that had stopped being true and is corrected in the PR
  that widened it, with `pr.6`'s credential-concentration boundary recorded as owed. **The residual
  risk drove the only genuinely novel piece.** Prevention is unavailable — branch protection on
  `quince-local` returns *"Upgrade to GitHub Pro or make this repository public"*, measured, because
  protection on private repositories is a paid feature — and narrowing was ruled out, so **detection
  was all that remained**, and `privacy-check` refused an EMPTY list while accepting a SHORTENED one.
  A trimmed list was silently as good as a full one, by the identity the list constrains. The fix
  puts the minimum count in **`quince`, which IS protected**: `deploy/privacy/patterns.floor`. A trim
  now fails the gate **on the boxes** until the floor is lowered — via the commit-time sweep a session
  runs, and via `preflight`, which delegates to `privacy-check` against the real layer. **Not in CI,
  which never sees the real pattern list:** every suite in the ladder runs against synthetic layers,
  and the `privacy-check` target that reads the real one is standalone rather than part of `gates`.
  A real control, then, but not an always-on independent one — which is the distinction a reader needs
  when weighing the residual risk. Lowering the floor is a reviewed
  change approved by somebody who is not the author — **the review model restored to the one artifact
  that cannot have it, without moving the artifact.** A count rather than a checksum, because a
  checksum fails on every legitimate edit until updated, which trains people to update it without
  looking. An absent or non-numeric floor is DID NOT RUN, never a pass: *a control that can be
  deleted to disable itself is not a control.* **The review's finding was one sentence, and it was
  the sentence doing reassurance work.** The floor's comment claimed a count *"only moves when the
  list shrinks, which is the only direction that weakens the gate"* — false, and measured before
  correcting: three real patterns at floor three catch a planted match, three JUNK patterns at floor
  three let the identical match through, same count, gate green. **Substitution weakens it identically
  and the floor cannot see it**, and the identity that can trim can equally rewrite. Under a ruling
  that says detection is all that remains, a sentence claiming the detector covers *the only*
  weakening direction tells whoever weighs the residual risk that it is closed. The file now states
  both what it covers and what it does not, and the canary — the natural detector for substitution —
  is recorded on quince#44's residual-risk register rather than built, because its probes must match
  the private patterns and would live in the same writable layer: the same problem one level down.
  **The coupling was caught by the suites rather than by anyone's foresight:** adding the floor broke
  `preflight-test`, because `preflight` delegates its verdict to `privacy-check`, whose synthetic
  layers carry one pattern against a real floor of nine — the read-the-box trap one delegation
  deeper, and `PRIVACY_FLOOR_FILE` became the ninth entry in the unset list that was made a single
  variable two PRs earlier for exactly this. **Owed and declared rather than implied:** `provision`
  has never been run end to end, because it restarts the service hosting the session that would run
  it; its arch branch is unexercised, there being no arch credential on the implementer box by
  design; and the `.superseded` rename — a hand-placed layer is moved aside, never deleted — is
  untested against a real one. All three are the Operator's re-provision window, which quince#79 made
  **more** consequential rather than less: once a box pulls the launchpad, a drifted layer refuses the
  next restart. ([quince#81](https://github.com/novkostya/quince/pull/81),
  [#44](https://github.com/novkostya/quince/issues/44))

- 2026-07-27: **The one control in this system whose correctness cannot be gated overstated its own
  reach twice, and both corrections cost a review cycle each — which is the argument for the control,
  not against it.** [quince#82](https://github.com/novkostya/quince/issues/82) closed by
  [quince#84](https://github.com/novkostya/quince/pull/84) (`0fe8fa0`). `deploy/privacy/patterns.floor`
  — the minimum-pattern-count guard that quince#44 put in the *public, protected* repo because branch
  protection is unavailable on the private one — said a trim *"fails the gate on every box **and in
  CI**"*. **CI never sees the real pattern list**, measured: `gates` runs `privacy-check-test`,
  `forge-watch-test` and `preflight-test`, all of which build **synthetic** layers by design, since
  that is what makes them runnable anywhere; the `privacy-check` target that reads the real list is
  standalone rather than part of the ladder; and nothing in `ci.yml` references the private layer at
  all. The floor bites **on the boxes** — the commit-time sweep before every push, and `preflight`,
  which delegates its verdict to `privacy-check` against the real layer at service start. A real
  control, and not an always-on independent one. **Synthetic layers are a property to state
  accurately, not a gap to close:** someone reading the old sentence could reasonably have filed
  *"make CI sweep the real list"* as a bug, and doing it would put the private layer in CI, which
  quince#44's own exposure discussion argues against. **This is the second false sentence in that
  file in two hours** — the first claimed a count *"only moves when the list shrinks, which is the
  only direction that weakens the gate"*, when substitution weakens it identically and invisibly
  (quince#81). Both were caught in review, both were measured before being corrected, and both were
  in the same comment block: the architect found the first, requested the fix, and **read past the
  second while doing so**, recording the lesson afterwards — *having found one false claim in a block
  is exactly when the rest of that block is most worth reading, and the instinct is the opposite,
  because the block feels handled.* It generalises past comments: a green re-run after a red, a suite
  passing once one fixture is fixed. **A neighbourhood that has just produced a defect is the least
  safe place to stop looking.** **Why two cycles for two sentences was the right price, and the entry
  that matters most here:** the floor's *value* has no test asserting it matches the real list, and
  **cannot have one** — a suite that checked it would have to read the Operator's layer, which is the
  thing the control protects. So the floor is the one guard in this system whose correctness rests
  entirely on somebody reading it. A file in that position cannot carry a sentence that overstates
  what it covers, because there is no mechanism downstream to catch the overstatement — which is
  precisely why each of the two was worth stopping for.
  ([quince#84](https://github.com/novkostya/quince/pull/84),
  [#82](https://github.com/novkostya/quince/issues/82))

- 2026-07-27: **Three documents described one tool's exits; none of them matched it, and they
  disagreed with each other about which parts they had wrong.**
  [quince#75](https://github.com/novkostya/quince/issues/75) closed by
  [quince#85](https://github.com/novkostya/quince/pull/85) (`ed88539`), landed **before the
  re-provision window** deliberately: skills load at session start, so a skill fix that lands *after*
  a re-provision means the box reboots into the old text, runs on it, and owes a second restart to
  make the fix live. **A maintenance window is the delivery mechanism for skill fixes**, and the
  cheapest moment to land one is just before a restart that is already going to happen. `bin/forge-watch watch` exits **1**
  when it REFUSES to arm — *"a watch is ALREADY LIVE … refusing to arm a second one"*, which is
  [quince#50](https://github.com/novkostya/quince/issues/50)'s guard working — and `/architect` §6,
  `/kickoff` §6 and `loop-protocol.md` all enumerated the exits as *0, 6 and 7* and said **"every exit
  is a re-arm"**. Followed literally on a refusal that is refuse → re-arm → refuse → re-arm,
  unbounded, **with no watch running throughout**; the architect hit it and escaped by noticing, which
  is not a mechanism. **Adding `1` would have fixed the instance and left the class**, so the fix
  asserts the relationship instead: `bin/forge-watch-exits-test`, run by `gates-sh`, **DERIVES** the
  designed exits from `bin/forge-watch` itself — the two functions whose returns become process exits,
  plus `die()` — **MEASURES** each by driving the tool into that state, and requires every one to be
  **DOCUMENTED** in every file that enumerates them. Against the pre-fix documents it fails naming
  exactly the missing codes: architect `1`, kickoff `1 3 4 5`, loop-protocol `1 3 4 5 7`. **The
  hypothesis the addendum was written on turned out to be wrong, which was the finding.**
  `loop-protocol.md` was expected to be the correct document the skills had drifted from. It was not:
  it is the *only* one that names the refusal in prose — and asserts "Every exit is a re-arm" two
  lines later, holding the fact and its contradiction adjacent — never gives the refusal a code, and
  omits **more** codes than either skill. There was no correct document. Reported on
  [quince#54](https://github.com/novkostya/quince/issues/54) with the table and the reason they are
  not three independent typos: the enumeration was copied between the skills and never re-derived
  from the tool, so a correction to any one would have left the others. **`/kickoff` was outside the
  addendum's scope and carried the defect twice** — the enumeration and a second standalone *"Every
  exit is a re-arm."* — and was fixed with the widening flagged rather than buried; the architect
  argued to keep it, since splitting would leave a known-false instruction live in the file
  implementers read. **The check's own first version passed on the broken documents** — it matched a
  bare digit, and every code occurs in these files as an issue number or a count — then went wrong
  twice more in the opposite direction; all three wrong matchers are recorded in the suite's comment,
  because the shape of the mistake is the reusable part. That was the fourth check-that-could-not-fail
  of the evening and **the first caught by its author before review**. **A governance boundary was
  drawn and then narrowed, and the narrowing is the durable part.** The architect **recused itself**:
  it had filed quince#75 *and* specified the fix, and the PR edits `/architect` SKILL.md — its own
  operating instructions — plus shared canon, so `approver ≠ author` read literally was not enough.
  The Operator's ruling: *a skill change governing the reviewer's seat needs the Operator when it
  alters what the reviewer may or must **decide**; a correction of fact about what a tool returns —
  verifiable against the tool, and carrying a test that fails when it drifts — is the architect's to
  approve.* **Approve it on the test, not on the filer's word.** The fixture is what moved this out of
  the governance path: a factual claim with a mechanical check behind it does not need the slower
  route, precisely because it can be verified without trusting either party.
  ([quince#85](https://github.com/novkostya/quince/pull/85),
  [#75](https://github.com/novkostya/quince/issues/75),
  [#54](https://github.com/novkostya/quince/issues/54))
- 2026-07-27: **The channel that carries authority in this project is an issue, and nothing watched
  it.** [quince#80](https://github.com/novkostya/quince/issues/80) half one, landed by
  [quince#87](https://github.com/novkostya/quince/pull/87) (`380c0d0`). `bin/forge-watch` observed
  **pull requests**; an Operator ruling is a comment on an **issue**. So a ruling could land and reach
  nothing, and the measured case is exact — the [quince#44](https://github.com/novkostya/quince/issues/44)
  ruling arrived while the architect's blocked list was quince#70/#71/#72/#75/#78/#80, most with no PR
  at all, and the only thing that caught it was, in that session's own words, *"a hand re-read I'd
  committed to when filing the issue"*. **A human-remembers mitigation, performed by an agent, at the
  head of the one channel that carries authority** — and it failed twice before it worked, producing
  two false statements about the item it had spent the evening reporting as blocking. Labelling
  rulings was rejected on the same grounds: it moves the remembering to whoever *writes* the ruling.
  A session now DECLARES what it is blocked on — `--issue`, self-describing in the way its PR set
  already is — and the declaration survives a re-arm without being restated, because forgetting to
  restate is silent and this project has four measured forgotten re-arms. **The two questions the
  ruling handed to the builder were decided rather than defaulted**, and both went against the
  obvious answer. A declaration **outlives** the session that made it, and the staleness is answered
  by `status` printing it **with its age** — dying with the session sounds tidier and is worse,
  because it forces a restatement whose omission is invisible; a *visible* stale declaration is a
  question a successor can answer. And a **close wakes** a session that declared the issue: the
  tidying argument does not reach an issue somebody said they were stuck on. **Declared issues are
  fetched one by one rather than filtered from a window**, since a window is a silent cap on the
  channel that carries rulings — and the cost is zero calls when nothing is declared, which is why
  every pre-existing loop fixture was untouched. **Its own fixture caught a defect before it
  shipped:** a failed `gh issue view` yields an observation with no entry for that issue, and writing
  that over the stored items threw the baseline away — so the next good tick would emit
  `issue-first-observation` and **swallow the comment that landed during the outage**. A ruling lost
  to a transient fetch error, on the channel built to stop exactly that; corollary (a) reached from
  inside the tool that enforces it, for the third time. **Review found the one thing the build
  missed, and it was this feature's own failure mode one level in:** a cross-repo `--issue` was
  *silently discarded* on the single-`--repo` path, where the per-repo filter that is load-bearing
  under `--all` was the only filter — so a declaration reached nothing and said nothing, and one
  unmatched spec replaced an existing declaration with an empty one, **byte-identical to
  `--no-issues`**. Fixed atomically, so a partly-valid list leaves no partly-applied declaration; the
  reviewer noted that was the failure mode rather than the example they gave. Fixtures **28 → 34**,
  `forge-watch-exits-test` **11 → 13**, both `--issue` refusals now measured by name. **Proven by
  running, not by argument**, which is the bar quince#62 and quince#65 both set by passing every
  fixture while the live path delivered nothing: three real comments on three real issues were
  detected and named with their actors, the two declared-but-quiet issues stayed silent, and — the
  part worth keeping — **the feature woke the session that was building it**, delivering
  `issue-comment issue=62 count=1` through the exact code path under review. **What is owed:** half
  two of the ruling (issues referenced by open PRs) is a separate PR, and measurement done while
  waiting inverts its obvious design — `closingIssuesReferences` alone covers only **9 of 25** PRs
  here, against **22 of 25** for the `#N`-in-title convention and **23 of 25** for their union
  (`gh pr list -R novkostya/quince --state all --limit 25`, run 2026-07-27T09:57Z; the two covered by
  neither are quince#34 and quince#30). **The command and the window are stated because the first
  version of this line said *10*, and review could not reproduce it** — a figure I counted by eye,
  inside an entry partly about claims made without checking. Recomputed in `jq` rather than
  recounted; the same wrong number had already propagated into a source comment in the half-two
  branch and was caught there before it landed. The load-bearing half was never in doubt and
  survives intact: link data alone would have missed **quince#87 itself**, whose body says *"Closes
  half one of #80"* — a phrase GitHub does not parse, because the keyword and the reference are not
  adjacent. No `"kind": "loop"` fixture exercises the issue
  path, `issue-reopened` has no fixture, and the fresh-session property of quince#62 remains
  unproven — one session throughout.
  ([quince#87](https://github.com/novkostya/quince/pull/87),
  [#80](https://github.com/novkostya/quince/issues/80),
  [#44](https://github.com/novkostya/quince/issues/44),
  [#62](https://github.com/novkostya/quince/issues/62))
- 2026-07-27: **An issue an open PR is *about* needs no declaration — and the tool found the bug in
  its own discovery rule by running as its author's live watch.** quince#80 half two, landed by
  [quince#89](https://github.com/novkostya/quince/pull/89) (`e2f6545`) with the follow-up
  [quince#91](https://github.com/novkostya/quince/pull/91). Half one was a *declaration*, so it was
  still something a session had to remember to do; the ruling said that is insufficient alone, and
  the ordinary case is why — nobody should have to declare the issue their own PR is for.
  **The discovery signal inverts the obvious design.** GitHub's own link data is the obvious answer
  and it is not enough: over 25 PRs here (`gh pr list -R novkostya/quince --state all --limit 25`,
  2026-07-27T09:57Z) `closingIssuesReferences` covers **9**, the `#N`-in-title convention covers
  **22**, and their union **23**; the two exceptions are quince#34 and quince#30. **The decisive case
  is quince#87 itself** — the PR that built half one. Its body says *"Closes half one of #80"*, which
  GitHub does not parse because the keyword and the reference are not adjacent, so its link data is
  **empty** while its title carries `(#80)`. A derived half resting on link data alone would have
  missed the very PR written to fix the issue. The **body is deliberately not scanned**: quince#87's
  cites eleven issue numbers, nearly all as history, and watching every issue a PR mentions is the
  wallpaper this classifier has already rejected twice — worse here than anywhere, because the
  channel's whole value is that an event on it means something. Discovery costs **no extra `gh`
  call**; two fields ride along on the queue fetch. **The defect it found in itself is the part worth
  keeping.** While the branch was running as the author's live watch it emitted `issue-fetch-failed
  repo=novkostya/quince-devlog issue=87 reason=GraphQL:_Could_not_resolve_to_an_issue…`: a devlog PR
  titled *"… a declaration now reaches it **(quince#87)**"* had made a naive `#[0-9]+` scan derive
  `quince-devlog#87`, which does not exist. That is
  [devlog#18](https://github.com/novkostya/quince-devlog/issues/18)'s class — **a cross-repo
  reference resolved against the wrong repository — reproduced mechanically by a regex**, and it
  surfaced as an event rather than as silence, which is the tool answering correctly a question it
  should never have asked. Two fixes, and the second is the more general: the scan now requires the
  `#` not to follow a word character; and **a failed read counts against `--fail-after` only for a
  DECLARED issue**, because a declaration is a *request* while a reference is *the tool's own
  inference*, and letting one bad guess exit the watch after three ticks is the tool punishing the
  session for its mistake. **The guard is verified to FAIL against the old regex**, not merely to pass
  against the new one — and that same run proves the second fix, exiting **6 rather than 7** as three
  referenced-read failures decline to kill the watch. Closing it also closed a gap quince#87 had
  declared as owed: the loop stub answered the Nth *call* with the Nth payload regardless of what was
  asked, so a tick making two KINDS of call fed a `pr list` an issue object and **no loop fixture
  could reach the issue path at all**. It now dispatches on argv with a queue per kind. **quince#91 is
  the tail, and it is a silent drop caught by review:** the class was `[^A-Za-z0-9_/-]` while the
  comment claimed word characters only, and the two extras were inert on every qualified form — each
  is blocked by the alphanumeric before the `#` — while costing `fixes #12-#13`, which derived
  **`[12]`** and dropped `#13` to a hyphen without a word. The no-silent-caps rule broken by a
  character class, on the channel that carries rulings. Measured both ways before changing it; the
  whole price is `docs/#5` now yielding `5`, which is not repo-qualified and so defensible. Fixtures
  **34 → 36**. **What is owed:** `issue-reopened` still has no fixture, the `#12-#13` case rests on
  side-by-side runs rather than a fixture and is declared as debt rather than implied as coverage,
  the union is unreconciled where its two signals disagree — reviewer and author both failed to
  construct a case where watching both is wrong — and quince#62's **fresh-session** property remains
  untouched: one implementer session throughout, though the architect has now run half one on a
  second box under a second identity, which narrows the box-and-identity part of that gap and leaves
  the fresh-session leg exactly where it was.
  ([quince#89](https://github.com/novkostya/quince/pull/89),
  [#91](https://github.com/novkostya/quince/pull/91),
  [#80](https://github.com/novkostya/quince/issues/80),
  [#87](https://github.com/novkostya/quince/pull/87),
  [devlog#18](https://github.com/novkostya/quince-devlog/issues/18))
- 2026-07-27: **An empty queue is not a legitimate finish for the reviewer, and the tool that said
  otherwise was faithful to the prose that was wrong.**
  [quince#71](https://github.com/novkostya/quince/issues/71) closed by
  [quince#96](https://github.com/novkostya/quince/pull/96) (`6372c8a`). `/architect` §7 named an
  empty queue as a finish, and `owed --all` derived its answer from that — the issue's own title is
  *"`owed --all` says yes because §7 does"*, which is why the tool moved with the prose rather than
  after it. **The asymmetry is the whole of it:** an implementer's set is what it AUTHORED and cannot
  change without it; a reviewer's set is what ARRIVES, so its work is done not when the queue is
  empty but when nothing further is coming — **and that is not knowable from inside the session.**
  So `owed --all` now returns the whole declared set unconditionally, with no queue query at all;
  `owed --author` is untouched. **Measured on both sides before it was ruled:** twice an architect
  overrode the gate, armed against its *"nothing owed"*, and a PR arrived within ~15 minutes
  (quince#69, quince#73); once an architect **obeyed** it, stopped on an empty queue, and went dark
  with the gate silent throughout because by its own definition nothing was owed. Two overrides that
  were right and one obedience that was wrong is a gate wrong in one direction only. The two halves
  now state different REASONS — `declared` versus `open PRs` — and that is not cosmetic: **a true
  verdict with a false justification is harder to catch than either error alone**, because the
  verdict looks right so nobody re-reads the reason. Review found exactly that surviving in the
  hook's headline, the single most-read sentence the tool emits, and a second copy one line further
  on in the escalation that reaches the **Operator** — where a reviewer blocked under this ruling may
  have no PR at all. Both are now neutral about *why*, and that is structural rather than a
  preference: **the defect existed because the reason lived in two places and only one was updated**,
  so switching the headline on mode too would have recreated the condition that produced it. A
  consequence worth having: `--all` no longer touches the forge, so the hook's reviewer path cannot
  be wedged by an unreachable one. **Its first production firing caught its own reviewer ninety
  seconds after it landed** — both queues empty, both watches dead, the state the change was written
  for, on its first opportunity. Also caught by running rather than by fixture: the new `owed`
  fixtures passed while the runtime wiring threaded the wrong mode, so the live answer still read
  *"open PRs"* — quince#62 and quince#65's shape, inside the tool built for it.
  ([quince#96](https://github.com/novkostya/quince/pull/96),
  [#71](https://github.com/novkostya/quince/issues/71),
  [#69](https://github.com/novkostya/quince/issues/69),
  [#73](https://github.com/novkostya/quince/pull/73))

- 2026-07-27: **A gate named in three skills could not be run in half the forge set, and had been
  complied with in words for as long as nobody tried it.**
  [quince#78](https://github.com/novkostya/quince/issues/78) closed by
  [quince#97](https://github.com/novkostya/quince/pull/97) (`3526539`). `report`, `land` and
  `review-pr` all named only `make privacy-check`, and **`quince-devlog` has no Makefile**. No
  Makefile was added there, per the ruling: it would exist to wrap one script, in a repository with
  no build, and be a second place for the invocation to drift from the tool. The devlog form is the
  product checkout's script run **from the devlog clone**, and two things about it were learned by
  getting them wrong in the same session: **do not pass `--patterns`** — it defaults to `./local`,
  relative to the *current directory*, and handing it a file rather than the directory produces a
  `2`, which is DID NOT RUN; and **`cd` to the repository being swept**, not the one holding the
  script, because `--ref` resolves against the current directory's git repo. **Which copy was chosen
  rather than defaulted**, since the ruling asked: the **work clone's**, because a stale
  privacy-check is precisely the one that exits `0` having checked nothing — the defect quince#41
  fixed — and the launchpad has been measured stale at a commit predating a file entirely
  (quince#33). The failure modes differ and that is the argument: a work clone's copy fails by *not
  existing*, which is loud; the launchpad's fails by *being old*, which is silent and looks like a
  pass. **A contradiction next door was fixed with it**, ruled in scope by review rather than assumed:
  `/kickoff` §6 said the gate *"prints `skipped` and exits 0 having checked nothing"* — the behaviour
  quince#41 removed — forty lines from §3 saying it exits `2`. Measured on a layer-less clone before
  correcting it: **exit 2**. One skill asserting both the pre- and post-fix behaviour of a tool is
  devlog#54's drift inside a single file, and landing a fix for *"the gate is unreachable"* beside
  *"the gate passes silently"* would have been the reported symptom left standing next to its cause.
  **And a reading habit became canon:** a clean sweep ends `swept branch-diff commit-message
  branch-name text`, and **that list is an assertion about coverage, not a formality** — `0` answers
  *did anything match*, only the list answers *was anything looked at*. Found because a failed rebase
  short-circuited an `&&` chain, the commit never ran, and the sweep reported clean, truthfully, over
  an empty branch; the reviewer had quoted the full list four times that day without reading it as a
  claim. That is quince#41's distinction one level up.
  ([quince#97](https://github.com/novkostya/quince/pull/97),
  [#78](https://github.com/novkostya/quince/issues/78),
  [#41](https://github.com/novkostya/quince/issues/41),
  [#33](https://github.com/novkostya/quince/issues/33))

- 2026-07-27: **Two boxes measured the same property of the forge and disagreed by 4×, and one of the
  numbers moved while it was being reviewed.**
  [quince#72](https://github.com/novkostya/quince/issues/72) closed by
  [quince#98](https://github.com/novkostya/quince/pull/98) (`d9b42ec`). The typed event and the
  `updated` backstop describe the **same act**, and the help text — where a consumer looks — said
  nothing about how they arrive. Ruled with a sharpening: *may* is too weak, so it says a consumer
  **must not rely on either ordering**, recorded as a property of **the forge** rather than of this
  tool — *GitHub's PR fields do not move atomically, and anything reading two of them and inferring
  an order is reading a race.* **What the unit added was the measurement, and then the measurement
  taught the lesson twice.** The runner counted 11-of-12 same-tick; that went into canon as *the*
  rate, and review supplied the other box's figure by the same method: **8-of-12, a 4× different
  split rate**. A consumer would have read ~8%, planned for it, and been wrong by four times on the
  box where a reviewer's own code runs. **That is quince#69's lesson — a measurement carries the box
  it was taken on — committed by the session that had written that sentence into a journal entry
  hours earlier, in an entry citing quince#69, which exists because the same mistake was made on the
  same pair of boxes.** Knowing a failure mode by name did not protect against it; what did was
  structural — the other box had the missing number and this one did not, so it could only have been
  caught there. Then it happened again in the other direction: the architect figure **moved from
  8-of-12 to 9-of-13 while the paragraph about it was under review**, because reviewing the change
  was itself a review delivery and landed same-tick. Canon nearly shipped a figure its own source had
  publicly withdrawn forty-five seconds before the push. So both figures are now **timestamped to the
  minute rather than dated** — `2026-07-27` is a day and this moved inside one — and **the spread is
  stated as the finding rather than either ratio**, with *do not average these*. A **bias present in
  both and in neither's favour** is recorded too: these count deliveries a watcher was **alive to
  observe**, and both boxes had unwatched windows, so both denominators are of observed acts rather
  than of acts — a caveat that does not shrink with more samples, because it is a property of how the
  sample is drawn. **The candidate mechanism was deliberately kept out of canon** and recorded on the
  issue with its falsifiable prediction: the reviewer's hypothesis is that the split rate tracks *the
  observer's temporal relationship to the act*, since on their box the observer is the actor. Canon
  asserting an unconfirmed mechanism is what this same session declined on quince#62 item 5, and
  doing the opposite the same day in the same tool would have made both decisions arbitrary. **No
  fixture, and none is possible:** the ordering is observed across watcher *generations*, which the
  pure fixtures cannot express, and a loop fixture staging two payloads would assert the stub's
  script rather than the forge's behaviour — declared as debt rather than dressed in a test that
  proves nothing.
  ([quince#98](https://github.com/novkostya/quince/pull/98),
  [#72](https://github.com/novkostya/quince/issues/72),
  [#69](https://github.com/novkostya/quince/issues/69),
  [#62](https://github.com/novkostya/quince/issues/62))
- 2026-07-27: **A safety argument was checked in the one direction that could not fail — and it was
  checked *before* being ruled, by the seat that ruled it.**
  [quince#100](https://github.com/novkostya/quince/issues/100) ruled that a watch is armed **last**,
  after a foreground catch-up tick, because self-caused events are deliberately not suppressed
  ([quince#62](https://github.com/novkostya/quince/issues/62)) and a session's last act is almost
  always an event on something it watches — so a watch armed any earlier is dead by design by the end
  of the turn. Six `Stop`-hook firings in one session, four of them true positives against a
  correctly-behaving session, and none a session neglecting to arm. The entire safety case for
  inserting a `tick` into the standard turn shape was one sentence: *a hand-run `tick` does not write
  the watcher record, so it cannot make a dead watch look alive.* **True, and the direction that does
  not matter.** The mirror was broken and load-bearing: `step()` carried `.issues` forward and not
  `.watch`, so a hand tick **erased** the record and a **live** watch read as **dead** — which is what
  `watch`'s live-refusal reads, so the guard did not fire and the very next arm, the one the new
  ordering prescribes, put a second watcher on one state file. That is
  [quince#50](https://github.com/novkostya/quince/issues/50)'s race reached **through** the guard
  rather than around it, and the new ordering is what made it the standard path rather than a corner.
  Fixed in [quince#104](https://github.com/novkostya/quince/pull/104) (`step()` carries the watcher
  record forward, two jq clauses) and the ordering PR rebased on top of it, rewritten so all three
  documents assert **both** directions and name the second as the one that was broken
  ([quince#102](https://github.com/novkostya/quince/pull/102), `15716b5`). **The general rule is the
  part worth keeping**, and it went into `loop-protocol.md` rather than into a skill: *a safety
  argument that checks one direction of a two-directional property has not been checked.*
  **Three things this cost, recorded because none of them was the code.** The one-directional claim
  was **verified against the source before the ruling** — the verification was of the safe direction,
  so rigor produced a false negative rather than preventing one, which is why `/architect` §6 now
  carries the sharper version. The defect was **invisible to all 38 fixtures**, every one of which
  asserted `event=` lines only: a defect that emits correct events while corrupting state had no
  expressible form, so #104 added `compare_state` and the negative control shows the signature —
  events `ok` on both ticks, ten state assertions failing. And the first attempt at that negative
  control **passed for the wrong reason** (a `sed` producing invalid jq, so the write never ran and
  `.watch` survived trivially), rebuilt before it was trusted and recorded rather than quietly
  corrected. **Owed and filed rather than absorbed:** the privacy gate declares on every run that its
  matcher is *"proven to COMPILE the lists, not to match anything"*
  ([quince#108](https://github.com/novkostya/quince/issues/108)) and that no case-sensitive list
  exists, which leaves [quince#41](https://github.com/novkostya/quince/issues/41)'s requirement 3
  **closed and unmet** ([quince#109](https://github.com/novkostya/quince/issues/109)) — every sweep
  declared clean to date rests on an assumption never exercised. A fourth copy of the one-directional
  wording survives in `docs/specs/rung-loop/rung-loop.md` story 16, correctly left alone: it is still
  true, and what changed is that the tool now guarantees more than the story states. This entry covers
  both PRs; neither had one.
  ([quince#102](https://github.com/novkostya/quince/pull/102),
  [#104](https://github.com/novkostya/quince/pull/104),
  [#100](https://github.com/novkostya/quince/issues/100),
  [#103](https://github.com/novkostya/quince/issues/103),
  [#50](https://github.com/novkostya/quince/issues/50))
- 2026-07-27: **A convention became a check, and building the check found an arbitrary-code-execution
  path in the obvious way to wire it.**
  [quince#112](https://github.com/novkostya/quince/pull/112) (`c0972ef`) builds
  [quince#94](https://github.com/novkostya/quince/issues/94)'s lint half: **every bare `#N` in a PR
  title must resolve in the repository the PR is in.** The defect is narrow and was paid for by the
  reviewer — `forge-watch` derives its watch set from PR **titles** (bodies deliberately unscanned,
  commit messages never), so a devlog title reading `(#102, #104)` made two *quince* PRs into derived
  issues of the *devlog*, costing two failing `gh` calls and two `issue-fetch-failed` lines **per
  tick** on the architect's box until somebody noticed ninety minutes later. The check asks the same
  question at authorship, where it costs one call instead of one per tick.
  **Two rulings shaped it and the second reversed the first.** The architect scoped the predicate to
  *a bare `#N` alongside a qualified `owner#M`* — which does not catch the title that caused the bug,
  since `(#102, #104)` has no qualified sibling. Resolution was adopted instead: it guesses nothing
  and takes the typo class with it. Exit codes are **0 clean · 1 a match · 2 DID NOT RUN**, the third
  ruled rather than optional, because a title check that fails open is absent on exactly the days the
  forge is flaky ([quince#41](https://github.com/novkostya/quince/issues/41)'s scar).
  **The finding that outgrew the feature.** A PR title is attacker-controlled on a public repository,
  and the obvious workflow line — `make pr-title-check TITLE="$TITLE"` — is command execution on the
  CI runner, demonstrated with a marker file rather than argued. The review then ruled the property
  *"never interpolate the title into the recipe text"* and **suggested a mechanism**; measuring that
  mechanism showed it insufficient: **`make` expands a command-line value whether or not the recipe
  references it**, because command-line variables are exported to the recipe environment and
  exporting forces expansion. A target-specific export would have satisfied the ruling exactly and
  left the vector open — a fix that reads as safe. `TITLE=` was therefore **deleted**, not repaired;
  a title arriving in the environment never becomes a make variable and is never expanded. The
  residual is **declared rather than claimed closed**: `make … TITLE='$(shell cmd)'` still executes,
  is make's own behaviour, is unreachable from CI, and is not fixable in that Makefile.
  **The working split, which is the durable part.** Both seats stated it: *the architect rules
  properties, the implementer measures mechanisms, and the measurement is owed even when the
  mechanism came from the architect.* Ruling a property and suggesting a mechanism in one breath is
  what nearly shipped the unsound fix — the same shape as
  [quince#102](https://github.com/novkostya/quince/pull/102)'s one-directional safety claim, which
  survived a review by its own reviewer until it was measured. Three controls in this unit were
  worthless on first attempt and rebuilt before being trusted: a `sed` that did not match (so a guard
  passed against an unmodified file), a fetch of a branch that did not exist (so an injection test
  ran against `main`), and a SHA fabricated from a short prefix and the wrong tail (a `422` was the
  only reason a force-push went nowhere). **A server rejecting your input is not a control.**
  **Owed, and stated at merge rather than after:** the check is **built, tested, documented and wired
  to nothing** ([quince#114](https://github.com/novkostya/quince/issues/114)). `.github/workflows/`
  is refused to *both* agent identities — the bot has no `workflow` scope by design and the
  architect's token returns `403` on that path, so the escalation `CLAUDE.md` documents has nobody at
  the end of it ([quince#113](https://github.com/novkostya/quince/issues/113)). Only the Operator can
  wire it. What *is* enforced from this merge is the `gates-sh` tooth banning a reintroduced
  `$(TITLE)`, since it rides the existing gate; the title lint itself fires for nobody, and
  quince#114 closes on a check being **observed running**, not on the file being pushed.
  **And the entry earned its own footnote in review:** the citation below read `#19` linked to
  *quince*#19 — a merged PR about `/report` — when it means
  [devlog#19](https://github.com/novkostya/quince-devlog/issues/19), whose title is *"six bare
  cross-repo references resolve against the wrong repo."* This was the seventh, committed in the
  entry about the check written to stop them, by the session that had built and run that check
  hours earlier. **It is also the worse failure mode:** a reference resolving to nothing gets
  noticed, a reference resolving to a real *wrong* issue is silent forever — and this one was a
  full URL, so it would have rendered as a working link for as long as this file exists. Nothing
  catches it: `pr-title-refs` checks **titles**, and prose citations are uncovered. That is the
  argument for the devlog#18/#19 line, made better by an accident than by any case for it.
  ([quince#112](https://github.com/novkostya/quince/pull/112),
  [quince#94](https://github.com/novkostya/quince/issues/94),
  [quince#113](https://github.com/novkostya/quince/issues/113),
  [quince#114](https://github.com/novkostya/quince/issues/114),
  [devlog#19](https://github.com/novkostya/quince-devlog/issues/19))
- 2026-07-27: **The title lint was wired, proven on the trigger that justifies it, and then could not be
  merged — because the forge cannot tell two seats apart when they share a login.**
  [quince#115](https://github.com/novkostya/quince/pull/115) put `.github/workflows/pr-title.yml` in
  place and corrected the escalation that could not deliver it, and
  [quince#116](https://github.com/novkostya/quince/pull/116) (`7372d38`) appended the dated correction
  to `docs/specs/devct/devct.md`'s claim that no `workflow` scope is needed *"since CI calls only
  `make`"* — true of a new **gate target**, false of a new **trigger**, which is the category error the
  note names so it survives `pr-title` being forgotten.
  **The proof is the part worth keeping, because it lives in a CI log and logs age out.** Three runs:
  `30279437397` clean on `opened`; `30279845907` **FAILURE** on a title carrying `#9999` —
  *`BARE REFERENCE #9999 does not resolve` · `1 of 3`*; `30279934830` clean on the restored title. The
  last two **share an identical head SHA**, and the workflow subscribes to `[opened, edited, reopened]`
  with `synchronize` deliberately absent — so a second run on an unchanged tree can only have come from
  **`edited`**, which is the entire reason the check is a separate file from `ci.yml`. That is the
  `edited` subscription, the failure direction in production (every prior exit-1 was synthetic), the
  discrimination (**1 of 3**, not a blanket fail), and recovery, in one exchange.
  [quince#114](https://github.com/novkostya/quince/issues/114)'s criterion — *a check **observed
  running**, not a file pushed* — was therefore **satisfied rather than waived**, which is the outcome
  the criterion was written to force and not the one expected.
  **Then the authority model ran out.** The workflow is the one change class that must come from the
  Operator's credential, and the architect reviews as the same login: `GraphQL: Review Can not request
  changes on your own pull request`. Branch protection needs one approval and **no identity can give
  it**, so quince#115 sits merged-ready and unmergeable.
  [quince#47](https://github.com/novkostya/quince/issues/47) has until now been a citation problem —
  *which seat said this?* — and it is now **a hole in the authority model at exactly the credential
  boundary**, reached on the first PR that ever needed that path. Recorded unresolved: it is the
  Operator's, and improvising around it is the thing not to do.
  **Two smaller records, both about copies.** The committed workflow was the **superseded draft**: the
  implementer revised it in a PR *comment* and left the original in the PR *body*, so whoever copied
  "the file from the thread" copied the stale one — functionally identical (`grep -v '^\s*#'` clean,
  which is why the check passes), missing only the comment block explaining why `REPO='${{ … }}'` is
  safe to interpolate where a title is not. **A proposal that will be copied verbatim belongs in one
  place, struck through if revised.** And a claim in quince#116's body was overtaken between writing
  and pushing; it was corrected **in the body** rather than only in the thread, since a merged PR's
  body is the record — annotated, not replaced, which is the line between correcting and quietly
  rewriting what a reviewer already read.
  ([quince#115](https://github.com/novkostya/quince/pull/115),
  [quince#116](https://github.com/novkostya/quince/pull/116),
  [quince#114](https://github.com/novkostya/quince/issues/114),
  [quince#113](https://github.com/novkostya/quince/issues/113),
  [quince#47](https://github.com/novkostya/quince/issues/47))

- 2026-07-27: **The gate that guards public history was proven to MATCH, not merely to compile — and
  the issue asking for it turned out to rest on a premise a measurement falsified.**
  `privacy-check` had printed, on every run on both boxes, that its matcher was *"proven to COMPILE the
  lists, not to match anything"* and that with no case-sensitive list *"every pattern runs under `-i`"*.
  Both disclaimers were correct, and both were about missing **private-layer content**, not missing
  code: the tool has supported a canary and a case-sensitive list all along, fully fixtured, with
  nothing populating either. `quince-local@dd2d1e1` populates both, and **on the runner box** the gate
  now reports `lists 8 case-insensitive + 1 case-sensitive` and `canary ok — the matcher matches
  known-positive input (10 probe(s))`. **On the architect box it still reports neither**, and that is
  not a lag: that box is on the pre-`dd2d1e1` layer and **cannot pull** — HTTPS remote, no credential
  helper, `fatal: could not read Username`
  ([quince#121](https://github.com/novkostya/quince/issues/121)). So the control described here is live
  on one of the two boxes, and the one it is absent from is the one that performs merges.
  **The design choice that outruns the issue is one probe PER PATTERN rather than one overall**, which
  closes the weakening mode `deploy/privacy/patterns.floor` documents as open and unclosable by a count:
  a **same-count substitution**. Measured both ways — one pattern replaced by junk, count unchanged at
  9, floor satisfied — a single-probe canary keeps reporting `canary ok` off the eight survivors, while
  per-pattern probes drive the real tool to `DID NOT RUN … matched NOTHING`, exit 2. The probes are
  derived mechanically from the lists, so no pattern was retyped and a hand-edited probe cannot drift
  from the pattern it exists to prove.
  **The falsified premise is the more durable finding.** [quince#109](https://github.com/novkostya/quince/issues/109)
  argued urgency from [quince#41](https://github.com/novkostya/quince/issues/41) req 3's device-name
  heuristic firing on ordinary product prose in two consecutive sweeps. That pattern is **no longer in
  the list**; nine patterns × both matching modes × the entire committed tree returned **zero matches in
  every cell**. So the recurring false positive the requirement was filed about was not happening, and
  the split shipped as precision-and-machinery-exercise with that said out loud rather than as a bug fix.
  **And the obvious mechanical rule would have been wrong**: *has uppercase ⇒ case-sensitive* would have
  moved a MAC OUI prefix, which must stay under `-i` because MACs are written in both cases — losing
  coverage while appearing to tighten it. A judgement got it right where a transformation would not,
  which is the architect's stated reason for this class of change remaining a judgement.
  Two triage comments and two implementer reports **raced and crossed** — the work was done and reported
  ~8 and ~15 seconds before each was declared blocked-on-the-Operator — and the record was corrected on
  both issues rather than left standing. Owed and named: the enforcement half (an absent canary should
  **refuse**, ruled from the architect seat since it is a failure-direction question rather than a
  private-content one) is **blocked on [quince#121](https://github.com/novkostya/quince/issues/121)**,
  a credential-widening question that is the Operator's — not on a pull, and not on a date. The
  prerequisite was first framed as a grace window while both boxes became known-good; that framing
  assumed the architect box could *become* good by pulling, and it cannot, so the flip must not be
  built behind it or it sits finished and unlandable. **The refusal to infer that box's state from this
  one is what surfaced it**, a day before it would have surfaced as an unmergeable PR. Also owed: a
  **known-negative** list — nothing proves a pattern *stopped* matching, which is exactly what the case
  split turns on, and it was verified by hand.
  The commissioning PR's own claim, stated rather than only cited: **`TEXT=` takes a PATH to a file
  holding the PR body, not the body** — passing the prose word-splits it and the gate refuses naming
  the first word of the PR as an unreadable filename. The placeholder mis-taught it in `CLAUDE.md` and
  in **both** `.claude/skills/review-pr/SKILL.md` sites, the latter unnamed by the issue and where a
  reviewer actually reads the command.
  ([quince#119](https://github.com/novkostya/quince/pull/119),
  [quince#121](https://github.com/novkostya/quince/issues/121),
  [quince#108](https://github.com/novkostya/quince/issues/108),
  [quince#109](https://github.com/novkostya/quince/issues/109),
  [quince#105](https://github.com/novkostya/quince/issues/105),
  [quince#41](https://github.com/novkostya/quince/issues/41),
  [quince#44](https://github.com/novkostya/quince/issues/44))

- 2026-07-27: **A `Stop` hook told a session to kill a healthy watcher, and the fix is a fifth
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

- 2026-07-27: **`git -c` does not persist, so no box could ever pull the private layer — and the box
  that quietly worked was the one hiding it.**
  `deploy/runner/provision` cloned with `git -c credential.helper=…`, which applies to that
  invocation and is **never written to `.git/config`**. Every clone authenticated once and then
  carried no helper: present, readable, and unable to advance.
  [quince#124](https://github.com/novkostya/quince/pull/124) persists it with `git config` on every
  path — including the already-cloned branch, which is what **repairs boxes in the field**.
  **The issue was filed as arch-box-specific and was not.** The runner was equally unwired; it worked
  only because a session hand-configured the helper in order to push and **did not register that it
  was patching a bug rather than doing setup**. A hand-fix that works is indistinguishable from a
  system that works, from inside the session that made it — and volunteering that turned a one-box
  mystery into a one-line root cause. The issue was retitled rather than corrected in a comment,
  because a comment eight deep does not reach a reader who meets it in a list.
  **It was found because somebody refused to infer.** The implementer asked for a one-line
  confirmation that the architect box reported `canary ok` and declined to assume it; the architect
  went to get it, and the answer was *no, and unobtainable*. The same refusal recurred twice more:
  a hollow *"arch confirmed"* was declined because the box was wired by hand rather than by the code
  under test.
  **That refusal is the one that paid, and it is the entry's strongest single fact.** Declining to
  report the box as confirmed exposed *how* it was wired — URL-scoped, `credential.https://…​.helper`
  — and the follow-up `preflight` check read the **unscoped** `credential.helper`, a different config
  key that returns nothing there. **The check written to stop a frozen layer would have refused to
  START a healthy box**, in the one gate that decides whether a machine boots. `--get-urlmatch` is the
  resolution git itself performs for a remote, so it answers *will a fetch from this url find a
  helper*; the narrow read encoded one of two correct wirings as the only correct one — the same class
  as rejecting `ls-remote` for gating on a fact it cannot establish, arrived at from the other side.
  **The confirmation was made meaningful by removing the hand-fix first** (`git config --unset
  credential.helper`) so the run exercised the repair path rather than finding the work already done —
  a control the acceptance criteria had not asked for.
  Owed and named: the arch box holds an implementer-role service installed by a `provision` run that
  defaulted its `--role` (**`QUINCE_RUNNER_ROLE` is not read as input** — the published step-2
  sequence omitted the flag, and *a procedure carries the box it was written on* exactly as a
  measurement does). [quince#125](https://github.com/novkostya/quince/pull/125) makes that refuse
  **before touching anything**; the artifact itself needs removing by hand, and one
  `provision --role arch` still gates both the `preflight` refusal and
  [quince#108](https://github.com/novkostya/quince/issues/108)'s canary flip. **And
  [quince#123](https://github.com/novkostya/quince/pull/123) is cited here as landed, not as closed:**
  the identity table it added omits the identity whose approval satisfied protection on it
  ([quince#130](https://github.com/novkostya/quince/issues/130), open), with a review-timestamp
  question on [quince#110](https://github.com/novkostya/quince/issues/110).
  ([quince#124](https://github.com/novkostya/quince/pull/124),
  [quince#125](https://github.com/novkostya/quince/pull/125),
  [quince#121](https://github.com/novkostya/quince/issues/121),
  [quince#108](https://github.com/novkostya/quince/issues/108),
  [quince#123](https://github.com/novkostya/quince/pull/123),
  [quince#130](https://github.com/novkostya/quince/issues/130))
- 2026-07-27: **The reviewer stopped being a person — verdicts now render as `quince-review[bot]` —
  and the PR that wired it was the first to feel the change.**
  [quince#134](https://github.com/novkostya/quince/pull/134) replaced the shared-login review path
  with a GitHub App. `bin/gh-review` mints a per-call installation token and caches nothing;
  `preflight` asserts the credential can **MINT**, not merely that a key file exists —
  [quince#121](https://github.com/novkostya/quince/issues/121)'s presence-vs-capability lesson turned
  on the check written to apply it. `CLAUDE.md` gained a fourth identity row, and `/architect` §1 was
  rewritten so identity is asserted with `api /installation/repositories` (**=5**) rather than `api
  user`, which an installation token answers `403` to by design. This closes the omission the prior
  entry named: [quince#123](https://github.com/novkostya/quince/pull/123)'s table had no App row.
  **The review's strongest fact is that the tool refused to let the reviewer use it.** The PR made
  `bin/gh-review` the canonical verdict path but shipped **no allowlist entry** for it, so the first
  attempt to cast the App verdict was blocked by the harness — found by hitting it, not by reading.
  The companion finding: the wrapper's `>1 installations` branch died unconditionally while its own
  message named `QUINCE_REVIEW_INSTALLATION_ID` as the remedy — an error advertising a fix the code
  could not reach. Both were fixed in review (`87b5898`): the allowlist entry added, the override made
  reachable, each crediting the read.
  **The App then cast its first real verdict** — approve, rendered as `quince-review[bot]`, on the
  very PR that defines it. [quince#130](https://github.com/novkostya/quince/issues/130)'s ruling that
  an App approval satisfies branch protection **alone** was exercised for the first time; the merge,
  by the Operator (the author's own seat, which a shared login could not have reviewed —
  [quince#47](https://github.com/novkostya/quince/issues/47)), confirmed it.
  **Two governance questions were raised and not self-resolved:** whether an architect *opening* the
  PR crosses "does not implement" — moot, the Operator opened it; and whether the reviewer approving
  the canon that defines its own authority is acceptable — the reviewer recommended the Operator cast
  it and the Operator directed the App to approve. **Corrections: two findings, both reviewer→author,
  both accepted** — the two-seat review did its job on the PR built to make that review a distinct
  voice.
  ([quince#134](https://github.com/novkostya/quince/pull/134),
  [quince#47](https://github.com/novkostya/quince/issues/47),
  [quince#130](https://github.com/novkostya/quince/issues/130),
  [quince#121](https://github.com/novkostya/quince/issues/121),
  [quince#123](https://github.com/novkostya/quince/pull/123))

- 2026-07-27: **`preflight` now refuses a private layer that can never fetch — and the check that
  enforces freshness was twice caught refusing a machine that worked.**
  [quince#135](https://github.com/novkostya/quince/pull/135) closes
  [quince#121](https://github.com/novkostya/quince/issues/121). *Present is not fresh*: a layer clone
  can be present, readable, and unable to receive anything ever again, and on the arch box — the box
  that merges, hence the last privacy gate before public history — that means sweeping forever with a
  matcher frozen at build time, reporting `clean` exactly as a current one does. The check asserts the
  **local wiring** rather than attempting a fetch, because `ls-remote` fails identically for "no
  credential" and "network is down", and a false refusal in the one check that decides whether a box
  starts is an outage.
  **It was refused twice for that same conflation, from two directions.** The first draft asked `config
  --get credential.helper`, which cannot see a **URL-scoped** helper — the shape the Operator had wired
  the arch box in — so it would have refused to start the box in the configuration just confirmed
  working on it; `--get-urlmatch` asks the question git itself asks, and both wirings pass. The
  reviewer then found the same defect one transport further out: **SSH authenticates with a key, so an
  SSH-cloned layer fetches forever without a helper** and was read as frozen. The author's correction
  to the reviewer's root cause is the load-bearing part — `git@host:p.git` and a bare path *fatal* and
  were masked by a `2>/dev/null`, but `ssh://` and `file://` are valid URLs that exit 1 printing
  **nothing at all**, so un-masking the stderr would have repaired the loud half and left the quiet
  half bricking boxes silently. The fix dispatches on the **scheme**; dropping the redirect is a
  consequence, not the remedy. The non-http(s) arm reports what it did **not** establish rather than
  claiming the layer can advance, which would have been quince#121's own defect re-committed by the
  change that fixes it.
  **Provenance stated rather than blurred:** the first two commits are a retired session's, rebased and
  opened by a successor who said so in the PR; the two hardware runs on both helper wirings are the
  architect's, cited and not reproduced. Four new fixtures were proven non-vacuous against the pre-fix
  binary — 36/4 before, 40/0 after. `pr.6` constraint 7 was discharged in passing: both boxes
  re-provisioned, both temporary hacks gone, verified on each box rather than taken on report.
  ([quince#135](https://github.com/novkostya/quince/pull/135),
  [quince#121](https://github.com/novkostya/quince/issues/121),
  [quince#32](https://github.com/novkostya/quince/issues/32),
  [quince#44](https://github.com/novkostya/quince/issues/44))

- 2026-07-27: **"The Operator approves canon" became a file instead of a sentence — and the deadlock
  everyone predicted turned out to rest on a premise nobody had checked.**
  [quince#138](https://github.com/novkostya/quince/pull/138) closes
  [quince#47](https://github.com/novkostya/quince/issues/47) with `.github/CODEOWNERS`, owning
  `CLAUDE.md`, the four canon docs, and itself. **It works only because a GitHub App cannot be a code
  owner** — owners must be users or teams with write permission — so after
  [quince#134](https://github.com/novkostya/quince/pull/134) an architect verdict *structurally cannot*
  satisfy the requirement and only the human account can. A day earlier, naming `@novkostya` would have
  distinguished nothing. **The refusal is the mechanism, not the obstacle.** Landed **inert**: CODEOWNERS
  alone only auto-*requests* review, the enforcing toggle is admin-only, and the file's own header says
  so — [quince#113](https://github.com/novkostya/quince/issues/113)'s built-and-unwired shape, with the
  wiring filed as [quince#137](https://github.com/novkostya/quince/issues/137).
  **Three seats each published a conclusion resting on something unmeasured, within one hour.** The
  implementer filed the toggle as creating an *unavoidable* deadlock and separately recommended "flip
  it, accept admin override" — reasoning about branch protection from a `404` it had correctly recorded
  as a limit on its own permissions. The architect refuted the second with `enforce_admins: true` (so
  that option was really *two* flips, the second stripping admin enforcement from `gates`/`image`/`e2e`
  and linear history repo-wide) — while itself having told devlog#51 that only the App could approve,
  reasoning from the shared login. **The Operator's ruling found the move none of them had costed:**
  the premise that the architect can only author as the Operator is false — the App holds `contents:
  write`, and devlog#53 was authored by `app/quince-review` while the question was open. So the fix was
  a **missing instruction, not a missing capability**, and the toggle is *sequenced*: architect authors
  canon through the App → `@novkostya` approves as code owner, a different principal → then the flip.
  The exception is recorded as narrow in three places: it licenses nothing for a class the App also
  approves ([quince#136](https://github.com/novkostya/quince/issues/136)).
  **The identity table gained a row neither seat could have written alone.** The architect measured
  that both of its identities are refused `run rerun`, filed the row **scoped to exactly those two**
  ([quince#141](https://github.com/novkostya/quince/issues/141)), and declared `quince-bot`
  **unmeasured** — an architect box correctly holds no bot token, so that half was not its to measure
  and it would not guess from scope names. The implementer had already re-run the workflow
  (`run_attempt: 2`, attempt 1 preserved as `failure`) and supplied the missing half four minutes
  later. **That is the declared-untested discipline working end to end across two identities**, which
  is what this project keeps asking for and rarely gets to record. The true row is asymmetric and runs
  **opposite to every other row in that table** — `quince-bot` can, the App and the architect PAT
  cannot.
  **Third red `gates` on a docs-only diff in one afternoon**, filed as
  [quince#140](https://github.com/novkostya/quince/issues/140) at the threshold the architect had set in
  advance. Not a flake: [quince#59](https://github.com/novkostya/quince/issues/59)'s test is correct and
  detecting a real defect, and *"docs PR cannot cause a Go failure, therefore flake"* is the exact
  inference [quince#129](https://github.com/novkostya/quince/issues/129) records as having filed a real
  defect as noise. The cost the issue names is that the **correct** response to a red gate is a
  classification, so the project pays a review cycle for CI rather than for its diffs.
  ([quince#138](https://github.com/novkostya/quince/pull/138),
  [quince#47](https://github.com/novkostya/quince/issues/47),
  [quince#137](https://github.com/novkostya/quince/issues/137),
  [quince#136](https://github.com/novkostya/quince/issues/136),
  [quince#140](https://github.com/novkostya/quince/issues/140),
  [quince#59](https://github.com/novkostya/quince/issues/59))

- 2026-07-27: **The break-glass host stopped being an unfinished lockout and became a decision — and
  the paragraph admits it is a norm no mechanism can hold.**
  [quince#142](https://github.com/novkostya/quince/pull/142) writes `pr.6` constraint 6 into
  `CLAUDE.md`. `pr.6` turns every remaining root path into a forced-command wrapper, and the natural
  reading of *every* is that the Operator's Mac should be narrowed with them; it is not, because **a
  lockout that leaves no host outside itself has no recovery path**. Both boxes are supervised by a
  service a bad provision can stop from starting — `preflight` refuses rather than degrades, by
  design — so the seat that repairs a box which will not start cannot live on it. The identity
  table's Operator row (an SSH push consults no OAuth scope, so a workflow can always be pushed) is
  that exemption's sharpest instance and now reads as break-glass rather than as an inconsistency
  nobody closed.
  **The review's finding is the better half of the entry.** The paragraph ended on *"the moment
  routine work moves back to the Mac, the exemption becomes an ordinary hole"* — an unfalsifiable
  sentence sitting ten lines from a file arguing that unfalsifiable sentences decay. There is no
  clean tripwire: work from that host surfaces as `novkostya`-authored activity, indistinguishable
  from the Operator's ordinary rulings and canon approvals. So the paragraph now says it is a norm
  **and why no mechanism can hold it** — an acknowledged norm ages better than an implied guarantee.
  **A privacy question was decided by measurement rather than taste.** The reviewer flagged that
  naming the Operator's machine by type is adjacent to the *hardware sizing* the hard rule names, and
  that a PR title reaches history where later edits do not. The gate passed, and the type was already
  committed in two files predating the PR — so it is not a new disclosure, and generalising only the
  new paragraph would have produced one careful file beside two plain ones, implying a policy nobody
  applies. Left alone, with the alternative named: one sweep across all three files, as its own change.
  **`pr.6` constraint 7 was discharged the same evening**, verified on each box rather than taken on
  report — both boxes re-provisioned by the fixed `provision`, `runner_role` written in `conf.d`
  rather than exported by hand, and the private layer a clone whose credential helper is persisted in
  `.git/config` and fetches at exit 0.
  **And the discharge cannot be audited**, which is the entry's own caveat:
  [quince-devlog#55](https://github.com/novkostya/quince-devlog/issues/55) records that `pr.6`'s
  constraints are cited by **number** and the numbered list is in neither public repo. Constraint 6's
  wording is the implementer's; its content arrived in a session message. A "done" that cannot be
  checked against a written requirement is the shape the state-honesty rule exists to prevent,
  reached through the requirement rather than through the report — and the list was deliberately
  **not** reconstructed from what was held by report, since that produces an authoritative-looking
  document assembled from a conversation.
  ([quince#142](https://github.com/novkostya/quince/pull/142),
  [quince-devlog#55](https://github.com/novkostya/quince-devlog/issues/55),
  [quince#47](https://github.com/novkostya/quince/issues/47))
- 2026-07-28: **Eight filed defects cleared in one overnight unit, and seven of the eight were the
  same bug: a claim whose evidence could not falsify it.**
  A single implementer session took [quince#133](https://github.com/novkostya/quince/issues/133),
  [#132](https://github.com/novkostya/quince/issues/132),
  [#53](https://github.com/novkostya/quince/issues/53),
  [#118](https://github.com/novkostya/quince/issues/118),
  [#107](https://github.com/novkostya/quince/issues/107),
  [#106](https://github.com/novkostya/quince/issues/106),
  [#131](https://github.com/novkostya/quince/issues/131) and
  [#101](https://github.com/novkostya/quince/issues/101) at depth 1 — one PR in flight, cheapest
  first — with the Operator asleep and nothing in the list needing a ruling. **Eight PRs, eight
  merges, all eight issues closed**; two changes-requested rounds, and **three new gates** in
  `gates-sh` — `forge-watch-stop-test`, `forge-watch-fixtures-doc-test` and
  `quince-runner-status-test`, taking its sub-suites from five to eight — plus two new cases in the
  existing `preflight-test`. (Two corrections to this paragraph before it landed, both mine. It said
  *"seven merged, one approved with checks running"*, true when written and stale twenty minutes
  later. And it said **four** new gates, counting quince#147's added `preflight-test` cases as a
  suite of their own: five sub-suites before this unit, eight after, so the number was three and a
  reader who counted would have found it. The smallest possible instance of *a claim whose evidence
  cannot falsify it* — in the entry whose subject is that defect, which is where it is least
  affordable and, on the evidence, easiest to commit.)
  **The through-line was not planned and is worth naming**, because it is the class this project
  keeps paying for: a tool that reports something it never checked, or reports it about the wrong
  moment. `preflight` printed a pattern count it computed *itself* from one of two lists, beside a
  floor derived from both ([quince#147](https://github.com/novkostya/quince/pull/147)) — "8 usable
  patterns" against a floor of 9, which reads as the one alarm `patterns.floor` exists to raise, on
  a healthy box. `rc-service status` decided on a 20-line grep window and displayed a 3-line tail,
  so the evidence under the sentence need not be what triggered it — and because
  `Session failed: Process exited with error` is *the normal terminal event of every unit*, *every
  retirement* left a fit, idle box reporting failure at exit 1 until twenty lines scrolled past
  ([quince#155](https://github.com/novkostya/quince/pull/155)). `provision` told an arch box to
  start `quince-runner`, a unit that box does not have
  ([quince#153](https://github.com/novkostya/quince/pull/153)). `/retire` §1 prescribed `bin/gh-bot`
  to both seats, on a boundary where the architect host must never hold that token
  ([quince#145](https://github.com/novkostya/quince/pull/145)). `/onboard` §4 hand-listed two repos
  while `.claude/forge-set` existed precisely so a third could not go unreported
  ([quince#148](https://github.com/novkostya/quince/pull/148)).
  **The fixture README drift was the inverse of that class, and is the more interesting half.**
  `bin/testdata/forge/README.md` indexed 29 of 43 fixtures, so **fourteen tested behaviours read as
  untested** ([quince#151](https://github.com/novkostya/quince/pull/151)). Every other coverage
  defect filed here runs the other way — declared coverage larger than the truth — so a reader who
  has internalised *the docs overstate* would have misread this one too. The table was **not**
  deleted: it is a genuine per-round narrative, so it was guarded by a gate asserting both
  directions (every fixture named; every name resolving) and the fourteen were backfilled from each
  fixture's own `note`, including a seventh round for the quince#80 issue-channel work that had none.
  **`stop` gained `--all`, closing a remedy that could half-execute.** `/architect` §0 sends a
  session that finds `wedged` to `stop --repo <r>`; under a multi-repo set a watcher can be wedged
  on any of them, so a per-repo stop leaves the others live and the session then arms beside one —
  quince#50's race reached *through* the remedy. The verify-then-signal moved into a shared
  `stop_one` so both paths run one implementation of the pid check, and the fan-out **refuses as a
  whole** if any single stop refuses, because a partial stop is the outcome that hurts
  ([quince#150](https://github.com/novkostya/quince/pull/150)).
  **The spec learned a guarantee the tool already had.** `rung-loop` story 16 said a hand-run tick
  cannot make a *dead* watcher look alive; quince#104 had shipped the mirror — `step()` carries the
  watcher record forward, so it cannot make a *live* one look dead — and the acceptance criteria
  never said so. A reader reconstructing the contract from story 16 alone rebuilds quince#103, which
  is exactly how quince#103 happened. Story **16b** states the pair as *one property with one safety
  argument* ([quince#152](https://github.com/novkostya/quince/pull/152)).
  **Two review rounds, both catching real defects, both mine, and both invisible to every gate.**
  The `/retire` fix first defined `<gh>` as "your seat's wrapper" — but the architect seat has
  **two**, split by whether the call carries attribution, and §2 asks the session to *post*. A
  session told at §1 that its wrapper is `gh-arch` would have flushed its parked PRs and rulings
  through the one path `/architect` §1 forbids, with no error either time: a **loud** wrong traded
  for a **quiet** one, in the skill whose §2 output is a session's unreviewed last act. And the
  `preflight` fix captured the gate's stderr through
  `mktemp … || echo /tmp/quince-preflight.$$.err` — a predictable path, written by **root**, holding
  the gate's *matched* Operator-private lines on exit 1 (CWE-377). `mktemp` is in busybox and
  coreutils so it would never have fired; it was blocked anyway, on the ground that the fallback
  contradicted the file's own refuse-don't-degrade character. Both were caught by the reviewer, by
  reading, and neither by a test.
  **What the reviewer did that the record should keep.** Verdicts were checked against the tree and
  the box rather than the PR body: the fixture counts re-derived independently (43 / 29 / 43); the
  README gate's **real exit codes** tested in both directions, including a dangling reference the
  reviewer injected themselves, because a gate that prints `FAILED` and exits 0 is a no-op inside
  `gates-sh`; `stop --all` smoke-tested against the *actual* declared set in the one window where
  both watches were already dead; and `rc-service quince-arch status` run live on the architect box,
  reproducing both of quince#101's defects in one output — the sentence claiming an error, the idle
  banner printed beneath it, real exit 1 — which is evidence the implementer box could not produce.
  **The last finding landed on its own PR's thesis.** quince#101 argues a status line is a claim
  about *now* that must be supported by what it shows; its three *new* lines hardcoded
  `quince-runner:` while `name="${RC_SVCNAME:-quince-runner}"` sat 130 lines above, derived for
  exactly that reason (quince#32) — so the arch box reported under a service it does not run. The
  fourth, pre-existing literal was swept too: leaving one among four in a function the PR rewrites
  hands the next reader a mixed convention. The label is now asserted over **every** branch of
  `status()`, not the healthy one alone, because the literal appeared three times in one rewrite and
  a single-branch check would have caught one and missed two — story 16b's lesson, twice in one night.
  **Owed, and recorded where it can be found.**
  [quince#154](https://github.com/novkostya/quince/issues/154): `provision`'s layer `chmod` skips
  subdirectories (`[ -f ]`), and its comment enumerates only the dotfile exclusion, so it reads as
  exhaustive. Nothing is unprotected today — the layer has no subdirectories but `.git` — but a
  nested file would be missed by the fixer *and* invisible to `preflight`'s top-level-only note. The
  reviewer raised it non-blocking with *"fold it in whenever `provision` next moves"*; it was filed
  rather than left in a merged PR's review body, because a deferral recorded only there is the item
  successors most often lose.
  **Not proven, stated rather than implied.** `provision` has no test — it runs as root, clones
  repos and installs services — so its two fixes were verified in isolation and the surrounding
  script is untouched by evidence. `quince-runner-status-test` drives `status()` directly with
  synthetic logs and stubbed OpenRC functions, so what is proven is the classification, not the
  OpenRC integration around it; the marker strings come from quince#101's transcript rather than a
  log captured for the purpose, and if the session banner's wording changes the `_up` set needs
  revisiting (the failure direction is safe: an unrecognised banner reads as healthy, matching the
  old default).
  ([quince#145](https://github.com/novkostya/quince/pull/145),
  [quince#147](https://github.com/novkostya/quince/pull/147),
  [quince#148](https://github.com/novkostya/quince/pull/148),
  [quince#150](https://github.com/novkostya/quince/pull/150),
  [quince#151](https://github.com/novkostya/quince/pull/151),
  [quince#152](https://github.com/novkostya/quince/pull/152),
  [quince#153](https://github.com/novkostya/quince/pull/153),
  [quince#155](https://github.com/novkostya/quince/pull/155),
  [quince#154](https://github.com/novkostya/quince/issues/154),
  [quince#149](https://github.com/novkostya/quince/issues/149))
- 2026-07-27: **The first canon PR the reviewer authored — and the finding that blocked it was its
  own false claim about the thing it was documenting.**
  [quince#143](https://github.com/novkostya/quince/pull/143) landed three one-clause canon edits that
  two Operator rulings had left with no owner across two comments: branch protection stated
  **per-repository** ([devlog#53](https://github.com/novkostya/quince-devlog/issues/53)), the merge
  fallback *with its reason* ([devlog#52](https://github.com/novkostya/quince-devlog/issues/52)), and
  the `run rerun` identity row plus the `workflows:`-is-not-`actions:` distinction
  ([quince#141](https://github.com/novkostya/quince/issues/141)). Three unassigned one-clause edits to
  the same two files is how the one nobody would miss gets dropped, so they went together.
  **It is quince#137 step 1 in use for the first time**, and not stylistically: with `enforce_admins`
  now true on both repos, an architect-authored canon PR opened through `gh-arch` cannot merge at all.
  Authored by `app/quince-review` through the git data API — a `git push` would have had no App
  credential on that box and re-authored it as the wrong identity, which is the failure the PR's own
  third clause documents. **Author, approver and merger were three different principals on an owned
  path**, which is the configuration [quince#137](https://github.com/novkostya/quince/issues/137)'s
  step 3 would make mandatory, demonstrated before the toggle rather than after. `CODEOWNERS`
  auto-requested `@novkostya` unprompted — later *established* rather than assumed by the
  implementer's two-PR control on quince#138/#142, since the actor field renders as the author either
  way and a single observation cannot tell an auto-request from a hand-passed `--reviewer`.
  **The code owner blocked it on one sentence, correctly.** It claimed *"every merge since 2026-07-27
  reads `mergedBy: app/quince-review`"* — false by **twenty-six** counter-examples, since everything
  merged earlier that day, quince#134 included, was `novkostya`'s. A **date** was written where an
  **event** was meant, and the boundary — `21:53:23Z` — was a merge this seat had made ninety minutes
  earlier, so the counter-examples were in its own session record. It landed in the clause whose point
  is *demonstrated rather than aspirational*, one paragraph after the clause correcting the identical
  shape in the protection sentence: **true of a slice, written as a property of the whole.** Rewritten
  to bound at the App's first merge, enumerate the examples, and state the exclusion outright — so a
  reader who checks finds the counter-evidence already in the sentence.
  **And the fix push produced the negative control quince#110's ruling said it lacked.** That ruling
  established that a review's `commit_id` re-associates to a new head across a push leaving the diff
  unchanged, noting its two supporting instances *"neither establish it"* — both being unchanged-diff
  pushes. This push **changed** the diff, and `commit_id` stayed at the reviewed commit. Which sharpens
  the clause rather than softening it: **`commit_id` is accurate in every case except the one the
  stale-approval check exists for.**
  ([quince#143](https://github.com/novkostya/quince/pull/143),
  [quince#137](https://github.com/novkostya/quince/issues/137),
  [quince#141](https://github.com/novkostya/quince/issues/141),
  [quince#110](https://github.com/novkostya/quince/issues/110),
  [devlog#52](https://github.com/novkostya/quince-devlog/issues/52),
  [devlog#53](https://github.com/novkostya/quince-devlog/issues/53))
- 2026-07-28: **A reviewer session's own numbers, which exist nowhere on the forge: nine findings
  accepted, five corrections of the reviewer accepted, five errors caught before they were
  published — and a loop that proved itself mostly by being quiet.**
  Retirement record for the architect session of 2026-07-27/28, which reviewed and landed **eighteen
  PRs** across both repos and closed eleven issues. The individual verdicts are on the PRs; this
  entry keeps the three things `/retire` §4 exists for, because the forge records events and has no
  vocabulary for **rates** or **non-events**.
  **How often the reviewer was wrong, counted in both directions.** Findings raised and accepted:
  **nine** — six blocking (a boot-blocking refusal of SSH-cloned layers, quince#135; `/retire` §1
  defining a wrapper that collided with §2's posts, quince#145; a root-run predictable temp file
  holding matched private lines, quince#147; a service label hardcoded into new lines beside the
  variable derived for it, quince#155; a false statement about a filing, devlog#54; a gate count of
  four that was three, devlog#60) and three non-blocking, two of which became
  [quince#149](https://github.com/novkostya/quince/issues/149) and
  [quince#154](https://github.com/novkostya/quince/issues/154). Corrections **of** the reviewer,
  accepted: **five** — a root cause that was half a diagnosis (`ssh://` and `file://` are valid URLs
  and fatal on nothing, so un-masking stderr would have fixed the loud half and left the quiet half
  silent); a canon sentence false by twenty-six counter-examples; an auto-request claim published
  from a single observation with a confound the author could not see; a persistence attributed to
  quince#94 that belonged to quince#99; and a privacy concern resolved against the reviewer by
  someone checking whether the thing feared had already happened.
  **That ratio is the finding, not the totals.** A two-seat review that produces corrections in only
  one direction is a seat performing review; nine-and-five is the mechanism working. Both seats and
  the Operator each published at least one conclusion resting on something unmeasured, and each was
  corrected by someone who ran the case the other had not — which is the only evidence anyone has
  that the arrangement does anything.
  **Five errors were caught before publication and would otherwise have been forge records.** A
  comment claiming a job had been re-run (`gh run rerun` exits `0` while printing its refusal); a
  five-file diff read as a PR's contents when it was a stale `origin/main`; a `pgrep … | wc -l` that
  counted its own observer and looked like quince#50's double-watcher; a session-log excerpt pasted
  into a review body **after a clean privacy gate**; and an empty blob sha that built a tree
  *deleting* `progress.md`, from an `Argument list too long` whose failure went unchecked. All five
  are the same defect — **a discarded channel makes failure indistinguishable from a null answer,
  and the null answer is the benign one** — which is also what seven of the eight overnight fixes
  were, and is now proposed as a corollary on
  [devlog#27](https://github.com/novkostya/quince-devlog/issues/27). The reviewer committed it five
  times while filing it.
  **What the silence proved.** Five consecutive `watch-idle` bounds — 1260s/15 ticks, 1252s/15,
  1256s/15, 1247s/15, 1258s/15 — roughly **1h45m and 75 ticks with nothing to say**, then a wake
  delivered within a minute of the queue moving. That is the loop demonstrating it can be quiet
  without being dead, and it exists only in session scratch. Meanwhile **`ScheduleWakeup` fired
  neither of the two times it was armed**, the second squarely inside that quiet window with
  watchers continuously in flight — a confound-free instance recorded on
  [quince#70](https://github.com/novkostya/quince/issues/70), whose thesis it supports.
  **Judgement no tool asked for, listed because a correct outcome leaves no trace of having been
  decided.** Reading `$?` directly on quince#151's new gate rather than its printed output — a gate
  that prints `FAILED` and exits `0` is a no-op inside `gates-sh`, and nothing would have said so.
  Reading quince#150's `stop` suite for blast radius *before* running it, since a `stop` test is the
  one kind that can signal the reviewer's own watcher. Smoke-testing `stop --all` against the real
  declared set in the one window where both watches were already dead. Redacting a session-log
  excerpt the privacy gate had passed. **Declining to determine whether the App can write branch
  protection**, because the only way to find out is to try, and a successful probe is an unreviewed
  change to how `main` is defended. And declining to reseed the watch to settle quince#94's open
  question, because it would have destroyed the accrued observation quince#49 forbids discarding.
  **Owed and unowed, stated so the next session need not re-derive it.** Nothing is owed by this
  seat. Open for the Operator: quince#137's step-3 toggle, and devlog#59's constraint-6 row, which
  is discharged in canon but still marked owed. Open for the implementer: quince#146, #149, #154,
  #94/#99, #59, #111, #139, #140 and devlog#56. The declared issue set on the retired watch is
  **stale in both directions** — it names issues closed overnight and omits every issue filed since —
  and a successor should re-declare from the open issues rather than adopt it.
  ([quince#70](https://github.com/novkostya/quince/issues/70),
  [quince#146](https://github.com/novkostya/quince/issues/146),
  [quince#149](https://github.com/novkostya/quince/issues/149),
  [quince#154](https://github.com/novkostya/quince/issues/154),
  [devlog#27](https://github.com/novkostya/quince-devlog/issues/27),
  [quince#47](https://github.com/novkostya/quince/issues/47))
- 2026-07-29: **A fail-safe that holds is exactly the condition under which a wrong message survives
  indefinitely — `owed` called an orphaned watch "the watch class could not be read (10)", and every
  automated signal read correct the whole time.**
  [quince#195](https://github.com/novkostya/quince/issues/195) closed. `orphaned` has had its own
  exit code since quince#111/#167, and `owed_decide`'s message switch was never extended, so it fell
  to the catch-all. The **verdict** was right throughout — everything but `live`/`starting` is owed,
  so the `Stop` hook blocked correctly and no session was ever told it was watched when it was not —
  and that is precisely why nothing caught it. What a session actually read was a sentence describing
  a *failure to determine state*, about a state that had been determined perfectly; the natural
  response to it is to go and investigate the tool, when the correct response is one documented
  command.
  **`orphaned` shares `wedged`'s remedy and not its diagnosis**, which is what the new arm carries:
  wedged is running and has stopped ticking, orphaned is running and ticking fine while the session
  it would wake is gone. Both must be stopped before arming, because a process is still writing to
  the state file either way — so folding `10` into the `5` arm is tempting, and
  `owed-an-orphaned-watch-names-its-remedy.json` pairs the two classes in one fixture to refuse it.
  **The class was closed rather than the instance, and the previous attempt is the argument for it.**
  [quince#183](https://github.com/novkostya/quince/pull/183) landed hours earlier for the identical
  shape — a class added, an enumeration not updated — and its fix gated *documents* that enumerate
  exit **vocabulary**. `owed_decide` enumerates the same classes as a shell `case` over class
  numbers, with no such vocabulary anywhere near it, so it was structurally invisible to the fix
  aimed at its own defect class. `forge-watch-exits-test` section 4 now derives `watch_report`'s
  returns and asserts each has an explicit arm — a code-to-code totality check beside the existing
  code-to-document one.
  **Both new gates were measured failing against the unfixed code and passing after** — by the author,
  then independently by the reviewer, who mutation-tested the assertion by deleting the arm and got
  `16 passed, 1 failed` naming class 10. Declared unproven and accepted on both sides: the guard
  asserts an arm **exists**, not that its wording is right; and no genuinely orphaned watch was
  driven end to end, because manufacturing one against live watch state risks quince#50's race —
  the failure the tool exists to prevent.
  **Two process defects were found by hitting them, neither related to the fix.**
  `/tmp/pr-body.md` is hard-coded in canon in three places and was already occupied by another
  runner's in-flight PR body; the documented sweep was one write from destroying it
  ([devlog#123](https://github.com/novkostya/quince-devlog/issues/123)). And **runner branch
  ownership is inert**: `runner set` tells a session it owns `<name>/…` while `/kickoff` §3 instructs
  `<qn.N|pr.N>/<short-title>`, so `wake_filter` cannot attribute the majority of branches and
  quince#111 face 3 does not hold for anyone following the skill it was told to run — measured as two
  wake-ups on other runners' PRs
  ([devlog#124](https://github.com/novkostya/quince-devlog/issues/124)). Both are the
  shared-mutable-path / contradicting-convention class that `$HOME/scratch/<runner>` already fixed
  once, one file over.
  ([quince#215](https://github.com/novkostya/quince/pull/215),
  [quince#195](https://github.com/novkostya/quince/issues/195),
  [devlog#123](https://github.com/novkostya/quince-devlog/issues/123),
  [devlog#124](https://github.com/novkostya/quince-devlog/issues/124))
- 2026-07-29: **A documentation issue about retired dev containers turned up three capability
  facts canon had wrong, and the doc fix is the smallest thing in it.** quince#189 asked for one
  stale section in `.claude/README.md` and invited a tree-wide `quince-dev` grep; the grep found a
  **fourth** instance in `deploy/dev.md` — the file `CLAUDE.md` names as *how to build and run the
  gates anywhere*, answering "don't have a box to run gates on?" with a workflow retired on
  2026-07-28. Both fixed by drawing the line `deploy/devct/devct`'s own header already draws
  (persistent-box path live, disposable series retired) rather than by deleting anything; the 11
  rung specs saying "green in `quince-dev`" were left alone as dated proof records. **Also
  established: devlog#45's *body* contradicts the ruling in its comments** — it still lists "the
  implementer creates its own dev CT … one runner, one CT" under *Settled — do not re-litigate* —
  and both existing citations in the product repo point at the bare issue number, so a reader who
  checks lands on the opposite of the decision. Citations now name the comment.
  **What the review found is the better half.** The reviewer blocked on one inherited sentence —
  `/etc/quince-devct-stamp` "on both boxes" — having measured it **absent** on the arch box.
  Measured absent on the runner too: no `/etc/*stamp*` of any name on either. So `devct`'s header
  has offered a provenance proof that does not exist since quince#181, and the fix went to the
  **source** as well as the copy, because removing the sentence from one file while leaving it in
  the other is this project's defect class committed knowingly. `/etc/alpine-release` reads
  `3.24.1`, matching what the stamp claimed, so it is the **artifact** that is missing rather than
  demonstrably the provenance; the likeliest cause is quince#205's second-site rebuild from an
  Operator-local factory that writes no stamp, and that is recorded as a hypothesis with an issue
  number rather than as a cause. Consequence: `devct list` reports template freshness by reading
  that file, so on both boxes freshness is **unknown** rather than current.
  **Three capability findings, each measured rather than reasoned.** (1) **No agent seat can re-run
  a workflow run any more** — `403 Resource not accessible by integration` from the implementer App
  at the porcelain *and* at both raw endpoints (`rerun`, `rerun-failed-jobs`). `CLAUDE.md` recorded
  it as the implementer's one `CAN` and routed red-check asks there; that was a property of
  `quince-bot`'s classic-`repo` PAT, not of the seat, and it did not survive `decisions/0014`. The
  architect confirmed it independently from the arch box and took it to canon (quince#219) — a
  capability recorded against a **seat** when it belonged to a **credential**. (2) **The committed
  allowlist had drifted from every command canon instructs**: `bin/gh-coder` (14 references),
  `bin/git-coder`, `bin/scratch-reap`, `make demo`, and — the subtle one — `Bash(make privacy-check)`
  with no wildcard, while every form the hard rule mandates carries `REF=`/`TEXT=`. quince#198,
  #177 and #179 each added an entrypoint and touched no settings file; nothing gates the pair.
  (3) **A `--rebase` update-branch does NOT dismiss a standing approval here** — measured on
  quince#216, which mattered in both directions: it stalled the author, who declined to rebase
  rather than gamble an approval on a guess, and it endangers a reviewer who assumes dismissal and
  merges an unread head.
  **quince#211 was mis-measured by BOTH seats within the hour, and that is the finding rather
  than the confirmation either of us filed.** `runner set r1` — the first name `/kickoff` §3
  suggests — was refused, and the implementer read an empty state directory plus a missing
  `$HOME/scratch` as a dead session's leftovers. They are also what a **live** session looks like
  in its startup window, and `r1` was about three minutes into one; the refusal was correct and the
  guard did its job. Retracted on the issue with the wrong comment left standing, because a
  retraction that deletes its own subject leaves the next reader a conclusion they cannot check.
  The architect over-read the same gap independently, from an isolated-state measurement whose
  "gone" session had never existed as a process. **The defect is that `runner set` has one signal
  where a watch has six:** quince#95 split `starting` out of `dead` precisely because they read
  identically and want opposite remedies, and a runner name has no such class — "the directory
  exists" has to answer live, starting and abandoned at once. Two careful readers got it wrong the
  same way on the same day, which is better evidence for that than either confirmation was.
  It surfaced only because a comment appeared under the implementer's own identity that the
  implementer had not written: **the forge cannot distinguish concurrent sessions in a seat.**
  `forge-watch` went to real trouble over runner ownership locally (quince#111, #174), but a PR
  comment carries the App, not the runner — so "the author replied" is not the claim it looks like.
  **Also:** a CI red on an
  unrelated PR was diagnosed rather than re-run: `forge-watch-stop-test` asserts a signalled child
  is dead without reaping it, and a zombie answers `kill -0` — the same file handles that exact
  hazard twenty lines below, with a comment naming it. A rebase gave the control run (identical
  tree, FAILURE then SUCCESS), which also shows the flake is not sticky.
  **The flake's fix is in, and the question under it was ruled rather than left.** The reviewer
  ruled that `stop_one` should wait for exit — bounded, escalating to `SIGKILL`, saying which
  happened — because `kill` returning 0 means the signal was *queued*, and every skill prescribes
  `stop`, **then** arm, which is quince#50's race if the watcher is still writing. Filed as
  quince#221; the test fix is quince#223 and stands either way. That fix took the pattern rather
  than the one site CI hit, and declined the obvious bare `wait`: the killer there is the tool under
  test, so `wait` would turn a failing assertion into a **hanging suite**. Proven in both directions
  deterministically, because the suite was green before and after — the old assertion `WOULD-FAIL`
  against a real zombie, `gone()` returns true, and a genuinely-running process still returns false
  at the bound rather than hanging. The window is also wider than "rare": 199 of 200 raw trials
  caught the child as a live-answering zombie, and it is the surrounding `$(...)` fork that usually
  closes it. **The CI failure was never reproduced locally, and the PR says so.**
  **Owed:** quince#213 green and awaiting re-review; quince#221 unimplemented; nobody has
  established what actually built the two boxes, which sits in quince#205's scope.
  ([quince#213](https://github.com/novkostya/quince/pull/213),
  [quince#216](https://github.com/novkostya/quince/pull/216),
  [quince#214](https://github.com/novkostya/quince/issues/214),
  [quince#218](https://github.com/novkostya/quince/issues/218),
  [quince#219](https://github.com/novkostya/quince/pull/219),
  [quince#141](https://github.com/novkostya/quince/issues/141),
  [quince#205](https://github.com/novkostya/quince/issues/205),
  [quince#211](https://github.com/novkostya/quince/issues/211),
  [quince#221](https://github.com/novkostya/quince/issues/221),
  [quince#223](https://github.com/novkostya/quince/pull/223))
- 2026-07-29: **Retirement record, runner `r2` — the session was wrong four times and caught three of
  them itself, which is the only number here that says whether two-seat review is working.** Took
  quince#189 (a documentation issue about retired dev containers) and landed it in four PRs:
  quince#213, #216, #223 and devlog#126. **The corrections are the record worth keeping**, because
  the instances live on the PRs and the *rate* lives nowhere. Self-caught, before anyone saw them:
  a fabricated `issuecomment-` id invented while writing a citation and corrected against the API
  before the commit; a proposed `owed` fix on quince#227 that the live queue falsified within the
  hour (five of six open PRs carried no runner prefix, so the filter would have reported *nothing
  owed* for all of them — under-reporting, quince#41's class, worse than the over-reporting it
  fixed); and the decision not to reuse `/tmp/pr-body.md` after the first PR, which turned out to
  be luck rather than judgement when quince#226 revealed a second session shared the path.
  **Caught by the reviewer, one:** propagating `/etc/quince-devct-stamp` "on both boxes" into a
  second document — an inherited claim, in a PR whose thesis is that documents outlive the reality
  they describe. **Caught by the reviewer, once more and worse:** the journal entry in devlog#126
  still asserted quince#211 "confirmed on first contact" **after** the session had retracted that
  claim on the issue itself — the correction sat in a comment while the withdrawn version was
  heading into the permanent record. So: **four corrections, three self-caught, one class the
  session could not catch alone** — both reviewer catches were *stale inherited text*, which is
  precisely what a second reader is for and precisely what a session re-reading its own work does
  not see.
  **What the mis-measurement cost, and why it is the most useful thing here.** The session reported
  runner name `r1` as a dead session's leftover, from an empty state directory and a missing
  `$HOME/scratch`. Both are also what a **live** session looks like three minutes into startup, and
  `r1` was. Retracted with the wrong comment left standing, because a retraction that deletes its
  own subject leaves a conclusion nobody can check. **The architect over-read the same gap
  independently, inside the hour**, from an isolated-state measurement whose "gone" session had
  never existed as a process, and said so unprompted. Two seats, same missing distinction, same
  day: `runner set` has **one signal where a watch has six** (quince#95 split `starting` from `dead`
  for exactly this reason). That reframing is worth more than either original report, and neither
  seat could have produced it alone.
  **It surfaced only through an accident that is itself a defect:** a comment appeared under this
  session's own identity that this session had not written. Two runners, one App — the forge cannot
  distinguish sessions within a seat, permanently, by the design of `decisions/0014`. Filed as
  quince#227 with both consequences: the loop side (`owed --author @me` returns another session's
  PRs, so the `Stop` hook blocks a session whose queue is empty) and the review side, which is
  worse and has no local workaround — the architect reports that "the implementer" in several review
  comments today may have addressed the wrong session, and went a full afternoon without knowing
  there were two.
  **Filed and not fixed, each with its evidence:** quince#221 (`stop` prints "stopped watcher" when
  `kill` only *queued* the signal, while every skill prescribes stop-then-arm — ruled by the
  architect, unimplemented); quince#227; quince#230 (the branch convention is documented two ways
  two lines apart, and runner-ownership work rests on which one a session reads); devlog#129 (a
  retirement record that goes `DIRTY` after its author retires has no permitted owner — `CLAUDE.md`
  puts conflicts with the author, and `/retire` guarantees every retirement produces a candidate;
  it is happening to devlog#127 now).
  **Owed:** quince#221 and quince#230 want a ruling before code. Nobody has established what
  actually built the two boxes — `/etc/quince-devct-stamp` is absent on both, measured one seat
  each, which sits in quince#205's scope.
  ([quince#213](https://github.com/novkostya/quince/pull/213),
  [quince#216](https://github.com/novkostya/quince/pull/216),
  [quince#223](https://github.com/novkostya/quince/pull/223),
  [devlog#126](https://github.com/novkostya/quince-devlog/pull/126),
  [quince#221](https://github.com/novkostya/quince/issues/221),
  [quince#227](https://github.com/novkostya/quince/issues/227),
  [quince#230](https://github.com/novkostya/quince/issues/230),
  [devlog#129](https://github.com/novkostya/quince-devlog/issues/129),
  [quince#211](https://github.com/novkostya/quince/issues/211))
- 2026-07-29: **The approving seat's identity guard was not merely absent — it was exercisable, and
  the boundary it was supposed to hold had been open since the implementer identity moved to an
  App.** `bin/gh-arch` and `bin/gh-review` asserted *"the implementer identity is absent"* by
  checking for a bot token and nothing else; `decisions/0014` moved that identity to a GitHub App,
  so both wrappers were making the assertion by checking for a credential that no longer carries
  it. quince#203 had fixed exactly this in `preflight`'s arch arm and said it was the first of
  them — this is the remainder, and the more load-bearing half, because `preflight` gates whether a
  box *starts* while these gate every action it takes. **What the review measured is worse than
  what the PR claimed**, and the difference is the entry: the author, on a runner holding no
  reviewer key, could show only that `main`'s wrappers walked past the boundary and stopped on
  their own missing credential. Run on the architect box, `main`'s `gh-review` **completed the mint
  and reached 5 repositories** with an implementer App key sitting beside the reviewer key — so a
  verdict cast from such a box would have been indistinguishable from a correct one. Unguarded was
  the prediction; exercisable was the fact, and only the other seat could establish it. The
  negative control matters as much: on a correctly provisioned arch box with no coder key the guard
  does not false-positive. **The suite was complete in one direction and silent in the other** —
  quince#198 had covered `gh-coder` refusing beside both approving credentials, thoroughly, while
  nothing anywhere asserted that an approving wrapper refuses beside a coder key. quince#103's rule
  in a second place: *checking one direction of a two-directional property is not a check*, and a
  suite that thorough on one side reads as thorough on both. Six assertions added and **driven
  against the unfixed wrappers first — 14/6, then 20/0** — because a test that cannot be made to
  fail is not testing. **Two things the author got wrong and one it declined to decide:** the
  PR's own Reproduce recipe used `git stash push`, which works only in the author's pre-commit
  working tree and prints `20/0` twice from a clean checkout — the opposite of the point that
  section makes; corrected in place, with the broken version left visible, since a recipe that only
  works where it was written is the same defect class as a document that only describes the box it
  was written on. And `bin/gh-bot` turned out to have **no** boundary check at all, live only
  because the account is suspended; filed as quince#232 rather than folded in, because
  `decisions/0014` condition 1 keeps that file as an intact record and whether a guard counts as
  tidying it away is a ruling, not a patch. **Both were settled within minutes of this entry being
  written, and the first draft of it said otherwise** — a two-line record of a moving reality,
  falsified before its own diff finished rendering, which is the entry's thesis arriving on the
  entry. quince#232 was **ruled** at `18:43:32Z`, twenty-three seconds after this PR opened: add the
  checks mirroring `gh-coder`, with suite assertions driving both directions, chosen over
  documenting the hole (does nothing if the account is restored) and over refusing unconditionally
  (which would destroy the very artifact condition 1 protects — a wrapper still runnable and still
  failing honestly is live evidence, where a comment asserting it is not). And quince#204's fourth
  item is **answered** in quince#233: `deploy/runner/provision` places no credentials at all — it
  names those paths only to read them, in one role-mismatch guard — so the hole was never reachable
  by provisioning. **Still owed** from that grep: the same guard fires only when *this* role's token
  is absent AND the other's is present, so an arch box holding both its own token and a bot token
  passes it; guarded twice downstream by `preflight` and `gh-arch`, so not a live hole, but narrower
  than it reads, and it compares bot against arch only — knowing nothing of either App key.
  ([quince#231](https://github.com/novkostya/quince/pull/231),
  [quince#204](https://github.com/novkostya/quince/issues/204),
  [quince#203](https://github.com/novkostya/quince/pull/203),
  [quince#232](https://github.com/novkostya/quince/issues/232),
  [quince#232 ruling](https://github.com/novkostya/quince/issues/232#issuecomment-5122106999),
  [quince#233](https://github.com/novkostya/quince/pull/233),
  [quince#198](https://github.com/novkostya/quince/pull/198),
  [quince#103](https://github.com/novkostya/quince/issues/103),
  [quince#157](https://github.com/novkostya/quince/issues/157))
- 2026-07-29: **The fifth wrapper had no boundary check at all, and the suspension everyone reasoned
  from stopped the credential working without stopping the message recruiting someone to recreate
  it.** quince#232 closed by quince#233: `bin/gh-bot` — the legacy implementer wrapper — asserted
  `approver ≠ author` *not at all*. Not a stale check naming a credential that had moved, which was
  quince#204's defect one PR earlier; none. It was the only one of five forge wrappers that could not
  refuse a second identity, and the omission survived every audit **because its four neighbours were
  correct**: a suite thorough in one direction reads as thorough in all of them. **The issue was
  filed on the argument that the hole was not live** — `quince-bot` was suspended on 2026-07-28, so
  every call fails at GitHub whatever else the box holds — and that argument was the weak part of it.
  The architect box measured why: `main`'s `gh-bot` there answers *"no bot token — place one"*, so a
  session doing what the tool tells it places the implementer credential on the box already holding
  the reviewer key and the architect token, **building the author-and-approve machine while following
  an instruction**. Suspension disables the credential; it does not disable the recruitment. That is
  quince#157's *"an environment refusal invites the wrong repair"* as a live property of a real box
  rather than a principle — on that box, before the fix, the wrong repair was the **only** thing
  offered. **Ruled by the architect** over documenting the hole (does nothing if the account is
  restored) and over refusing unconditionally, which would have destroyed the artifact
  `decisions/0014` condition 1 protects: a wrapper still runnable and still failing honestly is live,
  checkable evidence, where a comment asserting the same is not. **The two-seat pattern is now the
  finding, twice in two PRs and in the same direction both times.** On quince#231 the author could
  show only that the guard was absent; the approving box showed it *exercisable*. Here the author
  could offer only a negative control — the guard stays silent on a correctly provisioned implementer
  box — and the approving box supplied the positive one. Neither half was reachable from the other
  seat, by construction: the credentials are the thing being tested and no box holds both. **A
  question that had outlived two PRs was closed by a grep in the neighbourhood.** quince#204's fourth
  item — whether `deploy/runner/provision` makes this reachable by accident — was booked unproven by
  quince#204 and again by quince#231; `provision` **places no credentials at all**, naming those
  paths only to read them in one role-mismatch guard. Not reachable by provisioning; credentials are
  placed by hand. The grep then produced quince#234, and it is **the third instance in one day of a
  single shape**: that guard fires only when *this* role's token is absent AND the other's is
  present, so a box holding both passes it — and it compares bot against arch only, knowing nothing
  of either App key, which is to say it is a guard naming a credential set that moved underneath it,
  exactly like quince#203 and quince#204. Guarded twice downstream by `preflight` and `gh-arch`, so
  not live; recorded because three instances of one pattern in a day is the pattern, not the
  instances. **What the RULING got wrong, and the attribution is the point:** its sizing note said the
  PR should not grow to carry a second fix and then stopped — one sentence covering PR scope while
  leaving *whether to file* unaddressed, from the seat whose rulings are meant to be unambiguous
  instructions. The finding stayed in prose with nothing pointing at it, which is the precise decay
  that let quince#204's fourth item survive two PRs. The architect filed it as quince#234 and
  corrected the **note** rather than the reading: **filing is free and not in tension with sizing**,
  and an owed item with no issue behind it is an owed item that will be owed forever. The author's
  share is real and smaller than it first wrote: given a sentence that did not reach the question, it
  supplied a default instead of asking, and the first draft of this entry recorded the whole thing as
  a misreading. **The reviewer asked for that to be changed, which is why it is worth recording** —
  *"the author should have read more carefully"* is advice nobody can act on, since every misreading
  in this project's history looked reasonable from the inside, while *"a ruling conflated PR scope
  with filing scope"* names a thing one seat can change about how it writes them. It is also the only
  place this entry blamed a reader rather than an artifact, which is exactly what it faults `main`'s
  `gh-bot` message for not doing.
  ([quince#233](https://github.com/novkostya/quince/pull/233),
  [quince#232](https://github.com/novkostya/quince/issues/232),
  [quince#232 ruling](https://github.com/novkostya/quince/issues/232#issuecomment-5122106999),
  [quince#234](https://github.com/novkostya/quince/issues/234),
  [quince#231](https://github.com/novkostya/quince/pull/231),
  [quince#204](https://github.com/novkostya/quince/issues/204),
  [quince#203](https://github.com/novkostya/quince/pull/203),
  [quince#157](https://github.com/novkostya/quince/issues/157))
- 2026-07-29: **A guard that had no live coverage on either box, and a flag that vanished silently —
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
- 2026-07-30: **Ten fixes in one overnight run, and the three that recur are all one shape: a check
  that reports on a scope narrower than the word it prints.** Runner `r4`, unattended, closing
  quince#224, #199, #221, #200, #238, #237, #240, #243, #196, #149 and #245 across ten PRs
  (quince#235, #248, #250, #252, #253, #254, #257, #258, #259, #255), with quince#247 and #256 filed
  on the way. Grouped as one entry rather than ten because the cross-cutting findings are worth more
  than the individual diffs, and because four of the ten are the *same defect* in different files.
  **THE RECURRING SHAPE — a gate that says `clean` about something it never read.** quince#41
  established that a gate which cannot run must refuse rather than exit 0. Four of tonight's ten are
  that equivalence reached from the *other* side, where the gate **ran**, proved its matcher, and
  printed a true statement about the wrong scope: `gates-sh` linted a hand-maintained list nothing
  compared against disk, so `deploy/e2e-run.sh` had never once been shellchecked and the two
  identity-boundary wrappers of quince#198 went green unread (#200); `privacy-check` announced
  `+ text`, silently dropped an empty `--text`, and still said `clean` — the exact invocation canon
  mandates before every merge (#237); the same gate printed `clean` over commit author and committer
  identity it never sweeps, which is how a personal name on a `.lan` host reached devlog `main` in
  three commits (#196); and `forge-watch` emitted `actor=` where its own comment promised `unknown`,
  because jq's `//` falls through on `null` and not on the empty string `gh` actually returns (#199).
  The remedy in each is the same and it is not more patterns: **name the fields, not the category.**
  `privacy-check`'s scope line now reads `diff:added + message:subject,body + author:name,email +
  committer:name,email + branch-name`, so the *next* uncovered field is visible as an absence rather
  than discoverable only by a leak.
  **THE SECOND SHAPE, three arrivals: presence is not capability.** quince#121 was
  presence-is-not-freshness, quince#234 presence-is-not-usable, and quince#255's review found
  presence-is-not-*this-seat's* — `command -v ./bin/gh-coder` tests whether the **script** exists, and
  all four wrappers are committed, so every clone on every box carries every one of them. The first
  arm always matched, the `gh-arch` arm was unreachable, and on the architect box the selection handed
  a correct boundary guard an impossible question: it chose `gh-coder`, which refused with *"a REVIEWER
  APP KEY is present … Remove it"* — telling a cold architect session, in its first act, to delete the
  credential that box exists to hold. **The guard was right; the caller was wrong**, which is
  quince#157's "an environment refusal invites the wrong repair" reached *through* a working control.
  Fixed by asking each wrapper to act rather than asking whether it exists.
  **TWO ISSUES WERE WRONG ABOUT THEIR OWN MECHANISM, and measuring inverted the fix both times.**
  quince#224 reported a usage error exiting `127`; that is the `bash -c` form. `bash <file>`, which is
  how a script actually runs, exits **1** — an *allocated* code in that contract meaning "a bare
  reference does not resolve", so a malformed argument was **impersonating a real finding** rather than
  landing on an unused code. The comment the issue asked to correct was right, and was kept. quince#243
  reported the approved head as unfetchable after a force-push and proposed replacing `range-diff` with
  an API patch-hash compare; measured, `git fetch origin <full-40-char-oid>` **works** and only the
  abbreviation fails, so the proposed fix would have traded the rebase-aware tool for the weaker one on
  a false premise. `range-diff` stays primary. Both corrections are recorded on the issues, not only in
  the PRs, because an issue read later is where the wrong mechanism would otherwise survive.
  **THE GUARD CAUGHT WHAT THE AUTHOR DID NOT, five times.** quince#238's fix mattered most: `owed_role`
  knew only the two retired credentials, so on the implementer box every arm missed, the role resolved
  to `none`, and the `Stop` hook's `none` branch **fails open by design** — the guard against ending a
  turn with an open PR and no watch was dead on the one seat that opens pull requests. Proven live,
  same payload, before and after. **It failed in a shape that reads as normal**, which is why two
  earlier sessions sat inside it: on a box with genuinely no credential, *"whether a watch is owed was
  NOT checked"* is the expected output. Separately, this session lost its watch to its own last action
  **three times** — arming, then pushing or commenting, which is an event on a PR it watches — and once
  did so *having just written the prediction that it would*. Knowing the rule did not help; the `Stop`
  hook did, every time. The ordering is already canon (`/kickoff` §6: arm **last**, after a foreground
  catch-up tick) and the lesson is that prose loses to habit even when the habit is one paragraph old.
  **A red check was infrastructure and classifying it first was worth the minutes.** quince#259's
  `gates` failed in 7s where its siblings took ~1m15s: a Docker Hub connection reset pulling the
  **pinned** shellcheck image, `Error 125` — the container never started, so the gate proved nothing in
  either direction. Reproduced CI's exact scoped invocation locally as clean before concluding it.
  Remedy was close-and-reopen (`CLAUDE.md` §5 rung 3) because the branch was current and **no agent
  seat can re-run a workflow run**; the approval survived, as canon says it does. The log incidentally
  confirmed #200's new coverage gate running on CI — `all 34 shell file(s)` — and that it ran *before*
  the registry call, which is what made the failure cleanly attributable rather than a guess.
  **A HARNESS OUTAGE ALMOST STRANDED FINISHED WORK, and the escape is worth keeping.** For roughly two
  hours the Bash safety classifier was unavailable, reducing the session to commands matching a
  permissions allowlist **literally, by prefix** — `git status` ran, `cd X && git status` and `git -C X
  status` did not, so the session could not enter its own scratch clone, and `Write` was gated too. A
  finished, committed, privacy-swept commit was unreachable. It landed because **git can fetch from a
  local path**: `git fetch /root/scratch/<runner>/quince <branch>` then `git push origin
  FETCH_HEAD:refs/heads/<branch>`, both allowlisted. Filed as quince#256 with the sharper half — **`make
  gates-sh` is missing from the allowlist** while every sibling target is present, so during an outage
  the most-run gate in the repository cannot run and no PR can honestly be opened. Nothing was lost, and
  by luck rather than design: the outage landed between a sweep and a push.
  **Owed:** quince#239 stays **open on purpose** — items 1–2 landed in #255, and item 3, a gate refusing
  unscoped `/tmp/` paths in committed skills, needs code-fence awareness, because the only two remaining
  matches in `.claude/**` are *prose documenting the defect* and a naive grep flags the text that records
  the fix. quince#247 (a pending check is `""` on one fetch path and `null` on the other) and quince#256
  are filed and unruled. quince#196's pattern half is private-layer work and its history rewrite is
  Operator-only. quince#222 was **observed live** while this ran — the architect's `update-branch
  --rebase` on #255 reported `actor=quince-coder[bot] kind=commit`, naming the seat that did not act —
  which upgrades that issue from a reading to a measurement. And devlog#127 is **deliberately
  stranded**, not waiting on anybody: it is r1's retirement record, its author has retired, and rather
  than rule the collision of the two rules the Operator **deferred** it — *"leave them stranded for
  now"* — pending devlog#30, the journal restructure that removes the shared append target and with it
  this whole class. The distinction matters for whoever reads the queue next: **the defect is
  unresolved and the parking is deliberate**, which is why devlog#129 stays open rather than closed.
  The Operator's own words retain the finding — *"a retirement record orphaned by a merge still has no
  permitted owner, and the three candidate remedies are all still open"* — so what was stale in the
  first draft of this entry was the **status**, not the diagnosis. The cost is accepted and recorded:
  r1's retirement record may never enter the journal, and its PR is the only place that text survives.
  ([quince#235](https://github.com/novkostya/quince/pull/235),
  [quince#248](https://github.com/novkostya/quince/pull/248),
  [quince#250](https://github.com/novkostya/quince/pull/250),
  [quince#252](https://github.com/novkostya/quince/pull/252),
  [quince#253](https://github.com/novkostya/quince/pull/253),
  [quince#254](https://github.com/novkostya/quince/pull/254),
  [quince#257](https://github.com/novkostya/quince/pull/257),
  [quince#258](https://github.com/novkostya/quince/pull/258),
  [quince#259](https://github.com/novkostya/quince/pull/259),
  [quince#255](https://github.com/novkostya/quince/pull/255),
  [quince#247](https://github.com/novkostya/quince/issues/247),
  [quince#256](https://github.com/novkostya/quince/issues/256),
  [quince#239](https://github.com/novkostya/quince/issues/239),
  [quince#222](https://github.com/novkostya/quince/issues/222),
  [devlog#129](https://github.com/novkostya/quince-devlog/issues/129))
- 2026-07-30: **A classifier outage is a DEGRADED session, not a broken box or a finished one — ruled,
  after it cost the architect seat six and a half hours of unwatched queue.** Operator ruling, relayed
  on quince#256: when the Bash safety classifier is unavailable only commands matching an allowlist
  entry **literally, by prefix** run — one line, no `cd`, no chaining, no multi-line arguments, and
  `Write` is gated too. Both natural readings of the refusal are wrong: the box is fine and the session
  is not finished. Correct behaviour is to keep working inside the uncomposed allowlist, **commit
  early** because an uncommitted edit is unsavable, salvage a stranded commit by fetching from the
  local path (`git fetch /root/scratch/<runner>/quince <branch>` then `push origin
  FETCH_HEAD:refs/heads/<branch>`, since git can fetch a local path and `git config` is allowlisted so
  the helper can be set), and — without exception — **do not open a PR you cannot gate**: an ungateable
  PR is not a lowered bar, it is an unproven claim. A session that reaches that point and stops has
  behaved correctly and should say so. **What the outage actually cost, measured rather than
  estimated:** the architect's watch died at `19:54Z` and could not be re-armed, because arming is a
  `Bash` call; the queue ran unwatched for **6h29m** while four PRs opened and one was merged by the
  Operator executing an approval already cast. Nothing was lost, and nothing was covering it either —
  the fallback heartbeat is `ScheduleWakeup`, which is unavailable outside `/loop` dynamic mode, so the
  floor under an architect session is the watcher's own `--max-wait` and the watcher is what the outage
  removes. **THE ROOT CAUSE WAS NOT THE MISSING TARGET.** The issue was filed as *"`make gates-sh` is
  not on the allowlist"*; the supervisor's sweep found **17 of 32** `make` targets unlisted, the
  language gates all covered and not one shell suite — and then found the sharper fact: **the allowlist
  is directory-anchored by omission.** There is no `make -C` and no `git -C` form, so `make gates` (which
  *is* allowlisted, including `SCOPE=`) runs only in the launchpad while the work sits in
  `$HOME/scratch/<runner>/quince`. *"No gate can run"* was true in effect and wrong in mechanism, and
  the seventeen entries would not have fixed it. **Three ordered PRs, and the ordering is a ruling
  rather than a preference:** the `-C` forms alone first (unblocking, independently testable), then the
  seventeen entries, then an allowlist **totality gate** — every `make help` target has an entry and
  every `Bash(make …)` entry names a real target, which is the third check of that exact shape here
  after quince#75 and quince#107. **The sequencing came from a supervisor SELF-CATCH, ratified rather
  than imposed:** that seat first proposed bundling the entries with the totality gate, corrected its
  own framing unprompted one message later to `-C`-first-alone, and the Operator ratified it — citing
  `revamp.md`'s record of `pr.6` making the cheap half wait on the thorough half for a week. It also
  superseded the architect's independent bundling of the entries with the `-C` forms. Recorded this way
  because `revamp.md` tracks how much of this loop needs outside judgement and its standing finding is
  that the cross-seat half is smaller than claimed; scoring a self-catch as an Operator intervention
  would inflate exactly that metric, permanently, in the direction already under suspicion.
  **`Bash(make -C *)` unscoped was refused outright rather than escalated:** an allow entry means *run
  without classifier review*, so an unscoped `-C` means run any Makefile anywhere unreviewed, which is a
  different grant from running this repo's gates. The acceptable shape is named in the same ruling so
  PR-1 is executable rather than blocked on the same refusal — **scoped to the scratch root**
  (`make -C /root/scratch/**`, `git -C /root/scratch/**`), with the glob verified to match before it is
  claimed to, since a pattern matching nothing would reproduce this defect inside its own fix. **What is
  still unproven, and deliberately not asserted:** whether `deny` rules survive an outage. The probe is a
  denied *read* (`Read(~/.config/quince/**)`, enforced and demonstrated), not a push to `main` — the
  original filing declined the dangerous test and was right to; whoever runs the safe one adds the answer
  to the clause rather than leaving it inferred. **And the same surface refuses from the other side,
  unruled:** a *working* classifier blocked `bin/gh-review pr merge` twice and `bin/gh-arch pr merge`
  answered `Denied by user`, with no `deny` rule matching `pr merge` — so "the classifier is down" and
  "the classifier says no" strand a session identically and only the first is ruled. The day before, the
  same wrapper ran twelve merges with zero refusals, so `CLAUDE.md` §6's documented intermittency is now
  observed from both directions. Recorded on quince#262, where the architect then published a false
  conclusion from those refusals — asserting a merge was owed on a PR the Operator had merged nine
  minutes earlier — because **a refusal is not a state reading**, and no object was re-read between the
  last refusal and the claim.
  ([quince#256](https://github.com/novkostya/quince/issues/256),
  [quince#262](https://github.com/novkostya/quince/pull/262),
  [quince#75](https://github.com/novkostya/quince/issues/75),
  [quince#107](https://github.com/novkostya/quince/issues/107))

- 2026-07-30: **A gate that containerises its work and prints an accounting line reported `clean` over
  a suite with fifteen failing assertions — and the accounting line was what swallowed the failure.**
  `make gates-sh` exited **0** while `forge-watch-composition-test` failed 15 of 22. A shell `if` block
  exits with the status of the **last command it ran**, and the recipe chained the container run and
  its summary `echo` with `;` — so the gate reported the echo. **Only the container arm was affected,
  and it is the default: the one CI runs.** The `QUINCE_SH_RUN_HERE` arm was correct *by accident*,
  because `$(MAKE) …` happens to sit last in it. Scoped to the nineteen suites — `sh-lint-coverage`,
  `allowlist-coverage`, `suite-coverage`, shellcheck, the `curl -k` ban and the title-interpolation
  check are separate recipe lines and did still fail correctly — **and the window was not empty:
  `gate-scope-test` had been failing three assertions on every CI run since the containerisation
  landed**, invisible until the exit code was honest. `fatal: detected dubious ownership in repository
  at '/src'` — `actions/checkout` marks the *host* path safe and the container sees `/src` under a uid
  its root does not own, so it could never reproduce on a box. Two green `main` runs that day were
  green over a real failure. The first run with the fix went red immediately and named them
  (quince#277). **A gate whose failure mode is silence does not get the benefit of the doubt about
  what it was silent about** — so quince#246 broke two things in one commit and the second hid the
  first, which is a sharper lesson than two independent bugs. **The irony is the finding.** Three lines above the bug sits quince#246's own comment saying a gate that containerises
  *some* of its work and says `clean` cannot be told from one that containerised all of it, citing
  **quince#41 — the three-exit-code contract, where `0` must mean clean**. The same change wrote the
  comment and broke the exit code the comment is about. **It was found by reading suite output, not by
  a gate**: registering a new suite for quince#265 broke the composition test, and the ladder said
  `clean`. Every totality gate this project has built answers *"is the list complete"*; not one asks
  *"does a failure still reach the exit code"*. The proof drives the **real** recipe with a stubbed
  `RUNTIME` that fails only for the suite image — a hermetic mini-Makefile reproducing "the pattern"
  would pass forever while the recipe rotted — and against the unfixed recipe it fails exactly the
  three bug-detecting assertions while all three controls hold. **This entry went stale between
  drafting and review, and that is the record's own failure mode appearing in the record:** the
  paragraph above hedged with *"no evidence a suite actually broke unnoticed"* — and the author had
  already published the retraction, in another thread, five minutes after opening the journal PR and
  before any reviewer read it. The fourth such entry tonight. A journal written at the end of a unit
  of work is written at the moment its author knows least about what the work found.
  ([quince#274](https://github.com/novkostya/quince/issues/274),
  [quince#275](https://github.com/novkostya/quince/pull/275),
  [quince#277](https://github.com/novkostya/quince/issues/277),
  [quince#246](https://github.com/novkostya/quince/issues/246),
  [quince#41](https://github.com/novkostya/quince/issues/41))

- 2026-07-30: **The wake filter has never suppressed anything on the architect seat, because ownership
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

- 2026-07-30: **A skill can carry its own fix and be unable to apply it: `/architect` §1 said "declare
  first, before anything reads or writes state", and §0 ran first and read state.** Declaring a runner
  name **relocates** the state directory, so `status` read before it answers about the undeclared
  top-level path — and for a session resuming a name that has state, that reports **`absent`** where the
  truth is **`dead`**. Those are the two answers §0 spends twenty lines insisting must never be confused:
  `dead` carries an accrued observation to re-arm from, `absent` says nothing was ever armed. Measured
  2026-07-29 on the architect box: `absent (exit 4) … Cold start; nothing inherited` at 15:03:58Z, and at
  15:08:24Z the session found that declaring had moved the directory out from under that answer. It was a
  genuine cold start, so nothing was lost — **the defect is that the report could not have told the two
  apart.** **And the instance that FILED quince#241 was worse: both answers were `dead`** —
  `no_watcher_record` at the undeclared path against `no_process` at `arch1/`, whose observations were
  **2h43m apart** (measured by the architect seat, whose state directory still holds the orphaned file;
  corroborated here only in structure — this box has per-runner directories and no top-level state,
  because every session on it declared first). Where `absent`/`dead` differ in the WORD and mislead by
  reasoning, `dead`/`dead` differs only in CONTENT — so a session that reports the right answer, exactly
  as §0 instructs, still re-arms against the wrong observation, and no amount of careful reading
  recovers it. Only declaring first makes the two distinguishable at all, which is the stronger argument
  for the fix and the one the issue came from. `/kickoff` had the same split across §0 and §3. Same shape as quince#100: a rule that says
  *what* and not *when*, where the natural order is the broken one. **The declaration moved INTO §0
  rather than the sections being swapped**, because renumbering would ripple into `loop-protocol.md`,
  which both skills share — and drift between those two files is what quince#54 is about. **One claim was
  measured rather than asserted on the way**: re-declaring a runner name is a clean no-op from the SAME
  session, but from a different session a name whose holder is provably gone is **reclaimed** rather than
  refused (quince#211) — so "a taken name is refused" holds only while the holder is live, and reclaim is
  the path a resuming session actually takes.
  ([quince#241](https://github.com/novkostya/quince/issues/241),
  [quince#278](https://github.com/novkostya/quince/pull/278),
  [quince#100](https://github.com/novkostya/quince/issues/100))

- 2026-07-30: **`2>/dev/null` on a command does not cover the SHELL's own redirection error, and the
  liveness probe leaked one into every `Stop`.** `_rs_alive()` reads each `/proc/<pid>/environ` as
  `$(tr '\0' '\n' <"$f" 2>/dev/null || true)` — but `tr` never runs: the shell performs the `<`
  redirection before exec, so a failed open is reported on the *shell's* stderr, which a redirection
  attached to `tr` cannot reach, and `|| true` catches the status rather than the text. Seen in the wild
  as `can't open /proc/<pid>/environ: Permission denied` printed above a correct reclaim; `owed --hook`
  runs on every `Stop`, so it can surface at the end of any turn, attributed to nothing, exactly where a
  session is deciding whether it owes a watch. **The trigger is a TOCTOU no guard closes** — the process
  is alive at glob time and at `[ -r ]` time and a **zombie** by the time we open, and a zombie's environ
  returns EPERM rather than ENOENT. **Root cannot synthesise that**, which is the durable half: three
  fixtures were tried and rejected — a directory named `environ` (open(2) SUCCEEDS on a directory, so the
  error is `tr`'s and the old redirect already covered it), a unix socket (uncreatable without a helper
  the boxes lack), a nonexistent path (leaks correctly, but `-r` skips it). A `FORGE_PROC_ROOT` seam was
  built and then **reverted**: an injection point with no injector is worse than none. So the suite proves
  the idiom against a genuinely unopenable path and then asserts the SHIPPED LINE uses the fixed form —
  the second is what makes the first a regression guard rather than a true statement about POSIX shell.
  ([quince#279](https://github.com/novkostya/quince/issues/279),
  [quince#280](https://github.com/novkostya/quince/pull/280))

- 2026-07-30: **The privacy banner said how MANY patterns and never WHICH list, so two boxes swept with
  materially different matchers for hours and both printed `clean`.** Both banners were internally
  consistent and both canaries passed — a canary proves *a* matcher, never the **same** one. It was
  caught by a human comparing two banners quoted in two PR bodies, which is not a control. The gate now
  names the list's commit and whether it is behind its tracking ref. **Local-only, and the wording is the
  careful part:** `@{upstream}` is the LAST-FETCHED ref, so the claim is *"as of this box's last fetch"*
  and says so, while `no upstream` and `not a git worktree` report **cannot tell** rather than collapsing
  to a reassuring `0 behind` — because a freshness claim that overstates what it knows converts *unknown*
  into *verified current*, which is this defect wearing a fix's clothes. **Option 1 —
  `preflight` asserting a LIVE fetch — was deliberately NOT taken**: it makes whether a box may *start*
  depend on network reachability, on a pair of hosts whose only recovery seat is the Operator's Mac, and
  that is a ruling rather than an implementer's call. **This was also the first thing quince#275's fixed
  exit code caught in anger**: `gates-sh` returned 2 and named `preflight-test` at 43→41, because the new
  line was first called `lists provenance …` and `preflight` quotes the first line beginning `lists` — so
  it reported provenance where a count belongs. Before that morning the ladder would have said `clean`.
  **And the assertion written to pin the anchoring does not pin it**, checked rather than assumed: after
  the rename no banner line begins with `lists` except the count, so reverting the anchor leaves the
  suite green either way. Recorded as untested, with the reason, rather than left to read as coverage.
  ([quince#220](https://github.com/novkostya/quince/issues/220),
  [quince#281](https://github.com/novkostya/quince/pull/281),
  [quince#275](https://github.com/novkostya/quince/pull/275))

- 2026-07-30: **`provision` mapped a ROLE to a FILE, the file stopped existing when the identity moved,
  and the private-layer section went inert on a live box — kept working only by an undocumented
  hand-repair.** `LAYER_TOKEN="$_role_token"` meant `implementer -> quince-bot.token`; `decisions/0014`
  moved that identity to a GitHub App key, so on a current box the guard took the skip branch and
  `provision`'s documented repair path was closed. The layer stayed fresh because somebody had wired the
  helper to `gh-coder` by hand — load-bearing, and recorded nowhere. **The role→file mapping was the
  defect, not its implementer half:** pointing at a different FILE would rot the next time an identity
  moves, and that is already scheduled (quince#253). Operator ruling, three parts, all taken: the
  credential is chosen by asking **which wrapper can ACT** (quince#255's rule — all four wrappers are
  committed, so a presence test cannot tell two seats apart), the helper **fails closed** like
  `bin/git-coder` so a refusal emits no credential rather than a blank password, no usable credential is
  a **refusal** rather than a note with a bootstrap carve-out, and an existing helper is **not
  overwritten** when it differs — naming its shape, never its value, plus the command that clears it.
  **The decision moved above the dry-run exit**, which is beyond the ruling and flagged as such: it
  mutates nothing, it refuses before the box is touched as the role guard already does, and it is what
  makes all three behaviours observable without provisioning the host the suite runs on. `provision-guard-test`
  11 → 20, and **13/7 against `main`** — the two new assertions that pass there are the negative one and
  the control, which is the shape that says a suite measures the defect rather than the weather. **Two
  self-inflicted bugs, both found by running:** `die` was defined BELOW its first use, so the new refusal
  exited **127 with no message** — quince#224's exact shape, in the code written to stop silent failures
  — and the suite's credential overrides meant the REAL `gh-coder` correctly could not mint, so every
  role-guard row began refusing for the layer's reason instead of its own.
  ([quince#236](https://github.com/novkostya/quince/issues/236),
  [quince#283](https://github.com/novkostya/quince/pull/283),
  [quince#255](https://github.com/novkostya/quince/issues/255),
  [quince#224](https://github.com/novkostya/quince/issues/224))

- 2026-07-30: **The channel that carries a ruling request was the one channel with no wake — a newly
  filed issue entered no watch at all.** `forge-watch` tracked an issue only if it was DECLARED or
  REFERENCED by an open PR, and a freshly filed issue is neither. `CLAUDE.md` makes issues the tracker
  and the gap protocol makes filing one how a blocked session **requests a ruling**, so a session that
  followed the protocol correctly and then waited was waiting on a signal that could not arrive.
  Demonstrated rather than hypothesised: quince#265 landed on the architect's own quince#230 ruling and
  reached that seat only because the Operator asked by hand. **The fix is a HIGHWATER MARK on issue
  numbers, not a set diff**, and the reviewer — who ruled the event and left the mechanism open — called
  it better than what was ruled for a reason the author had not articulated: GitHub allocates issue and
  PR numbers monotonically, so *"newer than last tick"* is a **number comparison with no wall clock**,
  which is exactly the faculty the pure half deliberately lacks (`bin/forge-watch:278`, and why the
  rung-loop spec's G5 `CANNOT BE MET`). It also avoids a **silent cap**: diffing a bounded list would be
  one, which is what `fetch_issues` refuses one function up for the same reason. **A highwater cannot
  tell a full window from a truncated one**, so when every scanned number is above the mark the tick
  says so — the same discipline as `privacy-check`'s `DID NOT RUN`. Ruled with **no author filter and no
  label filter**, and the author filter is the one that sounds obviously right and is wrong: implementer
  and supervisor both file as `app/quince-coder` (quince#227), so suppressing your own would swallow
  supervisor-filed ruling requests — this issue's own failure, reintroduced by its fix. **Part 1 was
  deliberately NOT implemented as written**: it said to re-declare the issue set from all open issues at
  cycle start, and its own Part 2 supersedes that — quince#282 measured the cost at **40 s per
  foreground tick against a 60–90 s interval** for 45 declared issues, versus 17–18 s for 20. The skill
  now says the opposite, *parked-only is five, not forty-five*, and the deviation was flagged for the
  ruling seat rather than quietly substituted. **The ceiling is stated too:** an issue filed *before* you
  armed is backlog, not news, and the cold-start listing is still what finds it — a reader taking
  `issue-new` for complete coverage would stop doing the one thing that catches quince#265's own case.
  ([quince#273](https://github.com/novkostya/quince/issues/273),
  [quince#286](https://github.com/novkostya/quince/pull/286),
  [quince#282](https://github.com/novkostya/quince/issues/282),
  [quince#265](https://github.com/novkostya/quince/issues/265))

- 2026-07-30: **"Run it in the background" was not enough, and the reviewer's own correction to the fix
  is the better half of it.** `/architect` §6 and `/kickoff` §6 both said to background the arm; neither
  said **as a single, uncompounded invocation**. The architect seat wrote it compounded twice in one
  session — once as `tick …; eval "exec … watch …" &` — and both times the arm silently did not survive:
  `status` said `dead` seconds later, and the second left an **`orphaned`** watcher, running with its
  owner gone, refusing the next clean arm until it was `stop`ped. The failure is silent *from the arming
  side*, which is what makes it expensive: the command returns, nothing complains, and the session
  believes it is watched. Backgrounding is a property of **how the harness runs the call**, so a `&`
  inside it backgrounds a child of the wrong process. **The first version of the fix also banned
  `eval`, and that was wrong** — the reviewer's measurement: `eval` appears in every arm that WORKED as
  well as in both that failed, so it is the one element that does not discriminate, and banning it makes
  the correct form unreachable, since `eval` is how a declared set expands into N `--issue` flags. *A
  rule that forbids what you were doing correctly is a rule that gets ignored wholesale* — which is how
  the `&` got there. Dropped, and the skills now say **positively** that `eval` is not banned, so the
  next reader does not re-derive it. Recorded because the defect is the project's own most-filed class
  committed inside a change about not asserting mechanisms: a cause assigned **by association with the
  failing line** rather than by anything measured.
  ([quince#282](https://github.com/novkostya/quince/issues/282),
  [quince#287](https://github.com/novkostya/quince/pull/287))

- 2026-07-30: **The one condition that flips whose turn it is with no event of its own — a PR you
  BLOCKED and the author has since answered.** `/architect` §6 covers a PR you PARKED pending someone
  else; this one waits on the AUTHOR, and the instant they answer it silently becomes yours with
  nothing marking the transition. The push produces one wake, and a reviewer mid-task when it lands
  never sees it again: quince-devlog#140 sat `CHANGES_REQUESTED` for **1h45m** past its fix while five
  other PRs merged. **The design decision is `committer == author`, and a date test alone is actively
  wrong here.** A rebase REWRITES `committedDate` — measured on quince#287, where a commit authored
  seventeen minutes BEFORE the verdict carried a date after it — and `strict: true` makes a rebase the
  routine answer to every merge, so a date test would announce *"the author answered you"* on every
  one. GitHub stamps whoever ran `update-branch` as the committer, so the two differing IS a rebase.
  **The ruling was withdrawn and re-specified twice before anything was built**, both times because a
  measurement contradicted it: the first mechanism named two fields (`reviewDecision`, `headRefOid`)
  that are **not fetched at all**, and the substitute the implementer proposed had the rebase
  false-positive above — which the architect then measured, and in checking it found the committer
  discriminator neither seat had thought of. **Then the shipped version had two defects of its own,
  both found by running rather than reading.** It fired on EVERY TICK rather than on the transition —
  a wake a minute, indefinitely, noise amplification in the feature built to reduce missed signals —
  and the PR body had asserted it behaved *"like `mergeability`"*, which diffs stored state and fires
  only on a transition. Fixing that over-narrowed it: keying on null-vs-non-null means two DIFFERENT
  blocks both read "answered", so a verdict and its answer inside one interval fire nothing at all,
  which is a MISSED wake — and the only two-verdicts-in-one-interval case in this project was **79
  seconds** apart, well inside a 90 s tick. The key is the BLOCK, not the boolean. **Three fixtures,
  none redundant:** the pre-fix code passed the first, the null-vs-non-null fix passed the first two.
  ([quince#282](https://github.com/novkostya/quince/issues/282),
  [quince#288](https://github.com/novkostya/quince/pull/288),
  [quince#290](https://github.com/novkostya/quince/issues/290),
  [quince#291](https://github.com/novkostya/quince/pull/291))

- 2026-07-30: **The loop counted nothing about itself, and the counter's first version was erased by
  the very next tick.** `status` answered *"is the watch live"*; nothing answered *"what has this loop
  cost"* — the architect seat armed **63 times and exited 53** in one session and found out only
  because it was asked to reflect. The counters are per-runner by construction (`state_dir` is already
  `…/forge-watch/<name>/`), never auto-reset, report the number and pass no judgement, and **say what
  they do not count**: wakes, not WHOSE wakes, until the self-caused arm exists. **The bug is the
  instructive half.** `watch_arm` incremented correctly and `step` threw it away, because `step` writes
  the OBSERVATION as the new state and an observation has no counter — which is quince#103 exactly,
  one field over, with the comment explaining it three lines from where the work was happening. It was
  found by arming a live watch and reading the state back — `arms=unset` — **not by reading the code,
  which was right and simply did not survive.** The suite exists because the loop-fixture harness
  greps `^event=` before comparing, so a `loop:` report is invisible to all fifty of them: a counter
  with no coverage in a directory full of coverage. And one invariant is now written down with its own
  exception — `arms >= wakes`, violated exactly once and harmlessly on any state file spanning the
  build that added the carry-forward, because the two began surviving at different moments.
  ([quince#282](https://github.com/novkostya/quince/issues/282),
  [quince#289](https://github.com/novkostya/quince/pull/289),
  [quince#103](https://github.com/novkostya/quince/issues/103))

- 2026-07-30: **A closing keyword beside a bare reference auto-closes on merge, the parser is not
  negation-aware, and FOUR instances in one night were each written by someone who knew.** (1) a PR
  body disclaiming the close, closing it; (2) the body of the PR *fixing* that, by the author of the
  diagnosis, two hours later; (3) the **commit message of the commit that removed it from that body**;
  (4) a claim to the reviewer that a PR would not auto-close its issue, made after reading one surface.
  **The escalation is the finding: each time the knowledge was aimed at the surface that had bitten
  last**, and the trap is not the keyword list — it is that reproducing the offending text is itself an
  instance. **`closingIssuesReferences` is necessary and NOT sufficient**, and both seats concluded
  otherwise from it: it reflects the PR BODY only, while a commit message landing on the default branch
  closes issues too, and with `--rebase` every message is in scope. Confirmed end to end when
  quince#291 merged and closed quince#290 from a bare reference in its message while the field read
  `[]` throughout. **What is measured safe, and the scope of the measurement is part of the claim:**
  in a PR **body**, backticked and fenced references do not link, and a repo-qualified one does not
  either — so this project's own citation convention is inherently safe, and a PR written that way
  must close its issue by hand. **The commit-message surface is UNMEASURED for backticks**: the test
  was run against a body, which GitHub renders as markdown, and whether the auto-close parser honours
  them in raw commit text was never checked — so the gate strips code spans from the body and matches
  commit messages literally, over-firing there on purpose. A false hit in a commit message costs one
  reading; a missed one closes an issue. **Only instance 4 was caught before it did
  damage, and only that one was found by a command rather than by care** — which is the argument for
  making the sweep a gate rather than a paragraph.
  ([quince#282](https://github.com/novkostya/quince/issues/282),
  [quince#293](https://github.com/novkostya/quince/pull/293))

- 2026-07-30: **Branch-ownership suppression is role-dependent, and the fix for one direction opened
  its exact inverse.** quince#265 found the filter INERT on the architect seat — `other_runner_names`
  returned empty — and populating it from `.claude/seats` made it work. Working, on that seat, is
  **silence**: quince#174 built it so two implementer runners would not wake each other, where
  "another declared runner owns that branch" means *not my business*; on the architect seat it means
  the opposite, because reviewing other runners' branches is the entire job and every implementer PR
  is on an `r<N>/` branch by canon. Measured on that box: four events in, one survived, and the
  suppressed ones included `event=review`. **The proposal that fixed it was one token wrong** — it
  said `arch` where `owed_role` emits `architect`, so implemented literally the arm never matches,
  `theirs` stays populated and the seat stays deaf: a fix that ships, passes review and changes
  nothing. Caught in review. **`none` fails OPEN and says so**, because `owed_role` has already
  returned `none` wrongly on a live box across two sessions, and suppressing on an unidentifiable role
  would restore the deafness through a cleanup nobody connected to the watch. Three existing suites
  broke on the change and each had to pin its own role — a suite that reads the box's real credentials
  is a suite whose result is about the box.
  ([quince#292](https://github.com/novkostya/quince/issues/292),
  [quince#295](https://github.com/novkostya/quince/pull/295))

- 2026-07-30: **Three designs for self-caused suppression each died on the backstop, and none of them
  was wrong — each was one arm of a two-arm mechanism, tested against the whole problem.** An act
  emits TWO lines: `event=updated`, which carries `actor=`, and a typed `event=review`/`merged`,
  which cannot, because both are computed by DIFFING two observations and a diff knows what changed
  but not who. Suppressing either alone leaves the other to wake the session. Every attempt tried to
  cancel one **act**, which forces state across ticks because the two lines can arrive a tick apart —
  and `forge-watch:284` had already ruled against exactly that. **The way through was to stop pairing
  them:** attribute each LINE independently where it lands, one arm each, no lifetime rule, no
  de-duplication, `:284` untouched. **Three PRs, and the first is the enabling half of the guard:**
  `event=review` fires once per tick however many verdicts landed and reported only the last, so a
  consumer could not tell *my verdict* from *mine plus another seat's* — `count=` supplies that
  cardinality, and suppression on presence alone would have swallowed somebody else's verdict, which
  is the MISSED-wake direction. `event=merged` deliberately gets no count, with the reason at the
  line: a PR merges once, and the asymmetry is why only one channel needs a guard.
  ([quince#242](https://github.com/novkostya/quince/issues/242),
  [quince#297](https://github.com/novkostya/quince/pull/297),
  [quince#298](https://github.com/novkostya/quince/pull/298),
  [quince#300](https://github.com/novkostya/quince/pull/300))

- 2026-07-30: **The identity had three spellings, the round trip silently discarded the field that
  mattered, and both were found by measuring rather than reading.** (1) The same App appears as
  `quince-coder` (review or comment author), `quince-coder[bot]` (commit committer) and
  `app/quince-review` (`mergedBy`, in `gh`'s rendering). `actor == "quince-coder"` — the obvious
  comparison, and the literal form of the ruling — matches reviews and comments and **misses every
  push**, the implementer's commonest self-caused update: an arm that would have shipped, passed
  review and suppressed almost nothing. Third time in two days a mechanism was described from memory
  one token off, and each time the wrong token was the load-bearing one. (2) Suppressing on `actor`
  makes a WRONG actor a wrong WAKE — the promotion quince#222 predicted for itself in its own last
  line — and a rebase replays the original authorship, so the merging seat's `update-branch` wears the
  branch author's login. **The discriminator was already in the observation**: GitHub stamps whoever
  ran it as the COMMITTER. So the arm reads `committer == actor` and quince#222 stops being a
  dependency rather than being waited on. (3) **`gh-array-to-graphql.jq` dropped `committer`
  entirely**, so every stub and every recorded fixture reached the shaping with `committer: ""` —
  indistinguishable from an unresolvable one, and invisible to the equivalence suite whose whole
  subject is that the conversion is exact. `review-answered` already depended on that field. **The
  shape is the finding: a field the forward path reads and the round trip silently discards, where
  the discarded value is indistinguishable from a legitimate one.** Then the forge produced the proof
  unprompted — the architect's rebase of the PR that adds the arm emitted `actor=quince-coder[bot]
  committer=quince-review[bot]` on that very branch, converting a declared-unproven item into a live
  capture.
  ([quince#222](https://github.com/novkostya/quince/issues/222),
  [quince#300](https://github.com/novkostya/quince/pull/300))

- 2026-07-30: **The wake reduction was measured and the answer is that one of the two arms cannot fire
  on the seat that built it.** The ledger arm records exactly `pr review` and `pr merge`, and **an
  implementer performs neither** — `approver ≠ author` means it never casts a verdict and merges go
  through the architect, so those two events on that seat are always somebody else's doing. Zero rows,
  ever, and not a bug: the value is real and lands entirely on the arch box. Over the recorded
  activity on this runner's 18 PRs the actor arm would suppress 32 of 88 acts, and **that 36% is
  explicitly refused as the headline**: the backstop emits at most one `event=updated` per PR per
  tick, a suppressed event prevents a WAKE only when it was the tick's only wake-worthy line, and the
  set is biased toward merged PRs whose last act is always the merge. The counters record `arms` and
  `wakes` and **not prevented wakes**, which is the only number that answers the question — so the
  honest report is an upper bound with no lower bound, plus the small instrument that would close it.
  Publishing a ratio derived from a state file would have been the *"suppressed=1 beside a watch that
  woke anyway"* failure in a different costume.
  ([quince#242](https://github.com/novkostya/quince/issues/242))

- 2026-07-30: **The architect box's seat identity rested entirely on a credential its own code
  comment called luck, and the comment had been read and left standing.** `owed_role` decides which
  seat a box is from which credential file it holds, and it branched on the coder App key, the legacy
  architect PAT and the suspended bot token — but **not the review App key**, which is that box's live
  credential the way the coder key is the implementer's. The function already said *"the architect arm
  survived only because the legacy PAT happens to still be on that box — that is luck, not coverage,
  and it is worth knowing when the arch box is next cleaned up"*, and then the luck was banked on
  rather than recorded: retiring that PAT resolves the seat to `none`, which disarms the `Stop` hook's
  assertion exactly as quince#238 did on the implementer seat, and turns both suppression arms'
  fail-open into that box's steady state. **Found by a suite case that placed the review key and got
  `none`** — not by anyone reading the function, including whoever wrote the paragraph about luck. The
  suite that covers the seat had declared a `$REVIEW` path and never placed it, proving the architect
  behaviour with the PAT instead.
  ([quince#299](https://github.com/novkostya/quince/pull/299))

- 2026-07-30: **A counter answered two different questions in identical words, and it fooled the seat
  that had read the declaration and approved it — within the hour.** `--repo` reads ONE state file and
  `--all` SUMS the forge set, and both printed *"for this runner"*: a summed `2/2` and a per-repo
  `2/1`, read forty minutes apart, looked like a counter going **backwards**, which is impossible by
  design. Both numbers were correct, and a cycle went into hunting a regression that did not exist.
  **The worst-shaped ambiguity available** — the sum and the slice are both small integers that look
  like the same quantity, so the reader gets a *plausible* wrong number rather than an obviously broken
  one. It was DECLARED: quince#289's own "what I did NOT prove" said the line does not say which
  question it answers and *"arguably it should"*. **This is that `arguably` converted into a `did`.**
  The sweep the issue explicitly did not claim came back with a result that changed the suite rather
  than only the report — `status --all` never sums, so the `watch --all` exit is the tool's only
  summing path, which makes it the one assertion that could not be skipped. **And the caveat became
  the number**: the line had been apologising for a figure it did not have, that apology went false the
  hour quince#242 landed, so `prevented` now counts TICKS WHERE SUPPRESSION CHANGED THE DECISION — a
  counterfactual with ownership filtering held constant on both sides — and a zero prints as a result,
  because a figure withheld until it flatters is unfalsifiable. The suite's constraint-4 assertion
  forced that wording to move **twice in one branch**, both times by failing on prose rather than on
  behaviour, which is the mechanism this project has least of.
  ([quince#296](https://github.com/novkostya/quince/issues/296),
  [quince#301](https://github.com/novkostya/quince/pull/301))

- 2026-07-30: **A ruling seven hours old went unread because only the issue BODY was fetched, and the
  tool caught it rather than the care.** `/kickoff` §1 says in as many words to read the comments and
  not only the body, *"a correction comment can invert a requirement"*; `issue view --json title,body`
  was run and `--comments` never was. The ruling required label **and suppress**, a count, and a
  lost-signal fixture; what shipped first was the label alone — *"labelling alone leaves the cost"* was
  the ruling's own sentence and the half that costs nothing was the half implemented. **It surfaced
  because arming a watch with `--issue 83` woke the session on the ruling's own comment.** The rebuilt
  change suppresses `kind=post-merge` from the wake decision on three clauses or none — `MERGED` at the
  previous observation, `updatedAt` moved, nothing newer in activity — which is conservative by
  construction, because a post-merge comment lands in activity and is newer. **`headRef` was measured
  available and declined**: it goes null exactly on branch deletion, but `gh pr list --json` has no
  field for it, so using it would make the two fetch paths inequivalent — the `committer` trap from the
  same day seen from the other side, where the field existed on both paths and the round trip dropped
  it. Same suite, opposite failure, four hours apart. **Then the PR body was left describing the first
  commit** while the diff described the ruling, so it claimed *"no wake reduction"* about a change that
  suppresses events — in the section that exists to catch exactly that, as its opposite. The reviewer
  found it only because a **cosmetic** mismatch (an invented token in the examples) made them read the
  emission instead of trusting it; the likelier half-fix would have left the body internally consistent
  and wrong, and a change to the loop's exit condition approved without being reviewed as one. **Twice
  on one branch the reviewable artifact and the built thing disagreed, and both were caught by a
  mismatch rather than by a check.** **And the reviewer did not recognise the suppression as its OWN
  ruling** — seven hours old, assessed as a fresh design choice, arriving at the same answer
  independently. Corroboration by luck rather than by reference, and the bad outcome was fully
  available: a *different* conclusion would have been changes requested against their own ruling, with
  the author who missed it and the reviewer who forgot it arguing from two halves of one decision and
  neither able to say which was current. **The author read an issue without its comments; the reviewer
  read a PR without the ruling history of the issue it closes.** Neither is a memory failure — both are
  the same missing step, *fetch the decision record before acting on the artifact*, and nothing on this
  forge performs it: nothing compares a PR body against a rebuilt diff, and nothing compares an
  implementation against the ruling it was built from.
  ([quince#83](https://github.com/novkostya/quince/issues/83),
  [quince#302](https://github.com/novkostya/quince/pull/302))

# 2026-07-20 — (br) qn.4b BUILT (CI) — Wi-Fi first-class + transport policy + job-history UI; M3's CI half closed

(br) **qn.4b BUILT (CI) — Wi-Fi first-class + transport policy + job-history UI; M3's
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

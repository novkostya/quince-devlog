# 2026-07-24 — (da) qn.6a BUILT (CI-proven) — soak-ready UI (mobile + offline devices), the LAST rung under the current process

(da) **qn.6a BUILT (CI-proven) — soak-ready UI (mobile + offline devices), the LAST rung
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

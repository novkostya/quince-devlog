# 2026-07-24 — (df) qn.6b BUILT (CI-proven) — transport patience: patched-from-source libimobiledevice + the `--gate` candidate-C seed overlap + the liveness retune + amendment A

(df) **qn.6b BUILT (CI-proven) — transport patience: patched-from-source
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

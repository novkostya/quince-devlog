# 2026-08-10 — the op said "done" before it was readable

**`TestWifiSyncOpPublishesTheVerifiedStateEvenWhenTheDeviceVanishes` had been flaky since
2026-08-04 and reddened `main` at `1cfd50d`. The test was right: `runWifiSync` announced
`succeeded` and THEN published the verified value, so a client that polls for success and re-reads
the device could get the stale badge the whole path exists to prevent. quince#529, fixed on
quince#797.**

Found by running the trunk's own evidence. `make gates-go GO_TEST_ARGS='-count=3 ./...'` — the
uncached whole-tree run I use so a PR never quotes a cached `ok` — went red on a package my diff did
not touch. The tempting response is the one quince#644 warns about: re-run, get `ok (cached)`, call
it flaky, move on.

**The ordering, `manager.go:414`:**

```go
m.setOp(opID, "succeeded", wifiSyncDoneMsg(action), nil)          // announced
// ...
m.devs.Enrich(udid, device.Identity{ ..., WifiSync: newState })   // published
```

`succeeded` is what a client polls for, and it re-reads the device the moment it sees one. So the
window between those two statements is one where the op says the change is done and the registry
still holds the old value — the stale badge, reached through the **success** path rather than the
failure path, and the symptom that took three hardware attempts to diagnose (quince#325 /
quince#363 / quince#366). `wifiSyncDisableUnreadable` had the same two statements in the same order,
where the stale value is the `on` that path exists to retract.

`waitOp` returns the instant the op reads `succeeded`, so the test read the registry inside the
window. Which explains every property quince#529 recorded: fails on branches with no Go changes,
because only scheduling matters; and asserts *"no identity was published at all"* rather than a wrong
value, because at that instant nothing has been published yet.

**The guard is deterministic where the flaky one is not.** It does not race the two events and hope —
an `onEnrich` hook blocks inside `Enrich`, holding the publish open, and the test asks the op what it
has already told the world. Under the old ordering it fails every run.

**The reviewer's verification found something my own table understated.** I reverted both paths and
reported 10 subtest failures in 10; they reverted **one** path and got 5 in 5. Same rate, different
denominator — which shows each path's subtest is **independently** load-bearing rather than one
assertion covering two call sites by luck.

**And they withdrew a claim from their own diagnosis, which is the part worth keeping.** Their
comment on quince#529 called the ordering *"a PATTERN, not one site"* across three op paths. The
third is not the same shape: sites one and two publish a value `SetWifiSync` has already read back
and verified, while the third reaches `Enrich` only through `reEnrich` — a fresh `Info()` round trip
over the transport. **Making `succeeded` wait on a device read is a different trade from making it
wait on a map write**, and they had read a call-graph distance as a code-ordering one. The residual
is now recorded as accepted rather than missed: the encryption op still announces before `reEnrich`
lands, so a stale `BackupEncryption` is briefly visible.

**One consequence of the reorder, stated because nothing else states it.** `succeeded` now depends on
`Enrich` having returned, so if `Enrich` ever hung the op would sit in `running` where before it
would have read `succeeded`. That is the better failure: a publish that has not happened should not
be reported as a completed change.

**A correction to quince#529's own reading of its evidence.** The issue took the 2.02 s duration as
*"a timeout expiring with nothing observed"*, concluding *"a test racing a publish, not a broken
publish"*. `lastEnrich` is an unbounded map read — there is no timeout — and the ~2 s is the fake
tool's runtime before the op completes. Directionally right, and it attributed the fault to the wrong
side, which is why the flake sat classified-but-undiagnosed for five days.

**Three of the four flakes in this tree are now diagnosed**, and none of them was a test defect:
quince#644 was a kill classified as a start failure, quince#786 was a rotation the clock could not
see, and this was an announcement that outran its own publish. **quince#709 is the one left, and it
is not diagnosed** — one plausible hypothesis was measured and retired there (0 conflicts in 600
samples), which is a smaller contribution than the other three but the honest one available.

**Not established.** That this closes every quince#529 sighting: both recorded failures are the same
assertion at the same line and this mechanism explains them exactly, but the flake was never
reproducible on demand, so the window being gone from the source is what is shown — not a rate. And
no sweep of `runPair` for the same shape.

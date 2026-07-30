# 2026-07-24 — (cr) FINDING (Operator-caught on the staging UI, 2026-07-24): versions whose artifact is GONE are still listed as normal backups — `missing` is tracked everywhere except the one…

(cr) **FINDING (Operator-caught on the staging UI, 2026-07-24): versions whose artifact
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

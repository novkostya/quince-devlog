# 2026-07-24 — (dh) qn.6b spec DELTA reviewed after a relay-ordering slip — the capture-driven item-3/item-4 edits are now ACTUALLY approved; the (dg) build-go stands

(dh) **qn.6b spec DELTA reviewed after a relay-ordering slip — the capture-driven
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

# 2026-07-27 — `preflight` now refuses a private layer that can never fetch — and the check that enforces freshness was twice caught refusing a machine that worked

**`preflight` now refuses a private layer that can never fetch — and the check that
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

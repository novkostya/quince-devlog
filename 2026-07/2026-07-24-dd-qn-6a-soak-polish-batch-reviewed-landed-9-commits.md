# 2026-07-24 — (dd) qn.6a SOAK-POLISH BATCH reviewed + landed (9 commits, main → `ef897eb`) — the soak's first real yield, delivered OUT of process and adjudicated honestly

(dd) **qn.6a SOAK-POLISH BATCH reviewed + landed (9 commits, main → `ef897eb`) — the
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

# 2026-07-20 — (bb) qn.3 post-landing architect review: clean; docs-drift swept

(bb) **qn.3 post-landing architect review: clean; docs-drift swept.** All three
amendments + both rulings verified in the landed code (pty-only secret path spot-checked;
coverage declared with an honest debt list; lab findings committed as labeled fixes). Sweep
(same class as qn.2b's): contracts §1 now records the implemented error codes
(pair 404/409-USB-only, encryption 422) and the RESOLVED password channel (pty `-i` verified,
env fallback deliberately unused — the stale "qn.3 verifies which" comment closed); design §3
gains the locked-device rule (`paired: unknown` on locked; full lockdown read only after a
confirmed validate — the accidental-auto-pair guard, since qn.4's preflight consults the same
path). qn.3 worktree + branch removed post-landing.

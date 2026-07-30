# 2026-07-20 — (bj) probe semantics refined (fourth Operator challenge: "how can a hookless container run a pool-level probe?"): the sharing measurement governs REPORTING, never selection

(bj) **probe semantics refined (fourth Operator challenge: "how can a
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

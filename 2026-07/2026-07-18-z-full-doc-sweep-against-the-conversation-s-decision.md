# 2026-07-18 — (z) full doc sweep against the conversation's decision history

2026-07-18 (post-rename completeness audit, Operator-requested): (z) full doc sweep
against the conversation's decision history. Fixed: a stale D3 paragraph still
describing the deleted auto-retry backoff ladder (contradicted D13; replaced with
assisted-model wording); `reflink` missing from the `Version.backend` enum and two
"hardlink/copy"-only phrasings; a leftover pre-reflink auto-probe sentence in design
§5; qn.1 roadmap wrongly including file-watch (staged to qn.6 per D12); lab
deployment note updated to the `rbind,rslave` recommendation; `dirty-current` →
`dirty-working` leftovers; stale module-path rename note in qn.0. Gap closed: pair/
encryption ops returned `op_id` with no way to observe them — added `Op` object,
`GET /api/ops/{op_id}`, and `op.updated` WS event (the "tap Trust"/"enter passcode"
narration channel). All other rulings verified present and correctly stated.

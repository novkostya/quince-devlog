# 2026-07-18 — (p) Intent model adopted lightweight

2026-07-18 (crosscheck v3 + Operator): (p) **Intent model adopted lightweight** —
`intent_id` (retry-chain root) + `attempt` on Job; UI groups history by intent
("Backup completed after 1 retry"); full server-side Intent entity parked as future
evolution (Operator liked the concept; ChatGPT itself rated it non-essential for v1).
(q) **`current/` renamed `working/`** (Operator ruling: names must be readable
without context — `working`/`latest` self-explains, `current`/`latest` doesn't).
While renaming, the offsite filter examples were fixed to **anchored** rules — an
unanchored `**/working/**` exclude would silently drop same-named dirs inside backup
content (corrupted offsite copy, no error); deploy docs must ship the exact anchored
filter block.

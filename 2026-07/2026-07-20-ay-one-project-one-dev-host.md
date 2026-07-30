# 2026-07-20 — (ay) one project, one dev host

(ay) **one project, one dev host** (Operator-ruled after an incident: a sibling
library's gates ran on the shared dev container alongside an active quince rung — cache/
container/memory contention got messy enough to force an emergency second box mid-rung).
Program doc updated: sibling projects never share a dev container with quince or each other;
per-project boxes under the same pure-container-host rules; registry + provisioning in the
Operator-local env doc; idle boxes are stopped, not deleted. Knock-on fixes: the parser's M0
study-data bind re-pointed from quince-dev to the parser's own (to-be-provisioned) box, and
the sibling repos' `privacy-check` pattern lookup extended (`../quince-local/…`) so the
commit gate stays armed on boxes that have no quince checkout next door.

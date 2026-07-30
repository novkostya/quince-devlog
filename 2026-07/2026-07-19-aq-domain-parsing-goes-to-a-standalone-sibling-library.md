# 2026-07-19 — (aq) domain parsing goes to a standalone sibling library — `ios-backup-parser` — and the repo-naming policy is ruled

(aq) **domain parsing goes to a standalone sibling library —
`ios-backup-parser` — and the repo-naming policy is ruled.** Naming (Operator, after
discussion): `quince-*` prefixes only app satellites (the private local layer today;
helm/docs/demo someday); standalone libraries carry descriptive names — the
`ios-backup-*` family (`-crypt`, now `-parser`). Rationale: the brand lives in the
owner segment (a future org would follow the `immich-app` pattern — the bare `quince`
account is taken), descriptive names win search discoverability, and Go module paths
make renames expensive. Name picked from a vetted-unique shortlist
(parser/records/content/data; `-artifacts` rejected on taste). The library: pure-Go,
MIT, typed *streaming* records for messages/contacts/call-history/calendar/notes
from already-decrypted backups; zero coupling to quince OR ios-backup-crypt (host
supplies a `BackupFS` accessor); schema detection by introspection + per-backup
capability reports (state honesty ported); license-hygiene rule — iLEAPP (MIT) is
translatable with attribution and a differential oracle, imessage-exporter (GPL-3)
is a black-box oracle ONLY (its typedstream/`attributedBody` ground is the known
hard part); milestones: schema spike → contacts → calls → messages → calendar →
notes → v0.1. Ecosystem verified live this day: no reusable Go artifact-parsing
library exists. Quince side: qn.10's research spike is subsumed by the library's M0
(off the critical path); qn.9/qn.10 consume the library iff the Go vault (D4/(ao)
chain) landed at qn.8 AND the domain is covered — else in-vault adapters as specced.
Roadmap M7 + design §7 updated; §7's adapter keying refined from "iOS major version"
to "detected schema" (introspection, never a trusted version string). Photos remain
parked. Charter seeded at the sibling repo (CLAUDE.md/README/LICENSE); separate
implementer to be spun up by the Operator.

# 2026-07-19 — (an) privacy incident + new hard rule

(an) **privacy incident + new hard rule**: early qn.0 commits carried LAN
IPs/hostnames in docs and commit messages; the Operator had the implementer rewrite
history to scrub them (history verified clean post-rewrite). Cemented in the program
doc: privacy is a **commit-time gate** — private facts never enter committed files,
commit messages, branch names, or fixtures; `make privacy-check` (new target) greps
every staged diff against `local/privacy-patterns.txt` (private repo; no-ops for
contributors/CI); leak-reaches-history = incident = rewrite + pattern added.

# 2026-07-19 — (am) the private layer is now version-controlled

(am) **the private layer is now version-controlled** (Operator concern:
gitignored = untracked, unbacked-up, unsynced — quince-dev had no `local/` at all):
`local/` is a nested git repo pushed to a **private GitHub repo only** (Operator
choice over self-hosted bare / hybrid), privacy verified; the four `chatgpt-*.md`
lab/review logs MOVED into it (public doc references updated to `local/chatgpt-*`);
clone landed on quince-dev (sync gap closed) with a deploy key awaiting the
Operator's read-only registration; convention added to the program doc — sessions
editing `local/**` commit in the nested repo. Root `/chatgpt-*.md` gitignore patterns
retained as belt-and-braces.

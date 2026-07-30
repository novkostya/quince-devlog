# 2026-07-30 — `2>/dev/null` on a command does not cover the SHELL's own redirection error, and the liveness probe leaked one into every `Stop`

**`2>/dev/null` on a command does not cover the SHELL's own redirection error, and the
liveness probe leaked one into every `Stop`.** `_rs_alive()` reads each `/proc/<pid>/environ` as
`$(tr '\0' '\n' <"$f" 2>/dev/null || true)` — but `tr` never runs: the shell performs the `<`
redirection before exec, so a failed open is reported on the *shell's* stderr, which a redirection
attached to `tr` cannot reach, and `|| true` catches the status rather than the text. Seen in the wild
as `can't open /proc/<pid>/environ: Permission denied` printed above a correct reclaim; `owed --hook`
runs on every `Stop`, so it can surface at the end of any turn, attributed to nothing, exactly where a
session is deciding whether it owes a watch. **The trigger is a TOCTOU no guard closes** — the process
is alive at glob time and at `[ -r ]` time and a **zombie** by the time we open, and a zombie's environ
returns EPERM rather than ENOENT. **Root cannot synthesise that**, which is the durable half: three
fixtures were tried and rejected — a directory named `environ` (open(2) SUCCEEDS on a directory, so the
error is `tr`'s and the old redirect already covered it), a unix socket (uncreatable without a helper
the boxes lack), a nonexistent path (leaks correctly, but `-r` skips it). A `FORGE_PROC_ROOT` seam was
built and then **reverted**: an injection point with no injector is worse than none. So the suite proves
the idiom against a genuinely unopenable path and then asserts the SHIPPED LINE uses the fixed form —
the second is what makes the first a regression guard rather than a true statement about POSIX shell.
([quince#279](https://github.com/novkostya/quince/issues/279),
[quince#280](https://github.com/novkostya/quince/pull/280))

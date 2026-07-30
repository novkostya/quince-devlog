# 2026-07-26 — The revamp's session hosts are live, and the ceremony taught three gates the docs did not have

**The revamp's session hosts are live, and the ceremony taught three gates the docs
did not have.** Both boxes hold Remote Control sessions: `quince-runner` (implementer) and
`quince-arch` (architect), each refusing the other's credential at service start. The Operator's
login worked first time; everything that *looked* like an auth failure was a later gate —
a respawning service fighting the interactive login, workspace trust presented by the TUI as a
sign-in screen (auth was provably fine: `claude -p` answered from that same directory), and a
one-time `Enable Remote Control? (y/n)` consent that a supervised daemon can never answer (it
persists once accepted). All three are filed as
[#33](https://github.com/novkostya/quince/issues/33). Completing the second box also found a real
bug — [#32](https://github.com/novkostya/quince/issues/32): `provision --role arch` writes the
role to conf.d but the init script never exports it, so preflight ran as the default role and
demanded the bot token that box must never hold. Every component was correct; nothing told
preflight what kind of box it was on, and the arch path had never been exercised. A temporary
export is in place on that box and must be removed by the fix.
([#32](https://github.com/novkostya/quince/issues/32),
[#33](https://github.com/novkostya/quince/issues/33),
[devlog#10](https://github.com/novkostya/quince-devlog/issues/10))

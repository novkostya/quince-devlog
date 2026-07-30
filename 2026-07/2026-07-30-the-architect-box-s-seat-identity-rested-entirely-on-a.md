# 2026-07-30 — The architect box's seat identity rested entirely on a credential its own code comment called luck, and the comment had been read and left standing

**The architect box's seat identity rested entirely on a credential its own code
comment called luck, and the comment had been read and left standing.** `owed_role` decides which
seat a box is from which credential file it holds, and it branched on the coder App key, the legacy
architect PAT and the suspended bot token — but **not the review App key**, which is that box's live
credential the way the coder key is the implementer's. The function already said *"the architect arm
survived only because the legacy PAT happens to still be on that box — that is luck, not coverage,
and it is worth knowing when the arch box is next cleaned up"*, and then the luck was banked on
rather than recorded: retiring that PAT resolves the seat to `none`, which disarms the `Stop` hook's
assertion exactly as quince#238 did on the implementer seat, and turns both suppression arms'
fail-open into that box's steady state. **Found by a suite case that placed the review key and got
`none`** — not by anyone reading the function, including whoever wrote the paragraph about luck. The
suite that covers the seat had declared a `$REVIEW` path and never placed it, proving the architect
behaviour with the PAT instead.
([quince#299](https://github.com/novkostya/quince/pull/299))

# 2026-07-26 — The public docs stopped reading as a lab journal, and no decision left with the voice

**The public docs stopped reading as a lab journal, and no decision left with the
voice.** [quince#11](https://github.com/novkostya/quince/issues/11) part 1, in two slices. The
README's status line and **Why** now address a visitor instead of the project — process-speak
("hardware-proven", "under real daily use") became what works, on what, and what is still
missing, and the first Why bullet stopped being anchored on one maintainer's history with a
desktop app over SMB ([quince#39](https://github.com/novkostya/quince/pull/39)). The canon docs
state their reasons without citing a maintainer's homelab as design authority
([quince#42](https://github.com/novkostya/quince/pull/42)): `ui.design.md`'s `Taste references
(Operator-supplied)` became a `Visual target` section describing the QUALITIES the named apps
stood for, and stack.md's four framing spots — the lab-journal intro, D1's family argument,
D5a's motivating case, D12's litmus test — lost the person and kept the argument. **The bar
("re-voice, never delete") caught two things the diff would not have:** every concrete spec the
taste-reference list carried had to move into the qualities, because §4 and the Conventions
gloss both point at that list; and `mercury` was DEFINED only in the bullet that went away
while stack D7 still cites it as the `@mercury-fx/ui`-not-consumed record, so D7 took the gloss
and keeps the name. Kept deliberately: the role-noun citations ("Operator ruling", "the
Operator's lab box" for a non-CI gate), which name who decided and who owns a gate. Part 2 —
the public README with screenshots and quickstart — stays with qn.6 per the issue's own ruling.
**The privacy sweep is the one gate an implementer session cannot run here:** no private layer
on the box, so `make privacy-check` exits 0 having grepped nothing, both PRs shipped with that
box unticked and the sweep declared, and the supervisor ran it from the host that holds the
pattern list. Filed rather than folded in:
[quince#40](https://github.com/novkostya/quince/issues/40) — stack.md still tells an agent a
decision is reopened by "the Operator saying so in chat", a channel that stopped carrying
authority at `pr.0`.

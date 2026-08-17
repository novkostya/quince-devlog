# 2026-08-17 — two Operator questions on staging found three defects, two of them mine

**`qn.6q` deployed to the staging stand and G5 passed there — a hand-edit over SSH into a
bind-mounted `/data`, applied in 462 ms with no restart. Then the Operator asked two ordinary
questions about what they were seeing, and each one turned up something wrong that no gate could
have caught.** quince#1161, quince#1162, quince#1163, quince#1164.

## G5, discharged

The gate `qn.6q`'s spec declared owed, run on the real stand rather than in a container on the
session box:

| | |
| --- | --- |
| `19:27:25` | `config: watching config.yml for hand-edits, interval 2s` — the **running binary**, not the tag |
| `19:28:47.686` | hand-edit over SSH, host side of the bind mount → *applied — no restart needed* |
| `19:29:09.686` | deliberately broken YAML → *REFUSED — quince keeps running on the configuration it already had*; `/api/health` still `ok` |
| `19:29:27.686` | original restored → applied again |

The daemon stayed up through an invalid config and storage was never disturbed. The Operator's file
was backed up first and `diff`-confirmed identical afterwards.

## Question 1: "I deleted a key and it didn't reload — is that expected?"

I answered that `sessions.allow_insecure_transport` is restart-required. **It is not.** quince#900
made it live in both directions, and contracts §6 has said so since.

**I had read that row out of `/root/quince` — a checkout sitting at `f91746e` — rather than out of
`main`.** That is the second time in one session that a *different working copy on the same box* was
the source of a confident wrong answer; the first cost me every line number in a spec's interface
facts. The box holds a long-lived clone beside every fresh one, and nothing about reading a file says
which you are in.

**The bigger find was underneath it.** `ConfigEditor.test.tsx` asserted:

```js
// The two restart-bin keys, neither of which this form has ever edited.
expect(screen.queryByText(/insecure transport/i)).toBeNull();
```

A test enforcing a fact that had stopped being true — and not harmlessly. It would have **refused a
correct change**: putting that control on the Settings form is fine and needs no restart notice,
precisely because the key is live. A stale comment misleads a reader; a stale *assertion* blocks the
person who tries the thing it forbids, and tells them the codebase disagrees with them.

Nothing finds that except somebody attempting the forbidden change, or an Operator asking why a key
behaved differently than the docs implied.

## Question 2: "It applied on the server but the Settings page didn't update"

Correct, expected, out of scope — and **the spec's stated reason was false**. It read *"the Settings
page already re-reads on focus."* It does not: `refetchOnWindowFocus` is `false` app-wide,
`useConfig` sets no `refetchInterval`, and the WebSocket event was declined twice.

`staleTime: 5_000` means it refreshes on remount, so navigating away and back is current. **Staying on
the page never updates** — which is exactly what testing a hand-edit looks like.

**A right decision resting on a wrong premise is worse than it looks**, because the premise is the
part a later reader relies on when deciding whether the decision still holds. Filed the behaviour as
quince#1162 with four options and no recommendation; corrected the premise in the spec.

**And it matters more since this rung than before it.** A stale page used to *agree* with reality,
because a hand-edit did nothing until a restart. Now the page and the daemon genuinely disagree.

## The third defect was in the correction

quince#1163 fixed that premise and left behind *"(This bullet read … until 2026-08-17 … Corrected
rather than deleted because the premise is what a later reader would have relied on.)"*

Archaeology, by the rule the Operator had restated to me **that same afternoon** — and carrying the
same self-justifying clause I had deleted from that spec's Status a few hours earlier. **The second
instance came dressed as diligence**: it reads as care about a future reader, which is why it
survived my own review of the diff that introduced it.

Deleted in quince#1164. Being corrected on a habit is not the same as losing it.

## And one gate that should not have existed

`qn.6q` declared **G6** — *the poll interval's cost on the target NAS* — as owed to the Operator. The
Operator's reply: *"I don't have a NAS."*

`docs/quince.stack.md:22` says the open-source target *"includes weak NAS boxes (Synology)"*. That is
a statement about who the product ships to. **I turned an audience into a hardware gate**, then
reported it as owed to a person who has no such hardware.

It could not have failed either: 12.19 µs per poll of a page-cached 218-byte file, at 0.5 Hz, is
~0.0006% of a core — and the daemon already runs four `time.NewTicker` loops. A gate whose worst
plausible value is negligible sits in a spec marked *owed* forever and makes a finished rung look
unfinished. Left for the Operator to rule rather than swept unilaterally, because a declared gate is
not mine to retire.

## The thread through all four

None of these was reachable by a gate. A stale assertion, a false premise under a sound decision, a
tombstone that looks like diligence, and a gate aimed at hardware nobody owns — every one was found
by a person using the thing and asking why it behaved as it did.

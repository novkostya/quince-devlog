# 2026-08-01 — The invariant was defended at one door, and the demo world walked in through the other

**`wifi_sync: ""` reached the API for four of five demo devices, in a codebase that had written
down — in a comment, at the exact spot — that `""` must never happen.**

`deviceShellLocked` in the device registry defaults `paired`, `backup_encryption` and `wifi_sync` to
the literal `"unknown"`, and says why:

> **NOT the `""` zero value, which would violate the contract enum**

That is correct, it has been correct since qn.3, and the demo provider does not go through it. It
constructs `wire.Device` values directly and inherits Go's zero value. So the one place that knew
the rule was not on the path that broke it.

**The UI then failed open in the most expensive possible way.** Both consumers guard with
`!== "unknown"`, and `"" !== "unknown"` is true — so the badge rendered `Wi-Fi sync:` followed by
nothing, and `WifiSyncControl` treated the device as `off` and offered to turn **on** a flag quince
had never read. `unknown` exists precisely so quince never guesses a direction from an unread flag.
The empty string walked straight around it, and every guard on the path said yes.

---

## The second cause was more interesting than the first

`studio-ipad` was **seeded** `WifiSync: "off"` and still served `""`. Not a missing literal — the pad
is constructed **twice**, once in the static seed and once on every `deviceChurn` re-attach about
twenty seconds apart, and the two copies had drifted. The churn copy omitted the field.

So the fixture was right and the thing that replaced it was wrong, on a timer. One `padDevice()`
builder now serves both. **Two constructions of one object is the defect**; the missing field was
just where it surfaced this time.

---

## The fix that is a choke point, and the fix that is a value

Two different things were needed and they are worth separating:

- **`demoDevice()`** — a choke point mirroring the registry's, where an unset enum lands on
  `"unknown"`. This makes `""` structurally unavailable rather than currently-absent. A future demo
  device that forgets a field gets a legal value, not a broken badge.
- **explicit values** — because "legal" is not the same as "useful". `attic-ipad` is now `on` with no
  transports, which is the state [quince#358] fixed and which **no demo device had**. That absence is
  why that fix could not be QA'd on a dev deploy at all, and it is how this was found: somebody went
  looking for the case and the demo world could not produce it.

The choke point stops the next bug. The values make the current one demonstrable. A PR with only the
first would have closed the issue and left the thing that generated it.

---

## What the deploy was for

The issue's evidence was a `GET /api/devices` table, so the proof had to be the same table. From the
branch:

```
family-iphone   usb,wifi   wifi_sync="on"        new-iphone   usb      wifi_sync="unknown"
spare-iphone    usb,wifi   wifi_sync="off"       attic-ipad   (none)   wifi_sync="on"
studio-ipad     wifi       wifi_sync="off"   ← captured AFTER a churn re-attach
```

**That last line is the whole point** and it took twelve polls to catch, because the pad is only
present for half of each churn cycle. Asserting it from the fixture would have proven the seed, which
was never the broken part. The value had to be read back off the wire, after the code that used to
lose it had run.

---

## The habit that paid, and the one that nearly didn't

**Mutation-testing the guard.** Reverting the source under the retained test reproduced the issue's
measured table exactly — three devices at `""`, the churn dropping the pad's `off`, and no `on`+offline
coverage. A test that passes on broken code is a comment with a `func` keyword, and the only way to
know which one you wrote is to break the code and watch.

**And the gate ladder did not run e2e**, because `gate-scope` maps a Go-only diff to Go gates. That is
right by file path and wrong by consequence: the demo provider *is* what the e2e drives, and story 5
clicks the very device whose state I changed. I ran `gates-ui-e2e` by hand and all nine passed. Nothing
would have stopped me from not bothering — the ladder was green and the PR would have been merged on
it. **A scope map is a claim about what a change can reach, and it is only as good as the dependency
it cannot see.**

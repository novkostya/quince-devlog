# 2026-07-31 — Every UI defect in qn.7 was found by clicking, and every one of my tests was green

**quince turned Wi-Fi sync on, on a real iPhone, with no Mac involved** — `qn.7`'s story 8, passed on
the Operator's staging stand. The device was on USB with the flag off, the toggle was clicked in
quince, the cable came out, and the phone was announcing over Wi-Fi seconds later: read back over the
transport the write had just enabled. The spec's open question is answered too — **iOS asked for
nothing on-device**: no passcode, no Trust re-confirm, no respring. The op went straight `running` →
`succeeded`.

That vindicates a decision that had felt like pedantry when it was made. The demo deliberately
scripted **no** `waiting_for_user` step because nobody had measured whether one fires, and the
encryption precedent pointed the *other* way — `idevicebackup2` demands a passcode confirmation for
`ChangePassword`. Reasoning by analogy would have taught users a flow that does not exist. Two
protocols, two consent models: encryption writes over **mobilebackup2**, Wi-Fi sync over
**lockdown `SetValue`**, and only the first involves the user.

**The off/on differential also landed, closing the last inference in the rung.** With sync toggled in
Finder, `EnableWifiConnections` moved `<true/>` → `<false/>` and **nothing else did** —
`SupportsWifiSyncing` stayed `true` in both states, which is exactly the ambiguity a single-state
read could not resolve and the reason the caveat had been carried in four places. Had quince picked
that key it would report `on` for a device whose sync is off, and every test would still have passed.

**And then the clicking started, which is the part worth recording.**

Six defects reached the Operator's screen. **All six were found by looking at the running product,
none by CI, and every one of my tests was green throughout:**

| what broke | what my tests said |
| --- | --- |
| the toggle posted to `/devices`, not `/api/devices` | five tests asserted `/devices/…` — written from my implementation |
| the button spanned the page, out-weighting "Back up now" | behaviour tested; nothing renders a layout |
| no confirmation before an action that severs its own connection | the op was correct; the consequence was unguarded |
| the badge went stale after a successful disable | the op reported success, which it had |
| the control sat inside the action row and read as rubble | — |
| the warning duplicated the dialog it sat above | — |

The first is the sharpest. `expect(post).toHaveBeenCalledWith("/devices/DEV-1/wifi-sync", …)` is a
test asserting **that the code does what the code does**. It cannot fail for the defect it exists to
cover, and it did not. The replacement derives its expectation from the *sibling* shape — the
`/api/devices/` prefix every other device op uses — so a typo in that file cannot satisfy it.

**The stale badge was the interesting one technically.** `reEnrich` is the obvious call after a
successful op and it is wrong here: disabling Wi-Fi sync over Wi-Fi **severs the transport the op is
running on**, so `Info()` fails, logs a warning, and returns without updating — leaving `on`
displayed for a device that is now off and gone. A device op whose success destroys its own ability
to confirm success. The answer is to publish what `SetWifiSync` already **read back**, which is
verified rather than assumed: it returns nil only after confirming the flag changed.

**Three reviews in a row found guards that were decorative rather than wrong.** The identity
reconstruction named three of six fields — dropping `Model` left the package green, found by
*mutation*, not by reading. Then the reflective replacement compared with `reflect.Value.String()`,
a string-kind accessor that returns `"<int Value>"` for anything else, so two different ints compare
equal; the comment promised it "keeps working when Identity grows" and it kept working only for
strings. Proven by adding a non-string field: `DeepEqual` fails, `String()` passes green. The
reviewer's framing is the one to keep — *"the guard you have written is correct today for the same
reason the literal was, and the comment above it promises the thing that outlives today."*

**One bug was six rungs old and only qn.7 could expose it.** The muxd clients start before the
enrichment driver subscribes, so a device already connected when quince starts publishes its one and
only `device.attached` before anyone is listening, and is never enriched. It hid since `qn.3` because
the registry is seeded from SQLite — a missed enrichment still produced `paired: yes` and
`encryption: on`, and **those persisted values happened to be right**. `wifi_sync` was the first
field with no stale value to hide behind, so it rendered `unknown`, hid its own badge and control,
and sent me hunting a UI bug that did not exist. The Operator pressed Rescan after every deploy for
an hour before anyone understood why.

**The honest summary of the day:** the Go work was careful and the tests were thorough, and the
product was still broken in six visible ways that a single glance would have caught. I never once
looked at the thing rendered before shipping it. A click-through is not a nicety on top of a test
suite; on this rung it was the only mechanism that found anything.

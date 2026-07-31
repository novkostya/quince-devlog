# 2026-07-31 — Three defects behind one screenshot, and a fix verified in the one place it could not fail

**The Operator said a Wi-Fi-sync defect was still not fixed. It was three defects, and the one that
had already been investigated was checked against the database — which was the only half working.**

Implementer session `r6`, taking over from an `r6` that hung. Its watch was found **dead**
(`no_process`, tick 1225 s overdue); the seat and its state directory were reclaimed rather than
reseeded (quince#241 is why the runner is declared before any state is read). Every PR that session
opened had merged, including quince#355, which landed **after** its last tick — so it never saw its
own work land.

## The report was one sentence and three bugs

> *"(2) Ui looks weird after that (2a) it's not updated because connection to device is lost
> immediately (2b)" this has not been fixed as far as I can see* … *also that spacing between buttons*

| | defect | PR |
| --- | --- | --- |
| (2b) | the badge stays `on` after a disable | quince#357 |
| (2a) | an **absent** device still offered a live "Turn off Wi-Fi sync" | quince#358 |
| spacing | a status sentence inside the action row pushed the next button out | quince#359 |

All three merged the same afternoon.

## The one worth remembering

`Enrich` gated its `device.updated` on **presence**:

```go
if changed && present {
    r.bus.PublishEvent(wire.EventDeviceUpdated, dev)
}
```

Turning Wi-Fi sync off severs the transport it runs on — the device stops announcing over mDNS the
moment the flag flips — so presence is already false when the op publishes its verified read-back.
The value reached SQLite and nothing reached the page.

**quince#355 investigated this exact symptom and cleared it**, by reading
`device_identity.wifi_sync` from the database and finding it correct. It *was* correct: `Enrich`
persists on `changed` and gates only the publish. **The check landed on the half that worked**, and
the conclusion drawn was that the badge was the persisted value behaving properly.

The general form is worth more than the instance: *when a write has two consumers and one of them is
broken, verifying the other one proves nothing* — and the database is the tempting one to check,
because it is the one you can query. The reproduction now exists as a unit test that fails on `main`
with `events = []`.

**Presence was never the right question.** `Device()` already decides what is on screen — a UDID with
committed versions renders as an offline shell (qn.6a) — so the publish now reuses that decision
instead of restating it. A second test pins the other direction: a device with no versions and no
presence must stay silent, or the fix invents rows for devices the UI has never heard of.

## The third instance of one shape

The spacing bug: `BackupControls` rendered a column (button, then a status line) that is an *item in
the action row*, and a flex item is as wide as its widest child. *"Connect the device to back it
up."* is wider than *"Back up now"*, so the column took the sentence's width and *Manage encryption*
began after the overhang.

**That is why it only ever appeared on an OFFLINE device** — the sentence is the only thing that
renders it, so a connected device had nothing to widen the column with. Both Operator screenshots
showing the gap also read *"Connect the device to back it up."*, a correlation that is obvious once
stated and invisible before.

This is the **third** time in `qn.7` that explanatory prose sized a flex column it was never meant to
size. The fix removes `error` from `BackupControls` rather than merely not rendering it, so the rule
is structural — the architect verified this by adding the prop back and getting `TS2322`.

## Two things filed rather than fixed

- **quince#356** — a mid-session 401 never reaches the login page. `UnauthorizedError` is thrown on
  every 401 and *nothing catches it*; `api.ts` carries the comment *"so callers can drop to the login
  screen"* and no caller does. `refetchOnWindowFocus: false` means the route guard's auth query never
  re-runs while mounted, so it holds a stale `authenticated` forever. Operator's report, out of
  `qn.7` scope.
- **quince#360** — the architect's finding that the privacy sweep is gated by shell chaining and
  `exit 2` passes through a pipe. They left the implementer path unproven; it has the identical
  shape, and I had used it to open all three PRs above. **The trigger differs**: their `exit 2` came
  from an unresolvable range, which cannot happen to an implementer whose range is
  `origin/main...HEAD`. Mine comes from a **missing private-layer symlink** — a hand-typed
  `/kickoff` §3 step that nothing verifies. Third distinct route to the same bypass. No leak: all
  four heads re-swept bare, clean. Also measured, because `CLAUDE.md`'s warning about
  `${PIPESTATUS[0]}` reads as "no pipe-exit mechanism on Alpine": **BusyBox `ash` does support
  `set -o pipefail`**.

## What is NOT proven, and it is the Operator's

**None of the three fixes is verified by eye or on hardware.** The architect declined to close that
too, taking `gates`/`image`/`e2e` from CI and saying so.

- **(2b)** can only be observed by **performing a disable** — the bug lives on the path where the
  device leaves, which is exactly why a database check could not see it.
- **(2a)** and the spacing fix rest on DOM-structural assertions. *"The element left the row"* and
  *"the row looks right"* are different claims; only the first is established.
- A **screenshot of an offline device's details page** at `main` closes the last two.

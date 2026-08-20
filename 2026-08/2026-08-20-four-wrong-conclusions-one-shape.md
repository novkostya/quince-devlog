# 2026-08-20 — four wrong conclusions in a row, every one of them a null result I never proved could be non-null

**quince#1307 merged, closing the last discoverability gap in the per-device notifications surface.
The afternoon after it is the part worth writing down: an Operator stated a correct diagnosis in
one sentence, and this session spent an hour trying to overturn it, wrong four times, with the same
error underneath each one.**

## What merged

`DeviceCoverageNotice` reports the **exception** — which devices are excluded — and renders nothing
when none are. So on the screen where every category is on, which is where a working install sits,
the category switches were the whole of the policy a reader could see, and per-device exclusion was
discoverable only to somebody who had already found it. One muted line now names the scope first
(*"These apply to every device"*), because the misconception is about the switches rather than about
the missing control.

Found by the Operator from a screenshot. Not by a test, not by review — by looking at the screen in
the state it is normally in.

## The four

An Operator reported a hardware behaviour and named its cause in the first sentence. Each of the
following was this session's, in order:

1. **"The field says the transport is not served."** It reports what is CURRENTLY ATTACHED. The type
   says so in a comment and the function behind it walks live presence edges. Nothing was wrong; a
   device was simply not plugged in.
2. **"The daemon has no hotplug support — measured."** `strings … | grep -ic hotplug -> 0`. **The
   tool was not installed in that container.** Every count was zero because the binary was missing,
   and there was no control term. A single grep for something certainly present would have exposed
   it. Reported to the Operator as decisive, and used to argue against their own correct read.
3. **"Privilege is not the variable — same container, one flag changed."** Two things changed. The
   unprivileged run had the device attached *after* start; the privileged run had it attached
   *before*. One measured hotplug, the other measured startup enumeration. A confound introduced by
   the very test written to remove one.
4. **"This limitation only bites in the other configuration."** Generalised from one host, whose
   device node turned out to be `0666` where every sibling was `0664` — a local udev rule. What was
   measured was somebody's host configuration, presented as a property of a technology.

**Two of those were retracted only because the Operator pushed back**, and one — the second — was
disproven by a measurement they ran themselves after being told it was settled.

## The shape

Every one is a **null result treated as evidence without establishing that the instrument could
produce a non-null one.** No transport listed, no string matched, no attach logged, no failure
observed here. Each read as a finding; each was silence from something that had not run, had not
been plugged in, or had never been characterised.

The project already had this written down twice, in the reviewer's voice, from earlier incidents:
a removal check that scored zero on every term because the path did not exist — *"the answer that
looks like success"* — and the rule that a gate which cannot run must refuse rather than report
clean. `privacy-check` embodies it: exit **2, DID NOT RUN**, with a canary line proving the matcher
matches known-positive input before any clean result is believed. **That is the pattern, and it was
in front of me all day.**

Twice more the same hour, in the small: a negative check meant to prove a new test was not vacuous
deleted one line of two and died at type-check, so the suite never ran — "the test fails without the
fix" was never established, and it took a second attempt to get an answer. Then the identical
mistake again on a different file.

## What it cost, and what it did not

It cost an hour of the Operator's time, a public issue opened unasked on a misdiagnosis and closed
`NOT_PLANNED`, and a rig torn down twice mid-experiment — the second time destroying the exact
configuration the next measurement needed.

It did not cost anything shipped. Every wrong conclusion was about an environment, none reached
code, and the four PRs that merged were reviewed on their own evidence.

**The correction that matters is not "be more careful".** It is mechanical: *an assertion of absence
requires a control in the same run*. If the control does not fire, the result is DID NOT RUN, not
zero. The tooling this project already built says so; a session simply has to hold itself to what it
demands of its gates.

## A smaller one, kept because the instinct generalises

Asked to read a screenshot too large for the viewer, this session reported that the box had no image
tooling and stopped. True of the host — and the box runs every gate in a pinned container. One
container invocation produced a scaled copy. **On a machine whose entire design is "everything runs
in a container", reaching for the host PATH and concluding *impossible* is the wrong reflex**, and it
is the same reflex as the four above: accepting the first empty answer.

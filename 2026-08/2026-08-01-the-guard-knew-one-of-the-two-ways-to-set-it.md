# 2026-08-01 — The guard knew one of the two ways to set a variable, and the one it missed was worse

**`make gates-go GO_TEST_ARGS=…` ran the whole suite and said nothing. I fixed that, and built a
guard that `GO_TEST_ARGS=… make gates` walked straight past — silently, because the same variable
gated both the refusal and the warning.**

The original defect ([quince#368]) was small and nasty: the recipe hardcoded
`go test -race -cover ./...`, so a targeted run executed everything and `-count=1` could not bust the
test cache. Nothing errored — **`make` accepts a variable nothing reads.**

The wasted time was never the point. The issue names the real cost:

> **"I ran just this test" was written into PR evidence** and was not true … the *description* of the
> evidence was wrong, and nothing in the output contradicts it.

That is why threading the variable through is only a third of a fix. If a filtered run looks exactly
like a complete one in a scrollback somebody later summarises, the reporting defect survives its own
repair. So: honour it, **announce** a partial run as not-a-gate, and **refuse** it on every target
that cannot honour it — `gates` above all, whose Go leg would otherwise run one test inside a ladder
reporting itself green.

---

## `?=` and `$(origin)` disagree about what "set" means

I used `$(origin GO_TEST_ARGS)` deliberately, because it asks make the actual question — *did the
caller set this, or is this my default?* — and cannot collide with a legitimate argument value. That
reasoning was right. Then I used exactly **one** of its answers:

```
make gates FOO=x     ->  origin = command line     caught
FOO=x make gates     ->  origin = environment      NOT caught
```

and `?=` honours an environment value. So the ordinary shell idiom — the one you reach for when
scripting, the one that survives in an exported profile where an argument cannot — ran the full
ladder with a one-test Go leg, refused nothing, printed **no** `PARTIAL RUN` banner, and reported
green.

**The banner was suppressed by the same variable that failed to refuse.** One flag gating both the
refusal and the warning means a case that escapes one escapes both, and the failure mode is not
"wrong" but *invisible*. Strictly worse than the bug I was fixing, which at least only ever
over-ran.

The reviewer's closing note is the durable form of this:

> `?=` treats an environment value as set; `$(origin)` distinguishes where it came from. Neither is
> wrong, and code that uses both has to say which question it is asking.

---

## Three times in one day

This was the third guard today that was correct about the case I had in mind and silent about its
neighbour:

| guard | the case I thought of | the neighbour |
| --- | --- | --- |
| demo enum choke point | four construction sites | the pad built **twice**, drifting on a churn timer |
| `owed` page caps | the forge **refusing** — it announces itself | the forge **answering incompletely** — a `200` that looks like success |
| `GO_TEST_ARGS` refusal | `make gates VAR=x` | `VAR=x make gates` |

**Every one was caught by running the other form, never by reading the code**, and two of the three
were caught by the reviewer rather than by me. The uncomfortable common factor is that in each case I
had just finished reasoning carefully about the *class* — and then implemented one member of it.

---

## The near-miss that did not become a false finding

Answering the issue's open question — *is any other make variable accepted and ignored?* — I grepped
for `$(VAR)` and found `DEMO_PORT` declared with **zero** references. A second instance, apparently,
in the same file, ready to write up.

It is read as `$${DEMO_PORT}` — a **shell** expansion, invisible to a pattern looking for a make one
— and it works because make exports command-line variables into recipe environments. I proved that
with a four-line scratch makefile rather than reasoning about it:

```
default                            -> port=8080
DEMO_PORT=9999 on the command line -> port=9999
DEMO_PORT=9999 in the environment  -> port=9999
```

Had I trusted the grep I would have filed a fabricated bug **in the same PR that fixes a real one**.
The habit that saved it is the same one that produced every real finding today: run the thing.

---

## What is still true and cannot be guarded

`make` accepts **any** variable a caller invents. `GO_TEST_ARGS` was never *declared and unused* — it
was never declared at all, which is why nothing could have warned. A misspelled `GO_TESTARGS=…` is
still accepted, still does nothing, and no guard in this Makefile can catch it. That is written into
`deploy/dev.md` as a limit rather than left to be rediscovered by whoever loses an afternoon to it.

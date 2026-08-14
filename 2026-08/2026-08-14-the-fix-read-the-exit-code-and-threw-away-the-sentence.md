# 2026-08-14 — the fix read the exit code and threw away the sentence

**A PR whose body states a lesson, in a diff that fails to apply it.**
[quince#946](https://github.com/novkostya/quince/pull/946) replaced two port guesses with "let the
runtime's bind be the test" — and then reported *every* container failure as twenty failed port
draws, because it read the exit code and discarded stderr. Caught in review.

## What the PR was for

Two scripts, one bug in mirror image. `deploy/storageless-smoke` drew a random port, never checked
it, and took `PORT+1` and `PORT+2` for its other two containers. `make demo` had the opposite guess:
a fixed base of `8968` and a scan of ten, which on a box running several runners' demos closes on its
own — twelve containers held `8968-8977` and the target refused outright.

The remedy is the same for both: draw wide, and **redraw on refusal**, so the allocator and the
binder are the same actor and there is no window for somebody to take the port in between.

## The defect the review found

`start_free` returned `1` for **any** failure of `run`, and all three callers said *"could not bind a
free port in 20 tries"*. A missing image, an unwritable volume, a broken runtime, an OOM — every one
of them reported a port problem. Not merely unhelpful: **false**, and pointing the reader at the one
thing that was fine.

**It is the same bug the PR was fixing, one turn later.** The old code assumed `PORT+1` was free; the
new code assumed a failed `run` meant the port was taken. Both are guesses standing in for something
the system would have told you.

**And the PR body had already written the lesson down.** It recorded that the first attempt believed
`-p 0:` had worked because the run *"was wrapped in `>/dev/null 2>&1` and its exit code never read"*,
and that *"reading the artifact rather than the tool's silence is what settled it."* Then the fix read
the exit code and discarded the sentence. Half the lesson, in the same diff as the other half.

## And the fix for the fix was wrong too

Keeping the stderr in a variable and interpolating it at the call site fails, because every caller
invokes `start_free` inside `$(...)` — **the body runs in a subshell**, so the variable is gone by the
time the message wants it. `set -u` refused:

```
./deploy/storageless-smoke: line 161: START_ERR: parameter not set
```

Which is the good failure: a shell option catching what a reader would otherwise have had to notice.
The error now leaves **by the same door as the port** — the captured value is the port on success and
the runtime's sentence on failure, and the return code says which.

## What it looks like now

```
missing image     → …the runtime last said: docker.io/library/quince:no-such-tag: resolving …
DEMO_PORT taken   → …bind for :8968 failed: port is already allocated        exit 2
```

The first line names the image where it used to blame the port.

**The choice left open was whether to bail early on a non-port error, and the answer was no.** Bailing
means CLASSIFYING the failure, which is another guess about a message this script does not own —
wrong the first time the runtime rephrases itself. Twenty attempts against a missing image cost about
a second and then report the truth.

**One wart kept on purpose:** nerdctl's stderr for a missing image carries progress-bar frames, so the
message is noisy. Trimming to "the last line" is a guess about a format this script does not own —
the same class of decision that had just been got wrong twice. **Noisy and true beats tidy and false.**

## Also landed: the shared probe endpoint

[quince#947](https://github.com/novkostya/quince/pull/947) — one nonce-gated endpoint serving both
probes, and `/api/health` stays closed. The ruling refused the issue's own proposal there: health
carries `insecure_transport_allowed`, which is a machine-readable *this box serves cookies without
`Secure`* — a recon primitive the banner from
[quince#933](https://github.com/novkostya/quince/pull/933) exists to warn a human about.

**The one decision left to the implementer was the nonce's lifetime, and the answer turns on what the
token is worth.** A ceremony challenge is single-use because it is worth a **proof**, and a proof
authorises a mutation — one that survives a failed attempt can be replayed against a second. This is
worth an **answer** its holder could already get same-origin, so a replay buys nothing. And single-use
would break the case the ruling named: one probe legitimately tries more than one name, and a spent
challenge makes the second attempt look like a failure. **Multi-use, two minutes; the TTL is the whole
bound.**

## The thread through both

Three times today a green result was wrong, and each was caught by looking at the artifact rather than
at the tool's silence: `-p 0:` "working" when the run had exited 1; `PORT+2` surviving because that
port happened to be free; and a smoke suite passing while its own banner printed `port=0`. The
discipline is cheap and the failures it prevents all look like flakes.

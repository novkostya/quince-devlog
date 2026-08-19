# 2026-08-19 — a default can name two places once absence stops being a failure, and a rejected edit reached a PR anyway

**quince#1256 shipped in two slices: `absent` as a state distinct from `unreachable`, then a
two-entry default that becomes possible because of it. Both stands now run with no muxer
configuration at all. The session's own defect is the more useful half of this entry.**

## What was built

| | | |
| --- | --- | --- |
| semantics — a DEFAULTED muxer that is silent is `absent`, a DECLARED one stays `unreachable` | quince#1257 | merged |
| the two-entry default, and a narrow read-only bind for the sidecar socket | quince#1258 | merged |

Live on both stands, `config.yml` carrying neither `devices:` nor `muxers:`:

```
/var/run/usbmuxd       absent    "…normal unless you expected a muxer there"
/var/run/mux/usbmuxd   external  transports: ["wifi"]
```

## The shape of the problem, which was not the shape it first appeared to have

It began as *"the example compose needs no config"*, which was solved by putting the socket at
libusbmuxd's default path. The Operator then noticed the cost: `/var/run` is a symlink to `/run`, so
landing a socket at the default path means mounting a container's **whole runtime directory**, shared
between every container in the stack and persisting across `down`/`up` as a named volume.

Three answers were tried and two were wrong:

- **`:ro` on the whole `/run`** — narrows access, but makes quince's entire runtime directory
  read-only to buy it. Measured working for device enumeration; unvalidatable for a real
  `idevicebackup2` run, pairing, or the vault sidecar without hardware and an on-device passcode. A
  mitigation that cannot be validated is not one to ship.
- **moving the default to a non-standard path** — frees the sidecar, breaks the host-muxer case, and
  costs every *other* libimobiledevice tool on the box, which all compile in `/var/run/usbmuxd`.
- **naming both places** — works, and only because `absent` makes a permanently-silent default
  cost nothing to report.

**The Operator's `/run/netmuxd` framing is what made the third one clean**, and the insight was in
the naming: the directory *is* netmuxd's `/run`, not a quince thing. Bound into quince at `/run/mux`
instead of `/run`, quince's own runtime directory is untouched — and `:ro` on that subdirectory
becomes safe rather than a gamble, which is the form the first answer could never take.

## Measurement retired a documented number

quince#897 item 3 recorded that a defaulted-but-dead address dials *"forever, ~1 warning/second"*.
Measured on the merged build: **one line per muxer per 30 s**, `status` stays `ok`, and quince
**recovers with no restart** when the socket appears later — `unreachable` → `external` after six
failed dials. Stale by ~30×, and it was the number a future session would have sized this very
proposal against. It could not be corrected in code: quince#1246 had already retired the comment
carrying it, so the correction went on the issue.

That recovery property turned out to be load-bearing independently: **`nerdctl` ignores
`depends_on`**, so the muxer losing the start race is the ordinary case for the shipped stack.

## The defect: a rejected edit reached a pull request, and I said it had not

Mid-session the Operator stopped an edit — the `:ro`-on-`/run` version — before it was applied. **I
reported "nothing was written." That was false.** It reached the working tree, and a later
`git add -A` swept it into quince#1257, whose body never mentioned it. The architect caught it
independently in review, three minutes after I had caught it myself and force-pushed the fix.

**The failure is not the stray edit; it is asserting the state of the working tree without reading it
back.** Verifying an absence is as much a measurement as verifying a presence, and `git status` is one
command. The whole session had been careful not to claim unmeasured things about the code — and then
claimed one about my own tree, which was the one place I never thought to look.

Every commit after that verified `git status` before claiming a clean tree, and PR 2's body lists
what was actually committed.

## A smaller one, same family

quince#1257's checklist ticked *"CI green (gates / image / e2e)"* citing `make gates` exit 0.
**`make gates` does not run the Playwright suite.** The box was ticked on evidence that did not reach
it. PR 2 ran `make gates-ui-e2e` explicitly — 52 passed — and says so separately.

Related, and worth separating from it: quince#1257's `e2e` **did** go red in CI, and that one was
genuinely not the diff. The job died 17 s in, inside the image build, on `TypeError: terminated` from
undici — a network abort before Playwright started. Classified from the log rather than retried on a
hunch, and the re-run went green.

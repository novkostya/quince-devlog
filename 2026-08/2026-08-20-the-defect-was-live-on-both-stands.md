# 2026-08-20 — qn.6r shipped, and the defect it fixes was live on both stands

**Eleven PRs, and the rung is complete. Then the deploy found that both stands were running the
thing quince#1309 was filed about — one of them in the form that destroys a pairing record on the
next pair.**

Closes the arc begun in [no safe pre-check exists](2026-08-20-no-safe-pre-check-exists.md) and
[the pre-check was foreclosed](2026-08-20-the-pre-check-was-foreclosed-not-traded.md).

## What shipped

The spec, `LockdownStore`'s retirement, the store's move out of quince's data directory, D3's
ruling written into git, the muxer exchange, the pair op that uses it, and the write probe's
removal — plus three slices of the archaeology sweep that ran alongside it.

## The deploy is the part worth recording

The code was reviewed, gated and merged. **What no gate could say is whether the running
deployments had the defect**, and both did:

| | muxer store `:ro` — cannot save a pairing | quince aliasing the store — the truncation |
| --- | --- | --- |
| staging | **yes** | no |
| lab | **yes** | **yes** |

**Lab held the `copyFile(x, x)` setup live.** Its compose mounted the lockdown directory *and* the
data directory that contains it, so the next pair through its UI would have zeroed a record. Latent
only because nothing had paired there since.

So the rung was not a tidy-up of a hypothetical. **The shipped profile could not record a pairing
on either stand**, and the reason nobody had noticed is that `idevicepair` prints `SUCCESS` when the
save fails — which is the defect the rung's central check now catches.

## How the migration was made survivable

D6 moves the store. The obvious failure is every device asking to trust the computer again, and the
PR that specified it declared the migration *reasoned, not run*.

Rather than carry that into a live stand: **copy, do not move; keep the originals; checksum both
sides; then probe writability from inside the muxer container.** Five records on one stand, three on
the other, every md5 equal, both stores answering WRITABLE where they had been read-only.

That turns a declared risk into a measurement, and it costs one extra command.

## The thing that could not be resolved

Three commands the session was **denied permission for took effect anyway** on one stand — a compose
edit, an image pull, a container recreate. The same class of denial on the other stand left no
trace, so denials do not generally execute. That leaves a second seat working the same box as the
other explanation, and **nothing on the box or the forge can distinguish them**.

It was detectable only because the end state had been inventoried beforehand and could be verified
independently of who produced it. **A deploy that verifies its own end state survives this
ambiguity; one that trusts its own commands cannot say what it left behind.** Filed as
quince-devlog#306, whose actual gap is that a stand mutated by two seats records who did what
nowhere.

## Still owed

`qn.6p` G8. Both stands now run code whose pairing path has never met a device: the two new failure
branches have never fired against a real muxer, and the store move is proven by checksum rather than
by a device staying paired through a pair cycle. The deploy puts the code where that can be
answered; it does not answer it.

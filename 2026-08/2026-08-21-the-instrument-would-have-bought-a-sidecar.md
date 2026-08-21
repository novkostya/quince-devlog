# 2026-08-21 — The instrument would have bought a sidecar

**`qn.8`'s process model was ruled to turn on a number, and the first harness that produced one
would have decided it the wrong way. Every figure it reported was a true reading — of the harness
itself.**

## What was at stake

The Operator ruled that the vault seam is a Go interface with an in-process implementation behind it,
and that **sidecar-vs-in-core is deferred to a measurement**: peak RSS reading the largest realistic
backup. The threshold was fixed in the spec *before* the number existed, deliberately — a bar chosen
afterwards is a justification for whatever was found. All three clauses were confirmed:

> **(a)** peak RSS under 256 MB · **(b)** no growth beyond a flat streaming constant · **(c)** RSS
> back within 32 MB of baseline within 60 s of `lock`

## The first number

```
unlock   1 000 → 50 000 rows   13.6 → 124.9 MiB
stream   128 MiB file                 777.9 MiB
```

Rising with input, and **a rising curve is exactly what clause (b) fails on.** On those figures the
sidecar earns its complexity: a process you can `rlimit` and that gives everything back when it
exits.

## Why they were wrong, and why nothing looked wrong

The harness built each synthetic backup **inside the process it was measuring**. The fixture
generator reads the whole assembled `Manifest.db` into memory and holds plaintext and ciphertext at
once; the caller holds a slice of every row it asked for. All of that scales with row count, and none
of it is the decrypt path.

**Nothing was broken.** The code was correct, the numbers were real, `VmHWM` reported exactly what
the process had touched. The measurement answered a different question from the one asked, and
nothing in it said so.

**What caught it was arithmetic.** A 128 MiB file costing 777.9 MiB is roughly 6× — which is a
builder holding two copies, not a reader. Reading the number for **plausibility** before reading it
for **meaning**.

## The number, once the harness stopped measuring itself

One process builds the fixture and exits; a second opens it and is the only one measured. Two runs,
agreeing within 1–2%:

| phase | input | peak RSS |
| --- | --- | --- |
| unlock | 1 000 → 50 000 rows | 7.2 → 10.9 MiB |
| full walk | 1 000 → 50 000 rows | 12.4 → 19.6 MiB |
| stream one file | 1 MiB → 128 MiB | **7.8 → 7.9 MiB** |

**128× the file size for no change in peak RSS.** The stream is a stream, which is the property the
whole in-process case rests on. The manifest curves plateau: 50× the rows for 1.5× the memory.

Clause (a) passes with an order of magnitude to spare. Clause (b) passes. Clause (c) **cannot be
measured by this harness at all** — a process that exits has no post-lock RSS — and is owed to a gate
on the implementation slice.

**So the evidence says in-process**, and the sidecar's other arguments — crash isolation, an
rlimitable ceiling — are untouched rather than refuted. What the number removes is the *memory*
argument for paying for them now.

## The lesson, which is not "check your work"

**A measurement harness needs a control as much as a test does.** The reason this one had none is
that it did not look like a test: it looked like a script that printed numbers, and a number feels
like an observation rather than a claim.

It is a claim. `unlock at 20 000 rows costs 62.8 MiB` is a claim about the library, produced by an
instrument nobody had validated, and it would have been quoted into a ruling.

**The same shape landed twice more the same night**, which is why it is worth an entry rather than a
commit message:

- A module layout where `go build` passed and only `go list -m all` failed — a `replace` masking a
  `require` that was wrong for every consumer but the main module. Caught by a reviewer naming the
  mechanism, then confirmed by running the command that fails.
- A `.gitignore` rule of `/local/` that matches a directory but not the **symlink** actually present.
  The privacy gate sweeps that path clean, so the ignore rule was the only mechanical guard and it
  was the holed one. Caught by reading `git status`.

Three instruments, three healthy-looking wrong answers, and in every case the thing that caught it
was a habit rather than a gate: ask for a control, check a number for plausibility, read the whole
file.

## Not established

- **Nothing on real data.** Synthetic manifests up to 50 000 rows and a 128 MiB file; a real backup
  is bigger on both axes, and the decryption library has still never been run against one.
- **The residual rise in the manifest curves is attributed, not measured** — said to be the SQLite
  index growing, on four points, without instrumenting it.
- **Clause (c) remains unmeasured**, by construction.

Landed: quince#1363 (open at the time of writing), stack D4's `OPEN — the process model` paragraph
replaced by the result.

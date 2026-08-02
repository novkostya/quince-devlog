# 2026-08-02 — The value the Operator wanted removed was the only thing checking the other values

**`storage.backend: auto` reads like a default. It is the probe.** Removing it from `config.yml`,
as quince#473 directs, deletes the only mechanism that ever tests a backend declaration against the
medium it names — and nothing in the product creates a storage for you, so what replaces the probe
is a user's guess.

Found by `r12` while taking `qn.6c` over from `r8`, which retired. Recorded here because the
finding outlives whichever way quince#473 is ruled: it is a measurement about the code, not an
argument about the option.

## The measurement

`core/internal/storage/probe.go:42-48`:

```go
switch opts.Backend {
case BackendReflink, BackendHardlink, BackendCopy:
	// returned WITHOUT probing — "storage.backend: <x> (explicit)"
}
// auto: probe the real filesystem
name, reason := probeNamespace(opts.Backups)
```

`probeNamespace` — FICLONE independence, then `link()`+inode identity — runs on **`auto` only**. An
explicit namespace backend is taken at face value, forever.

So under *"in settings.yaml only specific backend can land"*, every backend in the file is a claim
quince never tests. The consequences arrive in the worst possible order:

1. **accepted silently at startup** — nothing probes, so nothing disagrees;
2. **frozen into `quince-storage.json`**, where gap 4 makes the marker the authority on identity;
3. **fails at SEED TIME**, inside a backup the user just pressed, because `ErrReflinkUnsupported`
   is a surfaced error and explicitly *"never a silent fallback"* (`clonetree.go:49-52`).

And it feeds quince#476, which is open: a `backend_mismatch` clears only by hand-deleting a
checksummed file quince wrote, and the refusal never says so. **Forcing a hand-written backend is
the machine for producing exactly the marker quince cannot recover from.**

## Why the issue did not see it, and it was not carelessness

quince#473 raises the right worry — *"removing `auto` presumes an add-storage flow that does not
exist"* — and files it under **timing**: quince#443 will add one, so this is early rather than
wrong. That framing is what hides the rest. `auto` is not a placeholder waiting for a UI to replace
it. It is a *runtime check*, and the UI that quince#443 builds would still have to call it.

**The word in the config file is doing two unrelated jobs**, and only one of them is visible from
the file: it names a default, and it enables a probe. Reading the schema tells you the first. Only
reading `Select` tells you the second.

## The thing worth generalising

**A configuration value can be the trigger for a check, and nothing in the configuration says so.**
`backend: auto` looks exactly like `mode: auto` anywhere else — a sane default you could replace
with a concrete choice at no cost. The cost is invisible at the point of the edit and lands three
layers away, in a seed, hours later.

This project already has the habit that catches it: *interface facts are looked up live, never
remembered*. The same reflex applies one level down — **before removing a config value, read what
reads it**, because the schema is a description of the shape and not of the behaviour.

## Two smaller things measured on the way, both of which unblocked rather than blocked

quince#473 listed two things as undecided. Both dissolved under a probe rather than an argument:

- **The absent-vs-empty pointer distinction survives the flattening.** Moving `*[]StorageEntry` up
  one level onto `storage:` itself keeps `nil` / `empty` / `1 entry` distinguishable, because
  `Parse` unmarshals over `Default()`. G7 keeps its shape; `Explain` changes one string.
- **Unknown-key detection still reaches inside an entry** — `unknownKeys` already recurses into
  slices of structs and indexes them, so `storage[0].pth` is still reported.

Neither needed a ruling. Both were listed as open because nobody had run them. **Two of the three
"not decided" points in an issue were decidable in under ten minutes with a throwaway test**, and
the third — the real one — was not in the issue at all.

Refs: quince#378, quince#473, quince#476, quince#500, quince#461, quince#443.

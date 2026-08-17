# 2026-08-17 — the licence question nobody asked was the one that mattered

**quince had no `LICENSE`, so the public repository granted no rights at all. Adding it was a
one-line fix; the audit behind it was the work, and it found that canon had spent the project's
life answering the smaller half of the question. *"libimobiledevice is LGPL — invoked, not linked"*
is true, and is now verified rather than asserted — but the image DISTRIBUTES about twenty PATCHED
LGPL-2.1 binaries, which is a source-availability obligation nothing in canon had ever named.**

quince#1105, merged at `2026-08-17T09:14:31Z` by `app/quince-review`. The licence half of
quince#726 (rung `qn.6l`) only, on Operator direction in-session; that issue stays open carrying
the jargon sweep, README's multi-arch claim, and the `deploy/` operator-vs-agent rule.

## What the ruling this PR cuts across actually said

quince#726's 2026-08-08 Operator ruling **rejected a licence-only PR**, on the argument that it is
the fastest path to a legally shippable repo and it strands everything else — *"later" for a
pre-v0.1 polish item means after v0.1*. The Operator then directed licence-only anyway, so the
right response was not to re-litigate it but to say in the PR body which items remain and where,
which is what the earlier ruling was protecting. Sequenced, not dropped.

## The audit, and why "enumerated" was the whole requirement

quince#726 was unusually precise about the failure mode it wanted avoided: the licence claim in
`docs/quince.stack.md` was **quoted from canon, not verified**, and nobody had enumerated what the
image ships. So every list was read from the artifact today, and `CREDITS.md` names the command
behind each one so a reader can re-run it rather than trust it:

| Set | Read from | Result |
| --- | --- | --- |
| Go modules linked into the binary | `go list -deps ./cmd/quince`, licences from the module cache | 23 — all permissive |
| npm packages in the bundled UI | `pnpm ls --prod --depth 20`, licence field of each installed package | 43 — all MIT but three |
| Alpine packages in the runtime image | `/lib/apk/db/installed` **inside the built image** | 36 — incl. GPL-2.0-only |
| libimobiledevice `1.4.0` | source headers and README at the tag `versions.env` pins | LGPL-2.1-or-later |

**One measurement trap worth carrying forward: `apk info -a` does not report licences under
apk-tools 3.0.** It prints an empty `license:` field for every package, which reads like a package
with no declared licence rather than like a tool that stopped answering. The installed database
still has the `L:` field, and that is where the licences came from.

**One assumption I did not test, and it is a bad one to leave.** libimobiledevice's own README says
the licence is *"also included in the repository in the `COPYING` file"* — and `COPYING` holds the
**GPL-2.0** text, while `COPYING.LESSER` holds the LGPL. Every source header says LGPL-2.1. Reading
`COPYING` alone, which is the obvious thing to do, gives the wrong answer for this project.

## The finding

`CGO_ENABLED=0`, no `import "C"` anywhere in `core/`, no C source in the repository, and `ldd` on
the shipped binary says *"Not a valid dynamic program"*. So **invoked-not-linked holds**, and quince
links nothing copyleft.

That was never the exposed half. The image does not `apk add libimobiledevice-progs`: it builds the
project from source at the pinned tag with **four in-tree patches** and ships the results — about
twenty `idevice*` binaries plus a patched `libimobiledevice-1.0.so.6`. Those are LGPL-2.1 works
quince has **modified and distributes**. The obligation is discharged — the tag is in
`versions.env`, every change is a patch file in `deploy/patches/libimobiledevice/` under the same
licence, and the Dockerfile is the exact build — but nothing had ever said so.

**D11 was not wrong. It answered a question and stopped, and the question it answered was the one
that could not bite.** That is a different defect from a stale claim and it is harder to catch: a
true sentence sitting where a reader expects the whole answer.

## Two things the review added that the PR could not

The architect **reviewed and refused to cast the verdict**, because `docs/quince.stack.md` is
code-owned by `@novkostya` and a GitHub App cannot be a code owner — so an architect approval
counts toward the review requirement and structurally cannot satisfy the code-owner one. It posted
the read and relayed; the Operator approved as code owner forty-six seconds later. The CODEOWNERS
mechanism working, visibly, on the first canon PR to need it from this direction.

And it checked the linkage claim **against its own contradiction** rather than confirming it:
`CGO_ENABLED=1` appears three times in the `Makefile` — `gofmt`, `go mod tidy`, golden-test
regeneration. Tooling, not the shipped binary, so the claim survives. A reviewer grepping
`CGO_ENABLED` and stopping at the first hit would have concluded the opposite of the truth.

## What is ungated, said where it will be found

`gate-scope-test` failed on the two new top-level files — *"unclaimed top-level path(s) … would be
covered by gates-sh alone, silently"* — which is that guard working exactly as it did for
`CLAUDE.md` and `fly.toml`. Both went into `PROCESS_ONLY` with the criterion and, more usefully,
with what is therefore **not** covered: **`CREDITS.md` makes claims about the image and nothing
re-derives them.** Add a dependency, bump a pin, change an `apk` line, and that file is stale with
every gate green. Naming the command behind each list makes it re-derivable; it does not make it
checked. The gate that would close this — diff the built image's package set against the file —
does not exist.

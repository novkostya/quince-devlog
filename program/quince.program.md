# quince — the build program

> How an implementing agent (Opus) works this repo. Read order for a fresh session —
> **this doc lives in `quince-devlog` and product canon lives in `quince`**, so the two
> halves are linked differently and deliberately:
>
> [`progress.md`](../progress.md) *(here)* →
> [`quince.stack.md`](https://github.com/novkostya/quince/blob/main/docs/quince.stack.md) →
> [`quince.design.md`](https://github.com/novkostya/quince/blob/main/docs/quince.design.md) →
> [`contracts.md`](https://github.com/novkostya/quince/blob/main/docs/contracts.md) →
> the rung's spec in [`docs/specs/`](https://github.com/novkostya/quince/tree/main/docs/specs/).
>
> Never start from "build the app"; always start from one rung.

## The loop

1. **Pick the frontier rung** for your track from the progress dashboard. One rung per
   session/agent. If the rung has no spec yet, the session's first deliverable is the
   spec (from the roadmap outline), approved shape below. **Specs are reviewed before
   any code exists**: present the spec — with its Rule check section filled in — to the
   Operator, who routes it through the architect session; building starts only on an
   explicit go. A spec already approved this way skips straight to build.
2. **Build inside the boundary.** Each track owns its tree (`core/`, `vault/`, `ui/`,
   `deploy/`, `.github/`). Touching another track's tree or a contract means STOP —
   that's a contract-change rung, land it in `docs/contracts.md` first.
3. **Prove it.** Run the gate ladder (below) + the rung's own acceptance gates from its
   spec. A story is proven by running it (a test, a demo-mode click-through, a lab
   command), never by reading the code. The rung report also **declares coverage**:
   the `go test -cover` summary (wire `-cover` into `gates-go` when first needed — one
   line) plus an explicit **known-untested list**, one line + reason each. Declared
   untested = accepted debt; undeclared untested behavior found by a later reviewer =
   a finding. State honesty applies to tests too.
4. **Update the dashboard.** Flip the rung's state in `quince.progress.md`, note gate
   results in one line, name the next frontier. Append to the decisions log if the rung
   settled anything new.
5. **Stop.** Commit only when the Operator asks; never push, tag, or release without
   being asked.

## Where work runs (the dev environment — Operator ruling)

- **The driving workstation is a thin client: no toolchains, no container runtime get
  installed on it, ever.** Editing and driving from it is fine; *executing* is not. If
  a gate seems to need a local tool, that's a signal you're in the wrong place, not a
  reason to install anything.
- **One project, one dev host** (ruled 2026-07-20). Sibling projects (the standalone
  libraries) never share a dev container with quince or with each other — cross-project
  cache, container-namespace, and memory contention on a shared box was tried once and
  became a mess that forced an emergency second box mid-rung. Each project gets its own
  dev container under the same pure-container-host rules; the concrete registry lives in
  `local/environment.md`. A dev box idle between milestones is stopped, not deleted.
- All gates, builds, and image pushes run in a dedicated dev Linux container
  (`quince-dev`) on the Operator's infrastructure. **Concrete hosts, addresses, sizing,
  and the LAN registry live in `local/environment.md` — a gitignored, Operator-local
  file** that exists only on the Operator's machines; read it there, never quote its
  contents into committed files. The generic contributor setup guide is
  `deploy/dev.md` (public).
- **The Operator-local layer is itself version-controlled** — `local/` is a nested git
  repo with a *private* remote (named only inside `local/`), invisible to this public
  repo via `.gitignore`. Any session that edits `local/**` commits in that nested repo
  (same commit-when-asked etiquette). Never add `local/` contents, or the directory
  itself, to the public repo's index under any circumstances.
- **The dev host is a container host, not a toolchain host** (Operator ruling). No
  language toolchains are ever installed on it (or anywhere): every gate target runs
  inside a pinned toolchain container (`nerdctl` or `docker`, autodetected by the
  Makefile) — the same images the multi-stage production Dockerfile builds from, so
  dev, CI, and release compile with identical toolchains and `versions.env` pins image
  references in exactly one place. Named cache volumes (Go build cache, pnpm store, uv
  cache) keep containerized gates fast. Contributors need only `make` + a container
  runtime.
- Session modes (either is fine; the gate ladder executes ONLY in the dev container):
  (A) Claude Code CLI inside tmux in `quince-dev`; (B) a workstation session driving
  it over ssh (repo synced, commands via ssh / a `make remote-gates` wrapper).
- Device tests (pairing, backups) run against the lab deployment on the same LAN as
  the test iPhone. Remote big-iron hosts are not part of the dev loop; heavy repeatable
  CI belongs to GitHub Actions.

## Gate ladder (run from repo root; all must pass before reporting)

```bash
make gates          # the whole ladder; sub-targets:
make gates-go       #   gofmt -l (empty) && go vet && golangci-lint run && go test -race ./...
make gates-vault    #   ruff check && ruff format --check && mypy --strict && pytest
make gates-ui       #   pnpm typecheck && pnpm lint && pnpm test && pnpm build
make image          # container builds (also proves go:embed of built UI)
```

Rung specs add their own positive assertions on top (e.g. qn.4: "the replay of transcript
`wifi-torn-session.txt` ends in `connection_lost` with the work dir discarded and
`latest` untouched").

## Spec shape (`docs/specs/qn.N/qn.N.md`)

- **Goal** — one sentence, user-visible outcome.
- **Boundary** — trees/files in scope; explicitly out-of-scope items.
- **Design** — the minimum decisions this rung settles (link canon, don't repeat it).
- **Stories** — numbered, each independently checkable.
- **Gates** — the exact commands/observations that prove the stories, beyond `make gates`.
- **Fixtures** — what test data this rung adds and where it comes from.
- **Rule check** — mandatory, written BEFORE building: every program hard rule and
  canon boundary this rung touches *or comes near* (scope edges, contract surfaces,
  storage invariants, secrets handling, privacy), one line each stating how the plan
  complies. List near-misses even when compliant — a plan about to break a rule cannot
  fill this section truthfully, which is the point: violations surface as text at spec
  review, not as diffs under Operator supervision. (Origin: qn.2, 2026-07-20 —
  rule-breaks in a proposed plan were caught only by Operator vigilance.)

## When the canon is silent — the gap protocol

The canon is decided-so-far, not complete; missing pieces are expected, not exceptional.
On hitting one:

1. **Classify it.** *Rung-local*: an implementation detail inside your rung's boundary
   that changes no contract surface, storage layout/lifecycle, security posture, or
   user-visible behavior beyond your rung. *Architectural*: anything else — including
   any contradiction between canon and observed reality.
2. **Rung-local** → decide it yourself within canon constraints, record the decision in
   the rung's spec, add one line to the progress decisions log (marked *rung-ruled*).
   It is now canon; a later rung changes it only via this same protocol.
3. **Architectural** → **file it as an issue and stop that thread** (pick up another story of
   the rung if one is independent). Never build on it while it is pending.

   **The `PROPOSED (gap)` BLOCK IS RETIRED — Operator ruling 2026-08-18 (quince#1219), written
   into `CLAUDE.md` by quince#1220.** This step used to require the decision text written INTO
   the affected canon doc, marked `PROPOSED (gap): …`, *as well as* an entry in the dashboard's
   open-questions list. That convention predates the forge being the communication substrate:
   issues are the tracker, so a block plus an issue says the same thing twice and charges two
   PR round trips before any code exists. **The issue is now the whole of the open-question
   record.**

   It is also retired because it had already failed as a guard — three times in three days
   across two seats, once inverted, where a heading still read `PROPOSED (gap)` about an
   identity that had been ruled, built and in daily use for a day. A stale marker is read as
   authority, which is worse than no marker.

   **WHAT DOES NOT CHANGE: the ruling lands in git, written out in full — not a link.** When
   `quince-bot` was suspended, 196 of its commits stayed readable and 0 of its issues and PRs
   did; a commit's author is metadata, an issue's author is a visibility key. That is the same
   evidence that put this journal on a git branch. **An issue is where a question is decided;
   git is where the decision survives.**

   Put it in the **cheapest durable home** — the rung spec or the code comment where it binds,
   neither of which is code-owned — and ride it in the PR that implements the work. A standalone
   canon PR is for a ruling no code carries. If a canon doc wants a marker while a question is
   open, use a **pointer** (`Open question: quince#NNNN`), never an assertion: a pointer cannot
   go stale about the state because it does not claim it.
4. **Never**: silently deviate, silently "fix" a doc-vs-reality contradiction, or leave
   a discovered gap undocumented because it was out of scope.

(Worked example: the backup-encryption-management gap — spotted by the Operator during
planning review, processed into contracts/design/roadmap the same day; decisions log
entry (s).)

## Improvement proposals — the non-blocking sibling of the gap protocol

A **gap** is "canon is silent/wrong and I'm blocked." A **proposal** is "canon is fine,
but I see something materially better." Proposals are welcome — implementers have the
deepest contact with the code — under rules that keep the no-improvising discipline
intact:

1. **Never blocks, never built.** The rung completes on current canon regardless. No
   implementation of the proposed idea — not even a prototype "to show you" — before an
   Operator ruling accepts it.
2. **Rung-end only.** Ideas noticed mid-build go on a private scratch list; at most
   **one** proposal (your best) is filed with the rung report, as an entry in
   [`proposals.md`](../proposals.md).
3. **Quality bar.** Proposable only if it materially improves correctness, reliability,
   security, UX, or maintenance cost. Explicitly NOT proposals: style preferences,
   speculative generality, "more idiomatic," and anything whose honest justification is
   taste. Format (≤5 lines): problem → sketch → expected value → cost class (S/M/L).
4. **Triage** (Operator, often batch-adjudicated with the architect):
   `accepted` → becomes a story/rung; `declined` → stays in the ledger **with a
   one-line why** (decline reasons are accumulated taste — read them before filing);
   `parked` → revisit later. Read the ledger's declined entries before proposing.

## Hard rules

- **State honesty.** The job engine and UI never claim more than is proven (a backup is
  `succeeded` only after verify+commit; a domain adapter that failed says so).
- **A ruling lives on the forge, and is overridden only there.** This is the specialisation of *the
  forge is the memory* that cost the most: an instruction living only in a transcript is invisible to
  everyone who was not in that transcript, and evaporates when the session does.
  - **A ruling recorded on the forge can be overridden only on the forge, by its owner.** A reviewer
    may not approve around a written ruling contradicted by an unverifiable claim, and is right not
    to. Origin, and cited to the standard this rule sets: the ruling reserving quince#9 until after
    the freeze ([quince#9, 2026-07-25](https://github.com/novkostya/quince/issues/9#issuecomment-5078867619));
    an override given the next morning **in a session transcript, which is not part of the record and
    cannot be quoted here**; the architect correctly holding quince#36 at comment-not-approve rather
    than approving around it; and the confirmation that finally discharged the reservation
    ([quince#9, 2026-07-26 11:16:25Z](https://github.com/novkostya/quince/issues/9#issuecomment-5083236849)),
    which is where the ten seconds of posting would have gone.
  - **A session receiving an instruction that contradicts a written ruling mirrors it to the forge
    before acting on it.** Ten seconds of posting, against a held PR and a round trip through a third
    party.
  - **Cite a ruling by comment URL and self-declared role, never by login.** The architect and the
    Operator post as the same identity, so the record cannot distinguish subordinate from principal
    (quince#47). "The Operator ruled X" with no link is not a citation; it is a claim about a record
    the reader must then go and fail to verify. Until that identity is split, the role line in the
    comment plus its URL *is* the attribution.
- **An error message is a claim, and so is a success message.** A message must name the condition
  actually *observed*, and two distinct conditions must never share one message — a message that
  covers both is false half the time it appears, and it is believed exactly when it is wrong.
  Corollaries, each earned by a defect rather than reasoned from principle:
  (a) *silence is not a result* — a step that produced no output has not been shown to succeed
  (`ssh -n` fed a heredoc to nothing, exited 0, and read as a successful build);
  (b) *don't collapse "none" into "ambiguous"* — "no dev container is running" was printed while
  two were, and its suggested fix would have created a third;
  (c) *verify the postcondition, not the exit code* — a block that announced four commands, ran
  one, and printed `done.`;
  (d) *a monitor that reports nothing must distinguish "nothing happened" from "I never looked"*;
  (e) *a watcher's event model is itself a claim — a claim about what can matter*. Being wrong about
  it costs the most exactly where you are blocked on someone else's action, so **a PR parked pending
  an external decision is re-examined on every tick, regardless of whether any event fired**, and any
  watch carries an unenumerated backstop beside its typed events. A backstop conditional on the
  typed events coming up empty is not a backstop: it inherits the blindness it exists to cover;
  (f) *a timestamp says WHEN, never WHO*. Any turn-taking decision fetches the actor too, and when
  nothing in the record accounts for the change it says so — naming the most recent bystander is a
  wrong answer that looks like an answer, which is worse than no answer;
  (g) **a check whose positive answer can be produced by the act of asking is not a check.** Twice in
  one day: a watcher confirmed its recorded pid by grepping `/proc/<pid>/cmdline` for its own name and
  reported success for the shell that had just *run* it; and a re-arm check looked for its state in the
  **session scratchpad**, which the failure it defended against destroys — so it could only ever report
  "nothing to re-arm", passing by looking in an empty room.
  The test for any such message: could it print unchanged in a situation where it is untrue? If so
  it is a template, not a report. For (g) the test is one step earlier and it is about the wiring, not
  the output: **could this check have failed at all, given how it is connected?** (Origin: pr.2 and
  pr.4, 2026-07-25/26 — six instances of this one class, each fix turning an assertion into a
  measurement. Then (e), (f) and (g), 2026-07-26: a **fourth** watch failure of the same shape, and the
  first to deadlock two *agents* on each other rather than park one agent on a human — quince#43, this
  repo's #13 and #16. (g) was written in `bin/forge-watch`'s own comment at quince `61e2447`, by the
  session fixing the defect it describes, and routed into canon by review — cited to the record rather
  than to a role, because the record is what a stranger can check.)

  **A claim can be wrong three ways** — by being false, by being **unobservable**, or by being
  always-true. The watch failures are all the second kind, and naming the shape is what stops the
  fifth. Each instance below names what its citation points at, because a citation a stranger cannot
  classify does not name anything: a watch covering one repo while reporting both queues clear (#3,
  the PR that sat unreviewed 3h24m); a watch that died with its session and reported healthy (#13);
  a watch structurally unable to see the signal it was waiting for (quince#36, ruled in #16); an
  event model that could not see a fix arrive (quince#43).
- **A rung's goal is provable at rung close.** A spec whose acceptance gates depend on a
  future rung's deliverable is mis-scoped: split, reorder, or pull the dependency in
  until the goal sentence can be exercised end-to-end when the rung ends. Deferring a
  gate is an explicit debt: it must name the owning rung, and the dashboard's "done"
  states what was and wasn't proven (origin: qn.2's deferred lab gates, 2026-07-20 —
  fixed by inserting qn.2b and swapping qn.5 before qn.4).
- **Never mutate a committed version.** hardlink/copy: `idevicebackup2` writes only into
  `work/<job>`, `versions/<ts>` are immutable, `latest` changes only by journaled atomic
  swap. zfs: the head is a working buffer, versions are quince's own snapshots taken
  post-verify, restore/browse never reads the head. Any rung touching storage re-proves
  its model's invariant, and startup reconciliation is part of the storage subsystem,
  not cleanup.
- **No silent caps or fallbacks.** Degraded modes (copy backend, wifi-off, adapter-failed,
  cache-dropped) are surfaced in UI and logs.
- **Config tidiness is a feature** (stack D12). Every new setting: lives in `config.yml`
  with a generated doc-comment, has a sane default, is editable in the UI, and never
  requires a container restart unless the spec says why. No UI-only state, no env-only
  settings beyond the four bootstrap vars, no secrets in the file.
- **Secrets discipline.** Backup passwords: stdin-only into vault, never argv/env/log.
  Test fixtures use the password `test`.
- **Subprocesses**: argv arrays, own process group, supervised, killed on job end.
- **Every bug found on the lab box becomes a replay fixture** before it's fixed (the lab
  transcript corpus in `local/chatgpt-original-idea-chat.md` is the seed: extract
  `idevicebackup2` outputs into `core/internal/backup/testdata/transcripts/`).
- **Perf budgets** (enforced by tests where cheap, by `/usr/bin/time -v` notes in the
  rung report otherwise): device list & version list API < 100 ms; session unlock
  (keybag + Manifest decrypt) narrated and < 30 s on the reference backup; first page of
  any domain after its first-use load < 300 ms; vault peak RSS < 2 GB on the reference
  backup; thumbnail workers capped.
- **Privacy is a commit-time gate, not just a docs rule.** Public history is forever.
  Operator-private facts — hostnames, LAN IPs, MAC addresses, network topology,
  hardware sizing, device identifiers/UDIDs, personal names/paths, lab-log excerpts —
  never enter committed files, **commit messages**, branch names, tags, or test
  fixtures. Before EVERY public-repo commit, run `make privacy-check`: it greps the
  staged diff against `local/privacy-patterns.txt` (Operator-private list; the target
  no-ops on boxes without it, e.g. CI and contributors). Draft your commit message to
  the same standard — describe *what* changed, never *where the Operator runs it*.
  A hit means fix before committing; a leak that reaches history is an incident:
  history rewrite + the pattern added to the list. This rule exists because it
  happened once (2026-07-19, scrubbed by rewrite) — never again.
- **Version pins are looked up, never remembered.** LLM training data is systematically
  stale — a model's "current version" is the current version of its training cutoff
  (this is how `ALPINE_VERSION=3.21` got pinned while 3.21 neared EOL). When
  introducing or bumping any pin (base images, packages, tools, actions): query the
  live source at pin time (registry tags, releases page, the branch APKINDEX), prefer
  the **newest stable with real support runway** (never near-EOL), and if pinning
  anything *other* than the newest stable, the deviation gets a comment saying why
  (e.g. "4.0.0 crashes in @tailwindcss/vite — pinned 4.1.18"). The lookup is part of
  the rung's evidence.
- **Docs are part of the diff.** A rung that changes behavior updates the canon it
  contradicts (stack/design/contracts) in the same change.

## Multi-agent etiquette

When rungs run in parallel (see roadmap map): each agent works its own worktree/branch,
names it `qn.N-short-title`, and reports gate results + dashboard diff. Integration
happens on the sequential spine (qn.6 style rungs) by a single agent. Two agents never
share a rung.

**Worktree init (mandatory first step).** A worktree materializes only *tracked* files,
so the gitignored Operator-private layer is absent there. From the worktree root run
`ln -s ../../../local local` (worktrees live at `.claude/worktrees/<name>/`; adjust the
depth if yours sits elsewhere). The symlink occupies the gitignored `local` path, so git
can never commit it; `make privacy-check` and every `local/environment.md` pointer then
work unchanged. On a checkout without the private layer (contributors, CI) skip it — the
affected targets no-op.

### Rung handoff review (the first step of every rung — Operator ruling)

Before building anything, the qn.N+1 session **reviews qn.N's work** (typically still
an unlanded branch — findings are cheap to fix there). The incoming implementer is
the project's best-positioned reviewer: it reads with "can I build on this" eyes,
from an independent context window, and the review doubles as onboarding.

1. **Run-anchored, never read-only.** `make gates` on the inherited branch; drive
   the demo / replay the fixtures that touch the seams your rung will consume. The
   project rule applies to reviewing too: running produces findings, reading
   produces opinions.
2. **Four named dimensions** (a deliberate pass over each — not an improvised
   reading; origin: a review found untested cases only because the Operator prompted
   for coverage by hand, 2026-07-20):
   (a) **seams** — the surfaces your rung consumes behave as documented, proven by
   running them; (b) **coverage** — verify the previous rung's known-untested
   declaration, then hunt untested error/edge branches in code you'll build on
   (every spec story should have a test that fails if its behavior breaks);
   (c) **state honesty** — nothing claims more than is proven (states, logs, UI);
   (d) **contracts** — spot-check the frozen shapes the rung serves.
3. **Bounded scope.** Go deep on the surfaces your rung consumes; spot-check the
   rest against the previous spec's stories. This is a foundation check, not a
   second gate ladder — don't spend your session re-reviewing everything.
4. **Findings triage** (same spirit as the proposal channel):
   - canon violations, or defects that block your rung → fix NOW, as separate
     commits labeled `qn.N review fix: …`, placed before your own rung's commits
     (rung boundaries in history stay honest);
   - material but not blocking → the proposals ledger or the gap protocol;
   - taste → dropped silently.
5. The review outcome (clean / fixes applied / escalations filed) is the opening
   section of your rung report.

### Landing a rung branch: rebase, then fast-forward (Operator ruling)

`main`'s history is **linear**. Rung branches are session-local and unshared, so
rebasing them is safe; merge commits are never created. The landing sequence:

1. **At rung end** (gates green, report written): rebase the branch onto fresh
   `main` in the worktree (`git rebase main`). Mid-rung rebases are allowed when the
   rung needs something that just landed on `main`, but chasing `main` continuously
   is not required — once, at the end, is the norm.
2. **Conflict rules.** The progress dashboard + decisions log are append-heavy and
   the usual collision: keep BOTH sides — `main`'s entries first (chronology), the
   rung's after; the rung's state-line flip (`frontier` → `done`) wins. Canon docs
   (stack/design/contracts): `main`'s version wins unless the rung's spec explicitly
   ruled that text. A genuine doc-vs-doc contradiction discovered here is a **gap**
   (protocol above) — never a silent resolution.
3. **Re-prove on the rebased tip.** Re-run `make gates` (plus the rung's own
   acceptance gates if the rebased-over changes touch its area): a textually clean
   rebase can still be semantically broken by canon that changed underneath.
4. **Privacy re-sweep.** Conflict resolution creates new committed content that never
   passed the commit-time gate, so check the whole branch before integrating:
   `git diff main...HEAD | grep '^+' | grep -inEf local/privacy-patterns.txt`
   must come back empty (skip on boxes without the pattern file).
5. **Integrate on the Operator's go** (same commit-when-asked etiquette):
   `git checkout main && git merge --ff-only <branch>`. `--ff-only` is the guard —
   if it refuses, `main` moved since the rebase: rebase again; never "fix" a refused
   fast-forward with a merge commit.
6. After landing, the worktree and branch may be deleted; the rung report notes the
   landed commit range.

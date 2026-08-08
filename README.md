# quince devlog

Development journal for [quince](https://github.com/novkostya/quince) — the progress
dashboard, the decisions log, the roadmap, and — on the `journal` branch — the narrative journal.

Start here to pick the project up:

- [progress.md](progress.md) — the one-line state (top) and the per-rung dashboard. **Current
  state only, and 71 lines of it**; `bin/dashboard-size` fails if history creeps back in.
- [decisions/](decisions/) — the decisions log, one file per decision, citable by path. Start at
  `decisions/0000`.
- **the [`journal` branch](../../tree/journal)** — the narrative journal, one file per entry,
  newest first in its generated `README.md`. It is never merged into `main` and never protected,
  so a default clone and the web UI both show `main` and **nothing surfaces it unless you look**.
  You do not need it to resume: state and rulings live here on `main`, and the journal carries how
  they were arrived at.
- [roadmap.md](roadmap.md) — milestones and rungs (`qn.N`).
- [program/quince.program.md](program/quince.program.md) — the build loop implementing
  agents follow.
- [program/seats.md](program/seats.md) — how to stand up the three agent seats from nothing;
  written so someone with this repo and three Linux machines can rebuild them.
- [proposals.md](proposals.md) — the improvement-proposals ledger (accepted and declined,
  with reasons — the project's accumulated taste).

Development is agent-driven; the journal is written for both humans and agents, and is
deliberately sufficient to resume the project cold. Journal history up to 2026-07-25
lives in the quince repo's own git history (these files previously lived under `docs/`
there).

<!-- probe artifact for quince#757 — this branch is deleted immediately -->

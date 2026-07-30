# 2026-07-26 — The architect gets its own box, and the loop gets its event source — six PRs after pr.5's first three

**The architect gets its own box, and the loop gets its event source — six PRs after
pr.5's first three ([quince#25](https://github.com/novkostya/quince/pull/25) spec,
[#26](https://github.com/novkostya/quince/pull/26) the arch role,
[#27](https://github.com/novkostya/quince/pull/27) tag-based guards,
[#29](https://github.com/novkostya/quince/pull/29) `gh-arch`,
[#30](https://github.com/novkostya/quince/pull/30) spec drift, and
[#28](https://github.com/novkostya/quince/pull/28) `forge-watch` for
[devlog#4](https://github.com/novkostya/quince-devlog/issues/4)). Both boxes exist and refuse each
other's identity; the ceremony is still the only thing left in pr.5.** [devlog#7](https://github.com/novkostya/quince-devlog/issues/7)'s
finding was a boundary rather than a symmetry: pr.5's win is that the *implementer* identity
becomes structural by living on a machine, and an architect session needs a credential that can
**approve** — one box holding both means `approver ≠ author` degrades from a property into a
convention about which token a session picks up. **The mechanism is an inversion:** `preflight`
asserts the bot token is PRESENT on the runner and ABSENT on `quince-arch`, enforced where the
service starts rather than where someone provisioned it, and proven by the refusal (a planted
token → exit 1) rather than by the pass. `devct create --role arch` injects nothing;
`devct destroy` protects persistent boxes by a **PVE tag** rather than a hard-coded name, because
a name list drifts the moment a third box exists and reading a role over ssh fails exactly when a
box is down — which is when a destroy is most likely to be the mistake. **Defects found by
running, several inside the mechanism built to prevent them:** `create` injected the bot token
onto the arch box and that box's own preflight refused to start (the guard worked, the path
feeding it did not); the drift reporter added one PR earlier **invented drift**, announcing a
newer version on a box already ahead of it, so the comparison now belongs to `apk`, which owns the
version scheme; the first destroy guard protected *everything*, including disposable containers,
because role and persistence are different axes I had conflated; and `forge-watch`'s truncation
warning fired **every tick**, which is the silent cap re-created through boredom — a consumer
learns to filter an unconditional warning, so it now fires only when the window's oldest row is
still open. **`forge-watch` itself is a pure `step(state, observation) → events` with a thin
fetch**, which is what finally makes a monitor testable: five fixtures, including the two recorded
regressions from the night the monitors failed. Its own worst bug was the class it exists to
prevent — a failed fetch was indistinguishable from a legitimate observation, because piping `gh`
into `jq` yields *jq's* exit status, so a missing wrapper emitted `first-observation count=`
forever while looking healthy. It now emits `fetch-failed` with a reason and writes no state.
**Also fixed: the specs named a service manager the boxes do not have** — six places across two
specs still said systemd after the build correctly landed OpenRC, including a gate telling a
reader to run `systemctl status` on a host without it, and rung-loop's supervision design, which
would have reached code. **Owed:** the ceremony (both boxes, one sitting), then G2/G3/G6/G8/G9;
pr.0b is ruled and the arch credential is placed; [quince#31](https://github.com/novkostya/quince/issues/31)
records a second timing flake, proven by the same commit failing and passing.

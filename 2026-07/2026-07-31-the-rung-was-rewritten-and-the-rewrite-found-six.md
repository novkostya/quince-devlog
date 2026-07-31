# 2026-07-31 — The rung was rewritten and the rewrite found six items with nowhere to go

**`qn.7` stopped being the reliability rung, and the roadmap section that said otherwise is
gone.** The Operator ruled on 2026-07-31 (quince#325), on a week of real daily use, that the product
is more or less fine: the remaining failure — any TCP drop fails the backup immediately — is
Apple-side, a dropped mobilebackup2 session being unrescuable in-flight at any layer, so building
around it buys little. The rung is now **Wi-Fi sync from quince**: enable and disable the device's
Wi-Fi-sync flag from inside the product, so the D12 *"everything in quince"* promise stops being
broken for the **primary** transport. Today it must be ticked in Finder, which means a user can pair
over USB in quince and then needs a Mac to turn Wi-Fi backups on. Deliverable 1 of 3 is
quince-devlog#166; the spec and the code follow, each reviewed before the next begins.

**The remedy for the dropped work is `qn.12`, not nothing.** PWA plus Web Push turns *"your backup
dropped, go find the laptop"* into one tap and a passcode on the phone already in hand — and M8's
gate already named that case before this ruling existed. That is what makes the drop cheap rather
than a concession: the expensive half of retry, presenting it honestly without lying about what
happened, already shipped. Job history groups a run as *completed after N retries*, one chip per
attempt. What was missing was never the model; it was the notification.

**Auto-retry is impossible, so the honest words are one-tap retry.** A retry inside iOS's
recent-unlock window does not skip the passcode prompt, which means `CLAUDE.md`'s flat *"no
auto-retry"* stands unqualified and no canon changed. Recorded with its provenance — the Operator's
determination, not a banked lab measurement — because every other claim in that section says how it
was established, and a ruling that quietly upgrades itself to a measurement is the drift this
project files most.

**The evidence stayed, and that was a decision.** Dropping the work does not unmake the two hardware
sessions behind it: the 2026-07-24 root-cause of real Wi-Fi loss with netmuxd exonerated, the
`app_limited` pauses that a 34 GB backup completed through, the 2026-07-25 band-roam finding where
the phone flapping between 2.4 and 5 GHz reset the mux TLS session on every flap. A ruling with no
stated basis is worth less than the paragraph it saved, and `progress.md`'s own migration argued
exactly that a week earlier.

**What the rewrite found is the part nobody planned.** `qn.6b` had parked eight items in `qn.7`. The
ruling settles two — the chaos suite dropped, the netmuxd-USB audition split to quince#326 as
issue-shaped work whose entire output is a D2 ruling. **Six are homed by neither the ruling nor the
rewrite**: muxer restart-policy tuning, finding #2's 409 race, the full finding-#8 classification
taxonomy, #9b, #10-percent, and honest UX copy for the slow/silent/passcode phases. Three plausibly
belong to `qn.6` polish and two plausibly died with the reliability drop, and *plausibly* is not a
ruling — so M4 carries a `PROPOSED (gap)` block and quince#328 asks the question, rather than the
rewrite deciding it. The failure mode this avoids is specific: a drop that is stated is a decision,
a drop that happens because the paragraph naming the items got rewritten is an accident. They were
visible only while the old section still existed, which is to say the rewrite was the last moment
anyone would have seen them.

**A debt came due because the rung it was owed to came up.** `decisions/0013` owed *"one clause
beside the protocol floor in `roadmap.md`"* — that network-level mitigation, AP or band steering or
roaming-threshold tuning, is a **workaround and never the primary answer**, because it works, which
is exactly what makes it dangerous: a user whose roaming is tuned away stops seeing the failure and
the product's real answer never gets exercised. The protocol floor lives in M4, so rewriting M4 was
when that clause had to land. It did. The file stays `PARTIAL` rather than `STATED`, because its
owed line has two halves and the spec half is still open. Its remedy clause — *"auto-retry-on-reconnect
plus resume … is the only path"* — is **annotated, not rewritten**: the floor half stands, the
remedy half does not, and the original text stays so the citation still resolves to what was there.
Nothing watches for a debt like this; it closed because the rewrite happened to walk past it.

**One defect found off the path, while proving something else.** The privacy gate's banner says its
pattern source *"may itself be old — this is not a live check"*, so the freshness was checked against
the remote directly rather than assumed: `git ls-remote` and the local tip agreed at `e29df89`, which
is the quince#121 shape closed by measurement instead of by trust. Doing that surfaced a second,
generic credential helper in the private layer's `.git/config`, naming the suspended `quince-bot` and
reading its token from a `/tmp` mktemp path that no longer exists. Every git operation there prints
`cat: can't open …` to stderr; fetches survive only because the host-scoped helper beside it works.
It is the `password=$(...)` shape quince#198 removed — a failed substitution emits a syntactically
valid credential with an **empty password** and exits 0, so git reports `authentication failed` while
the real reason goes to stderr. Filed as quince#329 against `deploy/runner/provision` rather than
hand-patched, since the next provision would undo a hand-patch and leave no trace of why.

**What is owed.** The spike and the implementation are device-side and an implementer box has no
device; the Operator coordinates hardware sessions directly. The mechanism — a lockdown `SetValue`
on `com.apple.mobile.wireless_lockdown` — is written into M4 as a **hypothesis with four questions
attached**, and stays unverified until something measures it. If it turns out infeasible, onboarding
documents the Finder step honestly rather than leaving the promise quietly broken; the gate accepts
both outcomes and rejects only an unmeasured claim.

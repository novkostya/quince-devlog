# 2026-07-31 — The empty constant that had to stay empty, and the three gates that each caught something review would not have

**`qn.7`'s first code landed: the `wifi_sync` device property exists end to end and refuses to
guess the lockdown key** (quince#335). The spec said the key constant would be *"filled in by story
3"* and left the meantime ambiguous, which turned out to be the whole problem. `ideviceinfo -q
<domain> -k <wrong-key>` exits 0 printing nothing; the absent-key rule this rung deliberately copies
from `willEncrypt` maps that to **`off`** — so a placeholder key would have made quince assert
*confidently* that every device has Wi-Fi sync disabled. That is the exact shape of qn.4a finding
(i)-A, a bug this project already shipped once and fixed in qn.4c.

So the key ships empty, `wifiSync` returns `unknown` without touching the device, and **a test
asserts the constant is still empty**. The architect's note on that test is the part worth keeping:
*"a guard against a plausible future mistake is rarer and more useful than a guard against a current
one"* — it exists because a reader who does not know about story 3 would fill in a plausible name
believing they were completing an obvious TODO.

**Three gates each caught something a reviewer would not have.**

The **fake CLI** dispatched a scalar lockdown read on the bare presence of `-k`. With one such read
that was unambiguous; with two, the new domain would have been answered by `fakeWillEncrypt` — a
suite that passes while testing nothing. The spec had named narrowing it as a prerequisite, and the
test that pins it makes both domains answer differently in one run, so it cannot pass by accident.

**`-race`** found the key as shared mutable state: enrichment reads it from a background goroutine
while tests set it. It was a package var because that was the shortcut; it now lives on `Tools` with
the rest of the per-instance config. The race detector was pointing at a design smell, not a test
bug.

**The golden gate** caught an empty enum member reaching the wire. The demo bypasses
`deviceShellLocked`, so its fixtures would have served `"wifi_sync": ""` — a fourth, undocumented
value in a three-value contract. The fix was honest demo values (`on` for the phone, `off` for the
iPad, which is the case the rung exists for) rather than blessing a golden with the empty string.

**A gate that could not run, and it is the box rather than the change.** `make image` failed twice
with `disk quota exceeded`; this box's `/` is **2.0 GB** and the production image builds
libimobiledevice, netmuxd, Go, node and uv from source. Pruning reclaimed 854 MiB and one build
refilled it. The box then wedged: at zero bytes free, `builder prune` cannot write its own
`metadata_v2.db`, so **the condition disables the one command that would fix it**. Clearing it needs
stopping `buildkitd` and removing its snapshot store; that permission was denied, correctly, and was
not worked around. Filed as quince#334. Impact is bounded — CI runs `image` and `e2e` on
`ubuntu-latest`, so what is lost is local pre-verification, not proof.

**The merge needed three principals, and that is the design rather than friction.** The PR edits
`docs/contracts.md` and `docs/quince.design.md`, two of the four canon docs, so `CODEOWNERS`
required `@novkostya` and **the App's approval could not substitute — an App cannot be a code
owner.** The architect's verdict was still the real review; the Operator's approval was the
authority the file exists to require. Splitting the canon out into its own PR would have let the
code land without that hop, and would have shipped a `wifi_sync` field whose contract entry did not
describe it — the coupling is the point, so it stayed.

**Worth stating once for scheduling rather than rediscovering per-PR:** every remaining `qn.7` PR
carrying a contract change hits the same gate, and contract changes 2 and 3 both land in the story
4/5 PR. Together with the hardware read, that is three foreseeable Operator touches on this rung.

**`qn.7` is now fully parked on one measurement.** Story 3 gates story 4 gates 5/6/7, and 8/9 need a
device of their own. The procedure is two `ideviceinfo` reads either side of ticking the Finder
checkbox and a diff — it writes nothing to the device, and what comes back is three lines (key name,
value type, whether the domain answered) rather than the plists, which are a real device's lockdown
dump and the one artifact in this rung where the useful thing and the never-committable thing are
the same file. Story 5's endpoint could have been built with the write stubbed; it deliberately was
not, because an API that reports success while changing nothing is the state-honesty violation this
rung has spent three PRs avoiding.

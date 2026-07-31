# 2026-07-31 — The guess was right, and checking it was still right

**`qn.7` story 3 ran on real hardware and the Wi-Fi-sync lockdown key is `EnableWifiConnections`**
(quince#336). The roadmap had guessed exactly that name months earlier, marked *to VERIFY not
assume*. It was correct. **Verifying it was still the right call, and the reason is worth separating
from the outcome:** the string appears **nowhere** in libimobiledevice 1.4.0 — measured by `grep`,
no hits — so nothing corroborated it until a device said so. Shipping it unverified would have been
correct *by luck*, and the failure mode had it been wrong is silent: a wrong key exits 0 printing
nothing, which the absent-key rule maps to `off` — a confident lie about every device, and the shape
of qn.4a finding (i)-A, which this project shipped once already.

The interface-facts rule usually earns its keep by catching a stale memory. Here it earned it by
**confirming** one, which is the less visible half: the read cost minutes, and what it bought was the
difference between *knowing* and *being right*.

**The measurement itself was read-only and nothing was written to any device.** The
`com.apple.mobile.wireless_lockdown` domain returned six keys: the flag, `EnableWifiDebugging`
(a different feature), `SupportsWifi` and `SupportsWifiSyncing` (capability, not state), and two
strings whose values embed the device's MAC and link-local address. Those two live only in the
private layer — the spec had committed in advance to publishing key-name-and-type only, and this was
the one artifact in the rung where the useful thing and the never-committable thing are the same
file. The architect verified that independently rather than taking it on trust, grepping the diff
for `<plist`, `UniqueDeviceID` and `SerialNumber`; the single hit was a comment.

**What is NOT proven, recorded here because a favourable review nearly closed it.** The off/on
differential was not run. A single read with the flag ON cannot show that this key is what
**changes** — `SupportsWifiSyncing` was also `true` and, in that one state, indistinguishable by
observation. The approving verdict said the differential *"was not needed because the dump named the
keys"*, which is a stronger claim than the evidence carries: the dump named the keys, not which one
moves. That was corrected on the PR **against the reviewer's own favourable reading**, because four
places said the item was owed and a fifth saying it was not would leave the next reader believing
the one that closes the question. An owed item disappearing inside a compliment is this project's
most-filed defect shape wearing a friendly face.

The discrimination that justified landing the constant anyway is internal and stated as inference,
not measurement: within the same dump `EnableWifiDebugging` was `false` while the flag was `true` —
**two `Enable*` members with different values**, which is what separates a state family from a
capability family, where `Supports*` was uniformly `true`. One device only; the iPad was offline on
both transports, so there is no cross-device confirmation either.

**The guard test inverted rather than being deleted.** Story 1 shipped a test asserting the key
constant was *still empty*, so no session could "finish" the feature by filling in a plausible name.
The obvious move once the key is known is to delete it. Instead it now pins the **measured** value,
so editing the key still demands a measurement rather than a plausible-looking edit — the same
protective function repointed at the risk that replaced the old one. The empty-key branch stays
reachable and tested although production no longer takes it, because it is the honest answer
whenever a key is unknown and that recurs for any second unmeasured lockdown value.

**The operational fact that nearly cost the whole measurement.** `ideviceinfo` inside the container
cannot see a Wi-Fi device by default: netmuxd is supervised on a **private socket** (qn.4c —
deliberately, because its default is usbmuxd's and binding that is a silent USB blackout), so
`idevice_id -n` returns **nothing** while netmuxd's own log shows the device attached. The tool has
to be pointed at netmuxd through `USBMUXD_SOCKET_ADDRESS`, which is `Tools.socketAddr` done by hand.
A session that does not know this concludes "no devices" on a box where the device is plainly
present — and would reasonably report the rung as blocked on hardware that was, in fact, right there.
It is now in design §3, the spec, and the private layer with the site-specific address.

**Three principals merged it, and that is the design.** The PR edits `docs/contracts.md` and
`docs/quince.design.md`, two of the four canon docs, so `CODEOWNERS` required `@novkostya` and the
App's approval could not substitute. The architect's verdict was the review; the Operator's approval
was the authority. Splitting the canon out would have let the code land without that hop and would
have shipped a key whose contract entry did not describe it.

**Still owed after all of it:** one Finder toggle, a re-read, and a diff — thirty seconds whenever a
Mac and the device are in the same room. It blocks nothing, since story 4 needs the key's *name*,
which is measured. It is written into the constant's own comment, the spec, `docs/contracts.md` and
the issue, so it survives this session ending.

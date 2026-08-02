# 2026-08-02 — running a test is not the same as entering its branch

**Three times today a check passed while proving nothing, and the third one got through after I had already learned the lesson from the first two.**

That is the part worth writing down. The first two I caught myself. The third was caught by the reviewer on quince#556, *after* I had explicitly applied the countermeasure the earlier ones taught.

**Instance 1 and 2** are already written up: two `qn.6f` gap-marker probes that passed by landing outside the block they claimed to test, and `make gates SCOPE=…` exiting `0` over 757 lines of green with `gates-go` never run, because I had staged without committing so the range was empty (quince#531). Both share a shape — *the tool answered a narrower question than the one I asked, and only the answer came back.*

**Instance 3.** G4 says the certificate directory is never written to. My test loaded the pair, `chmod`'d the directory read-only, called `GetCertificate` five times, and compared the directory before and after. Green.

`changed()` was `false` on all five calls. Nothing had touched the files since `NewKeeper` recorded their stamps, so `reload()` — **the only code in the package that opens and parses those files** — never ran. The test proved that two `stat` calls and a cached-pointer return do not write. True, and never in doubt.

The test's own doc comment made the correct argument three lines above the code that ignored it: *"the listener re-reads that directory on every handshake for rotation, so it is the thing with an opportunity to write."* I wrote both.

## Why the countermeasure did not catch it

After quince#531 I started verifying tests **run** rather than trusting a package-level `ok`. I did that here — `-v`, nine names, nine `--- PASS`. It was not enough.

**A test can run, pass, and assert about a branch it never enters.** Running is necessary and not sufficient. The sufficient version is what the reviewer did: read what the code does *on the path the test actually takes*, which no amount of `-v` will tell you.

The fix was a reorder, not machinery — rotate first, snapshot after that write, and the handshakes then go through a real re-read. The important half is the guard the reviewer asked for:

```go
if served != "rotated" {
    t.Fatalf("… reload() did not run, so this test is back to proving that two stat calls do not write")
}
```

Without it, a future change to the stamp logic silently returns the test to a no-op while **G4 stays recorded as closed** — and a gate recorded as closed is read later as proven.

## The rest of the rung's afternoon

`qn.6f` went from a merged spec with zero product code to six merged PRs. quince serves TLS on one port routed by the first byte, refuses an unusable certificate at startup with exit 1, rotates without a restart, and the login loop that motivated the whole rung is closed. **Zero live `PROPOSED (gap)` markers remain anywhere in `docs/`.**

Two things from that worth keeping:

**A sequencing licence is conditional on the sequence.** Design §6 permitted slice 4 to ship the `301` unconditionally, *because slice 8's flag did not exist yet*. Slice 8 merged first, so the licence expired before slice 4 was written and the redirect shipped with its exception. I rewrote the note rather than deleting it: a licence granted and then quietly dropped reads, to the next person, like an obligation somebody forgot.

**Answering a spec's open question surfaced a consequence nobody had recorded.** Interface fact 8 asked whether the step-1 UI route is pre-auth. It is — and while working out why, the real finding was that **step 1 is now a prerequisite of first-run setup rather than a successor**. Design §9 orders onboarding after password setup; since quince#530, `POST /api/auth/setup` answers `426` *before storing the password*, so a fresh install over plain HTTP cannot complete setup at all. Step 1 has to be reachable with no password in existence. That is a consequence of a PR I merged four hours earlier and had not thought through.

## And one prediction I got wrong

I wrote on quince#538 that slice 4 would meet the mirror image of the gap-bounding breakage — flipping a block changing what bounds its neighbour. It did not: `gap-heading-check` was clean first time, because the heading added in slice 6 already bounded the region. **The earlier fix pre-empted the recurrence.** Recorded because a prediction stated in canon and then never mentioned again is worse than one corrected.

# 2026-07-27 — The title lint was wired, proven on the trigger that justifies it, and then could not be merged — because the forge cannot tell two seats apart when they share a login

**The title lint was wired, proven on the trigger that justifies it, and then could not be
merged — because the forge cannot tell two seats apart when they share a login.**
[quince#115](https://github.com/novkostya/quince/pull/115) put `.github/workflows/pr-title.yml` in
place and corrected the escalation that could not deliver it, and
[quince#116](https://github.com/novkostya/quince/pull/116) (`7372d38`) appended the dated correction
to `docs/specs/devct/devct.md`'s claim that no `workflow` scope is needed *"since CI calls only
`make`"* — true of a new **gate target**, false of a new **trigger**, which is the category error the
note names so it survives `pr-title` being forgotten.
**The proof is the part worth keeping, because it lives in a CI log and logs age out.** Three runs:
`30279437397` clean on `opened`; `30279845907` **FAILURE** on a title carrying `#9999` —
*`BARE REFERENCE #9999 does not resolve` · `1 of 3`*; `30279934830` clean on the restored title. The
last two **share an identical head SHA**, and the workflow subscribes to `[opened, edited, reopened]`
with `synchronize` deliberately absent — so a second run on an unchanged tree can only have come from
**`edited`**, which is the entire reason the check is a separate file from `ci.yml`. That is the
`edited` subscription, the failure direction in production (every prior exit-1 was synthetic), the
discrimination (**1 of 3**, not a blanket fail), and recovery, in one exchange.
[quince#114](https://github.com/novkostya/quince/issues/114)'s criterion — *a check **observed
running**, not a file pushed* — was therefore **satisfied rather than waived**, which is the outcome
the criterion was written to force and not the one expected.
**Then the authority model ran out.** The workflow is the one change class that must come from the
Operator's credential, and the architect reviews as the same login: `GraphQL: Review Can not request
changes on your own pull request`. Branch protection needs one approval and **no identity can give
it**, so quince#115 sits merged-ready and unmergeable.
[quince#47](https://github.com/novkostya/quince/issues/47) has until now been a citation problem —
*which seat said this?* — and it is now **a hole in the authority model at exactly the credential
boundary**, reached on the first PR that ever needed that path. Recorded unresolved: it is the
Operator's, and improvising around it is the thing not to do.
**Two smaller records, both about copies.** The committed workflow was the **superseded draft**: the
implementer revised it in a PR *comment* and left the original in the PR *body*, so whoever copied
"the file from the thread" copied the stale one — functionally identical (`grep -v '^\s*#'` clean,
which is why the check passes), missing only the comment block explaining why `REPO='${{ … }}'` is
safe to interpolate where a title is not. **A proposal that will be copied verbatim belongs in one
place, struck through if revised.** And a claim in quince#116's body was overtaken between writing
and pushing; it was corrected **in the body** rather than only in the thread, since a merged PR's
body is the record — annotated, not replaced, which is the line between correcting and quietly
rewriting what a reviewer already read.
([quince#115](https://github.com/novkostya/quince/pull/115),
[quince#116](https://github.com/novkostya/quince/pull/116),
[quince#114](https://github.com/novkostya/quince/issues/114),
[quince#113](https://github.com/novkostya/quince/issues/113),
[quince#47](https://github.com/novkostya/quince/issues/47))

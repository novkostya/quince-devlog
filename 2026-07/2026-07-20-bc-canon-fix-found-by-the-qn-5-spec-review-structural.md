# 2026-07-20 — (bc) canon fix found by the qn.5 spec review: structural verification branches on encryption

(bc) **canon fix found by the qn.5 spec review: structural verification branches
on encryption.** Design §4's checklist ("`Manifest.db` opens read-only + record sample
resolves") is impossible passwordless on ENCRYPTED backups — the product default — because
since iOS 10.2 the manifest itself is encrypted; CI fixtures (unencrypted) would have passed
while gate 11's real encrypted tree failed. Ruled: `Manifest.plist.IsEncrypted` selects the
variant — encrypted: exists + non-trivial size + NOT-plaintext-SQLite-magic + blob-shard
sanity, with record-sampling deferred to the content level (qn.8's unlock, which now owns it
for encrypted versions); unencrypted: the full checklist. Design §4 amended; qn.5's spec
folds the branch + an encrypted fixture variant (amendment A1).

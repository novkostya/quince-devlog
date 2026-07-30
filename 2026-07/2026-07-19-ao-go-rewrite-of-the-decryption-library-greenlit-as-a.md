# 2026-07-19 — (ao) Go rewrite of the decryption library greenlit as a parallel independent project

(ao) **Go rewrite of the decryption library greenlit as a parallel
independent project** (Operator-proposed; scope verified small+frozen — reference lib
last released 2024, format stable since iOS 10.2, all primitives have mature Go
counterparts). Repo `github.com/novkostya/ios-backup-crypt` (name vetted 2026-07-19 — 0 GitHub
collisions, module path + pkg.go.dev free; public MIT; seed CLAUDE.md/README/LICENSE
authored, awaiting kickoff); includes a test-only encrypt/builder that
doubles as qn.8's synthetic-fixture generator. **Subprocess boundary kept** (Operator
ruling): quince-vault becomes a thin Go binary on the unchanged stdio RPC; key
isolation preserved. qn.8's vault implementation is now conditional — Go if the
library passes the conformance + real-backup differential gates by rung start,
Python otherwise. Zero coupling: quince contracts and schedule unaffected either way.

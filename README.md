# Snappy for macOS — Releases

Download the newest Snappy:
**https://snappy.ai/download** (redirects to
[Snappy.zip on the latest release][dl]).

[dl]: https://github.com/roboulos/snappy-releases/releases/latest/download/Snappy.zip

Each release ships the notarized
`Snappy-<version>.zip`, `Snappy.zip`,
`Snappy-<version>.zip.sha256`, and `appcast.xml`
(the signed Sparkle 2 update feed).
Source code stays in private repositories, and
`snappy-releases-gate` enforces that this public
repository tracks release workflows and
documentation only.

## Lockstep Release Pipeline

`snappy-rust` -> `snappy-swift` -> `snappy-releases`

1. **Daemon and CLI build (`roboulos/snappy-rust`):**
   Every green `main` commit cross-builds
   `aarch64-apple-darwin` (`snappy-daemon`,
   `snappy` CLI, `snappy-picture-thumbnail`)
   lock-free on `hz1`-`hz5`. `Mac mini` signs
   `SnappyDaemon.app` with Developer ID
   (`ai.snappy.macapp`), and GitHub Actions
   publishes attested release assets.
2. **App bundle, APFS layout, and Sparkle signing
   (`roboulos/snappy-swift`):**
   `snappy-release.yml` builds `Snappy.app` on
   `Mac mini` and embeds `Contents/MacOS/snappyd`
   plus `Contents/Helpers/snappy`
   (`Contents/Helpers/` avoids APFS case collisions
   with `Contents/MacOS/Snappy`). It writes
   `SnappyPairedDaemonRevision` into `Info.plist`,
   notarizes with `notarytool` and `stapler`,
   attests via GitHub OIDC (`id-token: write`),
   signs `appcast.xml` with Sparkle 2 EdDSA, and
   uploads `v<version>` with `--prerelease`.
3. **Mac check and promotion
   (`roboulos/snappy-releases`):**
   `release-gate.yml` runs on `macos-26`, checks
   Developer ID and notarization on `Snappy.app`
   and `snappyd`, and proves two planted faulty
   archives fail. It starts `snappyd` twice
   checking `/health` matches
   `SnappyPairedDaemonRevision`, checks
   `Snappy.app` opens a window, and promotes
   `v<version>` to `latest`.
   `release-check.yml` checks SHA-256 digests,
   `https://snappy.ai/download` redirects, and
   Sparkle 2 EdDSA signatures daily and on every
   PR. Across Snappy repositories, CI jobs
   authenticate to Mergify Test Engine via GitHub
   OIDC (`id-token: write`) with zero stored
   Mergify secrets.

## Product Truth and Single Substrate

`snappyd` plus `Snappy.app` is the single unified
agent, command, schedule, event-trigger, and
visibility engine on the user's machines. Users
never install duplicate per-repository runners
(`actions-runner`) alongside `snappyd` or start
hidden `nohup` background loops. Zero mystery
processes run behind `snappyd`. Every top-level
session, nested child run, command, and scheduled
or event run stays visible and controllable in
`Snappy.app` and the Floating Widget.

## Open Standards and Floating Widget Contract

- **Open protocols (zero hand-rolls, enforced by
  `handroll-review`):**
  - `MCP` (`2026-07-28` `InputRequiredResult` for
    approvals including destructive commands and
    production deploy or rollback steps,
    `SEP-2640` Skills, `SEP-2663` Tasks,
    `SEP-3415` Events, and `MCP Apps` `ui://`
    for `MCP App UI` views).
  - `ACP` (`session/new`, `session/load`,
    `session/fork` showing external CLI and Ghostty
    sessions truthfully in terminal with
    fork-to-continue in Snappy, never false
    account-closed blocks). Status enters
    `"running"` only when the first
    `session/update` arrives and stays
    `"starting"` or `"submitted"` beforehand.
  - `A2A` (`Task.contextId`,
    `referenceTaskIds`) + `OAuth 2.1`
    `SESSION_CLIENT` (`snappy:caller:<id>`) +
    `OTel GenAI` (`gen_ai.conversation.id`)
    propagating parent-child lineage automatically
    so child runs nest under their parent
    conversation in `Families::build` and
    background runs stay in `Agents` rather than
    `Today`.
  - `OAuth 2.1` / `RFC 9700` refresh-token
    rotation checking and refreshing expired
    tokens atomically before `me` reports `ready`
    and before `POST /acp/sessions` admits a
    start.
  - `CloudEvents 1.0` + `cron` for time- and
    event-driven triggers running prompts or
    commands.
- **Floating Widget UX contract:**
  `WidgetIsland` sits on top with inline chat
  above input and `Follow-up` vs `New chat`,
  Harness + Model, and Quick Skills. Never add
  `"Open Snappy"` filler or a duplicate top title
  pill. Live top-level session cards
  (`WidgetCards`) and fleet count
  (`WidgetFleetPill`) sit below the composer, and
  the bell badge counts all unseen or attention
  top-level sessions.

## Lock-Free Fleet and CI Rules (27 Nov 2026)

- Zero `/run/lock/snappy-heavy` or `flock` on
  `hz1`-`hz5`, zero cross-folder `lockf` on
  `Mac mini`, and zero `cargo` or `swift build`
  on `MacBook Pro`
  (`~/.claude/bin/snappy-preview-iter.sh` +
  `mac_look` runs the `<35s` UI loop).
- Use standard industry terms (`CI checks`,
  `merge and deploy`, `deployed version`,
  `server`, `runner service`, `agent session` or
  `branch`, `MCP App UI`, `read-only API call`,
  `build environment`).
- `snappy-releases-gate` fails a pull request when
  its title, body, or a commit holds a GitHub
  closing keyword (`Closes #N`, `Fixes #N`, or
  `Resolves #N`). The Mergify rule
  `the pull request names its issue with Refs only`
  checks the live title and body again before
  merge.
- Every Markdown file passes `ste-lint.py`
  (`ASD-STE100`: zero semicolons, sentences of
  25 words or fewer) and `jscpd --threshold 0`.
  Use neutral synthetic names (`Ada`, `Ben`,
  `example.test`), write `Refs #N` only (never
  `Closes`, `Fixes`, or `Resolves`), and add
  `--label now` on ready PRs.

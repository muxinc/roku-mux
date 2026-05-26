# Releasing roku-mux

This guide describes the current maintainer release process for `roku-mux`, the
Mux Data SDK for Roku.

## How To Use This Guide

- Humans can use the manual checklist for a concise overview of the release
  flow.
- AI agents must follow the agent-assisted runbook. Use the manual checklist as
  summary context, not as the execution procedure.

## How Distribution Works

Two version values must stay in sync, and they control different things:

- `src/mux-analytics.brs` (`m.MUX_SDK_VERSION`) controls the version the SDK
  reports to Mux Data.
- `package.json` (`version`) controls the path the SDK is deployed to on
  `src.litix.io`.

There is no package manager. Publishing is triggered by creating the GitHub
release off `master`:

1. Creating the release creates the `vX.Y.Z` tag.
2. The new tag kicks off a Buildkite pipeline that runs `npm run deploy`
   (`scripts/deploy.js`).
3. `deploy.js` uploads `src/mux-analytics.brs` to S3 (served from
   `src.litix.io`) under the scope `roku`, at both the full-version path and the
   major-version path, then invalidates CloudFront. The deployed files are
   served at:
   - `https://src.litix.io/roku/X.Y.Z/mux-analytics.brs`
   - `https://src.litix.io/roku/<major>/mux-analytics.brs` (e.g. `roku/2/...`)

This means the GitHub release is the publish action, not just release notes.
Nothing reaches production until the release/tag is created.

## Manual Release Checklist

1. Confirm the target version and verify the intended changes are merged to
   `master`.
2. Create `releases/vX.Y.Z` from `origin/master`, bump the version in both
   `package.json` and `src/mux-analytics.brs` to the same value, and open a
   release PR.
3. After the release PR is approved, squash-merge it, then fetch `master` and
   confirm the merged commit has the new version values.
4. Verify the `vX.Y.Z` tag does not already exist, then create the GitHub
   release off `master` with maintainer-approved release notes. This creates the
   tag and triggers the Buildkite deploy to `src.litix.io`.
5. Confirm the Buildkite deploy succeeded and the new version is live on
   `src.litix.io`.
6. Update mux.com documentation in a separate PR: update the Roku release notes
   page, and update feature docs when the release changes customer-facing
   behavior, setup, or API usage.

## Agent-Assisted Release Runbook

Follow this section when using an AI agent to prepare or publish a new SDK
version.

### Agent Rules

- Ask for the target version before changing files. Do not infer patch, minor,
  or major unless the maintainer explicitly asks you to.
- Release branches use the `releases/vX.Y.Z` format. Do not use personal or
  agent prefixes for release branches.
- The two version values must match exactly. Never bump one file without the
  other.
- Keep release PRs small. A release PR should only update `package.json` and
  `src/mux-analytics.brs`.
- The GitHub release is the publish trigger. Do not create the release until the
  version-bump PR is merged to `master`, and never pre-create the tag by hand.
- Let maintainers collaborate on release notes. Draft notes are useful, but do
  not treat generated notes as final if a human edits them. Release notes must
  be understandable by customers who do not know internal project names, ticket
  IDs, or TDD references.
- For follow-up branches outside this repo, such as mux.com documentation
  updates, use the maintainer's normal initials-style prefix (e.g.
  `<initials>/...`). Ask for it if it is not already clear. Do not invent
  agent-specific prefixes for team-visible branches.
- If validation, merge, release, deploy, or docs steps fail, stop and report the
  failure, the command that failed, and the safest next step. Do not silently
  continue past a failed release step.
- When asked to continue an interrupted release, inspect the current branch, PR,
  tag, GitHub release, Buildkite deploy, and docs state first. Resume from the
  first incomplete step instead of starting over.

### Prepare The Release PR

1. Confirm the target version with the maintainer.
   - Example: `2.7.0`
   - The tag will be `v2.7.0`.

2. Verify the intended feature changes are already merged to `master`.
   - Check the relevant feature PRs.
   - Fetch the latest master and tags:
     ```sh
     git fetch origin master --tags
     ```
   - Confirm `origin/master` contains the intended release contents.

3. Check the current version state.
   ```sh
   git tag --list 'v*' --sort=-version:refname
   ```
   Confirm `package.json` and `src/mux-analytics.brs` still match the latest
   release before bumping them.

4. Create a release branch from `origin/master`.
   ```sh
   git switch -c releases/vX.Y.Z origin/master
   ```
   If using a worktree, prefer a repo-local path:
   ```sh
   git worktree add <repo-local-worktrees>/release-X.Y.Z -b releases/vX.Y.Z origin/master
   ```

5. Bump the version in both files to the same value.
   - `package.json`: the `"version"` field.
   - `src/mux-analytics.brs`: the `m.MUX_SDK_VERSION` string near the top of the
     file.

6. Confirm both values match.
   ```sh
   grep '"version"' package.json
   grep 'm.MUX_SDK_VERSION =' src/mux-analytics.brs
   ```

7. Commit the version bump.
   ```sh
   git add package.json src/mux-analytics.brs
   git commit -m "version bump"
   ```

8. Push the release branch.
   ```sh
   git push -u origin releases/vX.Y.Z
   ```

9. Open a release PR.
   - Base: `master`
   - Head: `releases/vX.Y.Z`
   - Title: `Release vX.Y.Z`
   - Body:
     ```md
     ## Summary
     - bump SDK version from A.B.C to X.Y.Z in package.json and mux-analytics.brs
     ```

10. Stop until the PR is approved.

### Publish The Release

Continue only after the release PR is approved.

1. Squash-merge the release PR. roku-mux uses squash merges; `master` history
   shows the `(#NNN)` pattern.
   ```sh
   gh pr merge <PR_NUMBER> --repo muxinc/roku-mux --squash
   ```

2. Fetch the merged master branch and tags.
   ```sh
   git fetch origin master --tags
   ```

3. Verify `origin/master` contains the new version values in both
   `package.json` and `src/mux-analytics.brs`.

4. Confirm the tag does not already exist.
   ```sh
   git tag --list vX.Y.Z
   ```
   If this returns a tag, stop and ask the maintainer how to proceed.

5. Gather commits for release notes.
   ```sh
   git log --oneline <prev_tag>...origin/master
   ```
   Exclude the `version bump` commit itself.

6. Prepare final release notes.
   - Draft customer-facing notes from the merged feature PRs.
   - Focus on what changed from the user's perspective; avoid internal ticket
     IDs and TDD references.
   - Share the notes with the maintainer for review.
   - If the maintainer edits the notes, use the maintainer-edited version as
     final.

7. Create the GitHub release. This creates the `vX.Y.Z` tag off `master` and
   triggers the Buildkite deploy.
   ```sh
   gh release create vX.Y.Z \
     --repo muxinc/roku-mux \
     --target master \
     --title "vX.Y.Z" \
     --notes "<release notes>"
   ```

8. Verify the release.
   ```sh
   gh release view vX.Y.Z --repo muxinc/roku-mux \
     --json tagName,name,url,targetCommitish,publishedAt,isDraft,isPrerelease
   ```
   Confirm the release is published, not a draft, and not marked as a prerelease
   unless that was intentional. Also confirm the tag points at `origin/master`:
   ```sh
   git rev-list -n 1 vX.Y.Z
   git rev-parse origin/master
   ```
   These commit SHAs must match.

9. Confirm the deploy.
   - The new tag triggers a Buildkite pipeline that runs `npm run deploy`
     (`scripts/deploy.js`).
   - The deploy is asynchronous, so allow a short delay if it has not landed
     yet. Verify the deployed file reports the new version at both paths:
     ```sh
     curl -s https://src.litix.io/roku/X.Y.Z/mux-analytics.brs | grep 'MUX_SDK_VERSION ='
     curl -s https://src.litix.io/roku/<major>/mux-analytics.brs | grep 'MUX_SDK_VERSION ='
     ```
     Both should print the new `X.Y.Z`.

### Update Mux Docs

After the SDK release is published, update mux.com documentation in a separate
PR.

1. Read the final GitHub release notes.
   ```sh
   gh release view vX.Y.Z --repo muxinc/roku-mux --json body,url,name,tagName
   ```

2. Work in the `muxinc/mux.com` repo, which uses the `main` branch (not
   `master`). Use your local checkout of that repo, and create the docs branch
   from the latest `origin/main`.

3. Update the Roku release notes page:
   `apps/web/app/docs/_guides/developer/monitor-roku.mdx`
   - Find the `### Current release` section. It looks like this, where the most
     recent release sits under `### Current release` and older ones are listed
     under `### Previous releases`:
     ```md
     ### Current release

     #### vPREV.VERSION
     - previous release notes here

     ### Previous releases

     #### vOLDER.VERSION
     - older release notes here
     ```
   - Move the existing current release down to the top of `### Previous
     releases`, and add the new version under `### Current release`:
     ```md
     ### Current release

     #### vNEW.VERSION
     - new release notes here

     ### Previous releases

     #### vPREV.VERSION
     - previous release notes here

     #### vOLDER.VERSION
     - older release notes here
     ```
   - Use the final GitHub release notes as the source. Match the existing
     entries' formatting (heading level and bullet style).

4. Decide whether feature docs need updates.
   - Update feature docs when the release changes customer-facing behavior,
     setup, or API usage.
   - Do not add a new how-to section when behavior is automatic and there is no
     new customer-facing API. A short sentence may be enough.

5. Use a team branch prefix for mux.com docs branches.
   - Use the maintainer's normal initials-style prefix, e.g.
     `<maintainer-initials>/roku-X.Y.Z-docs`.
   - Ask the maintainer for their prefix if unsure.
   - Avoid agent-specific prefixes.

6. Validate the docs diff.
   ```sh
   git diff --check
   ```

7. Commit the docs update.
   ```sh
   git commit -m "roku X.Y.Z release notes"
   ```

8. Open a mux.com PR titled `roku X.Y.Z release notes` targeting `main` and wait
   for review.

## Common Pitfalls

- Do not bump one version file without the other. `package.json` and
  `src/mux-analytics.brs` must always match.
- Do not create the GitHub release or tag before the version-bump PR is merged
  to `master`. The release/tag is what triggers the production deploy.
- Do not pre-create the `vX.Y.Z` tag by hand. Let `gh release create
  --target master` create it.
- Do not skip asking for the target version. A feature release may still be a
  patch release.
- Do not publish generated release notes if a maintainer edited the final notes.
- Do not assume the deploy is done when the release is created. Confirm the
  Buildkite pipeline succeeded and the new version is live on `src.litix.io`
  using the `curl` checks above.
- Do not create team-visible branches (release or mux.com docs) with
  agent-specific prefixes.

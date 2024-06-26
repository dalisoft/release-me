---
sidebar_position: 5
---

# Configuration

## Environment variables

| Name           | Description                         | Type    | Depended plugin           |
| -------------- | ----------------------------------- | ------- | ------------------------- |
| `GITHUB_TOKEN` | Used to publish **Github** releases | Secrets | **GitHub Release** plugin |
| `NPM_TOKEN`    | Used to publish to **npm** registry | Secrets | **npm** plugin            |

## Git variables

> These variable names used for creating tag(s)

| Name           | Description               | Type      | Depended plugin         |
| -------------- | ------------------------- | --------- | ----------------------- |
| `GIT_USERNAME` | Specify tag author name   | Variables | **git,npm-post** plugin |
| `GIT_EMAIL`    | Specify tag author e-mail | Variables | **git,npm-post** plugin |

## GPG (Git) variables

> These variable names used for signing tag(s)

| Name             | Description            | Type      | Depended plugin         |
| ---------------- | ---------------------- | --------- | ----------------------- |
| `GPG_NO_SIGN`    | Skips Git Signing      | Variables | **git,npm-post** plugin |
| `GPG_KEY_ID`     | Public GPG key/ring ID | Variables | **git,npm-post** plugin |
| `GPG_KEY`        | Private GPG key        | Secrets   | **git,npm-post** plugin |
| `GPG_PASSPHRASE` | Private GPG passphrase | Secrets   | **git,npm-post** plugin |

## SSH (Git) variables

> These variable names used for signing tag(s)

| Name                 | Description             | Type      | Depended plugin         |
| -------------------- | ----------------------- | --------- | ----------------------- |
| `SSH_NO_SIGN`        | Skips Git Signing       | Variables | **git,npm-post** plugin |
| `SSH_PUBLIC_KEY`     | Public SSH key content  | Secrets   | **git,npm-post** plugin |
| `SSH_PRIVATE_KEY`    | Private SSH key content | Secrets   | **git,npm-post** plugin |
| `SSH_KEY_PASSPHRASE` | Private SSH passphrase  | Secrets   | **git,npm-post** plugin |

## GH Actions Configurations

See this project [workflow](../.github/workflows/lint_test.yml) or see below

> On **homepage** below content may show not properly, so, please check **workflow** file linked above

```yaml title=".github/workflows/release.yml"
name: Release
on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

env:
  CI: true

jobs:
  release:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # <-- This line is REQUIRED
          token: ${{ secrets.GITHUB_TOKEN }} # <-- This line is REQUIRED too
      - name: Release
        env:
          GIT_USERNAME: ${{ vars.GIT_USERNAME }}
          GIT_EMAIL: ${{ vars.GIT_EMAIL }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # <-- This line is REQUIRED too
          GPG_KEY_ID: ${{ vars.GPG_KEY_ID }}
          GPG_KEY: ${{ secrets.GPG_KEY }}
          GPG_PASSPHRASE: ${{ secrets.GPG_PASSPHRASE }}
        shell: bash
        run: |
          git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me
          bash .release-me/release.sh --plugins=git,github-release
```

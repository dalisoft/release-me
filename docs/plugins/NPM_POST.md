---
sidebar_position: 4
---

# `npm`-post

Commits updated `package.json` version field

This plugin is not essential but recommended to keep `version` field in sync

## Required: **No**

## Environment variables

### Git variables

> These variable names used for creating tag(s) and commit(s)

| Name           | Description               | Type      |
| -------------- | ------------------------- | --------- |
| `GIT_USERNAME` | Specify tag author name   | Variables |
| `GIT_EMAIL`    | Specify tag author e-mail | Variables |

### GPG (Git) variables

> These variable names used for signing tag(s) and commit(s)

| Name             | Description            | Type      |
| ---------------- | ---------------------- | --------- |
| `GPG_NO_SIGN`    | Skips Git Signing      | Variables |
| `GPG_KEY_ID`     | Public GPG key/ring ID | Variables |
| `GPG_KEY`        | Private GPG key        | Secrets   |
| `GPG_PASSPHRASE` | Private GPG passphrase | Secrets   |

### SSH (Git) variables

> These variable names used for signing tag(s) and commit(s)

| Name                 | Description             | Type      |
| -------------------- | ----------------------- | --------- |
| `SSH_NO_SIGN`        | Skips Git Signing       | Variables |
| `SSH_PUBLIC_KEY`     | Public SSH key content  | Secrets   |
| `SSH_PRIVATE_KEY`    | Private SSH key content | Secrets   |
| `SSH_KEY_PASSPHRASE` | Private SSH passphrase  | Secrets   |

### npm variables

> These variable names used for publishing to **npm** registry via the `npm` plugin

| Name        | Description                                   | Type    |
| ----------- | --------------------------------------------- | ------- |
| `NPM_TOKEN` | Optional. Used to publish to **npm** registry | Secrets |

When `NPM_TOKEN` is not set, publishing falls back to **Trusted publishing (OIDC)** — supported on GitHub Actions with `id-token: write` permission and npm >= 11.5.1, no token required. The `npm-post` plugin itself runs whenever it is listed in `--plugins`, with or without a token.

The version bump lands on the base branch as a direct, signed push (rebased and autostashed). Run the release CI with a token whose actor is allowed to push the base branch — e.g. a dedicated GitHub App in the branch ruleset bypass list — and keep the `[skip ci]` trailer so the bump push does not re-trigger the release.

## Usage

```bash title="Bash (Terminal)"
git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me
bash .release-me/release.sh --plugins=npm,npm-post,git
```

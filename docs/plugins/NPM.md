---
sidebar_position: 3
---

# `npm`

Updates version field and Publishes **npm** tag

## Required: **No**

## Environment variables

| Name        | Description                                   | Type    |
| ----------- | --------------------------------------------- | ------- |
| `NPM_TOKEN` | Optional. Used to publish to **npm** registry | Secrets |

When `NPM_TOKEN` is not set, the plugin publishes via **Trusted publishing (OIDC)** — supported on GitHub Actions with `id-token: write` permission and npm >= 11.5.1, no token required.

## Usage

```bash title="Bash (Terminal)"
git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me
bash .release-me/release.sh --plugins=npm,git
```

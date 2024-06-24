---
sidebar_position: 4
---

# Workspace

:::tip

First check out [`workspace`](../USAGE.md#workspace) option for how it works

:::

This project allows you publish workspace packages easier but automatized **Git tagging**, **npm publish**, **GitHub release** and/or **Generate changelog** for each package without headaches

You can check [`workspace`](../USAGE.md#workspace) example from [here](https://github.com/dalisoft/airlight/releases)

## Step-by-step guide

:::info

You should follow and read these pages before read this page

- [Installation](../INSTALLATION.md)
- [Usage](../USAGE.md)
- [pnpm Workspace](https://pnpm.io/pnpm-workspace_yaml)

:::

### Add `release` script

```json title="package.json"
{
  "release": "pnpm -r --workspace-concurrency=1 exec ../../.release-me/release.sh -w --use-version --plugins=npm,npm-post,git,github-release --preset=workspace"
}
```

Modyify plugins as you wish and for your project needs

### Add or set `env`

Add required [`Environment variables`](../CONFIGURATION.md#environment-variables) to file `.env` or set into your environment

Another option could be set your [`Environment variables`](../CONFIGURATION.md#environment-variables) on **CI** and run on **CI** for testing purposes. See [`example`](../CONFIGURATION.md#gh-actions-configurations)

### Run `release` script

```bash title="Bash (Terminal)"
pnpm run release
# or
env $(cat .env) pnpm run release
```

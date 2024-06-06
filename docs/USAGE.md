---
sidebar_position: 3
---

# Usage

This project can be used as you wish, local, remote, on CI and/or at VPS. Everywhere it works on same logic as you provide same credentials

## Requirements

> See [Getting Started](./GET_STARTED.md) page if you didn't read
> See [Environment variables](./CONFIGURATION.md#environment-variables)

- **bash** version **v5+** for best reliability
- Make sure you have **write** access
- Make sure you have **ACCESS TOKEN** with **write access**

## Preparation

- Add `.release-me` to `.gitignore`
- Add your `.gitignore` to commit
- Push into remote

## Commands

```bash
git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me
bash .release-me/release.sh --plugins=git,github-release --preset=conventional-commits
```

## Options

| Name          | Description                                                | Default                | Required |
| ------------- | ---------------------------------------------------------- | ---------------------- | -------- |
| `dry-run`     | Show only actions on logs                                  | `false`                | No       |
| `verbose`     | Verbose logs                                               | `true` on CI           | No       |
| `quiet`       | Quiet logs                                                 | `false`                | No       |
| `workspace`   | Releases every projects on workspace                       | `false`                | No       |
| `stable`      | If project current version is `0.x`, it will bump to `1.x` | `false`                | No       |
| `pre-release` | Publish this project as non-production ready               | `false`                | No       |
| `preset`      | Presets compatibility, see [Presets](./PRESETS.md)         | `conventional-commits` | No       |
| `plugins`     | Plugins compatibility, see [Plugins](./PLUGINS.md)         | `git`                  | No       |

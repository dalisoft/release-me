---
sidebar_position: 3
---

# Usage

This project can be used as you wish, local, remote, on CI and/or at VPS. Everywhere it works on same logic as you provide same credentials

## Requirements

> See [Getting Started](./GET_STARTED.md) page if you didn't read
> See [Configuration](./CONFIGURATION.md)
> See [Plugins](./category/plugins)

- **bash** version **v5+** for best reliability
- Make sure you have **write** access
- Make sure you have **ACCESS TOKEN** with **write access**

## Preparation

- Add `.release-me` to `.gitignore`
- Add your `.gitignore` to commit
- Push into remote

## Commands

```bash title="Bash (Terminal)"
git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me
bash .release-me/release.sh --plugins=git,github-release --preset=conventional-commits
```

## Options

### Quick summary

| Name          | Description                                                                | Default                | Required |
| ------------- | -------------------------------------------------------------------------- | ---------------------- | -------- |
| `dry-run`     | Show only actions on logs                                                  | `false`                | No       |
| `verbose`     | Verbose logs                                                               | `true` on CI           | No       |
| `quiet`       | Quiet logs                                                                 | `false`                | No       |
| `workspace`   | Releases every projects on workspace                                       | `false`                | No       |
| `use-version` | Use project version from manifest. Requires workspace and a valid manifest | `false`                | No       |
| `stable`      | If project current version is `0.x`, it will bump to `1.x`                 | `false`                | No       |
| `pre-release` | Publish this project as non-production ready                               | `false`                | No       |
| `preset`      | Presets compatibility, see [Presets](./PRESETS.md)                         | `conventional-commits` | No       |
| `plugins`     | Plugins compatibility, see [Plugins](./category/plugins)                   | `git`                  | No       |

### `dry-run`

- Shorthand: `-d`
- Default: `-`
- Type: `boolean`
- Requires: `No`
- Values: only key
- Example: `release-me --dry-run` or `release-me -d`
- Used by: **all** plugins and preset

When option is set, all plugins (made by author plugins only) works as a see what happens before acting. Does not take actions, just shows what actions could be done when removing this flag. You can combine this method with [`verbose`](#verbose) or [`quiet`](#quiet) mode to get desired results

### `verbose`

:::warning

On CI it's always set under the hood for debugging purposes

:::

- Default: `-`
- Type: `boolean`
- Requires: `No`
- Values: only key
- Example: `release-me --verbose`
- Used by: **all** plugins and preset

When option is set, you get more logs and information about the process and what actions are currently processing or will be on [`dry-run`](#dry-run) mode

### `quiet`

- Shorthand: `-q`
- Default: `-`
- Type: `boolean`
- Requires: `No`
- Values: only key
- Example: `release-me --quiet` or `release-me -q`
- Used by: **all** plugins and preset

When option is set, you get less logs and information about the process and what actions are currently processing or will be on [`dry-run`](#dry-run) mode

### `workspace`

:::tip

This option works best with [pnpm](https://pnpm.io) package manager

:::

- Shorthand: `-w`
- Default: `-`
- Type: `boolean`
- Requires: `Yes` on workspace projects
- Values: only key
- Example: `release-me --workspace` or `release-me -w`
- Used by: **workspace** preset

This mode allows you release entire workspace projects without hassle or headache with same speed and easy-of-use you love.

### `use-version`

:::warning

This method will work when using with [`workspace`](#workspace) option used to avoid confusion as in monorepo/workspaces can be either many git tags or no tags

:::

- Default: `-`
- Type: `boolean`
- Requires: `No`
- Values: only key
- Example: `release-me --use-version`
- Used by: **workspace** preset

This option makes your last version fetch from manifest (like `package.json`) instead of **Git tags**.

Useful for such cases whereas many git tags or no tags

### `stable`

:::tip

This is useful for early stage projects, Cargo projects, Bash libraries or projects

:::

- Default: `-`
- Type: `boolean`
- Requires: `No`
- Values: only key
- Example: `release-me --stable`
- Used by: **github-release** plugins

This option helps you switch from alpha release to stable release easier than ever or allows you use stable version at start.

:::info

This option runs this project same behavior as [semantic-release](https://semantic-release.gitbook.io/semantic-release) works, so you can use option as drop-in replacement for [semantic-release](https://semantic-release.gitbook.io/semantic-release)

:::

### `pre-release`

:::tip

This is useful for early stage projects, Cargo projects, Bash libraries or projects like [`stable`](#stable) option but does opposite action

:::

- Default: `-`
- Type: `boolean`
- Requires: `No`
- Values: only key
- Example: `release-me --pre-release`
- Used by: **github-release** plugins

This option helps you keep your project as alpha release easier than ever or allows you use pre-release versions.

### `preset`

- Default: `conventional-commits`
- Type: `string`
- Requires: `Yes`
- Values: one of [Presets](/docs/PRESETS.md)
- Example: `release-me --preset=workspace`
- Used by: **Core** features

### `plugins`

- Default: `git`
- Type: `string`
- Requires: `Yes`
- Values: String of Array of [Plugins](./category/plugins)
- Example: `release-me --plugins=npm-post,npm,git,github-release`
- Used by: **Core** features

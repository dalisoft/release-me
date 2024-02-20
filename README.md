# release-me

Blazing fast minimal [semantic-release](https://github.com/semantic-release/semantic-release) alternative written-in **Bash** script with it's **GitHub** and **npm** plugins and presets support

## Features

- Available on all **Unix** environments
- Zero third-party dependencies
- No pre-install, just use
- Blazing fast, no wait
- Workspace support out-of-box
- Much stable than **semantic-release** as does not loses commits
- Programming language agnostic\*
- Fast (<5 sec with all plugins execution)
- Plugins available/compatible
- Presets available/compatible

## Limitations

- Currently supports only **Node.js**, **Rust** and **Python** projects
- Version should be valid, see [Semantic Versioning](https://semver.org)

## Versioning priority

If one of files described below will be found, script parse first matched file and priority will ran as these

1. **Node.js** (`package.json`)
2. **Rust** (`Cargo.toml`)
3. **Python** (`setup.py`)

## Installation

### Requirements

> See [Environment variables](#environment-variables)

- **bash** version **v5+** for best reliability
- Make sure you have **write** access
- Make sure you have **ACCESS TOKEN** with **write access**

### Preparation

- Add `.release-me` to `.gitignore`
- Add your `.gitignore` to commit
- Push into remote

### Commands

```bash
git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me
```

## Usage

> See [Environment variables](#environment-variables)

```sh
bash --debug .release-me/release.sh --plugins=git,github-release --preset=conventional-commits
```

## Plugins

| Name             | Description                                      | Status |
| ---------------- | ------------------------------------------------ | ------ |
| `git`            | Creates **Git** tag and push to origin           | Stable |
| `github-release` | Release a tag with proper `CHANGELOG` and commit | Stable |
| `npm`            | Publishes **npm** tag                            | Stable |
| `npm_package`    | Updates `package.json` version                   | RC     |
| `changelog`      | Generates `CHANGELOG` within your project        | Alpha  |

## Presets

| Name                   | Description                              |
| ---------------------- | ---------------------------------------- |
| `conventional-commits` | Default preset like **semantic-release** |
| `library`              | Same as `conventional-commits` for now   |
| `workspace`            | Workspace preset for monorepos           |

## Options

| Name        | Description                                                | Required |
| ----------- | ---------------------------------------------------------- | -------- |
| `dry-run`   | Show only actions on logs                                  | No       |
| `verbose`   | Verbose logs                                               | No       |
| `quiet`     | Quiet logs                                                 | No       |
| `workspace` | Releases every projects on workspace                       | No       |
| `stable`    | If project current version is `0.x`, it will bump to `1.x` | Yes      |
| `presets`   | Presets compatibility, see [Presets](#presets)             | Yes      |
| `plugins`   | Plugins compatibility, see [Plugins](#plugins)             | Yes      |

## Environment variables

| Name        | Description                         |
| ----------- | ----------------------------------- |
| `GH_TOKEN`  | Used to publish **Github** releases |
| `NPM_TOKEN` | Used to publish to **npm** registry |

## Comparison

| Features      | release-me | semantic-release | go-semantic-release |
| ------------- | ---------- | ---------------- | ------------------- |
| Performance   | Fast       | Slow             | Fast                |
| Startup delay | -          | Slow             | Fast                |
| Platform      | Unix-only  | ALL              | ALL                 |
| Dependencies  | -          | +                | ?                   |
| Configuration | -          | +                | +                   |
| Presets       | +          | +                | -                   |
| Plugins       | +          | +                | +                   |
| Workspaces    | Built-in   | ?                | -                   |

## Benchmark

> Please test yourself on your machine. These results on my machine **MacBook Pro 13" M1 16/512**

| Name                | `time`  | Command                                                        |
| ------------------- | ------- | -------------------------------------------------------------- |
| semantic-release    | `7.93s` | `bunx semantic-release --dry-run`                              |
| go-semantic-release | `2s`    | `./semantic-release --hooks goreleaser`                        |
| release-me          | `2s`    | `bash ./release.sh --plugins=git,github-release,npm --dry-run` |

## Relative projects

- [semantic-release](https://semantic-release.gitbook.io)
- [go-semantic-release](https://github.com/go-semantic-release/semantic-release)

## License

GPL-3 or later

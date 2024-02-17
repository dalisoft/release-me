# release-me

Blazing fast minimal [semantic-release](https://github.com/semantic-release/semantic-release) alternative written-in **Bash** script with it's **GitHub** and **npm** plugins and presets support

## Features

- Available on all **Unix** environments
- Zero third-party dependencies
- Blazing fast, no wait
- Programming language agnostic\*
- Fast (<1 sec without GitHub plugin)
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

## Usage

```sh
GH_TOKEN=<YOUR_GITHUB_TOKEN> NPM_TOKEN=<YOUR_NPM_TOKEN> sh /path/to/script/release.sh --preset=conventional-commits
```

## Plugins

| Name        | Description                                      | Status |
| ----------- | ------------------------------------------------ | ------ |
| `git`       | Creates **Git** tag and push to origin           | RC     |
| `github`    | Release a tag with proper `CHANGELOG` and commit | RC     |
| `npm`       | Publishes **npm** tag                            | RC     |
| `changelog` | Generates `CHANGELOG` within your project        | Alpha  |

## Presets

| Name                   | Description                              | Status |
| ---------------------- | ---------------------------------------- | ------ |
| `conventional-commits` | Default preset like **semantic-release** | RC     |
| `library`              | Same as `conventional-commits` for now   | RC     |
| `workspace`            | Workspace preset for monorepos           | Alpha  |

## Options

| Name         | Description                                    | Status | Required |
| ------------ | ---------------------------------------------- | ------ | -------- |
| `dry-run`    | Show only actions on logs                      | RC     | No       |
| `verbose`    | Verbose logs                                   | RC     | No       |
| `presets`    | Presets compatibility, see [Presets](#presets) | RC     | Yes      |
| `plugins`    | Plugins compatibility, see [Plugins](#plugins) | RC     | Yes      |
| `workspaces` | Releases every projects on workspace           | Alpha  | No       |

## Environment variables

| Name        | Description                         |
| ----------- | ----------------------------------- |
| `GH_TOKEN`  | Used to publish **Github** releases |
| `NPM_TOKEN` | Used to publish to **npm** registry |

## License

GPL-3 or later

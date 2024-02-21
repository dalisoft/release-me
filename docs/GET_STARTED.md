# release-me \[0.x\]

> Except bugs, errors and/or strange behavior

Blazing fast minimal [semantic-release](https://github.com/semantic-release/semantic-release) alternative written-in **Bash** script with it's **GitHub** and **npm** plugins and presets support

List of contents:

- **Getting Started**
- [Installation](./INSTALLATION.md)
- [Usage](./USAGE.md)
- [Configuration](./CONFIGURATION.md)
- [Presets](./PRESETS.md)
- [Plugins](./PLUGINS.md)
- [Benchmark](./BENCHMARK.md)

## Getting Started

Welcome to release-me! This tool is designed to streamline your software release process, making it easier to manage versions, changelogs, and deployment. Whether you're working on a small project or a large enterprise application, release-me is here to simplify your workflow.

### Prerequisites

Before you start using release-me, make sure you have the following installed on your system:

- `git` (version 2.30 or later)
- `bash` (version 5.x or later) with `curl`, `sed` dependencies
- `npm` (version 9.x or later), required for `npm` package

### Features

- Available on all **Unix** environments
- Zero third-party dependencies
- No pre-install, just use
- Blazing fast, no wait
- Workspace support out-of-box
- Much stable/reliable than **semantic-release** as does not loses commits\*
- Programming language agnostic\*
- Fast (<5 sec with all plugins execution)
- Plugins available/compatible
- Presets available/compatible

> \* - It's still in `0.x` phase but still handles much better and faster

### Limitations

- Currently supports only **Node.js**, **Rust** and **Python** projects
- Version should be valid, see [Semantic Versioning](https://semver.org)

### Versioning priority

If one of files described below will be found, script parse first matched file and priority will ran as these

1. **Node.js** (`package.json`)
2. **Rust** (`Cargo.toml`)
3. **Python** (`setup.py`)

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

## Similar projects

- [semantic-release](https://semantic-release.gitbook.io)
- [go-semantic-release](https://github.com/go-semantic-release/semantic-release)
# release-me \[0.x\]

> Except bugs, errors and/or strange behavior

[![Coverage Status](https://coveralls.io/repos/github/dalisoft/release-me/badge.svg?branch=master)](https://coveralls.io/github/dalisoft/release-me?branch=master)

Blazing fast minimal release workflow script written in **Bash** with plugins and presets support

List of contents:

- [Github repository](https://github.com/dalisoft/release-me)
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
- Programming language agnostic
- Fast (<5 sec with all plugins execution)
- Plugins available/compatible
- Presets available/compatible

### Limitations

- Currently supports only **Node.js**, **Rust** and **Python** projects (library only)
- Rebased commits tracking are lost so duplicate releases possible
- Available only in **Unix** environments (no Windows support yet)

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
| `0.x` support | Built-in   | -                | ?                   |
| `semver`      | +          | +                | +                   |

## Similar projects

- [semantic-release](https://semantic-release.gitbook.io)
- [go-semantic-release](https://github.com/go-semantic-release/semantic-release)
- [changesets](https://github.com/changesets/changesets)
- [release-please](https://github.com/googleapis/release-please)

## Inspirations

- [semantic-release-bash](https://gitlab.com/mccleanp/semantic-release-bash)
- [semantic-release.sh](https://github.com/itninja-hue/semantic-release.sh)
- [conventional-commit-version-parser](https://github.com/djaustin/conventional-commit-parser)

## Credits to

- [Bash](https://www.gnu.org/software/bash)
- [ShellCheck](https://github.com/koalaman/shellcheck)
- [Bashcov](https://github.com/infertux/bashcov)
- [bash_unit](https://github.com/pgrange/bash_unit)

## License

GPL-3

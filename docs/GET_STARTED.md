---
sidebar_position: 1
---

# Getting Started

Welcome to release-me! This tool is designed to streamline your software release process, making it easier to manage versions, changelogs, and deployment. Whether you're working on a small project or a large enterprise application, release-me is here to simplify your workflow.

## Quick Start

:::info

You do not need compile, install dependencies or other actions

:::

It is easy to get-started in two steps if we do basic steps:

1. Clone repo with within folder into your project, see [Installation](./INSTALLATION.md) for other methods
2. Run `.release-me/release.sh` to run with default options, see [Usage](./USAGE.md) for more info about options

## Prerequisites

Before you start using release-me, make sure you have the following installed on your system:

- `git` (version 2.30 or later)
- `bash` (version 5.x or later) with `curl`, `sed` dependencies
- `npm` (version 9.x or later), required for `npm` package

## Features

- Available on all **Unix** environments
- Zero third-party dependencies
- No pre-install, just use
- Fast and no wait
- [Workspace](./features/WORKSPACE.md) support out-of-box
- Programming language agnostic
- [Fast](./BENCHMARK.md) (<5 sec with all plugins execution)
- [Plugins](./category/plugins) available/compatible
- [Presets](./PRESETS.md) available/compatible
- Free and permissive license

## Limitations

- Currently supports only **Node.js**, **Rust** and **Python** projects (library only)
- Rebased commits tracking are lost so duplicate releases possible
- Available only in **Unix** environments (no Windows support yet)

## Versioning priority

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
- [publish.sh](https://gist.github.com/shuckster/246e3d5f98d51d20cdf00ade25029d04)

## Credits to

> for making project safer with testing, coverage and linting entire project

- [Bash](https://www.gnu.org/software/bash)
- [ShellCheck](https://github.com/koalaman/shellcheck)
- [Bashcov](https://github.com/infertux/bashcov)
- [bash_unit](https://github.com/pgrange/bash_unit)

as well as

> for keeping project safe, catching early bugs and more useful tasks on local development

- [typos](https://github.com/crate-ci/typos)
- [lefthook](https://github.com/evilmartians/lefthook)
- [biome](https://github.com/biomejs/biome)
- [dprint](https://github.com/dprint/dprint)
- [commitlint-rs](https://github.com/KeisukeYamashita/commitlint-rs)
- [ls-lint](https://github.com/loeffel-io/ls-lint)

also to

> for amazing documentation tool

- [docusaurus](https://github.com/facebook/docusaurus)

and more

## License

Apache-2.0

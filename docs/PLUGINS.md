# release-me \[0.x\]

> Except bugs, errors and/or strange behavior

[![Coverage Status](https://coveralls.io/repos/github/dalisoft/release-me/badge.svg?branch=master)](https://coveralls.io/github/dalisoft/release-me?branch=master)

Blazing fast minimal release workflow script written in **Bash** with plugins and presets support

List of contents:

- [Github repository](https://github.com/dalisoft/release-me)
- [Getting Started](./GET_STARTED.md)
- [Installation](./INSTALLATION.md)
- [Usage](./USAGE.md)
- [Configuration](./CONFIGURATION.md)
- [Presets](./PRESETS.md)
- **Plugins**
- [Benchmark](./BENCHMARK.md)

## Plugins

| Name             | Description                                      | Required |
| ---------------- | ------------------------------------------------ | -------- |
| `git`            | Creates **Git** tag and push to origin           | Yes      |
| `github-release` | Release a tag with proper `CHANGELOG` and commit | No       |
| `npm`            | Updates version field and Publishes **npm** tag  | No       |
| `npm-post`       | Updates version field                            | No       |
| `changelog`      | Generates `CHANGELOG` within your project        | No       |
| `docker`         | Publishes `docker` image to **Docker Hub**       | No       |

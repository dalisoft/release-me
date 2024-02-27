# release-me \[0.x\]

> Except bugs, errors and/or strange behavior

Blazing fast minimal release workflow script written in **Bash** with plugins and presets support

List of contents:

- [Github repository](https://github.com/dalisoft/release-me)
- [Getting Started](./GET_STARTED.md)
- [Installation](./INSTALLATION.md)
- [Usage](./USAGE.md)
- [Configuration](./CONFIGURATION.md)
- [Presets](./PRESETS.md)
- [Plugins](./PLUGINS.md)
- **Benchmark**

## Benchmark

> Please test yourself on your machine. These results on my machine **MacBook Pro 13" M1 16/512**

### Average library project

> Spoiler: ~8-times faster

| Name                | `time`  | Command                                                        |
| ------------------- | ------- | -------------------------------------------------------------- |
| semantic-release    | `7.93s` | `bunx semantic-release --dry-run`                              |
| go-semantic-release | `1s`    | `./semantic-release --hooks goreleaser`                        |
| release-me          | `1s`    | `bash ./release.sh --plugins=git,github-release,npm --dry-run` |

### Workspace project

> Spoiler: ~75-times faster

| Name             | `time`   | Command                                                                                                                                                  |
| ---------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| semantic-release | `82.43s` | `pnpm -r --workspace-concurrency=1 exec semantic-release -e @lomray/semantic-release-monorepo --dry-run`                                                 |
| release-me       | `1.09s`  | `time pnpm -r --workspace-concurrency=1 exec .release-me/release.sh --workspace --plugins=git,github-release,npm --preset=workspace --verbose --dry-run` |

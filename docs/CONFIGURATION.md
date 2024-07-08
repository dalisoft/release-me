---
sidebar_position: 5
---

# Configuration

## See [plugins](./category/plugins)

## GH Actions Configurations

See this project [workflow](../.github/workflows/lint_test.yml) or see below

> On **homepage** below content may show not properly, so, please check **workflow** file linked above

```yaml title=".github/workflows/release.yml"
name: Release
on:
  push:
    branches: [master]
  pull_request:
    branches: [master]

env:
  CI: true

jobs:
  release:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # <-- This line is REQUIRED
          token: ${{ secrets.GITHUB_TOKEN }} # <-- This line is REQUIRED too
      - name: Release
        env:
          GIT_USERNAME: ${{ vars.GIT_USERNAME }}
          GIT_EMAIL: ${{ vars.GIT_EMAIL }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # <-- This line is REQUIRED too
          GPG_KEY_ID: ${{ vars.GPG_KEY_ID }}
          GPG_KEY: ${{ secrets.GPG_KEY }}
          GPG_PASSPHRASE: ${{ secrets.GPG_PASSPHRASE }}
        shell: bash
        run: |
          git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me
          bash .release-me/release.sh --plugins=git,github-release
```

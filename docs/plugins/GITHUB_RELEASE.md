---
sidebar_position: 2
---

# Github Release

Release a tag with proper `CHANGELOG` and commit

## Required: **No**

## Environment variables

| Name           | Description                         | Type    |
| -------------- | ----------------------------------- | ------- |
| `GITHUB_TOKEN` | Used to publish **Github** releases | Secrets |

## Usage

```bash title="Bash (Terminal)"
git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me
bash .release-me/release.sh --plugins=git,github-release
```

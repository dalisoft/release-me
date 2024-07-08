---
sidebar_position: 3
---

# `npm`

Updates version field and Publishes **npm** tag

## Required: **No**

## Environment variables

| Name        | Description                         | Type    |
| ----------- | ----------------------------------- | ------- |
| `NPM_TOKEN` | Used to publish to **npm** registry | Secrets |

## Usage

```bash title="Bash (Terminal)"
git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me
bash .release-me/release.sh --plugins=npm,git
```

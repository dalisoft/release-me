---
sidebar_position: 6
---

# Docker

Publishes `docker` image to **Docker Hub**

## Required: **No**

## Environment variables

| Name                  | Description         | Type    |
| --------------------- | ------------------- | ------- |
| `DOCKER_HUB_USERNAME` | Docker username     | Secrets |
| `DOCKER_HUB_PAT`      | Docker Access Token | Secrets |

## Usage

```bash title="Bash (Terminal)"
git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me
bash .release-me/release.sh --plugins=git,docker
```

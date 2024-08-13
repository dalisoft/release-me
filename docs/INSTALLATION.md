---
sidebar_position: 2
---

# Installation

This project can be installed many ways but here we'll provide some ways

## Git cloning (Recommended)

Cloning on project folder is the easiest and safest way to use project

```bash title="Bash (Terminal)"
# this line is important
git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me

# other lines are optional
printf "%s" '.release-me' >> .gitignore'
git add -A .gitignore
git commit -m "chore: integration of release-me to my project"
```

## Git submodules

Using this project as **Git submodule** can be but it's not recommended

```bash title="Bash (Terminal)"
# this line is important
git submodule add -b master --name release-me --depth=1 -f https://github.com/dalisoft/release-me.git .release-me

# other lines are optional
git add -A .release-me
git commit -m "chore: integration of release-me to my project"
```

## Docker

```bash title="Bash (Terminal)"
docker run --rm --volume $(pwd):/repository dalisoft/release-me:latest
```

### `npm`

```bash title="Bash (Terminal)"
npm install release-me-sh --save-dev
# or
yarn add release-me-sh --dev
# or
bun add release-me-sh --dev
```

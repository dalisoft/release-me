# release-me \[0.x\]

> Except bugs, errors and/or strange behavior

[![Coverage Status](https://coveralls.io/repos/github/dalisoft/release-me/badge.svg?branch=master)](https://coveralls.io/github/dalisoft/release-me?branch=master)

Blazing fast minimal release workflow script written in **Bash** with plugins and presets support

List of contents:

- [Github repository](https://github.com/dalisoft/release-me)
- [Getting Started](./GET_STARTED.md)
- **Installation**
- [Usage](./USAGE.md)
- [Configuration](./CONFIGURATION.md)
- [Presets](./PRESETS.md)
- [Plugins](./PLUGINS.md)
- [Benchmark](./BENCHMARK.md)

## Installation

This project can be installed many ways but here we'll provide some ways

### Git cloning (Recommended)

Cloning on project folder is the easiest and safest way to use project

```sh
# this line is important
git clone https://github.com/dalisoft/release-me.git --depth 1 .release-me

# other lines are optional
echo '.release-me' >> .gitignore'
git add -A .gitignore
git commit -m "chore: integration of release-me to my project"
```

### Git submodules

Using this project as **Git submodule** can be but it's not recommended

```sh
# this line is important
git submodule add -b master --name release-me --depth=1 -f https://github.com/dalisoft/release-me.git .release-me

# other lines are optional
git add -A .release-me
git commit -m "chore: integration of release-me to my project"
```

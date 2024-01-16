# release-me

An zero-dependency single-file shell script which does all the work of [semantic-release](https://github.com/semantic-release/semantic-release) with it's **GitHub** and **npm** plugin and it's so fast

## Features

- Available everywhere
- Zero-dependency
- Zero pre-install
- Zero wait
- Programming language agnostic\*
- Single file
- Fast (<1 sec)

## Limitations

- Currently supports only **Node.js**, **Rust** and **Python** projects
- Version should be valid, see [Semantic Versioning](https://semver.org)

## Versioning priority

If one of files described below will be found, script parse first matched file and priority will ran as these

1. **Node.js** (`package.json`)
2. **Rust** (`Cargo.toml`)
3. **Python** (`setup.py`)

## Usage

```sh
GH_TOKEN=<YOUR_GITHUB_TOKEN> NPM_TOKEN=<YOUR_NPM_TOKEN> sh /path/to/script/release.sh
```

## Options

| Name         | Description                          | Status |
| ------------ | ------------------------------------ | ------ |
| `dry-run`    | Show only actions on logs            | ❌     |
| `workspaces` | Releases every projects on workspace | ❌     |

## Environment variables

| Name        | Description                         |
| ----------- | ----------------------------------- |
| `GH_TOKEN`  | Used to publish **Github** releases |
| `NPM_TOKEN` | Used to publish to **npm** registry |

## License

GPL-3 or later

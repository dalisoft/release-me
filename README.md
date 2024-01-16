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

- Currently supports only **Node.js**, **Python** and **Rust** projects
- Version should be valid, see [Semantic Versioning](https://semver.org)

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

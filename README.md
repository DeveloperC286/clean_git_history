# Clean Git History
[![crates.io](https://img.shields.io/crates/v/clean_git_history)](https://crates.io/crates/clean_git_history)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![License](https://img.shields.io/badge/License-AGPLv3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)


A Git history linter to ensure it stays clean for those who prefer a linear history without merge commits.


## Content
- [Usage](#usage)
   * [Git Environment Variables](#git-environment-variables)
   * [Logging](#logging)
- [Examples](#examples)
   * [GitHub](#github)
   * [GitLab CI](#gitlab-ci)
   * [Git Hook](#git-hook)
- [Installing](#installing)
   * [Binary](#binary)
   * [Cargo](#cargo)
- [Development](#development)
   * [Setup](#setup)
   * [Commands](#commands)
- [Issues/Feature Requests](#issuesfeature-requests)


## Usage
Clean Git History checks the commits from the current `HEAD`(inclusively) till a provided Git reference(exclusively).
This reference can be a branch, commit or tag, just provide it as the final argument.

__e.g.__

```sh
clean_git_history "origin/main"
clean_git_history "v0.2.0"
clean_git_history "bac789b4cc5fce9a26d6805c5da4bf17241523f1"
```


### Git Environment Variables
When looking for a repository the Git environment variables are respected.
When `${GIT_DIR}` is set, it takes precedence and Clean History begins searching for a repository in the directory specified in `${GIT_DIR}`.
When `${GIT_DIR}` is not set, Clean History searches for a repository beginning in the current directory.


### Logging
The crates `pretty_env_logger` and `log` are used to provide logging.
The environment variable `RUST_LOG` can be used to set the logging level.
See [https://crates.io/crates/pretty_env_logger](https://crates.io/crates/pretty_env_logger) for more detailed documentation.


## Examples
### GitHub Actions
<!-- x-release-please-start-version -->
```yaml
name: Git History

on: pull_request

jobs:
  clean:
    name: Clean
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code.
        uses: actions/checkout@4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
          fetch-depth: 0
      - name: Install Clean Git history.
        run: version="v1.0.2" && wget -O - "https://github.com/DeveloperC286/clean_git_history/releases/download/${version}/x86_64-unknown-linux-musl.tar.gz" | tar xz --directory "/usr/bin/"
      - name: Check clean Git history.
        run: clean-git-history "origin/${{ github.base_ref }}"
```
<!-- x-release-please-end -->

### GitLab CI
<!-- x-release-please-start-version -->
```yaml
clean-git-history-checking:
  stage: clean-git-history-checking
  image: rust
  before_script:
    - version="v1.0.2" && wget -O - "https://github.com/DeveloperC286/clean_git_history/releases/download/${version}/x86_64-unknown-linux-musl.tar.gz" | tar xz --directory "/usr/bin/"
  script:
    - clean_git_history "origin/${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}"
  rules:
    - if: $CI_MERGE_REQUEST_ID
```
<!-- x-release-please-end -->

### Git Hook
An example `pre-push` Git hook to check if the history of a project is clean before it is pushed to the remote server.

```sh
#!/usr/bin/env bash

set -o errexit
set -o pipefail

branch=$(git branch --show-current)
"${HOME}/.cargo/bin/clean_git_history" "origin/${branch}"
```


## Installing
### Binary
Statically linked compiled binaries are available for download.
Visit the releases page at [https://github.com/DeveloperC286/clean_git_history/releases](https://github.com/DeveloperC286/clean_git_history/releases) to see all the releases, the release notes contains links to binary downloads for various architectures.

  <!-- x-release-please-start-version -->
```sh
version="v1.0.2" && wget -O - "https://github.com/DeveloperC286/clean_git_history/releases/download/${version}/x86_64-unknown-linux-musl.tar.gz" | tar xz --directory "/usr/bin/"
```
<!-- x-release-please-end -->

### Cargo
Cargo is the Rust package manager, the `install` sub-command pulls from [crates.io](https://crates.io/crates/clean_git_history) and then compiles the binary locally, placing the compiled binary at `${HOME}/.cargo/bin/clean_git_history`.

```sh
cargo install clean_git_history
```

By default it installs the latest version at the time of execution.
You can specify a specific version to install using the `--version` argument.
For certain environments such as CICD etc you may want to pin the version.

e.g.

<!-- x-release-please-start-version -->
```sh
cargo install clean_git_history --version "1.0.2"
```
<!-- x-release-please-end -->

See [https://doc.rust-lang.org/cargo/commands/cargo-install.html#install-options](https://doc.rust-lang.org/cargo/commands/cargo-install.html#install-options) for more detailed documentation.


## Development
### Setup
You need Earthly and Docker installed, Earthly handles all build and runtime dependencies.

* [Get Earthly](https://earthly.dev/get-earthly)
* [Get Docker](https://www.docker.com/get-started/)

### Commands
#### Git History
```sh
earthly +check-clean-git-history
```

#### Conventional Commits
```sh
earthly +check-conventional-commits-linting
```

#### Formatting
##### Check
```sh
earthly +check-formatting
```

`rust`, `python`, `shell` and `yaml`

```sh
earthly +check-{language}-formatting
```

##### Fix
```sh
earthly +fix-formatting
```

`rust`, `python`, `shell` and `yaml`

```sh
earthly +fix-{language}-formatting
```

#### Linting
```sh
earthly +check-linting
```

`rust`, `shell` and `github-actions-workflows`

```sh
earthly +check-{language}-linting
```

#### Compiling
```sh
earthly +compile
```

#### Testing

```sh
earthly +end-to-end-test
```

```sh
earthly +static-binary-test
```

```sh
earthly +unit-test
```


## Issues/Feature Requests
To report an issue or request a new feature use [https://github.com/DeveloperC286/clean_git_history/issues](https://github.com/DeveloperC286/clean_git_history/issues).

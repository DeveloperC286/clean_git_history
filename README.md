# Clean Git History
[![crates.io](https://img.shields.io/crates/v/clean_git_history)](https://crates.io/crates/clean_git_history)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![License](https://img.shields.io/badge/License-AGPLv3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)


A Git history linter to ensure it stays clean for those who prefer a linear history without merge commits.

- [Usage](#usage)
- [Examples](#examples)
  - [GitHub Actions](#github-actions)
  - [GitLab CI](#gitlab-ci)
- [Installation](#installation)
  - [Binary](#binary)
  - [Cargo](#cargo)
  - [Docker](#docker)

## Usage
Clean Git History checks the commits from the current `HEAD`(inclusively) till a provided Git reference(exclusively).
This reference can be a branch, commit or tag, just provide it as the final argument.

__e.g.__

```sh
clean_git_history "origin/main"
clean_git_history "v0.2.0"
clean_git_history "bac789b4cc5fce9a26d6805c5da4bf17241523f1"
```

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
    container:
      image: ghcr.io/developerc286/clean_git_history:v1.1.4
    steps:
      - name: Checkout code.
        uses: actions/checkout@v5
        with:
          ref: ${{ github.event.pull_request.head.sha }}
          fetch-depth: 0
      - name: Check clean Git history.
        run: clean_git_history "origin/${{ github.base_ref }}"
```
<!-- x-release-please-end -->

### GitLab CI
<!-- x-release-please-start-version -->
```yaml
clean-git-history-checking:
  stage: clean-git-history-checking
  image: ghcr.io/developerc286/clean_git_history:v1.1.4
  script:
    - clean_git_history "origin/${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}"
  rules:
    - if: $CI_MERGE_REQUEST_ID
```
<!-- x-release-please-end -->

## Installation
### Binary
Statically linked compiled binaries are available for download.
Visit the releases page at [https://github.com/DeveloperC286/clean_git_history/releases](https://github.com/DeveloperC286/clean_git_history/releases) to see all the releases, the release notes contains links to binary downloads for various architectures.

<!-- x-release-please-start-version -->
```sh
version="v1.1.4" && wget -O - "https://github.com/DeveloperC286/clean_git_history/releases/download/${version}/x86_64-unknown-linux-musl.tar.gz" | tar xz --directory "/usr/bin/"
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
cargo install clean_git_history --version "1.1.4"
```
<!-- x-release-please-end -->

See [https://doc.rust-lang.org/cargo/commands/cargo-install.html#install-options](https://doc.rust-lang.org/cargo/commands/cargo-install.html#install-options) for more detailed documentation.

### Docker
You can use the Docker image published to [ghcr.io/developerc286/clean_git_history](https://github.com/DeveloperC286/clean_git_history/pkgs/container/clean_git_history).

<!-- x-release-please-start-version -->
```sh
docker run --rm -v $(pwd):/workspace -w /workspace ghcr.io/developerc286/clean_git_history:v1.1.4 origin/HEAD
```
<!-- x-release-please-end -->

## Issues/Feature Requests
Report issues or request features on our [GitHub Issues](https://github.com/DeveloperC286/clean_git_history/issues).

# Clean Git History
[![crates.io](https://img.shields.io/crates/v/clean_git_history)](https://crates.io/crates/clean_git_history)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![License](https://img.shields.io/badge/License-AGPLv3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)


A Git history linter to ensure it stays clean for those who prefer rebasing and fast-forwarding compared to merge and squash commits.


## Content
- [Usage](#usage)
   * [Additional Arguments](#additional-arguments)
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
      + [Git History](#git-history)
      + [Conventional Commits](#conventional-commits)
      + [Formatting](#formatting)
         - [Check](#check)
         - [Fix](#fix)
      + [Linting](#linting)
      + [Compiling](#compiling)
      + [Testing](#testing)
      + [Publishing](#publishing)
- [Issues/Feature Requests](#issuesfeature-requests)


## Usage
Clean History operates upon a range of Git commits in the repositories' history.
To specify the range of commits you can use either the `--from-commit-hash <commit-hash>` or `--from-reference <reference>` arguments.
The range of commits starts exclusively from the commit specified till inclusively of `HEAD`.

The only required arguments are either `--from-commit-hash <commit-hash>` or `--from-reference <reference>`.


### Additional Arguments
Additional command line flags can be passed to alter what and how the history is linted.

| Flag                      | |
|---------------------------|-|
| --ignore-merge-commits | If the flag is enabled then any Git merge commits are ignored, otherwise a merge commit's presence will cause linting to fail. |


### Git Environment Variables
When looking for a repository the Git environment variables are respected.
When `${GIT_DIR}` is set, it takes precedence and Clean History begins searching for a repository in the directory specified in `${GIT_DIR}`.
When `${GIT_DIR}` is not set, Clean History searches for a repository beginning in the current directory.


### Logging
The crates `pretty_env_logger` and `log` are used to provide logging.
The environment variable `RUST_LOG` can be used to set the logging level.
See [https://crates.io/crates/pretty_env_logger](https://crates.io/crates/pretty_env_logger) for more detailed documentation.


## Examples
### GitHub
```yaml
123
```

### GitLab CI
```yaml
clean-git-history-checking:
  stage: clean-git-history-checking
  image: rust
  before_script:
    - wget -q -O tmp.zip "https://gitlab.com/DeveloperC/clean_git_history/-/jobs/artifacts/bin-0.1.2-recompiling/download?job=release-binary-compiling-x86_64-linux-musl" && unzip tmp.zip && rm tmp.zip
  script:
    # Check all the commits in the branch.
    - ./clean_git_history --from-reference "origin/${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}"
  rules:
    - if: $CI_MERGE_REQUEST_ID
```

### Git Hook
An example `pre-push` Git hook to check if the history of a project is clean before it is pushed to the remote server.

```sh
#!/usr/bin/env bash

set -o errexit
set -o pipefail

root_commit_hash=$(git rev-list --max-parents=0 HEAD)
"${HOME}/.cargo/bin/clean_git_history"  --from-commit-hash "$root_commit_hash"
```


## Installing
### Binary
Statically linked compiled binaries are available for download.
Visit the releases page at [https://github.com/DeveloperC286/clean_git_history/releases](https://github.com/DeveloperC286/clean_git_history/releases) to see all the releases, the release notes contains links to binary downloads for various architectures.

### Cargo
Cargo is the Rust package manager, the `install` sub-command pulls from [crates.io](https://crates.io/crates/clean_git_history) and then compiles the binary locally, placing the compiled binary at `${HOME}/.cargo/bin/clean_git_history`.

```sh
cargo install clean_git_history
```

By default it installs the latest version at the time of execution.
You can specify a specific version to install using the `--version` argument.
For certain environments such as CICD etc you may want to pin the version.

e.g.

```sh
cargo install clean_git_history --version 0.1.2
```

See [https://doc.rust-lang.org/cargo/commands/cargo-install.html#install-options](https://doc.rust-lang.org/cargo/commands/cargo-install.html#install-options) for more information on the `--version` argument.


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
```sh
earthly +check-rust-formatting
```
```sh
earthly +check-python-formatting
```
```sh
earthly +check-shell-formatting
```
```sh
earthly +check-yaml-formatting
```

##### Fix
```sh
earthly +fix-formatting
```
```sh
earthly +fix-python-formatting
```
```sh
earthly +fix-rust-formatting
```
```sh
earthly +fix-shell-formatting
```
```sh
earthly +fix-yaml-formatting
```

#### Linting
```sh
earthly +check-linting
```
```sh
earthly +check-rust-linting
```
```sh
earthly +check-shell-linting
```

```sh
earthly +check-github-actions-workflows-linting ## TODO?
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

#### Publishing
```sh
earthly +publish-binary
```
```sh
earthly +publish-crate
```


## Issues/Feature Requests
To report an issue or request a new feature use [https://github.com/DeveloperC286/clean_git_history/issues](https://github.com/DeveloperC286/clean_git_history/issues).

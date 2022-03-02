# Clean Git History
[![crates.io](https://img.shields.io/crates/v/clean_git_history)](https://crates.io/crates/clean_git_history)
[![Pipeline Status](https://gitlab.com/DeveloperC/clean_git_history/badges/main/pipeline.svg)](https://gitlab.com/DeveloperC/clean_git_history/-/commits/main)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![License](https://img.shields.io/badge/License-AGPLv3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)


A Git history linter to ensure it stays clean for those who prefer rebasing and fast-forwarding compared to merge and squash commits.


## Content
 * [Usage](#usage)
   + [Usage - Additional Arguments](#usage-additional-arguments)
   + [Usage - Git Environment Variables](#usage-git-environment-variables)
   + [Usage - Logging](#usage-logging)
 * [CICD Examples](#cicd-examples)
   + [GitLab CI Rust Project Example](#gitlab-ci-rust-project-example)
     + [Via Cargo](#via-cargo)
     + [Via Binary Download](#via-binary-download)
   + [Git Hooks Rust Project Example](#git-hooks-rust-project-example)
 * [Downloading Binary](#downloading-binary)
 * [Compiling via Local Repository](#compiling-via-local-repository)
 * [Compiling via Cargo](#compiling-via-cargo)
 * [Unit Testing](#unit-testing)
 * [End-to-End Testing](#end-to-end-testing)
 * [Issues/Feature Requests](#issuesfeature-requests)


## Usage
Clean History operates upon a range of Git commits in the repositories' history.
To specify the range of commits you can use either the `--from-commit-hash <commit-hash>` or `--from-reference <reference>` arguments.
The range of commits starts exclusively from the commit specified till inclusively of `HEAD`.

The only required arguments are either `--from-commit-hash <commit-hash>` or `--from-reference <reference>`.

## Usage - Additional Arguments
Additional command line flags can be passed to alter what and how the history is linted.

| Flag                      | |
|---------------------------|-|
| --ignore-merge-commits | If the flag is enabled then any Git merge commits are ignored, otherwise a merge commit's presence will cause linting to fail. |


### Usage - Git Environment Variables
When looking for a repository the Git environment variables are respected.
When `${GIT_DIR}` is set, it takes precedence and Clean History begins searching for a repository in the directory specified in `${GIT_DIR}`.
When `${GIT_DIR}` is not set, Clean History searches for a repository beginning in the current directory.


### Usage - Logging
The crates `pretty_env_logger` and `log` are used to provide logging.
The environment variable `RUST_LOG` can be used to set the logging level.
See [https://crates.io/crates/pretty_env_logger](https://crates.io/crates/pretty_env_logger) for more detailed documentation.


## CICD Examples
### GitLab CI Rust Project Example
#### Via Cargo
See [Compiling via Cargo](#compiling-via-cargo) for more details about installing via Cargo.

__Note - This example downloads the latest `0.*` version.__

```
clean-git-history-checking:
  stage: clean-git-history-checking
  image: rust
  before_script:
    - cargo install clean_git_history --version ^0
  script:
    # Check all the commits in the branch.
    - /usr/local/cargo/bin/clean_git_history --from-reference "origin/${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}"
  rules:
    - if: $CI_MERGE_REQUEST_ID
```


#### Via Binary Download
See [Downloading Binary](#downloading-binary) for more details about Binary downloads.

__Note - This example downloads version `0.1.2`.__
```
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


### Git Hooks Rust Project Example
An example `pre-push` Git hook to check if the history of a project is clean before it is pushed to the remote server.

```
#!/usr/bin/env bash

set -o errexit
set -o pipefail

root_commit_hash=$(git rev-list --max-parents=0 HEAD)
"${HOME}/.cargo/bin/clean_git_history"  --from-commit-hash "$root_commit_hash"
```


## Downloading Binary
Statically linked compiled binaries are available for download.
Visit the releases page at [https://gitlab.com/DeveloperC/clean_git_history/-/releases](https://gitlab.com/DeveloperC/clean_git_history/-/releases) to see all the releases, the release notes contains links to binary downloads for various architectures.

If you do not trust the provided binaries another option is to compile your own and then make it available for remote download, so your CICD etc can then download it.


## Compiling via Local Repository
Checkout the code repository locally, change into the repository's directory and then build via Cargo.
Using the `--release` flag produces an optimised binary but takes longer to compile.

```
git clone git@gitlab.com:DeveloperC/clean_git_history.git
cd clean_git_history/
cargo build --release
```

The compiled binary is present in `target/release/clean_git_history`.


## Compiling via Cargo
Cargo is the Rust package manager, the `install` sub-command pulls from [crates.io](https://crates.io/crates/clean_git_history) and then compiles the binary locally, placing the compiled binary at `${HOME}/.cargo/bin/clean_git_history`.

```
cargo install clean_git_history
```

By default it installs the latest version at the time of execution.
You can specify a specific version to install using the `--version` argument.
For certain environments such as CICD etc you may want to pin the version.

e.g.

```
cargo install clean_git_history --version 0.1.2
```

Rather than pinning to a specific version you can specify the major or minor version.

e.g.

```
cargo install clean_git_history --version ^0
```

Will download the latest `0.*` release whether that is `0.1.2` or `0.7.0`.


## Unit Testing
The unit test suite has several parameterised tests, Cargo is used to set up and run all the unit tests.

```
cargo test
```


## End-to-End Testing
To ensure correctness as there are a variety of out of process dependencies the project has an End-to-End behaviour driven test suite using the behave framework (https://github.com/behave/behave).
To run the test suite you need to first build a binary, install Python3, install behave and then execute behave to run the behaviour driven test suite.

__Note - You can't use --release as the test suite uses `target/debug/clean_git_history`.__

```
cargo build
cd clean_git_history/end-to-end-tests/
virtualenv -p python3 .venv
source .venv/bin/activate
pip3 install -r requirements.txt
behave
```


## Issues/Feature Requests
To report an issue or request a new feature use [https://gitlab.com/DeveloperC/clean_git_history/-/issues](https://gitlab.com/DeveloperC/clean_git_history/-/issues).

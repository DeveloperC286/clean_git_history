VERSION 0.7


COPY_CI_DATA:
    COMMAND
    COPY --dir "ci/" ".github/" "./"


COPY_METADATA:
    COMMAND
    DO +COPY_CI_DATA
    COPY --dir ".git/" "./"


alpine-base:
    FROM alpine:3.18.9
    # renovate: datasource=repology packageName=alpine_3_20/bash
    ENV BASH_VERSION=5.2.15-r5
    RUN apk add --no-cache bash=$BASH_VERSION


rust-base:
    FROM +alpine-base
    # renovate: datasource=repology packageName=alpine_3_20/rust
    ENV RUST_VERSION=1.71.1-r0
    RUN apk add --no-cache rust=$RUST_VERSION
    WORKDIR "/clean_git_history"


check-clean-git-history:
    FROM +rust-base
    # renovate: datasource=github-releases packageName=DeveloperC286/clean_git_history
    ENV CLEAN_GIT_HISTORY_VERSION=0.1.2 
    RUN cargo install clean_git_history --version $CLEAN_GIT_HISTORY_VERSION --locked
    DO +COPY_METADATA
    ARG from_reference="origin/HEAD"
    RUN ./ci/check-clean-git-history.sh --from-reference "${from_reference}"


check-conventional-commits-linting:
    FROM +rust-base
    # renovate: datasource=github-releases packageName=DeveloperC286/conventional_commits_linter
    ENV CONVENTIONAL_COMMITS_LINTER_VERSION=0.12.3
    RUN cargo install conventional_commits_linter --version $CONVENTIONAL_COMMITS_LINTER_VERSION --locked
    DO +COPY_METADATA
    ARG from_reference="origin/HEAD"
    RUN ./ci/check-conventional-commits-linting.sh --from-reference "${from_reference}"


COPY_SOURCECODE:
    COMMAND
    DO +COPY_CI_DATA
    COPY --if-exists "Cargo.lock" "./"
    COPY --dir "Cargo.toml" "src/" "end-to-end-tests/" "./"


rust-formatting-base:
    FROM +rust-base
    # TODO
    RUN rustup component add rustfmt
    DO +COPY_SOURCECODE


check-rust-formatting:
    FROM +rust-formatting-base
    RUN ./ci/check-rust-formatting.sh


python-base:
    FROM +alpine-base
    # renovate: datasource=repology packageName=alpine_3_20/python3
    ENV PYTHON3_VERSION=3.11.10-r1 
    # renovate: datasource=repology packageName=alpine_3_20/git
    ENV GIT_VERSION=2.40.3-r0
    RUN apk add --no-cache python3=$PYTHON3_VERSION git=$GIT_VERSION
    WORKDIR "/consistent_whitespace"
    DO +COPY_SOURCECODE


python-formatting-base:
    FROM +python-base
    RUN pip3 install -r "end-to-end-tests/autopep8.requirements.txt"


check-python-formatting:
    FROM +python-formatting-base
    RUN ./ci/check-python-formatting.sh


golang-base:
    FROM golang:1.22.1
    WORKDIR "/consistent_whitespace"


shell-formatting-base:
    FROM +golang-base
    # renovate: datasource=github-releases packageName=mvdan/sh
    ENV SHFMT_VERSION=3.7.0
    RUN go install mvdan.cc/sh/v3/cmd/shfmt@v$SHFMT_VERSION
    DO +COPY_CI_DATA


check-shell-formatting:
    FROM +shell-formatting-base
    RUN ./ci/check-shell-formatting.sh


yaml-formatting-base:
    FROM +golang-base
    # renovate: datasource=github-releases packageName=google/yamlfmt
    ENV YAMLFMT_VERSION=0.10.0
    RUN go install github.com/google/yamlfmt/cmd/yamlfmt@v$YAMLFMT_VERSION
    COPY ".yamlfmt" "./"
    DO +COPY_CI_DATA


check-yaml-formatting:
    FROM +yaml-formatting-base
    RUN ./ci/check-yaml-formatting.sh


check-formatting:
    BUILD +check-rust-formatting
    BUILD +check-python-formatting
    BUILD +check-shell-formatting
    BUILD +check-yaml-formatting


fix-rust-formatting:
    FROM +rust-formatting-base
    RUN ./ci/fix-rust-formatting.sh
    SAVE ARTIFACT "src/" AS LOCAL "./"


fix-python-formatting:
    FROM +python-formatting-base
    RUN ./ci/fix-python-formatting.sh
    SAVE ARTIFACT "end-to-end-tests/" AS LOCAL "./"


fix-shell-formatting:
    FROM +shell-formatting-base
    RUN ./ci/fix-shell-formatting.sh
    SAVE ARTIFACT "ci/" AS LOCAL "./"


fix-yaml-formatting:
    FROM +yaml-formatting-base
    RUN ./ci/fix-yaml-formatting.sh
    SAVE ARTIFACT ".github/" AS LOCAL "./"


fix-formatting:
    BUILD +fix-rust-formatting
    BUILD +fix-python-formatting
    BUILD +fix-shell-formatting
    BUILD +fix-yaml-formatting


check-rust-linting:
    FROM +rust-base
    # TODO
    RUN rustup component add clippy
    DO +COPY_SOURCECODE
    RUN ./ci/check-rust-linting.sh


ubuntu-base:
    FROM ubuntu:22.04
    # https://askubuntu.com/questions/462690/what-does-apt-get-fix-missing-do-and-when-is-it-useful
    RUN apt-get update --fix-missing


check-shell-linting:
    FROM +ubuntu-base
    # TODO 
    RUN apt-get install shellcheck -y
    DO +COPY_CI_DATA
    RUN ./ci/check-shell-linting.sh


check-github-actions-workflows-linting:
    FROM +golang-base
    # renovate: datasource=github-releases packageName=rhysd/actionlint
    ACTIONLINT_VERSION=1.6.26
    RUN go install github.com/rhysd/actionlint/cmd/actionlint@v$ACTIONLINT_VERSION
    DO +COPY_CI_DATA
    RUN ./ci/check-github-actions-workflows-linting.sh


check-linting:
    BUILD +check-rust-linting
    BUILD +check-shell-linting
    BUILD +check-github-actions-workflows-linting


compile:
    FROM +rust-base
    DO +COPY_SOURCECODE
    RUN ./ci/compile.sh
    SAVE ARTIFACT "target/" AS LOCAL "./"
    SAVE ARTIFACT "Cargo.lock" AS LOCAL "./"


unit-test:
    FROM +rust-base
    DO +COPY_SOURCECODE
    RUN ./ci/unit-test.sh


end-to-end-test:
    FROM +python-base
    RUN pip3 install -r "end-to-end-tests/requirements.txt"
    COPY "+compile/target/" "target/"
    RUN ./ci/end-to-end-test.sh


release-artifacts:
    FROM +alpine-base
    # renovate: datasource=repology packageName=alpine_3_20/github-cli
    ENV GITHUB_CLI_VERSION=2.29.0-r4
    RUN apk add --no-cache github-cli=$GITHUB_CLI_VERSION
    DO +COPY_METADATA
    DO +COPY_SOURCECODE
    ARG release
    RUN --secret GH_TOKEN ./ci/release-artifacts.sh --release "${release}"


publish:
    FROM +rust-base
    COPY "README.md" "./"
    DO +COPY_SOURCECODE
    RUN --secret CARGO_REGISTRY_TOKEN ./ci/publish.sh

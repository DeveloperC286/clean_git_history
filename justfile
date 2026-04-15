# Auto-detect musl target for static binaries (Linux only)
# Only set MUSL_TARGET on supported architectures; targets that need it will check
MUSL_TARGET := `uname -m | sed 's/^x86_64$/x86_64-unknown-linux-musl/;s/^aarch64$/aarch64-unknown-linux-musl/'`

# Use --locked in CI to ensure reproducible builds
CARGO_LOCKED := if env("CI", "") != "" { "--locked" } else { "" }

default: compile

check-shell-permissions:
    ./ci/check-scripts-permissions.sh

check-rust-formatting:
    cargo fmt --all -- --check --config=group_imports=StdExternalCrate

fix-rust-formatting:
    cargo fmt --all -- --config=group_imports=StdExternalCrate

check-shell-formatting:
    shfmt --simplify --diff ci/*

fix-shell-formatting:
    shfmt --simplify --write ci/*

check-python-formatting:
    autopep8 --exit-code --diff --aggressive --aggressive --max-line-length 120 --recursive end-to-end-tests/

fix-python-formatting:
    autopep8 --in-place --aggressive --aggressive --max-line-length 120 --recursive end-to-end-tests/

check-yaml-formatting:
    yamlfmt -verbose -lint -dstar .github/workflows/*

fix-yaml-formatting:
    yamlfmt -verbose -dstar .github/workflows/*

check-rust-linting:
    cargo clippy --verbose {{ CARGO_LOCKED }} -- -D warnings

check-shell-linting:
    shellcheck ci/*.sh

check-python-linting:
    ruff check --line-length 120 end-to-end-tests/

fix-python-linting:
    ruff check --fix --line-length 120 end-to-end-tests/

check-github-actions-workflows-linting:
    actionlint -verbose -color

check-rust-dependencies:
    cargo machete

compile:
    cargo build --verbose {{ CARGO_LOCKED }}

unit-test:
    cargo test --verbose {{ CARGO_LOCKED }}

end-to-end-test: compile
    cd end-to-end-tests/ && behave

release:
    cargo build --release --target={{ MUSL_TARGET }} --locked --verbose

publish-binary RELEASE: release
    ./ci/publish-binary.sh {{ RELEASE }} {{ MUSL_TARGET }}

publish-crate:
    cargo publish --verbose

# Emulate GitHub Actions CI environment for testing
GITHUB_ACTIONS_ENV := "--env HOME=/github/home --env GITHUB_ACTIONS=true --env CI=true"

dogfood-docker FROM: release
    docker build --build-arg TARGET={{ MUSL_TARGET }} --tag clean_git_history --file Dockerfile .
    docker run --rm --volume {{ justfile_directory() }}:/workspace --workdir /workspace {{ GITHUB_ACTIONS_ENV }} clean_git_history --verbose {{ FROM }}

publish-docker-image RELEASE PLATFORM TARGET SUFFIX:
    ./ci/publish-docker-image.sh {{ RELEASE }} {{ PLATFORM }} {{ TARGET }} {{ SUFFIX }}

publish-docker-manifest RELEASE:
    ./ci/publish-docker-manifest.sh {{ RELEASE }}

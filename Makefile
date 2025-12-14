# Auto-detect musl target for static binaries (Linux only)
MUSL_TARGET := $(shell uname -m | sed 's/^x86_64$$/x86_64-unknown-linux-musl/;s/^aarch64$$/aarch64-unknown-linux-musl/')
ifeq ($(filter %unknown-linux-musl,$(MUSL_TARGET)),)
    $(error Unsupported architecture: $(shell uname -m). Static musl builds only supported on Linux x86_64 and aarch64)
endif

# Use --locked in CI to ensure reproducible builds
CARGO_LOCKED := $(if $(CI),--locked,)

.PHONY: default
default: compile

.PHONY: check-rust-formatting
check-rust-formatting:
	cargo fmt --all -- --check --config=group_imports=StdExternalCrate

.PHONY: check-shell-formatting
check-shell-formatting:
	shfmt --simplify --diff ci/*

.PHONY: check-python-formatting
check-python-formatting:
	autopep8 --exit-code --diff --aggressive --aggressive --max-line-length 120 --recursive end-to-end-tests/

.PHONY: check-yaml-formatting
check-yaml-formatting:
	yamlfmt -verbose -lint -dstar .github/workflows/*

.PHONY: fix-rust-formatting
fix-rust-formatting:
	cargo fmt --all -- --config=group_imports=StdExternalCrate

.PHONY: fix-shell-formatting
fix-shell-formatting:
	shfmt --simplify --write ci/*

.PHONY: fix-python-formatting
fix-python-formatting:
	autopep8 --in-place --aggressive --aggressive --max-line-length 120 --recursive end-to-end-tests/

.PHONY: fix-yaml-formatting
fix-yaml-formatting:
	yamlfmt -verbose -dstar .github/workflows/*

.PHONY: check-rust-linting
check-rust-linting:
	cargo clippy --verbose $(CARGO_LOCKED) -- -D warnings

.PHONY: check-github-actions-workflows-linting
check-github-actions-workflows-linting:
	actionlint -verbose -color

.PHONY: compile
compile:
	cargo build --verbose $(CARGO_LOCKED)

.PHONY: unit-test
unit-test:
	cargo test --verbose $(CARGO_LOCKED)

.PHONY: end-to-end-test
end-to-end-test: compile
	cd end-to-end-tests/ && behave

.PHONY: release
release:
	cargo build --release --target=$(MUSL_TARGET) --locked --verbose

.PHONY: publish-binary
publish-binary: release
	./ci/publish-binary.sh ${RELEASE} $(MUSL_TARGET)

.PHONY: publish-crate
publish-crate:
	cargo publish --verbose

.PHONY: dogfood-docker
dogfood-docker: release
	docker build --build-arg TARGET=$(MUSL_TARGET) --tag clean_git_history --file Dockerfile .
	docker run --rm --volume $(PWD):/workspace --workdir /workspace --env HOME=/github/home --env GITHUB_ACTIONS=true --env CI=true clean_git_history $(FROM)

.PHONY: publish-docker
publish-docker:
	./ci/publish-docker.sh ${RELEASE}

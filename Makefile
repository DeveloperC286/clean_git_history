.PHONY: check-clean-git-history check-conventional-commits-linting check-github-actions-workflows-linting check-yaml-formatting compile unit-test static-binary-test end-to-end-test check-rust-formatting check-python-formatting check-rust-linting publish-crate publish-binary fix-rust-formatting fix-python-formatting fix-yaml-formatting

check-clean-git-history:
	docker build -f ci/check-clean-git-history.Dockerfile --build-arg FROM=$(FROM) .

check-conventional-commits-linting:
	docker build -f ci/check-conventional-commits-linting.Dockerfile --build-arg FROM=$(FROM) .

check-rust-formatting:
	docker build -f ci/check-rust-formatting.Dockerfile .

check-python-formatting:
	docker build -f ci/check-python-formatting.Dockerfile .

check-rust-linting:
	docker build -f ci/check-rust-linting.Dockerfile .

check-yaml-formatting:
	docker build -f ci/check-yaml-formatting.Dockerfile .

check-github-actions-workflows-linting:
	docker build -f ci/check-github-actions-workflows-linting.Dockerfile .

compile:
	docker build -t compile -f ci/compile.Dockerfile .

unit-test:
	docker build -f ci/unit-test.Dockerfile .

static-binary-test: compile
	docker build -f ci/static-binary-test.Dockerfile .

end-to-end-test: compile
	docker build -f ci/end-to-end-test.Dockerfile .

publish-binary:
	docker build --secret id=GH_TOKEN --build-arg RELEASE=$(RELEASE) -f ci/publish-binary.Dockerfile .

publish-crate:
	docker build --secret id=CARGO_REGISTRY_TOKEN -f ci/publish-crate.Dockerfile .

fix-rust-formatting:
	docker build -t fix-rust-formatting -f ci/fix-rust-formatting.Dockerfile .
	docker run --rm -v $(PWD):/clean_git_history fix-rust-formatting

fix-python-formatting:
	docker build -t fix-python-formatting -f ci/fix-python-formatting.Dockerfile .
	docker run --rm -v $(PWD):/clean_git_history fix-python-formatting

fix-yaml-formatting:
	docker build -t fix-yaml-formatting -f ci/fix-yaml-formatting.Dockerfile .
	docker run --rm -v $(PWD):/clean_git_history fix-yaml-formatting
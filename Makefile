.PHONY: check-clean-git-history

# Get current user's UID and GID
UID := $(shell id -u)
GID := $(shell id -g)

# Default reference to check from
FROM ?= origin/HEAD

check-clean-git-history:
	docker build -t clean-git-history-check -f ci/Dockerfile .
	docker run --rm \
		--volume $(PWD):/clean_git_history \
		-u $(UID):$(GID) \
		clean-git-history-check $(FROM)

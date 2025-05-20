.PHONY: check-clean-git-history

check-clean-git-history:
	docker build -t clean-git-history-check -f ci/Dockerfile .

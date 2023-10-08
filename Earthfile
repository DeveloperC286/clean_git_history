VERSION 0.7


e2e-formatting-base:
		FROM python:3.12.0-slim
		COPY "./ci" "./ci"
		COPY "./clean_git_history/end-to-end-tests" "./clean_git_history/end-to-end-tests"
		RUN pip3 install -r "./clean_git_history/end-to-end-tests/autopep8.requirements.txt"


check-e2e-formatting:
		FROM +e2e-formatting-base
		RUN ./ci/check-e2e-formatting.sh


fix-e2e-formatting:
		FROM +e2e-formatting-base
		RUN ./ci/fix-e2e-formatting.sh
		SAVE ARTIFACT "./clean_git_history/end-to-end-tests" AS LOCAL "./clean_git_history/end-to-end-tests"

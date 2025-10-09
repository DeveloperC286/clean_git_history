FROM python:3.14.0-alpine3.22@sha256:829edcc737417f9084a154511bde03a50b7996f3746e4c8a6b30a99a9a10648c
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

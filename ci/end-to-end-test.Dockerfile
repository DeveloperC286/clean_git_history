FROM python:3.14.0-alpine3.22@sha256:9c32c2f24d00536cac7d4d356d82c5274fb17366c52aa59ed0cc4c06f8b60a35
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

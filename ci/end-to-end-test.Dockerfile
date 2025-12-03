FROM python:3.14.1-alpine3.22@sha256:4f699e4afac838c50be76deac94a6dde0e287d5671fd8e95eb410f850801b237
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

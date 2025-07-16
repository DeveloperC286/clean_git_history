FROM python:3.13.5-alpine3.22@sha256:d005934d99924944e826dc659c749b775965b21968b1ddb10732f738682db869
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

FROM python:3.14.0-alpine3.22@sha256:0bf59161c735f604ea070af402d65b1a088ce3fd7fe4329f5983446148e84930
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

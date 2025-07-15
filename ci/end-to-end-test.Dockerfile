FROM python:3.13.5-alpine3.22@sha256:e08874637f2704667426cb3b8d14581b9cb12dd2c237c8419f65446669443921
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

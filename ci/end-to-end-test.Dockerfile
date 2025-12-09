FROM python:3.14.2-alpine3.22@sha256:91859223a313a4407c239afb3a8e68bddc3dbfb0d24ddc5bdeb029136b55b150
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

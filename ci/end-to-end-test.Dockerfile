FROM python:3.13.5-alpine3.22@sha256:610020b9ad8ee92798f1dbe18d5e928d47358db698969d12730f9686ce3a3191
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

FROM python:3.13.6-alpine3.22@sha256:af1fd7a973d8adc761ee6b9d362b99329b39eb096ea3c53b8838f99bd187011e
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

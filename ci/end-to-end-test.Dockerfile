FROM python:3.14.2-alpine3.22@sha256:1d8fa2886b8288e8c65e96ad0672224fe397ae627433f7d8187b08a7586b1fa9
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

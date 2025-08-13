FROM python:3.13.6-alpine3.22@sha256:97990f8cff85f0a25eef434f77f265d63d3767d15f59bfd19860de0b7f702ead
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

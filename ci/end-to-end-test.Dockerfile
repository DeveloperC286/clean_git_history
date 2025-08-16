FROM python:3.13.7-alpine3.22@sha256:587df003ff48316a56a0ddac50e1e2b64dfeca281f0c071b91920895a65b12d2
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

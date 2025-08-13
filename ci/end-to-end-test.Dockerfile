FROM python:3.13.6-alpine3.22@sha256:c28add7bfdd8e8c0bb557f4123d73a0f3afc2f3d7972c9af021b7551658bc641
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

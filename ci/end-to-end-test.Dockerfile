FROM python:3.13.3-alpine3.21@sha256:452682e4648deafe431ad2f2391d726d7c52f0ff291be8bd4074b10379bb89ff
RUN apk add --no-cache \
    git=2.47.2-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt 

WORKDIR /clean_git_history/end-to-end-tests
ENTRYPOINT ["behave"]
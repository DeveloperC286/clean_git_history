FROM python:3.13.3-alpine3.21
RUN apk add --no-cache \
    git=2.47.2-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt 

WORKDIR /clean_git_history/end-to-end-tests
ENTRYPOINT ["behave"]
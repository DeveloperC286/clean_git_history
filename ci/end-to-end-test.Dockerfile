FROM python:3.13.3-alpine3.21
RUN apk add --no-cache \
    git=2.47.2-r0

WORKDIR /clean_git_history

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt 

COPY end-to-end-tests ./end-to-end-tests/

COPY --from=compile /clean_git_history/target/x86_64-unknown-linux-musl/debug/clean_git_history /usr/local/bin/

RUN cd end-to-end-tests/ && behave 
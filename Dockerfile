FROM alpine:3.22.0

RUN apk add --no-cache \
    git=2.49.0-r0

COPY ./target/x86_64-unknown-linux-musl/release/clean_git_history /usr/local/bin/

ENTRYPOINT ["clean_git_history"] 
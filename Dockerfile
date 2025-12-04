FROM alpine:3.23.0@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375

RUN apk add --no-cache \
    git=2.49.1-r0 && \
    git config --system --add safe.directory '*'

COPY ./target/x86_64-unknown-linux-musl/release/clean_git_history /usr/local/bin/

WORKDIR /workspace

ENTRYPOINT ["clean_git_history"]

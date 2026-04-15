FROM alpine:3.23.4@sha256:c7989ac7a27b473e1795973c98d714f62b4dd0b134594d36880505ce0bfd716b

RUN apk add --no-cache \
    git=2.52.0-r0 && \
    git config --system --add safe.directory '*'

ARG TARGET
COPY ./target/${TARGET}/release/clean_git_history /usr/local/bin/

WORKDIR /workspace

ENTRYPOINT ["clean_git_history"]

FROM alpine:3.21
RUN apk add --no-cache \
    github-cli=2.63.0-r5

WORKDIR /clean_git_history

ENTRYPOINT ["/bin/sh", "-c", "ci/publish-binary.sh"]
FROM alpine:3.21@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c
RUN apk add --no-cache \
    github-cli=2.63.0-r5

WORKDIR /clean_git_history

ENTRYPOINT ["/bin/sh", "-c", "ci/publish-binary.sh"]
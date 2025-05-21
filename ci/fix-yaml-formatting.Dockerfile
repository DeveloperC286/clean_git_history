FROM golang:1.24.3@sha256:4c0a1814a7c6c65ece28b3bfea14ee3cf83b5e80b81418453f0e9d5255a5d7b8

# renovate: datasource=github-releases depName=google/yamlfmt
ENV YAMLFMT_VERSION="v0.17.0"
RUN go install github.com/google/yamlfmt/cmd/yamlfmt@$YAMLFMT_VERSION

WORKDIR /clean_git_history

ENTRYPOINT ["yamlfmt", "-dstar"]
CMD [".github/workflows/*"]
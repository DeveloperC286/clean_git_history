FROM golang:1.24.3@sha256:81bf5927dc91aefb42e2bc3a5abdbe9bb3bae8ba8b107e2a4cf43ce3402534c6

# renovate: datasource=github-releases depName=google/yamlfmt
ENV YAMLFMT_VERSION="v0.17.0"
RUN go install github.com/google/yamlfmt/cmd/yamlfmt@$YAMLFMT_VERSION

WORKDIR /clean_git_history

ENTRYPOINT ["yamlfmt", "-verbose", "-lint", "-dstar"]
CMD [".github/workflows/*"]
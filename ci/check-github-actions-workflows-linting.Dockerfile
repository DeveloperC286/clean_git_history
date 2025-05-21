FROM golang:1.24.3@sha256:4c0a1814a7c6c65ece28b3bfea14ee3cf83b5e80b81418453f0e9d5255a5d7b8

# renovate: datasource=github-releases depName=rhysd/actionlint
ENV ACTIONLINT_VERSION="v1.7.7"
RUN go install github.com/rhysd/actionlint/cmd/actionlint@$ACTIONLINT_VERSION

WORKDIR /clean_git_history
COPY .github .github

RUN actionlint --verbose .github/workflows/* 
FROM rust:1.87.0-alpine3.21@sha256:fa7c28576553c431224a85c897c38f3a6443bd831be37061ab3560d9e797dc82 AS builder
RUN apk add --no-cache \
    musl-dev=1.2.5-r9

WORKDIR /clean_git_history

COPY Cargo.toml Cargo.lock ./
COPY .cargo ./.cargo/
COPY src ./src/

RUN cargo build --target=x86_64-unknown-linux-musl --locked --release

FROM alpine:3.21
RUN apk add --no-cache \
    github-cli=2.63.0-r5

WORKDIR /clean_git_history
COPY --from=builder /clean_git_history/target/x86_64-unknown-linux-musl/release/clean_git_history .

ARG RELEASE
RUN tar -czvf "x86_64-unknown-linux-musl.tar.gz" clean_git_history
RUN gh release upload "${RELEASE}" "x86_64-unknown-linux-musl.tar.gz"

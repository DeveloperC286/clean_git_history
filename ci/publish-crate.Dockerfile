FROM rust:1.87.0-alpine3.21@sha256:fa7c28576553c431224a85c897c38f3a6443bd831be37061ab3560d9e797dc82

WORKDIR /clean_git_history

COPY Cargo.toml Cargo.lock ./
COPY src/ ./src/
COPY README.md ./

RUN --mount=type=secret,id=CARGO_REGISTRY_TOKEN,env=CARGO_REGISTRY_TOKEN \
    cargo publish --verbose
FROM ubuntu:24.04@sha256:6015f66923d7afbc53558d7ccffd325d43b4e249f41a6e93eef074c9505d2233

WORKDIR /clean_git_history
COPY --from=compile /clean_git_history/target/x86_64-unknown-linux-musl/debug/clean_git_history .

RUN ./clean_git_history --help 
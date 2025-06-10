FROM python:3.13.3-alpine3.21@sha256:452682e4648deafe431ad2f2391d726d7c52f0ff291be8bd4074b10379bb89ff
RUN apk add --no-cache \
    py3-autopep8=2.1.0-r1

WORKDIR /clean_git_history

ENTRYPOINT ["autopep8", "--exit-code", "--diff", "--aggressive", "--aggressive", "--max-line-length", "120", "--recursive"]
CMD ["."]
FROM python:3.13.3-alpine3.21
RUN apk add --no-cache \
    py3-autopep8=2.1.0-r1

WORKDIR /clean_git_history

ENTRYPOINT ["autopep8", "--exit-code", "--diff", "--aggressive", "--aggressive", "--max-line-length", "120", "--recursive"]
CMD ["."]
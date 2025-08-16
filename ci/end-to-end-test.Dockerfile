FROM python:3.13.7-alpine3.22@sha256:e1532c410c6cc58423c175421dbae22ac548760a318b085884af953115921ece
RUN apk add --no-cache \
	git=2.49.1-r0

COPY end-to-end-tests/requirements.txt ./
RUN pip3 install -r requirements.txt

ENTRYPOINT ["behave"]

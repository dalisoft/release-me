FROM alpine:latest

RUN apk add --no-cache bash git
RUN mkdir -p /repository

VOLUME [ "/repository" ]
WORKDIR /repository

ADD release.sh presets plugins /repository/
RUN chmod +x /repository/release.sh

ENTRYPOINT [ "/repository/release.sh" ]
CMD [ "--help" ]

FROM alpine:3.18

RUN apk add --update --no-cache bash curl

CMD ["/usr/local/bin/check.sh"]

COPY check.sh /usr/local/bin/


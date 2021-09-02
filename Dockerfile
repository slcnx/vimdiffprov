FROM alpine

ADD vimdiffprov.sh /usr/local/bin/vimdiffprov.sh
RUN chmod +x /usr/local/bin/vimdiffprov.sh
ENTRYPOINT /usr/local/bin/vimdiffprov.sh

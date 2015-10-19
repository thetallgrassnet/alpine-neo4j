FROM thetallgrassnet/alpine-java:8

RUN apk add --quiet --update bash curl \
    && curl --fail --silent --show-error --location --output lsof.apk http://dl-3.alpinelinux.org/alpine/v3.0/main/x86_64/lsof-4.87-r0.apk \
    && apk add --quiet --allow-untrusted lsof.apk \
    && rm lsof.apk \
    && rm -rf /var/cache/apk/*

ENV NEO4J_VERSION 2.3.0-RC1
ENV NEO4J_EDITION enterprise
ENV NEO4J_DOWNLOAD_SHA256 fdd77a1c0802241a4a712d0ae957abd5f3fe0fdb1124b0e3ca24d0621f01b986
ENV NEO4J_DOWNLOAD_ROOT http://dist.neo4j.org
ENV NEO4J_TARBALL neo4j-$NEO4J_EDITION-$NEO4J_VERSION-unix.tar.gz
ENV NEO4J_URI $NEO4J_DOWNLOAD_ROOT/$NEO4J_TARBALL



RUN curl --fail --silent --show-error --location --output neo4j.tar.gz $NEO4J_URI \
    && echo "$NEO4J_DOWNLOAD_SHA256  neo4j.tar.gz" | sha256sum -c -s - \
    && tar -xzf neo4j.tar.gz -C /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm neo4j.tar.gz

WORKDIR /var/lib/neo4j

RUN mv data /data \
    && ln -s /data

VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 7474 7473

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["neo4j"]

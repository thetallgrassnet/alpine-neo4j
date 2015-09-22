# Neo4j Server on Alpine
# Repository http://github.com/thetallgrassnet/alpine-neo4j
FROM thetallgrassnet/alpine-java

MAINTAINER Jesse B. Hannah <jesse@jbhannah.net>

ENV PATH $PATH:/var/lib/neo4j/bin

ENV NEO4J_VERSION 2.2.5
ENV NEO4J_DOWNLOAD_SHA256 7fadc119f465a3d6adceb610401363fb158a5ed25081f9893d4f56ac4989a998

RUN apk add --update bash curl \
    && curl -fSL -o neo4j-community.tar.gz http://dist.neo4j.org/neo4j-community-$NEO4J_VERSION-unix.tar.gz \
    && apk del --rdepends curl && rm -rf /var/cache/apk/* \
    && sha256sum neo4j-community.tar.gz \
    && echo "$NEO4J_DOWNLOAD_SHA256  neo4j-community.tar.gz" | sha256sum -c - \
    && tar xzf neo4j-community.tar.gz -C /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && ln -s /var/lib/neo4j/data /data \
    && touch /tmp/rrd \
    && rm neo4j-community.tar.gz

RUN sed -i -e "s|.*dbms.pagecache.memory=.*|dbms.pagecache.memory=512M|g" /var/lib/neo4j/conf/neo4j.properties \
    && sed -i -e "s|.*keep_logical_logs=.*|keep_logical_logs=100M size|g" /var/lib/neo4j/conf/neo4j.properties \
    && sed -i -e "s|#*remote_shell_enabled=.*|remote_shell_enabled=true|g" /var/lib/neo4j/conf/neo4j.properties \
    && sed -i -e "s|org.neo4j.server.webadmin.rrdb.location=.*|org.neo4j.server.webadmin.rrdb.location=/tmp/rrd|g" /var/lib/neo4j/conf/neo4j-server.properties \
    && sed -i -e "s|Dneo4j.ext.udc.source=.*|Dneo4j.ext.udc.source=docker|g" /var/lib/neo4j/conf/neo4j-wrapper.conf \
    && ulimit -n 40000 > /dev/null

VOLUME /data

COPY neo4j.sh /neo4j.sh

EXPOSE 7474 7473

CMD ["/neo4j.sh"]

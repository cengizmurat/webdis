FROM alpine:3.11.3 AS stage
MAINTAINER Nicolas Favre-Felix <n.favrefelix@gmail.com>

RUN apk update && apk add wget make gcc libevent-dev msgpack-c-dev musl-dev bsd-compat-headers git
RUN git clone https://github.com/cengizmurat/webdis.git
RUN cd webdis && make && make install && cd ..
RUN sed -i -e 's/"daemonize":.*true,/"daemonize": false,/g' /etc/webdis.prod.json

# main image
FROM alpine:3.11.3
RUN apk update && apk add libevent msgpack-c redis
COPY --from=stage /usr/local/bin/webdis /usr/local/bin/
COPY --from=stage /etc/webdis.prod.json /etc/webdis.prod.json
RUN echo "daemonize yes" >> /etc/redis.conf
CMD /usr/bin/redis-server /etc/redis.conf && /usr/local/bin/webdis /etc/webdis.prod.json
RUN chmod a+rw /var/log/redis

EXPOSE 7379

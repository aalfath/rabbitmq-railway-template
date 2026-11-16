# RabbitMQ for Railway: the official image, pinned by version and digest.
FROM rabbitmq:4.4.0-management@sha256:753099a19b577c322117f793f864b3129cbba96d40317221a69d73976e3c843c

# Railway gives every deploy a new container hostname. RabbitMQ keeps its data
# under a directory named after the node, so a fixed node name keeps the data
# on the volume across redeploys.
ENV RABBITMQ_NODENAME=rabbit@localhost \
    RABBITMQ_USE_LONGNAME=false

COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 0755 /usr/local/bin/railway-start.sh

# 5672 = AMQP, 15672 = management UI and HTTP API (also the health check)
EXPOSE 5672 15672

ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["rabbitmq-server"]

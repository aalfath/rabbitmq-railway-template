# Changelog

## 2026-11-16: RabbitMQ 4.4.0 (first release)

- RabbitMQ 4.4.0 from `rabbitmq:4.4.0-management@sha256:753099a19b577c322117f793f864b3129cbba96d40317221a69d73976e3c843c`.
- Data on a volume at `/var/lib/rabbitmq` with a fixed node name (`rabbit@localhost`), so it survives redeploys.
- Management UI on the public domain, AMQP on the private network and a TCP proxy, memory alarm sized to the container limit, no `guest` user.

# RabbitMQ on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/rabbitmq-2?utm_medium=integration&utm_source=button&utm_campaign=rabbitmq)

A one-click [Railway](https://railway.com) template for [RabbitMQ](https://www.rabbitmq.com/), the open-source message broker (AMQP 0-9-1, with the management UI and HTTP API).

**Version:** RabbitMQ 4.4.0, from the official image `rabbitmq:4.4.0-management`, pinned by digest in the [`Dockerfile`](Dockerfile).

## What the template deploys

One service, **RabbitMQ**, built from this repository:

- The official RabbitMQ image with the management and Prometheus plugins.
- A volume at `/var/lib/rabbitmq`, so queues, messages, users and settings survive redeploys. The node name is fixed (`rabbit@localhost`) because Railway gives each deploy a new hostname.
- The management UI on the service's public Railway domain (login required). The health check is `/` on the same port.
- AMQP on port `5672` over Railway's private network, plus a TCP proxy for clients outside Railway.
- A memory alarm sized to the container's memory limit instead of the host's RAM.
- No `guest` user. The admin user and its random password come from the template variables.

## Variables

| Variable | Default | What it is |
|---|---|---|
| `RABBITMQ_DEFAULT_USER` | `admin` | Admin user created on first start |
| `RABBITMQ_DEFAULT_PASS` | random, 32 characters | Its password, generated per deploy |
| `PORT` | `15672` | Port of the management UI and the health check |
| `RABBITMQ_PRIVATE_URL` | reference | `amqp://` URL for services in the same Railway project |
| `RABBITMQ_URL` | reference | `amqp://` URL through the public TCP proxy |

The user and password only apply on the first start, when the volume is empty. To change the password later, use the management UI (Admin > Users) or `rabbitmqctl change_password`.

Other services in the project connect with `${{RabbitMQ.RABBITMQ_PRIVATE_URL}}`.

## How updates reach you

The service builds from this repository's `main` branch. When a new RabbitMQ version is tested here, the pin in the `Dockerfile` is bumped, the change is described in [`CHANGELOG.md`](CHANGELOG.md), and Railway shows an "update available" notice on your deployment. You decide when to apply it. Read the changelog first: RabbitMQ only supports upgrading from the previous minor series, and some upgrades need all feature flags enabled first.

## Files

- `Dockerfile`: the pinned official image plus the start script.
- `railway-start.sh`: writes the Railway settings (management port, IPv6 listener, memory limit, guest restricted to localhost), checks the credentials are set, then runs the image's own entrypoint.

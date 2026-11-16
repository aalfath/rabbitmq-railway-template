#!/usr/bin/env bash
# Writes the Railway-specific RabbitMQ settings, then hands over to the
# official image's entrypoint (which fixes volume ownership and drops root).
set -euo pipefail

: "${PORT:=15672}"

if [ -z "${RABBITMQ_DEFAULT_USER:-}" ] || [ -z "${RABBITMQ_DEFAULT_PASS:-}" ]; then
  echo "railway-start: RABBITMQ_DEFAULT_USER and RABBITMQ_DEFAULT_PASS must be set" >&2
  exit 1
fi
if [ "${#RABBITMQ_DEFAULT_PASS}" -lt 12 ]; then
  echo "railway-start: RABBITMQ_DEFAULT_PASS must be at least 12 characters" >&2
  exit 1
fi

# Listen on IPv6 too (Railway's private network) when the container has it.
ip=0.0.0.0
[ -s /proc/net/if_inet6 ] && ip="::"

conf=/etc/rabbitmq/conf.d/90-railway.conf
{
  echo "# Written by railway-start.sh on every start. Do not edit."
  echo "# The guest user may only log in from inside the container."
  echo "loopback_users.guest = true"
  echo "listeners.tcp.default = 5672"
  echo "management.tcp.port = ${PORT}"
  echo "management.tcp.ip = ${ip}"
} > "$conf"

# Size the memory alarm to the container's memory limit, not the host's RAM.
limit=""
if [ -r /sys/fs/cgroup/memory.max ]; then
  limit=$(cat /sys/fs/cgroup/memory.max)
elif [ -r /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
  limit=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
fi
host_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
if [[ "$limit" =~ ^[0-9]+$ ]] && [ "$limit" -lt $((host_kb * 1024)) ]; then
  echo "total_memory_available_override_value = ${limit}" >> "$conf"
  echo "railway-start: container memory limit ${limit} bytes" >&2
fi

if [ "${1:-}" = "rabbitmq-server" ] || [ "$#" -eq 0 ]; then
  exec docker-entrypoint.sh rabbitmq-server
fi
exec docker-entrypoint.sh "$@"

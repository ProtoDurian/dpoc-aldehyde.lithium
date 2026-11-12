# No own source code: stock Logto plus a wrapper entrypoint (reads the database secret, seeds idempotently,
# deploys database alterations under a lock, starts). The wrapper image exists only so the Kargo Warehouse sees
# image + both charts at one version.
ARG LOGTO_VERSION=1.46.0
FROM ghcr.io/logto-io/logto:${LOGTO_VERSION}
ARG LOGTO_VERSION=1.46.0
ENV LITHIUM_LOGTO_VERSION=${LOGTO_VERSION}
COPY entrypoint.sh /usr/local/bin/lithium-entrypoint
COPY migrate.cjs /usr/local/bin/lithium-migrate.cjs
RUN chmod 0755 /usr/local/bin/lithium-entrypoint
ENTRYPOINT ["/usr/local/bin/lithium-entrypoint"]
CMD ["npm", "start"]

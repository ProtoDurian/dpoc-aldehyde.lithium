# No own source code: stock Logto 1.45.0 (round 2: upgrade test starts here, then 1.46.0) plus a wrapper entrypoint (reads the database secret,
# seeds idempotently, starts). The wrapper image exists only so the Kargo Warehouse sees
# image + both charts at one version.
FROM ghcr.io/logto-io/logto:1.45.0
COPY entrypoint.sh /usr/local/bin/lithium-entrypoint
RUN chmod 0755 /usr/local/bin/lithium-entrypoint
ENTRYPOINT ["/usr/local/bin/lithium-entrypoint"]
CMD ["npm", "start"]

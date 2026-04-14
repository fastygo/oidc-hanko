FROM ghcr.io/teamhanko/hanko:latest
COPY hanko-config.yaml /etc/config/config.yaml
EXPOSE 5700
CMD ["serve", "public", "--config", "/etc/config/config.yaml"]

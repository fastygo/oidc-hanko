FROM ghcr.io/teamhanko/hanko:latest
COPY hanko-config.yaml /etc/config/config.yaml
EXPOSE 5700
EXPOSE 8001
CMD ["serve", "all", "--config", "/etc/config/config.yaml"]

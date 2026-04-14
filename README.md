# oidc-hanko — Hanko authentication backend (Docker)

This repository packages the official **[Hanko](https://github.com/teamhanko/hanko)** server with a **project-specific `hanko-config.yaml`**. In a typical stack with a separate SAML IdP, Hanko provides:

- User accounts, passwords, and passkeys (WebAuthn)
- Session management and **JWT** issuance
- **JWKS** for JWT verification (used by the SAML IdP in `@SSO`)
- Frontend assets for **Hanko Elements** loaded by the IdP login page

Hanko’s built-in **SAML** features are **disabled** here (`saml.enabled: false`) because SAML for applications is handled by the dedicated Go IdP, not by Hanko as an SP.

There is **no custom Go application** in this repo—only Docker configuration and Hanko YAML.

**License:** [MIT](LICENSE)

---

## Requirements

- Docker and Docker Compose
- PostgreSQL (provided by Compose in this repo)

---

## Configuration

### `hanko-config.yaml`

Key sections:

| Section | Purpose |
|---------|---------|
| `database` | PostgreSQL connection (`host: hanko-db` matches the Compose service name) |
| `secrets.keys` | Signing material for Hanko JWTs — use `${HANKO_SESSION_SECRET}` with env substitution if supported by your Hanko version |
| `server.public.address` | Listen address inside the container (`:5700`) |
| `server.public.cors` | Origins allowed to call the API (website + IdP pages) |
| `session.cookie` | Cookie domain and flags for cross-site use |
| `webauthn.relying_party` | Relying Party ID and origins for passkeys |
| `saml.enabled` | `false` — SAML is not used on the Hanko side in this design |

Placeholders like `${HANKO_DB_PASSWORD}` are intended to match environment variables injected by Docker Compose. If your Hanko build does not expand variables inside YAML, set literal values in a **local, untracked** override file or consult the [Hanko configuration documentation](https://docs.hanko.io).

### `.env`

Copy from `.env.example` and set:

- `HANKO_DB_PASSWORD` — PostgreSQL password for user `hanko`
- `HANKO_SESSION_SECRET` — long random secret for JWT/session signing

---

## Build and run (Docker Compose)

From this directory:

```bash
cp .env.example .env
# Edit .env with strong secrets

docker compose build
docker compose up -d
```

The Hanko API is published on **127.0.0.1:5700** (see `docker-compose.yml`). PostgreSQL data persists in the named volume `hanko_pgdata`.

Healthcheck on `hanko-db` ensures the app starts after the database is ready.

---

## Production deployment

1. **TLS**: Put a reverse proxy in front (e.g. `https://api.yourdomain` → `http://127.0.0.1:5700`).
2. **Secrets**: Never commit `.env`; rotate `HANKO_DB_PASSWORD` and `HANKO_SESSION_SECRET` for production.
3. **Email**: If you require email verification or magic links, configure SMTP and `email_delivery` per Hanko docs (the sample file enables email features but may need extra SMTP settings).
4. **CORS / WebAuthn**: Update `server.public.cors.allow_origins` and `webauthn.relying_party.origins` to your real HTTPS URLs.

---

## Image

`Dockerfile` uses `ghcr.io/teamhanko/hanko:latest` and runs:

```text
serve public --config /etc/config/config.yaml
```

---

## Related repositories

| Repository | Role |
|------------|------|
| `@SSO` | SAML IdP (uses Hanko JWT + Elements) |
| (your SP repo) | Website (SAML SP) |

---

## Upstream

- [github.com/teamhanko/hanko](https://github.com/teamhanko/hanko)
- [Hanko documentation](https://docs.hanko.io)

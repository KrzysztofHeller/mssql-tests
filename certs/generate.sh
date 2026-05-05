#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout mssql.key -out mssql.pem \
  -days 365 -subj "/CN=mssql-tls" \
  -addext "subjectAltName=DNS:mssql-tls,DNS:localhost,IP:127.0.0.1,IP:192.168.10.226"

chmod 644 mssql.pem mssql.key

echo "Wygenerowano certs/mssql.pem i certs/mssql.key (dev-only, world-readable)"

# mssql-tests

Środowisko testowe Microsoft SQL Server (Docker Compose). Dwie instancje:

| Instancja      | Port | TLS                           | Użycie                                     |
|----------------|------|-------------------------------|--------------------------------------------|
| `mssql`        | 1434 | brak `force_encryption`       | Plain / REQUIRE z trustServerCertificate=true |
| `mssql-tls`    | 1435 | `force_encryption=1` + cert   | Test VERIFY_FULL z user-provided CA        |

## Struktura

```
├── docker-compose.yml   # Definicja serwisów MSSQL (plain + tls), init i SSH
├── mssql-tls.conf       # Konfiguracja MSSQL z force_encryption=1
├── certs/
│   ├── generate.sh      # Generator self-signed cert + key (dev-only)
│   └── .gitignore       # mssql.pem / mssql.key
├── ssh/Dockerfile       # Obraz kontenera SSH (Alpine + OpenSSH)
└── init/01-init.sql     # Skrypt inicjalizujący bazę danych
```

## Wymagania

- Docker + Docker Compose
- `openssl` (do wygenerowania self-signed certu)

## Uruchomienie

```bash
# 1. Wygeneruj cert (raz, przed pierwszym up)
./certs/generate.sh

# 2. Postaw środowisko
docker compose up -d
```

`mssql-init` / `mssql-tls-init` uruchomią się po starcie odpowiednich instancji, utworzą bazę `devdb`, użytkownika `testuser` oraz przykładową tabelę, i wyłączą się.

## Połączenie z bazą danych

### Plain MSSQL (port 1434) — bez wymuszonego TLS

```bash
sqlcmd -S 127.0.0.1,1434 -U testuser -P 'TestPass123!' -d devdb -C
```

### MSSQL z `force_encryption=1` (port 1435)

```bash
# DISABLE — odrzucone przez serwer
sqlcmd -S 127.0.0.1,1435 -U testuser -P 'TestPass123!' -d devdb -N optional -C

# REQUIRE — encrypt + trust (akceptuje self-signed)
sqlcmd -S 127.0.0.1,1435 -U testuser -P 'TestPass123!' -d devdb -N true -C

# VERIFY_FULL — encrypt bez trust; bez certu w truststore = fail
sqlcmd -S 127.0.0.1,1435 -U testuser -P 'TestPass123!' -d devdb -N true

# VERIFY_FULL z certem w systemowym truststore
sudo cp certs/mssql.pem /usr/local/share/ca-certificates/mssql-tls-test.crt
sudo update-ca-certificates
sqlcmd -S 127.0.0.1,1435 -U testuser -P 'TestPass123!' -d devdb -N true
```

> Uwaga: cert ma `CN=mssql-tls` z SAN `localhost,127.0.0.1`, więc weryfikacja pełnego hostname zadziała przy łączeniu się przez `127.0.0.1` lub `localhost`.

### Przez tunel SSH (do plain `mssql`)

#### 1. Otwórz tunel SSH (terminal 1)

```bash
ssh -L 1433:mssql:1433 tunnel@192.168.10.226 -p 2225
```

Hasło: `tunnel`

#### 2. Połącz się przez tunel (terminal 2)

```bash
sqlcmd -S 127.0.0.1,1433 -U testuser -P 'TestPass123!' -d devdb -C
```

## Dane dostępowe

| Parametr               | Wartość                                  |
|------------------------|------------------------------------------|
| Plain MSSQL host:port  | `127.0.0.1:1434`                         |
| TLS MSSQL host:port    | `127.0.0.1:1435`                         |
| Baza danych            | `devdb`                                  |
| SA hasło               | `RootPass123!`                           |
| Użytkownik             | `testuser`                               |
| Hasło                  | `TestPass123!`                           |
| SSH user               | `tunnel`                                 |
| SSH hasło              | `tunnel`                                 |
| SSH port               | `2225`                                   |

## Inicjalizacja bazy

Przy pierwszym uruchomieniu kontenery `mssql-init` / `mssql-tls-init` automatycznie tworzą bazę `devdb`, użytkownika `testuser` oraz tabelę `testowa` z przykładowymi danymi (skrypt `init/01-init.sql`).

## Regeneracja certu

Cert ważny 365 dni. Po wygaśnięciu:

```bash
./certs/generate.sh
docker compose restart mssql-tls
```

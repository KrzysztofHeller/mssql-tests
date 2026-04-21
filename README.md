# mssql-tests

Środowisko testowe Microsoft SQL Server z dostępem przez tunel SSH (Docker Compose).

## Struktura

```
├── docker-compose.yml    # Definicja serwisów MSSQL, init i SSH
├── ssh/Dockerfile        # Obraz kontenera SSH (Alpine + OpenSSH)
└── init/01-init.sql      # Skrypt inicjalizujący bazę danych
```

## Wymagania

- Docker + Docker Compose

## Uruchomienie

```bash
docker compose up -d
```

Serwis `mssql-init` uruchomi się po starcie MSSQL, utworzy bazę `devdb`, użytkownika `testuser` oraz przykładową tabelę, a następnie wyłączy się.

## Połączenie z bazą danych

### Bezpośrednio (bez proxy)

```bash
sqlcmd -S 127.0.0.1,1434 -U testuser -P 'TestPass123!' -d devdb -C
```

### Przez tunel SSH

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

| Parametr     | Wartość                                  |
|--------------|------------------------------------------|
| Host MSSQL   | `mssql` (wewnątrz sieci Docker)          |
| Port MSSQL   | `1433` (wewnętrzny) / `1434` (bezpośredni) |
| Baza danych  | `devdb`                                  |
| SA hasło     | `RootPass123!`                           |
| Użytkownik   | `testuser`                               |
| Hasło        | `TestPass123!`                           |
| SSH user     | `tunnel`                                 |
| SSH hasło    | `tunnel`                                 |
| SSH port     | `2225`                                   |

## Inicjalizacja bazy

Przy pierwszym uruchomieniu kontener `mssql-init` automatycznie tworzy bazę `devdb`, użytkownika `testuser` oraz tabelę `testowa` z przykładowymi danymi (skrypt `init/01-init.sql`).
# CardoO — End-to-End IoT Demo

An ESP32 (simulated in Wokwi) reads a DHT22 sensor every 3 seconds and POSTs the temperature + humidity to a NestJS backend, which persists to PostgreSQL and pushes the new reading over WebSocket. A Flutter app fetches the latest reading via REST, subscribes to the WebSocket stream for live updates, and renders a dual-line chart of recent history.

## Architecture

```
┌────────────────┐   HTTP POST /readings    ┌──────────────────┐
│ ESP32 + DHT22  │ ───────────────────────▶ │   NestJS API     │
│ (Wokwi cloud)  │   every 3s, JSON         │  /readings       │
└────────────────┘                          │  /readings/latest│
                                            │  /readings?limit │
                                            │  /api (Swagger)  │
                                            │  WS /readings    │
                                            └─────────┬────────┘
                                                      │ TypeORM
                                                      ▼
                                            ┌──────────────────┐
                                            │   PostgreSQL     │
                                            └──────────────────┘
                                                      ▲
                            GET + WS subscribe        │
┌────────────────┐ ◀───────────────────────────────────┘
│  Flutter app   │
│  (Riverpod)    │
│  Home + Chart  │
└────────────────┘
```

## Live demo

- **Wokwi project**: https://wokwi.com/projects/467436659652575233

## Repo layout

```
backend/      NestJS + TypeORM + Postgres + Socket.IO + Swagger
flutter_app/  Flutter app (Riverpod, Dio, fl_chart, socket_io_client)
wokwi/        ESP32 Arduino sketch + Wokwi diagram
```

## Quick start

### 1) Run the backend locally with Docker

```bash
docker compose up --build
# API:     http://localhost:3000
# Swagger: http://localhost:3000/api
```

Seed the database with 50 synthetic rows (so the chart isn't empty on first run):

```bash
docker exec -it cardoo-api npm run seed
```

### 2) Expose the local backend so Wokwi can reach it

Wokwi runs in the cloud and cannot reach `localhost` directly. Use **bore** (free, raw TCP — no HTTPS redirect or proxy timeout):

```bash
brew install bore-cli          # one-time install
bore local 3000 --to bore.pub  # prints "listening at bore.pub:<PORT>"
```

Paste `http://bore.pub:<PORT>` into:
- `wokwi/sketch.ino` → the `BACKEND_URL` `#define`
- The Flutter launch command → `--dart-define=API_BASE_URL=http://bore.pub:<PORT>`

> **Note**: bore assigns a random port each session. Update both files when you restart the tunnel.

### 3) Run the Wokwi simulation

1. Open https://wokwi.com → New project → ESP32.
2. Replace `sketch.ino` with [`wokwi/sketch.ino`](wokwi/sketch.ino).
3. Open the `diagram.json` panel and paste [`wokwi/diagram.json`](wokwi/diagram.json).
4. Click **Library Manager** and add `DHT sensor library` and `ArduinoJson` (see [`wokwi/libraries.txt`](wokwi/libraries.txt)).
5. Edit the `BACKEND_URL` `#define` at the top of `sketch.ino` to `http://bore.pub:<PORT>/readings`.
6. Click **Play**. The serial monitor should show `POST 201` every 3 seconds.

### 4) Run the Flutter app

```bash
cd flutter_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=API_BASE_URL=http://bore.pub:<PORT>
```

The Home tab shows large temperature + humidity cards with a "last updated" label and a connection chip (green = WebSocket live). The History tab shows a dual-line chart of the last 50 readings.

## API reference

| Method | Path                  | Body / Query                                                            | Response                       |
| ------ | --------------------- | ----------------------------------------------------------------------- | ------------------------------ |
| `POST` | `/readings`           | `{ "deviceId": "...", "temperature": 24.7, "humidity": 58.3 }`          | `201` saved row                |
| `GET`  | `/readings/latest`    | —                                                                       | most recent row (`404` if none) |
| `GET`  | `/readings?limit=50`  | `limit` 1–500, default 50                                               | array of rows desc by time     |
| `GET`  | `/health`             | —                                                                       | `{ "status": "ok" }`           |
| `WS`   | `/` (Socket.IO)       | subscribe to event `reading:new`                                        | emits saved row on every POST  |

Full schema at `http://localhost:3000/api` (Swagger UI).

## Tech stack

- **Firmware**: Arduino C++, `WiFi`, `HTTPClient`, `DHT sensor library`, `ArduinoJson`
- **Backend**: NestJS 10, TypeORM, PostgreSQL 16, Socket.IO, Swagger, class-validator, Joi, Helmet
- **Mobile**: Flutter 3, Riverpod 2, Dio, freezed, fl_chart, socket_io_client
- **Infra**: Docker + Docker Compose, bore

# CardoO Flutter app

Live IoT dashboard for the CardoO NestJS backend.

## First-time setup

Flutter projects need platform shells (android/, ios/, web/, ...) that aren't in this repo. Generate them in-place:

```bash
cd flutter_app
flutter create . --org com.cardoo --platforms=ios,android,web,macos
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates *.freezed.dart and *.g.dart
```

## Run

Point at the bore tunnel (start with `bore local 3000 --to bore.pub`, note the port):

```bash
flutter run --dart-define=API_BASE_URL=http://bore.pub:<PORT>
```

For desktop / web local dev (same machine as Docker), `http://localhost:3000` works.

## How it works

- `core/api/api_client.dart` — Dio with `Env.apiBaseUrl` as base
- `core/api/ws_client.dart` — Socket.IO; exposes a `Reading` stream and a connection-state stream
- `features/readings/application/latest_reading_provider.dart` — Riverpod `AsyncNotifier` that bootstraps via REST, then merges WS push events, with a 5 s polling fallback
- `features/readings/application/readings_history_provider.dart` — invalidates whenever a new reading lands
- `presentation/home_page.dart` — big cards for temp + humidity, connection chip
- `presentation/history_page.dart` — dual-line `fl_chart` of the last 50 readings

# Wokwi — ESP32 + DHT22

This folder holds the source for the simulated firmware. Wokwi runs in the browser/cloud, so the ESP32 needs a public URL to reach your local backend. We use **bore** for a plain TCP tunnel (no HTTPS required).

## Files

- `sketch.ino` — the Arduino sketch (WiFi + DHT22 read + HTTP POST every 3 s)
- `diagram.json` — the Wokwi wiring (ESP32 DevKit C v4 + DHT22 on GPIO 15)
- `libraries.txt` — the Arduino libraries to add via Wokwi Library Manager

## Setup

1. Go to https://wokwi.com → **New Project** → **ESP32**.
2. Click the file tab `sketch.ino` and paste the contents of [`sketch.ino`](sketch.ino).
3. Click the file tab `diagram.json` and paste the contents of [`diagram.json`](diagram.json).
4. Open the **Library Manager** (cube icon in the left bar) and add each library listed in [`libraries.txt`](libraries.txt).
5. Start a bore tunnel and note the port:
   ```bash
   brew install bore-cli          # one-time
   bore local 3000 --to bore.pub  # prints "listening at bore.pub:<PORT>"
   ```
   Edit the `BACKEND_URL` `#define` at the top of `sketch.ino`:
   ```cpp
   #define BACKEND_URL "http://bore.pub:<PORT>/readings"
   ```
   > Wokwi's ESP32 simulation does not support TLS, so use plain `http://` (not https). bore provides raw TCP with no HTTPS redirect.
6. Click **Save** → copy the project URL into the top-level `README.md`.
7. Click **Play**. The serial monitor should show:
   ```
   WiFi: connecting to Wokwi-GUEST
   .....
   WiFi: connected, IP=10.13.37.2
   DHT22: 24.0°C  58.0%
   POST 201  body={"deviceId":"esp32-wokwi-1","temperature":24,"humidity":58}
   ```

## Tweaking the simulated sensor

Click the DHT22 part in the diagram and use the sliders to change temperature / humidity at runtime — the Flutter app will pick the new value up within ~3 seconds.

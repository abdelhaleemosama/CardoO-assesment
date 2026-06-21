// CardoO IoT — ESP32 + DHT22 → NestJS backend
//
// Setup:
//   1) Start bore tunnel: bore local 3000 --to bore.pub
//      Note the port printed, e.g. "listening at bore.pub:26912"
//   2) Replace BACKEND_URL below with http://bore.pub:<PORT>/readings
//   3) Use the Wokwi Library Manager to install:
//        - DHT sensor library (by Adafruit)
//        - Adafruit Unified Sensor
//        - ArduinoJson
//   4) Click Play. The serial monitor should show "POST 201" every 3 seconds.

#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>
#include <ArduinoJson.h>

// ---------- CONFIG ----------
#define WIFI_SSID     "Wokwi-GUEST"
#define WIFI_PASSWORD ""                               // open network on Wokwi
#define BACKEND_URL   "http://bore.pub:26912/readings" // <-- replace port each session
#define DEVICE_ID     "esp32-wokwi-1"

#define DHT_PIN  15
#define DHT_TYPE DHT22

const unsigned long POST_INTERVAL_MS = 3000;
// ----------------------------

DHT dht(DHT_PIN, DHT_TYPE);
unsigned long lastPost = 0;

void connectWiFi() {
  Serial.print("WiFi: connecting to ");
  Serial.println(WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(250);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("WiFi: connected, IP=");
  Serial.println(WiFi.localIP());
}

void postReading(float temperature, float humidity) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi: lost, skipping POST");
    return;
  }

  HTTPClient http;
  http.begin(BACKEND_URL);
  http.addHeader("Content-Type", "application/json");

  StaticJsonDocument<192> doc;
  doc["deviceId"]    = DEVICE_ID;
  doc["temperature"] = temperature;
  doc["humidity"]    = humidity;

  String body;
  serializeJson(doc, body);

  int code = http.POST(body);
  Serial.printf("POST %d  body=%s\n", code, body.c_str());
  if (code <= 0) {
    Serial.printf("HTTP error: %s\n", http.errorToString(code).c_str());
  }
  http.end();
}

void setup() {
  Serial.begin(9600);
  delay(200);
  Serial.println("\nCardoO ESP32 boot");
  dht.begin();
  connectWiFi();
}

void loop() {
  unsigned long now = millis();
  if (now - lastPost < POST_INTERVAL_MS) {
    delay(50);
    return;
  }
  lastPost = now;

  float h = dht.readHumidity();
  float t = dht.readTemperature();

  if (isnan(h) || isnan(t)) {
    Serial.println("DHT22: read failed");
    return;
  }

  Serial.printf("DHT22: %.1f°C  %.1f%%\n", t, h);
  postReading(t, h);
}

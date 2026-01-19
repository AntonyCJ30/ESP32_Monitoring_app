#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define DEVICE_NAME "CJBLE"

// Nordic UART Service UUIDs
#define SERVICE_UUID           "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_RX_UUID "6E400002-B5A3-F393-E0A9-E50E24DCCA9E" // Flutter → ESP32
#define CHARACTERISTIC_TX_UUID "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" // ESP32 → Flutter

BLECharacteristic *txChar;
bool deviceConnected = false;

// -------- Server Callbacks --------
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    Serial.println("✅ Device Connected");
  }

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    Serial.println("❌ Device Disconnected");
    BLEDevice::startAdvertising();
  }
};

// -------- RX Callbacks --------
class RXCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pChar) {

    String rxValue = pChar->getValue();   // ✅ Arduino String

    if (rxValue.length() > 0) {
      Serial.print("📥 From Flutter: ");
      Serial.println(rxValue);

      // Echo back to Flutter
      if (deviceConnected) {
        txChar->setValue(rxValue);   // ✅ accepts String
        txChar->notify();
      }
    }
  }
};

void setup() {
  Serial.begin(115200);

  BLEDevice::init(DEVICE_NAME);
  BLEServer *server = BLEDevice::createServer();
  server->setCallbacks(new MyServerCallbacks());

  BLEService *service = server->createService(SERVICE_UUID);

  // TX → Notify
  txChar = service->createCharacteristic(
    CHARACTERISTIC_TX_UUID,
    BLECharacteristic::PROPERTY_NOTIFY
  );
  txChar->addDescriptor(new BLE2902());

  // RX → Write
  BLECharacteristic *rxChar = service->createCharacteristic(
    CHARACTERISTIC_RX_UUID,
    BLECharacteristic::PROPERTY_WRITE
  );
  rxChar->setCallbacks(new RXCallbacks());

  service->start();

  BLEAdvertising *advertising = BLEDevice::getAdvertising();
  advertising->addServiceUUID(SERVICE_UUID);
  advertising->setScanResponse(true);

  BLEDevice::startAdvertising();

  Serial.println("🚀 BLE UART Peripheral Started");
}

void loop() {
  static int count = 0;

  if (deviceConnected) {
    String msg = "ESP32 Count: " + String(count++);
    txChar->setValue(msg);
    txChar->notify();
    delay(2000);
  }
}

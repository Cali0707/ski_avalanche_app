
#include <ArduinoBLE.h>
BLEService newService("180A"); // creating the service

BLEByteCharacteristic startMotor("2A57", BLERead | BLEWrite); // creating the motor characteristic

const int motorPin = 2;
long previousMillis = 0;

//UUID = 8907AC3A-59C7-8664-7C62-250CE527A168

void setup() {
  Serial.begin(9600);    // initialize serial communication

  pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin to indicate when a central is connected
  pinMode(motorPin, OUTPUT); // initialize the motor pin to allow us to control the motor

  //initialize BLE library
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }

  BLE.setLocalName("MKR WiFi 1010"); //Setting a name that will appear when scanning for bluetooth devices
  BLE.setAdvertisedService(newService);

  newService.addCharacteristic(startMotor); //add characteristics to a service

  BLE.addService(newService);  // adding the service

  startMotor.writeValue(0); //set initial value for characteristics

  BLE.advertise(); //start advertising the service
  Serial.println("Bluetooth device active, waiting for connections...");
}

void loop() {

  BLEDevice central = BLE.central(); // wait for a BLE central

  if (central) {  // if a central is connected to the peripheral
    Serial.print("Connected to central: ");

    Serial.println(central.address()); // print the central's BT address

    digitalWrite(LED_BUILTIN, HIGH); // turn on the LED to indicate the connection

    // while the central is connected:
    while (central.connected()) {
      long currentMillis = millis();

      if (currentMillis - previousMillis >= 200) {
        previousMillis = currentMillis;

        if (startMotor.written()) {
          if (startMotor.value()) {   // any value other than 0
            Serial.println("LED on");
            digitalWrite(motorPin, HIGH);         // will turn the motor on
          } else {                              // a 0 value
            Serial.println(F("LED off"));
            digitalWrite(motorPin, LOW);          // will turn the motor off
          }
        }

      }
    }

    digitalWrite(LED_BUILTIN, LOW); // when the central disconnects, turn off the LED
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}

#include "Apb.h"


const int ssPin = 52;

long serial_command = 1000;

// Create Apb object
Apb apb(ssPin);

void serialFlush(){
  while(Serial.available() > 0) {
    char t = Serial.read();
  }
}

void setup() {
  // Start SPI
  apb.setup();
  apb.write(10,serial_command);
  // initialize serial communication:
  Serial.begin(9600);
}

void loop() {
  //long readVal = apb.read(20);
  //apb.write(10,1000);
  //delay(1000);

  // see if there's incoming serial data:
  delay(500);
  if (Serial.available() > 0) {
    // read the oldest byte in the serial buffer:
    serial_command = Serial.parseInt();
    serialFlush();
    //Serial.write(serial_command);
    apb.write(10,serial_command);
    delay(500);
  }
  //delay(5000);
}

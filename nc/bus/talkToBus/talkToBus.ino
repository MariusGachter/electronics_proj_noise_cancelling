#include "Apb.h"


const int ssPin = 52;

// Create Apb object
Apb apb(ssPin);

void setup() {
  // Start SPI
  apb.setup();
}

void loop() {
  long readVal = apb.read(20);
  apb.write(10,1000);
  delay(1000);
}

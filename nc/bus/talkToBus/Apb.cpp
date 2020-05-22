/*
  Apb.c - Library for using APB
  Created by Yves Acremann
  Edited by Simon Däster
  Released into the public domain.
*/

#include "Apb.h"

Apb::Apb(int ssPin) {

  pinMode (ssPin, OUTPUT);
  _pin = ssPin;
}

void Apb::setup() {
  digitalWrite(_pin,HIGH);
  SPI.begin();
  SPI.setDataMode(SPI_MODE0);
  // SPI.setClockDivider(15);
  SPI.setBitOrder(MSBFIRST);
  Serial.begin(115200);
}



unsigned int Apb::read(int address) {
  // convert the address:
  int addrMsb = address / 256;
  int addrLsb = address % 256;
  
  // now send the request:
  digitalWrite(_pin,LOW);
  SPI.transfer(addrMsb);
  SPI.transfer(addrLsb);
  // read and perform bit shifts
  unsigned long result1 = SPI.transfer(0x00) << 24;
  unsigned long result2 = SPI.transfer(0x00) << 16;
  unsigned long result3 = SPI.transfer(0x00) << 8;
  unsigned long result4 = SPI.transfer(0x00);
  digitalWrite(_pin,HIGH);
  
  return (result4 | result3 | result2 | result1);
}

void Apb::write(int address, unsigned long data) {
  // convert the address:
  // set the write bit
  int addrMsb = (address / 256) | 0x80;
  int addrLsb = address % 256;

  // convert the data into individual bytes:
  int dataMsb =  data >> 24;
  int data2   = (data >> 16) & 0xff;
  int data3   = (data >>  8) & 0xff;
  int dataLsb = data & 0xff;
  // now send the request:
  digitalWrite(_pin,LOW);
  SPI.transfer(addrMsb);
  SPI.transfer(addrLsb);
  SPI.transfer(dataMsb);
  SPI.transfer(data2);
  SPI.transfer(data3);
  SPI.transfer(dataLsb);
  digitalWrite(_pin,HIGH);
}

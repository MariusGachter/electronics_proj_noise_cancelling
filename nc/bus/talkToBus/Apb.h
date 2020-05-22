/*
  Apb.h - Library for using APB.
  Created by Yves Acremann
  Edited by Simon Däster
  Released into the public domain.
*/
#ifndef Apb_h
#define Apb_h

#include <SPI.h>
#include "Arduino.h"

class Apb
{
  public:
    Apb(int ssPin);
    void setup();
    unsigned int read(int address);
    void write(int address, unsigned long data);
  private:
    int _pin;
};

#endif

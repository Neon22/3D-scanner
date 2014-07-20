#include <Stepper.h>
Stepper mitsumi(48,7,8,9,10);        // 7.5 deg step for the Mitsumi scanner motor or 360/7.5 = 48 steps per rev
const int laser = 11;                // laser pin, use a PWM
//int laser_on = 0;                    // keep off unless turned on, and keep on unless turned off
int incomingByte;                    // a variable to read incoming serial data into

// 15360 steps per full external plate revolution using said motor, indicates 320:1 gearing. Your gearing will be different.

void setup() {
  Serial.begin(9600);
  pinMode(laser, OUTPUT);
  mitsumi.setSpeed(192);             // sets 4 revs per second of stepper. Possibly too fast... Seems stable
}

void loop() {
  
  analogWrite(laser, int(analogRead(A0) / 4) );    // We always want an updated laser power rating, so it goes here
  
  if (Serial.available() > 0) {                    // read the oldest byte in the serial buffer:
    incomingByte = Serial.read();
    
    if (incomingByte == 'F') {
      mitsumi.step(32);             // F is forward ~ 128 is 3deg on the big platter
      Serial.print('.');
    }
    
    if (incomingByte == 'R') { 
      mitsumi.step(-32);            //R is reverse
      Serial.print('.');
      }
      
//    if (incomingByte == 'l') {     //This layer is breaking on first scan from Processing, so for time we are turning it off and forcing laser on
//      digitalWrite(laser, LOW);    // turns laser off
//      laser_on = 0;
//      delay(20);
//      Serial.print('.');
//      }
//    if (incomingByte == 'L') {
//      analogWrite(laser, int(analogRead(A0) / 4 );     //turns laser on and sets value of laser to analog pin A0
//      laser_on = 1;
//      delay(20);                                       //eventually I want some sort of auto-calibration
//      Serial.print(laser_strength);
//      }
  }
}

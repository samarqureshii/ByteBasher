#include <Arduino.h>

void readDistance(int, int, int);

void setup() {

}

void loop() {
  //loop through all 9 squares in the 3 by 3 grid (using only 6 ultrasonic sensors)
  for(int i = 0; i<3; i++){
    for(int j = 0; j<3;j++){

    }
  }
}

void readDistance(int trigPin, int echoPin, int sensorNum) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  long duration = pulseIn(echoPin, HIGH);
  double distance = duration * 0.034 / 2; // 34m/s at 20 degrees C

  //serial monitor output
  Serial.print("Sensor ");
  Serial.print(sensorNum);
  Serial.print(": Distance = ");
  Serial.print(distance);
  Serial.println(" cm");
}

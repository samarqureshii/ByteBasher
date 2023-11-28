#include <Arduino.h>

// put function declarations here:
int myFunction(int, int);

void setup() {
  // put your setup code here, to run once:
  int result = myFunction(2, 3);
}

void loop() {
  // put your main code here, to run repeatedly:
}

// put function definitions here:
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
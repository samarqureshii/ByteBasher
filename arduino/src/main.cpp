#include <Arduino.h>
//OUTPUT SIGNALS (first to detect, needs to be detected for x consecutive seconds)
//0000 - nothing detected 
//0001 - box 1
//0010 - box 2
//0011 - box 3
//0100 - box 4
//0101 - box 5
//0110 - box 6
//0111 - box 7
//1000 - box 8
//1001 - box 9

double readDistance(int, int, int);
void enableLED(int);
/*** SEE CARDBAORD FOR SENSOR LABELLING ***/
//sensor 1
const int trig1 = 9;
const int echo1 = 8;
//sensor 2
const int trig2 = 11;
const int echo2 = 10;
//sensor 3
const int trig3 = 7;
const int echo3 = 6;
//sensor 4
const int trig4 = 5;
const int echo4 = 4;

//binary representation of the signal 

const int led3 = 13;
const int led1 = 3;
const int led2 = 2; //LSB


//board dimensions
const int height = 30;
const int width = 38;

//each small box is 10 cm by 13 cm 


void setup() { //pinmode
  // put your setup code here, to run once:
  //leds in 0,1,2,3
  pinMode(led1, OUTPUT);
  pinMode(led2, OUTPUT);
  pinMode(led3, OUTPUT);

  //trig echo in pairs from 4,5,6,7,8,9,10, 11
  pinMode(trig1, OUTPUT);
  pinMode(trig2, OUTPUT);
  pinMode(trig3, OUTPUT);
  pinMode(trig4, OUTPUT);

  pinMode(echo1, INPUT);
  pinMode(echo2, INPUT);
  pinMode(echo3, INPUT);
  pinMode(echo4, INPUT);

  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:
//  digitalWrite(led1, HIGH);
//  digitalWrite(led2, HIGH);
//  digitalWrite(led3, HIGH);
//  digitalWrite(led4, HIGH);
//  delay(1000);
//    digitalWrite(led1, LOW);
//  digitalWrite(led2, LOW);
//  digitalWrite(led3, LOW);
//  digitalWrite(led4, LOW);
  


  //box 1
  if(readDistance(trig1, echo1, 1) <= 10 && 
    readDistance(trig3, echo3, 3) <= 13){ 
      //box 1 (only sensor 1 and 3 need to be high, and contained to the distance of their box)
    Serial.println("Box 1 Hit (0001)");
    enableLED(1); //box 1 LED representation 0001
  }
  

  //box 2

  else if(readDistance(trig2, echo2, 2) <=10 && readDistance(trig3, echo3, 3) > 13){ //box 2
    Serial.println("Box 2 Hit (0010)");
    enableLED(2);//box 2 LED representation 0010
  }

  //box 3

  //box 4
  else if(readDistance(trig4, echo4, 4) <=13 && 
  readDistance(trig1,echo1, 1) > 10){
    Serial.println("Box 3 Hit (0011)");
    enableLED(3);
  }

  //box 5

  else if(readDistance(trig2, echo2, 2) > 10 && readDistance(trig4, echo4, 4) > 13 && readDistance(trig4, echo4, 4) <=26){
    Serial.println("Box 4 Hit (0100)");
    enableLED(4);
  }

  //box 6

  //box 7

  //box 8

  //box 9

  else{ //no detection
    Serial.println("No Box hit");
    digitalWrite(led1, LOW);
    digitalWrite(led2, LOW);
    digitalWrite(led3, LOW);
  }

  delay(2);
}

// put function definitions here:
double readDistance(int trigPin, int echoPin, int sensorNum) {
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

  return distance;
}

void enableLED(int box) {
  // convert the box number to binary and output the signal on LEDs
  if(box == 1){ //binary 010
     digitalWrite(led1, LOW);
     digitalWrite(led2, HIGH);
     digitalWrite(led3, LOW);

  }

  else if(box == 2){ //binary 011
     digitalWrite(led1, HIGH);
     digitalWrite(led2, HIGH);
     digitalWrite(led3, LOW);

  }

  
  else if(box == 3){ //binary 100
     digitalWrite(led1, LOW);
     digitalWrite(led2, LOW);
     digitalWrite(led3, HIGH);

  }

  else if(box == 4){ //binary 0101
     digitalWrite(led1, HIGH);
     digitalWrite(led2, LOW);
     digitalWrite(led3, HIGH);
    
  }
//  digitalWrite(led1, (box >> 3) & 1);
//  digitalWrite(led2, (box >> 2) & 1);
//  digitalWrite(led3, (box >> 1) & 1);
//  digitalWrite(led4, box & 1);
}
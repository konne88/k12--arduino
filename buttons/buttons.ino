#define RIGHT 2
#define UP 6
#define DOWN 4
#define LEFT 8
#define LED 13

void setup() {
  Serial.begin(9600);
  
  pinmode(LED, OUTPUT);
  pinMode(UP, INPUT);
  pinMode(RIGHT, INPUT);
  pinMode(DOWN, INPUT);
  pinMode(LEFT, INPUT);
  
  int countdown = 0;
}

void loop() {
  
  // if a 1 is read from Serial, 
  // turn on LED. if 0 is read, 
  // turn off LED.
  int inc = Serial.read();
  if (inc == 1) {
    digitalWrite(LED, HIGH);
  } else if (inc == 0) {
    digitalWrite(LED, LOW);
  }


  int upButton = digitalRead(UP);
  int rightButton = digitalRead(RIGHT);
  int downButton = digitalRead(DOWN);
  int leftButton = digitalRead(LEFT);
  
  if(upButton == HIGH) {
    Serial.write(0);
  } else if(rightButton == HIGH) {
    Serial.write(3);
  } else if(downButton == HIGH) {
    Serial.write(1);
  } else if(leftButton == HIGH) {
    Serial.write(2);
  }
}

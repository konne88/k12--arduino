#define RIGHT 2
#define UP 6
#define DOWN 4
#define LEFT 8

void setup() {
  Serial.begin(9600);
  
  pinMode(UP, INPUT);
  pinMode(RIGHT, INPUT);
  pinMode(DOWN, INPUT);
  pinMode(LEFT, INPUT);
}

void loop() {
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

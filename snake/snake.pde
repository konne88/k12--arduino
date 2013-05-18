import processing.serial.*;
import cc.arduino.*;

int PIN_UP = 6;
int PIN_DOWN = 4;
int PIN_LEFT = 8;
int PIN_RIGHT = 2;

int WIDTH = 30;
int HEIGHT = 30;
int SIZE = 14;
Snake snake;
Position food;
Arduino arduino;

void setup() {
  size(WIDTH*SIZE,HEIGHT*SIZE);
  
  snake = new Snake(new Position(WIDTH/2, HEIGHT/2), RIGHT);
  food = new Position(int(random(WIDTH)), int(random(HEIGHT)));

  println(Arduino.list());

  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(PIN_UP, Arduino.INPUT);
  arduino.pinMode(PIN_DOWN, Arduino.INPUT);
  arduino.pinMode(PIN_LEFT, Arduino.INPUT);
  arduino.pinMode(PIN_RIGHT, Arduino.INPUT);
  
  //speed of game
  frameRate(12);
}

void draw() {
  checkArduino();
  fill(0);
  background(255, 255, 255);

  // draw food
  drawBox(food);
  
  for(Position segment : snake.segments) {
    drawBox(segment);
  }
  
  snake.move();
    
  ArrayList<Position> segments = snake.segments;

  Position head = segments.get(0);
 
  // check for collision with wall
  if (head.x < 0 || head.x >= WIDTH || 
      head.y < 0 || head.y >= HEIGHT) {
    exit();
  }

  // check for collision with snake
  for(Position segment : segments.subList(1, segments.size())) {
    if (head.x == segment.x && head.y == segment.y) {
      exit();
    }
  }

  // eat food
  if (head.x == food.x && head.y == food.y) {
    snake.grow = true;
    food = new Position(int(random(WIDTH)), int(random(HEIGHT)));
  }
}

void keyPressed() {
  // only use special keys such as arrow keys
  if(key == CODED) {
    snake.setDirection(keyCode);
  }
}

void checkArduino() {
  if(arduino.digitalRead(PIN_LEFT) == Arduino.HIGH) {
    snake.setDirection(LEFT);
  }
  else if(arduino.digitalRead(PIN_RIGHT) == Arduino.HIGH) {
    snake.setDirection(RIGHT);
  }
  else if(arduino.digitalRead(PIN_UP) == Arduino.HIGH) {
    snake.setDirection(UP);
  }
  else if(arduino.digitalRead(PIN_DOWN) == Arduino.HIGH) {
    snake.setDirection(DOWN);
  }
}

void drawBox(Position position) {
  rect(position.x*SIZE, position.y*SIZE, SIZE, SIZE);
}

// Snake objects 
class Snake {
  private boolean grow;
  private int direction;
  private ArrayList<Position> segments;
  
  Snake(Position headPosition, int direction) {
    segments = new ArrayList<Position>();
    segments.add(headPosition);
    grow = true;
    this.direction = direction;
  }

  void grow() {
    grow = true;
  }

  void move() {
    if(!grow) {
      // remove the tail segment to create movement
      segments.remove(segments.size() - 1);
    }
    grow = false;
    
    Position oldHead = segments.get(0);
    Position head = oldHead.copy();
    if(direction == LEFT) {
      head.x = head.x - 1;
    } else if(direction == RIGHT) {
      head.x = head.x + 1;
    } else if(direction == UP) {
      head.y = head.y - 1;
    } else if(direction == DOWN) {
      head.y = head.y + 1;
    }
    segments.add(0, head);
  }
  
  // Sets the snake's direction; doesn't allow turning on itself.
  void setDirection(int dir) {
    if (dir != opposite(this.direction)) {
      direction = dir;
    }
  }

  int opposite(int dir) {
    if (dir == UP) {
      return DOWN;
    } else if (dir == DOWN) {
      return UP;
    } else if (dir == LEFT) {
      return RIGHT;
    } else if (dir == RIGHT) {
      return LEFT;
    } else {
      // this should never happen
      return 0;
    }
  }
}
  
// Position objects have x and y fields that represent positions in 2D space.
class Position {
  private int x;
  private int y;
  
  Position(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  Position copy() {
    return new Position(this.x, this.y);
  }
}

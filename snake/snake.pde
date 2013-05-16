// import libraries used to talk to the Arduino
import processing.serial.*;

int WIDTH = 20;
int HEIGHT = 20;
int SIZE = 14;
Snake snake;
Position food;
Serial myPort;  

void setup() {
  size(WIDTH*SIZE,HEIGHT*SIZE);
  
  snake = new Snake(new Position(WIDTH/2, HEIGHT/2), RIGHT);
  food = new Position(int(random(WIDTH)), int(random(HEIGHT)));

  myPort = new Serial(this, Serial.list()[1], 9600);
   
  //speed of game
  frameRate(12);
}

void draw() {
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

void serialEvent(Serial myPort) {
  int command = myPort.read();
  int dir;

  if (command == 2) { 
    dir = LEFT;
  } else if (command == 3) { 
    dir = RIGHT;
  } else if (command == 0) { 
    dir = UP;
  } else if (command == 1) { 
    dir = DOWN;
  } else {
    return;
  }

  snake.setDirection(dir);
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


import processing.serial.*;

class Position {
  Position(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  int x;
  int y;
  
  Position copy() {
    return new Position(this.x, this.y);
  }
}

class Snake {
  Snake(Position headPosition, int direction) {
    segments = new ArrayList<Position>();
    segments.add(headPosition);
    grow = true;
    this.direction = direction;
  }

  void grow() {
    this.grow = true;
  }

  void move() {
    if(!grow) {
      segments.remove(segments.size()-1);
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
    segments.add(0,head);
  }

  boolean grow;
  int direction;
  ArrayList<Position> segments;
}

class Game {
  Snake snake;
  Position food;
  int w;
  int h;
  
  Game(int w, int h) {
    this.w = w;
    this.h = h;
    snake = new Snake(new Position(w/2,h/2), RIGHT);
    newFood();
  }
  
  void newFood() {
    food = new Position(int(random(w)),int(random(h)));
  }
  
  int wrap(int n, int b) {
    if(n == b) {
      return 0;
    } 
    if(n == -1) {
      return b-1;
    }
    return n;
  }
  
  boolean move() {
    snake.move();
    
    // wrap snake around screen
    ArrayList<Position> segments = snake.segments;
    for(Position segment : segments) {
      segment.x = wrap(segment.x,w);
      segment.y = wrap(segment.y,h);
    }

    Position head = segments.get(0);
    
    // check for collision
    for(Position segment : segments.subList(1,segments.size())) {
      if (head.x == segment.x && head.y == segment.y) {
        return false;
      }
    }

    // eat food
    if (head.x == food.x && head.y == food.y) {
      snake.grow = true;
      newFood();
    }
    
    return true;
  }
}

void drawBox(Position position) {
  rect(position.x*SIZE,position.y*SIZE,SIZE,SIZE);
}

int WIDTH = 50;
int HEIGHT = 50;
int SIZE = 14;
Game game;
Serial myPort;  

void setup()
{
  size(WIDTH*SIZE,HEIGHT*SIZE);
  game = new Game(WIDTH,HEIGHT);

//  String portName = Serial.list()[0];
//  myPort = new Serial(this, portName, 9600);
   
  //speed of game
  frameRate(12);
}

void draw()
{
  fill(0);
  background(255,255,255);

  // draw food
  drawBox(game.food);
  
  for(Position segment : game.snake.segments) {
    drawBox(segment);
  }
  
  if(!game.move()) {
    exit();
  };
}

void keyPressed()
{
  if(key==CODED) {
    game.snake.direction = keyCode;
  }
}

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
//  int inByte = myPort.read();
//   if (inByte == '1') { 
 //    dir=0;
  // }
    //  myPort.clear();  
//       if (inByte == '2') { 
 //    dir=3;
 //  }
 //  if (inByte == '3') { 
 //    dir=2;
 //  }
 //  if (inByte == '4') { 
  //   dir=1;
  // }
}


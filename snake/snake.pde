// import libraries to talk to the Arduino
import processing.serial.*;
import cc.arduino.*;

// The arduino pins used to change the snake's direction
int PIN_UP = 6;
int PIN_DOWN = 4;
int PIN_LEFT = 8;
int PIN_RIGHT = 2;

// The number of columns in the game board.
int WIDTH = 30;

// The size of each square in the game board.
int HEIGHT = 30;
int SIZE = 14;

// The Snake that moves around the board.  The snake is made
// up of squares in the game board.  Each square is represented
// by a Position, which includes an (x, y) = (column, row) coordinate.
Snake snake;

// The single piece of food on the game board.  The piece of food
// is also represented by an (x, y) coordinate.
Position food;

// The arduino that we want to talk to.
Arduino arduino;

// This sets up the pieces of the game, that is, the board itself,
// the snake, and a single piece of food.
void setup() {
  size(WIDTH*SIZE,HEIGHT*SIZE);
  
  // Put the snake on the board, with the head in the very
  // middle of the board, and initial direction RIGHT.
  snake = new Snake(new Position(WIDTH/2, HEIGHT/2), RIGHT);
  
  // Put a single piece of food on the board, at a random
  // location.
  food = new Position(int(random(WIDTH)), int(random(HEIGHT)));

  // Connect to the arduino
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(PIN_UP, Arduino.INPUT);
  arduino.pinMode(PIN_DOWN, Arduino.INPUT);
  arduino.pinMode(PIN_LEFT, Arduino.INPUT);
  arduino.pinMode(PIN_RIGHT, Arduino.INPUT);
  
  //speed of game
  frameRate(12);
}

// This draws the game on the screen. It also moves the snake, and
// is responsible for killing the snake if the player loses the game.
void draw() {
  checkArduino();
  fill(0);
  background(255, 255, 255);

  // draw food
  drawBox(food);
  
  // draw the snake, body segment by body segment
  for(Position segment : snake.segments) {
    drawBox(segment);
  }
  
  snake.move();
    
  // Get the coordinates of the snake body as a list.
  ArrayList<Position> segments = snake.segments;

  // The head is the first coordinate in the list.
  Position head = segments.get(0);
 
  // Check for a collision with the wall.  This occurs
  // when the head moves past the boundaries of the board.  We
  // exit the game when this happens.
  if (head.x < 0 || head.x >= WIDTH || 
      head.y < 0 || head.y >= HEIGHT) {
    exit();
  }

  // Check for a collision with the snake itself.  This
  // occurs when the head has the same coordinates as a body segment.
  // We exit the game when this happens.
  for(Position segment : segments.subList(1, segments.size())) {
    if (head.x == segment.x && head.y == segment.y) {
      exit();
    }
  }

  // Check for eating food.  This occurs when the head has the same
  // coordinates as the single piece of food on the board.  In this case,
  // we grow the snake and put a new piece of food on the board.
  if (head.x == food.x && head.y == food.y) {
    snake.grow = true;
    food = new Position(int(random(WIDTH)), int(random(HEIGHT)));
  }
}

// This takes input from the keyboard and sets the direction
// of the snake accordingly.
void keyPressed() {
  // only use special keys such as arrow keys
  if(key == CODED) {
    snake.setDirection(keyCode);
  }
}

// This takes input from the Arduino keys and sets the direction
// of the snake accordingly.
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

// This class represents the snake itself.  The snake is made up of body
// segment squares at Position positions (as described above, a Position object
// represents a square in the window grid with an (x, y) coordinate).  The relevant
// information stored in the Snake is as follows:
//   direction: the direction the snake is moving (valid values are UP, DOWN, LEFT, RIGHT)
//   grow: whether or not to add another body segment on the next move.  we always grow on
//         the first move so the snake has at least one segment.
//   segments: a list of the coordinates in the snake body. the first segment
//             in the list is the snake head, and the last is the tail.
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

  // Sets the grow field in the snake to true, indicating the snake should grow on the
  // next move.
  void grow() {
    grow = true;
  }
  
  // Moves the snake one square.
  void move() {
    // If we aren't supposed to grow on the next move, remove the segment at the tail.
    // Now our snake has size one less than it did before.
    if(!grow) {
      // remove the tail segment to create movement
      segments.remove(segments.size() - 1);
    }    
    // If we are supposed to grow, we leave the tail square alone.  We still have a snake
    // of the same size as before.

    // Save the position of the current head, since we're going to add a new head, and
    // the hold head will become the body segment right next to the head.
    Position oldHead = segments.get(0);
    
    // The new head will be either one square above, below, right, or left
    // of the old head.  This is decided based on the direction.  Here, we
    // calculate the coordinates of the new head based on the coordinates
    // of the old head.
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
    
    // We've completed a single grow, so now we can set grow to false.
    grow = false;
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
  
// This class represents coordinate positions in the Snake window.  The snake
// window is a grid of squares, where x represents the column of the square, and y
// represents the row of the square.  For example, if the window is 21 rows by 21 columns,
// the square (x, y) = (10, 10) is located in the middle of the board,
// and the square (x, y) = (0, 0) is located at the top left corner
// of the board.
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

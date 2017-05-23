import processing.serial.*;

Serial myPort;        //  The serial port
float potVal = 10;         //  holds the given value of the potentiometer 
int x = 0;            //  Ship's X location
int y;                //  How far from the bottom is the ship
int points = 0;       //  Number of the shooted asteroids
int bgY = 0;          //  For the illusion of moving background
int bgSpeed = 2;      //  Speed of the moving background
int time = 60;        //  How ofthen to spawn an asteroid
int lifes = 5;        //  Ship's lifes
int shipDiameter = 80;
PImage spaceship;
PImage bgc;
PImage lasershot;
PImage asteroidImg;
ArrayList laserShots = new ArrayList();  //  Holds the array of asteroids
ArrayList asteroids = new ArrayList();   //  Holds the array of laser beams


void setup () {
  size(600, 800, P3D);
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n');       // don't generate a serialEvent() unless you get a newline character
  y = height-70;

  spaceship = loadImage("data/spaceship.png");
  bgc = loadImage("data/bgc.jpg");
  lasershot = loadImage("data/laser.png");
  asteroidImg = loadImage("data/asteroid2.png");

  delay(1000);                    // prevent buggy NULL read from the arduino
}
void draw () {

  moveBackground(bgc);
  spawnAsteroids();
  moveAsteroids();
  shootLasers();


  ship();

  textSize(20);
  text(frameRate, 30, 30);
  text(potVal, 30, 60);

  time++;
}

void moveBackground(PImage bgc) {
  background(0);
  imageMode(CORNER);
  image(bgc, 0, bgY);
  image(bgc, 0, (bgY - bgc.height));

  bgY += bgSpeed;    
  if (bgY > 1600) {
    bgY = 0;
  }
}

void ship() {
  //ellipse(x,y,shipDiameter,shipDiameter);  //  for debugging

  imageMode(CENTER);
  image(spaceship, x, y, shipDiameter, shipDiameter);
  //image(spaceship, mouseX, y, shipDiameter, shipDiameter);
}


void shot() {
  laserShots.add(new Laser(x, y, lasershot));    //shoot a laser beam
}

void shootLasers() {

  if (keyPressed) {
    shot();
  }

  for (int i = 0; i < laserShots.size(); i++) {    //  selects every laser shot
    Laser tLaser = (Laser) laserShots.get(i);
    tLaser.display();
    tLaser.move();


    for (int j = 0; j < asteroids.size(); j++) {    // code for successful shot here:
      Asteroid ast = (Asteroid) asteroids.get(j);
      asteroidHIT(ast, tLaser);
    }
  }
}







void spawnAsteroids() {

  if ( time == 100) {  //checks to see if enough time is passed to spawn an asteroid
    time = 0;
    asteroids.add(new Asteroid((int)random(0, width), -100, asteroidImg));    //spawn asteroid
  }
}

void moveAsteroids() {

  for (int i = 0; i < asteroids.size(); i++) {  //  selects every asteroid
    Asteroid tAsteroid = (Asteroid) asteroids.get(i);  
    tAsteroid.display();
    tAsteroid.move();

    if (tAsteroid.y > height+100) {    //  checks if the asteroid is out of the screen
      asteroids.remove(i);
    }

    if ( is_overlapping(tAsteroid.x, tAsteroid.y, tAsteroid.d/2, x, y, shipDiameter/2) ) {
    } else {
      fill(255);
    }
  }
}




boolean is_overlapping(float cx1, float cy1, float cr1, float cx2, float cy2, float cr2) {   //  if 2 objects overlap returns TRUE

  if (dist(cx1, cy1, cx2, cy2) < cr1 + cr2) { 
    return true;
  } else { 
    return false;
  }
} 


void asteroidHIT(Asteroid asteroid, Laser laser) {

  if ( is_overlapping(asteroid.x, asteroid.y, asteroid.d/2, laser.x, laser.y, 50/2) ) {      //  checks if the laser is hitting the asteroid
    asteroid.lifes--;                                                                        //  minus 1 life
    if (asteroid.lifes == 0) {
      points += asteroid.lifes + 1;
      /////////////////////                                            maybe special effect ????      !!!!!!!!!!!!!!!!!!!!!!!!!!!!
      asteroids.remove(asteroid);                                                            //  if hit and destroyed + point
    }
    laserShots.remove(laser);                                                                //  removes the shooted laser
  }
}




void serialEvent (Serial myPort) {
  // get the ASCII string:
  String readStr = myPort.readStringUntil('\n');

  if (readStr != null) {
    readStr = trim(readStr);
    potVal = float(readStr);
    //println(potVal);
    potVal = map(potVal, 0, 255, 0, width);
    x = (int)potVal;
  }
}
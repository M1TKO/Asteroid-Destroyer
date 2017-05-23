import processing.serial.*; //<>// //<>//
PFont font;
Serial myPort;              //  The serial port
float potVal = 10;         //  holds the given value of the potentiometer 
int x = 0;                  //  Ship's X location
int y;                    //  How far from the bottom is the ship
int points = 0;           //  Number of the shooted asteroids
int bgY = 0;                //  For the illusion of moving background
int bgSpeed = 2;          //  Speed of the moving background
int asteroidTimer = 0;     //  How ofthen to spawn an asteroid
int lifes = 5;              //  Ship's lifes
int laserTimer = 0;        //  Shot deley timer  // 30
int laserDelay = 10;
int shipDiameter = 80;
int asteroidDelay = 100;
int textHomeX;
boolean gameStarted = false;
boolean gameOver = false;
PImage spaceship;
PImage bgc;
PImage lasershot;
PImage asteroidImg;
ArrayList laserShots = new ArrayList();  //  Holds the array of asteroids
ArrayList asteroids = new ArrayList();   //  Holds the array of laser beams


void setup () {
  size(600, 800, P3D);    // P3D for smooter gameplay (optimization)
  myPort = new Serial(this, Serial.list()[0], 9600);  //  selects arduino port ( first found ) 
  myPort.bufferUntil('\n');       // don't generate a serialEvent() unless you get a newline character
  y = height-70;                  //  ship's location on Y axis
  font = loadFont("data/ErasITC-Bold-90.vlw");
  spaceship = loadImage("data/spaceship.png");
  bgc = loadImage("data/bgc.jpg");
  lasershot = loadImage("data/laser.png");
  asteroidImg = loadImage("data/asteroid2.png");

  delay(1000);                    // prevent buggy NULL read from the arduino
}
void draw () {
  if (gameStarted) {
    moveBackground(bgc);
    spawnAsteroids();
    moveAsteroids();
    shootLasers();
    ship();
    textSize(20);
    text("lifes: " + lifes + " | points: " + points, 30, 30);
    text(potVal, 30, 60);
    asteroidTimer++;    

    if (laserTimer < laserDelay) {    // delay between shots timer (can shoot only if it is >= the given value)
      laserTimer++;
    }
  } else if (gameOver) {  
    //      game over code....
  } else {
    background(0);                // Home screen
    image(bgc, 0, 0);

    textFont(font, 90);
    fill(#3993FF);
    text("ASTEROID DESTROYER", 15, 100, width-10, width-100);
    textFont(font, 25);
    fill(255);
    text("Press any key to start the game", textHomeX, 600);
    textHomeX += 2;
    if (textHomeX > width) {                                    //moving text
      textHomeX = 0;
    }
    text("Press any key to start the game", textHomeX-width, 600);
    textFont(font, 25);
    text("Developer: Dimitar Kalenderov", 10, height-10);
  }
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
}

void shot() {
  laserShots.add(new Laser(x, y, lasershot));    //shoot a laser beam (spawn)
}

void shootLasers() {

  if (laserTimer >= laserDelay && keyPressed) {     //  lasers shots delay
    laserTimer = 0;                        //reset timer for shot delay
    shot();
  }

  for (int i = 0; i < laserShots.size(); i++) {    //  selects every laser shot
    Laser tLaser = (Laser) laserShots.get(i);
    tLaser.display();
    tLaser.move();


    for (int j = 0; j < asteroids.size(); j++) {    // code for HITING an asteroid here:
      Asteroid ast = (Asteroid) asteroids.get(j);
      asteroidHIT(ast, tLaser);
    }
  }
}



void spawnAsteroids() {

  if ( asteroidTimer == asteroidDelay) {  //checks to see if enough time is passed to spawn an asteroid
    asteroidTimer = 0;
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
      points -= tAsteroid.lifes;            ////////////////////////////////////////////////////////////////////////////////
    }

    if ( is_overlapping(tAsteroid.x, tAsteroid.y, tAsteroid.d/2, x, y, shipDiameter/2) ) {
      //////////////////////////////////////////////////////////////////////////////////////////sound of conflict
      asteroids.remove(i);
      lifes--;
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
  if (asteroid.y > 0) {                                                                          //  prevent cheating
    if ( is_overlapping(asteroid.x, asteroid.y, asteroid.d/2, laser.x, laser.y, 50/2) ) {      //  checks if the laser is hitting the asteroid
      asteroid.lifes--;     //  minus 1 life
      if (asteroid.lifes == 0) {
        points += asteroid.reward;
        /////////////////////                                            maybe special effect ????      !!!!!!!!!!!!!!!!!!!!!!!!!!!!
        asteroids.remove(asteroid);                                                            //  if hit and destroyed + point     ////////////////////// hitted asteroid sound
      }
      laserShots.remove(laser);                                                                //  removes the shooted laser        //////////////// hitted asteroid sound
    }
  }
}


void keyPressed(){
  if(!gameOver && !gameStarted){
    gameStarted = true;   
  }else if(gameOver && !gameStarted){
    gameStarted =true;    
  }

}




/////////////////////  READS THE POTENTIOMETER VALUES FROM THE ARDUINO    ////////////////////////////////////

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
import processing.sound.*; //<>// //<>// //<>//
import processing.serial.*; 

float overheatTimer = 130;  ////
float overhitTs = 1;        //// Timers for overheat
float oHts = 30;            ////
PFont font;                 //  Font
Serial myPort;              //  The serial port
float potVal = 10;          //  holds the given value of the potentiometer 
int x = 0;                  //  Ship's X location
int y;                      //  How far from the bottom is the ship
int points = 0;             //  Number of the shooted asteroids
float bgY = 0;              //  For the illusion of moving background
float bgSpeed = 0.5;          //  Speed of the moving background
float asteroidTimer = 1; 
int lifes = 5;              //  Ship's lifes
int laserTimer = 0;         //  Shot deley timer  // 30
float laserDelay = 30; 
float shipDiameter = 80;
float asteroidDelay = 250;   //  How ofthen to spawn an asteroid
float asteroidSpeed = 1;
int textHomeX;
int bestResult;
float s = 2;         /////  
float yy = 600;     //Game Over bouncing text properties
float v = 0.3;      ////
boolean gameStarted = false;
boolean gameOver = false;
PImage spaceship;
PImage bgc;
PImage lasershot;
PImage asteroidImg;
SoundFile[] soundEffects = new SoundFile[7];
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

  soundEffects[0] = new SoundFile(this, "laser.mp3");                 //laser shooted effect
  soundEffects[1] = new SoundFile(this, "asteroid_hit.mp3");         //asteroid hitted by laser
  soundEffects[2] = new SoundFile(this, "asteroid_destroyed.mp3");  //asteroid destroyed by laser
  soundEffects[3] = new SoundFile(this, "ship_hitted.mp3");        //ship hitted by asteroid
  soundEffects[4] = new SoundFile(this, "win.mp3");               // win sound
  soundEffects[5] = new SoundFile(this, "loose.mp3");            // loose sound
  soundEffects[6] = new SoundFile(this, "music.mp3");           // loose sound
  soundEffects[6].loop();        
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
    //text(overheatTimer + "  " + laserDelay, 30, 120); 
    overheat();
    asteroidTimer++;    
    if (laserTimer < laserDelay) {    // delay between shots timer (can shoot only if it is >= the given value)
      laserTimer++;
    }
    showGameOver();
    
    
  } else if (gameOver) {  
    background(80);                // Game Over screen
    image(bgc, width/2, 0);
    textFont(font, 90);
    fill(#FFFFFF);
    text("GAME OVER", 15, 100, width-10, width-100);
    textFont(font, 45);
    text("Colected Points: " + points, 20, 500);
    text("Best Record: " + bestResult, 20, 550);
    textHomeX += 8;
    if (textHomeX > width+550) {                                    //moving text
      textHomeX = 0;
    }
    image(asteroidImg, textHomeX-250, 300, 200, 200);

    fill(#3993FF);
    textFont(font, 25);
    text("Developer: Dimitar Kalenderov", 10, 35);
    yy += s;
    
    fill(255);
    text("Press any key to play again", 100, yy);

    if (yy > height-8) {
      yy = height-8;
      s *= -0.8;
    }
    s+=v;
    
  } else {
    background(0);                // Home screen
    image(bgc, 0, 0);
    textFont(font, 90);
    fill(#3993FF);
    text("ASTEROID DESTROYER", 15, 100, width-10, width-100);
    textFont(font, 25);
    fill(255);
    text("Press any key to start the game", width-textHomeX, 600);
    textHomeX += 2;
    if (textHomeX > textHomeX+width/2) {                                    //moving text
      textHomeX = 0;
    }
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
  soundEffects[0].play();
  overheatTimer-=oHts;
}

void shootLasers() {
  if (overheatTimer > laserDelay) {
    if (laserTimer >= laserDelay && keyPressed) {     //  lasers shots delay
      laserTimer = 0;                        //reset timer for shot delay
      shot();
    }
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

void overheat() {  
  if (overheatTimer < 0) {
    overheatTimer = 0;
    overhitTs = 0.5;
  } else if (overheatTimer > 130) {
    overheatTimer = 130;
  } else if (overheatTimer > 20) {
    overhitTs = 5;
  }
  overheatTimer += overhitTs;
  fill(#FF1212);
  rect(30, 40, 160, 10);

  fill(255);
  rect(30, 40, 30 + overheatTimer, 10);
  fill(255);
}

void spawnAsteroids() {

  if ( asteroidTimer > asteroidDelay) {  //checks to see if enough time is passed to spawn an asteroid
    asteroidTimer = 0;
    asteroids.add(new Asteroid((int)random(0, width), -100, asteroidImg, asteroidSpeed));    //spawn asteroid
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
      soundEffects[3].play();
    }
  }
}

void showGameOver() {
  if (lifes <= 0) {
    gameOver = true;
    gameStarted = false;
    if (points >= bestResult) {
      bestResult = points;
      soundEffects[4].play();    //sound of win
    } else {
      soundEffects[5].play();    //sound loose
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
  if (asteroid.y > 0) {                                                                        //  prevent cheating(hit before it is shown)
    if ( is_overlapping(asteroid.x, asteroid.y, asteroid.d/2, laser.x, laser.y, 50/2) ) {      //  checks if the laser is hitting the asteroid
      asteroid.lifes--;     //  minus 1 life
      if (asteroid.lifes == 0) {
        points += asteroid.reward;
        asteroids.remove(asteroid);       
        soundEffects[2].play();               //  if hit and destroyed + points

        inceaseDifficulty();
      } else {
        //laser only hitted but not destroyed the asteroid
        soundEffects[1].play();
      }
      laserShots.remove(laser);                                                                //  removes the shooted laser
    }
  }
}


void keyPressed() {
  if (!gameOver && !gameStarted) {
    gameStarted = true;   
    gameOver = false;
  } else if (gameOver && !gameStarted) {
    gameRestart();
    gameOver = false;
    gameStarted =true;
  }
}


void gameRestart() {
  points = 0;          
  bgY = 0;             
  bgSpeed = 0.5;         
  asteroidTimer = 1;   
  lifes = 5;           
  laserTimer = 0;      
  laserDelay = 30;
  asteroidDelay = 250;
  asteroidSpeed = 1;
  asteroids = null;
  laserShots = null;
  asteroids = new ArrayList();
  laserShots = new ArrayList();
  s = 2;            
  yy = 600;            
  v = 0.3;

  overheatTimer = 130;
  overhitTs = 1;
  oHts = 30;
}


void inceaseDifficulty() {
  if (points > 1) {
    float iv = 0.25;
    if (bgSpeed < 2) {
      bgSpeed += iv/2;
      //bgSpeed = 2.5;
    }
    if (asteroidSpeed < 2.5) {
      asteroidSpeed += iv/2;
      //asteroidSpeed = 2;
    }
    if (laserDelay > 6) {
      laserDelay -= iv*2;
      //laserDelay = 6;
    }
    if (oHts < 80) {
      oHts += iv*60;
      //oHts = 80;
    }

    if (asteroidDelay > 50) {
      asteroidDelay -= iv*20;
      //asteroidDelay = 50;
    }
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
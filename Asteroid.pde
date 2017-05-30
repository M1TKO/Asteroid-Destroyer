class Asteroid {
  int d = (int)random(30, 120);
  float x, y, speed;
  int lifes, reward;
  PImage asteroid;
  Asteroid(int tx, int ty, PImage tasteroid, float tspeed) {
    this.x = tx;
    this.y = ty;
    this.asteroid = tasteroid;
    this.speed = tspeed;

    if (d <= 40) {   //  Give different lifes depending on the asteroid size
      lifes = 1;
    } else if (d > 40 && d <= 60) {
      lifes = 2;
    } else if (d > 60 && d <= 80) {
      lifes = 3;
    } else if (d > 80 && d <= 100) {
      lifes = 4;
    }  else if (d > 100 && d <= 120) {
      lifes = 5; 
    }else {
      lifes = 1;
    }
    reward = lifes;        //  backup value of the lifes (becouse lifes are always changing)
  }

  void display() {
    imageMode(CENTER);
    image(asteroid, x, y, d, d);
    //ellipseMode(CENTER);      // for debugging
    //ellipse(x,y, d, d);
    //textMode(CENTER);
    fill(255);
    text(lifes, x-5, y+5);      //  display lifes of the asteroid
  }
  void move() {
    this.y+= speed;

  }
}
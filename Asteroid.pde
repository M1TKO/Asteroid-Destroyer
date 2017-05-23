class Asteroid {
  int d = (int)random(30, 100);
  float speed = 4;
  int x, y;
  PImage asteroid;
  int lifes;
  int reward;
  Asteroid(int tx, int ty, PImage tasteroid) {
    this.x = tx;
    this.y = ty;
    this.asteroid = tasteroid;

    if (d <= 40) {
      lifes = 1;
    } else if (d > 40 && d <= 60) {
      lifes = 2;
    } else if (d > 60 && d <= 80) {
      lifes = 3;
    } else if (d > 80 && d <= 100) {
      lifes = 4;
    } else {
      lifes = 1;
    }
    reward = lifes;
  }

  void display() {
    imageMode(CENTER);
    image(asteroid, x, y, d, d);
    //textMode(CENTER);
    text(lifes, x-5, y+5);      //  display lifes of the asteroid
    //ellipseMode(CENTER);  // for debugging
    //ellipse(x,y, d, d);
  }
  void move() {
    this.y+= speed;
  }
}
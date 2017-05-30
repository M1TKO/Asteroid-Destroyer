class Laser {
  float speed = 10;
  int x, y;
  int d = 30;
  PImage laser;
  
  Laser(int tx, int ty, PImage tl){
    this.x = tx;
    this.laser = tl;
    this.y = ty;
    
  }
  
  void display() {
    imageMode(CENTER);
    image(laser, x, y, d, d);
    
        
  }
  void move(){
    this.y -= speed;
  }
  
}
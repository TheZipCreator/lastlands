class Entity {
  int x; //X position of the tile the entity is on
  int y; //Y position of the tile the entity is on
  int type; //Type of the entity. 0=Chiefdom, 1=Map Text
  boolean delete = false;
  Entity(int x, int y, int type) {
    this.x = x;
    this.y = y;
    this.type = type;
    this.delete = false;
  }
  
  void render() {
    image(entityImages[type], (x*tileSize)-panning.x, (y*tileSize)-panning.y);
  }
  
  boolean collide(int collideX, int collideY) { //Whether or not (collideX, collideY) intersect with the entity
    if(collideX > (x*tileSize)-panning.x && collideX < ((x*tileSize)+tileSize)-panning.x && collideY > (y*tileSize)-panning.y && collideY < ((y*tileSize)+tileSize)-panning.y) return true;
    return false;
  }
  void dayPassed() { //Called after a day has passed
    
  }
  void specificAction(int action, float args) { //I have to do this to get around stupid shit with the way java works
    
  }
}

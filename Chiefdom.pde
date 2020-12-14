class Chiefdom extends Entity {
  int x;
  int y;
  int type;
  PImage flag; //Flag of the chiefdom. Must be 200x150.
  String name; //Name of the chiefdom
  int population; //Population of the chiefdom
  Chiefdom(int x, int y, int type, PImage flag, String name, int population) {
    super(x, y, type);
    this.flag = flag;
    this.name = name;
    this.population = population;
  }
  
  void render() {
    image(entityImages[type], (x*tileSize)-panning.x, (y*tileSize)-panning.y);
  }
  
  boolean collide(int collideX, int collideY) { //Whether or not (collideX, collideY) intersect with the entity
    if(collideX > (x*tileSize)-panning.x && collideX < ((x*tileSize)+tileSize)-panning.x && collideY > (y*tileSize)-panning.y && collideY < ((y*tileSize)+tileSize)-panning.y) return true;
    return false;
  }
}

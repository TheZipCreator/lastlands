class Chiefdom extends Entity {
  int x;
  int y;
  int type;
  PImage flag; //Flag of the chiefdom. Must be 200x150.
  PImage smallFlag; //Downsize version of the flag that's 40x30
  String pathToFlag; //Path to the flag of the chiefdom
  String name; //Name of the chiefdom
  int population; //Population of the chiefdom
  String tag; //Used for identification
  ArrayList<intvect> path; //Path this chiefdom is going on
  int daysUntilNextMove; //Amount of days until this chiefdom moves again
  int daysSinceLastMoved; //Amount of days since the chiefdom last moved
  boolean inBattle; //Whether or not this chiefdom is in a battle
  Chiefdom(int x, int y, int type, String flag, String name, int population, String tag) {
    super(x, y, type);
    this.flag = loadImage(flag);
    this.pathToFlag = flag;
    this.name = name;
    this.population = population;
    this.tag = tag;
    this.smallFlag = loadImage(flag);
    smallFlag.resize(40, 30);
    this.path = new ArrayList<intvect>();
    this.delete = false;
    inBattle = false;
  }
  
  void render() {
    if(!inBattle) { //Only render if not in battle
      image(entityImages[type], (x*tileSize)-panning.x, (y*tileSize)-panning.y);
      fill(128, 128, 128, 128); //Display name & box around name - this code is extremely ugly and I do not care
      rect((x*tileSize)-panning.x, ((y*tileSize)-panning.y)-20, name.length()*9, 20);
      textSize(16);
      fill(255);
      text(name, (x*tileSize)-panning.x, ((y*tileSize)-panning.y)-2.5);
      image(smallFlag, (x*tileSize)-panning.x, ((y*tileSize)-panning.y)-50);
    }
  }
  boolean collide(int collideX, int collideY) { //Whether or not (collideX, collideY) intersect with the entity
    if(collideX > (x*tileSize)-panning.x && collideX < ((x*tileSize)+tileSize)-panning.x && collideY > (y*tileSize)-panning.y && collideY < ((y*tileSize)+tileSize)-panning.y) return true;
    return false;
  }
  void setFlag(String flag) {
    this.flag = loadImage(flag);
    this.smallFlag = loadImage(flag);
    smallFlag.resize(40, 30);
  }
  void dayPassed() { //Called after a day has passed
    if(!inBattle) daysSinceLastMoved++;
    if(this.path.size() > 0) { //Follow path
      daysSinceLastMoved = 0;
      daysUntilNextMove--;
      if(daysUntilNextMove == 0) {
        daysUntilNextMove = 4;
        x = this.path.get(0).x;
        y = this.path.get(0).y;
        this.path.remove(0);
      }
    }
    if(daysSinceLastMoved >= 62) { //Decrease population if haven't migreated
      if(day == 0) population -= population/10;
    }
    if(!inBattle) {
      for(int i = 0; i < diplomacy.size(); i++) { //Do battles and stuff
        if(diplomacy.get(i).type == 1) { //if the diplomatic relation is a war
          if(diplomacy.get(i).chiefdomA.equals(tag)) {
            Chiefdom chiefdomB = ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomB)));
            if(chiefdomB.x == x && chiefdomB.y == y) { //Chiefdom we're at war with is on the same tile
              inBattle = true;
              ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomB))).inBattle = true;
              battles.add(new Battle(tag, chiefdomB.tag, x, y));
            }
          }
        }
        //if(diplomacy.get(i).chiefdomB.equals(tag)) {
        //  Chiefdom chiefdomA = ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomA)));
        //  if(chiefdomA.x == x && chiefdomA.y == y) { //Chiefdom we're at war with is on the same tile
        //    if(chiefdomA.population > population) {
        //      delete = true;
        //    } else {
        //      ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomA))).delete = true;
        //    }
        //  }
        //}
      }
    }
  }
  void updateAI() { //Called daily if the chiefdom is not the player
    if(!inBattle) { //Only do AI if the chiefdom isn't in a battle
      if(daysSinceLastMoved >= 54) {
        int tempX = x+floor(random(-5,5));
        int tempY = y+floor(random(-5,5));
        while(!astar_nodes[tempX][tempY].traversable) {
          tempX = x+floor(random(-5,5));
          tempY = y+floor(random(-5,5));
        }
        ArrayList<intvect> path = a_star(astar_nodes, new intvect(x, y), new intvect(tempX, tempY));
        if(path != null) { //If there is a valid path
          //Fix the path
          if(path.size() > 0) {
            path = reversePath(path);
            path.remove(0);
            path.add(new intvect(tempX, tempY));
          }
          this.path = path; //Tell the chiefdom to move
          daysUntilNextMove = 4;
        }
      }
    }
  }
  void specificAction(int action, int args) { //I have to do this to get around stupid shit with the way java works
    if(action == 0) { //Remove population
      population += args;
    }
    if(action == 1) {
      inBattle = false;
    }
  }
}

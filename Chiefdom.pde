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
  float cohesion; //Goes from 0 to 100.
  float coins; //Coins
  
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
    cohesion = 100;
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
    if(day == 1) { //New month
      float coinGrowth = population*constCoinGrowth;
      float populationGrowth = float(population)*constPopGrowth;
      float cohesionGrowth = 0;
      boolean hasTributaries = false;
      for(int i = 0; i < diplomacy.size(); i++) { //Tributes
        if(diplomacy.get(i).type == 2) { //Pay tribute
          if(diplomacy.get(i).chiefdomB.equals(tag)) {
            String overlord = diplomacy.get(i).chiefdomA;
            populationGrowth -= populationGrowth*constPopPaidToTributary;
            coinGrowth -= coinGrowth*constCoinsPaidToTributary;
          } else if(diplomacy.get(i).chiefdomA.equals(tag)) {
            hasTributaries = true;
            Chiefdom chiefdomB = ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomB)));
            coinGrowth += (chiefdomB.population*constCoinGrowth)*constCoinsPaidToTributary;
            populationGrowth += (chiefdomB.population*constPopGrowth)*constPopPaidToTributary;
            if(chiefdomB.population >= population) {
              cohesionGrowth += constCohesionGrowthBigTributary;
            } else {
              cohesionGrowth += constCohesionGrowthTributary;
            }
          }
        }
        if(!hasTributaries) cohesionGrowth += constCohesionGrowthNoTributaries;
        cohesion += cohesionGrowth;
        if(cohesion > 100) cohesion = 100;
      }
      coins += coinGrowth;
      population += floor(populationGrowth);
    }
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
          if(diplomacy.get(i).containsMember(tag)) {
            Chiefdom chiefdomB = ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).getOther(tag)))); //Get the other chiefdom in this battle
            if(chiefdomB.x == x && chiefdomB.y == y) { //Chiefdom we're at war with is on the same tile
              inBattle = true;
              ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).getOther(tag)))).inBattle = true;
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
  void specificAction(int action, float args) { //I have to do this to get around stupid shit with the way java works
    if(action == 0) { //Add population
      population += floor(args);
    }
    if(action == 1) {
      inBattle = false;
    }
    if(action == 2) { //Path to a random tile
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
    if(action == 3) { //Add coins
      coins += args;
    }
    if(action == 4) { //Add cohesion
      cohesion += args;
    }
  }
  void wonBattle(String loserTag) { //Tells the AI they won a battle with the specified tag
    if(loserTag.equals(currChiefdom)) { //Will always make the player a tributary
      addDiplomacy(new DiplomaticRelation(2, tag, loserTag));
    } else {
      if(population < 3000) { //Will integrate chiefdoms if population is less than 3000, otherwise will tributary them
        population += ((Chiefdom)entities.get(findChiefdom(loserTag))).population;
        entities.remove(findChiefdom(loserTag));
      } else {
        addDiplomacy(new DiplomaticRelation(2, tag, loserTag));
      }
    }
  }
}

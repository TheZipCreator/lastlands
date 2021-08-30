class Battle {
  ArrayList<Soldier> attackers;
  ArrayList<Soldier> defenders;
  ArrayList<String> attackerParticipants;
  ArrayList<String> defenderParticipants;
  int x;
  int y;
  int winner; //-1 if no winner, 0 if attacker won, 1 if defender won
  
  Battle(String attacker, String defender, int x, int y) {
    winner = -1;
    this.x = x;
    this.y = y;
    attackerParticipants = new ArrayList<String>(); //Init participants
    defenderParticipants = new ArrayList<String>();
    attackerParticipants.add(attacker);
    defenderParticipants.add(defender);
    Chiefdom attackerChiefdom = (Chiefdom)entities.get(findChiefdom(attacker)); //Get attacker and defender chiefdoms
    Chiefdom defenderChiefdom = (Chiefdom)entities.get(findChiefdom(defender));
    attackers = new ArrayList<Soldier>();
    defenders = new ArrayList<Soldier>();
    for(int i = 0; i < attackerChiefdom.population; i++) { //Add a soldier for every person in the attacker chiefdom
      attackers.add(new Soldier(attacker, 0));
    }
    for(int i = 0; i < defenderChiefdom.population; i++) { //Add a soldier for every person in the defender chiefdom
      defenders.add(new Soldier(defender, 0));
    }
  }
  void tick() {
    //Only a max of 500 soldiers can be in combat at a time
    int numDefending = cap(defenders.size(), 500);
    for(int i = 0; i < numDefending; i++) { //Defenders go first
      if(defenders.get(i).hits()) { //if the soldier hits
        if(attackers.size() > 0) {
          if(random(3) < 1) { //1/3 soldiers die when hit, the other 2/3 are too injured to continue fighting
              entities.get(findChiefdom(attackers.get(0).owner)).specificAction(0, -1); //decrease population
          }
          attackers.remove(0); //Remove the attacker
        }
      }
    }
    int numAttacking = cap(attackers.size(), 500); 
    for(int i = 0; i < numAttacking; i++) { //Attackers go second
      if(attackers.get(i).hits()) { //if the soldier hits
        if(defenders.size() > 0) {
          if(random(3) < 1) { //1/3 soldiers die when hit, the other 2/3 are too injured to continue fighting
              entities.get(findChiefdom(defenders.get(0).owner)).specificAction(0, -1); //decrease population
          }
          defenders.remove(0); //Remove the defender
        }
      }
    }
    if(attackers.size() == 0) {
      winner = 1;
    }
    if(defenders.size() == 0) {
      winner = 0;
    }
  }
  void render() {
    float pannedX = (x*tileSize)-panning.x;
    float pannedY = (y*tileSize)-panning.y;
    image(((Chiefdom)entities.get(findChiefdom(attackerParticipants.get(0)))).smallFlag, pannedX, pannedY); //This is kind of a mess
    image(miscImages[4], pannedX+40, pannedY);
    image(((Chiefdom)entities.get(findChiefdom(defenderParticipants.get(0)))).smallFlag, pannedX+76, pannedY);
    textSize(16);
    fill(255);
    text(attackers.size(), pannedX, pannedY+46);
    text(defenders.size(), pannedX+76, pannedY+46);
  }
}

class Soldier { //Generated in battles whenever needed
  String owner; //Name of the owner of the soldier
  int diceAdvantage; //How much to add to the dice
  
  Soldier(String owner, int diceAdvantage) {
    this.owner = owner;
    this.diceAdvantage = diceAdvantage;
  }
  boolean hits() {
    return ceil(random(6))+diceAdvantage >= 6;
  }
}

class DiplomaticBox extends WindowElement { //Box to display a chefdom's diplomacy
  String tag; //Chiefdom to display diplomacy of
  int type; //Type of diplomatic relation to display
  int oneWay; //Whether or not to only show relations one way, 0 is default, 1 only shows if the chiefdom is chiefdomA, 2 only shows if the chiefdom is chiefdomB.
  
  DiplomaticBox(int x, int y, int type, String tag, int oneWay) {
    super(x,y);
    this.tag = tag;
    this.type = type;
    this.oneWay = oneWay;
  }
  
  void render(int windowX, int windowY) {
    int xPos = windowX+x+5;
    for(int i = 0; i < diplomacy.size(); i++) {
      if(diplomacy.get(i).type == type) {
        switch(oneWay) { //Test whether or not the diplomatic box is oneway
          case 1: //Only show if chiefdomA
          if(diplomacy.get(i).chiefdomA.equals(tag)) {
            image(((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomB))).smallFlag, xPos, windowY+y+5);
            xPos += 45;
          }
          break;
          case 2: //Only show if chiefdomB
          if(diplomacy.get(i).chiefdomB.equals(tag)) {
            image(((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomA))).smallFlag, xPos, windowY+y+5);
            xPos += 45;
          }
          break;
          case 0: //Show both
          if(diplomacy.get(i).chiefdomA.equals(tag)) {
            image(((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomB))).smallFlag, xPos, windowY+y+5);
            xPos += 45;
          } else if(diplomacy.get(i).chiefdomB.equals(tag)) {
            image(((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomA))).smallFlag, xPos, windowY+y+5);
            xPos += 45;
          }
          break;
          default:
          break;
        }
      }
    }
    noFill();
    stroke(0);
    rect(windowX+x, windowY+y, 440, 40);
  }
  void hover(int colX, int colY, int windowX, int windowY) {
    int xPos = windowX+x+5;
    int yPos = windowY+y+5;
    if(colX > windowX+x+5 && colX < windowX+x+5+440 && colY > yPos && colY < windowY+y+5+40) { //Test if the mouse is within the box
      for(int i = 0; i < diplomacy.size(); i++) {
        if(diplomacy.get(i).type == type) {
          switch(oneWay) { //Test whether or not the diplomatic box is oneway
            case 1: //Only show if chiefdomA
            if(diplomacy.get(i).chiefdomA.equals(tag)) {
              String name = ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomB))).name; //Get name of chiefdom
              if(colX > xPos && colX < xPos+40 && colY > yPos && colY < yPos+30) { //If the mouse is within the flag
                fill(255);
                textSize(16);
                text(name, mouseX, mouseY); //Display the name
              }
              xPos += 45;
            }
            break;
            case 2: //Only show if chiefdomB
            if(diplomacy.get(i).chiefdomB.equals(tag)) {
              String name = ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomA))).name; //Get name of chiefdom
              if(colX > xPos && colX < xPos+40 && colY > yPos && colY < yPos+30) { //If the mouse is within the flag
                fill(255);
                textSize(16);
                text(name, mouseX, mouseY); //Display the name
              }
              xPos += 45;
            }
            break;
            case 0: //Show both
            if(diplomacy.get(i).chiefdomA.equals(tag)) {
              String name = ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomB))).name; //Get name of chiefdom
              if(colX > xPos && colX < xPos+40 && colY > yPos && colY < yPos+30) { //If the mouse is within the flag
                fill(255);
                textSize(16);
                text(name, mouseX, mouseY); //Display the name
              }
              xPos += 45;
            } else if(diplomacy.get(i).chiefdomB.equals(tag)) {
              String name = ((Chiefdom)entities.get(findChiefdom(diplomacy.get(i).chiefdomA))).name; //Get name of chiefdom
              if(colX > xPos && colX < xPos+40 && colY > yPos && colY < yPos+30) { //If the mouse is within the flag
                fill(255);
                textSize(16);
                text(name, mouseX, mouseY); //Display the name
              }
              xPos += 45;
            }
            break;
            default:
            break;
          }
        }
      }
    }
  }
}

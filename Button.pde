class Button extends WindowElement {
  int sizeX;
  int sizeY;
  String text;
  String actionPath; //Path to the LEL script to activate upon the press of the button
  String[] metadata; //Metadata to pass into the script
  Button(int x, int y, int sizeX, int sizeY, String text, String actionPath, String[] metadata) {
    super(x, y);
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.text = text;
    this.actionPath = actionPath;
    this.metadata = metadata;
  }
  
  void render(int windowX, int windowY) {
    fill(128, 128, 128);
    rect(x+windowX, y+windowY, sizeX, sizeY);
    fill(255);
    textSize(30);
    textAlign(CENTER);
    text(text, (x+windowX)+sizeX/2, y+windowY+25);
    textAlign(LEFT);
  }
  
  void collide(int colX, int colY, int windowX, int windowY) { //Test if colX and colY are within the box's boundaries
    if(colX > x+windowX && colY > y+windowY && colX < x+windowX+sizeX && colY < y+windowY+sizeY) { //If the button collided
      loadScript(actionPath, metadata); //Load the script
      deleteParent = true;
      sfx[0].play(); //Play click sound
    }
  }
}

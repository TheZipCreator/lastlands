class Window {
  int x; //X and Y position on the screen
  int y;
  int sizeX; //Size of the window
  int sizeY;
  String title; //Title of the window
  ArrayList<WindowElement> elements; //List of WindowElements
  boolean delete; //If enabled, this window will be removed next iteration
  int prevX; //Previous mouse location relative to the window position
  int prevY;
  int dragTime = 0; //How long the window has been dragged for
  boolean disableX; //Whether or not the window has an X
  boolean force_pause;
  
  Window(int x, int y, int sizeX, int sizeY, String title) {
    this.x = x;
    this.y = y;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.title = title;
    elements = new ArrayList<WindowElement>();
    delete = false;
    prevX = sizeX/2;
    prevY = 25;
    dragTime = 1000;
    disableX = false;
    force_pause = false;
  }
  void addElement(WindowElement element) {
    elements.add(element);
  }
  void render() {
    stroke(0);
    fill(128, 128, 128, 128);
    rect(x, y+50, sizeX, sizeY);
    stroke(0);
    fill(255, 0, 255, 128);
    rect(x, y, sizeX, 50);
    fill(255);
    textSize(40);
    if(!disableX) text("X", (x+sizeX)-28, y+40);
    text(title, x, y+40);
    for(int i = 0; i < elements.size(); i++) {
      elements.get(i).render(x, y);
      if(elements.get(i).deleteParent) {
        delete = true;
      }
    }
    dragTime++;
    for(int i = 0; i < elements.size(); i++) { //Display hover text for all elements
      elements.get(i).hover(mouseX, mouseY, x, y);
    }
  }
  void click() {
    if(mouseX >= (x+sizeX)-20 && mouseX < x+sizeX && mouseY > y && mouseY < y+50 && !disableX) { //X was clicked
      delete = true;
      sfx[0].cue(0); //Play click sound
    }
    for(int i = 0; i < elements.size(); i++) {
      elements.get(i).collide(mouseX, mouseY, x, y);
    }
  }
  void drag() {
    if((mouseX >= x && mouseX < x+sizeX && mouseY > y && mouseY < y+50) || dragTime < 20) { //This window is being dragged
      if(dragTime > 20) {
        prevX = mouseX-x;
        prevY = mouseY-y;
        //println(dragTime);
        dragTime = 0;
      }
      //println(prevX, prevY);
      x = mouseX-prevX;
      y = mouseY-prevY;
    }
  }
}

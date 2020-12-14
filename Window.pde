class Window {
  int x; //X and Y position on the screen
  int y;
  int sizeX; //Size of the window
  int sizeY;
  String title; //Title of the window
  ArrayList<WindowElement> elements; //List of WindowElements
  boolean delete; //Whether or not to mark this window for deletion
  int prevX; //Previous mouse location relative to the window position
  int prevY;
  int dragTime = 0; //How long the window has been dragged for
  
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
  }
  void addElement(WindowElement element) {
    elements.add(element);
  }
  void render() {
    fill(128, 128, 128, 128);
    rect(x, y+50, sizeX, sizeY);
    for(int i = 0; i < elements.size(); i++) {
      elements.get(i).render(x, y);
    }
    fill(255, 0, 255, 128);
    rect(x, y, sizeX, 50);
    fill(255);
    textSize(40);
    text("X", (x+sizeX)-28, y+40);
    text(title, x, y+40);
    dragTime++;
  }
  void click() {
    if(mouseX >= (x+sizeX)-20 && mouseX < x+sizeX && mouseY > y && mouseY < y+50) { //X was clicked
      delete = true;
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

int state = 0; //State the game is in
int wsx = 200; //World Size X
int wsy = 152; //World Size Y
int[][] world; //The World
PImage[] tileImages; //Images for tiles
PImage[] entityImages; //Images for entities
PImage[] miscImages; //Images for anything else
PFont[] fonts; //Fonts
String parentDirectory = "data"; //Pointless as of now but will be used for modding and such
int tileSize = 64; //Size that each specific tile is. DO NOT CHANGE WITHOUT FIRST CHANGING THE IMAGES
PVector panning; //Amount of panning in X and Y
PVector panningChange; //Amount of change in the panning per frame
float panSpeed = 16; //How fast the camera pans
int conformedWidth; //Width expressed in a multiple of tileSize
int conformedHeight; //Height expressed in a multiple of tileSize
boolean acceleratePanSpeed = false; //Whether the pan speed is doubled or not
ArrayList<Entity> entities; //All entities in the game
ArrayList<Window> windows; //All windows in the game
boolean debug = true;

//Processing Functions
void settings() {
  fullScreen();
}
void setup() {
  world = new int[wsx][wsy]; //Init world
  loadLevel(parentDirectory+"/image/level/level.png");
  PImage defaultFlag = loadImage(parentDirectory+"/image/flag/example.png");
  tileImages = new PImage[3];
  tileImages[0] = loadImage(parentDirectory+"/image/tile/ground.png"); //Ground tile
  tileImages[1] = loadImage(parentDirectory+"/image/tile/water.png"); //Water tile
  tileImages[2] = loadImage(parentDirectory+"/image/tile/mountain.png"); //Mountain tile
  entityImages = new PImage[1];
  entityImages[0] = loadImage(parentDirectory+"/image/entity/tribe.png"); //Chiefdom entity
  miscImages = new PImage[1];
  miscImages[0] = loadImage(parentDirectory+"/image/misc/selection.png"); //Selection Box
  fonts = new PFont[1];
  fonts[0] = loadFont(parentDirectory+"/font/Consolas.vlw");
  textFont(fonts[0]);
  entities = new ArrayList<Entity>();
  windows = new ArrayList<Window>();
  int numChiefdoms = int(loadStrings(parentDirectory+"/data/chiefdom/amount.txt")[0]); //Get number of chiefdoms from amount.txt
  for(int i = 1; i <= numChiefdoms; i++) { //Add all chiefdoms to the array
    Chiefdom temp = new Chiefdom(0, 0, 0, defaultFlag, "Unnamed Tribe", 1000);
    String[] info = loadStrings(parentDirectory+"/data/chiefdom/"+i+".txt");
    temp.x = int(info[0]);
    temp.y = int(info[1]);
    temp.flag = loadImage(parentDirectory+info[2]);
    temp.name = info[3];
    entities.add(temp);
  }
  panning = new PVector();
  panningChange = new PVector();
  conformedWidth = width/tileSize;
  conformedHeight = height/tileSize;
}
void draw() {
  if(state == 0) { //Chiefdom Select Screen
    background(0);
    if(!acceleratePanSpeed) {
      panning.x += panningChange.x;
      panning.y += panningChange.y; 
    } else {
      panning.x += panningChange.x*2;
      panning.y += panningChange.y*2;
    }
    renderWorld();
    renderEntities();
    int tileX = floor((mouseX+panning.x)/tileSize); //X position of the tile the player is hovering on
    int tileY = floor((mouseY+panning.y)/tileSize); //Y position of the tile the player is hovering on
    image(miscImages[0], (tileX*tileSize)-panning.x, (tileY*tileSize)-panning.y);
    if(debug) {
      textSize(32);
      fill(255);
      text("("+tileX+","+tileY+")", 0, 32);
    }
    renderWindows();
  }
}
void mousePressed() {
  if(mouseButton == LEFT) {
    for(int i = 0; i < windows.size(); i++) {
      windows.get(i).click();
    }
  }
  if(state == 0) {
    for(int i = 0; i < entities.size(); i++) {
      if(entities.get(i).collide(mouseX, mouseY) && entities.get(i) instanceof Chiefdom) {
        String[] metadata = {((Chiefdom)entities.get(i)).name};
        loadWindow(parentDirectory+"/data/window/select_chiefdom.lgl", metadata);
      }
    }
  }
}
void mouseDragged() {
  if(state == 0) {
    if(mouseButton == LEFT) {
      for(int i = 0; i < windows.size(); i++) {
        windows.get(i).drag();
      }
    }
  }
}
void keyPressed() {
  if(state == 0) {
    if(Character.toLowerCase(key) == 'w' || keyCode == UP) { //There's probably a way to do this with switch statements but honestly I can't be bothered
      panningChange.y = -panSpeed;
    }
    else if(Character.toLowerCase(key) == 'a' || keyCode == LEFT) {
      panningChange.x = -panSpeed;
    }
    else if(Character.toLowerCase(key) == 's' || keyCode == DOWN) {
      panningChange.y = panSpeed;
    }
    else if(Character.toLowerCase(key) == 'd' || keyCode == RIGHT) {
      panningChange.x = panSpeed;
    }
    if(keyCode == SHIFT) {
      acceleratePanSpeed = true;
    }
  }
}
void keyReleased() {
  if(state == 0) {
    if(Character.toLowerCase(key) == 'w' || keyCode == UP || Character.toLowerCase(key) == 's' || keyCode == DOWN) {
      panningChange.y = 0;
    }
    if(Character.toLowerCase(key) == 'a' || keyCode == LEFT || Character.toLowerCase(key) == 'd' || keyCode == RIGHT) {
      panningChange.x = 0;
    }
    if(keyCode == SHIFT) {
       acceleratePanSpeed = false; 
    }
  }
}
//Other Functions
void renderWorld() { //Render the world
  int renderX = floor(panning.x)/tileSize;
  int renderY = floor(panning.y)/tileSize;
  for(int i = max(0,renderX); i < min(wsx,renderX+conformedWidth+tileSize); i++) {
    for(int j = max(0,renderY); j < min(wsy,renderY+conformedHeight+tileSize); j++) {
      image(tileImages[world[i][j]],(i*tileSize)-panning.x, (j*tileSize)-panning.y); //Then render the tile
    }
  }
}
void renderEntities() { //Render all entities
  for(int i = 0; i < entities.size(); i++) {
    entities.get(i).render();
  }
}
void renderWindows() { //Render all windows
  for(int i = windows.size()-1; i >= 0; i--) {
    windows.get(i).render();
    if(windows.get(i).delete) {
      windows.remove(i);
    }
  }
}
void loadLevel(String path) { //Load a level given the path
  PImage lvl = loadImage(path);
  for(int i = 0; i < wsx; i++) {
    for(int j = 0; j < wsy; j++) {
      color c = lvl.get(i, j);
      int type = 2000;
      if(c == color(128, 128, 128)) {
        type = 0; 
      }
      if(c == color(0, 0, 255)) {
        type = 1;
      }
      if(c == color(64, 64, 64)) {
        type = 2; 
      }
      world[i][j] = type;
    }
  }
}
void printChiefdom(Chiefdom chiefdom) { //Used for debug purposes
  println("Name: "+chiefdom.name+", Position: {"+chiefdom.x+","+chiefdom.y+"}");
}
void loadWindow(String path, String[] metadata) { //Displays a window given the path to the .lgl file
  String[] file = loadStrings(path);
  Window window = new Window(width/2, height/2, 100, 100, "Title");
  for(int i = 0; i < file.length; i++) {
    String text = file[i];
    if(metadata.length >= 1) text = text.replace("{metadata.0}", metadata[0]);
    if(metadata.length >= 2) text = text.replace("{metadata.1}", metadata[1]);
    String[] tokens = createTokens(text);
    if(tokens[0].equals("#")) { //If it's a comment
      continue; //Skip this iteration
    }
    if(tokens[0].equals("size")) { //Size command
      window.sizeX = int(tokens[1]);
      window.sizeY = int(tokens[2]);
    }
    if(tokens[0].equals("element")) { //Element command
      window.addElement(new WindowElement(int(tokens[1]), int(tokens[2])));
    }
    if(tokens[0].equals("position")) { //Position command
      window.x = int(tokens[1]);
      window.y = int(tokens[2]);
    }
    if(tokens[0].equals("title")) { //Title command
      window.title = tokens[1];
    }
  }
  windows.add(window);
}
String[] createTokens(String string) { //Create tokens from a given string
  ArrayList<String> tokens = new ArrayList<String>();
  char[] chars = string.toCharArray();
  String output = "";
  boolean ignoreSpace = false;
  for(int i = 0; i < chars.length; i++) {
    if((i == chars.length-1) && (chars[i] != ' ')) {
      if(chars[i] != '"') output += chars[i];
      tokens.add(output);
      continue;
    }
    if((chars[i] == ' ' && !ignoreSpace)) {
      tokens.add(output);
      output = "";
      continue; //Skip loop iteration
    }
    if(chars[i] == '"') {
      ignoreSpace = !ignoreSpace;
      continue;
    }
    output += chars[i];
  }
  println(output);
  Object[] temp = tokens.toArray(); //Conver tokens.toArray() from Object[] to String[]
  String[] temp2 = new String[temp.length];
  for(int i = 0; i < temp.length; i++) {
    temp2[i] = (String)temp[i];
  }
  printArray(temp2);
  return temp2;
}

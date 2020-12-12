int state = 0; //State the game is in
int wsx = 100; //World Size X
int wsy = 75; //World Size Y
int[][] world; //The World
PImage[] tileImages; //Images for specific tiles
String parentDirectory = ""; //Pointless as of now but will be used for modding and such
int tileSize = 64; //Size that each specific tile is. DO NOT CHANGE WITHOUT FIRST CHANGING THE IMAGES
PVector panning; //Amount of panning in X and Y
PVector panningChange; //Amount of change in the panning per frame
float panSpeed = tileSize/4; //How fast the camera pans
int conformedWidth; //Width expressed in a multiple of tileSize
int conformedHeight; //Height expressed in a multiple of tileSize

void settings() {
  fullScreen();
}
void setup() {
  world = new int[wsx][wsy]; //Init world
  loadLevel(parentDirectory+"image/level/level.png");
  tileImages = new PImage[2];
  tileImages[0] = loadImage(parentDirectory+"image/tile/ground.png"); //Ground tile
  tileImages[1] = loadImage(parentDirectory+"image/tile/water.png"); //Water tile
  panning = new PVector();
  panningChange = new PVector();
  conformedWidth = width/tileSize;
  conformedHeight = height/tileSize;
}
void draw() {
  if(state == 0) { //Chiefdom Select Screen
    background(0);
    panning.x += panningChange.x;
    panning.y += panningChange.y;
    renderWorld();
  }
}
void renderWorld() { //Render the world
  int renderX = floor(panning.x)/tileSize;
  int renderY = floor(panning.y)/tileSize;
  for(int i = max(0,renderX); i < min(wsx,renderX+conformedWidth+tileSize); i++) {
    for(int j = max(0,renderY); j < min(wsy,renderY+conformedHeight+tileSize); j++) {
      image(tileImages[world[i][j]],(i*tileSize)-panning.x, (j*tileSize)-panning.y); //Then render the tile
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
      world[i][j] = type;
    }
  }
}
void keyPressed() {
  if(state == 0) {
    if(key == 'w' || keyCode == UP) { //There's probably a way to do this with switch statements but honestly I can't be bothered
      panningChange.y = -panSpeed;
    }
    else if(key == 'a' || keyCode == LEFT) {
      panningChange.x = -panSpeed;
    }
    else if(key == 's' || keyCode == RIGHT) {
      panningChange.y = panSpeed;
    }
    else if(key == 'd' || keyCode == DOWN) {
      panningChange.x = panSpeed;
    }
  }
}
void keyReleased() {
  if(state == 0) {
    if(key == 'w' || keyCode == UP || key == 's' || keyCode == DOWN) {
      panningChange.y = 0;
    }
    if(key == 'a' || keyCode == LEFT || key == 'd' || keyCode == RIGHT) {
      panningChange.x = 0;
    }
  }
}

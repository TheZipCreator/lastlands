import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

int state = 3; //State the game is in
int wsx = 200; //World Size X
int wsy = 152; //World Size Y
int[][] world; //The World
PImage[] tileImages; //Images for tiles
PImage[] entityImages; //Images for entities
PImage[] notificationImages; //Images for notifications
PImage[] miscImages; //Images for anything else
PFont[] fonts; //Fonts
Minim minim; //minim
AudioPlayer[] sfx; //Sound effects
AudioPlayer[] music; //Music
int[] musicLength; //How long each song is
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
String currChiefdom = "Unknown";  //Tag of chiefdom the player is playing as
Node[][] astar_nodes; //Nodes for a* pathfinding algorithm
boolean debug = true;
String[] months = {"January","February","March","April","May","June","July","August","September","October","November","December"}; //Months
int[] days = {31,28,31,30,31,30,31,31,30,31,30,31}; //# of days in each month
int year = 2231; //Current year
int month = 0; //Current month
int day = 0; //Current day
boolean paused = true;
ArrayList<Notification> notifications;
int lastTrackTime; //Time when the last track was played
int currentTrack = 0; //Which track is currently being played
boolean enableMusic = false;
ArrayList<DiplomaticRelation> diplomacy; //All diplomatic relations between chiefdoms
ArrayList<Battle> battles; //Ongoing battles

//Processing Functions

void settings() {
  fullScreen();
}
void restart() {
  state = 3; //State the game is in
  wsx = 200; //World Size X
  wsy = 152; //World Size Y
  parentDirectory = "data"; //Pointless as of now but will be used for modding and such
  tileSize = 64; //Size that each specific tile is. DO NOT CHANGE WITHOUT FIRST CHANGING THE IMAGES
  panSpeed = 16; //How fast the camera pans
  acceleratePanSpeed = false; //Whether the pan speed is doubled or not
  currChiefdom = "Unknown";  //Tag of chiefdom the player is playing as
  debug = true;
  String[] temp1 = {"January","February","March","April","May","June","July","August","September","October","November","December"};
  months = temp1; //Months
  int[] temp2 = {31,28,31,30,31,30,31,31,30,31,30,31};
  days = temp2; //# of days in each month
  year = 2231; //Current year
  month = 0; //Current month
  day = 0; //Current day
  paused = true;
  currentTrack = 0; //Which track is currently being played
  enableMusic = false;
  setup();
}
void setup() {
  background(0);
  textSize(64);
  text("Loading", width/2, height/2);
  minim = new Minim(this);
  world = new int[wsx][wsy]; //Init world
  loadLevel(parentDirectory+"/image/level/level.png");
  tileImages = new PImage[3];
  tileImages[0] = loadImage(parentDirectory+"/image/tile/ground.png"); //Ground tile
  tileImages[1] = loadImage(parentDirectory+"/image/tile/water.png"); //Water tile
  tileImages[2] = loadImage(parentDirectory+"/image/tile/mountain.png"); //Mountain tile
  entityImages = new PImage[1];
  entityImages[0] = loadImage(parentDirectory+"/image/entity/tribe.png"); //Chiefdom entity
  notificationImages = new PImage[2];
  notificationImages[0] = loadImage(parentDirectory+"/image/notification/default.png");
  notificationImages[1] = loadImage(parentDirectory+"/image/notification/migration_required.png");
  miscImages = new PImage[5];
  miscImages[0] = loadImage(parentDirectory+"/image/misc/selection.png"); //Selection Box
  miscImages[1] = loadImage(parentDirectory+"/image/misc/population.png"); //Population icon in the GUI
  miscImages[2] = loadImage(parentDirectory+"/image/misc/paused.png"); //Paused icon
  miscImages[3] = loadImage(parentDirectory+"/image/misc/play.png"); //Play icon
  miscImages[4] = loadImage(parentDirectory+"/image/misc/battle.png"); //Battle icon
  fonts = new PFont[1];
  fonts[0] = loadFont(parentDirectory+"/font/Consolas.vlw"); //Load font
  sfx = new AudioPlayer[2];
  sfx[0] = minim.loadFile("sound/sfx/click.mp3"); //Click sound effect
  sfx[1] = minim.loadFile("sound/sfx/notification.mp3"); //Notification sound effect
  //Load music tracks
  String[] tracks = loadStrings(parentDirectory+"/sound/music/tracks.txt");
  music = new AudioPlayer[tracks.length/2];
  musicLength = new int[tracks.length/2];
  for(int i = 0; i < tracks.length; i+=2) {
    music[i/2] = minim.loadFile(tracks[i]);
    musicLength[i/2] = int(tracks[i+1]);
  }
  if(enableMusic) music[currentTrack].play();
  lastTrackTime = getTimeInSeconds();
  printArray(music);
  printArray(musicLength);
  textFont(fonts[0]);
  entities = new ArrayList<Entity>();
  windows = new ArrayList<Window>();
  notifications = new ArrayList<Notification>();
  diplomacy = new ArrayList<DiplomaticRelation>();
  int numChiefdoms = int(loadStrings(parentDirectory+"/data/chiefdom/amount.txt")[0]); //Get number of chiefdoms from amount.txt
  for(int i = 1; i <= numChiefdoms; i++) { //Add all chiefdoms to the array
    Chiefdom temp = new Chiefdom(0, 0, 0, parentDirectory+"/image/flag/example.png", "Unnamed Tribe", 1000, "Unknown");
    String[] info = loadStrings(parentDirectory+"/data/chiefdom/"+i+".txt");
    temp.x = int(info[0]);
    temp.y = int(info[1]);
    temp.setFlag(parentDirectory+info[2]);
    temp.pathToFlag = parentDirectory+info[2];
    temp.name = info[3];
    temp.tag = info[4];
    temp.population = int(info[5]);
    entities.add(temp);
  }
  panning = new PVector();
  panningChange = new PVector();
  conformedWidth = width/tileSize;
  conformedHeight = height/tileSize;
  astar_nodes = constructNodes();
  String[] metadata = {};
  loadWindow(parentDirectory+"/data/window/main_menu.lgl", metadata); //Open main menu
  battles = new ArrayList<Battle>(); //Initialize battles
}
void draw() {
  if(getTimeInSeconds() >= lastTrackTime+musicLength[currentTrack]) { //Play the next track if the current one ends
    currentTrack = floor(random(music.length));
    if(enableMusic) music[currentTrack].play();
    lastTrackTime = getTimeInSeconds();
  }
  if(state == 0 || state == 1 || state == 2) { //Basic map things a few modes do
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
      text("("+tileX+","+tileY+")", 0, height-8);
    }
  }
  if(state == 1) { //Play screen (screen where you actually play the game)
    ArrayList<Notification> tempNotifications = sortNotifications(notifications); //Sort notifications by urgency
    stroke(0);
    fill(0, 255, 255, 128);
    rect(0, 0, 320, 220); //Rectangle around flag
    rect(320, 0, width, 100); //Rectangle for stats
    rect(0, 220, 320, 30); //Rectangle for name
    rect(320, 100, 400, 37); //Rectangle for date
    for(int i = 0; i < tempNotifications.size(); i++) { //Render notifications and display hover
      tempNotifications.get(i).render(328+(i*76), 145);
      if(tempNotifications.get(i).collide(mouseX, mouseY, 328+(i*76), 145)) { //If the mouse is hovering over the notification
        tempNotifications.get(i).hover(); //Display hover texts
      }
    }
    for(int i = entities.size()-1; i >= 0; i--) { //Delete entities if they have the delete flag
        if(entities.get(i).delete) {
          entities.remove(i);
        }
    }
    for(int i = diplomacy.size()-1; i >= 0; i--) { //Delete diplomacy if nations in it doesn't exist anymore
        if(findChiefdom(diplomacy.get(i).chiefdomA) == -1 || findChiefdom(diplomacy.get(i).chiefdomB) == -1) {
          diplomacy.remove(i);
        }
    }
    fill(255);
    textSize(30);
    //println(currChiefdom);
    text(((Chiefdom)entities.get(findChiefdom(currChiefdom))).name, 10, 245); //Dispay current chiefdom's name and flag
    image(((Chiefdom)entities.get(findChiefdom(currChiefdom))).flag, 10, 10);
    image(miscImages[1], 330, 10); //Display population
    textSize(36);
    text(((Chiefdom)entities.get(findChiefdom(currChiefdom))).population, 404, 56);
    textSize(32); //Display date
    text(months[month]+" "+(day+1)+", "+year, 320, 132);
    if(paused) image(miscImages[2], 686, 102); //Display paused/play icon
    else image(miscImages[3], 686, 102);
    if(!paused && frameCount%5 == 0) dayPassed(); //Progress to next day if not paused
    displayPath(((Chiefdom)entities.get(findChiefdom(currChiefdom))).path); //Display the path of the player's chiefdom
  }
  if(state == 2) { //Move chiefdom screen
    fill(128, 128, 128, 64);
    noStroke();
    rect(0, 0, width, height);
    Chiefdom chiefdom = (Chiefdom)entities.get(findChiefdom(currChiefdom));
    int tileX = floor((mouseX+panning.x)/tileSize); //X position of the tile the player is hovering on
    int tileY = floor((mouseY+panning.y)/tileSize); //Y position of the tile the player is hovering on
    ArrayList<intvect> path = new ArrayList<intvect>();
    if(astar_nodes[tileX][tileY].traversable == true) {
      path = a_star(astar_nodes, new intvect(chiefdom.x, chiefdom.y), new intvect(tileX, tileY));
    }
    if(path != null) displayPath(path);
  }
  if(state == 3) { //Menu
    background(0);
  }
  if(state == 0 || state == 1 || state == 3) {
    renderWindows();
  }
}
void mousePressed() {
  if(state == 0 || state == 1 || state == 3) {
    if(mouseButton == LEFT) {
      for(int i = 0; i < windows.size(); i++) {
        windows.get(i).click();
      }
    }
  }
  if(state == 0) { //Chiefdom select screen
    if(mouseButton == LEFT) {
      for(int i = 0; i < entities.size(); i++) { //Detect if the player clicked on a chiefdom and if so open the "select chiefdom" window
        if(entities.get(i).collide(mouseX, mouseY) && entities.get(i) instanceof Chiefdom) {
          String[] metadata = {((Chiefdom)entities.get(i)).name, ((Chiefdom)entities.get(i)).pathToFlag, ((Chiefdom)entities.get(i)).tag};
          loadWindow(parentDirectory+"/data/window/select_chiefdom.lgl", metadata);
          sfx[0].play(); //Play click sound
        }
      }
    }
  }
  if(state == 1) { //Play screen
    if(mouseButton == LEFT) {
      if(entities.get(findChiefdom(currChiefdom)).collide(mouseX, mouseY)) { //Detect if the player clicked on their own chiefdom and if they did put them into the "move chiefdom" state
        state = 2;
        sfx[0].play(); //Play click sound
        return; //Stop execution of the mouseClick function
      }
      for(int i = 0; i < entities.size(); i++) { //Detect if the player clicked on a chiefdom and if so open the "chiefdom information" window
        if(entities.get(i).collide(mouseX, mouseY) && entities.get(i) instanceof Chiefdom) {
          if(((Chiefdom)entities.get(i)).tag != currChiefdom) {
            String[] metadata = {((Chiefdom)entities.get(i)).name, ((Chiefdom)entities.get(i)).pathToFlag, str(((Chiefdom)entities.get(i)).population), ((Chiefdom)entities.get(i)).tag, ((Chiefdom)entities.get(findChiefdom(currChiefdom))).tag};
            loadWindow(parentDirectory+"/data/window/chiefdom_information.lgl", metadata);
            sfx[0].play(); //Play click sound
          }
        }
      }
    }
  }
  if(state == 2) { //Chiefdom move screen
    //println("clicked");
    Chiefdom chiefdom = (Chiefdom)entities.get(findChiefdom(currChiefdom));
    int tileX = floor((mouseX+panning.x)/tileSize); //X position of the tile the player is hovering on
    int tileY = floor((mouseY+panning.y)/tileSize); //Y position of the tile the player is hovering on
    ArrayList<intvect> path = new ArrayList<intvect>();
    if(astar_nodes[tileX][tileY].traversable == true) { //If the player is hovering over a block that can be walked on
      path = a_star(astar_nodes, new intvect(chiefdom.x, chiefdom.y), new intvect(tileX, tileY));
    }
    if(path != null) { //If there is a valid path
      sfx[0].play(); //Play click sound
      //Fix the path
      if(path.size() > 0) {
        path = reversePath(path);
        path.remove(0);
        path.add(new intvect(tileX, tileY));
      }
      ((Chiefdom)(entities.get(findChiefdom(currChiefdom)))).path = path; //Tell the player's chiefdom to move
      ((Chiefdom)(entities.get(findChiefdom(currChiefdom)))).daysUntilNextMove = 4;
      state = 1; //Go back to play screen
    }
  }
}
void mouseDragged() {
  if(state == 0 || state == 1) {
    if(mouseButton == LEFT) {
      for(int i = 0; i < windows.size(); i++) {
        windows.get(i).drag();
      }
    }
  }
}
void keyPressed() {
  if(key == ESC) { //Cancel escape key. To detect presses of escape detect if they pressed ♣ (alt+5)
    key = '♣';
  }
  if(state == 0 || state == 1 || state == 2) {
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
  if(state == 1) { //Play screen
    if(key == ' ') {
      for(int i = 0; i < windows.size(); i++) { //Prevent unpausing if a force pause window exists
        if(windows.get(i).force_pause) return; 
      }
      paused = !paused;
      sfx[0].play(); //Play click sound effect
    }
    if(debug) {
      if(key == '.') {
        dayPassed();
      }
    }
  }
  if(state == 0 || state == 1) { //Chiefdom select and play screen
    if(key == '♣') {
      String[] metadata = {};
      loadWindow(parentDirectory+"/data/window/menu.lgl", metadata); //Open menu
      paused = true; //Pause the game
    }
  }
  if(state == 2) { //Move chiefdom screen
    if(key == '♣') {
      state = 1; //Go back to play screen
    }
  }
}
void keyReleased() {
  if(state == 0 || state == 1 || state == 2) {
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
void renderEntities() { //Render all entities (and also battles)
  for(int i = 0; i < entities.size(); i++) {
    entities.get(i).render();
  }
  for(int i = 0; i < battles.size(); i++) {
    battles.get(i).render();
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
      if(c == color(128, 128, 128)) { //Ground
        type = 0; 
      }
      if(c == color(0, 0, 255)) { //Water
        type = 1;
      }
      if(c == color(64, 64, 64)) { //Mountain
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
    for(int j = 0; j < metadata.length; j++) { //Replace {metadata.x} with the actual metadata
      text = text.replace("{metadata."+j+"}", metadata[j]);
    }
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
      if(tokens[1].equals("center")) {
        window.x = (width/2)-(window.sizeX/2);
        window.y = (height/2)-(window.sizeY/2);
      } else {
        window.x = int(tokens[1]);
        window.y = int(tokens[2]);
      }
    }
    if(tokens[0].equals("title")) { //Title command
      window.title = tokens[1];
    }
    if(tokens[0].equals("text")) { //Text command
      window.addElement(new Text(int(tokens[2]), int(tokens[3]), tokens[1], int(tokens[4]), color(int(tokens[5]), int(tokens[6]), int(tokens[7]))));
    }
    if(tokens[0].equals("image")) { //Image command
      if(tokens.length < 5) window.addElement(new Image(int(tokens[2]), int(tokens[3]), loadImage(tokens[1])));
      else window.addElement(new Image(int(tokens[2]), int(tokens[3]), loadImage(tokens[1]), tokens[4]));
    }
    if(tokens[0].equals("button")) { //Button command
      ArrayList<String> temp = new ArrayList<String>();
      if(tokens.length > 6) { //Get all args for the LEL script
        for(int k = 7; k < tokens.length; k++) {
          temp.add(tokens[k]);
        }
      }
      Object[] temp2 = temp.toArray(); //Convert temp.toArray() from Object[] to String[]
      String[] temp3 = new String[temp2.length];
      for(int k = 0; k < temp2.length; k++) {
        temp3[k] = (String)temp2[k];
      }
      window.addElement(new Button(int(tokens[1]), int(tokens[2]), int(tokens[3]), int(tokens[4]), tokens[5], parentDirectory+tokens[6], temp3)); //Finally add the button
    }
    if(tokens[0].equals("disable_x")) { //Disable X command
      window.disableX = true;
    }
    if(tokens[0].equals("line")) { //Line command
      window.addElement(new Line(int(tokens[1]), int(tokens[2]), int(tokens[3]), int(tokens[4]), color(int(tokens[5]), int(tokens[6]), int(tokens[7]))));
    }
    if(tokens[0].equals("diplomaticbox")) { //Diplomatic box command
      window.addElement(new DiplomaticBox(int(tokens[1]), int(tokens[2]), int(tokens[3]), tokens[4], int(tokens[5])));
    }
    if(tokens[0].equals("print")) { //print command
      println(tokens[1]);
    }
    if(tokens[0].equals("force_pause")) { //force pause command
      paused = true;
      window.force_pause = true;
    }
  }
  windows.add(window);
}
void loadScript(String path, String[] metadata) { //Loads a script given the path to the .lel file
  String[] file = loadStrings(path);
  for(int i = 0; i < file.length; i++) {
    String text = file[i];
    for(int j = 0; j < metadata.length; j++) { //Replace {metadata.x} with the actual metadata
      text = text.replace("{metadata."+j+"}", metadata[j]);
    }
    String[] tokens = createTokens(text);
    if(tokens[0].equals("#")) { //If it's a comment
      continue; //Skip this iteration
    }
    if(tokens[0].equals("change_state")) { //Change state command
      state = int(tokens[1]);
    }
    if(tokens[0].equals("reset_windows")) { //Reset windows command
      for(int j = 0; j < windows.size(); j++) { //Mark all windows for deletion
        windows.get(j).delete = true;
      }
    }
    if(tokens[0].equals("play")) { //Play command
      currChiefdom = tokens[1];
    }
    if(tokens[0].equals("open_window")) { //Open window
      ArrayList<String> temp = new ArrayList<String>(); //Create an arraylist with all metadata
      for(int j = 2; j < tokens.length; j++) {
        temp.add(tokens[j]);
      }
      String[] temp2 = new String[temp.size()]; //Turn the arraylist into an array
      for(int j = 0; j < temp2.length; j++) {
        temp2[j] = temp.get(j);
      }
      loadWindow(parentDirectory+tokens[1], temp2);
    }
    if(tokens[0].equals("restart")) { //Restart game
      restart();
    }
    if(tokens[0].equals("diplomacy")) { //Diplomacy command
      diplomacy.add(new DiplomaticRelation(int(tokens[1]), tokens[2], tokens[3]));
    }
    if(tokens[0].equals("print")) { //print command
      println(tokens[1]);
    }
    if(tokens[0].equals("exterminate")) { //exterminate command
      entities.remove(findChiefdom(tokens[1]));
    }
    if(tokens[0].equals("make_tributary")) { //make tributary command
      diplomacy.add(new DiplomaticRelation(2, tokens[1], tokens[2]));
    }
    if(tokens[0].equals("integrate")) { //integrate command
      entities.get(findChiefdom(tokens[1])).specificAction(0, ((Chiefdom)entities.get(findChiefdom(tokens[2]))).population); //Add population of chiefdomB to chiefdomA
      entities.remove(findChiefdom(tokens[2])); //Remove chiefdomB
    }
  }
}
int findChiefdom(String tag) { //Gives the index of a chiefdom in the entities array given the tag
  for(int i = 0; i < entities.size(); i++) {
    if(entities.get(i) instanceof Chiefdom) {
      if(((Chiefdom)entities.get(i)).tag.equals(tag)) return i;
    }
  }
  return -1;
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
  //println(output);
  Object[] temp = tokens.toArray(); //Conver tokens.toArray() from Object[] to String[]
  String[] temp2 = new String[temp.length];
  for(int i = 0; i < temp.length; i++) {
    temp2[i] = (String)temp[i];
  }
  //printArray(temp2);
  return temp2;
}

void displayPath(ArrayList<intvect> path) { //Displays a list of integer vectors as a line
  stroke(0, 0, 255);
  strokeWeight(5);
  for(int i = 1; i < path.size()-1; i++) {
    line(((path.get(i).x*tileSize)+tileSize-panning.x)-tileSize/2, ((path.get(i).y*tileSize)+tileSize-panning.y)-tileSize/2, ((path.get(i+1).x*tileSize)+tileSize-panning.x)-tileSize/2, ((path.get(i+1).y*tileSize)+tileSize-panning.y)-tileSize/2);
  }
  //TODO: Display path correctly
  strokeWeight(1);
}
void dayPassed() { //Call once a day has passed
  day++;
  if(day >= days[month]) { //Update day
    day = 0;
    month++;
  }
  if(month >= 12) {
    month = 0;
    year++;
  }
  for(int i = 0; i < entities.size(); i++) { //Tell all entities a day has passed
    entities.get(i).dayPassed();
  }
  if(((Chiefdom)entities.get(findChiefdom(currChiefdom))).daysSinceLastMoved == 54) addNotification(1); //Tell the player they need to move
  if(((Chiefdom)entities.get(findChiefdom(currChiefdom))).daysSinceLastMoved < 54) removeNotification(1); //Remove the "migration required" notification
  for(int i = 0; i < entities.size(); i++) { //Update AI of non-player chiefdoms
    if(entities.get(i) instanceof Chiefdom && i != findChiefdom(currChiefdom)) {
      ((Chiefdom)entities.get(i)).updateAI();
    }
  }
  for(int i = battles.size()-1; i >= 0; i--) { //Update battles
    battles.get(i).tick();
    if(battles.get(i).winner != -1) { //If one of the battles was won
      String winner_tag = "";
      String loser_tag = "";
      if(battles.get(i).winner == 0) { //If the attacker won
        winner_tag = battles.get(i).attackerParticipants.get(0);
        loser_tag = battles.get(i).defenderParticipants.get(0);
      } else { //If the defender won
        winner_tag = battles.get(i).defenderParticipants.get(0);
        loser_tag = battles.get(i).attackerParticipants.get(0);
      }
      entities.get(findChiefdom(winner_tag)).specificAction(1, 0);
      entities.get(findChiefdom(loser_tag)).specificAction(1, 0);
      println("a");
      println(winner_tag, currChiefdom);
      if(winner_tag.equals(currChiefdom)) { //If the winner is a player
        println("b");
        String md[] = {loser_tag, ((Chiefdom)entities.get(findChiefdom(loser_tag))).name, currChiefdom};
        loadWindow("data/window/battle_won.lgl", md); //Display the "battle won" window
      }
      for(int j = diplomacy.size()-1; j >= 0; j--) {
        if(diplomacy.get(j).containsMembers(winner_tag, loser_tag)) {
          diplomacy.remove(j);
        }
      }
      battles.remove(i);
    }
  }
}
ArrayList<intvect> reversePath(ArrayList<intvect> path) {
  ArrayList<intvect> reversedPath = new ArrayList<intvect>();
  for(int i = path.size()-1; i >= 0; i--) {
    reversedPath.add(path.get(i));
  }
  return reversedPath;
}
void addNotification(int type) { //Add a notification only given a type (types are listed in the notification object)
  sfx[1].play(); //Notification sound effect
  Notification n = new Notification(byte(0), notificationImages[0], "Example Notification", 0); //Notification to add
  switch(type) {
    case 1:
    n = new Notification(byte(0), notificationImages[1], "The resources in this area have ran out. You need to migrate or your population will drop.", 1); //Migration required
    break;
    default:
    break;
  }
  notifications.add(n);
}
void removeNotification(int type) { //Removes all notifications of a specified type
  for(int i = notifications.size()-1; i >= 0; i++) {
    if(notifications.get(i).type == type) {
      notifications.remove(i);
      return; //Removed the notification, we're done as there should only be one instance of a specific notification at once
    }
  }
}
ArrayList<Notification> sortNotifications(ArrayList<Notification> notifications) { //Sort notifications by urgency
  ArrayList<Notification> result = new ArrayList<Notification>();
  for(int i = 0; i < notifications.size(); i++) {
    if(notifications.get(i).urgency == 0) result.add(notifications.get(i));
  }
  for(int i = 0; i < notifications.size(); i++) {
    if(notifications.get(i).urgency == 1) result.add(notifications.get(i));
  }
  for(int i = 0; i < notifications.size(); i++) {
    if(notifications.get(i).urgency == 2) result.add(notifications.get(i));
  }
  return result;
}
int getTimeInSeconds() {
  return second()+(minute()*60)+(hour()*60*60)+(day()*60*60*24);
}

int cap(int value, int cap) {
  if(value > cap) value = cap;
  return value;
}

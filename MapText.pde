class MapText {
  String text = "";
  int x;
  int y;
  MapText(int x, int y, String t) {
    this.x = x;
    this.y = y;
    text = t;
  }
  
  void render() {
    textSize(64);
    fill(255, 255, 255, 128);
    textAlign(CENTER);
    text(text, (x*tileSize)-panning.x, ((y*tileSize)+tileSize/2)+16-panning.y);
    textAlign(LEFT);
  }
}

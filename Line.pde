class Line extends WindowElement {
  int x1;
  int y1;
  int x2;
  int y2;
  color col;
  Line(int x1, int y1, int x2, int y2, color col) {
    super(x1, y1);
    this.x1 = x1;
    this.x2 = x2;
    this.x2 = x2;
    this.y2 = y2;
    this.col = col;
  }
  void render(int windowX, int windowY) {
    stroke(red(col), green(col), blue(col));
    line(x1+windowX, y1+windowY, x2+windowX, y2+windowY);
  }
  
}

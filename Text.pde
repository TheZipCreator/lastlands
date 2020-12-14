class Text extends WindowElement {
  int x; //Position relative to the window
  int y;
  String text; //Text to be displayed
  int textSize; //Size of the text
  color textColor; //Text color
  Text(int x, int y, String text, int textSize, color textColor) {
    super(x, y);
    this.text = text;
    this.textSize = textSize;
    this.textColor = textColor;
  }
  void render() {
    fill(red(textColor), blue(textColor), green(textColor));
    textSize(textSize);
    text(text, x, y);
  }
  
}

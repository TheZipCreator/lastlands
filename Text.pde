class Text extends WindowElement {
  String text; //Text to be displayed
  int textSize; //Size of the text
  color textColor; //Text color
  Text(int x, int y, String text, int textSize, color textColor) {
    super(x, y);
    this.text = text;
    this.textSize = textSize;
    this.textColor = textColor;
  }
  void render(int windowX, int windowY) {
    fill(red(textColor), blue(textColor), green(textColor));
    textSize(textSize);
    text(text, windowX+x, windowY+y);
  }
  
}

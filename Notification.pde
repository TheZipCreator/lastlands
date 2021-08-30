class Notification {
  byte urgency; //Severity of the notification. 0=Very Urgent 1=Somewhat Urgent 2=Not Urgent
  PImage image; //Image displayed by the notification. Should be 64x64
  String text; //Text displayed when hovering over the notification
  int type; //What type of notification it is
  /*
  0=Example notificaction
  1=Migration required
  */
  
  Notification(byte urgency, PImage image, String text, int type) {
    this.urgency = urgency;
    this.image = image;
    this.text = text;
    this.type = type;
  }
  
  void render(int x, int y) {
    switch(urgency) { //Red if very urgent, yellow if somewhat urgent, green if not urgent
      case 0:
      fill(255, 0, 0, 128);
      break;
      case 1:
      fill(255, 255, 0, 128);
      break;
      case 2:
      fill(0, 0, 255, 128);
      break;
    }
    rect(x, y, 68, 68);
    image(image, x+4, y+4);
  }
  void hover() {
    fill(255);
    textSize(16);
    text(text, mouseX, mouseY);
  }
  boolean collide(int testX, int testY, int posX, int posY) { //Test if a position collides with the notification
    return (testX > posX && testX < posX+68 && testY > posY && testY < posY+68);
  }
}

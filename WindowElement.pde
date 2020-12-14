class WindowElement { //Used for things that go on windows (such as buttons, text, 
   int x; //Position relative to the window
   int y;
   
   WindowElement(int x, int y) {
     this.x = x;
     this.y = y;
   }
   
   void render(int windowX, int windowY) {
     textSize(32);
     fill(255);
     text("Invalid Element", windowX+x, windowY+y);
   }
}

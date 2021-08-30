class WindowElement { //Used for things that go on windows (such as buttons, text, etc.
   int x; //Position relative to the window
   int y;
   boolean deleteParent; //If enabled, the parent of this WindowElement will be removed next iteration
   
   WindowElement(int x, int y) {
     this.x = x;
     this.y = y;
     deleteParent = false;
   }
   
   void render(int windowX, int windowY) {
     textSize(32);
     fill(255);
     text("Invalid Element", windowX+x, windowY+y);
   }
   
   void collide(int colX, int colY, int windowX, int windowY) {
     //This is filled by child objects but not by the WindowElement itself
   }
   void hover(int colX, int colY, int windowX, int windowY) {
     //This is filled by child objects but not by the WindowElement itself
   }
}

class Image extends WindowElement {
   PImage image;
   String hover;
   
   Image(int x, int y, PImage image) {
     super(x, y);
     this.image = image;
     hover = "";
   }
   Image(int x, int y, PImage image, String hover) {
     super(x, y);
     this.image = image;
     this.hover = hover;
   }
   
   void render(int windowX, int windowY) {
     image(image, windowX+x, windowY+y);
   }
   void hover(int colX, int colY, int windowX, int windowY) {
     if(colX > x+windowX && colX < x+windowX+image.width && colY > y+windowY && colY < y+windowY+image.height) {
       textSize(16);
       text(hover, mouseX, mouseY);
       //println(hover);
     }
   }
}

import processing.video.*;

int[] previousFrame;
Capture video;

int maxBrightPos=0;
int row;
int col;
float pixBright;
color black=color(0);
color white=color(255);

void setup() {
  size(640, 480);
  
  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, width, height);
  
  // Start capturing the images from the camera
  video.start(); 
  loadPixels();
}

void draw() {
  if (video.available()) {
    // When using video to manipulate the screen, use video.available() and
    // video.read() inside the draw() method so that it's safe to draw to the screen
    video.read(); // Read the new frame from the camera
    if (mousePressed) {
      image(video, 0, 0) ; }
    else {
    
    video.loadPixels(); // Make its pixels[] array available
    int currentPos;
    for(row=0; row<video.height; row++){ 
      maxBrightPos=0;
      float maxBright = 70;
      for(col=0; col<video.width; col++){
        currentPos = row * video.width + col;
        pixBright=green(video.pixels[currentPos]);
        if(pixBright>maxBright){
          maxBright=pixBright;
          maxBrightPos=currentPos;  }
        pixels[currentPos]=black;  }
      pixels[maxBrightPos]=white;  }
    updatePixels();  }
  }
  }


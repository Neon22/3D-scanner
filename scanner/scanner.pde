import processing.video.*;
import processing.serial.*;

//objects
PFont f;
Capture video;
Serial myPort;
PrintWriter output;

//colors
color black=color(0);
color white=color(255);

//variables
int iteration; //iteration
float pixBright;
// float maxBright=70; // brightness() reports highest of RGB, from 0-255 . This needs to be autotuned but I see that 70 works well for now.
int maxBrightPos=0;
int prevMaxBrightPos;
int cntr=1;
int row;
int col;

//scanner parameters
float pics_per_rev = 480;  //number of phases profiling per revolution
float angle_per_step = 2*PI/pics_per_rev;  //angle between 2 profiles [radian]
float cam_angle = .96363 ;  // the angle measured from vertical to the platter laser line. [radians]
float turntable_center_horizontal = 245 ;  // Use GIMP to determine this X of center platter (first # near bottom)
float turntable_center_vertical = 370 ;    // Use GIMP to determine this Y of center platter (second # near bottom)
float camera_x_mod = 1.3;  // pixels per millimeter for horizontal
float camera_y_mod = 1.3;  // pixels per millimeter for vertical
                           // Use the enclosed checkerboard and then take picture. Then count how px for each and divide by 10 (10mm sq.)




//coordinates
float x, y, z;  //cartesian cords., [milimeter]

//================= CONFIG ===================

void setup() {
  size(640, 480);
  strokeWeight(1);
  smooth();
  background(0);
 
  //fonts
  f=createFont("Arial",16,true);
   
  //video conf.
  video = new Capture(this, width, height);
  video.start();
 
  //Serial (COM) conf.
  println(Serial.list());
  myPort=new Serial(this, Serial.list()[0], 9600);
//  myPort.write('L');
  
  //output file
  output=createWriter("pointcloud.asc");  //the pointcloud gets outputted to pointcloud.asc
  
}

//============== MAIN PROGRAM =================

void draw() {

  video.read();
  image(video, 0, 0, width, height);
  video.loadPixels();
  delay(2000);
  for (iteration=0;iteration<pics_per_rev;iteration++) {
    video.read();
    image(video, 0, 0, width, height);
    video.loadPixels();
    for (int n=0;n<video.width*video.height;n++){
        video.pixels[n]=video.pixels[n];
        }
    video.updatePixels();
    set(20,20,video);
    String file_name="raw_image-"+nf(iteration+1, 3)+".png";
    video.save(file_name);
    turn_platter();
    
      }
    
  turn_platter();
  line_processor();
  noLoop(); 
}

//============== Line Calculator =================


void line_processor(){
  for (iteration=0; iteration<pics_per_rev; iteration++){
   
    String file_name="raw_image-"+nf(iteration+1, 3)+".png";
    PImage scan=loadImage(file_name);                          //This loads the images we just collected
    String file_name2="line_image-"+nf(iteration+1, 3)+".png";
    PImage line_image=createImage(scan.width, scan.height, RGB);
    scan.loadPixels();
    line_image.loadPixels();
    int currentPos;
    println(iteration * (360/pics_per_rev));
    output.println("// image  " + nf(iteration+1, 3) );

    for(row=0; row<scan.height; row++){  //starting row analysis
      maxBrightPos=0;
      float maxBright = 70; // have to set this down here, no clue why
      for(col=0; col<scan.width; col++){
        currentPos = row * scan.width + col;
        pixBright=green(scan.pixels[currentPos]);
        if(pixBright>maxBright){
          maxBright=pixBright;
          maxBrightPos=currentPos;   }
        line_image.pixels[currentPos]=black; //setting all pixels black
      }
      line_image.pixels[maxBrightPos]=white; //setting brightest pixel white
      
      if(maxBrightPos!=0) {
        XYZ_calculate( (maxBrightPos - (scan.width*row)) , (row), iteration);
      }
      
    }//end of row analysis

    line_image.updatePixels();
    line_image.save(file_name2);
   
  }
  output.flush();
  output.close();

}


void XYZ_calculate(int current_col, int current_row, int current_iteration) {
  x = (current_col + 1 - turntable_center_horizontal)/( sin(cam_angle) ) * sin(angle_per_step * current_iteration) ;
  y = -1*((current_col + 1 - turntable_center_horizontal)/( sin(cam_angle) ) * cos(angle_per_step * current_iteration)) ;
  z = ( (turntable_center_vertical - current_row) - ((current_col - turntable_center_horizontal)/(tan(-cam_angle))));  
  output.println(x + "," + y + "," + z);
}


void turn_platter() {  //sending command to turn
  myPort.write('F');
  int finish = 0 ;   // Serves as the delay. Arduino sens period when stepper command is done.
    while (finish != '.' ) {
          finish = myPort.read(); }
  }
  


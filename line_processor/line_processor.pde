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
int maxBrightPos=0;
int row;
int col;

//scanner parameters
float pics_per_rev = 120;  //number of phases profiling per revolution
float angle_per_step = 2*PI/pics_per_rev;  //angle between 2 profiles [radian]
float cam_angle = .96363 ;  // the angle measured from vertical to the platter laser line. [radians]
float turntable_center_horizontal = 258 ;  // Use GIMP to determine this X of center platter (first # near bottom)
float turntable_center_vertical = 373 ;    // Use GIMP to determine this Y of center platter (second # near bottom)
float camera_x_mod = 1.3;  // pixels per millimeter for horizontal
float camera_y_mod = 1.3;  // pixels per millimeter for vertical
                           // Use the enclosed checkerboard and then take picture. Then count how px for each and divide by 10 (10mm sq.)


//coordinates
float x, y, z;  //cartesian cords., [milimeter]
// float pxmmpoz = 13; //pixels per milimeter horizontally 1px=0.2mm
// float pxmmpion = 13; //pixels per milimeter vertically 1px=0.2mm

//================= CONFIG ===================

void setup() {
  size(640, 480);
  strokeWeight(1);
  smooth();
  background(0);
 
  //fonts
  f=createFont("Arial",16,true);

  //output file
  output=createWriter("pointcloud.asc");  //the pointcloud gets outputted to pointcloud.asc
  
}

//============== MAIN PROGRAM =================

void draw() {
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

  noLoop(); 
}



void XYZ_calculate(int current_col, int current_row, int current_iteration) {
  x = camera_x_mod*(current_col + 1 - turntable_center_horizontal)/( sin(cam_angle) ) * sin(angle_per_step * current_iteration) ;
  y = -1*camera_y_mod*((current_col + 1 - turntable_center_horizontal)/( sin(cam_angle) ) * cos(angle_per_step * current_iteration)) ;
  z = ( (turntable_center_vertical - current_row) - ((current_col - turntable_center_horizontal)/(tan(-cam_angle))));  
  output.println(x + "," + y + "," + z);
}


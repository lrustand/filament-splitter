
/************************************
 *
 * Parametric multi filament splitter,
 * takes multiple bowden connections
 * and allows for switching between
 * different extruders and filaments
 * with one hotend.
 *
 * This model depends on the
 * libraries threads.scad and
 * text_on.scad, and needs them to
 * be in the same folder as this
 * file.
 * They should be distributed with
 * this file, but if they aren't you
 * can find them here:
 * http://dkprojects.net/openscad-threads/
 *
 *  and here:
 * https://github.com/brodykenrick/text_on_OpenSCAD
 *
 ***********************************/

// import libraries
use <threads.scad>
use <text_on.scad>

/*----------------------------------*
 *  Begin user variables
 *----------------------------------*/

filament = 1.75; // Filament diameter

/* Bowden connector types to choose from:
   1=PC4-M5, 2=PC4-M6, 3=PC4-01,
   4=PC4-02, 5=PC6-M5, 6=PC6-M6,
   7=PC6-01, 8=PC6-02, 9=PC8-01,
   10=PC8-02
 Or type 0 to manually specify dimensions below */
bowden_type = 1;

// The following thread variables are only used if bowden_type is 0.
thread_dia = 14; // Bowden thread diameter
nut_size = 18; // Bowden nut size
thread_pitch = 0; // Bowden thread pitch. If left as 0, we will try to guess it.

thread_depth = 4;

// You may need to add or subtract a little from the thread diameter to make them fit depending on your printer
thread_correction = 0.5;
threads = false; // Used to disable threads while editing to reduce rendering time

holes = 5; // Number of filament inputs
center_hole = true; // Center hole makes the part easier to print

bot_conn = "e3d"; // e3d, bowden, none. (Bottom connector type)

angle = 15; // Angle of filament hole (low is good, but too low takes too much space). 15 is a good default
col_height = 5;  // Collector height (0 to disable). Correcting angle of filament before entering hotend/bowden makes transition smoother.
round_numbers = true; // Round off body dimensions to integer numbers

/*----------------------------------*
 *  End user variables
 *----------------------------------*/




/*----------------------------------*
 *  Begin calculated constants
 *----------------------------------*/

letter_depth = 0.5;
font = "Liberation Sans";


thread_dia_ =
     (bowden_type==1) ? 5      //PC4-M5
    :(bowden_type==2) ? 6      //PC4-M6
    :(bowden_type==3) ? 9.728  //PC4-01
    :(bowden_type==4) ? 13.157 //PC4-02

    :(bowden_type==5) ? 5      //PC6-M5
    :(bowden_type==6) ? 6      //PC6-M6
    :(bowden_type==7) ? 9.728  //PC6-01
    :(bowden_type==8) ? 13.157 //PC6-02

    :(bowden_type==9) ? 9.728  //PC8-01
    :(bowden_type==10)? 13.157 //PC8-02
    :thread_dia;

nut_size_ =
     (bowden_type==1) ? 10 //PC4-M5
    :(bowden_type==2) ? 10 //PC4-M6
    :(bowden_type==3) ? 10 //PC4-01
    :(bowden_type==4) ? 14 //PC4-02

    :(bowden_type==5) ? 12 //PC6-M5
    :(bowden_type==6) ? 12 //PC6-M6
    :(bowden_type==7) ? 12 //PC6-01
    :(bowden_type==8) ? 14 //PC6-02

    :(bowden_type==9) ? 14 //PC8-01
    :(bowden_type==10)? 14 //PC8-02
    :(
        (nut_size==0) ? thread_dia_
        :nut_size
     );

thread_pitch_ =
     (bowden_type==1) ? 0.8   //PC4-M5
    :(bowden_type==2) ? 1     //PC4-M6
    :(bowden_type==3) ? 0.907 //PC4-01
    :(bowden_type==4) ? 1.337 //PC4-02

    :(bowden_type==5) ? 0.8   //PC6-M5
    :(bowden_type==6) ? 1     //PC6-M6
    :(bowden_type==7) ? 0.907 //PC6-01
    :(bowden_type==8) ? 1.337 //PC6-02

    :(bowden_type==9) ? 0.907 //PC8-01
    :(bowden_type==10)? 1.337 //PC8-02
    :thread_pitch;

thread_depth_ =
     (bowden_type==1) ? 4 //PC4-M5
    :(bowden_type==2) ? 4 //PC4-M6
    :(bowden_type==3) ? 6 //PC4-01
    :(bowden_type==4) ? 8 //PC4-02

    :(bowden_type==5) ? 4 //PC6-M5
    :(bowden_type==6) ? 4 //PC6-M6
    :(bowden_type==7) ? 6 //PC6-01
    :(bowden_type==8) ? 8 //PC6-02

    :(bowden_type==9) ? 6 //PC8-01
    :(bowden_type==10)? 8 //PC8-02
    :thread_depth;

// Threads per inch. Used for british pipe thread
thread_tpi_ =
     (bowden_type==3) ? 28 //PC4-01
    :(bowden_type==4) ? 19 //PC4-02

    :(bowden_type==7) ? 28 //PC6-01
    :(bowden_type==8) ? 19 //PC6-02

    :(bowden_type==9) ? 28 //PC8-01
    :(bowden_type==10)? 19 //PC8-02
    :0; //Others

english =
     (bowden_type==3) ? true //PC4-01
    :(bowden_type==4) ? true //PC4-02

    :(bowden_type==7) ? true //PC6-01
    :(bowden_type==8) ? true //PC6-02

    :(bowden_type==9) ? true //PC8-01
    :(bowden_type==10)? true //PC8-02
    :false; //Others


// Turning diameter of nut
nut_dia = nut_size_ / cos(30);

// Holes along the edges
edge_holes = (holes>4) ? holes-1 : holes;

// Height needed for clearance in the circumference direction
function h_perimeter(dia=nut_dia) =
    (dia+1)/(2*tan(angle)*cos((edge_holes-2)*180/(2*edge_holes)))
  + (center_hole ?
      filament/(2*sin(angle))
      :0);

// Height needed for clearance in the radial direction
function h_radial(dia=nut_dia) =
    (dia+1)/(2*tan(angle))
  + (holes>4 ?
      (dia+1)/(2*sin(angle))
      :(center_hole ?
        filament/(2*sin(angle))
        :0
       )
    );
function h_perimeter_thread() =
  h_perimeter(
    dia = thread_dia_) + thread_depth;
function h_radial_thread() =
  h_radial(
    dia = thread_dia_) + thread_depth;

// Calculate height needed for clearance in all directions
height_unrounded = max(
  h_perimeter(),
  h_perimeter_thread(),
  h_radial(),
  h_radial_thread());

height_rounded =
    ceil(height_unrounded)
    //Need to add 0.3 to get even
  + ((bot_conn=="e3d") ? 0.3 : 0);

height = (round_numbers) ? height_rounded : height_unrounded;

// Width needed for square hole configurations (4 or 5 holes)
body_width_square =
    2*height*sin(angle/sqrt(2))
  + thread_dia_*cos(angle/sqrt(2));

// Width needed for circular hole configurations (for the moment all other hole counts)
body_width_round =
    height*sin(angle)*2
  + thread_dia_*cos(angle);

body_width_t =
   (
     (holes==5 || holes==4)?body_width_square
     :body_width_round
   ) + 3;

// Body width must be greater than e3d connector if using one
body_width_unrounded =
      max(
        body_width_t,
        (bot_conn=="e3d" ? 30 : 0)
      );
body_width_rounded = ceil(body_width_unrounded);

body_width =
    (round_numbers) ? body_width_rounded
    :body_width_unrounded;

// Body length must be greater than e3d connector
body_length_unrounded = max(((holes==2) ? thread_dia_+2 : body_width_t), 18);
body_length_rounded = ceil(body_length_unrounded);

body_length =
    (round_numbers) ? body_length_rounded
    :body_length_unrounded;

clamp_height =
  (bot_conn=="e3d") ? 13.7 : 0;

// This is how high the main filament holes start.
pad_height = clamp_height
  + (bot_conn=="bowden" ? thread_depth : 0)
  + col_height;

// This is the total height of the whole thing
body_height = height + pad_height;

/*----------------------------------*
 *  End calculated constants
 *----------------------------------*/





/*----------------------------------*
 *  Begin variable sanity tests
 *----------------------------------*/

if(bot_conn != "bowden" &&
   bot_conn != "e3d" &&
   bot_conn != "none")
  echo(str("WARNING: Unknown connector type: ",bot_conn));

if(filament > thread_dia_)
  echo("WARNING: Filament diameter bigger than thread diameter")

if(filament > nut_dia_)
  echo("WARNING: Filament diameter bigger than nut diameter")

if(thread_dia_ > nut_dia_)
  echo("WARNING: Thread diameter bigger than nut diameter")

/*----------------------------------*
 *  End variable sanity tests
 *----------------------------------*/




 // Print geometries
 echo("Printing body dimensions:");
 echo(str("Height=",body_height,
          ", Width=",body_width,
          ", Length=",body_length));

//####################################

/*----------------------------------*
 *  Begin modules
 *----------------------------------*/

 // Bowden threads module
 //----------------------
module bowden_threads(){
  if(threads==false){
    cylinder(
      d =  thread_dia_ + thread_correction,
      h = thread_depth_
    );
  }
  else if(english){
    english_thread(
      diameter =
         (thread_dia_
         +thread_correction) / 25.4,
      threads_per_inch = thread_tpi_,
      taper = 1/16,
      length = thread_depth_ / 25.4,
      internal = true
    );
  }
  else {
    metric_thread(
      diameter = thread_dia_ + thread_correction,
      pitch = thread_pitch_,
      length = thread_depth_,
      internal = true
    );
  }
}

 // Filament hole module
 //----------------------
module filament_hole(angles){
  rotate(angles){
    // Filament hole
    translate([0,0,-0.2])
      cylinder(
        h = height-thread_depth+12,
        d = filament+0.25,
        $fn = 32);

    // Threads for bowden connector
    translate([0,0,height-thread_depth-0.001])
      bowden_threads();

    // "Nut" (cube) for cutting facets
    translate([0,0,height-0.002+body_width])
      cube(
        size = body_width*2,
        center = true
      );

    // Nut for debugging nut spacing
    translate([0,0,height])
      #cylinder(
        d = nut_dia,
        h = 5
      );
  }
}


// E3D clamp module
 //-----------------
module e3d_clamp(t="body"){
  if(t=="body"){
    translate([-body_width/2+0.5,0,clamp_height/2-1]){
      cube(
        size = [
          body_width,
          body_width+10,
          clamp_height+2],
        center = true
      );
    }
    e3d();
    screw_holes();
  }
  else if(t=="clamp"){
    // Clamp piece
    rotate([0,90,0])
      translate([-body_length/2,body_width+2,0]){
      difference(){
        translate([0.5,-body_width/2,0]){
          cube(
            size = [
              body_length/2-0.5,
              body_width,
              clamp_height-0.5]
          );
        }
        e3d();
        screw_holes();
      }
    }
  }
  // Screw holes module
  module screw_holes(){
    for(s=[1,-1])
      translate([0, 12*s, 6]) rotate([0,90,0])
        cylinder(
          d = 3.3,
          h = body_width+10,
          center = true,
          $fn = 32
        );
  }
  // E3D mouth module
  module e3d(){
    union(){
      $fn=128;
      // Scale a little bigger to make assembly possible without using a hammer ;)
      scale([1.01,1.01,1]){
        translate([0,0,-0.1]){
          // Top ring
          translate([0,0,9])
            cylinder(
              d = 16,
              h = 4.8);
          // Middle groove
          cylinder(
            d = 12,
            h = clamp_height
          );
          // Bottom ring
          cylinder(
            d = 16,
            h = 3.2
          );
        }
      }
    }
  }
}

// Main body module
 //-----------------
module body(){
  // Round cone shaped body
  // For bowden style bottom connector
      dia1=thread_dia_+3;
      dia2=2*height*sin(angle)+thread_dia_*cos(angle)*1.5+3;
  if(bot_conn=="bowden"){
    difference(){
      cylinder(
        h = body_height,
        d1 = dia1,
        d2 = dia2,
        $fn = 128
      );
      //Labels and signature
      labels();
    }
  }
  // Square body for
  // E3D style or no connector
  else {
    difference(){
      translate([0,0,(body_height)*0.5])
        cube(
          size = [
            body_length,
            body_width,
            body_height
          ],
          center = true
        );
      // Labels and signature
      labels();
    }
  }
  // Label module. Prints labels and signature on body
  module labels(){
    // Text on cone module (writes text on cone body)
    module text_on_cone(txt,size=3,x=0,y=0){
      text_on_cylinder(
        t = txt,
        r1 = dia1/2,
        r2 = dia2/2,
        h = body_height,
        size = size,
        eastwest = x,
        updown = y,
        extrusion_height = letter_depth
      );
    }
    // String module (makes flat text)
    module string(txt, size, x=0, y=0, z=0){
      translate([x,y,z]){
        rotate([90,0,90]){
          linear_extrude(height = letter_depth*2){
            text(
              txt,
              size = size,
              font = font,
              halign = "center",
              valign = "center",
              $fn = 16
            );
          }
        }
      }
    }
    if(bot_conn=="bowden"){
      text_on_cone(str(filament,"mm"),5);
      text_on_cone(
        "made by lrustand",
        size = 3,
        x = -30,
        y = -4
      );
    }
    else {
      translate([body_length/2-letter_depth/2, 0, clamp_height]){
        string(str(filament,"mm"), 5, z=8);
        string("made by lrustand", 2.5, z=3);
      }
    }
  }
}
/*-----------------------------------*
 *  End modules
 *-----------------------------------*/

//####################################

/*-----------------------------------*
 *  Begin body assembly
 *-----------------------------------*/
difference(){
  body();
  // Filament holes/tubes starts above connector and collector
  translate([0,0,pad_height]){
    rot_z =
    (
      (edge_holes==9) ? 11.25
      :(edge_holes==8) ? 22.5
      :(edge_holes==7) ? 11.25
      :(edge_holes==5) ? 22.5
      :(edge_holes==4) ? 45
      :(edge_holes==3) ? 90
      :0
    );
    hole_spacing = 360/edge_holes;
    for(deg=[0: hole_spacing: 360]){
      rotate([0, 0, deg])
        filament_hole([angle,0,rot_z]);
    }
    if(holes>4) filament_hole([0,0,0]);
  }

  // Bottom collector tube
  translate([0,0,-1]){
    cylinder(
      h = pad_height+1,
      d = filament+0.25,
      $fn = 32
    );
  }

  // Center maintenance hole
  if(center_hole)
    cylinder(
      h = body_height+10,
      d = filament+0.25,
      $fn = 32
    );

  // Bottom connector
  if(bot_conn=="e3d")
    e3d_clamp();
  else if(bot_conn=="bowden")
    translate([0,0,-0.01])
      bowden_threads();
}

if(bot_conn=="e3d")
  e3d_clamp("clamp");
/*-----------------------------------*
 *  End body assembly
 *-----------------------------------*/

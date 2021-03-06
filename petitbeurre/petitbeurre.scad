/*
 *
 * Petit Beurre
 *
 * This is a naive attempt at reproducing a vintage Petit Beurre cutter.
 *
 * Inspired from https://en.wikipedia.org/wiki/Petit-Beurre
 *
 * (c) 2017 AUTONOMOUS INDUSTRIAL TOOLS INCORPORATED
 *
 * Licensed under CERN OHL v.1.2 or later
 *
 * You may redistribute and modify this documentation under the terms of the
 * CERN OHL v.1.2. (http://ohwr.org/cernohl). This documentation is distributed
 * WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF
 * MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A
 * PARTICULAR PURPOSE. Please see the CERN OHL v.1.2 for applicable
 * conditions
 *
 * author: william@accret.io
 *
 */

MoldHeight=12;
MoldRecess=1;
MoldBaseHeight=1;

CookieLength=72.4;
CookieWidth=54;

EarRadius=5;

TeethWidth=4.6;
TeethLength=7;
TeethOffset=4;

DotDiameter=1.6;
FontSize=5;

BladeWidth=1.0;

EjectorTolerance=1.4;
EjectorHeight=4;

PusherRadius=3;

res=20; /* this is the $fn value - the higher, the longer the rendering time is */

/* 2D shape of the Petit Beurre */

module teeth(Spacing, teethlength) {
     translate([Spacing/2, 0, 0]) {
          square([TeethWidth - Spacing, teethlength ]);
          translate([(TeethWidth - Spacing)/2, teethlength ]) circle((TeethWidth - Spacing)/2, $fn=res, center=true);
     }
}

module ear(Spacing) {
     resize([12-Spacing,8-Spacing])circle(5, $fn=res);
}

module quadrant(Spacing, teethlength) {
     translate([CookieLength/2, CookieWidth/2, 0 ]) {
          rotate([0, 0, 45])
               ear(Spacing);
     }
     for (i=[0:4]) {
          translate([CookieLength/2 - teethlength + 3 , CookieWidth/2 - i*(TeethWidth ) - TeethOffset, 0 ]) {
               rotate([0, 0, -90]) teeth(Spacing, teethlength);
          }
     }
     for (i=[1:7]) {
          translate([CookieLength/2 - i*(TeethWidth) - TeethOffset , CookieWidth/2 - teethlength + 3, 0 ]) {
               rotate([0, 0, 0]) teeth(Spacing, teethlength);
          }
     }
  
}

module shape(Spacing, teethlength) {
     quadrant(Spacing, teethlength);
     mirror([1, 0, 0]) {
          quadrant(Spacing, teethlength);
     }
     mirror([0, 1, 0]) {
          quadrant(Spacing, teethlength);
     }
     rotate([0, 0 , 180]) {
          quadrant(Spacing, teethlength);
     }
}

/* the 24 dots. later they will be the pushers of the ejection mechanism */

module dot(tolerance) {
     cylinder(MoldHeight-MoldRecess, DotDiameter + tolerance/2, /* 3* */DotDiameter + tolerance/2 , $fn = res);
}

module dot_row(tolerance) {
     for (i=[0:2]) {
          translate([-10 * i - 5, 0, 0]) {
               dot(tolerance);
          }
          translate([10 * i + 5, 0, 0]) {
               dot(tolerance);
          }
     }
}
   
   
module dots(tolerance) {

     for (i=[0:1]) {
          translate([0, 6 + i * 12 ]) {
               dot_row(tolerance);
          }
           translate([0, - 6 - i * 12 ]) {
               dot_row(tolerance);
          }
     }

}




/* the text. you need to install the Rebel bones font on your system, or to use another font */
module label(position, t, tolerance) {
     module thetext() {
          linear_extrude(height = MoldHeight-MoldRecess, center = false, convexity = 10, twist = 0) {
               
               translate([0, position, 0])
                    text(t, size= FontSize, font = "Rebel bones", halign="center", valign = "center");
          }
     }
     
     if (tolerance == 0.0) {
          thetext();
     } else {

          translate([0, position, (MoldHeight+MoldRecess)/2])
          cube([4.4*len(t) + tolerance, 5 + tolerance,  MoldHeight-MoldRecess], center=true);
          
     }
}


/* assembling everything */
module cutter(tolerance, fontTolerance) {
     
     difference() {
          linear_extrude(height = MoldHeight, center = false, convexity = 10, twist = 0) {
               shape(0, TeethLength+tolerance/2);
          }
          
          linear_extrude(height = MoldHeight, center = false, convexity = 10, twist = 0) {
               shape(BladeWidth+tolerance, TeethLength+tolerance/2);
          }
          
          translate([CookieLength/2-5 + tolerance/2, CookieWidth/2-5 + tolerance/2 , 0 ]) 
               cylinder(MoldHeight, 3-tolerance/2, 3-tolerance/2, $fn=res);
          
          translate([CookieLength/2-5 + tolerance/2, -(CookieWidth/2-5)- tolerance/2, 0 ]) 
               cylinder(MoldHeight, 3-tolerance/2, 3-tolerance/2, $fn=res);
          
          translate([-(CookieLength/2-5)  - tolerance/2, CookieWidth/2-5  + tolerance/2, 0 ]) 
               cylinder(MoldHeight, 3-tolerance/2, 3-tolerance/2, $fn=res);
          
          translate([-(CookieLength/2-5) - tolerance/2, -(CookieWidth/2-5) - tolerance/2, 0 ]) 
               cylinder(MoldHeight, 3-tolerance/2, 3-tolerance/2, $fn=res);
     }

     
     translate([0, 0, MoldRecess]) {
          label(12, "COLETTE", tolerance);
          label(0, "EDITH", tolerance);
          label(-12, "MARGUERITE", tolerance);
          dots(tolerance);
          
     }
     
   
}

module base() {
       translate([0, 0, MoldHeight])
            cube([CookieLength+15, CookieWidth+15, MoldBaseHeight], center=true);
       
}

//rotate([180, 0, 0])


module pushers(tolerance) {
   translate([CookieLength/2 * 2/3, 0, -MoldBaseHeight + MoldHeight])
        cylinder(MoldHeight+5, PusherRadius+tolerance, PusherRadius+tolerance, $fn=res);
      translate([- CookieLength/2 * 2/3, 0, -MoldBaseHeight + MoldHeight])
           cylinder(MoldHeight+5, PusherRadius+tolerance, PusherRadius+tolerance, $fn=res);
}


module ejector_base() {
     translate([0, 0, -2*MoldBaseHeight])
               translate([0, 0, MoldHeight])
               cube([CookieLength+12, CookieWidth+12, EjectorHeight], center=true);
}
module ejector() {
     difference() {
          ejector_base();
          cutter(EjectorTolerance);
     }
     pushers(0);
}


translate([0, CookieWidth + 20, 20])
rotate([180, 0, 0])
ejector();

cutter(0);
difference() {
     translate([0, 0, MoldHeight])
          cube([CookieLength+15, CookieWidth+15, MoldBaseHeight], center=true);
     
     pushers(EjectorTolerance);
}
  

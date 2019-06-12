/*
    clock_reel.scad

    A decagon reel suitable for displaying digits.  (A large 
    reel like those used on electromechanical pinball games.)

    Copyright (C) 2019  John Winans

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/



/*
    Official source and documentation:
        https://github.com/johnwinans/DecagonReelClock
        
    Select to print the entire reel or just the top or bottom in the code below.
    By default, nothing is rendered because it can take over a minute.
*/




use <MCAD/involute_gears.scad>

$fa=2;    // render high quality for printing (takes a minute to compile!)

m3nutDia=6.6;       // The diameter of the hex point-to-point on an M3 nut
m3BoltDia=3.4;      // the diameter of an M3 bolt shaft hole

wheel_dia=200;      // outer diameter of the reel
wheel_height=50;    // how wide the reel will be (or the height when printing it sideways)
wheel_thickness=3;  // how thick the reel hub shiuld be

wheel_axel_bore_diameter=5.4;  // the size of the hole in the hub (for the axle)


wheel_axel_bearing_diameter=6.7;
bearing_height=3;


//reel();                         // <---------------  Render the entire reel

//rotate([180,0,0]) reelBottom(); // <--------------- Render the bottom only

//reelTop();                      // <--------------- Render the top only


//testBearingCountersink();
module testBearingCountersink()
{
    difference()
    {
        cylinder(d=15, h=10, $fn=30);
        translate([0,0,10-bearing_height+.001]) cylinder(d=wheel_axel_bearing_diameter, h=bearing_height, $fn=30);
        translate([0,0,-.5]) cylinder(d=wheel_axel_bore_diameter, h=wheel_height+1, $fn=30);   
    }
}

/**
* A 'blob' with a hexagonal hole suitable for holding an M3 nyloc
* nut.
***********************************************************************/
module nutRetainer(boltDia, nutDia)
{
    difference()
    {
        union()
        {
            translate([0,0,-2.5]) cube([20,20,5], center=true);
            scale([1,1,.5]) sphere(r=10);
        }
        cylinder(d=nutDia, h=10, $fn=6);
        translate([0,0,-5.1]) cylinder(d=boltDia, h=20, $fn=20);
    }
}


/**
* Render just the top half of the reel (better suited to 3D printing
* with no supports.)
***********************************************************************/
module reelTop()
{
    difference()
    {
        reel();
        translate([-100,-100,0]) cube([200,200,8+2.5]);
    }
}

/**
* Render just the bottom half of the reel (better suited to 3D printing
* with no supports.)
***********************************************************************/
module reelBottom()
{
    difference()
    {
        reel();
        translate([-100,-100,8+2.5]) cube([200,200,100]);
    }
}

/**
* The decagon score reel.
***********************************************************************/
module reel()
{
    difference()
    {
        union()
        {
            wheel();
    
            // 60 teeth = 6 teeth/digit
            // 200 steps/rev 
            // 10-tooth drive dear = 200/10 steps/tooth = 20
            // 20*6 = 180 steps/digit
            mygear($fn=20,
                number_of_teeth=60, 
                bore_diameter=wheel_axel_bore_diameter,
                hub_thickness=0,
                rim_thickness = 8,      // how thick the 'tire' of the gear will be
                gear_thickness = 8      // how thick the inner-wheel will be
                );
            
            // add some blobs that we can hollow out to use for nut-holders
            for ( t = [ 18 : 72 : 360 ] )
                rotate([0,0,t]) translate([85,0,8+5]) scale([1,1,.5]) sphere(r=10);
            
        }
    
        // put relief holes around the bottom gear and hub
        for ( t = [ 0 : 36 : 360 ] )
            rotate([0,0,t]) translate([73,0,0]) cylinder(d=35, h=100);
        for ( t = [ 0 : 72 : 360 ] )
            rotate([0,0,t]) translate([25,0,-.1]) cylinder(d=24, h=100);
        
        
        // add some bolt holes to attach the top & bottom together
        // bolt holes
        for ( t = [ 18 : 72 : 360 ] )
            rotate([0,0,t]) translate([85,0,0]) 
            {
                cylinder(d=m3BoltDia, h=100, $fn=20);
                translate([0,0,8+5]) cylinder(d=m3nutDia, h=100, $fn=6);
            }
            
        // Bearings
        translate([0,0,-.001]) cylinder(d=wheel_axel_bearing_diameter, h=bearing_height, $fn=30);
        translate([0,0,wheel_height-bearing_height+.001]) cylinder(d=wheel_axel_bearing_diameter, h=bearing_height, $fn=30);

    }
}


/**
* A hollowed out decagon.
***********************************************************************/
module wheel()
{
    wheel_inner_dia=wheel_dia-2*wheel_thickness;

    difference()
    {
        cylinder(d=wheel_dia, h=wheel_height, $fn=10);//=360/10);

        // hollow out the top
        translate([0,0,5+5+8]) 
            minkowski()
            {
                difference()
                {
                    cylinder(d=wheel_inner_dia-10, h=wheel_height+1, $fn=10);       // hollow decagon
                    cylinder(d=wheel_axel_bore_diameter+10+10, h=wheel_height+20); // axel hub
                }
                sphere(r=5,$fn=30);     // fillet all of the corners
            }
            
        // hollow out the bottom
        minkowski()
        {
            cylinder(d=wheel_inner_dia-10, h=8-5, $fn=10);
            sphere(r=5,$fn=30);
        }
        
        // the axel bore
        translate([0,0,-.5]) cylinder(d=wheel_axel_bore_diameter, h=wheel_height+1, $fn=30);   
        
    }
    
    rotate([0,0,-360/20]) translate([wheel_dia/2-15,0,0]) magnetRetainer(); // index magnet
}

/**
* A mount for a magnet used for a 0-digit index.
***********************************************************************/
module magnetRetainer()
{
    difference()
    {
        cylinder(d=16, h=8);
        translate([0,0,-.001]) cylinder(d=7, h=2, $fn=20);
    }
}




/**
* A wrapper for rendering a gear.
***********************************************************************/
module mygear(
    number_of_teeth = 48,
    gear_thickness = 5,
    rim_thickness = 7,
    rim_width = 3,
    hub_thickness = 10,
    hub_diameter = 10,
    bore_diameter = 6)
{
    difference()
    {
    gear (number_of_teeth=number_of_teeth,
        circular_pitch=268,
        gear_thickness = gear_thickness,
        rim_thickness = rim_thickness,
        rim_width = rim_width,
        hub_thickness = hub_thickness,
        hub_diameter = hub_diameter,
        bore_diameter = bore_diameter,
        circles=0,
        twist = 0,
        involute_facets = 12,
        circle_facets = 7);    
    }
}

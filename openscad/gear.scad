/*
    gear.scad

	A drive gear for NEMA17 motor.

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
*/


use <MCAD/involute_gears.scad>

m5bore=5.6;
m3bore=3.4;
m3nbore=6.5;        // countersink diameter for an M3 hex nut

$fs=2;
bore_countersink_dia=9.5;       // head countersink diameter for an M5 bolt head
bore_countersink_depth=5+1;     // countersink depth for an M5 bolt head
bore_diameter=m5bore;           // axle diameter for loose fit on an M5 bolt

nema17shaft=5.5;

involute_facets=12;	
circle_facets=7;
circular_pitch=268;



// radius of the gear pairs
rad60=pitch_radius(60, circular_pitch);
rad72=pitch_radius(72, circular_pitch);
rad12=pitch_radius(12, circular_pitch);
rad10=pitch_radius(10, circular_pitch);
rad6=pitch_radius(6, circular_pitch);
meshFudge=.15;   // extra space between gear axles

small(nema17shaft, teeth=8, $fn=20);


// Note: motor mounting is designed for a total of 38 teeth!

///*rotate([180,0,0])*/ small(nema17shaft, teeth=12);
//rotate([180,0,0]) small(m3bore, teeth=26);
//rotate([180,0,0]) small(m3bore, teeth=16);


//gear6x1();
//axleHub(10, bore_diameter, 7.5);

// test-fit things
//translate([0,0,-5]) 
//gearbox_plate(rad12+rad72+meshFudge, rad72+rad6+meshFudge, bore_diameter);
//translate([0,rad12+rad72,7]) rotate([0,0,360/72/2]) gear6x1();

//testmesh();




function pitch_radius(number_of_teeth, circular_pitch) = (number_of_teeth * circular_pitch / 180) / 2;
function tooth_angle(number_of_teeth) = 360/number_of_teeth;


module axleHub(hubdia, bore, thick)
{
    difference()
    {
        cylinder(d=hubdia, h=thick);
        translate([0,0,-.5]) cylinder(d=bore, h=thick+1);
    }
}


module gearbox_plate(rad, mrad, bore)
{
    x=120;
    y=rad*2+30;
    z=10;
    honeyrad=4;
    hubdia=honeyrad*3.5;
    mb_t=5;             // mounting block thickness
    x_inset=10;
    y_inset=10;

    difference()
    {
        union()
        {
            //translate([-x_inset,-y_inset,0]) honeycombPlate(x,y,z,rad=4,th=1.5,inset=3);
            translate([-x_inset,-y_inset,0]) cube([x,y,z]);
            axleHub(hubdia, bore, z);
            translate([0,rad,0]) axleHub(hubdia, bore, z);
            
            // mounting blocks
            translate([x-mb_t-10,-y_inset,0]) cube([mb_t,y,z]);
            translate([-x_inset,y-y_inset-mb_t,0]) cube([x,mb_t,z]);
            
            // nut access border
            for ( p = [ 90, 30 ] )
                translate([x-x_inset-p,y-y_inset-mb_t-5,z/2]) cube([15,13,z], center=true);
            for ( p = [ 20, 100 ] )
                translate([x-x_inset-mb_t-10/2,-y_inset+p,z/2]) cube([13,15,z], center=true);
        }    
        
        // nut access
        for ( p = [ 90, 30 ] )
            translate([x-x_inset-p,y-y_inset-mb_t-5,z/2]) cube([12,10,z+1], center=true);
        for ( p = [ 20, 100 ] )
                translate([x-x_inset-mb_t-10/2,-y_inset+p,z/2]) cube([10,12,z+1], center=true);
        
            
        // axle holes
        translate([0,0,-.5])cylinder(d=bore, h=z+1, $fn=30);
        translate([0,rad,-.5]) cylinder(d=bore, h=z+1, $fn=30);
        
        // back mounting blocks
        for ( p = [ 90, 30 ] )
            translate([x-x_inset-p,y-y_inset+.01,z/2]) 
                rotate([90,0,0]) cylinder(d=m3bore, h=20, $fn=20);
        
        // bottom mounting blocks
        for ( p = [ 20, 100 ] )
                translate([x-x_inset+.01,-y_inset+p,z/2]) rotate([0,-90,0]) cylinder(d=m3bore, h=20, $fn=20);
        
        // motor mounting bracket
        translate([0,rad+mrad,0]) rotate([0,0,90]) motorCore(z+1);
        translate([-x_inset,rad+mrad,0]) cube([mb_t*2,1,z]);       // flex slot
    }
    
    // nut retainers
    if (false)
    for ( p = [ 90, 30 ] )
        translate([x-x_inset-p,y-y_inset-mb_t,z/2]) rotate([90,0,0]) 
            intersection() { m3mount(); cube([20,z,10],center=true); }

    // motor mounting bracket
    translate([0,rad+mrad,0]) rotate([0,0,90]) motorClamp(25,3);

}

module gear6x1()
{
    difference()
    {
        union()
        {
            mygear($fn=20,
                bore_diameter=bore_diameter, 
                number_of_teeth=72, 
                bore_diameter=bore_diameter,
                hub_thickness=0,
                rim_width=0,            // make the circles as big as possible
                rim_thickness = 7,      // how thick the 'tire' of the gear will be
                gear_thickness = 7      // how thick the inner-wheel will be
                );

            translate([0,0,7])              // raise to the thickness of the inner-wheel
                mygear($fn=20,
                    bore_diameter=bore_diameter,
                    number_of_teeth=12, 
                    bore_diameter=bore_diameter, 
                    rim_thickness=8, 
                    hub_thickness=8
        //            hub_diameter=bore_diameter+2
                    );
        }
        if (false)
        {
            // hollow out a countersing in the hub for a bolt head
            translate([0,0,7+8-bore_countersink_depth]) cylinder(d=bore_countersink_dia, h=bore_countersink_depth+1, $fn=25);
        }
    }
}


// A rendering a two gears to see how the mesh
module testmesh()
{
    g1_teeth=60;
    g2_teeth=11;

    //g1_diameter = g1_teeth * circular_pitch / 180;
    //g2_diameter = g2_teeth * circular_pitch / 180;
    //axis_difference = g1_diameter/2 + g2_diameter/2 +meshFudge;
    
    axis_difference = (g1_teeth+g2_teeth) * circular_pitch / 360 + meshFudge;
    
    gear(number_of_teeth=g1_teeth, circular_pitch=circular_pitch);
    
    translate([axis_difference,0,0])
        rotate([0,0,(g1_teeth+g2_teeth)%2 ? 0 : 360/g2_teeth/2]) 
           gear(number_of_teeth=g2_teeth, circular_pitch=circular_pitch);
    
    
    
    // draw a reference line
    difference()
    {
        translate([-10,-10,12]) cube([axis_difference+20,20,3]);
        #cylinder(d=5, h=40, center=true, $fn=20);
        #translate([axis_difference,0,0]) cylinder(d=5, h=40, center=true, $fn=20);
    }
    //translate([0,0,10]) cube([axis_difference,5,5]);
}



/*
module mygear(
    number_of_teeth = 48,
    gear_thickness = 5,
    rim_thickness = 7,
    rim_width = 4,
    hub_thickness = 10,
    hub_diameter = 10,
    bore_diameter = 6)
{
    gear (number_of_teeth=number_of_teeth,
        circular_pitch=circular_pitch,
        gear_thickness = gear_thickness,
        rim_thickness = rim_thickness,
        rim_width = rim_width,
        hub_thickness = hub_thickness,
        hub_diameter = hub_diameter,
        bore_diameter = bore_diameter,
        circles=5,
        twist = 0,
        involute_facets = involute_facets,
        circle_facets = circle_facets);    
}
*/



module small(bore, teeth=10)
{
	difference()
    {
        union()
        {
        rotate([180,0,0]) m3GrubHubPos(axle=bore, hubZ=9, $fn=30);
		gear (number_of_teeth=teeth,
			circular_pitch=268,
			gear_thickness = 8,
			rim_thickness = 8,
			hub_thickness = 0,
			hub_diameter = 20,
			bore_diameter = bore,
			circles=0,
			twist = 0,
			involute_facets = involute_facets,
			circle_facets = circle_facets, $fn=30);
        }
        rotate([180,0,0]) m3GrubHubNeg(axle=bore, hubZ=9, $fn=30);
	}
}

//******************************************************************************
grubDia=3.6;
M3SqNutWidth=6;
M3SqNutHt=2.8;

module m3GrubHubPos(axle, hubZ)
{
    od = axle+M3SqNutHt*6;
    cylinder(d=od, h=hubZ, $fn=30);
  
}

module m3GrubHubNeg(axle, hubZ, hubRad=M3SqNutHt*4)
{
    $fn=30;
    od = axle+M3SqNutHt*2+hubRad;
    grubScrewCenter=grubDia/2+1.8;

    nutFudgeZ=0.3;  // extra depth for the nut hole
    
    // shaft hole
    translate([0,0,-.05]) cylinder(d=axle, h=hubZ*2.5);
    
    // M3 grub screw nut hole (5.5mm square nut)
    // translating to .4 in Y allows as few as 10 teeth on the gear
    translate([-(M3SqNutWidth/2), axle/2+.6, grubScrewCenter-(M3SqNutWidth/2)-nutFudgeZ]) cube([M3SqNutWidth, M3SqNutHt, hubZ+grubScrewCenter]);
    
    // M3 grub screw hole
    translate([0, od/2, grubScrewCenter]) rotate([90,0,0]) cylinder(d=grubDia, h=od, center=true);
}

module m3GrubHub(axle, hubZ=10)
{
    difference()
    {
        m3GrubHubPos(axle, hubZ);
        m3GrubHubNeg(axle, hubZ);
    }
}


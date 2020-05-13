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

meshFudge=.15;   // extra space between gear axles


small(nema17shaft, teeth=12);
//small(m3bore, teeth=26);
//small(m3bore, teeth=16);

//m3GrubHub(nema17shaft, 9);

module small(bore=10, teeth=10)
{
    hubZ=9;
	difference()
    {
        union()
        {
        translate([0,0,-hubZ]) m3GrubHubPos(bore, hubZ, $fn=30);
		gear (number_of_teeth=teeth,
			circular_pitch=268,
			gear_thickness = 8,
			rim_thickness = 8,
			hub_thickness = 0,
			hub_diameter = 20,
			bore_diameter = 0,
			circles=0,
			twist = 0,
			involute_facets = involute_facets,
			$fn=30);
        }
        translate([0,0,-hubZ]) m3GrubHubNeg(bore, hubZ, axleZ=hubZ+8+.1, $fn=30);
	}
}

//******************************************************************************
grubDia=3.6;
M3SqNutWidth=6;
M3SqNutHt=2.8;

// This is the definition of the axle shaft hole
module axleHoleNeg(bore, h)
{
    // A hole with flats, suitable for 28BYJ-48
    //translate([0,0,h/2])
    intersection()
    {
        cylinder(d=bore, h=h);
        translate([-bore/2, -3.1/2, 0]) cube([bore,3.1,h+.001]);
    }
    // clear some space for the non-flattened base of the shaft
    cylinder(d=bore, h=1.5);
}


module m3GrubHubPos(axle, hubZ)
{
    od = axle+M3SqNutHt*6;
    cylinder(d=od, h=hubZ, $fn=40);
}

module m3GrubHubNeg(axle, hubZ, axleZ, hubRad=M3SqNutHt*4)
{
    $fn=30;
    od = axle+M3SqNutHt*6;
    grubScrewCenter=hubZ/2;

    nutFudgeZ=0.5;  // extra depth for the nut hole
    
    // shaft hole
    translate([0,0,-.001]) axleHoleNeg(bore=axle, h=axleZ);
    
    // M3 grub screw nut hole (5.5mm square nut)
    // translating to .4 in Y allows as few as 10 teeth on the gear
    //nutAxleGap=.01;
    nutAxleGap=.8;
    translate([-(M3SqNutWidth/2), axle/2+nutAxleGap, -.001]) cube([M3SqNutWidth, M3SqNutHt, grubScrewCenter+M3SqNutWidth/2+nutFudgeZ]);  //M3SqNutWidth+nutFudgeZ]);
    
    // M3 grub screw hole
    translate([0, 0, grubScrewCenter]) rotate([-90,0,0]) cylinder(d=grubDia, h=od/2);//, center=true);
}

module m3GrubHub(axle, hubZ=10)
{
    difference()
    {
        m3GrubHubPos(axle, hubZ);
        m3GrubHubNeg(axle, hubZ);
    }
}


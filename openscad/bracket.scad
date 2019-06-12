/*
    bracket.scad

    A mounting bracket for a decagon clock reel.

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



circular_pitch=268;
function pitch_radius(number_of_teeth, circular_pitch) = (number_of_teeth * circular_pitch / 180) / 2;

BearingOD=10.5;
BearingThickness=4;

axleFudge = .25;     // extra space to deal with imperfect gear teeth

// 60 teeth hath the wheel & 8 hath the driver gear
axleSpacing = pitch_radius(68, circular_pitch) + axleFudge;

echo("axle spacing=", axleSpacing);


mountingBracket();

module mountingBracket()
{
    wallCornerRad = 15;
    wallthickness = 13;
    wallWidth = 75;
    wallHeight = 130;
    wheel_dia = 200;
    footWidth = 50;
    
    
    difference()
    {
        union()
        {
            // the base
            translate([-footWidth/2,-wallWidth/2,-5]) cube([footWidth,wallWidth, 5]);

            // the bracket/wall
            minkowski()
            {
                translate([-wallthickness/2,-(wallWidth-wallCornerRad*2)/2,0]) cube([wallthickness, wallWidth-2*wallCornerRad, wallHeight-wallCornerRad]);
                    
                rotate([0,90,0]) cylinder(r=wallCornerRad, h=.001, center=true);
            }    
            
            // a round foot
            scale([1,1,.3]) rotate([90,0,0]) cylinder(d=wallthickness*2, h=wallWidth, center=true);
        }
            
        // some mounting holes 
        for (x = [-(footWidth/2-5), footWidth/2-5])
            for(y = [-(wallWidth/2-5), wallWidth/2-5])
                translate([x,y,0]) 
                {
                    cylinder(d=3.5, h=40, center=true, $fn=20);
                    translate([0,0,-2.5]) cylinder(d=6.6, h=10, $fn=6);
                }
        
        
        // remove the minkowski noise below the base
        translate([0,0,-5-(wallCornerRad+50)/2]) cube([wallthickness+50, wallWidth+50, wallCornerRad+50], center=true);
    
        // wheel axle hole
        translate([wallthickness/2+.002,0,120]) axleNeg();
        translate([0,0,120]) rotate([90,0,-90]) m3GrubHubNeg(hubZ=wallthickness);
        
        translate([wallthickness/2+.002,0,120-axleSpacing-axleFudge]) nmea17Neg();
            
        // The index sensor hole (2x5 flat package)
        translate([-(wallthickness/2+.002),0,120]) // axle center
            rotate([-360/20,0,0]) 
                translate([0,0,-(wheel_dia/2-15)])
                {
                    translate([0,0,-3]) cube([4,5,15], center=true);
                    translate([0,0,2]) rotate([0,90,0]) cylinder(d=4, h=40, center=true, $fn=20);
                }

//                rotate([0,-90,0]) cylinder(d=5, h=100, center=false, $fn=30); // index magnet


    }
}

axleDia=3.5;
// the parts that require removing for an axle mount
module axleNeg()
{
    // wheel axle hole
    rotate([0,-90,0]) cylinder(d=axleDia, h=100, center=false, $fn=30);

    // include a set screw
    
    
    // bearing countersink
   // rotate([0,-90,0]) cylinder(d=BearingOD, h=BearingThickness, center=false);
}

grubDia=3.6;
M3SqNutWidth=6;
M3SqNutHt=2.8;

module m3GrubHubNeg(axle=axleDia, hubZ, hubRad=M3SqNutHt*4)
{
    $fn=30;
    od = axle+M3SqNutHt*2+hubRad;
    grubScrewCenter=grubDia/2+1.8;
    nutFudgeZ=0.3;  // extra depth for the nut hole

    // M3 grub screw nut hole (5.5mm square nut)
    // translating to .4 in Y allows as few as 10 teeth on the gear
    translate([-(M3SqNutWidth/2), axle/2+.6, -(M3SqNutWidth/2)-nutFudgeZ]) cube([M3SqNutWidth, M3SqNutHt, hubZ+grubScrewCenter]);

    // M3 grub screw hole
    translate([0, od/2, 0/*grubScrewCenter*/]) rotate([90,0,0]) cylinder(d=grubDia, h=od, center=true);
}



// the parts that require cutting away to mount a nema17 motor
module nmea17Neg()
{
    // the motor shaft hole
    rotate([0,90,0]) cylinder(d=25, h=100, center=true, $fn=30);
    
    // frame-mounting holes
    for (z = [ 31/2, -31/2 ])
        for (y = [ 31/2, -31/2 ])
        {
            // M3 bolt holes
            translate([0, y, z]) rotate([0,-90,0]) cylinder(d=3.8, h=100, center=false, $fn=30);
            // countersinks
            translate([-5, y, z]) rotate([0,-90,0]) cylinder(d=6.5, h=100, center=false, $fn=30);
        }
}

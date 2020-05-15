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

axleFudge = .1;     // extra space to deal with imperfect gear teeth

// 60 teeth hath the wheel & 8 hath the driver gear for 200mm reels
//axleSpacing = pitch_radius(68, circular_pitch) + axleFudge;
// 32+12 teeth for 140mm reels
axleSpacing = pitch_radius(32+12, circular_pitch) + axleFudge;

echo("axle spacing=", axleSpacing);


mountingBracket();

module mountingBracket()
{
    wheel_thickness = 4;
    
    wallCornerRad = 15;
    wallthickness = 10; // 13=NEMA17, 10=28BYJ-48
    //wallWidth = 75;
    wallWidth = 52;
    wallHeight = 95;   // larger wheel = 130;
    wheel_dia = 140;    // NEMA17 = 200;
    footWidth = 50;
    sensorRadius = wheel_dia/2-wheel_thickness-4;   // NEMA17 = wheel_dia/2-15; 
    
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
        translate([wallthickness/2+.002,0,wallHeight-10]) axleNeg();
        translate([0,0,wallHeight-10]) rotate([90,0,-90]) m3GrubHubNeg(hubZ=wallthickness);
                   
        translate([wallthickness/2+.002,0,wallHeight-10-axleSpacing-axleFudge]) motorNeg();
                
        // access hole for the grub on the motor gear
        translate([0,0,wallHeight-10-axleSpacing-axleFudge]) rotate([90,0,0]) cylinder(d=6, h=100, $fn=20);
            
        // The index sensor hole (2x5 flat package)
        translate([-(wallthickness/2+.002),0,wallHeight-10]) // axle center
            rotate([-360/20,0,0]) 
                translate([0,0,-(sensorRadius)])
                {
                    translate([0,0,0]) cube([4,5,15], center=true);
                    translate([0,0,5]) rotate([0,90,0]) cylinder(d=4, h=40, center=true, $fn=20);
                }

//                rotate([0,-90,0]) cylinder(d=5, h=100, center=false, $fn=30); // index magnet


    }
    translate([wallthickness/2+.002,0,wallHeight-10-axleSpacing-axleFudge]) motorPos();

    // cable retainer
    crd = 6;
    
    translate([wallthickness/2+crd/2, 20, wallHeight-10-axleSpacing-axleFudge]) 
    {
        difference()
        {
            rotate([0,0,-90]) retainer(len=30, rd=crd);
            // if we angle the bottom then we don't need support material
            translate([crd*.9,0,-len/2]) rotate([0,45,0]) cube([crd*2,crd*2,crd*2], center=true);
        }
    }
    translate([0, wallWidth/2+crd/2, 10]) 
    {
        difference()
        {
            retainer(len=wallHeight-25, rd=crd);
            translate([0,crd*.9,-len/2]) rotate([45,0,0]) cube([crd*2,crd*2,crd*2], center=true);
        }
    }
}
  
// A tube for retaining a cable
module retainer(len, rd=8)
{
    th = 1.25;  // wall thickness
    
    translate([0,0,len/2])
    difference()
    {
        cylinder(d=rd+th*2, h=len, center=true, $fn=30);
        cylinder(d=rd, h=len+1, center=true, $fn=30);
        translate([0, rd/2, 0]) cube([2, rd, len+1], center=true);
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


module motorNeg()
{
    //nmea17Neg();
    stepper28byj48Neg();
}

module motorPos()
{
    stepper28byj48Pos();
}

// The positive portion of a 28byj-48 stepper mount
module stepper28byj48Neg()
{
    bracketOffset = 8;          // mounting holes are 8mm offset from center of shaft
    bracketSpacing = 35/2;      // mounting holes spacing is 35mm on center
    
    rotate([0,90,0]) cylinder(d=25, h=100, center=true, $fn=30);

    translate([0,0,-bracketOffset])
    {
        for ( y = [ -bracketSpacing, bracketSpacing ])
        {
            // bolt holes
            translate([0,y,0]) rotate([0,-90,0]) cylinder(d=3.5, h=40, center=true, $fn=20);
            // countersinks
            translate([-5, y, 0]) rotate([0,-90,0])
            cylinder(d=6.6, h=10, $fn=6);
        }
    }
}

// The negative portion of a 28byj-48 stepper mount
module stepper28byj48Pos()
{
    bracketOffset = 8;
    translate([0,0,-bracketOffset]) slottedNotch();
}


// A slotted notch for guiding a 28byj-48 stepper mounting bracket
module slottedNotch()
{
    bracketSpacing = 35/2;      // offset from center to the bracket mounting holes
    bracketWith = 7.3;          // the width of the mounting brackets 
    bracketLength = 42;         // the total outer length of the brackets
    motorHousingDiameter = 29;
    
    difference()
    {
        hull()
        {
            translate([0,bracketSpacing,0]) rotate([0,90,0]) cylinder(d=bracketWith+6, h=2, center=true, $fn=30);
            translate([0,-bracketSpacing,0]) rotate([0,90,0]) cylinder(d=bracketWith+6, h=2, center=true, $fn=30);
        }

        hull()
        {
            translate([0,bracketSpacing,0]) rotate([0,90,0]) cylinder(d=bracketWith, h=3, center=true, $fn=30);
            translate([0,-bracketSpacing,0]) rotate([0,90,0]) cylinder(d=bracketWith, h=3, center=true, $fn=30);
        }
        cube([10,motorHousingDiameter,bracketWith+10], center=true);
    }
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

// This will do a soft landing on any vacuum world except gilly, because the tolerances are too small and it gets confused

// Gets the current altitude above terrain (ish).
function getCurrentAlt {
 return ALTITUDE - SHIP:GEOPOSITION:TERRAINHEIGHT.
}

// Get the acceleration due to gravity for the body
function getGForBody {
 return body:mu / (ship:position - body:position):mag ^ 2.
}

// Get the estimated descent distance remaining
function getDescentDistance {
 parameter g.
 parameter v.
 local a is availablethrust/mass - g.
 local v0 is verticalspeed.
 return -1 * ((v + v0) / 2) * ((v - v0) / a).
}

// Setup
clearscreen.
print "Setting up.".
sas off.
unlock steering.
unlock throttle.

set current_alt to getCurrentAlt().
set g to getGForBody().
set current_throttle to 0.
panels off.

print "Getting rid of horizonal vectors.".

// Todo: project this onto yz so there's no x component.
set desired_heading to srfretrograde:forevector.
lock throttle to current_throttle.
lock steering to desired_heading.
wait 3.

// Burn to 10 m/s
set warpmode to "physics".
set warp to 3.
until groundspeed <= 10 {
 set desired_heading to srfretrograde:forevector.
 set current_throttle to 1.
}
set warp to 0.

// Try to get within 0.5 m/s
set desired_heading to srfretrograde:forevector.
until groundspeed <= 0.5 {
 set current_throttle to 0.25.
}

set current_throttle to 0.
print "Succesfully reduce horizonal component.".

wait 1.

// Vertical phase
print "Preparing for vertical descent burn.".
set desired_heading to up.
wait 5. 
set current_altitude to getCurrentAlt().
set descent_distance to 0.

// Buffer for timewarp.
set buffer to (-1 * verticalspeed + getGForBody() * 15) * 15.

set warp to 2.
// Wait until we're closer to the ground.
until current_altitude - descent_distance <= buffer {
 set buffer to (-1 * verticalspeed + getGForBody() * 30) * 15.
 set descent_distance to getDescentDistance(getGForBody(), -1.5).
 set current_altitude to getCurrentAlt().
 wait 0.001.
}
set warp to 0.

// Final phase
print "Entering final burn phase.".
set desired_heading to up.
gear on.
set current_throttle to 1.
set vspeed to verticalspeed.

// We want to hit ~1.5 m/s by ~15m above surface, so we add some leeway room
until current_altitude <= 20 and vspeed > -2 {
 set vspeed to verticalspeed.
 set desired_heading to up.
 set current_altitude to getCurrentAlt().
 set descent_distance to getDescentDistance(getGForBody(), -1.5).
 // Only burn if we need to! Don't slow down too fast!
 if current_altitude - 20 <= descent_distance {
  set current_throttle to 1.
 } else {
  set current_throttle to 0.
 }
 wait 0.0000000001.
}

// Let's not hoverslam hard.
print "Soft landing initiated.".
until current_altitude <= 3 {
 set desired_heading to up.
 set current_altitude to getCurrentAlt().
 // f = g 
 set throttle to (getGForBody() * mass)/availablethrust. 
}

set desired_heading to up.
wait 1.

// Cleanup
unlock throttle.
unlock steering.
sas on.
print "Successful landing.".


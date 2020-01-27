// Gets the true current altitude above terrain 
function getCurrentAlt {
 return ship:bounds:bottomaltradar.
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

function getInverseHorizontalHeading {
    local a is 2 / vang(velocity:surface:normalized, -body:position:normalized).
    return -1 * ((1.0 - a)*velocity:surface:normalized - a*body:position:normalized).
}

// Setup
clearscreen.
print "Setting up.".
set warp to 0.
sas off.
unlock steering.
unlock throttle.

set current_alt to getCurrentAlt().
set g to getGForBody().
set current_throttle to 0.
panels off.

print "Getting rid of horizonal vectors.".
set desired_heading to getInverseHorizontalHeading().
lock throttle to current_throttle.
lock steering to desired_heading.
wait until vang(ship:facing * v(0,0,1), desired_heading) <= 5.
wait 1.

// Burn to 10 m/s
set warpmode to "physics".
set warp to 3.
until abs(groundspeed) <= 10 {
 set desired_heading to getInverseHorizontalHeading().
 set current_throttle to 1.
 wait 0.00001.
}
set warp to 0.
set desired_heading to getInverseHorizontalHeading().

// Try to get within 0.5 m/s
until abs(groundspeed) <= 0.5 {
 set current_throttle to 0.25.
 set desired_heading to getInverseHorizontalHeading().
 wait 0.00001.
}

set current_throttle to 0.
print "Succesfully reduce horizonal component.".
wait 1.

// Vertical phase
print "Preparing for vertical descent burn.".
set desired_heading to up:vector.
wait until vang(ship:facing * v(0,0,1), desired_heading) <= 5.

set current_altitude to getCurrentAlt().
set descent_distance to 0.

// Buffer for timewarp.
set buffer to (-1 * verticalspeed + getGForBody() * 15) * 15.

set warpmode to "rails".
set warp to 2.
// Wait until we're closer to the ground.
until current_altitude - descent_distance <= buffer {
 set buffer to (-1 * verticalspeed + getGForBody() * 30) * 15.
 set descent_distance to getDescentDistance(getGForBody(), -3).
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
until current_altitude <= 20 and vspeed >= -2 and vspeed < 0 {
 set vspeed to verticalspeed.
 set desired_heading to srfretrograde.
 set current_altitude to getCurrentAlt().
 set descent_distance to getDescentDistance(getGForBody(), -3).
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
until current_altitude <= 2 {
 set desired_heading to up.
 set current_altitude to getCurrentAlt().
 // f = g but slightly less.
 set throttle to (getGForBody() * mass / availablethrust) * 0.9.
 wait 0.000001.
}
wait 2.
lock throttle to 0.
lock steering to up.
wait 1.

// Cleanup
unlock throttle.
unlock steering.
wait 1.
sas on.
print "Successful landing.".


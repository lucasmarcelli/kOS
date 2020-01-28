clearscreen.

// Prints some fancy data
function printData {
    local emptyLine is "                             ".
    print "Q: " + ship:q at (0, 5).
    print "Altitude above ground: " + ship:bounds:bottomaltradar + emptyLine at (0, 6).
    print "Altitude above sea level: " + ship:altitude + emptyLine at(0, 7).
    print "Vertical Speed: " + ship:verticalspeed + emptyLine at (0, 8).
    print "Ground Speed: " + ship:groundspeed + emptyLine at (0, 9).
    print "Apoapsis: " + apoapsis + emptyLine at(0, 10).
    print "Periapsis: " + periapsis + emptyLine at(0, 11).
    print "Orbital Velocity: " + ship:velocity:orbit:mag + emptyLine at(0,12).
    print "Bearing: " + ship:facing + emptyLine at (0, 13).
    print "Position " + ship:position + emptyLine at (0, 14).
    print "Airspeed " + ship:airspeed + emptyLine at (0, 15).
}

function printHeader {
    parameter header is "Setting Up.".
    local emptyLine is "                             ".
    print header + emptyLine at (0, 3).
}

// Angle of attack for early burn stages
function getAscentAngle {
    parameter minangle is 10.
    local x is ship:velocity:orbit:mag.
    // Mapping orbital speed onto angle of attack
    local slope is -0.1 * x + 100.
    if slope < minangle {
        return minangle.
    } else {
        return slope.
    }
}

// Print our data out continously. 
on (ship:velocity:orbit) {
    printData().
    return true.
}

printData().
printHeader().
// Setup.
set warp to 0.
sas off.
unlock steering.
unlock throttle.

wait 1.

set current_thrust to 1.
set desired_heading to up.
lock throttle to current_thrust.
lock steering to desired_heading.

// Launch phase
printHeader("Launch phase initiated.").
wait 1.
until ship:availablethrust > 0 {
    stage.
    wait 0.5.
}

when stage:liquidfuel < 1 then {
  stage.
  return true.
}

// Vertical acceleration
printHeader("Accelerating vertically.").
wait until ship:verticalspeed >= 100.

// Early gravity turn.
printHeader("Performing gravity turn.").
until ship:altitude >= 35000 {
    if eta:apoapsis < 30 or apoapsis < 40000 {
        set desired_heading to heading(90, getAscentAngle(45), 90).
    } else {
        set desired_heading to heading(90, getAscentAngle(), 90).
    } 
}

// Prograde burn.
printHeader("Burning prograde.").
until apoapsis >= 71000 {
    if eta:apoapsis < 60 {
        set desired_heading to heading(90, 45, 90).
    } else {
        set desired_heading to prograde.
    }
}

set current_thrust to 0.

// Circularizing - want to do this without nodes so i can have things launch without being the "player" vessel.
printHeader("Calculating circularization burn").




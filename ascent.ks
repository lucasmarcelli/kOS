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
    print "Airspeed " + ship:airspeed + emptyLine at (0, 14).
}

function printHeader {
    parameter header is "Setting Up.".
    local emptyLine is "                             ".
    print header + emptyLine at (0, 3).
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
set desired_heading to heading(90, 90, 270).
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
wait until ship:verticalspeed >= 100 or ship:bounds:bottomaltradar > 1000.
set desired_heading to heading(90, 84, 270).
wait until vang(heading(90, 84, 270):forevector, ship:srfprograde:forevector) < 0.5.

// Gravity turn.
printHeader("Performing gravity turn.").
until ship:apoapsis >= 85000 {
    if ship:airspeed > 1100 or (ship:altitude > 10000 and eta:apoapsis >= 30) {
        set desired_heading to ship:prograde:forevector.
    } else {
        set desired_heading to ship:srfprograde:forevector.
    }
    wait 0.00001.
}

set current_thrust to 0.
set warpmode to "physics".
set warp to 2.
printHeader("Coasting to edge of atmosphere.").
until ship:altitude >= 70000 {
    set desired_heading to ship:srfprograde:forevector.
    if ship:apoapsis < 84750 {
        set current_thrust to 1.
    } else {
        set current_thrust to 0.
    }
    wait 0.00001.
}
set warp to 0.
set warpmode to "rails".
set desired_heading to ship:prograde.

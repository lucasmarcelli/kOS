@lazyGlobal off.
runOncePath("0:/utils/utils").
runOncePath("0:/utils/kd").

set SAS to false.
unlock steering.
unlock throttle.

clearscreen.

parameter hoverHeight is 2.
parameter tolerance is 0.01.

local desiredHeading is ship:up.
local desiredThrottle is 0.
lock throttle to desiredThrottle.
lock steering to desiredHeading.

printHeader("Executing initial height change burn.").
local shipEngines is list().
list engines in shipEngines.
local ff is getCurrentFuelFlow(shipEngines).
local net0 is getForceNewtonExtended(ship:mass, getGForBody(), verticalspeed, fuelFlowToKg(ff)) / ship:availablethrust.
local netF is 0.
local sign is choose 1 if hoverHeight > ship:bounds:bottomaltradar else -1.

set desiredThrottle to net0 + netF * sign.
wait 1.

set netF to net0 * 0.25. // 0.25 times the net0
set desiredThrottle to net0 + netF * sign.

printHeader("Boop").

local d is ship:bounds:bottomaltradar.

local infoList is list("Current prediction for height: " + round(d, 3), "Current Altitude: " + round(ship:bounds:bottomaltradar, 2)).
local a is getAccelerationNewton(ship:mass, -1 * getGForBody()).

// boost up to the hoverheight.
until d > hoverHeight {
    set ff to getCurrentFuelFlow(shipEngines).
    set net0 to getForceNewtonExtended(ship:mass, getGForBody(), ship:verticalspeed, ff) / ship:availablethrust.
    set a to getAccelerationNewton(ship:mass, -1 * getGForBody()).
    set desiredThrottle to net0 + netF * sign.
    // This numerical intergration is actually working great for the ascent
    set d to getDfVelocityDependent(0, ship:verticalspeed, choose eta:apoapsis if eta:apoapsis < eta:periapsis else eta:periapsis, ship:bounds:bottomaltradar).
    set infoList to list("Current prediction for height: " + round(d, 3), "Current Altitude: " + round(ship:bounds:bottomaltradar, 2), "Fuel flow: " + ff, "Acceleration: " + a, "V0: " + ship:verticalspeed).
    printInfo(infoList).
    wait 0.00001.
}
set desiredThrottle to 0.
local f is 0.

wait until abs(ship:verticalspeed) < 0.001 or ship:bounds:bottomaltradar > hoverHeight.

clearscreen.
until false {
    set ff to getCurrentFuelFlow(shipEngines).
    set net0 to getForceNewtonExtended(ship:mass, getGForBody(), ship:verticalspeed, ff) / ship:availablethrust.
    // this was a bad idea
    set sign to choose 1 if hoverHeight > ship:bounds:bottomaltradar else -1.
    if ship:bounds:bottomaltradar > hoverHeight - tolerance and ship:bounds:bottomaltradar < hoverHeight + tolerance {
        set a to 0.
        // this works great to counterbalance as long as you're within tolerance but 
        // i might need to limit the acceleration to g for the body ???
        if ship:verticalspeed <> 0 {
            set a to ship:verticalspeed.
        }
    } else {
        // this doesn't work
        // todo: try doing an effective acceleration capped at -g or g with some nth time derivative
        // from d such that we don't need to provide a time in the calculation
        if ship:verticalspeed >= 0 and sign = -1 or ship:verticalSpeed <= 0 and sign = 1 {
            set a to ship:verticalspeed * sign.    
        } else {
            set a to log10(abs(ship:groundspeed)) * sign.
        }
    }
    set f to getForceNewtonExtended(ship:mass, a, ship:verticalspeed, ff) / ship:availablethrust.
    set infoList to list(
        "Altitude: " + ship:bounds:bottomaltradar, 
        "Hover Height: " + hoverHeight, 
        "Tolerance: " + tolerance, 
        "Delta: " + (hoverHeight - ship:bounds:bottomaltradar),
        "F: " + f * ship:availablethrust,
        "Verticalspeed: " + ship:verticalspeed,
        "A: " + a,
        "sign " + sign
        ).
    set desiredThrottle to net0 + f.
    printInfo(infoList).
    wait 0.00001.
}
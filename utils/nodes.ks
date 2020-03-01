@lazyGlobal off.
runOncePath("orbital").

function getCircularizeDV {
    parameter pe is true.
    
    local current_orbit is choose orbitSpeedEquation(ship:periapsis, ship:apoapsis, ship:periapsis, body:mu, body:radius) if pe else orbitSpeedEquation(ship:periapsis, ship:apoapsis, ship:apoapsis, body:mu, body:radius).
    local circular is choose orbitSpeedEquation(ship:periapsis, ship:periapsis, ship:periapsis, body:mu, body:radius) if pe else orbitSpeedEquation(ship:apoapsis, ship:apoapsis, ship:apoapsis, body:mu, body:radius).

    return circular - current_orbit.
}
function orbitSpeedEquation {
    parameter pe.
    parameter ap.
    parameter r.
    parameter mu.
    parameter body_radius.
    local a is ((pe + ap) / 2) + body_radius.
    local true_r is r + body_radius.
    local speed is mu * (2/true_r - 1/a).
    return sqrt(speed).
}

set current_orbit to orbitSpeedEquation(ship:periapsis, ship:apoapsis, ship:periapsis, body:mu, body:radius).
set circle_orbit to orbitSpeedEquation(ship:periapsis, ship:periapsis, ship:periapsis, body:mu, body:radius).
set dv_required to circle_orbit - current_orbit.

print dv_required.
set myNode to node(time:seconds+eta:periapsis, 0, 0, dv_required).
add myNode.
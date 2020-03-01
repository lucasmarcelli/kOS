@lazyGlobal off.

function getTerrainAlt {
 return ship:bounds:bottomaltradar.
}

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

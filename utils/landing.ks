@lazyGlobal off.


function getDescentBurnDistance {
 parameter g.
 parameter v.
 // If we so desire, update a to be the real acceleration as a form of numerical intergration
 parameter a is ship:availablethrust/ship:mass - g.

 local v0 is ship:verticalspeed.
 return -1 * ((v + v0) / 2) * ((v - v0) / a).
}


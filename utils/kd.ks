@lazyGlobal off.
// Kinematics and Dynamics.

function getVfTimeDependent {
    parameter v0, a, t.
    return v0 + a * t.
}

function getDfTimeDependent {
    parameter v0, a, t, d0.
    return d0 + v0 * t + 0.5 * a * t^2.
}

function getVfDDependent {
    parameter v0, a, d0, df.
    local vfvf is v0^2 + 2 * a / (df - d0).
    return sqrt(vfvf).
}

function getDfVelocityDependent {
    parameter vf, v0, t, d0.
    return d0 + 0.5 * (vf + v0) * t.
}

function getAccelerationTimeDependent {
    parameter vf, v0, t.
    return (vf - v0) / t.
}

function getTimeAccelerationDependent {
    parameter vf, v0, a.
    return (vf - v0) / a.
}

function getAccelerationDVDependent {
    parameter vf, v0, df, d0.
    return (vf^2 - v0^2) / (2 * (df - d0)). 
}

function getV0TimeDependent {
    parameter vf, a, t.
    return vf - a * t.
}

function getVfTDDependent {
    parameter v0, t, d0, df.
    return (2 * (df - d0) / t) - v0. 
}

// When mass change over time matters greatly, use chain rule (extended): 
// f = d/dt p = d/dt mv = dm/dt dm/dv (mv) = dm/dt v + m dv/dt
// dm / dt is the fuel flow, dv / dt is acceleration
// f = fuel flow * velocity + mass * acceleration

function getForceNewton {
    parameter m, a.
    return m * a.
}

function getForceNewtonExtended {
    parameter m, a, v, ff.
    return ff * v + m * a.
}

function getMassNewton {
    parameter a, f.
    return f / a.
}


function getAccelerationNewton {
    parameter m, f.
    return f / m.
}


function getAccelerationNewtonExtended {
    parameter m, f, v, ff.
    return (f - v * ff) / m.
}

function getForceForImpulse {
    parameter m, vf, v0, tf, t0.
    return m * (vf - v0) / (tf - t0).
}
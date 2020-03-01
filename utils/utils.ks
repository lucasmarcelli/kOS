@lazyGlobal off.
global emptyLine to "                                              ".

function getGForBody {
    return body:mu / (ship:position - body:position):mag ^ 2.
}

function fuelFlowToKg {
    parameter ff.
    parameter density is 5.
    return ff * density.
}

function getCurrentFuelFlow {
    parameter engines.
    local ff is 0.
    for eng in engines {
        set ff to ff + eng:fuelflow.
    }
    return ff.
}

function printHeader {
    parameter header is "Setting Up.".
    print header + emptyLine at (0, 3).
}

function printInfo {
    parameter info is list("No info to display.").
    local itr is info:iterator.
    until not itr:next {
        print itr:value + emptyLine at (0, itr:index + 5).
    }
}
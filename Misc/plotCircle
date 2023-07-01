--Controllable settings
local radius = 6.2 --units
local radianRes = math.rad(10) --radians per sample
local decPlaces = 3 --decimal places to round outputs to

local function main()
    --Core variables/functions
    local cos, sin = math.cos, math.sin
    local mult = 10^decPlaces
    local round = function(x)
        roundedX = math.floor((x*mult+0.5))/mult
        return roundedX
    end

    --Execution and output
    print("\ncreating circle with radius", radius)
    print("(x, y), rads")
    for radsCovered = 0, math.pi*2, radianRes do
        print(
            round(cos(angle))*radius,
            round(sin(angle))*radius, "\trads:", radsCovered
        )  
    end
end

main()

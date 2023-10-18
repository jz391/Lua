-- server script
local IRL_Seconds = 0.1 -- basically the how fast time goes by based off this time (lower is smoother, but laggier. this is in seconds)

local secnds = 5 -- change to edit time in the game per real life time (higher is faster)
local mins = 30
local hrs = 0

local lighting = game.Lighting

local function GetNewTime(t)
	local splits = string.split(t, ":")
	local Hours = splits[1]
	local Mins = splits[2]
	local Secnds = splits[3]
	splits = nil
	
  --adds everything
	Secnds = tonumber(Secnds) + secnds
	Mins = tonumber(Mins) + mins
	Hours = tonumber(Hours) + hrs

	--convert units over
	local sRemain = math.floor(Secnds/60)
	local Secnds = tostring(Secnds%60)
	local mRemain = math.floor(Mins/60)
	local Mins = tostring(Mins%60+sRemain)
	local Hours = tostring(Hours+mRemain)

	--hours are automatically reset by the game if filled past 24
	local newStr = Hours..':'..Mins..':'..Secnds
	return newStr
end

while task.wait(IRL_Seconds) do
	local new = GetNewTime(lighting.TimeOfDay)
	lighting.TimeOfDay = new
end

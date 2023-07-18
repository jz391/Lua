--!strict
export type int = number
export type float = number
export type anyfunc = '(any...) -> any?'
export type array = {
	[int]: any?
}
export type dictionary = {
	[any]: any?
}
type connectionsArray = {
	[int]: RBXScriptConnection
}

local baselineAPI

local date = os.date
local rand, abs, floor, sqrt = math.random, math.abs, math.floor, math.sqrt
local linearEase: Enum.EasingStyle = Enum.EasingStyle.Linear
local killConnections = function(connections: connectionsArray)
	local connection: RBXScriptConnection
	for i = 1, #connections do
		connection = connections[i]
		local _: nil = connection and connection:Disconnect()
	end
end

local LPEvents = {
	["charDied"] = {['length'] = 0},
	["charDel"] = {['length'] = 0},
	["charAdd"] = {['length'] = 0}
}
local suffixes = {"k", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "O", "N", "D", "U", "DD"}
local charTable = ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()'):split('')

-- wait for game to load
if not game.Loaded then game.Loaded:Wait() end

-- in-game variables
local tweenServ = game:GetService("TweenService")
local pathfindServ = game:GetService("PathfindingService")
local starterGui = game.StarterGui

local LP = game:GetService("Players").LocalPlayer

-- player events
local charAdded: RBXScriptSignal = LP.CharacterAdded
local hRootAdded: BindableEvent = Instance.new("BindableEvent")
local humanoidAdded: BindableEvent = Instance.new("BindableEvent")

-- player variables
local LPName: string = LP.Name
local character: Model = LP.Character or charAdded:Wait()
local hRoot: Instance = character:WaitForChild("HumanoidRootPart", 10)
local humanoid: Instance = character:WaitForChild("Humanoid", 10)

coroutine.wrap(function() -- refresh variables and call connections when player respawns
	local cleanGarbage: () -> nil
	local function onCharacterAdd(newChar: Model)
		local _ = cleanGarbage and cleanGarbage()
		character = newChar
		local charChildEvent: RBXScriptConnection, hrootDeleteEvent: RBXScriptConnection, diedEvent: RBXScriptConnection
		local hRootFoundFunc: (Instance) -> nil, humanoidFoundFunc: (Instance) -> nil

		-- disconnects connections and wipes unnecessary variables (should only be called on death)
		cleanGarbage = function()
			coroutine.wrap(function()
				for i, callback in pairs(LPEvents.charDel) do
					if not tonumber(i) then continue end
					coroutine.wrap(callback)()
				end
			end)()
			killConnections({charChildEvent, hrootDeleteEvent, diedEvent})
			charChildEvent, hrootDeleteEvent, diedEvent = nil
			hRootFoundFunc, humanoidFoundFunc, character, hRoot, humanoid, cleanGarbage = nil
		end

		-- update variables and call cleanGarbage when dead
		hRootFoundFunc = function(newHRoot: Instance)
			hRoot = newHRoot
			hRootAdded:Fire(hRoot)
			hrootDeleteEvent = hRoot.Destroying:Connect(cleanGarbage)
			if humanoid then charChildEvent:Disconnect() end
		end
		humanoidFoundFunc = function(newHumanoid: Instance)
			humanoid = newHumanoid
			humanoidAdded:Fire(humanoid)
			diedEvent = humanoid.Died:Connect(function()
				for i, callback in pairs(LPEvents.charDied) do
					if not tonumber(i) then continue end
					coroutine.wrap(function() callback() end)()
				end
			end)
			if hRoot then charChildEvent:Disconnect() end
		end

		-- new instances added to this triggers their corresponding functions
		charChildEvent = character.ChildAdded:Connect(function(instance: Instance) 
			if instance.Name == "HumanoidRootPart" then 
				hRootFoundFunc(instance)

			elseif instance:IsA("Humanoid") then 
				humanoidFoundFunc(instance)
				
			end
		end)

		do -- check if they existed before the charChildEvent was connected
			local rootCheck, humanCheck = character:FindFirstChild("HumanoidRootPart"), character:FindFirstChildOfClass("Humanoid")
			if rootCheck then hRootFoundFunc(rootCheck) end
			if humanCheck then humanoidFoundFunc(humanCheck) end
		end
		for i, callback in pairs(LPEvents.charAdd) do
			if not tonumber(i) then continue end
			coroutine.wrap(function()
				print(callback)
				callback(character)
			end)()
		end
	end
	local _ = character and onCharacterAdd(character)
	LP.CharacterAdded:Connect(onCharacterAdd)
end)()

baselineAPI = {
	['ver'] = 1,

	-- local player stuff
	['LocalPlayer'] = LP,
	['name'] = LPName,
	
	-- character, humanoidRoot, and humanoid
	-- dontYield: whether the function should yield until the object exists
	['character'] = function(dontYield: boolean)
		character = character or (not dontYield and charAdded:Wait())
		return character or nil
	end,
	['humanoidRoot'] = function(dontYield: boolean?)
		hRoot = (hRoot and hRoot.Parent) or (not dontYield and hRootAdded.Event:Wait())
		return hRoot or nil
	end,
	['humanoid'] = function(dontYield: boolean?) 
		humanoid = (humanoid and humanoid.Parent) or (not dontYield and humanoidAdded.Event:Wait())
		return humanoid or nil
	end,
	
	-- onCharacterEvent
	-- eventType: type of event (look at the LPEvents table)
	-- callback: function to be called when the event is fired
	["onCharacterEvent"] = function(eventType: string, callback: (...any) -> any?) --charDied is only fired when your humanoid dies, which wont happen if your humanoid is deleted
		local eventType = LPEvents[eventType]
		if not eventType then 
			local warnStr = eventType .. " is not a valid argument. Valid arguments are:\n"
			for key:string in pairs(LPEvents) do
				warnStr = warnStr..key.."\n"
			end
			warn(warnStr)
			return
		end
		
		local index
		for i = 1, eventType.length+1 do
			if eventType[i] then continue end
			index = i
		end        
		eventType.length += 1 -- increment for a new spot
		eventType[index] = callback -- claims the spot in the array

		local connection = {} -- very limited variant of rbxscriptconnection
		function connection:Disconnect()
			eventType[index] = nil -- deletes the event from the table
		end
		return connection
	end,

	-- time functions
	
	-- getDate
	-- return <string>: client's date in MO/DD/YY
	['getDate'] = function() return date("%x") end, 
	
	--getTime
	-- return <string>: client's time in hh:mm:ss millitary time
	['getHMS'] = function() return date("%X") end,
	
	--getDate
	-- return <string>: client's date (ex: Mon Jan 1 hh:mm:ss YY) 
	['getDateTime'] = function() return date("%c") end, -- return <string>

	-- getTimeInHMS
	-- return <string>: client's time in hh:mm (AM or PM) format
	['getHM'] = function()
		local date = os.date("!*t")
		local hour: int = (date.hour - 5) % 24
		local meridian: string = (hour < 12) and "AM" or "PM"
		local timestamp: string = string.format("%02i:%02i %s", ((hour - 1) % 12) + 1, date.min, meridian)
		return timestamp
	end,
	
	-- secondsToHMS
	-- seconds: number of seconds to be converted into HMS
	-- return <string>: string of the seconds in hh:mm:ss format
	['secondsToHMS'] = function(seconds: int)
		local mins: int = (seconds - seconds%60)/60
		seconds = seconds - mins*60

		local hrs: int = (mins - mins%60)/60
		mins = mins - hrs*60

		return string.format("%02i", hrs)..":"..string.format("%02i", mins)..":"..string.format("%02i", seconds)
	end, 

	-- misc functions
	
	-- suffixNum
	-- num: number to add a suffix with 
	-- decPlaces: # of decimal places to round (no negatives)
	-- return <string>: the suffixed number rounded up
	['suffixNum'] = function(num: float, decPlaces: int)
		decPlaces = decPlaces or 0 
		num = floor(num) -- round number
		local absNum: float = abs(num)
		if absNum < 1000 then return tostring(num) end -- no suffix
		
		local absNumLen: int = tostring(absNum):len()
		local absNum: string = tostring(floor(
			num + 5*10^( absNumLen - decPlaces-2 )
			))--round number to the visible decimal places

		local visibleNums: int = absNumLen%3 -- the amount of decimal places visible
		visibleNums = (visibleNums == 0 and 3) or visibleNums

		absNum = absNum:sub(1, visibleNums).. -- get the whole numbers when suffixed
			((decPlaces ~= 0) and '.'..absNum:sub(visibleNums+1, visibleNums+decPlaces) or "").. -- if there are decimal places to round, then round
			suffixes[ floor( (absNumLen-1)/3 ) ] -- get suffix wth the length of the number
		return (num < 0 and "-" or "")..absNum -- format the string with the appropriate extreme (pos/neg)
	end, 

	-- toCFrame
	-- vecOrCFrame: data to be converted
	-- return <CFrame>: the CFrame equivalent of the Vector3
	['toCFrame'] = function(vecOrCFrame: Vector3 | CFrame)
		return (typeof(vecOrCFrame) == "CFrame" and vecOrCFrame) or CFrame.new(vecOrCFrame)
	end,
	
	-- toVector3
	-- vecOrCFrame: data to be converted
	-- return <Vector3>: the CFrame equivalent of the Vector3
	['toVector3'] = function(vecOrCFrame: Vector3 | CFrame)
		return (typeof(vecOrCFrame) == "Vector3" and vecOrCFrame) or (vecOrCFrame == "CFrame" and vecOrCFrame.Position) or (warn("Only can provide a Vector3 or CFrame"))
	end,
	
	-- raycast
	-- origin: ray origin
	-- direction: ray direction 
	-- maxLength: how long the ray be casted
	-- params: table of raycast parameters (if none then default will be used)
	-- return <Instance?> the part hit during raycast, if any
	['raycast'] = function(origin: Vector3, direction: Vector3, maxLength: float?, params: dictionary?)  
		direction = direction.Unit*(maxLength or 1000)
		
		local rayParams: dictionary = RaycastParams.new()
		if params then
			for rayParam, rayArg in pairs(params) do 
				rayParams[rayParam] = rayArg 
			end
		end

		return workspace:Raycast(origin, direction, rayParams)
	end, 
	
	-- generateRandomStr
	-- strLength: length of the random string to be generated
	-- return <string>: a randomly generated string
	['generateRandomStr'] = function(strLength: int?)
		local str: string = '' 
		for i = 1, strLength or rand(10, 30) do 
			str = str..charTable[rand(1, #charTable)]
		end 
		return str 
	end,
	
	-- notify
	-- title: title of notification
	-- description: text under the title
	-- duration: how long the notification is up
	['notify'] = function(title: string?, description: string?, duration: float?)
		pcall(function()
			starterGui:SetCore("SendNotification", {
				Title = title or "Title",
				Text = description or "Description",
				Duration = duration or 2,
			})
		end)
	end,
	
	-- userId: a player's id, otherwise will be set to one's own id
	-- return <string>: the url of the user id
	['userIconURL'] = function(userId: int) 
		return string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png", userId or LP.UserId)
	end,
	
	-- newCoro
	-- callback: the function to be run in the new coroutine 
	['newCoro'] = function(callback: (any) -> ...any)
		return coroutine.wrap(callback)()
	end,
	
	-- killConnections
	-- connections: an array of connections to be disconnected
	['killConnections'] = killConnections,
	
	-- killClient
	['killClient'] = function()
		game:Shutdown()
	end
}

-- character movement

-- teleportTo
-- position: place to teleport the player to
baselineAPI.teleportTo = function(position: CFrame | Vector3) 
	baselineAPI.humanoidRoot().CFrame = baselineAPI.toCFrame(position)
end

-- tweenTo
-- position: place to tween the player to
-- return <Tween>: the tween used
baselineAPI.tweenTo = function(position: CFrame | Vector3, seconds: float, waitForComplete: boolean?)
	local tween: Tween = tweenServ:Create(baselineAPI.humanoidRoot(), TweenInfo.new(seconds or 2, linearEase), {CFrame = baselineAPI.toCFrame(position)})
	tween:Play()
	if waitForComplete then tween.Completed:Wait() return tween	end
end

-- tweenTo
-- position: place to teleport to
baselineAPI.walkTo = function(position: Vector3 | CFrame)
	baselineAPI.humanoid():MoveTo(baselineAPI.toVector3(position)) 

end

-- pathfind
-- position: where the humanoid should pathfind to
baselineAPI.pathfind = function(position: Vector3)
	local path: Instance = pathfindServ:CreatePath({
		AgentCanJump = true,
		WaypointSpacing = 1
	})
	path:ComputeAsync(baselineAPI.humanoidRoot().Position, baselineAPI.toVector3(position))
	local waypoints = path:GetWaypoints()

	local humanoid: Humanoid = baselineAPI.humanoid()
	for _, point in ipairs(waypoints) do
		humanoid:MoveTo(point.Position)
		humanoid.MoveToFinished:Wait()

		humanoid.Jump = (point.Action == Enum.PathWaypointAction.Jump)
	end
end

return baselineAPI

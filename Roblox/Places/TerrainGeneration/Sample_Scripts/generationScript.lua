-- server script
local blockStorage = game:GetService("ServerStorage"):WaitForChild("ItemStorage"):WaitForChild("Blocks")
local worldSystem = require(game:GetService("ServerStorage"):WaitForChild("WorldSystem")) -- import WorldSystem module scripts (similar to a class) 
local worldInfo = worldSystem.WorldInfo
local Plrs = game:GetService("Players")

--get world size from object system
local worldSize = worldInfo.Size

local playerParts = {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}

local origin = worldInfo.Origin

local dirtModel = blockStorage:WaitForChild("Midground"):WaitForChild("Dirt").Name
local grassModel = blockStorage.Midground:WaitForChild("Grass").Name
local stoneModel = blockStorage.Midground:WaitForChild("Stone").Name

local sizeInfo = worldInfo.Size
local origin = worldInfo.Origin
local boundary = worldInfo.Boundary

local xStart, xEnd = origin.X, boundary[1]
local yBoundaryMin, yBoundaryMax = origin.X, boundary[2]
local clamp, floor, noise = math.clamp, math.floor, math.noise

local seed = worldInfo.Seed or math.random()
local wavyness = 50
local density = 0.04
local grassStartHeight = worldInfo.Size.Y*0.6
local stoneFromDirtHeightLimit = 0

local chunks = {}
local generationTable = {}

origin, sizeInfo, boundary = nil

local startTime = os.clock()

--generate into a table
local threads = {}
for x = xStart, xEnd do
	generationTable[x] = {}
	
	--generation of block by block from topleft -> topright -> botomleft -> botomright soon
	
	local noiseY = floor(noise(x*density, seed) * wavyness) + grassStartHeight
	local stoneSeed = (seed*0.18+seed/0.85)^2
	generationTable[x][noiseY] = grassModel
	local grassY = noiseY

	local randomStone = clamp(grassY-floor(noise(x*density, stoneSeed)*wavyness*0.5) - grassStartHeight*0.5, yBoundaryMin, clamp(grassY - stoneFromDirtHeightLimit, yBoundaryMin, math.huge))
	coroutine.wrap(function()
		local threadIndex = #threads + 1
		threads[threadIndex] = false
		for below = grassY-1, -worldInfo.Size.Y*0.5, -1 do
			local belowModel = dirtModel
			if below < randomStone then belowModel = stoneModel end
			generationTable[x][below] = belowModel
			below = below % 6 ~= 0 or task.wait()
		end
		threads[threadIndex] = nil
	end)()
end

--load objects
repeat task.wait(0.3) until #threads == 0
for x, _ in pairs(generationTable) do
	local yValues = generationTable[x]
	for y, block in pairs(yValues) do
		worldSystem.placeBlock('', block, x, y, "Midground")
	end
	task.wait()	
end

print(os.clock()-startTime, "seconds elapsed") --for testing purposes

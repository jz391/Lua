-- module script (similar to a class)
local ServStorage = game:GetService("ServerStorage")
local blockStorage = ServStorage:WaitForChild("ItemStorage"):WaitForChild("Blocks")
local gameTerrain = workspace:WaitForChild("GameTerrain")

local floor = math.floor
local System = {}

--public variables
System.WorldInfo = {
	['Seed'] = math.random()*math.random(),
	['Size'] = Vector2.new(80, 60),
	['Origin'] = Vector2.new(0, 0), --bottom left corner
	['GlobalSpawn'] = workspace:WaitForChild("GameTerrain"):WaitForChild("Midground"):WaitForChild("SpawnPoint", 5),
}

System.WorldInfo.Boundary = {
	System.WorldInfo.Size.X + System.WorldInfo.Origin.X,
	System.WorldInfo.Size.Y + System.WorldInfo.Origin.Y
}

System.Blocks = {}
for x = 1, System.WorldInfo.Size.X do
	System.Blocks[x] = {}
end

--methods
function System.placeBlock(placer, blockName, blockPosX, blockPosY, field)
	local placerType = typeof(placer)
	if blockPosX < System.WorldInfo.Origin.X or blockPosX > System.WorldInfo.Boundary[1]
		or blockPosY < System.WorldInfo.Origin.Y or blockPosY > System.WorldInfo.Boundary[2] then 
	return end --restrict blocks to be placed in boundaries
	
	if placerType == 'Instance' and placer:IsA("Player") then
		--check and subtract player inventory
	end
	local blockObj
	if typeof(blockName) == "Instance" then
		blockObj, blockName = blockName, nil
		field = blockObj.Parent.Name
	else
		blockObj = blockStorage:WaitForChild(field):WaitForChild(blockName, 5)--find block object
		if not blockObj then warn(blockName, "not found in block storage") return nil end
	end
	local blockClone = blockObj:Clone()

	local newX, newY = floor(blockPosX+0.5), floor(blockPosY+0.5)
	
	blockClone:SetPrimaryPartCFrame(CFrame.new(newX, newY, 0))
	blockClone.Parent = gameTerrain:WaitForChild(field)
end

--ensures there is a global spawnpoint if none is set
if not System.WorldInfo['GlobalSpawn'] then
	local newPoint = Instance.new('Part')
	newPoint.Position, newPoint.Size = Vector3.new(), Vector3.new()
	newPoint.Color = Color3.new()
	newPoint.Anchored = true
	newPoint.CanTouch, newPoint.CanCollide, newPoint.CanQuery, newPoint.CastShadow = false, false, false, false
	newPoint.Transparency = 1
	System.WorldInfo['GlobalSpawn'] = newPoint
end

return System

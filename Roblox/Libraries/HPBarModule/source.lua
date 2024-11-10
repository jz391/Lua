local TServ = game:GetService("TweenService")
local Plrs = game:GetService("Players")
local LP = game.Players.LocalPlayer
local mouse = LP:GetMouse()

local refreshUis = Instance.new("BindableEvent")
local mainUi = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")

local defaultInfo_HP = TweenInfo.new(0.8, Enum.EasingStyle.Circular)
local defaultInfo_Ui = TweenInfo.new(1.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local basePos = UDim2.new(0.01, 0, 0.55, 0)
local padding = UDim2.new(0, 0, 0.02, 0)
local frame_YLength

do --create mainUI beforehand for quicker(?) cloning
	mainUi.Name = "HPBar"
	mainUi.ResetOnSpawn = true

	local nameHolder = Instance.new("TextButton")
	local notifyChange = Instance.new("TextLabel")
	local noHealth = Instance.new("TextLabel")
	local healthBar = Instance.new("TextLabel")
	local healthOverlay = Instance.new("TextLabel")
	local xButton = Instance.new("TextButton")

	mainFrame.BackgroundColor3 = Color3.new(0.24, 0.24, 0.24)
	mainFrame.BorderSizePixel = 0
	mainFrame.Position = UDim2.new(0.021, 0, 0.58, 0)
	mainFrame.Size = UDim2.new(0.21, 0, 0.04, 0)
	mainFrame.Visible = true

	nameHolder.Name = "nameHolder"
	nameHolder.AnchorPoint = Vector2.new(0, 1)
	nameHolder.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	nameHolder.BorderColor3 = Color3.fromRGB(89, 89, 89)
	nameHolder.BorderMode = Enum.BorderMode.Inset
	nameHolder.BorderSizePixel = 3
	nameHolder.Size = UDim2.new(0.8, 0, 0.7, 0)
	nameHolder.ZIndex = 5
	nameHolder.Text = "Player: nil"
	nameHolder.TextColor3 = Color3.fromRGB(206, 206, 206)
	nameHolder.TextScaled = true
	nameHolder.AutoButtonColor = false

	notifyChange.Name = "notifyChange"
	notifyChange.BackgroundColor3 = Color3.new(0, 0, 0)
	notifyChange.BackgroundTransparency = 1
	notifyChange.BorderSizePixel = 0
	notifyChange.Position = UDim2.new(1.026, 0, 0, 0)
	notifyChange.Size = UDim2.new(0.158, 0, 1, 0)
	notifyChange.ZIndex = 3
	notifyChange.RichText = true
	notifyChange.Text = "<b>+0 (0%)</b>"
	notifyChange.TextColor3 = Color3.new(0.56, 0, 0) --for when hp is going down (red)
	notifyChange.TextScaled = true
	notifyChange.TextStrokeColor3 = Color3.fromRGB(250, 250, 250)
	notifyChange.TextStrokeTransparency = 0
	notifyChange.Visible = false

	noHealth.Name = "noHealth"
	noHealth.BackgroundColor3 = Color3.fromRGB(143, 52, 52)
	noHealth.BorderSizePixel = 0
	noHealth.Size = UDim2.new(1, 0, 1, 0)
	noHealth.ZIndex = 4
	noHealth.Text = ""

	healthBar.Name = "healthBar"
	healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	healthBar.BorderSizePixel = 0
	healthBar.ZIndex = 5
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.Text = ""

	local uiGrad = Instance.new("UIGradient")
	uiGrad.Name = "uiGrad"
	uiGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(0, 0.603922, 0)), ColorSequenceKeypoint.new(1, Color3.new(0, 1, 0))}
	uiGrad.Rotation = 270
	uiGrad.Parent = healthBar

	healthOverlay.Name = "healthOverlay"
	healthOverlay.BackgroundTransparency = 1
	healthOverlay.BorderSizePixel = 0
	healthOverlay.Size = UDim2.new(1, 0, 1, 0)
	healthOverlay.RichText = true
	healthOverlay.ZIndex = 6
	healthOverlay.Font = Enum.Font.TitilliumWeb
	healthOverlay.Text = "<b>Health: 0/0 (not found)</b>"
	healthOverlay.TextColor3 = Color3.fromRGB(245, 245, 245)
	healthOverlay.TextScaled = true

	xButton.Name = "xButton"
	xButton.AnchorPoint = Vector2.new(0, 1)
	xButton.BackgroundColor3 = Color3.new(1, 1, 1)
	xButton.BorderColor3 = Color3.fromRGB(250, 90, 90)
	xButton.BorderMode = Enum.BorderMode.Inset
	xButton.BorderSizePixel = 3
	xButton.Position = UDim2.new(nameHolder.Size.X.Scale, 0, 0, 0)
	xButton.Size = UDim2.new(0.09, 0,nameHolder.Size.Y.Scale, 0)
	xButton.ZIndex = 5
	xButton.Text = "X"
	xButton.TextColor3 = Color3.fromRGB(207, 0, 0)
	xButton.TextScaled = true

	nameHolder.Parent = mainFrame
	notifyChange.Parent = mainFrame
	noHealth.Parent = mainFrame
	healthBar.Parent = mainFrame
	healthOverlay.Parent = mainFrame
	xButton.Parent = mainFrame

	mainFrame.Parent = nil
	frame_YLength = mainFrame.nameHolder.Size.Y.Scale*mainFrame.Size.Y.Scale + mainFrame.Size.Y.Scale + padding.Y.Scale
end

local abs = math.abs
local suffixes = {"k", "M", "B", "T", "Qd", "Qn"}
local function suffixNum(number)
	number = math.floor(number+0.5)
	local dpsAbs = tostring(abs(number))
	if dpsAbs:len() > 3 then --if number has more than 3 digits

		local viewNums = dpsAbs:len()%3
		if viewNums == 0 then viewNums = 3 end
		local places = math.floor((dpsAbs:len()-1)/3)
		local suffix = suffixes[places]

		dpsAbs = dpsAbs:sub(1, viewNums)..'.'..dpsAbs:sub(viewNums+1, viewNums+1)..suffix
	end

	return (number < 0 and "-" or "")..dpsAbs --string (not the absolute value in the end)
end

local function getHP(humanoid: Humanoid)
	if not humanoid then return nil end
	local percent = math.floor((humanoid.Health/humanoid.MaxHealth) * 100)
	local hp, hpMax = humanoid.Health, humanoid.MaxHealth
	hp, hpMax = suffixNum(hp), suffixNum(hpMax) --string
	return hp.." / "..hpMax.." ("..tostring(percent).."%)", percent
end

local function getNonBypassedBars()
	local insts = 0
	for i, v in pairs(mainUi:GetChildren()) do
		if not v:IsA("Frame") or v:FindFirstChild("bypassUi") then continue end
		insts += 1
	end
	return insts
end

local HPBarModule = {}
HPBarModule.__index = HPBarModule


function HPBarModule.setDefautlTweenInfoUi(givenInfo:TweenInfo)
	defaultInfo_Ui = givenInfo
end
function HPBarModule.setDefaultTweenInfoHP(givenInfo:TweenInfo)
	defaultInfo_HP = givenInfo
end
function HPBarModule.setPaddingInfo(givenInfo:UDim2)
	padding = givenInfo
	frame_YLength = mainFrame.nameHolder.Size.Y.Scale*mainFrame.Size.Y.Scale + mainFrame.Size.Y.Scale + padding.Y.Scale
	refreshUis:Fire()
end
function HPBarModule.setBasePos(givenInfo:UDim2)
	basePos = givenInfo
	frame_YLength = mainFrame.nameHolder.Size.Y.Scale*mainFrame.Size.Y.Scale + mainFrame.Size.Y.Scale + padding.Y.Scale
	refreshUis:Fire()
end

function HPBarModule:editEvents(delete, ...)
	local eventsToEdit = {...}
	local eventsTab = self.events
	if delete then
		for _, eventName in pairs(eventsToEdit) do
			eventsTab[eventName] = nil
		end
		return
	end
	for name, event in pairs(eventsToEdit) do
		eventsTab[(not tonumber(name) and name) or #eventsTab] = event --if you dont enter key pair with events, they can't be deleted unless the gui's X button is clicked
	end
end
function HPBarModule:editInitEvents(delete, ...) --initevents are disconnected every time player dies, unlike the normal events
	local eventsToEdit = {...}
	local eventsTab = self.initEvents
	if delete then
		for _, eventName in pairs(eventsToEdit) do
			eventsTab[eventName] = nil
		end
		return
	end
	for name, event in pairs(eventsToEdit) do
		eventsTab[(not tonumber(name) and name) or #eventsTab] = event --if you dont enter key pair with events, they can't be deleted unless the gui's X button is clicked
	end
end
function HPBarModule:editInitFuncs(delete, ...) -- add your function that initializes the init events
	local funcsToAdd = {...}
	local funcsTab = self.initFuncs
	for _, func in pairs(funcsToAdd) do
		funcsTab[#funcsTab] = func
	end
end


function HPBarModule:removeFormatting(fromModule)
	if not fromModule then warn("pls set the table's bypassUiFormat value to true instead") return end
	refreshUis:Fire(self.frame:GetAttribute("frameOrder"))
	self.frame:SetAttribute("frameOrder", nil)
end

function HPBarModule:removeBar(fromModule)
	print("Deleting bar")
	if not fromModule then warn("pls set the table's delete value to true instead") return end
	local frame, eventsTab, funcsTab = self.frame, {self.initEvents, self.events}, self.initFuncs
	if frame:FindFirstChild("nameHolder") then frame.nameHolder.Text = "Removing..." end
	for i in pairs(funcsTab) do
		funcsTab[i] = nil
	end
	for i = 1, 2 do
		for _, event in pairs(eventsTab[i]) do
			event:Disconnect()
		end
		eventsTab[i] = nil
	end
	eventsTab, funcsTab = nil

	coroutine.wrap(function()
		local goal = {Position = UDim2.new(-0.5, 0, frame.Position.Y.Scale, 0)}
		local tween = TServ:Create(frame, defaultInfo_Ui, goal)
		tween:Play()

		self.bypassUiFormat = true
		tween.Completed:Wait()

		frame.Parent = nil
		frame:Destroy()

		setmetatable(self.__index, nil)
		setmetatable(self, nil)
		coroutine.wrap(function()
			for i, v in pairs(self) do
				self[i] = nil
			end
			self = nil
		end)()
	end)()
end

-- constructor here:
function HPBarModule.newBar(charModel: Model | Player, propTab:table) -- padding is a number 1 to 1000 (scales a whole screen's length at 1000)
	print("Creating tab")
	propTab = propTab or {}

	local player = Plrs:GetPlayerFromCharacter(charModel)
	local playerName, human
	if player and player:IsA("Player") or charModel:IsA("Player") then --getting player and 
		if charModel:IsA("Player") then --if its already a player, set charModel to be the char of the player
			player = charModel
			charModel = player.Character or player.CharacterAdded:Wait()
		end

		human = charModel and charModel:FindFirstChildOfClass("Humanoid")
		while not human or not human:IsA("Humanoid") do
			human = charModel.ChildAdded:Wait()
		end

		playerName = '[Player]: '..player.Name
	end

	local human = human or charModel:FindFirstChildOfClass("Humanoid")
	if not human then warn("charModel contains no humanoid (please wait until the humanoid has been added for nonplayer characters), returning") return end

	local frame = mainFrame:Clone() --UI setup
	local refreshEvent, refreshUiFunc = nil

	frame:SetAttribute("frameOrder", getNonBypassedBars())

	local mainTab = {
		["bypassUiFormat"] = propTab.bypassUiFormat or false,
		["delete"] = false
	}
	local barTab = {
		["frame"] = frame,
		["initEvents"] = {refreshEvent or nil}, --init events are reconnected upon death as stated in HPBarModule:editInitEvents
		["events"] = {}, --put events here to prevent memory leak
		["initFuncs"] = {},
		["refreshOnRespawn"] = propTab.refreshOnRespawn or false --refresh gui on respawn
	}
	
	if propTab.bypassUiFormat == false then
		refreshUiFunc = function(startPos:UDim2, destroyingFrameOrder)
			if not startPos or typeof(startPos) ~= 'UDim2' then startPos = frame.Position end
			local currFrameOrder = frame:GetAttribute("frameOrder")
			if not currFrameOrder then return end

			if destroyingFrameOrder and destroyingFrameOrder <= currFrameOrder then
				currFrameOrder = currFrameOrder - 1
				frame:SetAttribute("frameOrder", currFrameOrder)
			end
			--[[
			local borderPixels = 0
			local function addBorderPixels(ui)
				if ui.BorderMode == Enum.BorderMode.Outline then
					borderPixels += ui.BorderSizePixel
				elseif ui.BorderMode == Enum.BorderMode.Middle then
					borderPixels += ui.BorderSizePixel*0.5
				else
					return
				end
			end
			addBorderPixels(frame, frame.nameHolder) addBorderPixels = nil
			]]
			local UI_YEnd = frame_YLength*currFrameOrder + (basePos.Y.Scale)
			frame.Position = startPos

			local goalTab = {Position = UDim2.new(basePos.X.Scale, 0, UI_YEnd, 0)}
			local tween = TServ:Create(frame, defaultInfo_Ui, goalTab)
			tween:Play()
		end

		local refreshEvent = refreshUis.Event:Connect(function(destroyingFrameOrder)
			if barTab and barTab.bypassUiFormat == true then refreshEvent:Disconnect() refreshUiFunc = nil return end
			refreshUiFunc(nil, destroyingFrameOrder)
		end)
		refreshUiFunc(basePos)
	end

	setmetatable(mainTab, HPBarModule)
	setmetatable(barTab, {
		__index = mainTab--[[function(_, i, v)
			if i ~= "bypassUiFormat" and i ~= "delete" then return mainTab[i] end
		end]],
		__newindex = function(self, i, v)
			print("New indexed", self, i, v)
			if i ~= "bypassUiFormat" and i ~= "delete" and v ~= true then rawset(mainTab,i,v)  return end
			if i == "delete" then
				self:removeBar(true) --ill rawset values above later or simething
			end
			self:removeFormatting(true)
			rawset(mainTab,i,v) 
		end
	})

	local healthOld, maxHealthOld = human.Health, human.MaxHealth
	local percentOld = human.Health/human.MaxHealth*100
	local function updateHP(init)
		local healthDiff = math.floor(human.Health - healthOld)
		if healthDiff == 0 and human.MaxHealth == maxHealthOld and init == nil then return end

		local percentNew = (human.Health/human.MaxHealth)*100
		local percentDiff = math.floor((percentNew-percentOld)*100)/100
		print("HDiff, percNew, percDiff", healthDiff, percentNew, percentDiff)

		if not (frame and frame:FindFirstChild("healthBar") and frame:FindFirstChild("notifyChange")) then return end
		local healthInfo, percent = getHP(human)
		local goal = {Size = UDim2.new(percent/100, 0, frame.healthBar.Size.Y.Scale, 0)}
		local tween = TServ:Create(frame.healthBar, defaultInfo_HP, goal)

		coroutine.wrap(function()
			if not frame or not frame:FindFirstChild("noHealth") then return end
			local noHealth = frame.noHealth
			task.wait(1)
			local percent = human.Health/human.MaxHealth
			goal = {Size = UDim2.new(percent, 0, noHealth.Size.Y.Scale, 0)}
			local noHPTween = TServ:Create(noHealth, defaultInfo_HP, goal)
			noHPTween:Play()
		end)()

		local notifChange = frame.notifyChange:Clone()
		notifChange.Parent = frame
		notifChange.Visible = true
		local notifyMoveGoal = {['Position'] = UDim2.new(notifChange.Position.X.Scale, 0, notifChange.Position.Y.Scale + 0.65, 0)}

		if healthDiff >= 0 then
			notifyMoveGoal = {['Position'] = UDim2.new(notifyMoveGoal['Position'].X.Scale, 0, -notifyMoveGoal['Position'].Y.Scale, 0)}
			if percentDiff == 0 then 
				notifChange.TextColor3 = Color3.new(0.6, 0.6, 0.6)
				percentDiff, healthDiff = 0, 0
			else
				notifChange.TextColor3 = Color3.new(0, 0.51, 0)
			end
		end

		healthOld, maxHealthOld, percentOld = human.Health, human.MaxHealth, percentNew
		local notifyTween = TServ:Create(notifChange, defaultInfo_HP, notifyMoveGoal)
		notifyTween:Play()

		tween:Play()
		notifChange.Text = '<b>'..suffixNum(healthDiff).."\n".."("..percentDiff.."%)"..'</b>'

		frame.healthOverlay.Text = "<b>"..healthInfo.."</b>"

		notifyTween.Completed:Connect(function()
			notifChange:Destroy()
		end)
	end

	local function DeathFunc()
		print('died')
		if barTab.delete then return end
		if not (player and barTab.refreshOnRespawn) then barTab.delete = true return end
		frame.healthOverlay.Text = "Waiting on respawn..."
		if player.Character ~= charModel then player.CharacterRemoving:Wait() end
		charModel = player.CharacterAdded:Wait()
		local newHuman = charModel:FindFirstChildOfClass("Humanoid")

		while not newHuman or not newHuman:IsA("Humanoid") do
			newHuman = charModel.ChildAdded:Wait()
		end
		if barTab.delete then return end
		human, newHuman = newHuman, nil

		for _, event in pairs(barTab.initEvents) do
			coroutine.wrap(function()
				event:Disconnect()
			end)()
		end
		for _, initFunc in pairs(barTab.initFuncs) do
			coroutine.wrap(function()
				initFunc()
			end)()
		end
		print("successful reload")
	end
	local function refreshEventsFunc() 
		updateHP(true)
		barTab:editInitEvents( --place these into an init func so that it refreshes on death
			false,
			human:GetPropertyChangedSignal("Health"):Connect(updateHP),
			human:GetPropertyChangedSignal("MaxHealth"):Connect(updateHP),
			human.Died:Connect(DeathFunc),
			human.Destroying:Connect(DeathFunc),
			player and player.CharacterRemoving:Connect(DeathFunc)
		)
	end

	barTab:editInitFuncs(
		false,
		updateHP,
		refreshUiFunc,
		refreshEventsFunc
	)
	refreshEventsFunc()

	barTab:editEvents(false, frame.xButton.MouseButton1Up:Connect(function()
		barTab.delete = true
	end))

	if propTab.draggable then
		barTab:editEvents(false, frame.nameHolder.MouseButton1Down:Connect(function()
			if barTab.bypassUiFormat == false then barTab.bypassUiFormat = true end
			local clickEnd
			local clickEndEvent = frame.nameHolder.MouseButton1Up:Connect(function()
				clickEnd = true
			end)
			repeat
				task.wait(0.03)
				frame.AnchorPoint = Vector2.new(0.5, 0.15)
				frame.Position = UDim2.new(mouse.X/mouse.ViewSizeX, 0, mouse.Y/mouse.ViewSizeY, 0)
			until clickEnd == true or barTab.delete == true
			clickEndEvent:Disconnect()
		end))
	end

	frame.nameHolder.Text = playerName or "[NPC]: "..charModel.Name
	frame.Name = charModel.Name
	frame.Parent = mainUi
	frame.Visible = true
	propTab = nil
	return barTab
end


local s, e = pcall(function()
	mainUi.Parent = game:WaitForChild("CoreGui", 2)
end)
if e then mainUi.Parent = LP:WaitForChild("PlayerGui") end
return HPBarModule

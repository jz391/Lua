-- client script
-- limited to only positive integer inputs

local Input = script.Parent:WaitForChild("Input")
local Confirm = script.Parent:WaitForChild("Confirm")
local FactorsFrame = script.Parent.Parent:WaitForChild("FactorsFrame")
local EndTask = script.Parent:WaitForChild("EndTask")
local floor = math.floor
local prevConfirmText = Confirm.Text
local db = false

local acceptedInputs = { -- input from varying platforms
	Enum.UserInputType.MouseButton1.Value,
	Enum.UserInputType.MouseButton2.Value,
	Enum.UserInputType.Touch.Value
}
local labelSize = UDim2.new(0.5, 0, 0, 40) --only should change Y Offset (4th arg)

EndTask.Visible = false
Confirm.InputEnded:Connect(function(inputObj) -- numbers like 1M+ may take a while
	if not table.find(acceptedInputs, inputObj.UserInputType.Value) then return end
	if db then return end
	db = true 
	local number = tonumber(Input.Text)
	
	if not number or number < 0 or floor(number) ~= number then 
		Confirm.Text = "Please input a positive integer in the text box" task.wait(3) Confirm.Text = prevConfirmText 
		db = false
	return end
	
	local numOfFactors = 0
	local function createFactor(factor1, factor2) --outputs factor to gui
		local Txt1, Txt2, labelPos1 = Instance.new("TextLabel"), Instance.new("TextLabel"), UDim2.new(0, 0, 0, numOfFactors*labelSize.Y.Offset)
		numOfFactors += 1
		
		Txt1.Text, Txt2.Text = tostring(factor1), tostring(factor2)
		Txt1.Size, Txt2.Size = labelSize, labelSize
		Txt1.Position, Txt2.Position = labelPos1, UDim2.new(0.5, labelPos1.X, labelPos1.Y.Scale, labelPos1.Y.Offset)
		Txt1.BorderMode, Txt2.BorderMode = Enum.BorderMode.Inset, Enum.BorderMode.Inset
		Txt1.Parent, Txt2.Parent = FactorsFrame, FactorsFrame
		FactorsFrame.CanvasSize = UDim2.new(0, 0, 0, numOfFactors*labelSize.Y.Offset)
	end
	
	local endTask = false --stop calculating when user has clicked button
	local function setEndTaskVal()
		endTask = true
	end

  --wait for user to press end button
	EndTask.TouchTap:Connect(setEndTaskVal) 
	EndTask.MouseButton1Up:Connect(setEndTaskVal)

	EndTask.Visible = true
	
	for i, v in pairs(FactorsFrame:GetChildren()) do --reset canvas
		v:Destroy()
	end
	FactorsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	
	createFactor(1, number)
	local recentFactor2 = 1
	for factor1 = 2, number-1 do --start factoring
		if factor1 % 150 == 0 then task.wait()  if endTask then break end  end

		local factor2 = number/factor1
		
		if floor(factor2) ~= factor2 then continue end
		if recentFactor2 == factor1 then break end
		
		recentFactor2 = factor2
		createFactor(factor1, factor2)
		
		if factor1 == factor2 then break end --stops when similar # found
	end
	
	EndTask.Visible = false
	task.wait(0.2)
	db = false
end)

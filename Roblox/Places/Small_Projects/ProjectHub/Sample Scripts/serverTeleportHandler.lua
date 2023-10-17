-- this script handles teleports to my other Roblox projects from the server
local TpServ = game:GetService("TeleportService")
local notifRemote = game:GetService("ReplicatedStorage"):WaitForChild("PromptNotify")

game:GetService("ProximityPromptService").PromptTriggered:Connect(function(promptObj, plr)
	local id = promptObj:WaitForChild("ID").Value
	
	print("Attempting to teleport player ("..plr.Name..")\nPlace Name:", promptObj.Parent.SG.Text.Text, "\nPlace Id:", id)
	notifRemote:FireClient(plr)
	TpServ:Teleport(id, plr) --teleport the player
end)

local enumStrLength = tostring(Enum.TeleportResult):len()

local failedTP = TpServ.TeleportInitFailed:Connect(function(plr, tpResult, errorMsg, tpOptions)
	local errorEnum, tpOptions = nil
	if tpResult ~= Enum.TeleportResult.Success then
		tpResult = tostring(tpResult)
		errorEnum = string.sub(tpResult, enumStrLength, tpResult:len())
		errorMsg = errorMsg or "No other info given"
	end
	warn("Error teleporting", plr.name, "\nError enum:", errorEnum, "\nError message:", errorMsg)
	notifRemote:FireClient(plr, errorEnum, errorMsg) -- notifies player of issue when teleporting
end)

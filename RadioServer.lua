local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local DispatchModule = require(ReplicatedStorage:WaitForChild("DispatchModule"))

-- SetCallsign RemoteFunction
local function SetCallSign(player, callsign)
	local status = player:FindFirstChild("Status")
	if status then
		local callsignValue = status:FindFirstChild("Callsign")
		if callsignValue then
			callsignValue.Value = callsign
			Remotes.SetCallsignEvent:FireAllClients(player.Name, callsign)  
			return true
		else
			return false, "Callsign not found in Status."
		end
	else
		return false, "Status not found for player."
	end
end

--[[
local function SendNewCallMessage(Channel)
	for _, v in ipairs(Players:GetChildren()) do
		if v:IsA('Player') then
			Remotes.RadioMessageSent:FireClient(v, "RADIO - New call has been received. Please check your CAD for more information.", Channel, Color3.fromRGB(0, 85, 255), true) -- Blue color for dispatch
		end
	end
end
--]]

ReplicatedStorage.Remotes.SetCallsign.OnServerInvoke = SetCallSign
Remotes.RadioMessageSent.OnServerEvent:Connect(function(Player, Message, Channel)
	local status = Player:FindFirstChild("Status")
	local callsign = status and status:FindFirstChild("Callsign") and status.Callsign.Value or "nil"
	for _, v in ipairs(Players:GetChildren()) do
		if v:IsA('Player') then
			local filteredMessage = game.Chat:FilterStringAsync(Message, Player, v)
			Remotes.RadioMessageSent:FireClient(v, callsign .. " - " .. filteredMessage, Channel, nil, false)
		end
	end
	--[[
	workspace.Part.ClickDetector.MouseClick:Connect(function()
		SendNewCallMessage(Channel)
	end)
	--]]
	local dispatchResponse, statusUpdate = DispatchModule.CheckCommand(Message, callsign)
	if dispatchResponse then
		task.wait(1.5) -- Delay for realism

		for _, v in ipairs(Players:GetChildren()) do
			if v:IsA('Player') then
				Remotes.RadioMessageSent:FireClient(v, "RADIO - " .. dispatchResponse, Channel, Color3.fromRGB(0, 85, 255), true) -- Blue color for dispatch
			end
		end
		
		if statusUpdate then
			local statusKey = status:FindFirstChild(statusUpdate.key)
			if statusKey then
				statusKey.Value = statusUpdate.value
			else
				warn("Status key '" .. statusUpdate.key .. "' not found for player " .. Player.Name)
			end
		end
	end
end)





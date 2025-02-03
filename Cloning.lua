game.Players.PlayerAdded:Connect(function(Player)
	local ClonedFolder = script.Status:Clone()
	ClonedFolder.Parent = Player
end)


Include a folder called status inside that folder there is the callsign, channel,onduty and radio on

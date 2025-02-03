local DispatchModule = {}

DispatchModule.Commands = {
	["radio show me 10-8"] = {response = "Copy %s, showing you 10-8.", statusUpdate = {key = "OnDuty", value = true}},
	["radio show me 10-7"] = {response = "Copy %s, showing you 10-7.", statusUpdate = {key = "OnDuty", value = false}},
	-- Add more commands and status updates here
}

function DispatchModule.CheckCommand(Message, Callsign)
	for command, data in pairs(DispatchModule.Commands) do
		if string.lower(Message) == command then
			return data.response and string.format(data.response, Callsign), data.statusUpdate
		end
	end
	return nil, nil
end

return DispatchModule

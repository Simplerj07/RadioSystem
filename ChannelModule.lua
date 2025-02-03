local ChannelsModule = {}

ChannelsModule.Channels = {
	["Riverwood Police Department"] = {
		Default = {"MAIN COMMUNICATIONS"},
		Access = {
			["SIT1"] = true,
			["SIT2"] = false
		},
		Frequencies = {
			["MAIN COMMUNICATIONS"] = "470.0000 MHz UHF | Police Band / Zone",
			["SIT1"] = "471.0000 MHz UHF | Police Band / Zone",
			["SIT2"] = "472.0000 MHz UHF | Police Band / Zone"
		}
	},
	["Security"] = {
		Default = {"SEC"},
		Access = {
			["MAIN COMMUNICATIONS"] = false,
			["SIT2"] = false
		},
		Frequencies = {
			["SEC"] = "470.0503 MHz UHF | SEC / Zone"
		}
	},
	["Default"] = {
		Default = {"SIT2"},
		Access = {
			["MAIN COMMUNICATIONS"] = false,
			["SIT1"] = false
		},
		Frequencies = {
			["SIT2"] = "474.0000 MHz UHF",
			["MAIN COMMUNICATIONS"] = "470.0000 MHz UHF"
		}
	}
}

return ChannelsModule

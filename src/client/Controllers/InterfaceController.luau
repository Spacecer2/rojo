local GuiService = game:GetService("GuiService")

local InterfaceController = {}

function InterfaceController.Init()
	-- Disable default Roblox UI that interferes with FPS games
	GuiService.TouchControlsEnabled = false
end

function InterfaceController.Start()
	print("Interface Controller Started")
	-- Here we will eventually load the HUD
end

return InterfaceController
local Theme = {
	Colors = {
		Background = Color3.fromRGB(15, 15, 15),
		Panel = Color3.fromRGB(30, 30, 35),
		AccentBlue = Color3.fromRGB(0, 162, 255),
		AccentYellow = Color3.fromRGB(255, 215, 0),
		AccentGold = Color3.fromRGB(255, 215, 0),
		TextMain = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 180, 180),
		Success = Color3.fromRGB(0, 255, 120),
		Delete = Color3.fromRGB(255, 70, 70),
		Overlay = Color3.fromRGB(0, 0, 0)
	},
	
	Fonts = {
		Main = Enum.Font.Gotham,
		Bold = Enum.Font.GothamBold,
		Black = Enum.Font.GothamBlack
	},
	
	Transitions = {
		Default = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		Quick = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		Smooth = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	},
	
	Sounds = {
		Hover = "rbxassetid://6042048399",  -- Soft blip
		Click = "rbxassetid://6895079853",  -- Mechanical click
		Back = "rbxassetid://6895079667",   -- Thud/Back
		Transition = "rbxassetid://6042047495" -- Swoosh
	}
}

return Theme
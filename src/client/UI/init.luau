local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Theme = require(ReplicatedStorage:WaitForChild("Constants"):WaitForChild("Theme"))

local UI = {}

-- Utility: Play UI Sound
function UI.PlaySound(soundId, volume)
	if not soundId or soundId == "" then return end
	
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.5
	sound.PlayOnRemove = true
	sound.Parent = SoundService
	sound:Destroy() -- Triggers PlayOnRemove
end

-- Utility: Apply Visual/Audio Feedback
function UI.ApplyFeedback(button, options)
	options = options or {}
	local originalSize = button.Size
	local hoverScale = options.HoverScale or 1.05
	local pressScale = options.PressScale or 0.95
	
	-- Hover
	button.MouseEnter:Connect(function()
		if options.HoverSound ~= false then
			UI.PlaySound(Theme.Sounds.Hover, 0.3)
		end
		
		TweenService:Create(button, Theme.Transitions.Quick, {
			Size = UDim2.new(
				originalSize.X.Scale * hoverScale, 
				originalSize.X.Offset * hoverScale, 
				originalSize.Y.Scale * hoverScale, 
				originalSize.Y.Offset * hoverScale
			)
		}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, Theme.Transitions.Default, {Size = originalSize}):Play()
	end)
	
	-- Press
	button.MouseButton1Down:Connect(function()
		if options.ClickSound ~= false then
			UI.PlaySound(Theme.Sounds.Click, 0.5)
		end
		
		TweenService:Create(button, Theme.Transitions.Quick, {
			Size = UDim2.new(
				originalSize.X.Scale * pressScale, 
				originalSize.X.Offset * pressScale, 
				originalSize.Y.Scale * pressScale, 
				originalSize.Y.Offset * pressScale
			)
		}):Play()
	end)
	
	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, Theme.Transitions.Quick, {
			Size = UDim2.new(
				originalSize.X.Scale * hoverScale, 
				originalSize.X.Offset * hoverScale, 
				originalSize.Y.Scale * hoverScale, 
				originalSize.Y.Offset * hoverScale
			)
		}):Play()
	end)
end

-- Widget: Button
function UI.Button(props)
	local btn = Instance.new("TextButton")
	btn.Name = props.Name or "Button"
	btn.Text = props.Text or ""
	btn.Font = props.Font or Theme.Fonts.Bold
	btn.TextSize = props.TextSize or 14
	btn.TextColor3 = props.TextColor or Theme.Colors.TextMain
	btn.BackgroundColor3 = props.BackgroundColor or Theme.Colors.Panel
	btn.Size = props.Size or UDim2.fromOffset(200, 50)
	btn.Position = props.Position or UDim2.fromScale(0, 0)
	btn.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	btn.BackgroundTransparency = props.BackgroundTransparency or 0
	btn.AutoButtonColor = false -- Disable default dark/bright effect
	
	if props.Corner then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, props.Corner)
		corner.Parent = btn
	end
	
	if props.Feedback ~= false then
		UI.ApplyFeedback(btn, {
			HoverScale = props.HoverScale,
			PressScale = props.PressScale,
			HoverSound = props.HoverSound,
			ClickSound = props.ClickSound
		})
	end
	
	btn.Parent = props.Parent
	return btn
end

-- Widget: Panel
function UI.Panel(props)
	local frame = Instance.new("Frame")
	frame.Name = props.Name or "Panel"
	frame.Size = props.Size or UDim2.fromScale(1, 1)
	frame.Position = props.Position or UDim2.fromScale(0, 0)
	frame.BackgroundColor3 = props.BackgroundColor or Theme.Colors.Panel
	frame.BackgroundTransparency = props.BackgroundTransparency or 0
	frame.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	
	if props.Corner then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, props.Corner)
		corner.Parent = frame
	end
	
	frame.Parent = props.Parent
	return frame
end

-- Widget: Label
function UI.Label(props)
	local label = Instance.new("TextLabel")
	label.Name = props.Name or "Label"
	label.Text = props.Text or ""
	label.Font = props.Font or Theme.Fonts.Main
	label.TextSize = props.TextSize or 14
	label.TextColor3 = props.TextColor or Theme.Colors.TextMain
	label.Size = props.Size or UDim2.new(1, 0, 0, 20)
	label.Position = props.Position or UDim2.fromScale(0, 0)
	label.BackgroundTransparency = 1
	label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	
	label.Parent = props.Parent
	return label
end

return UI
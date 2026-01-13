local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Theme = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Constants"):WaitForChild("Theme"))

local UI = {}

-- Utility: Apply Hover Effect
function UI.ApplyHover(button, targetScale)
	local originalSize = button.Size
	targetScale = targetScale or 1.05
	
	button.MouseEnter:Connect(function()
		TweenService:Create(button, Theme.Transitions.Default, {
			Size = UDim2.new(
				originalSize.X.Scale * targetScale, 
				originalSize.X.Offset * targetScale, 
				originalSize.Y.Scale * targetScale, 
				originalSize.Y.Offset * targetScale
			)
		}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, Theme.Transitions.Default, {Size = originalSize}):Play()
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
	
	if props.Corner then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, props.Corner)
		corner.Parent = btn
	end
	
	if props.Hover ~= false then
		UI.ApplyHover(btn, props.HoverScale)
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
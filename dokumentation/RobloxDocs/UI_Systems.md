# Roblox UI & GUI Systems

Building user interfaces with ScreenGui, BillboardGui, and UI elements.

## GUI Hierarchy

```
ScreenGui (parent: PlayerGui)
├── Frame (container)
│   ├── TextLabel
│   ├── TextButton
│   └── ImageLabel
├── ImageButton
└── ScrollingFrame
    ├── UIGridLayout
    └── [Dynamic items]
```

## ScreenGui (HUD & Menus)

GUI that appears on player's screen.

```lua
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false  -- Keep GUI after respawn
gui.Name = "HUD"
gui.Parent = playerGui

-- Create frame
local frame = Instance.new("Frame")
frame.Name = "MainPanel"
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0
frame.Parent = gui

-- Add label
local label = Instance.new("TextLabel")
label.Text = "Health: 100"
label.Size = UDim2.new(1, 0, 0, 50)
label.BackgroundTransparency = 1
label.TextScaled = true
label.TextColor3 = Color3.new(1, 0, 0)
label.Parent = frame
```

## BillboardGui (3D Labels)

GUI that floats in the world.

```lua
-- Create billboard above character head
local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(0, 100, 0, 50)
billboard.MaxDistance = 100  -- Only visible within 100 studs
billboard.MaxHeight = 50
billboard.MaxWidth = 50
billboard.Parent = character:FindFirstChild("Head")

-- Add name label
local nameLabel = Instance.new("TextLabel")
nameLabel.Text = player.Name
nameLabel.BackgroundColor3 = Color3.new(0, 0, 0)
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.TextScaled = true
nameLabel.Size = UDim2.new(1, 0, 1, 0)
nameLabel.Parent = billboard

-- Add damage floating text
local damageLabel = Instance.new("TextLabel")
damageLabel.Text = "-50 HP"
damageLabel.TextColor3 = Color3.new(1, 0, 0)
damageLabel.Size = UDim2.new(0, 50, 0, 20)
damageLabel.TextScaled = true
damageLabel.Parent = billboard

-- Animate damage popup
game:GetService("TweenService"):Create(
    damageLabel,
    TweenInfo.new(1),
    {Position = UDim2.new(0, 0, 0, -50)}
):Play()
```

## Common UI Elements

### TextLabel
```lua
local label = Instance.new("TextLabel")
label.Text = "Welcome"
label.TextSize = 24
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
label.Size = UDim2.new(0, 200, 0, 50)
label.Parent = parentFrame
```

### TextButton
```lua
local button = Instance.new("TextButton")
button.Text = "Click Me"
button.Size = UDim2.new(0, 100, 0, 50)
button.Parent = parentFrame

button.MouseButton1Click:Connect(function()
    print("Button clicked!")
end)

-- Hover effects
button.MouseEnter:Connect(function()
    button.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
end)

button.MouseLeave:Connect(function()
    button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
end)
```

### ImageLabel
```lua
local image = Instance.new("ImageLabel")
image.Image = "rbxassetid://1234567890"
image.Size = UDim2.new(0, 128, 0, 128)
image.BackgroundTransparency = 1
image.Parent = parentFrame
```

### ScrollingFrame
```lua
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 1000)  -- Larger content
scrollingFrame.ScrollBarThickness = 12
scrollingFrame.Parent = containerFrame

-- Add UIGridLayout for automatic item arrangement
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 100, 0, 100)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.Parent = scrollingFrame
```

## Layout Systems

### UIListLayout (Vertical/Horizontal List)
```lua
local listLayout = Instance.new("UIListLayout")
listLayout.Orientation = Enum.Orientation.Vertical
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = containerFrame

-- Items automatically arrange vertically
for i = 1, 10 do
    local item = Instance.new("Frame")
    item.Size = UDim2.new(1, 0, 0, 50)
    item.Parent = containerFrame
end
```

### UIGridLayout (Grid)
```lua
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 100, 0, 100)
gridLayout.FillDirection = Enum.FillDirection.Horizontal
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
gridLayout.Parent = containerFrame
```

### UITableLayout (Table)
```lua
local tableLayout = Instance.new("UITableLayout")
tableLayout.FillDirection = Enum.FillDirection.Horizontal
tableLayout.Rows = 5
tableLayout.Columns = 3
tableLayout.Parent = containerFrame
```

## UI Animations

### Tweening UI Elements
```lua
local TweenService = game:GetService("TweenService")

-- Fade in
local tweenInfo = TweenInfo.new(
    1,  -- Duration
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.InOut
)

local tween = TweenService:Create(frame, tweenInfo, {
    BackgroundTransparency = 0.5
})

tween:Play()
```

### Position Animation
```lua
-- Slide panel in from left
local targetPos = frame.Position
frame.Position = UDim2.new(-1, 0, targetPos.Y.Scale, targetPos.Y.Offset)

TweenService:Create(frame, TweenInfo.new(0.5), {
    Position = targetPos
}):Play()
```

## Text Scaling & Responsiveness

### Relative Sizing
```lua
-- Size relative to parent (0.5 = 50% of parent)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.5, 0, 0.5, 0)  -- 50% width, 50% height, no pixel offset

-- Position relative to parent
frame.Position = UDim2.new(0.25, 0, 0.25, 0)  -- Centered
```

### Aspect Ratio Constraint
```lua
local aspectRatio = Instance.new("UIAspectRatioConstraint")
aspectRatio.AspectRatio = 16/9  -- 16:9 ratio
aspectRatio.Parent = frame
```

## Text Input

```lua
local textBox = Instance.new("TextBox")
textBox.PlaceholderText = "Enter text..."
textBox.Size = UDim2.new(0, 200, 0, 40)
textBox.Parent = frame

-- Get input when player hits Enter
textBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local inputText = textBox.Text
        print("Player typed:", inputText)
        textBox.Text = ""  -- Clear
    end
end)
```

## Warzone-Style HUD Example

```lua
-- Combat HUD
local HudFrame = Instance.new("Frame")
HudFrame.Size = UDim2.new(1, 0, 1, 0)
HudFrame.BackgroundTransparency = 1
HudFrame.Parent = playerGui

-- Health bar
local healthBar = Instance.new("Frame")
healthBar.Size = UDim2.new(0, 200, 0, 30)
healthBar.Position = UDim2.new(0.5, -100, 1, -40)  -- Bottom center
healthBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
healthBar.Parent = HudFrame

local healthFill = Instance.new("Frame")
healthFill.Size = UDim2.new(1, 0, 1, 0)
healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
healthFill.Parent = healthBar

-- Ammunition counter
local ammoLabel = Instance.new("TextLabel")
ammoLabel.Size = UDim2.new(0, 100, 0, 50)
ammoLabel.Position = UDim2.new(1, -110, 1, -60)
ammoLabel.Text = "30 / 240"
ammoLabel.Font = Enum.Font.GothamBold
ammoLabel.TextSize = 20
ammoLabel.TextColor3 = Color3.new(1, 1, 1)
ammoLabel.BackgroundTransparency = 1
ammoLabel.Parent = HudFrame

-- Minimap
local minimap = Instance.new("ImageLabel")
minimap.Size = UDim2.new(0, 150, 0, 150)
minimap.Position = UDim2.new(1, -160, 0, 10)
minimap.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
minimap.Parent = HudFrame

-- Update health bar when humanoid takes damage
humanoid.HealthChanged:Connect(function(health)
    healthFill.Size = UDim2.new(health / humanoid.MaxHealth, 0, 1, 0)
end)
```

## Best Practices

1. **Use UDim2 for positioning** - Scales with screen size
2. **Organize with Frames** - Group related UI elements
3. **Use Layouts** - Automatic arrangement reduces manual positioning
4. **Cache GUI elements** - Store references to frequently accessed parts
5. **Disable ResetOnSpawn** - Keep persistent UI elements
6. **Use TextScaled** - Automatic font sizing based on container
7. **Transparency for layers** - Create depth with semi-transparent elements
8. **Mobile support** - Test with different screen sizes

## UI Events

```lua
frame.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        print("Clicked frame")
    end
end)

frame.MouseEnter:Connect(function()
    print("Mouse over frame")
end)

frame.MouseLeave:Connect(function()
    print("Mouse left frame")
end)
```

---

**For more information:**
- [GUI Documentation](https://create.roblox.com/docs/reference/engine/classes/ScreenGui)
- [UI Best Practices](https://create.roblox.com/docs/tutorials)
- [Text Guidelines](https://create.roblox.com/docs/reference/engine/classes/TextLabel)

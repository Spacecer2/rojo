# Roblox Services Reference

Built-in services that manage core Roblox functionality.

## Essential Services Overview

Services are singleton objects that manage key functionality. Access them via `game:GetService()`.

### Player & User Management

**Players Service**
```lua
local Players = game:GetService("Players")

-- Connect to player joining
Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " joined")
end)

-- Connect to player leaving
Players.PlayerRemoving:Connect(function(player)
    print(player.Name .. " left")
end)

-- Get specific player
local player = Players:FindFirstChild("PlayerName")
local playerById = Players:GetPlayerByUserId(123456)

-- Get all players
for _, player in pairs(Players:GetPlayers()) do
    print(player.Name)
end
```

**UserService** - User information
```lua
local UserService = game:GetService("UserService")
-- Get user ID, username info
```

### Networking & Communication

**RemoteEvent** - One-way communication
```lua
local Players = game:GetService("Players")
local RemoteEvent = Instance.new("RemoteEvent")

-- Server sends to client
RemoteEvent:FireClient(player, data)
RemoteEvent:FireAllClients(data)

-- Client receives
RemoteEvent.OnClientEvent:Connect(function(data)
    print("Received:", data)
end)

-- Client sends to server
RemoteEvent:FireServer(data)

-- Server receives
RemoteEvent.OnServerEvent:Connect(function(player, data)
    print(player.Name, "sent:", data)
end)
```

**RemoteFunction** - Two-way communication
```lua
local RemoteFunction = Instance.new("RemoteFunction")

-- Server function
RemoteFunction.OnServerInvoke = function(player, arg)
    return player.Name .. " sent: " .. arg
end

-- Client call
local result = RemoteFunction:InvokeServer("Hello")

-- Client function
RemoteFunction.OnClientInvoke = function(arg)
    return "Client response"
end

-- Server call
local response = RemoteFunction:InvokeClient(player, "Hello")
```

### Game Loop & Timing

**RunService** - Frame updates and timing
```lua
local RunService = game:GetService("RunService")

-- Client-side frame update (runs on every frame)
RunService.RenderStepped:Connect(function(deltaTime)
    -- Update camera, animations, etc.
end)

-- Server-side frame update
RunService.Heartbeat:Connect(function(deltaTime)
    -- Server logic, physics, etc.
end)

-- Before physics simulation
RunService.PreSimulation:Connect(function()
    -- Update velocities, constraints
end)

-- After physics simulation
RunService.PostSimulation:Connect(function()
    -- React to physics results
end)

-- Check if running in Studio or game
if RunService:IsStudio() then
    print("Running in Studio")
end

if RunService:IsClient() then
    print("Running on client")
end

if RunService:IsServer() then
    print("Running on server")
end
```

### Data Persistence

**DataStoreService** - Persistent player data
```lua
local DataStoreService = game:GetService("DataStoreService")
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

-- Save data
playerDataStore:SetAsync(player.UserId, {level = 5, coins = 100})

-- Load data
local data = playerDataStore:GetAsync(player.UserId)

-- Update with versioning
local newData = playerDataStore:UpdateAsync(player.UserId, function(oldData)
    if oldData == nil then
        oldData = {level = 1}
    end
    oldData.level = oldData.level + 1
    return oldData
end)
```

### Input Handling

**ContextActionService** - Keyboard/controller input
```lua
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

-- Bind action
ContextActionService:BindAction("Jump", function(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        print("Jump!")
    end
end, false, Enum.KeyCode.Space)

-- Unbind when done
ContextActionService:UnbindAction("Jump")
```

**UserInputService** - Direct input
```lua
local UserInputService = game:GetService("UserInputService")

-- Keyboard input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then
        print("W pressed")
    end
end)

-- Mouse input
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
Mouse.Button1Down:Connect(function()
    print("Left click")
end)
```

### Animation & Tweening

**TweenService** - Smooth animations
```lua
local TweenService = game:GetService("TweenService")

local part = Instance.new("Part")
local tweenInfo = TweenInfo.new(
    1,  -- Duration
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.InOut
)

local tween = TweenService:Create(part, tweenInfo, {
    Position = Vector3.new(10, 0, 0),
    Color = Color3.new(1, 0, 0)
})

tween:Play()
tween.Completed:Connect(function(playbackState)
    if playbackState == Enum.PlaybackState.Completed then
        print("Animation finished")
    end
end)
```

### Lighting & Environment

**Lighting** - Scene lighting
```lua
local Lighting = game:GetService("Lighting")

-- Ambient lighting
Lighting.Ambient = Color3.new(1, 1, 1)
Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)

-- Time of day
Lighting.ClockTime = 14  -- 2:00 PM

-- Effects
local bloom = Instance.new("BloomEffect", Lighting)
bloom.Intensity = 2
```

### Sound

**SoundService** - Audio management
```lua
local SoundService = game:GetService("SoundService")

-- Create sound
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://123456789"
sound.Volume = 0.5
sound.Parent = workspace

-- Play
sound:Play()

-- Stop
sound:Stop()

-- Pause/Resume
sound.TimePosition = 5  -- Jump to 5 seconds
```

### Physics

**PhysicsService** - Advanced physics
```lua
local PhysicsService = game:GetService("PhysicsService")

-- Create region
local region = PhysicsService:CreateRegion3FromLocations(v1, v2)
local terrain = workspace.Terrain

-- Fill terrain
terrain:FillBall(center, radius, material)
```

### UI & GUI

**GuiService** - GUI management
```lua
local GuiService = game:GetService("GuiService")

-- Check if on mobile
if GuiService:IsTenFootInterface() then
    print("Large screen UI")
end
```

## Common Patterns

### Safe Service Access
```lua
local function getService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and service or nil
end
```

### Event Connection Management
```lua
local connections = {}

function addConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

function disconnectAll()
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
    connections = {}
end
```

---

**For more information:**
- [Official Service API](https://create.roblox.com/docs/reference/engine)
- [Scripting Guide](https://create.roblox.com/docs/tutorials/scripting)

# Roblox Performance Optimization Guide

Techniques to maximize frame rate, reduce lag, and optimize resource usage.

## Performance Profiling

### Finding Bottlenecks
```lua
local startTime = tick()

-- Code to measure
local result = complexCalculation()

local elapsed = tick() - startTime
print("Operation took", elapsed * 1000, "ms")
```

### Using Microprofiler (Studio Only)
- In Studio: Debug → Show Microprofiler (Ctrl+Shift+F5)
- Check CPU, GPU, and memory usage
- Look for red spikes indicating bottlenecks

## Client-Side Optimization

### Reduce Rendering Complexity

**Disable Shadows**
```lua
local Lighting = game:GetService("Lighting")
Lighting.GlobalShadows = false
```

**Lower Graphics Settings**
```lua
-- Force lower render distance
workspace.Terrain.MaxX = 512
workspace.Terrain.MaxY = 512
workspace.Terrain.MaxZ = 512
```

**Hide Distant Objects**
```lua
local players = game:GetService("Players")
local camera = workspace.CurrentCamera

game:GetService("RunService").RenderStepped:Connect(function()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= players.LocalPlayer then
            local distance = (player.Character.HumanoidRootPart.Position - camera.CFrame.Position).Magnitude
            
            -- Hide if far away
            if distance > 200 then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Transparency = 1
                    end
                end
            else
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                    end
                end
            end
        end
    end
end)
```

### Optimize Audio

```lua
local sound = Instance.new("Sound")
sound.Volume = 0.5

-- Only play if not too many sounds
local activeSounds = 0
sound.Ended:Connect(function()
    activeSounds = activeSounds - 1
end)

if activeSounds < 5 then  -- Max 5 simultaneous sounds
    sound:Play()
    activeSounds = activeSounds + 1
else
    print("Too many sounds, skipping")
end
```

## Server-Side Optimization

### Reduce Network Traffic

**Only Send Changed Data**
```lua
local lastState = {}

game:GetService("RunService").Heartbeat:Connect(function()
    local currentState = {
        position = player.Character.HumanoidRootPart.Position,
        health = humanoid.Health
    }
    
    -- Only send if changed
    if currentState.position ~= lastState.position or currentState.health ~= lastState.health then
        playerUpdateEvent:FireAllClients(currentState)
        lastState = currentState
    end
end)
```

**Batch Updates**
```lua
local pendingUpdates = {}
local BATCH_INTERVAL = 0.05

local function queueUpdate(player, data)
    if not pendingUpdates[player] then
        pendingUpdates[player] = {}
    end
    table.insert(pendingUpdates[player], data)
end

game:GetService("RunService").Heartbeat:Connect(function()
    for player, updates in pairs(pendingUpdates) do
        if #updates > 0 then
            batchEvent:FireClient(player, updates)
            pendingUpdates[player] = {}
        end
    end
end)
```

### Optimize Loops

**Efficient Iteration**
```lua
-- INEFFICIENT: Checking every part constantly
game:GetService("RunService").Heartbeat:Connect(function()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Do something
        end
    end
end)

-- EFFICIENT: Cache and update on changes
local parts = {}
workspace.DescendantAdded:Connect(function(instance)
    if instance:IsA("BasePart") then
        table.insert(parts, instance)
    end
end)

workspace.DescendantRemoving:Connect(function(instance)
    for i, part in pairs(parts) do
        if part == instance then
            table.remove(parts, i)
            break
        end
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    for _, part in pairs(parts) do
        -- Do something
    end
end)
```

### Lazy Loading

```lua
-- Don't create everything at start
local models = {}

function loadModel(name)
    if not models[name] then
        models[name] = game.ServerStorage:FindFirstChild(name):Clone()
        models[name].Parent = workspace
    end
    return models[name]
end

-- Only load when needed
if shouldSpawnEnemy then
    loadModel("Enemy")
end
```

## Memory Optimization

### Disconnect Events

```lua
local connection = signal:Connect(callback)

-- When done
connection:Disconnect()
```

**Cleanup on Destroy**
```lua
local object = Instance.new("Part")

local connections = {}

connections.touched = object.Touched:Connect(function()
    print("Touched")
end)

-- When removing
object.Destroying:Connect(function()
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
end)
```

### Reuse Objects

```lua
-- INEFFICIENT: Creates new table every frame
game:GetService("RunService").Heartbeat:Connect(function()
    local newTable = {x = 0, y = 0, z = 0}
    processData(newTable)
end)

-- EFFICIENT: Reuse same table
local dataTable = {x = 0, y = 0, z = 0}

game:GetService("RunService").Heartbeat:Connect(function()
    dataTable.x = 0
    dataTable.y = 0
    dataTable.z = 0
    processData(dataTable)
end)
```

### Destroy Unused Parts

```lua
-- Stop physics on inactive objects
part.CanCollide = false
part.Anchored = true

-- Completely remove when done
part:Destroy()
```

## Pathfinding & AI Optimization

### Spatial Partitioning

```lua
-- Divide world into regions
local CELL_SIZE = 50
local cells = {}

function getCellKey(position)
    local x = math.floor(position.X / CELL_SIZE)
    local z = math.floor(position.Z / CELL_SIZE)
    return x .. "," .. z
end

function addToCell(part)
    local key = getCellKey(part.Position)
    if not cells[key] then
        cells[key] = {}
    end
    table.insert(cells[key], part)
end

function getNearbyCells(position, radius)
    local nearby = {}
    local key = getCellKey(position)
    local cellRadius = math.ceil(radius / CELL_SIZE)
    
    for dx = -cellRadius, cellRadius do
        for dz = -cellRadius, cellRadius do
            local x = tonumber(key:split(",")[1]) + dx
            local z = tonumber(key:split(",")[2]) + dz
            local cellKey = x .. "," .. z
            if cells[cellKey] then
                for _, part in pairs(cells[cellKey]) do
                    table.insert(nearby, part)
                end
            end
        end
    end
    
    return nearby
end
```

## Warzone-Specific Optimizations

### Efficient Enemy AI

```lua
-- Only update nearby enemies
local MAX_ACTIVE_ENEMIES = 10
local enemies = {}

game:GetService("RunService").Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    local playerPos = player.Character.HumanoidRootPart.Position
    
    -- Sort by distance
    table.sort(enemies, function(a, b)
        local distA = (a.Position - playerPos).Magnitude
        local distB = (b.Position - playerPos).Magnitude
        return distA < distB
    end)
    
    -- Only update closest enemies
    for i = 1, math.min(MAX_ACTIVE_ENEMIES, #enemies) do
        updateEnemyAI(enemies[i])
    end
    
    -- Far enemies use simple behavior
    for i = MAX_ACTIVE_ENEMIES + 1, #enemies do
        updateEnemySimple(enemies[i])
    end
end)
```

### Optimized Bullet System

```lua
-- Use object pooling for bullets
local bulletPool = {}
local MAX_BULLETS = 100

function createBullet()
    if #bulletPool > 0 then
        return table.remove(bulletPool)
    end
    
    local bullet = Instance.new("Part")
    bullet.Shape = Enum.PartType.Cylinder
    bullet.CanCollide = false
    return bullet
end

function releaseBullet(bullet)
    bullet.Parent = nil
    table.insert(bulletPool, bullet)
end

-- Use bullets
local bullet = createBullet()
bullet.Parent = workspace
-- ... use bullet ...
releaseBullet(bullet)
```

### LOD (Level of Detail)

```lua
-- Use lower quality models for distant objects
local detailedModel = Instance.new("Model")
local simplifiedModel = Instance.new("Model")

local camera = workspace.CurrentCamera

game:GetService("RunService").RenderStepped:Connect(function()
    for _, model in pairs(workspace.Objects:GetChildren()) do
        local distance = (model.PrimaryPart.Position - camera.CFrame.Position).Magnitude
        
        if distance > 200 then
            -- Use simplified model
            model:Clone().Parent = workspace
        else
            -- Use detailed model
            model.Parent = workspace
        end
    end
end)
```

## Profiling Best Practices

| Metric | Target | Warning |
|--------|--------|---------|
| Frame Time | < 16ms (60 FPS) | > 33ms (30 FPS) |
| Memory | < 512MB | > 1GB |
| Network Traffic | < 1MB/s | > 5MB/s |
| Active Scripts | < 100 | > 500 |

## Quick Optimization Checklist

- ✅ Disconnect unused events
- ✅ Use spatial partitioning for large worlds
- ✅ Batch network updates
- ✅ Only send changed data
- ✅ Cache frequently accessed objects
- ✅ Use object pooling for projectiles
- ✅ Disable shadows if not needed
- ✅ Remove distant/invisible objects
- ✅ Limit simultaneous audio
- ✅ Profile with Microprofiler

---

**For more information:**
- [Optimization Techniques](https://create.roblox.com/docs/tutorials)
- [Performance Benchmarking](https://create.roblox.com/docs)
- [Network Best Practices](https://create.roblox.com/docs/tutorials/scripting/networking)

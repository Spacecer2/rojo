# Roblox Networking Guide

Client-server communication patterns for multiplayer games.

## Architecture Overview

Roblox uses a **client-server model**:
- **Server** authorizes actions, maintains game state
- **Client** displays visuals, handles local input
- **Replication** syncs game state automatically

Security Rule: **Never trust the client**

## RemoteEvent vs RemoteFunction

| Feature | RemoteEvent | RemoteFunction |
|---------|-------------|-----------------|
| Direction | One-way | Two-way |
| Response | No | Yes (waits) |
| Performance | Better | Slower (blocking) |
| Use Case | Fire-and-forget | Requests answers |

## Client to Server Communication

### RemoteEvent (Fire & Forget)
```lua
-- Setup: ReplicatedStorage.Events.PlayerAttack

-- SERVER CODE
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local attackEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerAttack")

attackEvent.OnServerEvent:Connect(function(player, targetId)
    print(player.Name .. " attacked target " .. targetId)
    -- Validate, process, update game state
end)

-- CLIENT CODE
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local attackEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerAttack")

-- Send attack to server
attackEvent:FireServer(targetCharacter.Id)
```

### RemoteFunction (Request Response)
```lua
-- Setup: ReplicatedStorage.Remotes.GetPlayerStats

-- SERVER CODE
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getStatsRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetPlayerStats")

getStatsRemote.OnServerInvoke = function(player, statName)
    -- Look up player's data
    local stats = {health = 100, mana = 50}
    return stats[statName] or 0
end

-- CLIENT CODE
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local getStatsRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetPlayerStats")

-- Request data (blocks until response)
local health = getStatsRemote:InvokeServer("health")
print("Player health:", health)
```

## Server to Client Communication

### Sending Data to Specific Client
```lua
-- SERVER: Send to one client
local attackEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerHit")
attackEvent:FireClient(player, damageAmount, hitPosition)

-- CLIENT: Receive
attackEvent.OnClientEvent:Connect(function(damageAmount, hitPosition)
    print("Hit for " .. damageAmount .. " damage!")
end)
```

### Broadcasting to All Clients
```lua
-- SERVER: Send to all clients
attackEvent:FireAllClients(bulletId, position, velocity)

-- CLIENT: Receive
attackEvent.OnClientEvent:Connect(function(bulletId, position, velocity)
    createBulletVisuals(bulletId, position, velocity)
end)
```

## Optimized Networking Patterns

### Throttled Updates
```lua
-- SERVER: Limit updates to prevent spam
local lastUpdateTime = {}
local UPDATE_INTERVAL = 0.1  -- 100ms

local function sendPlayerUpdate(player, data)
    local currentTime = tick()
    if not lastUpdateTime[player] then
        lastUpdateTime[player] = currentTime
    end
    
    if currentTime - lastUpdateTime[player] >= UPDATE_INTERVAL then
        playerUpdateEvent:FireClient(player, data)
        lastUpdateTime[player] = currentTime
    end
end
```

### Batched Updates
```lua
-- SERVER: Send multiple updates at once
local pendingUpdates = {}
local BATCH_INTERVAL = 0.05

local function queueUpdate(player, updateData)
    if not pendingUpdates[player] then
        pendingUpdates[player] = {}
    end
    table.insert(pendingUpdates[player], updateData)
end

-- Send batches periodically
game:GetService("RunService").Heartbeat:Connect(function()
    for player, updates in pairs(pendingUpdates) do
        if #updates > 0 then
            batchUpdateEvent:FireClient(player, updates)
            pendingUpdates[player] = {}
        end
    end
end)
```

### Unreliable High-Frequency Updates
```lua
-- CLIENT: Send input only when it changes
local lastInput = nil

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local currentInput = {
        forward = input.KeyCode == Enum.KeyCode.W,
        backward = input.KeyCode == Enum.KeyCode.S,
        left = input.KeyCode == Enum.KeyCode.A,
        right = input.KeyCode == Enum.KeyCode.D
    }
    
    if currentInput ~= lastInput then
        moveEvent:FireServer(currentInput)
        lastInput = currentInput
    end
end)
```

## Error Handling & Safety

### Server-side Validation
```lua
-- ALWAYS validate client input
attackEvent.OnServerEvent:Connect(function(player, targetId)
    -- Validate player is alive
    if not isPlayerAlive(player) then
        return
    end
    
    -- Validate target exists and is in range
    local target = workspace:FindFirstChild(targetId)
    if not target then return end
    
    local distance = (player.Character.HumanoidRootPart.Position - target.Position).Magnitude
    if distance > 100 then  -- Max attack range
        return
    end
    
    -- Only now process the attack
    processAttack(player, target)
end)
```

### Debouncing
```lua
local debounce = {}

attackEvent.OnServerEvent:Connect(function(player, targetId)
    -- Prevent spam
    if debounce[player.UserId] then
        return
    end
    
    debounce[player.UserId] = true
    
    -- Process attack
    processAttack(player, targetId)
    
    -- Cooldown
    task.wait(0.5)
    debounce[player.UserId] = nil
end)
```

## Data Serialization

### Complex Data Types
```lua
-- Objects don't serialize well, so convert to simple types

-- SERVER: Send player data
local playerData = {
    id = player.UserId,
    name = player.Name,
    position = {x = char.HRP.Position.X, y = char.HRP.Position.Y, z = char.HRP.Position.Z},
    health = humanoid.Health,
    weapons = {weapon1_id, weapon2_id},
    inventory = {item1 = 5, item2 = 10}
}

playerUpdateEvent:FireClient(player, playerData)

-- CLIENT: Reconstruct
local function deserializePlayer(data)
    return {
        id = data.id,
        name = data.name,
        position = Vector3.new(data.position.x, data.position.y, data.position.z),
        health = data.health
    }
end
```

## For Warzone-Style Games

### Movement Replication
```lua
-- CLIENT: Send movement input frequently
local MovementInput = game:GetService("UserInputService")
local moveEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerMove")

game:GetService("RunService").RenderStepped:Connect(function()
    local direction = Vector3.new(0, 0, 0)
    if MovementInput:IsKeyDown(Enum.KeyCode.W) then direction = direction + workspace.CurrentCamera.CFrame.LookVector end
    if MovementInput:IsKeyDown(Enum.KeyCode.S) then direction = direction - workspace.CurrentCamera.CFrame.LookVector end
    if MovementInput:IsKeyDown(Enum.KeyCode.A) then direction = direction - workspace.CurrentCamera.CFrame.RightVector end
    if MovementInput:IsKeyDown(Enum.KeyCode.D) then direction = direction + workspace.CurrentCamera.CFrame.RightVector end
    
    moveEvent:FireServer(direction.Unit)
end)

-- SERVER: Process movement and replicate to other clients
moveEvent.OnServerEvent:Connect(function(player, direction)
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.Velocity = direction * PLAYER_SPEED
        -- Replicate to other players
        playerMoveReplicateEvent:FireAllClients(player.UserId, humanoidRootPart.Position, direction)
    end
end)
```

### Weapon Firing
```lua
-- CLIENT: Request to fire weapon
local fireEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("FireWeapon")

Mouse.Button1Down:Connect(function()
    local rayStart = Mouse.Hit.Position
    local rayDirection = (Mouse.Hit.Position - workspace.CurrentCamera.CFrame.Position).Unit
    fireEvent:FireServer(rayStart, rayDirection)
end)

-- SERVER: Validate and apply damage
fireEvent.OnServerEvent:Connect(function(player, rayStart, rayDirection)
    -- Validate player is alive and armed
    if not isPlayerAlive(player) then return end
    
    -- Server-side raycast for accuracy
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character}
    
    local result = workspace:Raycast(rayStart, rayDirection * 300, raycastParams)
    
    if result then
        local hitCharacter = result.Instance.Parent
        if hitCharacter:FindFirstChild("Humanoid") then
            hitCharacter.Humanoid:TakeDamage(50)
            -- Notify all clients about the hit
            bulletHitEvent:FireAllClients(result.Position, hitCharacter.Name)
        end
    end
end)

-- CLIENT: Show visual feedback
bulletHitEvent.OnClientEvent:Connect(function(hitPosition, targetName)
    -- Create particle effect at hit position
    createExplosion(hitPosition)
end)
```

## Performance Tips

1. **Minimize network calls** - Batch updates when possible
2. **Use events for fire-and-forget** - Avoid blocking RemoteFunctions in tight loops
3. **Replicate efficiently** - Only send changed data
4. **Server-authoritative** - Trust server calculations for important logic
5. **Client-side prediction** - Show local changes immediately, sync with server
6. **Compression** - Use short names, combine related data
7. **Cooldowns** - Prevent spam with debouncing

---

**For more information:**
- [Network Replication](https://create.roblox.com/docs/tutorials/scripting/networking)
- [Remote Events](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent)
- [Remote Functions](https://create.roblox.com/docs/reference/engine/classes/RemoteFunction)

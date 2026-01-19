# Roblox Physics & Constraints

Physics simulation and constraint systems for advanced mechanics.

## Physics Basics

### Part Properties

```lua
local part = Instance.new("Part")

-- Mass (determines momentum)
part.Size = Vector3.new(2, 2, 2)

-- Friction & Bounce
part.TopSurface = Enum.SurfaceType.Smooth
part.BottomSurface = Enum.SurfaceType.Brick
part.CustomPhysicalProperties = PhysicalProperties.new(
    0.7,    -- Density (kg/m³)
    0.3,    -- Friction coefficient
    0.5     -- Elasticity (bounciness)
)

-- Gravity
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.Velocity = Vector3.new(0, 50, 0)  -- Upward velocity
bodyVelocity.Parent = part
```

### Movement

```lua
local part = Instance.new("Part")

-- Velocity (change per second)
part.Velocity = Vector3.new(0, 0, 20)  -- 20 studs/sec forward

-- Acceleration using BodyVelocity
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
bodyVelocity.Velocity = Vector3.new(10, 20, 0)
bodyVelocity.Parent = part

-- Apply force
local bodyForce = Instance.new("BodyForce")
bodyForce.Force = Vector3.new(100, 0, 0)  -- 100 studs/sec² acceleration
bodyForce.Parent = part
```

## Constraints

Constraints are modern physics joints replacing old methods.

### WeldConstraint (Rigid Connection)

```lua
local part1 = Instance.new("Part")
local part2 = Instance.new("Part")

-- Weld parts together
local weld = Instance.new("WeldConstraint")
weld.Part0 = part1
weld.Part1 = part2
weld.Parent = part1

-- Result: part2 moves with part1 as a single unit
```

### HingeConstraint (Rotating Joint)

```lua
-- Door on hinges
local doorFrame = workspace.DoorFrame
local door = workspace.Door

local hinge = Instance.new("HingeConstraint")
hinge.Attachment0 = doorFrame.Attachment0
hinge.Attachment1 = door.Attachment0
hinge.Parent = doorFrame

-- Control rotation
hinge.AngularVelocity = math.rad(45)  -- Rotate 45°/sec
```

### BallSocketConstraint (Free Rotation)

```lua
-- Swinging pendulum
local anchor = workspace.Anchor
local pendulum = workspace.Pendulum

local socket = Instance.new("BallSocketConstraint")
socket.Attachment0 = anchor.Attachment0
socket.Attachment1 = pendulum.Attachment0
socket.Parent = anchor

-- Pendulum swings freely but stays connected
```

### RodConstraint (Fixed Distance)

```lua
-- Spring-like connection that maintains distance
local spring = Instance.new("RodConstraint")
spring.Attachment0 = part1.Attachment0
spring.Attachment1 = part2.Attachment0
spring.Parent = part1

-- Distance is determined by attachment positions
```

### DistanceConstraint (Spring Joint)

```lua
-- Springy connection
local spring = Instance.new("DistanceConstraint")
spring.Attachment0 = part1.Attachment0
spring.Attachment1 = part2.Attachment0
spring.MaxForce = 1000  -- Spring strength
spring.Parent = part1

-- Parts oscillate around target distance
```

### CylindricalConstraint (Sliding + Rotating)

```lua
-- Piston or sliding door
local piston = Instance.new("CylindricalConstraint")
piston.Attachment0 = base.Attachment0
piston.Attachment1 = rod.Attachment0
piston.Parent = base

-- Rod slides along axis and rotates around it
```

### Rope Constraint (Max Distance)

```lua
-- Rope that pulls parts together but doesn't push
local rope = Instance.new("RopeConstraint")
rope.Attachment0 = anchor.Attachment0
rope.Attachment1 = hanging.Attachment0
rope.Length = 50  -- Max distance
rope.Thickness = 1
rope.Parent = anchor
```

## Attachments

Attachments define where constraints connect.

```lua
local part = Instance.new("Part")

-- Create attachment at part center
local attachment = Instance.new("Attachment")
attachment.Parent = part

-- Position relative to part
attachment.Position = Vector3.new(0, 2, 0)  -- Top of part
attachment.Orientation = Vector3.new(0, 0, 90)  -- Rotated 90°

-- Use in constraint
local constraint = Instance.new("WeldConstraint")
constraint.Attachment0 = part.Attachment
constraint.Attachment1 = otherPart.Attachment
```

## Motor Control

### Motor6D (Advanced Joints)

```lua
-- Used for character animation joints
local motor = Instance.new("Motor6D")
motor.Part0 = character.Torso
motor.Part1 = character["Right Arm"]
motor.Parent = character.Torso

-- Rotate arm
motor.Transform = CFrame.Angles(math.rad(45), 0, 0)
```

### AngularVelocity (Spinning)

```lua
local gyro = Instance.new("BodyGyro")
gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
gyro.Parent = part

-- Make part spin
gyro.CFrame = CFrame.Angles(math.rad(45), math.rad(90), 0)
```

## Raycasting

Find what's in the world along a line.

```lua
local workspace = game:GetService("Workspace")

-- Setup raycast
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {character}

-- Cast ray
local rayOrigin = character.Head.Position
local rayDirection = (targetPosition - rayOrigin).Unit
local result = workspace:Raycast(rayOrigin, rayDirection * 1000)  -- 1000 studs range

if result then
    print("Hit:", result.Instance.Parent.Name)
    print("Position:", result.Position)
    print("Surface normal:", result.Normal)
else
    print("No hit")
end

-- Region3 for area search (deprecated, use Terrain:FillBall instead)
```

## Raycasting for Warzone

```lua
-- Bullet firing
local cannonPart = workspace.Cannon
local bulletSpeed = 500

function fireWeapon(targetPosition)
    local rayOrigin = cannonPart.Position
    local rayDirection = (targetPosition - rayOrigin).Unit
    
    -- Server-side raycast for accuracy
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    raycastParams.FilterDescendantsInstances = {workspace.Enemies}
    
    local result = workspace:Raycast(rayOrigin, rayDirection * 1000, raycastParams)
    
    if result then
        local enemyCharacter = result.Instance.Parent
        print("Hit enemy:", enemyCharacter.Name)
        
        -- Calculate damage based on hit location
        if result.Instance.Name == "Head" then
            enemyCharacter.Humanoid:TakeDamage(100)  -- Headshot
        else
            enemyCharacter.Humanoid:TakeDamage(50)
        end
    end
    
    -- Create visual bullet for all clients
    createBulletTrail(rayOrigin, rayDirection, 1000)
end
```

## Collision Groups

Control which parts collide with each other.

```lua
local PhysicsService = game:GetService("PhysicsService")

-- Create collision group
pcall(function()
    PhysicsService:CreateCollisionGroup("Players")
end)

-- Add parts to group
PhysicsService:CollisionGroupSetCollidable("Players", false)  -- Players don't collide with each other

-- Add player to group
for _, part in pairs(character:GetDescendants()) do
    if part:IsA("BasePart") then
        PhysicsService:CollisionGroupAddMember("Players", part)
    end
end
```

## Advanced Physics Examples

### Character Knockback
```lua
local function applyKnockback(character, direction, force)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.Velocity = humanoidRootPart.Velocity + (direction.Unit * force)
    end
end

applyKnockback(character, (character.HumanoidRootPart.Position - shooterPosition), 50)
```

### Sliding Mechanics
```lua
-- Smooth sliding on slopes
local slidingVelocity = Vector3.new(0, 0, 0)
local SLIDE_ACCELERATION = 50
local SLIDE_FRICTION = 0.1

game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
    if isSliding then
        local slopeDirection = calculateSlopeDirection()
        slidingVelocity = slidingVelocity + (slopeDirection * SLIDE_ACCELERATION * deltaTime)
        slidingVelocity = slidingVelocity * (1 - SLIDE_FRICTION)
        
        character.HumanoidRootPart.Velocity = slidingVelocity
    end
end)
```

### Gravity Control
```lua
-- Zero-G environment
local ZeroGParts = {}

game:GetService("RunService").Heartbeat:Connect(function()
    for _, part in pairs(ZeroGParts) do
        if part.Parent then
            part.AssemblyLinearVelocity = part.AssemblyLinearVelocity * Vector3.new(1, 0.98, 1)  -- Slight damping
        end
    end
end)
```

## Performance Tips

1. **Use Constraints** - More efficient than BodyMover objects
2. **Collision Groups** - Exclude non-colliding parts from physics
3. **Network Optimization** - Only replicate important physics
4. **Use Assembly Linear Velocity** - More efficient than Velocity
5. **Disable Physics** - Set CanCollide = false for non-interactive objects
6. **LOD Physics** - Reduce physics complexity for distant objects

---

**For more information:**
- [Constraints Documentation](https://create.roblox.com/docs/reference/engine/classes)
- [Physics Best Practices](https://create.roblox.com/docs/tutorials)
- [Raycasting Guide](https://create.roblox.com/docs/tutorials/scripting)

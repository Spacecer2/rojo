# Roblox Physics & Constraints: Engineering Realistic Interactions for Warzone

## Introduction & Philosophy

The fidelity of physics simulation is paramount to achieving the authentic "Warzone Feel" in our Roblox recreation. Realistic and predictable physics directly influence player movement (the "heavy but fast" paradox), weapon ballistics (bullet drop, wall penetration), and dynamic environmental interactions. Our philosophy is to:

-   **Prioritize Realism**: Employ Roblox's advanced physics engine to simulate physically plausible movement and interactions, avoiding "floaty" or unrealistic behavior.
-   **Enhance Player Skill**: Ensure physics systems contribute to a high skill ceiling, where mastery of movement and ballistic trajectories is rewarded.
-   **Optimize for Performance**: Strategically utilize constraints, collision groups, and raycasting to deliver complex physical interactions without compromising frame rate or server stability.
-   **Drive Immersion**: Create a tangible sense of weight and impact for characters, weapons, and environmental elements.

This document serves as our technical guide to leveraging Roblox's physics capabilities to build an immersive and competitive experience.

---

## Physics Basics: Understanding the Core Elements

### Part Properties: Defining Physical Characteristics

```lua
local part = Instance.new("Part")
part.BrickColor = BrickColor.new("Dark stone grey")
part.Material = Enum.Material.Concrete
part.Anchored = false -- Unanchored parts are subject to physics

-- Size directly influences mass (default density). Larger parts are heavier.
part.Size = Vector3.new(2, 2, 2)

-- CustomPhysicalProperties allow granular control over how a part interacts physically.
-- This is critical for achieving specific material behaviors (e.g., a "bouncy" tire, a "grippy" floor).
part.CustomPhysicalProperties = PhysicalProperties.new(
    0.7,    -- Density (kg/m³): How heavy the part is for its volume.
    0.3,    -- Friction coefficient: Resistance to sliding (0 = no friction, 1 = high friction).
    0.5,    -- Elasticity (bounciness): How much energy is retained on collision (0 = no bounce, 1 = full bounce).
    0,      -- FrictionWeight (Optional): How friction is weighted across surfaces.
    0       -- ElasticityWeight (Optional): How elasticity is weighted across surfaces.
)

-- Example: Simulating a low-gravity or controlled upward force (generally deprecated, prefer BodyForce/LinearVelocity for modern physics)
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0) -- Allow infinite force on Y-axis
bodyVelocity.Velocity = Vector3.new(0, 50, 0)  -- Applies an upward velocity
bodyVelocity.Parent = part
```

### Movement: Directly Manipulating Physical State

```lua
local part = Instance.new("Part")
part.Anchored = false

-- Direct velocity manipulation: Instantly changes speed and direction.
-- Use with caution, as it can conflict with the physics engine if not managed carefully.
part.AssemblyLinearVelocity = Vector3.new(0, 0, 20)  -- Moves at 20 studs/sec forward (along Z-axis)

-- Applying continuous force (acceleration) using BodyForce.
-- This is a more physically accurate way to exert influence on a part over time.
local bodyForce = Instance.new("BodyForce")
bodyForce.Force = Vector3.new(100, 0, 0)  -- Applies a constant force of 100 Newtons along the X-axis
bodyForce.Parent = part

-- Applying rotational force (torque) using BodyTorque (similar to BodyForce but for rotation).
local bodyTorque = Instance.new("BodyTorque")
bodyTorque.Torque = Vector3.new(0, 100, 0) -- Applies torque around the Y-axis
bodyTorque.Parent = part
```

---

## Constraints: Modern Joints for Complex Mechanical Systems

Constraints are the preferred, modern method for creating robust and performant physical connections and mechanical systems. They are significantly more stable and efficient than older methods like `Motor` objects or manual CFrame manipulation in tight loops.

### WeldConstraint: Rigid, Immutable Connection
Creates a rigid connection between two parts, making them behave as a single assembly. Ideal for static structures or connecting child parts to a main body.

```lua
local part1 = Instance.new("Part")
local part2 = Instance.new("Part")

-- Connect two parts rigidly at their current relative positions
local weld = Instance.new("WeldConstraint")
weld.Part0 = part1
weld.Part1 = part2
weld.Parent = part1 -- Parent to one of the parts for cleanup

-- Result: part2 will maintain its exact position and orientation relative to part1.
```

### HingeConstraint: Controlled Rotational Movement
Allows rotational movement around a single axis, simulating a door, a wheel, or a rotating turret.

```lua
-- Simulate a door swinging on hinges
local doorFrame = workspace.DoorFrame -- An anchored part
local door = workspace.Door           -- An unanchored part

-- Attachments define the pivot points and axes of the hinge.
-- Attachment0 is usually the fixed point, Attachment1 is the moving point.
local hinge = Instance.new("HingeConstraint")
hinge.Attachment0 = doorFrame.Attachment0
hinge.Attachment1 = door.Attachment0
hinge.Parent = doorFrame

-- Control the hinge: Set target angle, motor, or servo.
hinge.AngularVelocity = math.rad(45)  -- Applies constant angular velocity (45 degrees/sec)
hinge.MotorMaxTorque = 1000           -- Strength of the motor
```

### BallSocketConstraint: Free Rotation, Fixed Connection Point
Creates a connection that allows free rotation around a single point, like a shoulder joint, a swinging pendulum, or a loose chain link.

```lua
-- Simulate a swinging pendulum
local anchor = workspace.Anchor     -- An anchored part
local pendulum = workspace.Pendulum -- An unanchored part

-- Attachments define the single point of connection.
local socket = Instance.new("BallSocketConstraint")
socket.Attachment0 = anchor.Attachment0
socket.Attachment1 = pendulum.Attachment0
socket.Parent = anchor

-- The pendulum will swing freely while remaining connected at the socket point.
```

### RodConstraint: Fixed Distance, Flexible Orientation
Maintains a fixed distance between two attachments, but allows them to rotate freely. Useful for suspension systems or keeping objects a set distance apart without rigid connection.

```lua
-- Simulate a simple spring-like connection that maintains a fixed distance
local partA = Instance.new("Part", workspace)
local partB = Instance.new("Part", workspace)

local rod = Instance.new("RodConstraint")
rod.Attachment0 = partA.Attachment0
rod.Attachment1 = partB.Attachment0
rod.Parent = partA

-- The distance between partA and partB will be fixed by the distance between their attachments.
```

### DistanceConstraint: Spring-like Connection
Creates a spring-like connection that oscillates around a target distance. Ideal for suspension, flexible cables, or absorbing impacts.

```lua
-- Create a springy connection, good for suspension systems
local partA = Instance.new("Part", workspace)
local partB = Instance.new("Part", workspace)

local spring = Instance.new("DistanceConstraint")
spring.Attachment0 = partA.Attachment0
spring.Attachment1 = partB.Attachment0
spring.MaxForce = 1000      -- The maximum force the spring can exert
spring.Damping = 0.5        -- How quickly oscillations decay
spring.Restitution = 0.2    -- Bounciness
spring.Parent = partA

-- Parts will oscillate around the target distance defined by their attachments, with damping.
```

### CylindricalConstraint: Sliding and Rotating Joint
Combines linear movement along an axis with rotation around that same axis. Useful for pistons, sliding doors, or rotating shafts.

```lua
-- Simulate a piston or sliding door mechanism
local base = workspace.BasePart     -- Anchored base
local rod = workspace.PistonRod     -- Moving rod

local piston = Instance.new("CylindricalConstraint")
piston.Attachment0 = base.Attachment0
piston.Attachment1 = rod.Attachment0
piston.Parent = base

-- The rod will slide along and rotate around the axis defined by the attachments.
```

### RopeConstraint: Max Distance with Flexibility
A non-rigid connection that prevents parts from exceeding a specified maximum distance, simulating a rope or chain that pulls but does not push.

```lua
-- Simulate a hanging rope or chain that pulls an object.
local anchor = workspace.Anchor     -- Fixed anchor point
local hanging = workspace.HangingPart -- Object to be hung

local rope = Instance.new("RopeConstraint")
rope.Attachment0 = anchor.Attachment0
rope.Attachment1 = hanging.Attachment0
rope.Length = 50                    -- Maximum length of the rope
rope.Thickness = 1                  -- Visual thickness of the rope (can be >0 to be visible)
rope.Parent = anchor

-- The hanging part will stay within 50 studs of the anchor, mimicking a rope.
```

---

## Attachments: Defining Connection Points

Attachments are crucial for precise constraint placement. They define a point and orientation on a part where a constraint connects.

```lua
local part = Instance.new("Part")
part.Size = Vector3.new(4, 1, 4)
part.Parent = workspace

-- Create an attachment at the center of the part (default position)
local attachmentCenter = Instance.new("Attachment")
attachmentCenter.Name = "CenterAttachment"
attachmentCenter.Parent = part

-- Create an attachment at the top of the part, rotated
local attachmentTop = Instance.new("Attachment")
attachmentTop.Name = "TopAttachment"
attachmentTop.Position = Vector3.new(0, part.Size.Y / 2, 0)  -- Position at top surface
attachmentTop.Orientation = Vector3.new(0, 0, 90)           -- Rotate 90 degrees around Z
attachmentTop.Parent = part

-- Attachments are then used by constraints to define their connection points.
local hinge = Instance.new("HingeConstraint")
hinge.Attachment0 = attachmentTop -- Connect this attachment
-- ... connect to another part's attachment ...
```

---

## Motor Control: Precise Rotational Dynamics

### Motor6D: The Backbone of Character Animation
`Motor6D` instances are specialized joints used extensively in character rigging and animation. They allow precise control over rotational relationships between parts.

```lua
-- Typically found within character models, connecting limbs to the torso.
local motor = Instance.new("Motor6D")
motor.Part0 = character.Torso
motor.Part1 = character["Right Arm"]
motor.Parent = character.Torso

-- Control the motor's target orientation using CFrame.
-- This is how animations drive character movement.
motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(45), 0, 0) -- Rotate arm 45 degrees
```

### AngularVelocity: Applying Rotational Forces
The `AngularVelocity` property (or `BodyAngularVelocity` for older methods) allows direct control over a part's rotational speed.

```lua
local part = Instance.new("Part", workspace)
part.Anchored = false
part.Size = Vector3.new(2,2,2)

-- Applying continuous angular velocity using BodyAngularVelocity (deprecated, prefer AngularVelocity property of Part).
-- This forces the part to spin at a certain rate.
local bodyGyro = Instance.new("BodyGyro") -- Often used with BodyAngularVelocity for stability
bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
bodyGyro.Damping = 100
bodyGyro.Parent = part

part.RotationalVelocity = Vector3.new(0, 5, 0) -- Spin around Y-axis at 5 rad/s
```

---

## Raycasting: Precise World Queries for Interaction and Combat

Raycasting is an essential tool for accurate hit detection, line-of-sight checks, and intelligent environmental interactions in a complex 3D world.

```lua
local Workspace = game:GetService("Workspace")

-- Raycast parameters define what the ray interacts with.
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist -- Ignore specific instances
raycastParams.FilterDescendantsInstances = {character}       -- Ignore the player's own character
raycastParams.IgnoreWater = true                             -- Don't hit water

-- Define the ray: origin and direction/length.
local rayOrigin = character.Head.Position
local rayDirection = (targetPosition - rayOrigin).Unit * 1000 -- Ray points from head towards target, 1000 studs long
local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)

if result then
    print("Ray hit:", result.Instance.Name)
    print("Hit position:", result.Position)
    print("Surface normal:", result.Normal)      -- The orientation of the surface hit
    print("Material:", result.Material.Name)     -- The physical material of the surface
else
    print("Ray did not hit anything within range.")
end
```

### Raycasting for Warzone: Accurate Bullet Ballistics

In a high-fidelity FPS like Warzone, raycasting is fundamental for server-authoritative bullet tracing, ensuring accurate hit registration and damage application.

```lua
-- SERVER (Module: CombatService): Authoritative bullet firing logic.
local ServerWorkspace = game:GetService("Workspace")

function CombatService.fireWeapon(player: Player, weaponConfig: any, rayOrigin: Vector3, rayDirection: Vector3)
    -- Server-side validation (ammo, cooldown, etc.) would precede this.

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character} -- Don't hit self
    raycastParams.IgnoreWater = true
    
    local rayLength = weaponConfig.MaxRange or 1000
    local result = ServerWorkspace:Raycast(rayOrigin, rayDirection * rayLength, raycastParams)
    
    if result then
        local hitInstance = result.Instance
        local hitCharacter = hitInstance:FindFirstAncestorWhichIsA("Model") -- Check if hit a character
        
        if hitCharacter and hitCharacter:FindFirstChildOfClass("Humanoid") then
            CombatService.applyDamage(player, hitCharacter.Humanoid, result) -- Custom damage application
            CombatService.replicateHit(result.Position, hitCharacter) -- Notify clients of hit
        else
            CombatService.replicateMiss(result.Position, result.Normal, result.Material) -- Notify clients of miss
        end
    end
end
```

---

## Collision Groups: Fine-Grained Physics Interaction Control

Collision Groups allow precise control over which groups of parts collide with each other, significantly optimizing physics calculations and preventing unintended interactions (e.g., player's bullets not hitting teammates).

```lua
local PhysicsService = game:GetService("PhysicsService")

-- Define custom collision groups (do this once, e.g., on server startup)
pcall(function() PhysicsService:CreateCollisionGroup("Players") end)
pcall(function() PhysicsService:CreateCollisionGroup("PlayerBullets") end)
pcall(function() PhysicsService:CreateCollisionGroup("Environment") end)

-- Set collision rules (e.g., Players don't collide with other Players)
PhysicsService:SetCollisionGroupCollidable("Players", "Players", false)
PhysicsService:SetCollisionGroupCollidable("PlayerBullets", "Players", false) -- Player bullets don't hit their own team
PhysicsService:SetCollisionGroupCollidable("PlayerBullets", "PlayerBullets", false) -- Bullets don't collide with each other
PhysicsService:SetCollisionGroupCollidable("PlayerBullets", "Environment", true) -- Bullets hit environment

-- Assign a part to a collision group
local function assignToCollisionGroup(part: BasePart, groupName: string)
    part.CollisionGroup = groupName
end

-- Example: Assigning character parts to "Players" group
local function setupCharacterCollision(character: Model)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            assignToCollisionGroup(part, "Players")
        end
    end
end
```

---

## Advanced Physics Examples: Custom Mechanics

### Character Knockback: Impactful Feedback
Applying controlled forces to characters to simulate impacts from explosions or melee attacks.

```lua
local function applyKnockback(character: Model, sourcePosition: Vector3, forceMagnitude: number)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local direction = (humanoidRootPart.Position - sourcePosition).Unit -- Direction away from source
        local knockbackVector = direction * forceMagnitude + Vector3.new(0, forceMagnitude / 2, 0) -- Add some upward force
        humanoidRootPart.AssemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity + knockbackVector
    end
end

-- Usage: applyKnockback(targetCharacter, explosionPosition, 75)
```

### Sliding Mechanics: Dynamic Player Movement
Implementing momentum-based sliding, crucial for advanced movement.

```lua
-- CLIENT/SERVER (depending on authority for movement):
local function updateSliding(character: Model, deltaTime: number)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
    local groundNormal = PlayerMovementService.getGroundNormal(character) -- Custom function to get terrain normal
    local slideDirection = (currentVelocity - currentVelocity:Dot(groundNormal) * groundNormal).Unit -- Project velocity onto ground plane

    local slideSpeed = currentVelocity.Magnitude
    local desiredSlideSpeed = math.max(0, slideSpeed - SLIDE_DRAG * deltaTime) -- Apply drag

    humanoidRootPart.AssemblyLinearVelocity = slideDirection * desiredSlideSpeed

    -- Additional logic for slide cancellation, animations, etc.
end
```

### Gravity Control: Environmental Dynamics
Modifying gravity's effect for specific parts or regions, enabling unique gameplay mechanics.

```lua
-- For a specific part, you can manually apply anti-gravity force or override Workspace.Gravity.
local function createZeroGField(zonePart: Part)
    local connections = {}
    connections.touched = zonePart.Touched:Connect(function(otherPart)
        if otherPart.Parent and otherPart.Parent:FindFirstChildOfClass("Humanoid") then
            local rootPart = otherPart.Parent.HumanoidRootPart
            if rootPart then
                -- Apply upward force to simulate zero-G (or set custom PhysicalProperties)
                local bodyForce = Instance.new("BodyForce")
                bodyForce.Force = Vector3.new(0, Workspace.Gravity * rootPart:GetMass(), 0) -- Counteract gravity
                bodyForce.Parent = rootPart
                table.insert(connections, rootPart.AncestryChanged:Connect(function()
                    bodyForce:Destroy() -- Clean up force when part removed
                end))
            end
        end
    end)
    -- Disconnect on zonePart.Destroying for cleanup
end
```

---

## Performance Tips: Optimizing Physics for Scale

1.  **Prefer Constraints over BodyMovers**: Constraints are generally more stable and performant than legacy `BodyMover` objects.
2.  **Utilize Collision Groups**: Define custom collision rules to prevent unnecessary collision checks between groups of parts that should not interact (e.g., character with own bullets).
3.  **Optimize Network Replication of Physics**: Only replicate essential physics data and ensure server authority. Over-replicating physics can quickly saturate network bandwidth.
4.  **Use `AssemblyLinearVelocity` / `AssemblyAngularVelocity`**: Directly setting these properties is often more efficient and predictable than applying continuous forces (like `BodyForce`) for simple movements.
5.  **Anchor Static Objects**: Set `Part.Anchored = true` for any part that should not move or be affected by physics. This tells the engine to ignore them in physics calculations.
6.  **LOD Physics (Level of Detail)**: Reduce physics complexity for distant objects. For instance, less critical physics objects far away might have their `CanCollide` set to `false` or be removed entirely.
7.  **Minimize Part Count**: Reduce the total number of parts, especially unanchored ones. Combine multiple parts into single `MeshParts` where possible.
8.  **Avoid High `Density`**: Extremely dense parts interacting with normal parts can lead to unstable physics. Keep `PhysicalProperties.Density` reasonable.
9.  **Cache Raycast Results**: For repeated queries in a short timeframe, cache and reuse raycast data if the environment is static enough.

---

## Further Reading & Integration: Mastering Roblox Physics

-   **[RobloxDocs/EngineReference.md](EngineReference.md)**: Details other core services that interact with physics (e.g., `RunService`).
-   **[RobloxDocs/Performance_Guide.md](Performance_Guide.md)**: Dive deeper into general optimization strategies, many of which apply directly to physics.
-   **[RobloxDocs/Networking_Guide.md](Networking_Guide.md)**: Essential for understanding how physics-driven interactions are replicated in a multiplayer environment.
-   **[Components/Component_MovementController.md](../../Components/Component_MovementController.md)**: See practical application of physics principles for character movement.
-   **[Features/Combat/WeaponFramework.md](../../Features/Combat/WeaponFramework.md)**: How raycasting and physics are used for weapon ballistics and hit detection.
-   **[Vision.md](../../Vision.md)**: Understand how realistic physics contributes to the "Heavy but Fast" feel and overall immersion.

---
*Last Updated: 2026-01-21*
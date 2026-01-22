# Weapon Framework: Hybrid Hitscan/Projectile System

## Overview
The weapon framework is the foundation of our combat system. It's a unified ballistics system that supports both instant-hit (hitscan) and physics-based projectile weapons, with realistic bullet travel, drop, wall penetration, and material-based damage falloff.

## System Design & Vision

The weapon framework is designed to deliver a "AAA-feel" gunplay experience that is both authentic and responsive. The core principles are:

- **Hybrid Ballistics for the Best of Both Worlds:** We use a hybrid hitscan/projectile system to achieve the perfect balance of realism and playability.
    - **Hitscan for Close-Quarters:** For close-to-medium range combat, we use a hitscan system to ensure that shots feel instant and responsive. This is crucial for a fast-paced shooter.
    - **Projectiles for Long-Range:** For long-range engagements, we switch to a projectile-based system that simulates bullet drop and travel time. This adds a layer of skill and realism to sniping and long-range gunfights.
- **Data-Driven and Extensible:** The entire framework is data-driven, with all weapon properties defined in configuration files. This makes it easy to add new weapons, balance existing ones, and even create entirely new weapon archetypes without having to modify the core code.
- **Seamless Integration:** The weapon framework is designed to be seamlessly integrated with other core systems like the Gunsmith and Visual Recoil. Attachments from the Gunsmith can directly modify weapon properties in the framework, and the framework provides the necessary data to the Visual Recoil system to generate realistic feedback.

## Architecture

### Core Components
1. **WeaponFramework.luau** (Server)
   - Central dispatcher for all weapon firing
   - Ballistics calculation and validation
   - Damage application and networking

2. **ProjectileManager.luau** (Server)
   - Spawns and tracks physical bullets
   - Collision detection and penetration
   - Cleanup and memory management

3. **HitscanHandler.luau** (Server)
   - Raycast-based instant hit detection
   - Penetration surface checks
   - Performance optimization via spatial queries

4. **DamageCalculator.luau** (Shared)
   - Distance-based falloff curves
   - Armor and shield calculations
   - Critical hit multipliers

5. **WeaponClient.luau** (Client)
   - Weapon state management
   - Fire rate control and queuing
   - Recoil/visual feedback application

## Weapon Configuration

```lua
local WeaponConfig = {
    M4 = {
        FireMode = "Auto",
        BallisticType = "Hitscan", -- or "Projectile"
        FireRate = 0.1, -- Seconds between shots
        Damage = {
            Base = 28,
            HeadMultiplier = 2.0,
            LimbMultiplier = 0.75,
            MaxRange = 250,
            MinRange = 5,
            FalloffStart = 20, -- Damage begins dropping
            FalloffEnd = 100 -- Zero damage beyond this
        },
        Recoil = {
            HorizontalSpread = 2,
            VerticalKick = 1.5,
            RecoilPattern = "Manageable"
        },
        Penetration = {
            Enabled = true,
            SurfaceTypes = {"Drywall", "Wood", "Light Metal"},
            DamageReductionPerSurface = 0.3 -- 30% per penetrated surface
        }
    }
}
```

## Firing Pipeline

### Server-Side (Authority)
1. Client sends fire request
2. Server validates player state (not in menu, weapon equipped, ammo available)
3. Determine ballistic type (hitscan vs projectile)
4. Cast ray/spawn projectile
5. Check collisions and penetration
6. Calculate damage and apply to targets
7. Replicate hits to all clients

### Client-Side (Feedback)
1. Queue fire input
2. Apply visual recoil immediately
3. Play muzzle flash effect
4. Send fire request to server
5. Play fire sound
6. Update HUD (ammo counter, heat indicator)

## Hitscan Implementation

```lua
-- RaycastParams setup for penetration
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.IgnoreWater = true

-- Check all surfaces for penetration capability
local hitParts = {}
local penetrateCount = 0
while penetrateCount < MAX_PENETRATION_DEPTH do
    local rayResult = workspace:FindPartBoundInRay(ray, raycastParams)
    if not rayResult then break end
    
    table.insert(hitParts, rayResult.Instance)
    
    if IsPenetrableMateria(rayResult.Instance) then
        penetrateCount += 1
        -- Continue ray from exit point
    else
        break -- Hard stop on non-penetrable surface
    end
end
```

## Projectile Implementation

### Physics-Based Bullets
- Model: Spawned as small spheres with minimal collision
- Velocity: Initial direction + drop over distance
- Collision: OnTouched triggers damage/penetration
- Cleanup: Destroyed after max range or time exceeded

```lua
local projectile = Instance.new("Part")
projectile.Shape = Enum.PartType.Ball
projectile.Size = Vector3.new(0.1, 0.1, 0.1)
projectile.CanCollide = false
projectile.CFrame = muzzlePosition

local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.Velocity = fireDirection * BULLET_SPEED
bodyVelocity.Parent = projectile

projectile.Parent = workspace.Bullets
```

## Penetration System

### Penetrable Materials
- Drywall (80% penetration damage)
- Light wood (70% penetration damage)
- Thin metal sheets (60% penetration damage)
- Glass (90% penetration damage, breaks)

### Non-Penetrable
- Reinforced walls
- Solid metal doors
- Terrain/rock

### Algorithm
1. Cast ray from fire point
2. If hit penetrable surface → continue ray from exit point, reduce damage
3. If hit non-penetrable → stop
4. Apply cumulative damage reduction per surface

## Damage Falloff

```lua
function CalculateFalloff(distance, config)
    local falloff = config.Damage
    
    if distance < falloff.FalloffStart then
        return falloff.Base
    elseif distance > falloff.FalloffEnd then
        return 0
    else
        -- Linear interpolation between start and end
        local ratio = (distance - falloff.FalloffStart) / 
                      (falloff.FalloffEnd - falloff.FalloffStart)
        return falloff.Base * (1 - ratio)
    end
end
```

## Integration Points

### With Gunsmith System
- Barrel length modifies falloff curves
- Muzzle attachments affect velocity
- Optic mounting affects hitscan ray origin

### With HUD
- Ammo count synchronization
- Heat indicator for continuous fire
- Penetration indicator (visual feedback on successful penetration)

### With Sound System
- Fire sound (affected by suppressor)
- Ricochet sound (on hard surfaces)
- Impact sound (body hit vs material)

## Performance Considerations

1. **Raycast Pooling**: Reuse ray objects to avoid allocation
2. **Spatial Queries**: Use raycasts over multiple hit detection
3. **Projectile Cleanup**: Max range limits bullet lifetime
4. **Batch Damage**: Apply multiple hits in single UpdatePlayerHealth call
5. **LOD System**: Disable penetration checks for distant players

## Testing Checklist

- [ ] Hitscan accuracy at various ranges
- [ ] Projectile drop visualization
- [ ] Penetration through drywall
- [ ] Damage falloff curves match design
- [ ] Ricochet behavior on angled surfaces
- [ ] Ammo synchronization client/server
- [ ] Network replication of hit markers

## Future Enhancements

- Tracer rounds for sniper rifles
- Ricochet physics
- Armor plating damage reduction
- Explosive rounds
- Incendiary effects

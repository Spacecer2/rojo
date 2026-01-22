# The Gas System: Circular Hazard with Visual Distortion

## Overview
The gas system is the primary mechanism for controlling the pace and flow of a battle royale match. It's a constantly-contracting circular hazard that forces players into an ever-shrinking playable area, creating tension, strategic decision points, and a climactic endgame.

## System Design & Vision

The gas system is designed to be more than just a simple hazard. It's a core element of the Warzone experience, and its design is guided by the following principles:

- **Pacing and Tension:** The primary function of the gas is to control the pacing of the match. The early-game circles are slow and forgiving, allowing players time to loot and position themselves. As the game progresses, the circles become faster and more damaging, ratcheting up the tension and forcing squads into conflict.
- **Forced Engagement:** By constantly reducing the playable area, the gas system ensures that players are always on the move and cannot simply camp in one location for the entire match. This forces squads to interact with each other, leading to more dynamic and exciting gameplay.
- **Strategic Depth:** The shrinking circle creates a wealth of strategic options. Players must constantly make decisions about when and how to rotate to the next safe zone. Do you move early and risk encountering other rotating squads, or do you play the edge of the gas and pick off players who are forced to move?
- **Narrative Arc:** The gas system gives each match a clear narrative arc. The beginning is a tense scramble for resources. The mid-game is a strategic game of cat and mouse as squads vie for position. The endgame is a chaotic and intense battle for survival in a tiny, final circle.

## Gas Circle Mechanics

### Circle Phases

#### Phase 1 (T=60s, 30-40% Map)
- **Radius**: 400 studs from center
- **Damage**: 1 HP/sec outside
- **Warning**: 15s before contraction
- **Duration**: 4 minutes until next circle
- **Player Impact**: ~100 players remain

#### Phase 2 (T=5min, 15-20% Map)
- **Radius**: 150 studs from center
- **Damage**: 5 HP/sec outside
- **Warning**: 10s before contraction
- **Duration**: 3 minutes
- **Player Impact**: ~60 players remain

#### Phase 3 (T=10min, 5-10% Map)
- **Radius**: 50 studs from center
- **Damage**: 10 HP/sec outside
- **Warning**: 5s before contraction
- **Duration**: 2 minutes
- **Player Impact**: ~25 players remain

#### Phase 4+ (T=12min+, Rapid Mini-Circles)
- **Radius**: 10-20 studs (very small)
- **Damage**: 20 HP/sec outside
- **Warning**: Immediate contraction
- **Duration**: 30-60 seconds each
- **Player Impact**: 5-10 players remain (chaotic, intense)

### Circle Contraction Algorithm

```lua
function ContractCircle(currentPhase)
    local nextCenter = PickRandomPointInRadius(
        currentCenter, 
        minDistanceFromEdge
    )
    
    local contractDuration = PHASE_DURATIONS[currentPhase] * 1000 -- ms
    
    -- Smooth easing function
    local startRadius = PHASE_RADIUS[currentPhase]
    local endRadius = PHASE_RADIUS[currentPhase + 1]
    
    for t = 0, contractDuration, TICK_RATE do
        local progress = t / contractDuration
        local easeProgress = EaseInQuad(progress) -- Accelerate into center
        
        currentRadius = Lerp(startRadius, endRadius, easeProgress)
        currentCenter = Lerp(oldCenter, nextCenter, easeProgress)
        
        ApplyGasDamage() -- Tick damage calculation
    end
end
```

### Randomization
- New circle center chosen randomly within previous phase radius
- Ensures unpredictability and strategy
- Edge players vs center players balanced by luck

## Visual Effects

### Gas Rendering (Client)

#### Visual Boundary
- Colored semi-transparent dome (blue-ish purple)
- Pulsing animation at boundary
- Animated "smoke" texture scrolling inward
- Becomes more opaque as player approaches

#### Screen Effect
- Applies post-processing near edge
- Chromatic aberration (color fringing)
- Vignetting (edges darken)
- Blur intensity increases as player takes damage in gas

#### Distortion Layers
```lua
-- Far from gas: Normal view
-- Medium distance: Slight chromatic aberration
-- Close to gas: Heavy blur + vignette
-- Inside gas: Full distortion, visual chaos

local distanceFromBoundary = Vector3.Distance(player.Pos, gasEdge)
local distortionIntensity = math.max(0, 1 - (distanceFromBoundary / DISTORTION_RANGE))

ApplyChromaticAberration(distortionIntensity * 0.5)
ApplyVignette(distortionIntensity * 0.8)
ApplyBlur(distortionIntensity * 10) -- pixels
```

### Ambient Effects
- Spooky gas loop sound (volume based on proximity)
- Temperature warning indicator (screen temperature gauge)
- Teammate callouts ("Get out of the gas!")

## Damage System

### Damage Calculation
```lua
function CalculateGasDamage(player, deltaTime)
    if IsPlayerInGas(player) then
        local phaseMultiplier = PHASE_DAMAGE[currentPhase]
        local baseDamage = 1 * phaseMultiplier -- Scales with phase
        
        -- Armor reduces gas damage by 50%
        if player.HasArmor then
            baseDamage *= 0.5
        end
        
        -- Perks can reduce gas damage
        local perkReduction = GetPerkGasReduction(player)
        baseDamage *= (1 - perkReduction)
        
        ApplyDamage(player, baseDamage * deltaTime)
    end
end
```

### Damage Tick Rate
- Every 0.1 seconds while in gas
- Stacks quickly (1 damage/sec = 10 HP every second)

### Player Communication
- HUD indicator: "Taking gas damage" warning
- Visual feedback: Screen tint changes color
- Audio: Warning beep accelerates as damage increases

## Circle Prediction & Strategy

### Map Indicators
- **Next Circle Preview**: Shown 30s before contraction
- **Time Remaining**: Countdown timer
- **Path Visualization**: Map shows contraction animation

### Strategic Decision Points
1. **Should I hold current position?**
   - Safe if next circle includes current location
   - Risky if caught in middle of gas rotation

2. **Should I rotate early?**
   - Pro: Better positioning, less gas damage
   - Con: Encounter enemy players rotating same direction

3. **Should I hold gas edge?**
   - Pro: Ambush rotating enemies
   - Con: Take damage if circle moves away

### Pinging System
- Teammates can ping predicted circle
- Ping shows estimated rotation time

## Map Size Considerations

### Small Map (400x400 studs)
- Circles very tight even early game
- Forces combat earlier
- Intense gameplay

### Medium Map (800x800 studs)
- Balanced early/mid/late game pacing
- Good for strategy

### Large Map (1200x1200 studs)
- More looting time early
- Strategic rotations important

## Gas Boundary Edge Cases

### Building Interiors
- Gas passes through buildings
- No safe zones (encourages movement)
- Damage applies regardless of cover

### Water Bodies
- Gas can contract across water
- Swimming slows movement (vulnerability)
- Can be tactical advantage/disadvantage

### Elevation Changes
- Gas follows 2D circular path (ignores height)
- Mountain top inside circle = safe
- Valley outside circle = must climb out

## Network Synchronization

### Circle Data Broadcast
- Server sends circle state every 100ms
- Position (X, Y)
- Radius
- Current phase
- Time until next contraction

### Client Interpolation
```lua
-- Smooth movement between network updates
CircleCenter = Lerp(lastKnownCenter, newCenter, 
                    (tick() - lastUpdateTime) / 0.1)
```

### Prediction
- Client predicts incoming damage
- Server validates and applies actual

## Performance Optimization

### Gas Damage Loop
- Only process players within gas range check
- Use spatial partitioning to cull distant players
- Batch damage updates into single network packet

### Visual Rendering
- LOD system for gas dome at distance
- Disable distortion effects for low-end devices
- Cache circle boundary mesh between frames

## Audio Design

### Gas Ambient Loop
- Deep, ominous tone
- Increases in volume as player approaches
- Frequency shift indicates proximity

### Warning Sounds
- Beep sequence when taking damage
- Tempo increases with damage rate
- Stops when gas healing starts

## Perk/Attachment Integration

### Armor Plating
- Reduces gas damage by 50%
- High-tier armor (legendary) reduces by 60%

### Perks
- "Cold Blooded": Ignore gas damage in protected areas
- "Quartermaster": Move faster through gas (90% speed instead of 50%)

### Contracts in Gas
- "Survive Gas": Win streak (easy cash if done correctly)

## Testing Checklist

- [ ] Circle spawns at correct locations
- [ ] Gas contraction timing matches design
- [ ] Damage application matches phase multipliers
- [ ] Visual distortion activates at correct distances
- [ ] Boundary detection accurate (3D sphere check)
- [ ] Network replication smooth
- [ ] Sound cues at appropriate volumes
- [ ] Armor/perks modify damage correctly
- [ ] Multiple circle phases complete without issues
- [ ] Edge cases handled (building interiors, water)

## Balancing Parameters

All exposed in `GasConfig.luau`:
- Phase durations
- Circle radii
- Damage per phase
- Contraction smoothing
- Distortion intensity
- Visual boundary color

## Future Enhancements

- Animated gas clouds (visual particles)
- Different gas types (toxic, fire, radiation)
- Safe zones with temporary immunity
- Gas escape vehicles
- Gas-based event: "Storm incoming" mode
- Seasonal gas color changes

# Visual Recoil System: Camera Kick & Weapon Vibration

## Overview
The visual recoil system is a critical component of our "AAA-feel" gunplay. It's a multi-layered system that provides visceral, tactile feedback to the player, making every shot feel impactful and rewarding. This is not just a cosmetic effect; it's a core part of the skill-based combat loop.

## System Design & Vision

The design of the visual recoil system is guided by a few key principles:

- **Feedback, Not Just Recoil:** The primary goal of the system is to provide clear and consistent feedback to the player. The camera kick, weapon sway, and haptic feedback all work together to communicate information about the weapon's state, such as its rate of fire, stability, and current recoil level.
- **Skill-Based and Predictable:** While the recoil is designed to be challenging, it is also designed to be predictable and controllable. Skilled players will be able to learn the recoil patterns of their favorite weapons and compensate for them, creating a high skill ceiling that rewards practice and mastery.
- **A Multi-Layered Approach:** To achieve a truly visceral and immersive experience, we use a multi-layered approach to recoil:
    - **Camera Kick:** The foundation of the system, providing the primary sense of impact and force.
    - **Weapon Sway:** A procedural animation layer that adds a sense of weight and momentum to the weapon.
    - **Haptic Feedback:** Controller vibration that provides a direct, tactile connection to the weapon's recoil.
- **Deeply Integrated with Gunsmith:** The visual recoil system is deeply integrated with the Gunsmith system. Every attachment has a tangible effect on the weapon's recoil, allowing players to fine-tune the feel of their weapon to their personal preference.

## Architecture

### Core Components
1. **RecoilController.luau** (Client)
   - Manages recoil animation state machine
   - Applies spring physics to camera
   - Queues recoil patterns

2. **WeaponSway.luau** (Client)
   - Weapon model tilt and sway
   - Attachment-based recoil curves
   - Procedural animations

3. **HapticFeedback.luau** (Client)
   - Vibration intensity mapping
   - Haptic pattern sequences
   - Controller detection

4. **RecoilData.luau** (Shared)
   - Per-weapon recoil patterns
   - Falloff curves over distance
   - Attachment modifier tables

## Recoil Pattern System

### Pattern Definition
```lua
local RecoilPatterns = {
    M4 = {
        Name = "M4 Carbine",
        BaseKick = Vector3.new(0, 2.5, 0), -- Upward bias
        BaseSpread = Vector3.new(1.2, 0.8, 0), -- Horizontal, Vertical
        Controllability = 0.7, -- 0-1, player skill compensation
        
        -- Progressive recoil over burst
        RecoilProgression = {
            {Kick = 2.5, Spread = 1.2}, -- Shot 1
            {Kick = 3.0, Spread = 1.5}, -- Shot 2
            {Kick = 3.2, Spread = 1.8}, -- Shot 3
            {Kick = 3.5, Spread = 2.0}  -- Shot 4+
        },
        
        -- Recovery speed
        RecoveryTime = 0.15, -- Seconds to return to center
        RecoverySpring = 8.0 -- Spring constant
    }
}
```

### Recoil Components
1. **Vertical Kick**: Camera X rotation (upward)
2. **Horizontal Spread**: Camera Z rotation (left/right randomization)
3. **Weapon Tilt**: Weapon model rotates alongside camera
4. **ADS Offset**: Sight picture movement relative to reticle

## Camera Kick Implementation

### Spring Physics
```lua
local springForce = -recoilVelocity * springDamping - 
                    recoilOffset * springStiffness

recoilVelocity += springForce * deltaTime
recoilOffset += recoilVelocity * deltaTime

-- Apply to camera
camera.CFrame = camera.CFrame * 
                CFrame.Angles(math.rad(recoilOffset.X), 0, 0)
```

### Progressive Recoil
Each shot increases recoil intensity:
1. Shot 1: Base recoil (2.5 degrees)
2. Shot 2: +20% (3.0 degrees)
3. Shot 3: +28% (3.2 degrees)
4. Shot 4+: +40% (3.5 degrees) → Stabilizes

### Recovery
After fire ceases:
- Spring-based return to center
- Smooth deceleration over 0.15 seconds
- Overshoot damping prevents oscillation

## Weapon Sway

### Procedural Animation
```lua
local time = tick() * SWAY_FREQUENCY
local swayX = math.sin(time) * swayAmplitude
local swayY = math.cos(time * 0.7) * swayAmplitude

weapon.PrimaryPart.CFrame = weapon.PrimaryPart.CFrame * 
                            CFrame.Angles(swayX, swayY, 0)
```

### During Active Fire
- Sway increases as recoil accumulates
- Weapon tilts to match camera kickback
- Hand twitches simulate muscle tension

### Factors Affecting Sway
- **Fire Rate**: Higher RPM = more frequent disturbance
- **Stability Stat**: Lower = more pronounced sway
- **Grip Type**: Affects sway damping (Angled Grip reduces it)
- **Player Sensitivity**: Higher sens = more jerky movements

## Haptic Feedback (Controller Vibration)

### Vibration Patterns
```lua
local VibrationType = {
    LIGHT_SHOT = {
        Duration = 0.05,
        Intensity = 0.4,
        Pattern = "Single" -- One pulse
    },
    MEDIUM_BURST = {
        Duration = 0.1,
        Intensity = 0.6,
        Pattern = "Pulse" -- Multiple quick pulses
    },
    HEAVY_SUSTAINED = {
        Duration = 0.15,
        Intensity = 0.8,
        Pattern = "Rumble" -- Continuous
    },
    MAGAZINE_EMPTY = {
        Duration = 0.2,
        Intensity = 1.0,
        Pattern = "Alert" -- Double pulse
    }
}
```

### Haptic Mapping
- Handgun: Light vibration (0.4 intensity)
- Assault Rifle: Medium vibration (0.6 intensity)
- Light Machine Gun: Heavy rumble (0.8 intensity)

### Haptic Customization
- Disableable in settings
- Intensity slider (0-100%)
- Pattern preference (Rumble vs Pulse)

## Recoil Compensation

### Player Skill Factor
The "Controllability" stat (0-1) determines how much recoil the player must manually counteract:
- Controllability = 0.9: Minimal compensation needed (AR with Angled Grip)
- Controllability = 0.4: High compensation needed (Sniper without stabilization)

### Mouse/Stick Counter-Aiming
Players can "pull down" on their input to compensate for upward recoil, demonstrating skill and reducing spread:
```lua
-- Adjusted kick based on player input
adjustedKick = baseKick * (1 - playerControlFactor * controllability)
```

## Attachment Impact on Recoil

### Barrel Length
- Longer barrel: ↓ Vertical recoil, ↑ Horizontal spread
- Shorter barrel: ↑ Vertical recoil, ↓ Horizontal spread

### Muzzle Type
- Muzzle Brake: ↑↑ Recoil (poor stability)
- Suppressor: ↓ Recoil, ↑ Handling
- Flash Hider: Balanced trade-offs

### Grip Type
- Angled Grip: ↓↓ Vertical recoil
- Vertical Grip: ↑ Stability, ↓ Hip-fire
- Lightweight Grip: Minimal recoil change

### Stock Type
- Extended Stock: ↓ Recoil
- Collapsed Stock: ↑ Recoil, ↓ Mobility penalty

## Distance-Based Recoil

Recoil intensity scales with distance to target:
```lua
local recoilMultiplier = 1 + (distance / maxRange) * 0.5
-- Close range: 1.0x recoil (full kick)
-- Max range: 1.5x recoil (exaggerated jitter)
```

This helps counteract bullet spread at range while keeping close-range intense.

## ADS vs Hip-Fire

### Aiming Down Sights
- Recoil magnitude: Full intensity
- Direction: Vertical + horizontal spread
- Recovery: Slower spring return

### Hip-Fire
- Recoil magnitude: 60% of ADS
- Direction: More chaotic (wider spread angles)
- Recovery: Faster spring return

## UI Integration

### Crosshair Bloom
- Center reticle grows during fire
- Bloom size matches horizontal spread
- Resets smoothly during recovery

### Hit Marker Feedback
- Visual "tink" on crosshair when hitting target
- Color-coded by damage (red = critical, yellow = normal)
- Coincides with haptic pulse

### On-Screen Indicators
- Current recoil intensity meter (when firing)
- Magazine heat indicator (overheat if sustained fire too long)
- Attachment loadout display

## Animation Curves

### Spring Constant Presets
```lua
local SpringPresets = {
    Responsive = 10, -- Fast return (SMG-like)
    Balanced = 8,    -- Medium return (AR-like)
    Sluggish = 6     -- Slow return (LMG-like)
}
```

### Damping Ratio
- Under-damped: Springy, bouncy (fun, less realistic)
- Critically damped: Smooth, no overshoot (realistic)
- Over-damped: Slow, heavy (weapon feels sluggish)

Current: Critically damped for balance between realism and responsiveness.

## Performance Optimization

1. **Camera Update**: Runs every frame in `RunService.RenderStepped`
2. **Weapon Sway**: Procedural sine waves (no animation playback)
3. **Spring Physics**: Pre-calculated tables for common recoil values
4. **Haptic Fallback**: Disabled on unsupported devices

## Testing Checklist

- [ ] Camera recoil applies smoothly
- [ ] Progressive recoil increases over burst
- [ ] Spring recovery has correct damping
- [ ] Weapon sway correlates with recoil
- [ ] Haptic feedback triggers on fire
- [ ] Attachment modifiers affect recoil patterns
- [ ] ADS vs Hip-fire recoil differs appropriately
- [ ] Recoil controllability improves with skill
- [ ] Crosshair bloom matches recoil spread
- [ ] No camera clipping into geometry

## Tuning Parameters

All values exposed in `RecoilData.luau` for easy balancing:
- Spring stiffness
- Damping ratio
- Recovery time
- Sway frequency/amplitude
- Haptic intensity thresholds

## Future Enhancements

- Advanced recoil patterns (signature curves per weapon)
- Recoil mastery challenges (control full mag with minimal spread)
- Weapon balancing based on recoil feedback data
- Environmental effects (wind causes sway)
- Momentum-based recoil (firing while moving increases it)
- Partial recoil reset on weapon swap

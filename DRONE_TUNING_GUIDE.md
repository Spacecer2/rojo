# Drone Camera Tuning Guide

This guide explains the most important parameters for controlling the drone's behavior. All parameters can be modified in real-time using player attributes.

## Core Behavior Parameters

### Responsiveness & Laziness

**`DroneAmbitionBase`** (Default: 0.55)
- How "eager" the drone is at rest
- Lower = More lazy and drifty (0.3-0.5)
- Higher = More responsive and tight (0.6-1.0)

**`DroneAmbitionScale`** (Default: 1.8)
- How much the drone "wakes up" when stressed
- Lower = Stays lazy even when far away (1.0-1.5)
- Higher = Gets very aggressive when correcting (2.0-3.0)

**`DroneStressSmoothing`** (Default: 0.012)
- How quickly the drone notices it needs to correct
- Lower = Very slow to react, zen-like (0.005-0.01)
- Higher = Quick to notice problems (0.02-0.05)

### Movement Feel

**`DroneLatencySteps`** (Default: 15)
- Reaction delay in frames (~250ms at 60fps)
- Lower = Snappier, more immediate (5-10)
- Higher = More sluggish, delayed (15-25)

**`DroneTopSpeed`** (Default: 40)
- Maximum velocity in studs/second
- Lower = Slower, more cinematic (25-35)
- Higher = Faster, more dynamic (45-60)

**`DroneManualStrength`** (Default: 25)
- How much authority WASD has
- Lower = Gentle nudges (15-20)
- Higher = Strong manual control (30-40)

### Orbital Behavior

**`DroneOrbitSwayAmplitude`** (Default: 0.6 radians)
- How far the drone sways laterally
- Lower = Tighter orbit (0.3-0.5)
- Higher = Wider, more expressive sways (0.7-1.0)

**`DroneOrbitSwayFrequency`** (Default: 0.4 Hz)
- How often the drone sways
- Lower = Slow, graceful (0.2-0.3)
- Higher = Quick, active (0.5-0.7)

### Camera Feel

**`DroneFocusSpringSpeed`** (Default: 1.8)
- How quickly the camera tracks the player
- Lower = Loose, handheld feel (1.0-1.5)
- Higher = Tight, locked feel (2.5-4.0)

**`DroneFocusSpringDamper`** (Default: 0.6)
- Camera stabilization strength
- Lower = More drift and overshoot (0.4-0.5)
- Higher = More stable and direct (0.7-0.9)

## Quick Presets

### Cinematic (Slow & Smooth)
```lua
DroneAmbitionBase = 0.4
DroneStressSmoothing = 0.008
DroneLatencySteps = 20
DroneTopSpeed = 30
```

### Responsive (Quick & Tight)
```lua
DroneAmbitionBase = 0.7
DroneStressSmoothing = 0.03
DroneLatencySteps = 8
DroneTopSpeed = 50
```

### Lazy Drift (Very Relaxed)
```lua
DroneAmbitionBase = 0.35
DroneAmbitionScale = 1.5
DroneStressSmoothing = 0.005
DroneLatencySteps = 25
```

## How to Apply

In Roblox Studio or at runtime:
```lua
player:SetAttribute("DroneAmbitionBase", 0.6)
player:SetAttribute("DroneTopSpeed", 45)
-- etc.
```

Changes take effect immediately on the next frame.

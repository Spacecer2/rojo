# Drone Camera Tuning Guide

## Overview
This guide provides an in-depth explanation of the critical parameters used to control the cinematic "Stalker Drone" camera behavior. These parameters offer granular control over the camera's responsiveness, movement dynamics, and overall aesthetic, enabling fine-tuning to achieve the precise desired "feel."

## Design Philosophy

The exposure of these tuning parameters is a deliberate architectural decision. Our philosophy is to empower developers and designers with direct control over the camera's kinematic behavior without requiring code modifications. This approach is founded on the following principles:

-   **Empirical Tuning**: The "feel" of a cinematic camera is highly subjective and often discovered through iterative experimentation. Providing real-time adjustable parameters facilitates rapid prototyping and empirical validation of camera behaviors.
-   **Decoupling of Logic and Values**: Separating the camera's underlying physics and control logic from its specific tuning values allows for independent iteration by different team members (e.g., engineers on physics, designers on feel).
-   **Expressive Control**: These parameters are designed to translate high-level artistic intent (e.g., "lazy," "responsive," "cinematic") into measurable, adjustable values, providing a direct pipeline from vision to implementation.
-   **Adaptability**: By exposing core behaviors, the camera system can be easily adapted for different scenarios (e.g., subtle menu idle, dynamic spectating, scripted sequences) by simply adjusting attributes, rather than reimplementing logic.

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

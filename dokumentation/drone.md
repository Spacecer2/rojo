# Intelligent Drone Camera Architecture

This document summarizes the "Stalker Drone" camera system, designed to feel intelligent, physical, and cinematic.

## 1. Dual-Brain Architecture
To prevent physics rubberbanding and effector conflicts, the drone operates in two distinct modes:

- **Kinematic Mode (High Intent)**: During active maneuvers (Anticipation/Execution), the drone follows hard-coded mathematical curves. Springs are bypassed but continuously resynced.
- **Dynamic Mode (Organic Idle)**: During passive states (Idle/Settle), the drone uses spring physics for a soft, "living" feel.

## 2. Behavioral State Machine
The drone transitions through four distinct phases:

| Phase | Mode | Description |
| :--- | :--- | :--- |
| **Idle** | Dynamic | Organic hovering with multi-layered noise and independent look-ahead. |
| **Anticipation** | Kinematic | The "Wind-up." A sharp, controlled pull-back in the opposite direction of the move. |
| **Execution** | Kinematic | The "Zip." A high-speed dash following an elliptical "Safety Arch" to clear the character. |
| **Settle** | Dynamic | The "Handover." Springs take back control, fading in decorative jitters over 3 seconds. |

## 3. Core Principles

### Physical Integrity
- **Safety Arch**: During orbits, the drone increases its distance (centrifugal boost) to ensure it flies *around* the character, not *through* them.
- **Banking & Yaw Lead**: The camera rolls into turns and leads with its nose based on its derived velocity, creating a high-speed vehicle feel.
- **Motor Shiver**: A subtle, localized tremor that activates during the Settle phase to simulate motor stabilization.

### Psychological Animation
- **Intentionality**: The drone makes a "decision" to move, signaling its intent via a look-at shift before the physical dash starts.
- **Layered Noise**: Idle swaying is composed of 3+ unsynchronized sine waves (different frequencies) to break rhythmic, robotic patterns.

### Effector Suppression
To maintain clarity during zips:
- **Authority Blending**: Decorative sways, height bobbing, and random jitters are zeroed out during the Execution phase.
- **Settle Alpha**: These effects fade back in linearly over the Settle phase to prevent visual "snapping."

## 4. Implementation Details
- **Spring Resync**: During Kinematic Mode, spring positions and velocities are forced to match the kinematic target every frame.
- **Centering Stability**: Camera focus is locked to a steady intent point during zips, bypassing the swaying look-ahead logic until settled.

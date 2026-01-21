# Component: Movement Controller

## System Design & Vision

The `MovementController` is the heart of our character's physical presence in the world. It's designed to deliver a "AAA-feel" movement system that is both responsive and grounded in realism. The vision is to move beyond the default Roblox character controller and create a system that has a true sense of weight, momentum, and inertia. This is not just about moving the character from point A to point B; it's about making the player feel like they are in control of a real human body, capable of advanced movement techniques like slide-canceling and tactical sprinting.

## 🛠️ Implementation Details
- **Location**: `src/character/MovementController.client.luau`
- **Execution**: Runs on `RunService.Heartbeat` for frame-perfect physics updates, ensuring that player input is translated into movement with minimal latency.

## ⚙️ Core Responsibilities
- **State-Driven Speed Control**: The controller sets the `Humanoid.WalkSpeed` based on the current state from the `StateMachine`. This allows for a wide range of movement speeds, from slow and methodical ADS walking to fast and aggressive tactical sprinting.
- **Dynamic FOV Transitions**: The controller smoothly tweens the camera's `FieldOfView` during ADS transitions, creating a snappy and responsive "tactical" feel.
- **Grounded State Detection**: The controller constantly monitors the character's `FloorMaterial` to accurately determine whether the character is on the ground or in the air, allowing for seamless transitions between different movement states.

## 📐 Speed Table (Example)
| State | Base Speed | Multiplier | Resulting Speed |
|-------|------------|------------|-----------------|
| Walk | 12 | 1.0 | 12 |
| Run | 12 | 1.5 | 18 |
| Sprint | 12 | 2.2 | 26.4 |
| ADS | 12 | 0.6 | 7.2 |

## 🚀 Warzone-Specific Logic
- **ADS Snappiness**: The FOV transition is a key part of the "feel" of our gunplay. It uses a high-speed interpolation to create a snappy and responsive aiming experience that is inspired by *Call of Duty: Modern Warfare (2019)*.
- **A Foundation for Advanced Movement**: The current movement controller is just the beginning. The architecture is designed to be extensible, with plans to add custom acceleration curves, slide-canceling, and other advanced movement mechanics in the future.

---
*Ensures tight, predictable control in all combat scenarios.*

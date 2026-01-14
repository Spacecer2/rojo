# Component: Movement Controller

The **Movement Controller** is the "Physics Engine" of the character. It translates the abstract state from the `StateMachine` into physical movement via the Roblox `Humanoid`.

## 🛠️ Implementation Details
- **Location**: `src/character/MovementController.client.luau`
- **Execution**: Runs on `RunService.Heartbeat` for frame-perfect physics updates.

## ⚙️ Core Responsibilities
- **Speed Management**: Sets `Humanoid.WalkSpeed` based on the current state and multipliers (e.g., ADS speed is a % of base speed).
- **FOV Manipulation**: Smoothly tweens the `Camera.FieldOfView` during ADS transitions using a linear interpolation (Lerp).
- **Grounded Detection**: Monitors `FloorMaterial` to switch between ground and air states.

## 📐 Speed Table (Example)
| State | Base Speed | Multiplier | Resulting Speed |
|-------|------------|------------|-----------------|
| Walk | 12 | 1.0 | 12 |
| Run | 12 | 1.5 | 18 |
| Sprint | 12 | 2.2 | 26.4 |
| ADS | 12 | 0.6 | 7.2 |

## 🚀 Warzone-Specific Logic
- **ADS Snappiness**: The FOV transition uses a high-speed interpolation to feel responsive and "tactical."
- **Movement Weight**: Plans for Phase 3 include custom acceleration curves to prevent the "instant-stop" feel of default Roblox movement.

---
*Ensures tight, predictable control in all combat scenarios.*

# Component: CameraController

## Responsibility
The `CameraController` handles the "Stalker Drone" camera behavior used during the main menu. It provides a cinematic, physics-based camera that follows the player character at a distance while providing smooth sway and movement.

## Features
- **Stalker Drone Movement**: Follows the player character with high-quality spring physics.
- **Sway & Noise**: Periodic motion to simulate a drone hovering.
- **Dynamic Distance**: Camera distance changes slightly to create a "breathing" effect.
- **Look-Ahead**: The camera anticipates character movement to prevent the subject from leaving the frame.
- **Soft Boundaries**: Prevents the camera from clipping into walls or flying too far from the character.
- **NaN/Lag Protection**: Ensures stability during frame rate drops or physics glitches.

## State Management
- **`InMenu` (Attribute)**: The controller listens for this attribute on the LocalPlayer to enable/disable the menu camera.
- **`isFirstFrame`**: Handles the initial "snap" to prevent the camera from flying across the map on load.

## Key Functions
- `Init()`: Sets up the attribute listener.
- `EnableMenuCamera()`: Connects to `RenderStepped` and starts the drone physics loop.
- `DisableMenuCamera()`: Disconnects the loop and returns the camera to `Custom` mode.
- `Start()`: Bootstraps the system if already in the menu.

## Dependencies
- `Shared/Utils/Spring`: High-performance 1D/3D spring solver.
- `RunService`: Used for frame-by-frame updates (`RenderStepped`).

# Component: CameraController

## System Design & Vision

The `CameraController` for the main menu is designed to be more than just a simple static camera. It's a "Stalker Drone," a cinematic, physics-based camera that is designed to create a "wow" factor from the moment the player loads into the game. The vision is to create a camera that feels alive and intelligent, one that dynamically frames the player's character and creates a sense of immersion and anticipation for the match to come. This is a key part of our "AAA-feel" presentation layer.

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

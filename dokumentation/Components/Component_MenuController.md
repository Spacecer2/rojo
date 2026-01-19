# Component: MenuController

## Responsibility
The `MenuController` is the central hub for the main menu experience. It manages the UI lifecycle, view transitions, and global menu state.

## Features
- **UI Management**: Spawns and manages the `WarzoneMenu` ScreenGui.
- **View Switching**: Leverages `ViewManager` to swap between Home, Loadout, and other screens.
- **Local Movement Test**: Provides a bypass to instantly enter a movement testing state.
- **Replication Focus**: Sets the player's `ReplicationFocus` to ensure the menu area stays loaded under StreamingEnabled.
- **Global State**: Manages the `InMenu` attribute and camera modes.

## View Management
- **PLAY**: Home screen with matchmaking and test buttons.
- **WEAPONS**: Character loadout and gunsmith (WIP).
- **OPERATORS**: Operator selection (Placeholder).

## Local Game Flow
1. User clicks **TEST MOVEMENT**.
2. `StartLocalGame()` is called.
3. Menu UI is hidden.
4. Camera is set to `LockFirstPerson`.
5. `InMenu` attribute is set to `false`, activating the standard movement scripts.

## Dependencies
- `ViewManager`: Handles the logic of swapping UI panels.
- `HomeView` / `LoadoutView`: The actual UI layout modules.
- `Network`: Used for communication with matchmaking services.

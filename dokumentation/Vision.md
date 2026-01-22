# Project Vision: The "Warzone Feel" in Roblox

Recreating *Modern Warfare 2019 / Warzone* in Roblox is more than just copying mechanics; it's about capturing a specific **"feel"**—a blend of weight, snappiness, and tactical atmosphere. This document outlines the core tenets of our approach.

---

## 1. The "Heavy but Fast" Paradox
MW 2019 redefined the FPS genre by making characters feel like they have weight without sacrificing responsiveness.
- **Momentum**: Characters shouldn't start and stop instantly. We use interpolation (Lerping) and Springs for `WalkSpeed` transitions.
- **Procedural Motion**: Instead of static animations, we use procedural tilt and camera bobbing that reacts to velocity. If you stop suddenly, the camera should "settle" forward slightly.
- **Weapon Sway**: Weapons aren't glued to the center of the screen. They lag behind camera movement (Sway) and move during breathing/walking.

## 2. Tactical UI & UX
The UI should feel like a high-tech military interface—clean, functional, and immersive.
- **Minimalist Aesthetic**: Dark grays, blues, and sharp accents (Gold/Yellow for rarity).
- **Physicality**: Menus like the "Loadout" screen should feature 3D representations of the gear, making the player feel like they are preparing at a real armory table.
- **Audio Feedback**: Every click, hover, and selection should have a distinct, "mechanical" sound effect.

## 3. Advanced Movement Mechanics
Movement is the skill ceiling in Warzone. Our implementation focuses on:
- **Tactical Sprint**: a higher-speed, limited-duration sprint that raises the weapon.
- **Slide Canceling**: Recreating the iconic (though originally unintended) movement tech through state-machine interrupts.
- **ADS Transitions**: A smooth zoom into the optics that adjusts sensitivity and FOV dynamically.

## 4. Audio-Visual Immersion
- **Spatial Audio**: Footsteps that change based on material and distance, with proper occlusion.
- **Dynamic FOV**: Camera FOV that expands during sprints and narrows during ADS to provide a sense of speed and focus.
- **VFX**: Subtle screen shakes, muzzle flashes that light up the environment, and shell casings that follow physics.

## 5. Technical Philosophy: "Roblox as an Engine"
We treat Roblox as a powerful C++ engine and write our Luau code to be as efficient as possible:
- **State-Driven Logic**: The client predicts the state, the server validates the state, and attributes synchronize it.
- **Decoupled Systems**: The `InputManager` doesn't know about `AnimationController`. They both just talk to the `StateMachine`.
- **Parallelism**: Using `task.spawn` and eventually Actor-based parallelism for heavy calculations like procedural IK.

---
**Vision Statement:** To be the benchmark for FPS movement and feel on the Roblox platform, delivering an unparalleled, authentic Warzone experience through meticulous engineering and visionary design.
---
*Last Updated: 2026-01-21*
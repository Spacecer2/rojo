# Component: Procedural Animator

## System Design & Vision

The `Procedural Animator` is a critical component in achieving a "AAA-feel" visual fidelity for our character and weapon systems. Its vision is to move beyond static, canned animations and to create a dynamic and responsive animation system that reacts in real-time to player input, weapon state, and environmental factors. This component is designed to complement traditional animation by adding layers of subtle, organic motion that make the game world feel more alive and immersive.

## Responsibility
The `Procedural Animator` injects dynamic, context-aware motion into the character and weapon. It works in conjunction with traditional keyframe animations to create a more fluid and believable experience.

## 🛠️ Implementation Details
- **Location**: `src/character/ProceduralAnimator.client.luau`
- **APIs Used**: Custom `Spring` module, `RunService.RenderStepped` for visual smoothness.

## ✨ Current Features
- **Head Look-At**: In the Main Menu, the character's head procedurally tracks the camera using a clamped `Neck.C0` rotation, enhancing character presence.
- **Spring Integration**: All procedural motion is passed through a custom `Spring` class to ensure it has "weight" and "rebound" characteristics (damping and speed), preventing sterile, robotic movement.

## 🔭 Future Features (Warzone Style)
- **Viewmodel Sway**: The weapon model will dynamically lag behind camera movement based on mouse delta, simulating real-world weapon weight and inertia.
- **Weapon Bobbing**: Sinusoidal movement of the weapon while walking or running, scaled by player velocity, enhancing the sense of motion.
- **Procedural Recoil**: Instead of just moving the camera, the weapon itself will procedurally kick back and tilt using Springs, providing more visceral feedback directly from the weapon model.
- **The "Settle" Effect**: A procedural "dip" in the camera and weapon will provide visual feedback of momentum being lost when stopping a sprint or other high-speed movement.

## 🚀 Warzone-Specific Logic
- **Dynamic Realism**: The focus is on subtle visual cues that create immersion, mirroring the high fidelity seen in *Call of Duty: Modern Warfare (2019)*. This includes nuanced weapon movement that communicates weapon weight and player exertion.
- **Integration with Core Systems**: This component will integrate deeply with the `MovementController` and `VisualRecoil` to ensure all procedural animations are synchronized and contribute to a cohesive, high-quality player experience.

---
*Focusing on the subtle visual cues that create immersion and enhance player feedback.*

# Component: Procedural Animator

The **Procedural Animator** provides the "Juice" and "Weight" that distinguishes a high-quality FPS from a standard game. It uses math and physics (Springs) rather than pre-baked animations for secondary motion.

## 🛠️ Implementation Details
- **Location**: `src/character/ProceduralAnimator.client.luau`
- **APIs Used**: Custom `Spring` module, `RunService.RenderStepped` for visual smoothness.

## ✨ Current Features
- **Head Look-At**: In the Main Menu, the character's head procedurally tracks the camera using a clamped `Neck.C0` rotation.
- **Spring Integration**: All procedural motion is passed through a Spring class to ensure it has "weight" and "rebound" (Damper/Speed).

## 🔭 Future Features (Warzone Style)
- **Viewmodel Sway**: The weapon model will lag behind camera movement based on mouse delta.
- **Weapon Bobbing**: Sinusoidal movement of the weapon while walking, scaled by velocity.
- **Procedural Recoil**: Instead of just moving the camera, the weapon itself will kick back and tilt using Springs.

## 🚀 Warzone-Specific Logic
- **The "Settle" Effect**: When stopping a sprint, a procedural "dip" in the camera/weapon provides visual feedback of momentum being lost.

---
*Focusing on the subtle visual cues that create immersion.*

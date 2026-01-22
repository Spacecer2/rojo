# CameraController Critique & Refactoring Roadmap

## Executive Summary

This document provides a critical analysis of the `CameraController`'s "Stalker Drone" implementation. While the three-layer architecture is conceptually sound, there are several key areas where the implementation falls short of its ambitious goals.

The main issues are:
- **Architectural Leaks:** The separation of concerns between the three layers is not strictly enforced, leading to a hidden feedback loop that makes the system difficult to tune and debug.
- **Overloaded and Fragile Systems:** The "Framing Quality" and "Motion Plan" layers are overloaded with responsibilities, making them complex and prone to emergent, unpredictable behavior.
- **Pseudo-Physics:** The physical layer uses a number of "hacks" that break physical correctness and introduce hidden energy damping.

The proposed refactoring steps are designed to address these issues by formalizing the system's architecture, simplifying the core components, and fixing the most egregious "hacks" in the physics layer. The goal is to create a camera system that is more robust, stable, and maintainable, while still delivering the "wow" factor of the original vision.

## 1. Architectural Claims vs Reality

### ✔ What works
* The **three-layer separation is conceptually sound**.
* One-way influence is mostly respected.
* You avoided the classic camera sins: force-driven intent, random impulses, and direct physics hacks.
* Framing quality as a unifying objective is a *good idea*.

### ❌ Where the architecture leaks
Despite the stated one-way design, **semantic intent bleeds into lower layers implicitly**:
* MotionPlanLayer **re-evaluates framing quality** and modifies targets (section 7.5).
* AuthorityWeight is influenced by framing quality → affects physical control gains.
* Manual input affects both *semantic intent* and *trajectory* depending on mode.

**Consequence:**
You’ve built a *three-layer system with a hidden feedback loop*. That makes stability analysis and tuning much harder.

## 2. Framing Quality System – Conceptual Issues

### 2.1 Overloaded Objective Function
`EvaluateFramingQuality` mixes:
* distance optimality
* silhouette readability
* forward motion bias
* vertical composition

These are **not commensurate metrics**, yet they are linearly combined.

**Suggestion:**
Return a structured score:
```lua
{
  distance = ...,
  angle = ...,
  forward = ...,
  height = ...,
  total = ...
}
```
Then let higher layers decide trade-offs explicitly.

### 2.2 Sampling-Based Angle Search
`FindBestFramingAngle` brute-samples orbit angles.
* O(N) cost every impulse.
* No continuity guarantee → potential angle jitter when two nearby angles have similar scores.
* No hysteresis except via smoothing.

**Consequence:**
Under noisy velocity input, the “best” angle may oscillate.

## 3. Intent Layer – Hidden Instability

### 3.1 Impulse Generator Is Not Actually Event-Based
* Impulses are *time-driven*.
* They continuously modify centralAngle and targetDist.
* There is **no clear phase separation** between “decision” and “execution”.
* The system is always *slightly undecided*.

### 3.2 Randomness Still Exists (Just Disguised)
* Random duration
* Random distance variation
* Random overhead escape direction

## 4. Motion Plan Layer – Overloaded Responsibility

This is the most problematic layer.

### 4.1 It Does Too Much
MotionPlanLayer handles:
* prediction
* constraints
* obstacle avoidance
* manual control arbitration
* framing refinement
* error synthesis
* authority scaling
* trajectory generation

**Consequence:**
Any change here risks emergent side effects elsewhere.

### 4.2 Constraint Interference
Constraints are applied sequentially:
1. leash
2. roof
3. min distance
4. obstacle avoidance
5. manual input
6. framing refinement

This order is arbitrary and **non-commutative**.

### 4.3 Predictive Filtering Is Numerically Fragile
Target velocity and acceleration are computed via finite differences of a **moving target**.
* dt jitter amplifies acceleration noise.
* Smoothing factor is dt-dependent but not bounded physically.
* Prediction lead time is fixed, regardless of target dynamics.

## 5. Authority & Error Model – Conceptual Confusion

### 5.1 ErrorMagnitude Is Not an Error
You combine:
* distance error
* current velocity magnitude
* manual input magnitude
* framing error

### 5.2 AuthorityWeight Feedback Loop
Authority affects gains, but authority depends on error, which depends on framing.
**Nonlinear gain feedback loop**: bad framing → higher authority → stiffer system → potentially worse overshoot → worse framing.

## 6. Physical Layer – Pseudo-Physics

### 6.1 Orientation Is Not Physically Consistent
* Orientation is lerped toward thrust direction.
* This is **kinematic orientation**, not physics.

### 6.2 dt Scaling Hack
The dtScale trick breaks physical correctness and introduces hidden energy damping.

## 7. Obstacle Avoidance – Heuristic and Brittle
* Single raycast → no spatial awareness.
* Cache validity depends on arbitrary position deltas.
* Avoidance direction logic is ad-hoc.

## 8. Manual Control Modes – Semantic Ambiguity
The three modes (“bias”, “override”, “assist”) are underspecified. User input interacts differently depending on camera state.

## 9. Maintainability
* Almost no instrumentation.
* Many magic constants.

## High-Level Diagnosis
This is **not overengineered** — it is **under-formalized** for its ambition.
You’re building a *camera agent*, but you’re still tuning it like a *camera script*.

## Proposed Refactoring Steps

1.  **Formalization**: Extract framing quality into a proper module with structured returns.
2.  **Layer Separation**: Remove framing logic from MotionPlanLayer.
3.  **Constraint Refinement**: Order constraints logically and reduce MotionPlanLayer responsibilities.
4.  **Physics Fixes**: Address the `dtScale` hack and consistent orientation.

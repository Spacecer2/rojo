# Roblox Creator Documentation Reference

This document provides a comprehensive summary of key Roblox API services and concepts, suitable for a developer reference.

---

## 1. Humanoid

The `Humanoid` is a specialized object that imbues models with character-like functionality, enabling them to walk, jump, and interact within a Roblox experience. It is always parented to a `Model` and expects a specific assembly of `BasePart` and `Motor6D` objects, with a `HumanoidRootPart` as the root and a `Head` connected to the torso. Roblox supports two primary character rig types: R6 (6-part limbs) and R15 (15-part limbs), each with distinct structural requirements and scaling behaviors.

### Properties

*   **`AutoJumpEnabled`** (`boolean`): Controls whether the character automatically jumps over obstacles on mobile devices.
*   **`AutomaticScalingEnabled`** (`boolean`): If true, the character's size adjusts based on child scale values (e.g., `BodyDepthScale`).
*   **`AutoRotate`** (`boolean`): Determines if the `Humanoid` automatically rotates to face its movement direction.
*   **`CameraOffset`** (`Vector3`): An offset applied to the camera's position relative to the `HumanoidRootPart`.
*   **`Health`** (`number`): The current health of the `Humanoid`, ranging from 0 to `MaxHealth`.
*   **`MaxHealth`** (`number`): The maximum health value for the `Humanoid`.
*   **`WalkSpeed`** (`number`): The maximum movement speed of the `Humanoid` in studs per second.
*   **`Jump`** (`boolean`): If true, the `Humanoid` attempts to jump.
*   **`JumpHeight`** (`number`): Controls the height the `Humanoid` jumps to (used when `UseJumpPower` is false).
*   **`JumpPower`** (`number`): Determines the upward force applied when jumping (used when `UseJumpPower` is true).
*   **`MoveDirection`** (`Vector3`): A read-only `Vector3` indicating the direction the `Humanoid` is currently walking in.
*   **`PlatformStand`** (`boolean`): If true, the `Humanoid` is in a free-falling, unmovable state similar to sitting.
*   **`RigType`** (`Enum.HumanoidRigType`): Specifies whether the `Humanoid` uses an R6 or R15 character rig.
*   **`RootPart`** (`BasePart`): A reference to the `HumanoidRootPart`, the primary part controlling movement.
*   **`SeatPart`** (`BasePart`): A reference to the `Seat` or `VehicleSeat` the `Humanoid` is currently sitting in.
*   **`Sit`** (`boolean`): Indicates whether the `Humanoid` is currently sitting.
*   **`WalkToPart`** (`BasePart`): A reference to a `BasePart` the `Humanoid` is trying to reach via `MoveTo()`.
*   **`WalkToPoint`** (`Vector3`): The 3D position the `Humanoid` is trying to reach via `MoveTo()`.

### Events

*   **`Died()`**: Fires when the `Humanoid`'s `Health` reaches 0.
*   **`HealthChanged(newHealth: number)`**: Fires when the `Humanoid`'s `Health` property changes.
*   **`MoveToFinished(reached: boolean)`**: Fires when the `Humanoid` has reached its destination set by `Humanoid:MoveTo()`.
*   **`Seated(isSitting: boolean, seat: BasePart)`**: Fires when the `Humanoid` sits down in or gets up from a `Seat` or `VehicleSeat`.
*   **`StateChanged(oldState: Enum.HumanoidStateType, newState: Enum.HumanoidStateType)`**: Fires when the `Humanoid`'s state changes.
*   **`Running(speed: number)`**: Fires when the `Humanoid`'s movement speed changes.

### Functions (Methods)

*   **`Humanoid:AddAccessory(accessory: Instance)`**: Attaches the specified `Accessory` to the `Humanoid`'s parent.
*   **`Humanoid:ApplyDescriptionAsync(humanoidDescription: HumanoidDescription, assetTypeVerification: Enum.AssetTypeVerification)`**: Applies a `HumanoidDescription` to change the character's appearance.
*   **`Humanoid:BuildRigFromAttachments()`**: Assembles `Motor6D` joints based on `Attachment` objects in the character, essential for animations.
*   **`Humanoid:ChangeState(state: Enum.HumanoidStateType)`**: Forces the `Humanoid` to enter a specific `Enum.HumanoidStateType`.
*   **`Humanoid:EquipTool(tool: Instance)`**: Makes the `Humanoid` equip the given `Tool`.
*   **`Humanoid:GetAccessories()`**: Returns an array of `Accessory` objects currently worn by the `Humanoid`'s parent.
*   **`Humanoid:GetState()`**: Returns the current `Enum.HumanoidStateType` of the `Humanoid`.
*   **`Humanoid:LoadAnimation(animation: Animation)`**: Loads an `Animation` into the `Humanoid` (deprecated, but still functional).
*   **`Humanoid:Move(moveDirection: Vector3)`**: Moves the `Humanoid` in the specified world-space direction.
*   **`Humanoid:MoveTo(location: Vector3)`**: Commands the `Humanoid` to move to a specific 3D world position.
*   **`Humanoid:TakeDamage(amount: number)`**: Subtracts the specified `amount` from the `Humanoid`'s `Health`.
*   **`Humanoid:UnequipTools()`**: Unequips all `Tool` objects from the `Humanoid`.

---

## 2. ContextActionService

`ContextActionService` is a client-side service used to bind user input to contextual actions. These actions are only active under specific conditions or for a limited time. It is preferred over `UserInputService.InputBegan` for contextual input handling because it manages action priority and unbinding automatically, preventing unintended input conflicts (e.g., a car horn activating while typing in chat). Actions are identified by unique strings.

### Events

*   **`LocalToolEquipped(toolEquipped: Instance)`**: Fires when the local player equips a `Tool`.
*   **`LocalToolUnequipped(toolUnequipped: Instance)`**: Fires when the local player unequips a `Tool`.

### Functions (Methods)

*   **`ContextActionService:BindAction(actionName: string, functionToBind: function, createTouchButton: boolean, ...inputTypes: Enum.KeyCode | Enum.UserInputType)`**: Binds user input (e.g., `Enum.KeyCode.R`, `Enum.UserInputType.MouseButton1`) to an action handling function. If `createTouchButton` is true, an on-screen button is created for touch devices.
    *   **`functionToBind` parameters**: `actionName` (string), `inputState` (`Enum.UserInputState`), `inputObject` (`InputObject`).
*   **`ContextActionService:BindActionAtPriority(actionName: string, functionToBind: function, createTouchButton: boolean, priorityLevel: number, ...inputTypes: Enum.KeyCode | Enum.UserInputType)`**: Similar to `BindAction`, but allows specifying a `priorityLevel` (higher values take precedence) to override the default stack-based priority.
*   **`ContextActionService:GetAllBoundActionInfo()`**: Returns a dictionary containing information about all currently bound actions.
*   **`ContextActionService:GetBoundActionInfo(actionName: string)`**: Returns a dictionary of information for a specific bound action.
*   **`ContextActionService:GetButton(actionName: string)`**: Retrieves the `ImageButton` created for a bound action on touch-enabled devices (if `createTouchButton` was true).
*   **`ContextActionService:SetDescription(actionName: string, description: string)`**: Sets a text description for a bound action.
*   **`ContextActionService:SetImage(actionName: string, image: string)`**: Sets the image for the touch button associated with a bound action.
*   **`ContextActionService:SetPosition(actionName: string, position: UDim2)`**: Sets the position of the touch button for a bound action.
*   **`ContextActionService:SetTitle(actionName: string, title: string)`**: Sets the text title displayed on the touch button for a bound action.
*   **`ContextActionService:UnbindAction(actionName: string)`**: Unbinds an action from its associated inputs, removing its handler from the action stack.
*   **`ContextActionService:UnbindAllActions()`**: Removes all currently bound actions and their associated touch buttons.

---

## 3. UserInputService

`UserInputService` is a client-side service crucial for detecting available input types on a user's device and handling various input events. It enables developers to tailor user experiences based on the input methods (keyboard, mouse, touch, gamepad, VR, accelerometer, gyroscope) a player is using. All its properties, methods, and events are exclusively accessible from client-side scripts.

### Properties

*   **`AccelerometerEnabled`** (`boolean`): True if the device has an accelerometer.
*   **`GamepadEnabled`** (`boolean`): True if a gamepad is available.
*   **`GyroscopeEnabled`** (`boolean`): True if the device has a gyroscope.
*   **`KeyboardEnabled`** (`boolean`): True if a keyboard is available.
*   **`MouseBehavior`** (`Enum.MouseBehavior`): Controls whether the mouse moves freely or is locked (`Default`, `LockCenter`, `LockCurrentPosition`).
*   **`MouseDeltaSensitivity`** (`number`): Scales the delta output of mouse movement.
*   **`MouseEnabled`** (`boolean`): True if a mouse is available.
*   **`MouseIcon`** (`ContentId`): The content ID for the user's mouse icon.
*   **`MouseIconEnabled`** (`boolean`): Determines if the mouse icon is visible.
*   **`OnScreenKeyboardVisible`** (`boolean`): True if an on-screen keyboard is currently visible.
*   **`PreferredInput`** (`Enum.PreferredInput`): Indicates the primary input type a player is likely using (e.g., `Touch`, `Gamepad`, `KeyboardAndMouse`).
*   **`TouchEnabled`** (`boolean`): True if the device has a touch screen.
*   **`VREnabled`** (`boolean`): True if the user is using a virtual reality headset.

### Events

*   **`DeviceAccelerationChanged(acceleration: InputObject)`**: Fires when the device's acceleration changes.
*   **`DeviceGravityChanged(gravity: InputObject)`**: Fires when the device's gravity vector changes.
*   **`DeviceRotationChanged(rotation: InputObject, cframe: CFrame)`**: Fires when the device's rotation changes.
*   **`GamepadConnected(gamepadNum: Enum.UserInputType)`**: Fires when a gamepad connects.
*   **`GamepadDisconnected(gamepadNum: Enum.UserInputType)`**: Fires when a gamepad disconnects.
*   **`InputBegan(input: InputObject, gameProcessedEvent: boolean)`**: Fires when a user starts interacting with an input device.
*   **`InputChanged(input: InputObject, gameProcessedEvent: boolean)`**: Fires when a user changes their interaction with an input device.
*   **`InputEnded(input: InputObject, gameProcessedEvent: boolean)`**: Fires when a user stops interacting with an input device.
*   **`JumpRequest()`**: Fires when the client requests a jump (e.g., pressing spacebar).
*   **`LastInputTypeChanged(lastInputType: Enum.UserInputType)`**: Fires when the client's last input type changes.
*   **`TextBoxFocused(textBox: TextBox)`**: Fires when a `TextBox` gains focus.
*   **`TextBoxFocusReleased(textBox: TextBox)`**: Fires when a `TextBox` loses focus.
*   **`TouchStarted(touch: InputObject, gameProcessedEvent: boolean)`**: Fires when a touch begins on the screen.
*   **`TouchEnded(touch: InputObject, gameProcessedEvent: boolean)`**: Fires when a touch ends on the screen.
*   **`TouchMoved(touch: InputObject, gameProcessedEvent: boolean)`**: Fires when a touch moves on the screen.

### Functions (Methods)

*   **`UserInputService:GamepadSupports(gamepadNum: Enum.UserInputType, gamepadKeyCode: Enum.KeyCode)`**: Checks if a gamepad supports a specific button.
*   **`UserInputService:GetConnectedGamepads()`**: Returns an array of connected gamepad `Enum.UserInputType`s.
*   **`UserInputService:GetDeviceAcceleration()`**: Returns an `InputObject` describing the device's current acceleration.
*   **`UserInputService:GetDeviceGravity()`**: Returns an `InputObject` describing the device's current gravity vector.
*   **`UserInputService:GetDeviceRotation()`**: Returns an `InputObject` and `CFrame` describing the device's current rotation.
*   **`UserInputService:GetFocusedTextBox()`**: Returns the `TextBox` currently focused by the client.
*   **`UserInputService:GetGamepadConnected(gamepadNum: Enum.UserInputType)`**: Checks if a specific gamepad is connected.
*   **`UserInputService:GetKeysPressed()`**: Returns an array of `InputObject`s for currently pressed keys.
*   **`UserInputService:GetLastInputType()`**: Returns the `Enum.UserInputType` of the user's most recent input.
*   **`UserInputService:GetMouseButtonsPressed()`**: Returns an array of `InputObject`s for currently held mouse buttons.
*   **`UserInputService:GetMouseDelta()`**: Returns the change in mouse position (pixels) in the last frame, only if the mouse is locked.
*   **`UserInputService:GetMouseLocation()`**: Returns the current screen location of the mouse in pixels.
*   **`UserInputService:GetStringForKeyCode(keyCode: Enum.KeyCode)`**: Returns a string representing the key a user should press for a given `Enum.KeyCode`, considering keyboard layout.
*   **`UserInputService:IsGamepadButtonDown(gamepadNum: Enum.UserInputType, gamepadKeyCode: Enum.KeyCode)`**: Checks if a specific gamepad button is pressed.
*   **`UserInputService:IsKeyDown(keyCode: Enum.KeyCode)`**: Checks if a specific keyboard key is held down.
*   **`UserInputService:IsMouseButtonPressed(mouseButton: Enum.UserInputType)`**: Checks if a specific mouse button is held down.
*   **`UserInputService:RecenterUserHeadCFrame()`**: Recenters the VR headset's `CFrame` to the user's current orientation.

---

## 4. RunService

`RunService` is a core service responsible for managing runtime activity, time progression, and determining the execution context of scripts. It provides methods to check if code is running on the client, server, or in Studio, which is invaluable for writing robust `ModuleScript`s that adapt to different environments. Additionally, `RunService` offers a suite of events that synchronize code execution with the engine's frame-by-frame loop, allowing for precise control over animations, physics, and rendering updates.

### Properties

*   **`ClientGitHash`** (`string`): A read-only string representing the client's Git hash.
*   **`RunState`** (`Enum.RunState`): Indicates the current run state of the experience (e.g., `Running`, `Paused`).

### Events

*   **`Heartbeat(deltaTime: number)`**: Fires every frame *after* the physics simulation completes. Ideal for general game logic and tasks that don't need to run before physics.
*   **`PostSimulation(deltaTimeSim: number)`**: Fires every frame *after* the physics simulation completes, before `Heartbeat`. Useful for final adjustments to simulation outcomes.
*   **`PreAnimation(deltaTimeSim: number)`**: Fires every frame *before* the physics simulation but *after* rendering. Useful for modifying animation objects.
*   **`PreRender(deltaTimeRender: number)`**: Fires every frame *prior* to the frame being rendered. Use for last-minute visual adjustments. (Supersedes `RenderStepped`).
*   **`PreSimulation(deltaTimeSim: number)`**: Fires every frame *prior* to the physics simulation. Useful for adjusting properties like velocity or forces just before they are applied. (Supersedes `Stepped`).
*   **`RenderStepped(deltaTime: number)`**: (Deprecated) Fires every frame prior to rendering. Use `PreRender` instead.
*   **`Stepped(time: number, deltaTime: number)`**: (Deprecated) Fires every frame prior to physics simulation. Use `PreSimulation` instead.

### Functions (Methods)

*   **`RunService:BindToRenderStep(name: string, priority: number, func: function)`**: Binds a custom function to be called during the `PreRender` step. `priority` determines execution order (lower runs sooner). The function receives `deltaTime`.
*   **`RunService:BindToSimulation(func: function, frequency: Enum.StepFrequency)`**: Binds a function to be called at a fixed frequency, independent of frame rate, for physics-related logic (requires `Workspace.UseFixedSimulation`).
*   **`RunService:GetPredictionStatus(context: Instance)`**: Checks the `Enum.PredictionStatus` of a specific instance.
*   **`RunService:IsClient()`**: Returns `true` if the current environment is running on the client.
*   **`RunService:IsEdit()`**: Returns `true` if the current environment is in Studio's "edit" mode (not running).
*   **`RunService:IsRunMode()`**: Returns `true` if a "Run" playtest (without a player character) has been initiated in Studio.
*   **`RunService:IsRunning()`**: Returns `true` if the experience's simulation is currently running.
*   **`RunService:IsServer()`**: Returns `true` if the current environment is running on the server.
*   **`RunService:IsStudio()`**: Returns `true` if the current environment is running in Roblox Studio.
*   **`RunService:Pause()`**: Pauses the experience's simulation, suspending physics and scripts.
*   **`RunService:Run()`**: Starts or resumes the experience's simulation.
*   **`RunService:SetPredictionMode(context: Instance, mode: Enum.PredictionMode)`**: Sets the prediction mode for an `Instance`.
*   **`RunService:Stop()`**: Stops the experience's simulation.
*   **`RunService:UnbindFromRenderStep(name: string)`**: Unbinds a function previously bound with `BindToRenderStep`.

---

## 5. TweenService

`TweenService` is a powerful service used to create `Tween` objects, which smoothly interpolate (animate) the properties of instances over time. Tweens can be applied to various property types, including numbers, booleans, `CFrame`, `Color3`, `Vector3`, and more. It's important to note that if multiple tweens attempt to modify the same property on an instance, the most recent tween will override and cancel any previous tweens affecting that specific property.

### Functions (Methods)

*   **`TweenService:Create(instance: Instance, tweenInfo: TweenInfo, propertyTable: Dictionary)`**: The primary constructor for creating a `Tween`.
    *   `instance`: The `Instance` whose properties will be tweened.
    *   `tweenInfo`: A `TweenInfo` object defining the tween's duration, easing style, easing direction, repeat count, reversal, and delay.
    *   `propertyTable`: A dictionary where keys are property names (strings) and values are the target values for those properties at the end of the tween.
    *   **Example (Tween Creation)**:
        ```lua
        local TweenService = game:GetService("TweenService")
        local part = Instance.new("Part")
        part.Position = Vector3.new(0, 10, 0)
        part.Color = Color3.new(1, 0, 0)
        part.Anchored = true
        part.Parent = game.Workspace

        local goal = {
            Position = Vector3.new(10, 10, 0),
            Color = Color3.new(0, 1, 0)
        }
        local tweenInfo = TweenInfo.new(5) -- 5 seconds duration
        local tween = TweenService:Create(part, tweenInfo, goal)
        tween:Play()
        ```
    *   **Example (Looping Tween)**:
        ```lua
        local TweenService = game:GetService("TweenService")
        local part = Instance.new("Part")
        part.Position = Vector3.new(0, 10, 0)
        part.Anchored = true
        part.Parent = workspace

        local tweenInfo = TweenInfo.new(
            2, -- Time
            Enum.EasingStyle.Linear, -- EasingStyle
            Enum.EasingDirection.Out, -- EasingDirection
            -1, -- RepeatCount (loops indefinitely)
            true, -- Reverses (plays backward after reaching goal)
            0 -- DelayTime
        )
        local tween = TweenService:Create(part, tweenInfo, { Position = Vector3.new(0, 30, 0) })
        tween:Play()
        task.wait(10)
        tween:Cancel() -- Cancel after 10 seconds
        ```
*   **`TweenService:GetValue(alpha: number, easingStyle: Enum.EasingStyle, easingDirection: Enum.EasingDirection)`**: Calculates an interpolated alpha value (between 0 and 1) based on a given `alpha`, `EasingStyle`, and `EasingDirection`. Useful for custom tweening logic.
*   **`TweenService:SmoothDamp(current: Variant, target: Variant, velocity: Variant, smoothTime: number, maxSpeed: number?, dt: number?)`**: Smoothly interpolates a value towards a target, simulating a critically damped spring. Returns the `newValue` and `newVelocity`. The `newVelocity` must be fed back into the next call for continuous smoothing. Supports `number`, `Vector2`, `Vector3`, and `CFrame`.

---

## 6. Attributes (Instance attributes)

Attributes allow you to store custom data directly on Instances (like Parts, Models, or Folders) without creating ValueObjects (like `IntValue` or `StringValue`). This keeps the hierarchy clean and improves performance. Attributes replicate from server to client (but not vice versa).

### Functions (Methods)

*   **`Instance:GetAttribute(attributeName: string)`**: Returns the value of the attribute, or `nil` if it doesn't exist.
*   **`Instance:SetAttribute(attributeName: string, value: any)`**: Sets the value of an attribute. Setting it to `nil` deletes the attribute. Supported types: string, boolean, number, UDim, UDim2, BrickColor, Color3, Vector2, Vector3, CFrame, NumberSequence, ColorSequence, NumberRange, Rect.
*   **`Instance:GetAttributes()`**: Returns a dictionary of all attributes on the instance.
*   **`Instance:GetAttributeChangedSignal(attributeName: string)`**: Returns a signal (RBXScriptSignal) that fires when the specified attribute changes.
*   **`Instance.AttributeChanged`**: An event that fires when *any* attribute on the instance changes.


---
sidebar_position: 1
---

# Intro

Crunchyroll is a dedicated library for calculating coordinates frames of a rig from an array of animation tracks. You can define a rig by calling `crunchyroll.create_rig`, which is a representation of Roblox Motor6Ds. You can then pass this rig into `crunchyroll.solve_animation`, which also takes animation tracks. These are tables which are similar to Roblox's `AnimationTrack`s. Similar to AnimationTracks, you need an animation "asset". You can load a Roblox animation by calling `crunchyroll.load_keyframe_sequence`. Crunchyroll will then give you the coordinate frames of the "limbs" (think Torso, Head, "Left Leg", UpperTorso etc.), and that's it!

# Why use this?

If you don't intend on using Crunchyroll to write your own animation player:

- No instances! You can calculate how an animation looks at any given time without affecting your game in any way. This means you could implement things like proper ping compensation and secure hit detection (secure headshot detection!)
- Allows for extremely convenient still shots of characters
- Great for characters in viewport frames! Animations

If you do write your own animation player:

- Numerical priorities! No more Action1, Action2, Action3.
- No more :LoadAnimation() or any asset ID management.
- Immediate stops! No more forced 0.05s fade time.
- Very fast and performant :3
- potential for things like easy animation skipping!
- remove the physics from animations, makes it significantly easier to write your own animation replication!

# Future support

Eventually, I may consider making a custom animation format which supports things like sinusoidal easing, additive blending, and other features. I do not know how popular this would be though so I am not sure I will implement these right now.

# Example

```luau
local rig = require(...) -- Path to a Crunchyroll R6 rig
local crunchyroll = require(...) -- Path to Crunchyroll

local crunchyroll_animation = crunchyroll.load_keyframe_sequence(ReplicatedStorage.assets.TestAnimation)

crunchyroll_animation.solve_animation(rig, {
	[crunchyroll_animation] = {
		stop_fade_time = 0.25, -- 0.25 seconds
		start_fade_time = 0.25,

		weight = 1, -- Supports blending!
		priority = 1, -- Supports numerical priorities!

		alpha = 0.5 -- Halfway through the animation
	}
})

-- placed into a result table for optimal performance
local left_arm_cframe = rig.result_coordinate_frames["Left Arm"]
```

# Example with AnimationConstraints or Motor6D

Warning to use this approach on a Character rig. You must do either one of these
- Delete the [`Animator`](https://create.roblox.com/docs/reference/engine/classes/Animator) Instance.
- Keep the [`Animator`](https://create.roblox.com/docs/reference/engine/classes/Animator) Instance and apply the edits within [`RunService.PreSimulation`](https://create.roblox.com/docs/reference/engine/classes/RunService#PreSimulation)



*Most likely the best approach would be to delete the [`Animator`](https://create.roblox.com/docs/reference/engine/classes/Animator) Instance*

The [`Animator`](https://create.roblox.com/docs/reference/engine/classes/Animator) Roblox game engine will overwrite any edits you do before or during [`RunService.PreAnimation`](https://create.roblox.com/docs/reference/engine/classes/RunService#PreAnimation)

otherwise the [`Animator`](https://create.roblox.com/docs/reference/engine/classes/Animator) instance will hold you in neutral pose

```luau
-- during the rig creation ...
local rig = require(...) -- Path to a Crunchyroll R6 rig
local crunchyroll = require(...) -- Path to Crunchyroll

-- link up the Animation Constraints or Motor6D
-- standard r6 setup
-- [Crunchyroll Limb name [`limb.name`]] = AnimationConstraint | Motor6D
local tree: { [string]: AnimationConstraint | Motor6D } = {
    ["Torso"] = character.HumanoidRootPart.RootJoint,
    ["Head"] = character.Torso.Neck,
    ["Left Leg"] = character.Torso["Left Hip"],
    ["Right Leg"] = character.Torso["Right Hip"],
	["Left Arm"] = character.Torso["Left Shoulder"],
    ["Right Arm"] = character.Torso["Right Shoulder"],
}

-- link them up
local constraint_linkage: { [number]: AnimationConstraint | Motor6D } = {}
for limb_name, constraint in tree do
    local pointer = rig.limb_name_to_index[limb_name]
    if pointer == nil then
        error(`limb_name={limb_name} not found`)
    end
    constraint_linkage[pointer] = constraint
end
```
```luau
-- during some render process ...
crunchyroll_animation.solve_animation(rig, {
	... -- insert animations
})

for index, animation_constraint in constraint_linkage do
	local transform = rig.limb_transforms[index]

    local position = transform.position
	local quat_vector = transform.quat_vector
	local quat_scalar = transform.quat_scalar

    animation_constraint.Transform = CFrame.new(
		position.x,
		position.y,
		position.z,
		quat_vector.x,
		quat_vector.y,
		quat_vector.z,
		quat_scalar
	)
end
```

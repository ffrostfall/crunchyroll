local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local crunchyroll = require(ReplicatedStorage.crunchyroll)
local rig_template = require("./rig") :: any

local TEST_TRANSFORM = CFrame.new(10, 0, -0) * CFrame.fromEulerAnglesYXZ(0, math.rad(90), 0)

local character_template = ReplicatedStorage.assets.character
local character_joints_template = ReplicatedStorage.assets.character_motor6d

local character_index = 0
local function spawn_character()
	character_index += 1
	local spawned_rig = character_template:Clone()

	for _, child in spawned_rig:GetChildren() do
		if child:IsA("BasePart") then
			child.Anchored = true
		end
	end

	spawned_rig:PivotTo(CFrame.new(0, 0, 5 * character_index) * TEST_TRANSFORM)

	-- strict datamodel types, lol.
	spawned_rig.Parent = workspace :: any

	return spawned_rig
end
local function spawn_motor_character(derived)
	local spawned_rig = character_joints_template:Clone()

	spawned_rig.Torso.Color = Color3.new(0, 1, 0)
	spawned_rig:PivotTo(CFrame.new(0, 6, 0) * derived:GetPivot())

	-- strict datamodel types, lol.
	spawned_rig.Parent = workspace :: any

	return spawned_rig
end

local function preview_roblox(rig, keyframe_sequence)
	local spawned_rig = character_joints_template:Clone()
	spawned_rig:PivotTo(CFrame.new(0, 6, 0) * rig:GetPivot())

	spawned_rig.Parent = workspace :: any

	local animator = spawned_rig.Humanoid.Animator
	local animation = Instance.new("Animation")
	animation.AnimationId = KeyframeSequenceProvider:RegisterKeyframeSequence(keyframe_sequence)

	local track = animator:LoadAnimation(animation)

	track:Play()
end

local function apply_cframe(character, rig)
	character["Left Arm"].CFrame = rig.result_coordinate_frames["Left Arm"]
	character["Right Arm"].CFrame = rig.result_coordinate_frames["Right Arm"]

	character["Left Leg"].CFrame = rig.result_coordinate_frames["Left Leg"]
	character["Right Leg"].CFrame = rig.result_coordinate_frames["Right Leg"]

	character["Torso"].CFrame = rig.result_coordinate_frames["Torso"]
	character["Head"].CFrame = rig.result_coordinate_frames["Head"]

	local joint = character:FindFirstChild("ExtraJoint")
	if joint then
		joint.CFrame = rig.result_coordinate_frames["ExtraJoint"]
	end
end

-- one keyframe
do
	local character = spawn_character()
	local rig = crunchyroll.create_rig(rig_template)
	local single_keyframe_animation = crunchyroll.load_keyframe_sequence(
		ReplicatedStorage.assets.single_keyframe_animation,
		rig
	)

	crunchyroll.solve_animation(rig, {
		[single_keyframe_animation] = {
			priority = 1,

			start_fade_time = 0,
			stop_fade_time = 0,
			weight = 1,
			alpha = 0,
		},
	}, character.HumanoidRootPart.CFrame)

	apply_cframe(character, rig)
end

-- looped animations
for _, keyframe_sequence in
	{
		ReplicatedStorage.assets.walk,
		ReplicatedStorage.assets.animation_with_holes,
		ReplicatedStorage.assets.wave_5_step,
		ReplicatedStorage.assets.lift_left_arm,
		ReplicatedStorage.assets.joint_animation,
	}
do
	local character = spawn_character()
	local motor_6dcharacter = spawn_motor_character(character)
	preview_roblox(motor_6dcharacter, keyframe_sequence)

	local rig = crunchyroll.create_rig(rig_template)
	local animation = crunchyroll.load_keyframe_sequence(keyframe_sequence, rig)

	local joint_lookup = {
		["ExtraJoint"] = motor_6dcharacter.HumanoidRootPart.ExtraJoint,
		["Head"] = motor_6dcharacter.Torso.Neck,
		["Right Arm"] = motor_6dcharacter.Torso["Right Shoulder"],
		["Left Arm"] = motor_6dcharacter.Torso["Left Shoulder"],
		["Right Leg"] = motor_6dcharacter.Torso["Right Hip"],
		["Left Leg"] = motor_6dcharacter.Torso["Left Hip"],
		["Torso"] = motor_6dcharacter.HumanoidRootPart.RootJoint,
	}

	local alpha = 0

	RunService.RenderStepped:Connect(function(delta_time)
		-- loop the animation
		alpha += delta_time / animation.length
		alpha %= 1

		-- HumanoidRootPart.CFrame for the root CFrame
		crunchyroll.solve_animation(rig, {
			[animation] = {
				priority = 1,

				start_fade_time = 0,
				stop_fade_time = 0,
				weight = 1,

				alpha = alpha,
			},
		}, character.HumanoidRootPart.CFrame)

		apply_cframe(character, rig)

		for index, joint in rig.limbs do
			local limb_transform = rig.limb_transforms[index]

			local position = limb_transform.position
			local quat_vector = limb_transform.quat_vector
			local quat_scalar = limb_transform.quat_scalar

			local transform = CFrame.new(
				position.x,
				position.y,
				position.z,
				quat_vector.x,
				quat_vector.y,
				quat_vector.z,
				quat_scalar
			)

			if joint_lookup[joint.name] then
				joint_lookup[joint.name].Transform = transform
			end
		end
	end)
end

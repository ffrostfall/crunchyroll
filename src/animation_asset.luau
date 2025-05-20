local roblox_easings = require("./roblox_easings")

export type PoseNode = {
	easing_direction: Enum.PoseEasingDirection,
	easing_style: Enum.PoseEasingStyle,

	easing_function: (alpha: number) -> number,

	coordinate_frame: CFrame,

	name: string,
	time: number,
}

export type KeyframeNode = {
	time: number,

	poses: { [string]: PoseNode },
}

export type Identity = {
	keyframes: { KeyframeNode },
	markers: { [string]: number },

	length: number,
	priority: Enum.AnimationPriority,
	looping: boolean,
}

local function recursive_tree_from_pose(keyframe: Keyframe, poses: { [string]: PoseNode }, root_pose: Pose): ()
	local sub_poses = (root_pose:GetSubPoses() :: any) :: { Pose }

	for _, sub_pose in sub_poses do
		recursive_tree_from_pose(keyframe, poses, sub_pose)
	end

	poses[root_pose.Name] = {
		easing_direction = root_pose.EasingDirection,
		easing_style = root_pose.EasingStyle,

		coordinate_frame = root_pose.CFrame,

		easing_function = roblox_easings[root_pose.EasingStyle][root_pose.EasingDirection],

		name = root_pose.Name,
		time = if keyframe then keyframe.Time else 0.5,
	}
end

local animation_asset = {}

function animation_asset.load_keyframe_sequence(keyframe_sequence: KeyframeSequence): Identity
	local keyframes = (keyframe_sequence:GetKeyframes() :: any) :: { Keyframe }
	local keyframe_nodes: { KeyframeNode } = {}
	local markers = {}

	for keyframe_index, keyframe in keyframes do
		for _, marker in (keyframe:GetMarkers() :: any) :: { KeyframeMarker } do
			markers[marker.Name] = keyframe_index
		end

		local poses: { [string]: PoseNode } = {}
		for _, pose_instance in keyframe:GetPoses() do
			recursive_tree_from_pose(keyframe, poses, pose_instance :: Pose)
		end

		table.insert(keyframe_nodes, {
			time = keyframe.Time,
			poses = poses,
		})
	end

	table.sort(keyframe_nodes, function(left: KeyframeNode, right: KeyframeNode): boolean
		return left.time < right.time
	end)

	local top = keyframe_nodes[#keyframe_nodes]

	return {
		keyframes = keyframe_nodes,

		length = top.time,
		priority = keyframe_sequence.Priority,
		looping = keyframe_sequence.Loop,
		markers = markers,
	}
end

return animation_asset

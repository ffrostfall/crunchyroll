local easing_enum_map = require("./easing_enum_map")

export type PoseNode = {
	easing_direction: Enum.PoseEasingDirection,
	easing_style: Enum.PoseEasingStyle,

	easing_function: (alpha: number) -> number,

	position: vector,
	--- xyz components of a unit quaternion
	quat_vector: vector,
	quat_scalar: number,

	name: string,
	time: number,
}

export type KeyframeNode = {
	time: number,

	poses: { [string]: PoseNode },
}

export type Identity = {
	keyframes: { KeyframeNode },
	length: number,
}

local function recursive_tree_from_pose(
	keyframe: Keyframe,
	poses: { [string]: PoseNode },
	root_pose: Pose
)
	local sub_poses = root_pose:GetSubPoses() :: { Pose }

	for _, sub_pose in sub_poses do
		recursive_tree_from_pose(keyframe, poses, sub_pose)
	end

	local cframe = root_pose.CFrame
	local axis, angle = cframe:ToAxisAngle()

	local half_angle = angle / 2
	local position = cframe.Position
	local quat_vector = axis * math.sin(half_angle)
	local quat_scalar = math.cos(half_angle)

	poses[root_pose.Name] = {
		easing_direction = root_pose.EasingDirection,
		easing_style = root_pose.EasingStyle,

		position = position,
		quat_vector = quat_vector,
		quat_scalar = quat_scalar,

		easing_function = easing_enum_map[root_pose.EasingStyle][root_pose.EasingDirection],

		name = root_pose.Name,
		time = if keyframe then keyframe.Time else 0.5,
	}
end

local animation_asset = {}

function animation_asset.load_keyframe_sequence(keyframe_sequence: KeyframeSequence): Identity
	local keyframes = keyframe_sequence:GetKeyframes() :: { Keyframe }
	local keyframe_nodes: { KeyframeNode } = {}
	local markers = {}

	for keyframe_index, keyframe in keyframes do
		for _, marker in keyframe:GetMarkers() :: { KeyframeMarker } do
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

	table.sort(keyframe_nodes, function(left, right)
		return left.time < right.time
	end)

	local top = keyframe_nodes[#keyframe_nodes]

	return {
		keyframes = keyframe_nodes,

		length = top.time,
	}
end

return animation_asset

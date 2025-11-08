local easing = require("../easings")
local easing_enum_map = require("./easing_enum_map")
local rig = require("../rig")

export type PoseNode = {
	position: vector,
	quat_vector: vector,
	quat_scalar: number,
	easing_function: (alpha: number) -> number,
}

--- [1] = previous keyframe index
--- [2] = next keyframe index
export type KeyframeHole = { number }
export type Poses = { PoseNode }

type KeyframeNode = {
	time: number,
	poses: { [string]: PoseNode },
}

export type Identity = {
	keyframe_times: { number },
	keyframe_poses: { Poses },
	keyframe_holes: { [number]: { KeyframeHole } },
	length: number,
}

local function recursive_tree_from_pose(poses: { [string]: PoseNode }, root_pose: Pose)
	local sub_poses = root_pose:GetSubPoses() :: { Pose }

	for _, sub_pose in sub_poses do
		recursive_tree_from_pose(poses, sub_pose)
	end

	-- example, a keyframe that is deeply nested. but ancestor(s) is not animated, roblox will indicate this with .Weight == 0
	if root_pose.Weight == 0 then
		return
	end

	local cframe = root_pose.CFrame
	local axis, angle = cframe:ToAxisAngle()

	local half_angle = angle / 2
	local position = cframe.Position :: any
	local quat_vector = axis * math.sin(half_angle) :: any
	local quat_scalar = math.cos(half_angle)

	-- TODO weird type error
	poses[root_pose.Name] = {
		position = position,
		quat_vector = quat_vector,
		quat_scalar = quat_scalar,
		easing_function = easing_enum_map[root_pose.EasingStyle][root_pose.EasingDirection],
	}
end

local animation_asset = {}

function animation_asset.load_keyframe_sequence(
	keyframe_sequence: KeyframeSequence,
	rig: rig.Identity
): Identity
	local keyframes = keyframe_sequence:GetKeyframes() :: { Keyframe }

	local markers = {}
	local keyframe_nodes: { KeyframeNode } = {}

	for keyframe_index, keyframe in keyframes do
		for _, marker in keyframe:GetMarkers() :: { KeyframeMarker } do
			markers[marker.Name] = keyframe_index
		end

		local poses: { [string]: PoseNode } = {}
		for _, pose_instance in keyframe:GetPoses() do
			recursive_tree_from_pose(poses, pose_instance :: Pose)
		end

		table.insert(keyframe_nodes, {
			time = keyframe.Time,
			poses = poses,
		})
	end

	table.sort(keyframe_nodes, function(left: KeyframeNode, right: KeyframeNode)
		return left.time < right.time
	end)

	local limb_name_to_index = rig.limb_name_to_index
	local keframe_holes: { [number]: { KeyframeHole } } = {}

	-- previous keyframe that had no holes, [limb_index]: keyframe_node_index
	local no_holes: { [number]: number } = {}
	local future_right: { [number]: true | nil } = {}

	for index, node in keyframe_nodes do
		for limb_name, limb_index in limb_name_to_index do
			-- if we are the first keyframe, we should fill in the default pose
			if index == 1 and node.poses[limb_name] == nil then
				node.poses[limb_name] = {
					position = vector.zero,
					quat_vector = vector.zero,
					quat_scalar = 1,
					easing_function = easing.linear,
				}
			end

			if node.poses[limb_name] then
				no_holes[limb_index] = index
				future_right[limb_index] = nil
			elseif not node.poses[limb_name] and future_right[limb_index] == nil then
				-- there's a holes, find the left and right keyframes and fill the indexes between
				-- left should always be avaliable

				local left_pointer = no_holes[limb_index]
				assert(left_pointer, "there should always be a left pointer keyframe")

				local right_pointer
				for right_pose_counter = index + 1, #keyframe_nodes do
					if keyframe_nodes[right_pose_counter].poses[limb_name] then
						right_pointer = right_pose_counter
						break
					end
				end
				future_right[limb_index] = true

				-- if this is nil, the limb does not have any future keyframes
				if right_pointer then
					local hole = {
						left_pointer,
						right_pointer,
					}

					local limb_holes = keframe_holes[limb_index]
					if limb_holes == nil then
						limb_holes = {}
						keframe_holes[limb_index] = limb_holes
					end

					for fill_in = left_pointer + 1, right_pointer do
						limb_holes[fill_in] = hole
					end
				end
			end
		end
	end

	local length = keyframe_nodes[#keyframe_nodes].time
	local keyframe_times = {}
	local keyframe_poses = {}

	for index, keyframe_node in keyframe_nodes do
		local mapped_poses: Poses = {}
		for name, pose in keyframe_node.poses do
			local limb_index = limb_name_to_index[name]
			if limb_index ~= nil then
				mapped_poses[limb_index] = pose
			end
		end

		keyframe_poses[index] = mapped_poses
		keyframe_times[index] = keyframe_node.time
	end

	return {
		keyframe_times = keyframe_times,
		keyframe_poses = keyframe_poses,
		length = length,
		keyframe_holes = keframe_holes,
	}
end

return animation_asset

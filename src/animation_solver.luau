--!optimize 2

local animation_asset = require("./roblox/animation_asset")
local create_rig = require("./rig")

export type AnimationTrack = {
	-- 0-1
	alpha: number,

	-- 0-1
	start_fade_time: number,
	stop_fade_time: number,
	weight: number,

	-- arbitrary number
	priority: number,
}

local function vector_lerp(a: vector, b: vector, t: number): vector
	return a + (b - a) * t
end

local function quat_nlerp(a_vector: vector, a_scalar: number, b_vector: vector, b_scalar, t: number)
	local quat_vector = vector_lerp(a_vector, b_vector, t)
	local quat_scalar = math.lerp(a_scalar, b_scalar, t)

	--stylua: ignore
	local magnitude = math.sqrt(quat_vector.X^2 + quat_vector.Y^2 + quat_vector.Z^2 + quat_scalar^2)
	return quat_vector / magnitude, quat_scalar / magnitude
end

local function solve_fade_time_influence(
	real_time: number,
	animation_length: number,
	start_fade_time: number,
	stop_fade_time: number
): number
	if real_time <= start_fade_time then
		return math.min(1 - ((start_fade_time - real_time) / start_fade_time), 1)
	elseif real_time >= (animation_length + stop_fade_time) then
		return math.min(
			1 - ((real_time - (animation_length - stop_fade_time)) / stop_fade_time),
			1
		)
	else
		return 1
	end
end

local function animation_solver(
	rig: create_rig.Identity,
	tracks: {
		[animation_asset.Identity]: AnimationTrack,
	},
	root: CFrame
)
	local limb_array: { create_rig.Limb }, result_coordinate_frames: { [string]: CFrame }, total_weight: number =
		rig._topologically_sorted_limbs, rig.result_coordinate_frames, 0
	for _, limb in limb_array do
		limb.priority = -1
	end

	for _, track in tracks do
		total_weight += track.weight
	end

	for animation, playback in tracks do
		local real_time: number, priority: number =
			animation.length * playback.alpha, playback.priority
		local influence: number = (playback.weight / total_weight)
			* solve_fade_time_influence(
				real_time,
				animation.length,
				playback.start_fade_time,
				playback.stop_fade_time
			)

		-- Figure out which keyframes to interpolate between
		local keyframe_after: animation_asset.KeyframeNode?
		local keyframe_before: animation_asset.KeyframeNode?

		for index, keyframe in animation.keyframes do
			if keyframe.time >= real_time then
				keyframe_after = keyframe
				keyframe_before = animation.keyframes[index - 1]
				break
			end
		end

		-- Solve limb transforms
		for _, node in limb_array do
			if node.priority > priority then
				continue
			end

			local left_pose: animation_asset.PoseNode?, right_pose: animation_asset.PoseNode? =
				keyframe_before and keyframe_before.poses[node.name],
				keyframe_after and keyframe_after.poses[node.name]
			local left_or_right = left_pose or right_pose

			--stylua: ignore start
			if left_pose and right_pose then
				local alpha = left_pose.easing_function((real_time - left_pose.time) / (right_pose.time - left_pose.time))
				local position = vector_lerp(left_pose.position, right_pose.position, alpha)
				local quat_vector, quat_scalar = quat_nlerp(
					left_pose.quat_vector, left_pose.quat_scalar, 
					right_pose.quat_vector, right_pose.quat_scalar, 
					alpha
				)

				node.position = vector_lerp(node.position, position, influence)
				node.quat_vector, node.quat_scalar = quat_nlerp(
					node.quat_vector, node.quat_scalar, 
					quat_vector, quat_scalar, 
					influence
				)
				node.priority = priority
			elseif left_or_right then
				node.position = vector_lerp(node.position, left_or_right.position, influence)
				node.quat_vector, node.quat_scalar = quat_nlerp(
					node.quat_vector, node.quat_scalar, 
					left_or_right.quat_vector, left_or_right.quat_scalar, influence
				)
				node.priority = priority
			end
			--stylua: ignore end
		end
	end

	result_coordinate_frames["root"] = root
	for _, limb in limb_array do
		local position = limb.position
		local quat_vector = limb.quat_vector

		--stylua: ignore
		local transform = CFrame.new(
			position.X, position.Y, position.Z,
			quat_vector.X, quat_vector.Y, quat_vector.Z, limb.quat_scalar
		)

		result_coordinate_frames[limb.name] = result_coordinate_frames[limb.depends_on]
			* limb.c0
			* transform
			* limb.c1
	end
end

return animation_solver

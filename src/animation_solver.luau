local create_rig = require("./rig")
local animation_asset = require("./animation_asset")

export type AnimationPlayback = {
	asset: animation_asset.Identity,

	-- 0-1
	alpha: number,

	-- 0-1
	influence: number,

	-- arbitrary number
	priority: number,
}

local function get_keyframe_before(
	alpha: number,
	keyframeArray: { animation_asset.KeyframeNode },
	length: number
): animation_asset.KeyframeNode?
	local closestKeyframe: animation_asset.KeyframeNode? = nil
	local closestDistance: number = math.huge

	local specifiedTime = (alpha * length)

	for _, keyframeNode in keyframeArray do
		local distance = keyframeNode.time - specifiedTime
		local absoluteDistance = math.abs(distance)

		if distance <= 0 and (absoluteDistance < closestDistance) then
			closestKeyframe = keyframeNode
			closestDistance = absoluteDistance
		end
	end

	return closestKeyframe
end

local function get_keyframe_after(
	alpha: number,
	keyframeArray: { animation_asset.KeyframeNode },
	length: number
): animation_asset.KeyframeNode?
	local closestKeyframe: animation_asset.KeyframeNode? = nil
	local closestDistance: number = math.huge

	local specifiedTime = (alpha * length)

	for _, keyframe in keyframeArray do
		local distance = keyframe.time - specifiedTime
		local absoluteDistance = math.abs(distance)

		if distance >= 0 and (absoluteDistance < closestDistance) then
			closestKeyframe = keyframe
			closestDistance = absoluteDistance
		end
	end

	return closestKeyframe
end

local function calculate(rig: { [string]: CFrame }, info: create_rig.LimbInfo, origin: CFrame): ()
	local result_transform = origin * info.coordinate_frame0 * info.transform * info.coordinate_frame1

	rig[info.name] = result_transform

	for _, derived in info.derived do
		calculate(rig, derived, result_transform)
	end
end

local function animation_solver(
	rig: create_rig.Identity,
	anim_playbacks: { [animation_asset.Identity]: AnimationPlayback },
	root: CFrame
): ()
	local limb_info_array = rig.flattened
	for _, node in limb_info_array do
		node.priority = -1
	end

	for _, playback in anim_playbacks do
		local before_keyframe, after_keyframe =
			get_keyframe_before(playback.alpha, playback.asset.keyframes, playback.asset.length),
			get_keyframe_after(playback.alpha, playback.asset.keyframes, playback.asset.length)

		local lerp_alpha = playback.asset.length * playback.alpha

		for _, node in limb_info_array do
			if node.priority > playback.priority then
				continue
			end

			local left_pose, right_pose =
				before_keyframe and before_keyframe.poses[node.name], after_keyframe and after_keyframe.poses[node.name]

			if left_pose and right_pose then
				node.priority = playback.priority
				local calculated_transform = left_pose.coordinate_frame:Lerp(
					right_pose.coordinate_frame,
					left_pose.easing_function((lerp_alpha - left_pose.time) / (right_pose.time - left_pose.time))
				)

				node.transform = node.transform:Lerp(calculated_transform, playback.influence)
			elseif left_pose or right_pose then
				node.priority = playback.priority
				local calculated_transform = ((left_pose or right_pose) :: animation_asset.PoseNode).coordinate_frame

				node.transform = node.transform:Lerp(calculated_transform, playback.influence)
			end
		end
	end

	calculate(rig.result, rig.root, root)
end

return animation_solver

export type LimbInfo = {
	c0: CFrame,
	c1: CFrame,

	name: string,

	children: { LimbInfo }?,
}

export type Limb = {
	name: string,
	c0: CFrame,
	c1: CFrame,
	depends_on: string,

	priority: number,

	position: vector,
	quat_vector: vector,
	quat_scalar: number,
}

export type Identity = {
	_topologically_sorted_limbs: { Limb },

	result_coordinate_frames: { [string]: CFrame },
}

local function topological_sort(array: { Limb }, node: LimbInfo)
	if not node.children then
		return
	end

	for _, value in node.children do
		table.insert(array, {
			name = value.name,
			depends_on = node.name,

			c0 = value.c0,
			c1 = value.c1:Inverse(),

			priority = -1,
			position = vector.zero,
			quat_vector = vector.zero,
			quat_scalar = 1,
		})

		topological_sort(array, value)
	end
end

local function create_rig(limb: LimbInfo): Identity
	local limb_arr = {}

	table.insert(limb_arr, {
		name = limb.name,
		depends_on = "root",

		c0 = limb.c0,
		c1 = limb.c1:Inverse(),

		priority = -1,
		position = vector.zero,
		quat_vector = vector.zero,
		quat_scalar = 1,
	})

	topological_sort(limb_arr, limb)

	return {
		_topologically_sorted_limbs = limb_arr,

		result_coordinate_frames = {},
	}
end

return {
	create_rig = create_rig,
}

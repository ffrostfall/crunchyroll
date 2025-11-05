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
}

export type LimbTransform = {
	priority: number,
	position: vector,
	quat_vector: vector,
	quat_scalar: number,
}

export type Identity = {
	limbs: { Limb },
	limb_transforms: { LimbTransform },
	--- used in animation loading to quickly map pose name to limb index
	limb_name_to_index: { [string]: number },

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
		})

		topological_sort(array, value)
	end
end

local function create_rig(root: LimbInfo): Identity
	local limbs: { Limb } = {}
	table.insert(limbs, {
		name = root.name,
		depends_on = "root",
		c0 = root.c0,
		c1 = root.c1:Inverse(),
	})

	topological_sort(limbs, root)

	local limb_transforms: { LimbTransform } = {}
	local limb_name_to_index: { [string]: number } = {}

	for index, limb in limbs do
		limb_transforms[index] = {
			priority = -1,
			position = vector.zero,
			quat_vector = vector.zero,
			quat_scalar = 1,
		}
		limb_name_to_index[limb.name] = index
	end

	return {
		limbs = limbs,
		limb_transforms = limb_transforms,
		limb_name_to_index = limb_name_to_index,

		result_coordinate_frames = {},
	}
end

return {
	create_rig = create_rig,
}

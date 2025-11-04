return {
	name = "HumanoidRootPart",
	c0 = CFrame.identity,
	c1 = CFrame.identity,
	children = {
		{
			name = "Torso",

			c0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
			c1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),

			children = {
				{
					name = "Head",
					c0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
					c1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
				},
				{
					name = "Left Leg",
					c0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
					c1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
				},
				{
					name = "Right Leg",
					c0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
					c1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
				},
				{
					name = "Left Arm",
					c0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
					c1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
				},
				{
					name = "Right Arm",
					c0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
					c1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
				},
			},
		},
		{
			name = "ExtraJoint",
			c0 = CFrame.new(0, 0, -2),
			c1 = CFrame.identity,
		},
	},
}

---
sidebar_position: 3
---

# Rigs

Rigs in crunchyroll are really just Motor6D instances in dictionary form. An easy way to convert an existing rig into a crunchyroll rig is to use the Codify plugin to grab the C0 and C1s of the Motor6Ds.

The format is pretty simple.

## Easy R6 rig

```luau
return crunchyroll.create_rig({
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
})
```

### R6 rig with a joint attached to "HumanoidRootPart"

```luau
return crunchyroll.create_rig({
    name = "HumanoidRootPart",
	c0 = CFrame.identity,
	c1 = CFrame.identity,
	children = {
		{
			name = "Ball",
			c0 = CFrame.new(0, -2, -2),
			c1 = CFrame.identity,
		},
		{
			name = "Torso",
			-- ... the rest of r6 rig
		},
	},
})
```

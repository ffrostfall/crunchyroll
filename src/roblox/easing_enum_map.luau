local Enum = Enum or (require("@lune/roblox").Enum :: any) :: typeof(Enum)

local easings = require("../easings")

local EASING_IN = Enum.PoseEasingDirection.In
local EASING_OUT = Enum.PoseEasingDirection.Out
local EASING_IN_OUT = Enum.PoseEasingDirection.InOut

local LINEAR = Enum.PoseEasingStyle.Linear
local CUBIC = Enum.PoseEasingStyle.Cubic
local BOUNCE = Enum.PoseEasingStyle.Bounce
local ELASTIC = Enum.PoseEasingStyle.Elastic
local CONSTANT = Enum.PoseEasingStyle.Constant

return {
	[LINEAR] = {
		[EASING_IN] = easings.linear,
		[EASING_OUT] = easings.linear,
		[EASING_IN_OUT] = easings.linear,
	},

	[CUBIC] = {
		[EASING_IN] = easings.cubic_in,
		[EASING_OUT] = easings.cubic_out,
		[EASING_IN_OUT] = easings.cubic_in_out,
	},

	[BOUNCE] = {
		[EASING_IN] = easings.bounce_in,
		[EASING_OUT] = easings.bounce_out,
		[EASING_IN_OUT] = easings.bounce_in_out,
	},

	[ELASTIC] = {
		[EASING_IN] = easings.elastic_in,
		[EASING_OUT] = easings.elastic_out,
		[EASING_IN_OUT] = easings.elastic_in_out,
	},

	[CONSTANT] = {
		[EASING_IN] = easings.constant,
		[EASING_OUT] = easings.constant,
		[EASING_IN_OUT] = easings.constant,
	},
}

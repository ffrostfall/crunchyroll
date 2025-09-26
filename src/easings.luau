--!native
local function linear(value: number): number
	return value
end

local function cubic_in(alpha: number): number
	return alpha ^ 3
end

local function cubic_out(alpha: number): number
	return 1 - ((1 - alpha) ^ 3)
end

local function cubic_in_out(alpha: number): number
	if alpha < 0.5 then
		return 4 * (alpha ^ 3)
	end

	return 1 - ((-2 * alpha + 2) ^ 3) * 0.5
end

local function bounce_in(alpha: number): number
	local Compliment = 1 - alpha

	if Compliment < 0.36363636363636365 then
		return 1 - 7.5625 * Compliment * Compliment
	end

	if Compliment < 0.7272727272727273 then
		local Base = Compliment - 0.5454545454545454
		return 1 - 7.5625 * Base * Base + 0.75
	end

	if Compliment < 0.9090909090909091 then
		local Base = Compliment - 0.9090909090909091
		return 1 - 7.5625 * Base * Base + 0.9375
	end

	local Base = Compliment - 0.9545454545454546
	return 1 - 7.5625 * Base * Base + 0.984375
end

local function bounce_out(alpha: number): number
	if alpha < 0.36363636363636365 then
		return 7.5625 * alpha * alpha
	end

	if alpha < 0.7272727272727273 then
		local Base = alpha - 0.5454545454545454
		return 7.5625 * Base * Base + 0.75
	end

	if alpha < 0.9090909090909091 then
		local Base = alpha - 0.9090909090909091
		return 7.5625 * Base * Base + 0.9375
	end

	local Base = alpha - 0.9545454545454546
	return 7.5625 * Base * Base + 0.984375
end

local function bounce_in_out(Value: number): number
	if Value < 0.5 then
		local Compliment = 1 - 2 * Value

		if Compliment < 0.36363636363636365 then
			return (1 - 7.5625 * Compliment * Compliment) * 0.5
		end

		if Compliment < 0.7272727272727273 then
			local Base = Compliment - 0.5454545454545454
			return (1 - 7.5625 * Base * Base + 0.75) * 0.5
		end

		if Compliment < 0.9090909090909091 then
			local Base = Compliment - 0.9090909090909091
			return (1 - 7.5625 * Base * Base + 0.9375) * 0.5
		end

		local Base = Compliment - 0.9545454545454546
		return (1 - 7.5625 * Base * Base + 0.984375) * 0.5
	end

	local Compliment = 2 * Value - 1

	if Compliment < 0.36363636363636365 then
		return (1 + 7.5625 * Compliment * Compliment) * 0.5
	end

	if Compliment < 0.7272727272727273 then
		local Base = Compliment - 0.5454545454545454
		return (1 + 7.5625 * Base * Base + 0.75) * 0.5
	end

	if Compliment < 0.9090909090909091 then
		local Base = Compliment - 0.9090909090909091
		return (1 + 7.5625 * Base * Base + 0.9375) * 0.5
	end

	local Base = Compliment - 0.9545454545454546
	return (1 + 7.5625 * Base * Base + 0.984375) * 0.5
end

local function elastic_in(alpha: number): number
	return -2 ^ (10 * alpha - 10) * math.sin((alpha * 10 - 10.75) * 2.0943951023931953)
end

local function elastic_out(Value: number): number
	return 2 ^ (-10 * Value) * math.sin((Value * 10 - 0.75) * 2.0943951023931953) + 1
end

local function elastic_in_out(Value: number): number
	if Value < 0.5 then
		return -2 ^ (20 * Value - 10) * math.sin((20 * Value - 11.125) * 1.3962634015954636) * 0.5
	end

	return 2 ^ -20 * Value + 10 * math.sin(20 * Value - 11.125 * 1.3962634015954636) * 0.5 + 1
end

local function constant(Value: number): number
	return 0
end

return {
	linear = linear,

	constant = constant,

	cubic_in = cubic_in,
	cubic_out = cubic_out,
	cubic_in_out = cubic_in_out,

	bounce_in = bounce_in,
	bounce_out = bounce_out,
	bounce_in_out = bounce_in_out,

	elastic_in = elastic_in,
	elastic_out = elastic_out,
	elastic_in_out = elastic_in_out,
}

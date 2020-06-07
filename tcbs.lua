local halfpi = 0.5*math.pi
local pi = math.pi
local twopi = 2*math.pi
local tcb_svg_data = {}

-- Solution to the gradient of the line subtended by an angle from the vertical
-- axis (like north in minetest), using sine rule.
function angle2gradient(gamma)
	if gamma == pi or gamma == 0 then return math.huge end
	local alpha = math.pi-(gamma+(halfpi))
	local r = 1/math.sin(alpha)
	local m = (math.sin(pi-(gamma+halfpi))) / (math.sin(gamma))
	if gamma > 180 then
		return -m
	else 
		return m
	end
end

function testAngles()
	local testAngles = {0, 30, 45, 63.434949, 90, 120, 135, 153.434949, 180}
	for _,x in pairs(testAngles) do
		print(x, angle2gradient(math.rad(x)))
	end
end

local function debugprint(...)
	if false then 
		table.insert(tcb_svg_data, a)
		local varargs = {...}
		local str = {}
		for k,v in pairs(varargs) do
			table.insert(str, tostring(v))
		end

		table.insert(tcb_svg_data, '<!--'.. (table.concat(str, "\t")) .. '-->')
	end
end

-- The TCB is drawn perpendicular to the rail it is assigned to.
-- The drawn TCB is the hypotenuse of a triangle on (x,z) plane and its
-- hypotenuse length is constant, while its x,z components are in a ratio
-- according to the gradient of the TCB's line.
local hypot = 1.2
local hypotsq = hypot*hypot
function tcb_do_pos(pos)
	local x,y,z = pos:match("(-?%d+),(-?%d+),(-?%d+)")
	x = tonumber(x)
	y = tonumber(y)
	z = tonumber(z)
	--debugprint(x,y,z)
	local vPos = vector.new(x,y,z)

	local trackData = advtrains.ndb.get_node(vPos)
	--debugprint("get_node:", core.serialize(trackData))

	local good, conns, railheight = advtrains.get_rail_info_at(vPos)
	--debugprint("get_rail_info_at:", good, core.serialize(conns), railheight)

	if (not conns) then
		print("Invalid pos in database: "..tostring(pos))
		return false -- Various other garbage will appear for whatever reason.
	end
	local medianAngle = advtrains.conn_angle_median(conns[1].c, conns[2].c)
	local gradient = angle2gradient(medianAngle)
	--debugprint(string.format("Median connecting angle: %f rad / %f deg has gradient %f",
	--	medianAngle, math.deg(medianAngle), gradient))

	-- Normalise median angle to 0-180 degrees
	if medianAngle < 0 then medianAngle = medianAngle + twopi end
	if medianAngle > twopi then medianAngle = medianAngle - twopi end
	if medianAngle > math.pi then medianAngle = medianAngle - math.pi end

	-- Add a right angle to make the perpendicular line
	local perpAngle = medianAngle + halfpi
	if perpAngle > math.pi then
		perpAngle = perpAngle - math.pi -- then normalise back to 0-180 again
	end
	local perpGradient
	-- premature opimisation / is not actually cheaper because it does not
	-- give 0 or infinity without fuzzy comparison
	-- perpGradient = -1/gradient
	perpGradient = angle2gradient(perpAngle)
	--debugprint(string.format("Perp. angle: %f rad / %f deg has gradient %f",
	--	perpAngle, math.deg(perpAngle), perpGradient))

	-- TODO: Calculate a distance of 0.5 out along the perpedicular line
	-- in both directions, and place a line through those two points.
	local x_delta, z_delta
	if perpGradient == math.huge then
		x_delta = 0.0
		z_delta = hypot
	elseif perpGradient == 0 then
		x_delta = hypot
		z_delta = 0.0
	else
		-- Solution based on pythagorean theorem with ratio of sides given by gradient and hypotenuse of length 1.2
		local m2 = perpGradient*perpGradient
		m2 = m2 + 1
		m2 = 1/m2
		x_delta = math.sqrt(hypotsq*(m2))
		z_delta = math.sqrt(hypotsq*(1-m2))
	end
	--debugprint(string.format("x_delta = %f", x_delta))
	--debugprint(string.format("z_delta = %f", z_delta))

	local x1, y1, x2, y2
	if perpGradient < 0 then
		x1 = x + x_delta
		y1 = z + z_delta
		x2 = x - x_delta
		y2 = z - z_delta
	else
		x1 = x + x_delta
		y1 = z - z_delta
		x2 = x - x_delta
		y2 = z + z_delta
	end

	return string.format('<line x1="%f" y1="%f" x2="%f" y2="%f" stroke="orange" stroke-width="0.5" />',
		x1, -y1, x2, -y2
	)
end

for pos,data in pairs(advtrains.track_circuit_breaks) do
	local a = tcb_do_pos(pos)
	if a then
		table.insert(tcb_svg_data, a)
	end
end

return tcb_svg_data
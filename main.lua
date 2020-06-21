-- advtrains track map generator
-- Usage: lua main.lua path/to/world

-- Viewport maximum coordinate in all directions
local maxc = 7008

-- embed an image called "world.png"
local wimg = false
-- image file resolution (not world resolution!)
local wimresx = 14016
local wimresy = 14016
-- one pixel is ... nodes
local wimscale = 1

-- y ranges and line colors
-- Minimum y level drawn
local drminy = -30
-- Color of min y level
local colminy = {r=0, g=0, b=255}
-- Intermediate color
local colmedy = {r=255, g=0, b=0}
-- Maximum y level drawn
local drmaxy = 80
-- Color of max y level
local colmaxy = {r=255, g=255, b=0}


datapath = (arg[1] or "").."/"


--Constant for maximum connection value/division of the circle
AT_CMAX = 16

advtrains = {}
minetest = {}
core = minetest

--table for track nodes/connections
trackconns = {}

-- math library seems to be missing this function
math.hypot = function(a,b) return math.sqrt(a*a + b*b) end

-- need to declare this for trackdefs
function attrans(str) return str end

-- pos to string
local function pts(pos)
	return pos.x .. "," .. pos.y .. "," .. pos.z
end

--Advtrains dump (special treatment of pos and sigd)
function atdump(t, intend)
	local str
	if type(t)=="table" then
		if t.x and t.y and t.z then
			str=minetest.pos_to_string(t)
		elseif t.p and t.s then -- interlocking sigd
			str="S["..minetest.pos_to_string(t.p).."/"..t.s.."]"
		else
			str="{"
			local intd = (intend or "") .. "  "
			for k,v in pairs(t) do
				if type(k)~="string" or not string.match(k, "^path[_]?") then
					-- do not print anything path-related
					str = str .. "\n" .. intd .. atdump(k, intd) .. " = " ..atdump(v, intd)
				end
			end
			str = str .. "\n" .. (intend or "") .. "}"
		end
	elseif type(t)=="boolean" then
		if t then
			str="true"
		else
			str="false"
		end
	elseif type(t)=="function" then
		str="<function>"
	elseif type(t)=="userdata" then
		str="<userdata>"
	else
		str=""..t
	end
	return str
end

dofile("vector.lua")
dofile("serialize.lua")
dofile("helpers.lua")
dofile("tracks.lua")
dofile("track_defs.lua")
atlatc_parse_database = require("atlatc_defs")

dofile("nodedb.lua")


function parse_args(argv) 
	local i = 1
	local no_trains = false
	local datapath, mappath, worldimage
	while i <= #argv do
		local a = argv[i]
		if (a == "-m") or (a == "--map-file") then
			-- only draw trains – requires specifying an already drawn file
			i = i+1
			if not argv[i] then
				error(("missing filename after `%s'"):format(a))
			end
			mappath = argv[i]
		elseif (a == "-t") or (a == "--no-trains") then
			-- do not draw trains
			no_trains = true
		elseif (a == "-w") or (a == "--world-image") then
			-- overlay over world image
			i = i+1
			if not argv[i] then
				error(("missing filename after `%s'"):format(a))
			end
			worldimage = argv[i]
		else
			datapath = a
		end
		
		i = i + 1
	end
	return datapath, mappath, no_trains, worldimage
end

datapath, mappath, no_trains, worldimage = parse_args(arg)

local function loadtable(filename, nicename)
	local file, err = io.open(filename, "r")
	local tbl = minetest.deserialize(file:read("*a"))
	if type(tbl) ~= "table" then
		error(nicename .. " file: not a table")
	end
	file:close()
	return tbl
end

advtrains.trains = loadtable(datapath.."advtrains_trains", "Trains")
advtrains.ndb.load_data(loadtable(datapath.."advtrains_ndb", "Node database"))
advtrains.lines = loadtable(datapath.."advtrains_lines", "Lines")
advtrains.track_circuit_breaks = loadtable(datapath.."advtrains_interlocking_tcbs")
advtrains.luaautomation = loadtable(datapath.."advtrains_luaautomation")

local svgfile = io.open(datapath.."out.svg", "w")

if mappath then
	mapfile = io.open(mappath, "r")
	cont = mapfile:read("*a"):sub(1, -7) -- remove </svg> end tag
	svgfile:write(cont)
else
	svgfile:write([[
<?xml version="1.0" standalone="no" ?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN"
  "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg width="1024" height="800" xmlns="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink" ]])


	svgfile:write('viewBox="'..(-maxc)..' '..(-maxc)..' '..(2*maxc)..' '..(2*maxc)..'" >')

	svgfile:write([[
<circle cx="0" cy="0" r="5" stroke="red" stroke-width="1" />
]])
end
if worldimage then
	local wimx = -(wimresx*wimscale/2)
	local wimy = -(wimresy*wimscale/2)
	local wimw = wimresx*wimscale
	local wimh = wimresy*wimscale
	
	svgfile:write('<image xlink:href="'..worldimage..'" x="'..wimx..'" y="'..wimy..'" height="'..wimh..'px" width="'..wimw..'px"/>')
end

local function writec(text)
	--print("\n"..text)
	svgfile:write("<!-- " .. text .. " -->\n")
end

-- Calculate how TCBs will be drawn, but draw them after the rails
-- so the TCBs are on top. The nodedb will emptied when the rails are drawn, so
-- the TCBs are calculated first.
tcb_svg_data = require("tcbs")

-- everything set up. Start generating an SVG
-- All nodes that have been fit into a polyline are removed from the NDB, in order to not draw them again.

-- "Restart points" for the breadth-first traverser (set when more than 2 conns present)
-- {pos = <position>, connid = <int>, conn = <conndef>}
-- Note that the node at "pos" is already deleted from the NDB at the time of recall, therefore "conn" is specified
local bfs_rsp = {}

local ndb_nodes_handled = 0

-- Points of the current polyline. Inserted as xyz vectors, maybe we'll use the y value one day
local current_polyline = {}

-- Traverser function from interlocking, highly modified
local function gen_rsp_polyline(rsp)

	-- trick a bit
	local pos, connid, conns = rsp.pos, 1, {rsp.conn}
	current_polyline[#current_polyline+1] = pos
	
	while true do
		local adj_pos, adj_connid, conn_idx, nextrail_y, next_conns = advtrains.get_adjacent_rail(pos, conns, connid)
		if not adj_pos then
			-- proceed one more node, for seamless turnout transitions
			current_polyline[#current_polyline+1] = advtrains.pos_add_dir(pos, conns[connid].c)
			return
		end
		-- continue traversing
		local conn_mainbranch
		for nconnid, nconn in ipairs(next_conns) do
			if adj_connid ~= nconnid then
				if not conn_mainbranch then
					--use the first one found to continue
					conn_mainbranch = nconnid
					--writec(nconnid.." nconn mainbranch")
				else
					-- insert bfs reminders for other conns
					table.insert(bfs_rsp, {pos = adj_pos, connid = nconnid, conn = nconn})
					--writec(nconnid.." nconn bfs")
				end
			end
		end
		
		-- save in polyline and delete from ndb
		--writec("Saved pos: "..pts(adj_pos).." mainbranch cont "..conn_mainbranch.." nextconns "..atdump(next_conns))
		current_polyline[#current_polyline+1] = adj_pos
		advtrains.ndb.clear(adj_pos)
		ndb_nodes_handled = ndb_nodes_handled + 1
		
		pos, connid, conns = adj_pos, conn_mainbranch, next_conns
		
	end
end

plcnt = 0


local function hexcolor(clr)
	return "#"..advtrains.hex8(clr.r)..advtrains.hex8(clr.g)..advtrains.hex8(clr.b)
end

local function cfactor(ry)
	local y = ry - (ry%4)

	local fac = (y-drminy)/(drmaxy-drminy)
	return fac
end

local function pl_header(fac)
	
	local color
	if fac<0.5 then
		color = {
			r = colminy.r + (colmedy.r-colminy.r)*2*fac,
			g = colminy.g + (colmedy.g-colminy.g)*2*fac,
			b = colminy.b + (colmedy.b-colminy.b)*2*fac,
		}
	else
		color = {
			r = colmedy.r + (colmaxy.r-colmedy.r)*(2*fac-1),
			g = colmedy.g + (colmaxy.g-colmedy.g)*(2*fac-1),
			b = colmedy.b + (colmaxy.b-colmedy.b)*(2*fac-1),
		}
	end
	
	local c = hexcolor(color)
	return '<polyline style="fill:none;stroke:'..c..';stroke-width:1" points="'
end

local function polyline_write(pl)
	local p1y = cfactor(pl[1].y) --colour factor
	local str = {}
	
	if p1y <= 1 and p1y >= 0 then
		table.insert(str, pl_header(p1y))
	end
	
	local i
	local e
	local lastcf = p1y
	local lastldir = {x=0, y=0}
	for i=1,#pl do
		e = pl[i]
		local cf = cfactor(e.y)
		if cf ~= lastcf then
			if lastcf <= 1 and lastcf >= 0 then
				-- insert final point
				-- Note that we mirror y, so positive z is up
				table.insert(str, e.x .. "," .. -(e.z) .. " ")
				table.insert(str, '" />\n')
				plcnt = plcnt + 1
			end
			if cf <= 1 and cf >= 0 then
				table.insert(str, pl_header(cf))
			end
		end
		if cf <= 1 and cf >= 0 then
			-- Note that we mirror y, so positive z is up
			table.insert(str, e.x .. "," .. -(e.z) .. " ")
		end
		lastcf = cf
	end
	if lastcf <= 1 and lastcf >= 0 then
		table.insert(str, '" />\n')
	end
	svgfile:write(table.concat(str))
	plcnt = plcnt + 1
end


-- while there are entries in the nodedb
-- 1. find a starting point
if not mappath then
	local stpos, conns = advtrains.ndb.mapper_find_starting_point()
	while stpos do
		
		writec("Restart at position "..pts(stpos))
		for connid, conn in ipairs(conns) do
			table.insert(bfs_rsp, {pos = stpos, connid = connid, conn = conn})
		end
		advtrains.ndb.clear(stpos)
		
		-- 2. while there are BFS entries
		while #bfs_rsp > 0 do
			-- make polylines
			local current_rsp = bfs_rsp[#bfs_rsp]
			bfs_rsp[#bfs_rsp] = nil
			--print("Starting polyline at "..pts(current_rsp.pos).."/"..current_rsp.connid)
			
			
			current_polyline = {}
			
			gen_rsp_polyline(current_rsp)
			
			polyline_write(current_polyline)
			
			io.write("Progress ", ndb_nodes_handled, "+", ndb_nodes_notrack, "/", ndb_nodes_total, "=", math.floor(((ndb_nodes_handled+ndb_nodes_notrack)/ndb_nodes_total)*100), "%\r")
		end
		stpos, conns = advtrains.ndb.mapper_find_starting_point()
	end
end
-- draw trains
trains = 0
stopped = 0
lines = {}
running = {}
if not no_trains then
	for i,v in pairs(advtrains.trains) do
		pos = v.last_pos
		color = "green"
		if v.velocity == 0 then
			color = "orange"
			stopped = stopped + 1
		end
		svgfile:write("<circle cx=\""..pos.x.."\" cy=\""..-pos.z.."\" r=\"3\" stroke=\""..color.."\" stroke-width=\"1\" fill=\"none\" />")
		if v.line then
			lines[v.line] = (lines[v.line] or 0) + 1
			if v.velocity ~= 0 then
				running[v.line] = (running[v.line] or 0) + 1
			end
			svgfile:write(" <text x=\""..(pos.x+5).."\" y=\""..-pos.z.."\" class=\"trainline\">"..v.line.."</text>")
		end
		trains = trains+1
	end
end

-- draw station stops
totalStops = 0
stopPos = vector.new()
for encodedPos, stopInfo in pairs(advtrains.lines.stops) do
	stopPos = advtrains.decode_pos(encodedPos)
	--io.write(string.format("Stop at (%d, %d, %d) at Station %s", stopPos.x, stopPos.y, stopPos.z, stopInfo.stn or ""))
	svgfile:write(string.format('<circle cx="%d" cy="%d" r="3" stroke="cyan" stroke-width="2" fill="black" />\n',
		                         stopPos.x, -stopPos.z))
	local stnInfo = advtrains.lines.stations[stopInfo.stn]
	local trackText = stopInfo.track
	if trackText ~= "" then
		trackText = "T. " .. trackText
	end
	if (advtrains.lines.stations[stopInfo.stn] ~= nil) then
		svgfile:write(string.format('<text x="%d" y="%d" transform="rotate(45,%d, %d)" class="stop">%s %s</text>\n',
		                             stopPos.x, -stopPos.z, stopPos.x, -stopPos.z,
		                             htmlspecialchars(advtrains.lines.stations[stopInfo.stn].name),
		                             htmlspecialchars(trackText)))
	end
end

-- draw LuaATC stops
svgfile:write(table.concat(atlatc_parse_database(advtrains.luaautomation.active.nodes)))

-- Draw TCBs on top of tracks
svgfile:write(table.concat(tcb_svg_data, "\n"))

svgfile:write("</svg>")
svgfile:close()

print("\nWrote",plcnt,"polylines. Processed", ndb_nodes_handled, "track,",ndb_nodes_notrack, "non-track nodes out of", ndb_nodes_total)
print("Drew "..trains.." trains. "..stopped.." stopped trains.")
print("\n Number of trains moving/total:")
for i,v in pairs(lines) do
	print(i..":            "..(running[i] or 0).."/"..v)
end

--nodedb.lua
--database of all nodes that have 'save_in_at_nodedb' field set to true in node definition


--serialization format:
--(2byte z) (2byte y) (2byte x) (2byte contentid)
--contentid := (14bit nodeid, 2bit param2)

local function int_to_bytes(i)
	local x=i+32768--clip to positive integers
	local cH = math.floor(x /           256) % 256;
	local cL = math.floor(x                ) % 256;
	return(string.char(cH, cL));
end
local function bytes_to_int(bytes)
	local t={string.byte(bytes,1,-1)}
	local n = 
		t[1] *           256 +
		t[2]
    return n-32768
end
local function l2b(x)
	return x%4
end
local function u14b(x)
	return math.floor(x/4)
end
local ndb={}

--local variables for performance
local ndb_nodeids={}
local ndb_nodes={}

local function ndbget(x,y,z)
	local ny=ndb_nodes[y]
	if ny then
		local nx=ny[x]
		if nx then
			return nx[z]
		end
	end
	return nil
end
local function ndbset(x,y,z,v)
	if not ndb_nodes[y] then
		ndb_nodes[y]={}
	end
	if not ndb_nodes[y][x] then
		ndb_nodes[y][x]={}
	end
	ndb_nodes[y][x][z]=v
end


local path="advtrains_ndb2"
--load
--nodeids get loaded by advtrains init.lua and passed here
function ndb.load_data(data)
	ndb_nodeids = data and data.nodeids or {}
	local file, err = io.open(path, "rb")
	if not file then
		print("Couldn't load the node database: ", err or "Unknown Error")
	else
		local cnt=0
		local hst_z=file:read(2)
		local hst_y=file:read(2)
		local hst_x=file:read(2)
		local cid=file:read(2)
		while hst_z and hst_y and hst_x and cid and #hst_z==2 and #hst_y==2 and #hst_x==2 and #cid==2 do
			ndbset(bytes_to_int(hst_x), bytes_to_int(hst_y), bytes_to_int(hst_z), bytes_to_int(cid))
			cnt=cnt+1
			hst_z=file:read(2)
			hst_y=file:read(2)
			hst_x=file:read(2)
			cid=file:read(2)
		end
		print("nodedb: read", cnt, "nodes.")
		file:close()
	end
end

--function to get node. track database is not helpful here.
function ndb.get_node_or_nil(pos)
	-- FIX for bug found on linuxworks server:
	-- a loaded node might get read before the LBM has updated its state, resulting in wrongly set signals and switches
	-- -> Using the saved node prioritarily.
	local node = ndb.get_node_raw(pos)
	if node then
		return node
	else
		-- no minetest here
		return nil
	end
end
function ndb.get_node(pos)
	local n=ndb.get_node_or_nil(pos)
	if not n then
		return {name="ignore", param2=0}
	end
	return n
end
function ndb.get_node_raw(pos)
	local cid=ndbget(pos.x, pos.y, pos.z)
	if cid then
		local nodeid = ndb_nodeids[u14b(cid)]
		if nodeid then
			return {name=nodeid, param2 = l2b(cid)}
		end
	end
	return nil
end

function ndb.clear(pos)
	ndbset(pos.x, pos.y, pos.z, nil)
end


--get_node with pseudoload. now we only need track data, so we can use the trackdb as second fallback
--nothing new will be saved inside the trackdb.
--returns:
--true, conn1, conn2, rely1, rely2, railheight   in case everything's right.
--false  if it's not a rail or the train does not drive on this rail, but it is loaded or
--nil    if the node is neither loaded nor in trackdb
--the distraction between false and nil will be needed only in special cases.(train initpos)
function advtrains.get_rail_info_at(pos)
	local rdp=advtrains.round_vector_floor_y(pos)
	
	local node=ndb.get_node_or_nil(rdp)
	if not node then return end
	
	local nodename=node.name
	
	local conns, railheight, tracktype=advtrains.get_track_connections(node.name, node.param2)
	
	if not conns then
		return false
	end
	
	return true, conns, railheight
end


-- mapper-specific

function ndb.mapper_find_starting_point()
	for y, ty in pairs(ndb_nodes) do
		for x, tx in pairs(ty) do
			for z, v in pairs(tx) do
				local pos = {x=x, y=y, z=z}
				local node_ok, conns, _ = advtrains.get_rail_info_at(pos)
				if node_ok then
					return pos, conns
				else
					-- this is a signal or something similar, ignore.
					tx[z]=nil
				end
			end
		end
	end
end


advtrains.ndb = ndb

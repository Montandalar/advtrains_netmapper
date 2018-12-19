--advtrains by orwell96, see readme.txt

--dev-time settings:
--EDIT HERE
--If the old non-model rails on straight tracks should be replaced by the new...
--false: no
--true: yes
advtrains.register_replacement_lbms=false

--[[TracksDefinition
nodename_prefix
texture_prefix
description
common={}
straight={}
straight45={}
curve={}
curve45={}
lswitchst={}
lswitchst45={}
rswitchst={}
rswitchst45={}
lswitchcr={}
lswitchcr45={}
rswitchcr={}
rswitchcr45={}
vert1={
	--you'll probably want to override mesh here
}
vert2={
	--you'll probably want to override mesh here
}
]]--
advtrains.all_tracktypes={}

--definition preparation
local function conns(c1, c2, r1, r2) return {{c=c1, y=r1}, {c=c2, y=r2}} end
local function conns3(c1, c2, c3, r1, r2, r3) return {{c=c1, y=r1}, {c=c2, y=r2}, {c=c3, y=r3}} end

advtrains.ap={}
advtrains.ap.t_30deg_flat={
	regstep=1,
	variant={
		st={
			conns = conns(0,8),
			desc = "straight",
			tpdouble = true,
			tpsingle = true,
			trackworker = "cr",
		},
		cr={
			conns = conns(0,7),
			desc = "curve",
			tpdouble = true,
			trackworker = "swlst",
		},
		swlst={
			conns = conns3(0,8,7),
			desc = "left switch (straight)",
			trackworker = "swrst",
			switchalt = "swlcr",
			switchmc = "on",
			switchst = "st",
		},
		swlcr={
			conns = conns3(0,7,8),
			desc = "left switch (curve)",
			trackworker = "swrcr",
			switchalt = "swlst",
			switchmc = "off",
			switchst = "cr",
		},
		swrst={
			conns = conns3(0,8,9),
			desc = "right switch (straight)",
			trackworker = "st",
			switchalt = "swrcr",
			switchmc = "on",
			switchst = "st",
		},
		swrcr={
			conns = conns3(0,9,8),
			desc = "right switch (curve)",
			trackworker = "st",
			switchalt = "swrst",
			switchmc = "off",
			switchst = "cr",
		},
	},
	regtp=true,
	tpdefault="st",
	trackworker={
		["swrcr"]="st",
		["swrst"]="st",
		["cr"]="swlst",
		["swlcr"]="swrcr",
		["swlst"]="swrst",
	},
	rotation={"", "_30", "_45", "_60"},
}
advtrains.ap.t_30deg_slope={
	regstep=1,
	variant={
		vst1={conns = conns(8,0,0,0.5), rail_y = 0.25, desc = "steep uphill 1/2", slope=true},
		vst2={conns = conns(8,0,0.5,1), rail_y = 0.75, desc = "steep uphill 2/2", slope=true},
		vst31={conns = conns(8,0,0,0.33), rail_y = 0.16, desc = "uphill 1/3", slope=true},
		vst32={conns = conns(8,0,0.33,0.66), rail_y = 0.5, desc = "uphill 2/3", slope=true},
		vst33={conns = conns(8,0,0.66,1), rail_y = 0.83, desc = "uphill 3/3", slope=true},
	},
	regsp=true,
	slopeplacer={
		[2]={"vst1", "vst2"},
		[3]={"vst31", "vst32", "vst33"},
		max=3,--highest entry
	},
	slopeplacer_45={
		[2]={"vst1_45", "vst2_45"},
		max=2,
	},
	rotation={"", "_30", "_45", "_60"},
	trackworker={},
	increativeinv={},
}
advtrains.ap.t_30deg_straightonly={
	regstep=1,
	variant={
		st={
			conns = conns(0,8),
			desc = "straight",
			tpdouble = true,
			tpsingle = true,
			trackworker = "st",
		},
	},
	regtp=true,
	tpdefault="st",
	rotation={"", "_30", "_45", "_60"},
}
advtrains.ap.t_30deg_straightonly_noplacer={
	regstep=1,
	variant={
		st={
			conns = conns(0,8),
			desc = "straight",
			tpdouble = true,
			tpsingle = true,
			trackworker = "st",
		},
	},
	tpdefault="st",
	rotation={"", "_30", "_45", "_60"},
}
advtrains.ap.t_45deg={
	regstep=2,
	variant={
		st={
			conns = conns(0,8),
			desc = "straight",
			tpdouble = true,
			tpsingle = true,
			trackworker = "cr",
		},
		cr={
			conns = conns(0,6),
			desc = "curve",
			tpdouble = true,
			trackworker = "swlst",
		},
		swlst={
			conns = conns3(0,8,6),
			desc = "left switch (straight)",
			trackworker = "swrst",
			switchalt = "swlcr",
			switchmc = "on",
			switchst = "st",
		},
		swlcr={
			conns = conns3(0,6,8),
			desc = "left switch (curve)",
			trackworker = "swrcr",
			switchalt = "swlst",
			switchmc = "off",
			switchst = "cr",
		},
		swrst={
			conns = conns3(0,8,10),
			desc = "right switch (straight)",
			trackworker = "st",
			switchalt = "swrcr",
			switchmc = "on",
			switchst = "st",
		},
		swrcr={
			conns = conns3(0,10,8),
			desc = "right switch (curve)",
			trackworker = "st",
			switchalt = "swrst",
			switchmc = "off",
			switchst = "cr",
		},
	},
	regtp=true,
	tpdefault="st",
	trackworker={
		["swrcr"]="st",
		["swrst"]="st",
		["cr"]="swlst",
		["swlcr"]="swrcr",
		["swlst"]="swrst",
	},
	rotation={"", "_30", "_45", "_60"},
}
advtrains.trackpresets = advtrains.ap

--definition format: ([] optional)
--[[{
	nodename_prefix
	texture_prefix
	[shared_texture]
	models_prefix
	models_suffix (with dot)
	[shared_model]
	formats={
		st,cr,swlst,swlcr,swrst,swrcr,vst1,vst2
		(each a table with indices 0-3, for if to register a rail with this 'rotation' table entry. nil is assumed as 'all', set {} to not register at all)
	}
	common={} change something on common rail appearance
}
[18.12.17] Note on new connection system:
In order to support real rail crossing nodes and finally make the trackplacer respect switches, I changed the connection system.
There can be a variable number of connections available. These are specified as tuples {c=<connection>, y=<rely>}
The table "at_conns" consists of {<conn1>, <conn2>...}
the "at_rail_y" property holds the value that was previously called "railheight"
Depending on the number of connections:
2 conns: regular rail
3 conns: switch:
	- when train passes in at conn1, will move out of conn2
	- when train passes in at conn2 or conn3, will move out of conn1
4 conns: cross (or cross switch, depending on arrangement of conns):
	- conn1 <> conn2
	- conn3 <> conn4
]]

function advtrains.register_tracks(tracktype, def, preset)
	for suffix, var in pairs(preset.variant) do
		for rotid, rotation in ipairs(preset.rotation) do
			if not def.formats[suffix] or def.formats[suffix][rotid] then
				
				--connections
				local at_conns = advtrains.rotate_conn_by(var.conns, (rotid-1)*preset.regstep)

				trackconns[def.nodename_prefix.."_"..suffix..rotation] = at_conns
				
			end
		end
	end
end


function advtrains.get_track_connections(name, param2)
	
	if not trackconns[name] then return end
	
	return advtrains.rotate_conn_by(trackconns[name], param2*AT_CMAX/4), nil, nil
end

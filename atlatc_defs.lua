atlatc_envs = {}
local function register_atlatc_env(name, def)
	atlatc_envs[name] = def
end

-- Definitions follow for the 3 atlatc environments that actually provide
-- station/stop information on LinuxForks server. You can register your own
-- in similar fashion. The first () match in one of the patterns in
-- stop_patterns must match a station code from station_names.
register_atlatc_env("durt", {
	station_names = {
		Dbl = "Dubulti",
		Pav = "Pence Avenue",
		Ghd = "Greenhat Mountain",
		Acm = "Acacia Mountains",
		Ghb = "Green Hill Beach",
		Ged = "Green Edge",
		Dri = "Dry Island",
		Gcl = "Green Cliffs",
		Sfs = "South Forest",
		Jms = "Jude Milhon Street",
		Bam = "Bamboo Hills",
		Cli = "Clown Island",
		Wat = "Something in the Water",
		Duf = "Duff Road",
		Tro = "Turtle Rock"
	},
	stop_patterns = {
		'F.station%s*[(]"(...)",%s*"[WE]"[)]'
	}
})

register_atlatc_env("subway", {
	station_names = {
		Ewb="Edenwood Beach",
		Ban="Bananame",
		ctr="Coulomb Street Triangle",
		Cht="Churchill Street",
		Bbe="Birch Bay East",
		Bap="Turtle Rock",
		Icm="Ice Mountain",
		Eft="BHS10",
		Apl="Apple Plains",
		Pal="Palm Bay",
		Slh="Smacker's Land of Hope and Glory",
		Lks="Leekston",
		Ta1="Testing Area 1",
		Ta2="Testing Area 2",
		Ahr="AHRAZHUL's Station",
		Ahz="Large Beach",
		Wim="Windy Mountains",
		Dam="Szymon's Dam",
		Wva="Windy Mountains Valley 1",
		Wvb="Windy Mountains Valley 2",
		Wvc="Windy Mountains Valley 3",
		App="Apple Grove",
		Dem="Desert Mountain",
		Dev="Desert View (OCP)",
		Lvc="Levenshtein Canyon",
		Gho="Green Hope",
		Snb="Snake Bend",
		Adb="Adorno Boulevard",
		Duf="Duff Road",
		Wat="Something in the water",
		Ram="Ramanujan Street",
		Per="Perelman Street",
		Trp="Trump Park",
		Sfs="South Forest Station",
		Lok="Jude Milhon Street",
		Bam="Bamboo Hills",
		Sfa="unnamed",
		Gcl="Green Cliffs",
		Dri="Dry Island",
		Ged="Green Edge",
		Ghb="Green Hill Beach",
		Acm="Acacia Mountains",
		Ghm="Greenhat Mountain",
		Pna="Pence Avenue",
		Dbl="Dubulti",
		Sws="Schwarzschildt Street",
		Mnk="Minkowsky Street",
		Rgs="Robert Gardon Street",
		Ehl="Ehlodex",
		Lus="Lusin Street",
		Lin="Lesnoi Industrial Area",
		Boz="Booze Grove",
		Mrh="Mirzakhani Street",
		Plt="Planetarium",
		Mcf="McFly Street",
		Tha="Theodor Adorno Street",
		Oni="Onionland",
		Ora="Orange Lake",
		Uaa="Eiffel Street",
		Leo="Leonhard Street",
		Bby="Birch Bay",
		Stb="Stone Beach",
		Jis="Jungle Island",
		Ice="Eternal Ice",
		Bnt="Pierre Berton Street",
		Osa="Origin Sands",
		OBa="Cartesian Square",
		OOr="School",
		OSc="ARA",
		ONb="Intel ME Stairs",
		OIs="SCSI Connector Mess",
		OSm="Origin Sands (Plaza de la Republica)",
		ioa="Cow Bridge",
		iob="Babbage Road",
		Wcs="Watson-Crick Street",
		Rru="Rockefeller Runway",
		Ewd="Edenwood",
		Chu="Marcuse Street Station",
		Erd="Erdos Street",
		Uni="Museum",
		Mar="Felfa's Market (Bracket Road)",
		Wac="Watson-Crick",
		OLv="Market",
		Irk="Ice Rink",
		Sbr="Suburb",
		Unv="University",
		Arc="Archangel",
		Dar="Darwin Road",
		Hmi="Half-Mile Island",
		Zoo="Zoo",
		Bea="Beach",
		Yos="Yoshi Island",
		Krs="Kernighan&Ritchie Street",
		Rkb="Robert Koch Boulevard",
		Rsi="Riverside",
		Swr="Swimming Rabbit Street",
		Wbb="Banana Forest",
		Ori="Origin",
		Snl="Snowland",
		Sys="Ship Rock",
		Rfo="Redwood forest",
		Moj="Mom Junction",
		Wfr="Wolf Rock",
		Spa="Shanielle Park",
		Thh="Treehouse Hotel",
		Stn="Main station",
		WB1="Riverside",
		WB2="Banana Forest",
		WB3="Eiffel Street",
		WB4="Buckminster Fuller Street",
		WB5="White Beaches",
		Shn="Shanielle City",
		Jus="Tom Lehrer Street",
		Fre="Frege Street",
		Min="MinerLand",
		Vlc="Volcano Cliffs",
		Mio="Minio",
		Wpy="Water Pyramid",
		Cat="Cathedral",
		Dca="Desert Canyon",
		Spn="Spawn",
		Brn="Ministry of Transport (bernhardd)",
		Kav="Knuth Avenue",
		Lvf="Library",
		Fms="John Horton Conway Street",
		Mnt="Mountain",
		Mnv="Mountain Valley",
		Mnn="Mountain View",
		Max="Maxwell Street",
		Snp="Snowy Peak",
		Scl="ScottishLion's City",
		Lza="Laza's City",
		Bld="BlackDog",
		Hts="Hotel Shanielle",
		Fmn="Euler Street",
		Gpl="Market",
		Jun="Jungle",
		Jng="Franklin Road",
		Uic="Coulomb Street",
		Grs="Gram-Schmidt Street",
		Lih="Lighthouse",
		Rea="Reactor",
		Hhs="Henderson-Hasselbalch Street",
		Ack="Ackermann Avenue",
		Lis="Lone Island",
		Pyr="Pytagoras Road",
		Nha="North Harbour",
		STn="Technic Station",
		SPo="Post Office",
		SSw="Spawn, westbound",
		SSe="Spawn, eastbound",
		SPa="Papyrus Farm",
		STo="Tourist Info",
		SMi="Public Mine",
		MR1="Euler Street",
		MSt="Main Station (Spawn)",
		MOr="Marcuse Street Station (Origin)",
	},
	stop_patterns = {
		'F.stn%s*[(]%b"",%s*["\']*(...)',
		'F.stn_ilk%s*[(]%b"",%s*"(...)',
		'F.stn_return%s*[(]%b"",%s*"(...)',
	}
})

register_atlatc_env("Crossroads", {
	station_names = {
		cg               = "Colored Grasses",
		clockwise        = "Clockwise Route",
		counterclockwise = "Counterclockwise Route",
		cras             = "Crossroads ARSE7's Shop",
		crbfost          = "Crossroads Station East",
		crbfsm           = "Crossroads Station St. Central",
		crbfso           = "Crossroads Station St. East",
		crbfsw           = "Crossroads Station St. West",
		crch             = "Crossroads City Hall",
		crchs            = "Crossroads City Hall South",
		crmtrail         = "Crossroads Mountain Railway Terminus",
		crnsw            = "CR North Station St. 9th Alley",
		crrathaus        = "Crossroads City Hall",
		crsmacker        = "Crossroads Smacker's Station",
		crwm             = "Crossroads West Mountains",
		crzn             = "Crossroads Central/North",
		elchateau        = "Erstaziland-Chateau d'Erstazi",
		elgp             = "Erstaziland-Greener Pastures",
		elsf             = "Erstaziland-Salt Factory",
		evo              = "EVO",
		mushroom         = "Mushroom Land",
		neverbuild       = "Neverbuild",
		nvbcentral       = "Neverbuild Central",
		nvbold           = "Neverbuild Old Terminus",
		nvboutskirts     = "Neverbuild Outskirts",
		oc               = "Ocean City",
		occh             = "Ocean City City Hall",
		occrt            = "Ocean City CRT Office",
		ocmushroom       = "Ocean City Mushroom Market",
		ocoutskirts      = "Ocean City Outskirts",
		phsc             = "Personhood Southern Crossing",
		phwest           = "Personhood West",
		scc              = "Silver Coast Central",
		scn              = "Silver Coast North",
		scs              = "Silver Coast South",
		thecube          = "The Cube",
	},
	stop_patterns = {
		'F.stn2gen%s*[(]%s*"([^"]+)"',
		"F.stn2gen%s*[(]%s*'([^']+)'",
		'F.stnbasic%s*[(]%s*"([^"]+)"',
		"F.stnbasic%s*[(]%s*'([^']+)'",
		'F.hst%s*[(]%s*"([^"]+)"',
		"F.hst%s*[(]%s*'([^']+)'",
		'F.k?bhf%s*[(]"%s*([^"]+)"',
		"F.k?bhf%s*[(]'%s*([^']+)'"
		--F.timing is not used anywhere. Also, exponential explosion of patterns to support '' or "" for args.
	}
})

--[[Environment	Station Function
durt	F.station(string code, string direction)
subway	F.stn(string prev, string this, string next, string doors) --ordinary station (origin U2)
subway	F.stn_ilk(string prev, string this, string next) --interlocked station (origin U1/4), previous station was station/stop track
subway	F.stn_return(string prev, string this, string next, string doors, string switchpos, string switchdir)
Crossroads	F.stnbasic(stn, side, optime, reverse, acc, out, reventry, predepart, postdepart, next,track)
Crossroads	F.hst(cur, nxt, side, spd, out, trk)
Crossroads	F.bhf(cur, nxt, side, spd, out, trk)
Crossroads	F.kbhf(cur, nxt, side, spd, out, trk)
Crossroads	F.timing(d_off, d_int, cur, nxt, side, spd, out, trk, term, pre, post)
Crossroads	F.stn2gen(stn, trk, door, ret, chout)
Note: 'Crossroads' environment also manages ATL
Note: OTL is interlocking and station tracks only

-- Register a lua environment
-- Register an array of station codes to env, where key is the station code and value is the name
-- Register pattern matches for station codes, where key is not important and value is the pattern string, where pattern matching returns the code for lookup
-- env must exist in the data files
register_atlatc_station_names(env, stations)
register_atlatc_stops(env, patterns)
--]]

local function atlatc_nameat(posData)
	-- If the pos does not exist as an atlatc rail, quit
	if not (posData.arrowconn and posData.env) then return end
	local env = posData.env
	-- Quit if it's an unregistered env
	if not atlatc_envs[posData.env] then return nil end
	local code = posData.code
	local matches
	for _, pattern in pairs(atlatc_envs[env].stop_patterns) do
		codeMatched = code:match(pattern)
		if codeMatched then
			return atlatc_envs[env].station_names[codeMatched]
		end
	end
	return nil
end

function atlatc_parse_database(activeNodeData)
	local atlatc_station_names = {}
	local formatStrCircle = '<circle cx="%d" cy="%d" r="3" stroke="blue" stroke-width="2" fill="black" />\n'
	local formatStrText = '<text x="%d" y="%d" transform="rotate(45,%d, %d)" class="stop">%s</text>\n'
	for pos, posData in pairs(activeNodeData) do
		--dbg()
		local x,y,z = pos:match("(-?%d+),(-?%d+),(-?%d+)")
		x = tonumber(x)
		y = tonumber(y)
		z = tonumber(z)
		local name = atlatc_nameat(posData)
		if (x and y and z and name ~= nil) then
			table.insert(atlatc_station_names, formatStrCircle:format(x, -z))
			table.insert(atlatc_station_names, formatStrText:format(x, -z, x, -z, name))
		end
	end
	return atlatc_station_names
end

return atlatc_parse_database
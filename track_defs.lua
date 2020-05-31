--== Insert track defs here! ==--
-- Default tracks for advtrains
-- (c) orwell96 and contributors

--flat
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack",
	texture_prefix="advtrains_dtrack",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_shared.png",
	description=attrans("Track"),
	formats={},
}, advtrains.ap.t_30deg_flat)
--slopes
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack",
	texture_prefix="advtrains_dtrack",
	models_prefix="advtrains_dtrack",
	models_suffix=".obj",
	shared_texture="advtrains_dtrack_shared.png",
	second_texture="default_gravel.png",
	description=attrans("Track"),
	formats={vst1={true, false, true}, vst2={true, false, true}, vst31={true}, vst32={true}, vst33={true}},
}, advtrains.ap.t_30deg_slope)

--bumpers
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_bumper",
	texture_prefix="advtrains_dtrack_bumper",
	models_prefix="advtrains_dtrack_bumper",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_rail.png",
	--bumpers still use the old texture until the models are redone.
	description=attrans("Bumper"),
	formats={},
}, advtrains.ap.t_30deg_straightonly)



-- atc track
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_atc",
	texture_prefix="advtrains_dtrack_atc",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_shared_atc.png",
	description=attrans("ATC controller"),
	formats={},
	get_additional_definiton = advtrains.atc_function
}, advtrains.trackpresets.t_30deg_straightonly)

advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_unload",
	texture_prefix="advtrains_dtrack_unload",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_shared_unload.png",
	description=attrans("Unloading Track"),
	formats={},
	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
		   after_dig_node=function(pos)
		      advtrains.invalidate_all_paths()
		      advtrains.ndb.clear(pos)
		   end,
		   advtrains = {
		      on_train_enter = function(pos, train_id)
			 train_load(pos, train_id, true)
		      end,
		   },
		}
	end
				     }, advtrains.trackpresets.t_30deg_straightonly)
advtrains.register_tracks("default", {
	nodename_prefix="advtrains:dtrack_load",
	texture_prefix="advtrains_dtrack_load",
	models_prefix="advtrains_dtrack",
	models_suffix=".b3d",
	shared_texture="advtrains_dtrack_shared_load.png",
	description=attrans("Loading Track"),
	formats={},
	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
		   after_dig_node=function(pos)
		      advtrains.invalidate_all_paths()
		      advtrains.ndb.clear(pos)
		   end,

		   advtrains = {
		      on_train_enter = function(pos, train_id)
			 train_load(pos, train_id, false)
		      end,
		   },
		}
	end
				     }, advtrains.trackpresets.t_30deg_straightonly)


	advtrains.register_tracks("default", {
		nodename_prefix="advtrains:dtrack_detector_off",
		texture_prefix="advtrains_dtrack_detector",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_dtrack_shared_detector_off.png",
		description=attrans("Detector Rail"),
		formats={},
		get_additional_definiton = function(def, preset, suffix, rotation)
			return {
				mesecons = {
					receptor = {
						state = mesecon.state.off,
						rules = advtrains.meseconrules
					}
				},
				advtrains = {
					on_train_enter=function(pos, train_id)
						advtrains.ndb.swap_node(pos, {name="advtrains:dtrack_detector_on".."_"..suffix..rotation, param2=advtrains.ndb.get_node(pos).param2})
						mesecon.receptor_on(pos, advtrains.meseconrules)
					end
				}
			}
		end
	}, advtrains.ap.t_30deg_straightonly)
	advtrains.register_tracks("default", {
		nodename_prefix="advtrains:dtrack_detector_on",
		texture_prefix="advtrains_dtrack",
		models_prefix="advtrains_dtrack",
		models_suffix=".b3d",
		shared_texture="advtrains_dtrack_shared_detector_on.png",
		description="Detector(on)(you hacker you)",
		formats={},
		get_additional_definiton = function(def, preset, suffix, rotation)
			return {
				mesecons = {
					receptor = {
						state = mesecon.state.on,
						rules = advtrains.meseconrules
					}
				},
				advtrains = {
					on_train_leave=function(pos, train_id)
						advtrains.ndb.swap_node(pos, {name="advtrains:dtrack_detector_off".."_"..suffix..rotation, param2=advtrains.ndb.get_node(pos).param2})
						mesecon.receptor_off(pos, advtrains.meseconrules)
					end
				}
			}
		end
	}, advtrains.ap.t_30deg_straightonly_noplacer)
	

-- Linetrack watertrack
advtrains.register_tracks("waterline", {
	nodename_prefix="linetrack:watertrack",
	texture_prefix="advtrains_ltrack",
	models_prefix="advtrains_ltrack",
	models_suffix=".obj",
	shared_texture="linetrack_line.png",
	description=attrans("Water Line Track"),
	formats={},
	liquids_pointable=true,
	suitable_substrate=suitable_substrate,
	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
			groups = {
				advtrains_track=1,
				advtrains_track_waterline=1,
				save_in_at_nodedb=1,
				dig_immediate=2,
				not_in_creative_inventory=1,
				not_blocking_trains=1,
			},
			use_texture_alpha = true,
		}
	end
}, advtrains.ap.t_30deg_flat)
--slopes
advtrains.register_tracks("waterline", {
	nodename_prefix="linetrack:watertrack",
	texture_prefix="advtrains_ltrack",
	models_prefix="advtrains_ltrack",
	models_suffix=".obj",
	shared_texture="linetrack_line.png",
	description=attrans("Line Track"),
	formats={vst1={true, false, true}, vst2={true, false, true}, vst31={true}, vst32={true}, vst33={true}},
	liquids_pointable=true,
	suitable_substrate=suitable_substrate,
	get_additional_definiton = function(def, preset, suffix, rotation)
		return {
			groups = {
				advtrains_track=1,
				advtrains_track_waterline=1,
				save_in_at_nodedb=1,
				dig_immediate=2,
				not_in_creative_inventory=1,
				not_blocking_trains=1,
			},
			use_texture_alpha = true,
		}
	end
}, advtrains.ap.t_30deg_slope)
--== END insert track defs ==--

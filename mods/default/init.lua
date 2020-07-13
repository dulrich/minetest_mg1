-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.

-- The API documentation in here was moved into game_api.txt

-- Load support for MT game translation.
local S = minetest.get_translator("default")

-- Definitions made by this mod that other mods can use too
default = {
	deepest_fill = 1,
	
	biomes = {},
	failsafe_biome = nil,
	failsafe_stone_biome = nil,
	ores = {},
	stone_biomes = {},
	surface_decorations = {},
	surface_ores = {}, -- NOT IMPLEMENTED
	
	cold = { -- all in degrees C
		base_temp = 10,
		lat_variation = 80,
		day_variation = 15,
		season_variation = 20,
		deg_per_meter = 0.1,
		max_elev = 300,
	},
}

default.LIGHT_MAX = 14
default.get_translator = S

-- GUI related stuff
minetest.register_on_joinplayer(function(player)
	-- Set formspec prepend
	local formspec = [[
			bgcolor[#080808BB;true]
			listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF] ]]
	local name = player:get_player_name()
	local info = minetest.get_player_information(name)
	if info.formspec_version > 1 then
		formspec = formspec .. "background9[5,5;1,1;gui_formbg.png;true;10]"
	else
		formspec = formspec .. "background[5,5;1,1;gui_formbg.png;true]"
	end
	player:set_formspec_prepend(formspec)

	-- Set hotbar textures
	player:hud_set_hotbar_image("gui_hotbar.png")
	player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")
end)

function default.get_hotbar_bg(x,y)
	local out = ""
	for i=0,7,1 do
		out = out .."image["..x+i..","..y..";1,1;gui_hb_bg.png]"
	end
	return out
end

default.gui_survival_form = "size[8,8.5]"..
			"list[current_player;main;0,4.25;8,1;]"..
			"list[current_player;main;0,5.5;8,3;8]"..
			"list[current_player;craft;1.75,0.5;3,3;]"..
			"list[current_player;craftpreview;5.75,1.5;1,1;]"..
			"image[4.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
			"listring[current_player;main]"..
			"listring[current_player;craft]"..
			default.get_hotbar_bg(0,4.25)

-- Load files
local modpath = minetest.get_modpath("default")




minetest.register_on_mods_loaded(function()
-- 	print("mapgen init")
	for _,def in pairs(default.biomes) do
		
		default.deepest_fill = math.max(default.deepest_fill, def.fill_max + 1)
		
		def.surface_decos = {}
		def.surface_ores = {}
		
-- 		print(dump(def))
		def.cids = {
			cover = {},
			chance_cover = {},
			fill = {},
			chance_fill = {},
		}
		
		for i,v in ipairs(def.cover) do
			if type(v) == "string" then
				table.insert(def.cids.cover, minetest.get_content_id(v))
			else
				def.cids.chance_cover[i] = {
					chance = v.chance,
					cid = minetest.get_content_id(v.name),
				}
			end
		end
		for i,v in ipairs(def.fill) do
			if type(v) == "string" then
				table.insert(def.cids.fill, minetest.get_content_id(v))
			else
				def.cids.chance_fill[i] = {
					chance = v.chance,
					cid = minetest.get_content_id(v.name),
				}
			end
		end
		
-- 		print(dump(def))
		
	end
	
	local def = default.failsafe_biome
	def.surface_decos = {}
	def.surface_ores = {} -- NOT IMPLEMENTED
	def.cids = {
		cover = {},
		chance_cover = {},
		fill = {},
		chance_fill = {},
	}
	
	for i,v in ipairs(def.cover) do
		if type(v) == "string" then
			table.insert(def.cids.cover, minetest.get_content_id(v))
		else
			def.cids.chance_cover[i] = {
				chance = v.chance,
				cid = minetest.get_content_id(v.name),
			}
		end
	end
	for i,v in ipairs(def.fill) do
		if type(v) == "string" then
			table.insert(def.cids.fill, minetest.get_content_id(v))
		else
			def.cids.chance_fill[i] = {
				chance = v.chance,
				cid = minetest.get_content_id(v.name),
			}
		end
	end
	
	
	
	-- pre-process surface decorations
	for k,deco in pairs(default.surface_decorations) do
		
		-- cache content id's
		deco.cids = {
			place = {},
		}
		
		for i,v in ipairs(deco.place) do
			deco.cids.place[i] = minetest.get_content_id(v)
		end
		
		
		-- fill decorations into biomes
		for _,biome_name in ipairs(deco.biomes) do
			local bio = default.biomes[biome_name]
			if not bio then
				print("Unknown biome '"..biome_name.."' in decoration '"..deco.name.."'.")
			else
				bio.surface_decos[deco.name] = deco
			end
		end
	end
	
	--[[ NOT IMPLEMENTED
	-- pre-process surface ores
	for k,ore in pairs(default.surface_ores) do
		
		-- cache content id's
		ore.cids = {
			place = {},
		}
		
		for i,v in ipairs(ore.place) do
			ore.cids.place[i] = minetest.get_content_id(v)
		end
		
		-- NOT IMPLEMENTED
		-- fill decorations into biomes
		for _,biome_name in ipairs(ore.biomes) do
			local bio = default.biomes[biome_name]
			if not bio then
				print("Unknown biome '"..biome_name.."' in surface ore '"..ore.name.."'.")
			else
				bio.surface_ores[ore.name] = ore
			end
		end
	end
	]]
	
	
	--
	-- stone biomes
	--
	
	for _,def in pairs(default.stone_biomes) do
		
		def.ores = {}
		--[[
-- 		print(dump(def))
		def.cids = {
			cover = {},
			fill = {},
		}
		
		for i,v in ipairs(def.cover) do
			def.cids.cover[i] = minetest.get_content_id(v)
		end
		for i,v in ipairs(def.fill) do
			def.cids.fill[i] = minetest.get_content_id(v)
		end
		]]
	end
	
	default.failsafe_stone_biome.ores = {}
	
	-- pre-process ore registratoins
	for k,ore in pairs(default.ores) do
		
		-- fill ores into biomes
		if ore.stone_biomes == "*" then
		print("all is all: ".. ore.name)
			for _,bio in pairs(default.stone_biomes) do
				print(" sbio: "..bio.name) 
				bio.ores[ore.name] = ore
			end
		else
			
			for _,biome_name in ipairs(ore.stone_biomes) do
				local bio = default.stone_biomes[biome_name]
				if not bio then
					print("Unknown stone biome '"..biome_name.."' in ore '"..ore.name.."'.")
				else
					bio.ores[ore.name] = ore
				end
			end
		end
	end
end)


function default.get_elev_temp_factor(y)
	local y2 = math.max(0, math.min(pos.y, default.cold.max_elev))
	return -(y2 * default.cold.deg_per_meter)
end


function default.get_temp(pos)
	local y = math.max(0, math.min(pos.y, default.cold.max_elev))
	local elev_factor = -(y * default.cold.deg_per_meter)
	
	local lat = math.abs(pos.z)
	local lat_factor = (math.cos((math.pi / 31000) * lat) - 1) * 0.5 * default.cold.lat_variation
	
	local time = minetest.get_timeofday()
	local day_factor = math.sin(math.pi * time) * default.cold.day_variation
	
	local season_factor = math.sin(math.pi * default.get_timeofyear()) * default.cold.season_variation
-- 	print("  ")
-- 	print("  day factor: ".. day_factor)
-- 	print("  ele factor: ".. elev_factor)
-- 	print("  lat factor: ".. lat_factor)
-- 	print("  sea factor: ".. season_factor)
	return default.cold.base_temp + elev_factor + lat_factor + day_factor + season_factor
end


default.register_biome = function(def)
-- 	print("registering biome")
	if def.name == "failsafe" then
		default.failsafe_biome = def
	else
		default.biomes[def.name] = def
	end
end


default.select_biome = function(x, y, z, heat, humidity, magic, flatness)
-- 	print("   y="..y)
	local best = nil
	local best_d = 99999999999999999999
	
	for _,def in pairs(default.biomes) do
		local y_r = y + math.random(-def.y_rand, def.y_rand) 
-- 		print(def.name.." "..y_r.. " "..def.y_min.. " "..def.y_max )
		if def.y_min <= y_r and def.y_max >= y_r then
			local he = heat - def.heat
			local hu = humidity - def.humidity
			local ma = magic - def.magic
			local fl = flatness - def.flatness
			local la = math.abs(z / 320) - def.lat_center 
			local d = he * he + hu * hu + ma * ma + fl * fl + la * la
			
-- 			print(" "..def.name.. " d: "..d)
			if d < best_d then
				
				best = def
				best_d = d
			end
		end
	end
	
	local b = best or default.failsafe_biome
-- 	print("  "..b.name)
	return b
end


default.register_stone_biome = function(def)
-- 	print("registering biome")
	if def.noise then
		def.noise.offset = 0.4
		def.noise.scale = 0.4
	end

	if def.name == "failsafe" then
		default.failsafe_stone_biome = def
	else
		default.stone_biomes[def.name] = def
	end
end


default.select_stone_biome = function(x, y, z, heat, humidity, magic, flatness, vulcanism)
-- 	print("   y="..y)
	local best = nil
	local best_d = 99999999999999999999
	
	for _,def in pairs(default.stone_biomes) do
		local y_r = y + math.random(-def.y_rand, def.y_rand) 
-- 		print(def.name.." "..y_r.. " "..def.y_min.. " "..def.y_max )
		if def.y_min <= y_r and def.y_max >= y_r then
			local he = heat - def.heat
			local hu = humidity - def.humidity
			local ma = magic - def.magic
			local fl = flatness - def.flatness
			local vu = vulcanism - def.vulcanism
			local la = math.abs(z / 320) - def.lat_center 
			local d = he*he + hu*hu + ma*ma + fl*fl + la*la + vu*vu
			
-- 			print(" "..def.name.. " d: "..d)
			if d < best_d then
				
				best = def
				best_d = d
			end
		end
	end
	
	local b = best or default.failsafe_stone_biome
-- 	print("  "..b.name)
	return b
end



default.register_surface_deco = function(def)
	
	-- todo: fill in missing defaults
	-- TODO: warnings for invalid data
	
	if def.noise then
		def.noise.offset = 0.4
		def.noise.scale = 0.4
	end
	
	default.surface_decorations[def.name] = def
end


-- NOT IMPLEMENTED
default.register_surface_ore = function(def)
	
	-- todo: fill in missing defaults
	-- TODO: warnings for invalid data
	
	if def.noise then
		def.noise.offset = 0.4
		def.noise.scale = 0.4
	end
	
	default.surface_ores[def.name] = def
end



default.register_ore = function(def)
-- 	print("registering ore")
	if def.noise then
		def.noise.offset = 0
		def.noise.scale = 1
	end
	if def.noise_1 then
		def.noise_1.offset = 0
		def.noise_1.scale = 1
	end
	if def.noise_2 then
		def.noise_2.offset = 0
		def.noise_2.scale = 1
	end

	default.ores[def.name] = def
end



-- temp

minetest.register_tool("default:axe_steel", {
	description = "Steel Axe",
	inventory_image = "default_tool_steelaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level=1,
		groupcaps={
			choppy={times={[1]=2.50, [2]=1.40, [3]=1.00}, uses=20, maxlevel=2},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {axe = 1}
})




minetest.register_node("default:lake_magic", {
	description = "Lake Magic Block",
	tiles = {"default_snow.png"},
	groups = {crumbly = 3, cools_lava = 1, snowy = 1},
	on_timer = function(pos)
		minetest.set_node(pos, {name = "default:lake_water_source"})
	end
})

minetest.register_abm({
	nodenames = {"default:lake_magic"},
	neighbors = {"air"},
	interval  = 1,
	chance = 1,
	catch_up = true,
	action = function(pos, node)
		
		local n
		
		while 1==1 do
			n = minetest.get_node({x=pos.x+1, y=pos.y, z=pos.z})
			if n.name == "air" then break end
			
			n = minetest.get_node({x=pos.x-1, y=pos.y, z=pos.z})
			if n.name == "air" then break end
			
			n = minetest.get_node({x=pos.x, y=pos.y, z=pos.z+1})
			if n.name == "air" then break end
			
			n = minetest.get_node({x=pos.x, y=pos.y, z=pos.z-1})
			if n.name == "air" then break end
			
			local timer = minetest.get_node_timer(pos)
			if not timer:is_started() then
				timer:start(15)
			end
			
			return
		end
		
		minetest.set_node(pos, {name="air"})
	end,
})


minetest.register_abm({
	nodenames = {"default:lake_magic"},
	neighbors = {"default:lake_water_source"},
	interval  = 1,
	chance = 1,
	catch_up = true,
	action = function(pos, node)
		minetest.set_node(pos, {name="default:lake_water_source"})
		
		pos.y = pos.y - 1
		local n = minetest.get_node(pos)
		if n.name ~= "air" 
			and n.name ~= "default:lake_water_source" 
			and n.name ~= "default:lake_magic" 
		then
			minetest.set_node(pos, {name="default:wet_sand"})
		end
		
	end
})






-- /temp



dofile(modpath.."/functions.lua")
dofile(modpath.."/water.lua")
dofile(modpath.."/seasons.lua")
dofile(modpath.."/player.lua")

dofile(modpath.."/biomes.lua")
dofile(modpath.."/surface_deco.lua")
dofile(modpath.."/ores.lua")
dofile(modpath.."/trees.lua")
dofile(modpath.."/trees/aspen.lua")
dofile(modpath.."/trees/birch.lua")
dofile(modpath.."/trees/fir.lua")

dofile(modpath.."/casting.lua")

--[[
dofile(default_path.."/trees.lua")
dofile(default_path.."/nodes.lua")
dofile(default_path.."/chests.lua")
dofile(default_path.."/furnace.lua")
dofile(default_path.."/torch.lua")
dofile(default_path.."/tools.lua")
dofile(default_path.."/item_entity.lua")
dofile(default_path.."/craftitems.lua")
dofile(default_path.."/crafting.lua")
dofile(default_path.."/mapgen.lua")
dofile(default_path.."/aliases.lua")
dofile(default_path.."/legacy.lua")
--]]

dofile(modpath.."/soil.lua")
dofile(modpath.."/stone.lua")


local S = default.get_translator


-- greensand is "green" in the sense of "green wood" in that it's not dried and fired.
minetest.register_node("default:greensand", {
	description = S("Green Sand"),
	tiles = {"default_sand.png^[colorize:black:10"},
-- 		tiles = {"default_stone.png^[colorize:"..colors[def.t]..":"..i*15},
	groups = {crumbly = 3, sand = 1, green_sand = 1, },
-- 	sounds = default.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "default:greensand 9",
	type = "shapeless",
	recipe = {
		"group:wet_clay",
		"group:wet_sand",
		"group:wet_sand",
		"group:wet_sand",
		"group:wet_sand",
		"group:wet_sand",
		"group:wet_sand",
		"group:wet_sand",
		"group:wet_sand",
	},
})



-- molds
local mold_types = {
	"ingots",
	"axehead",
	"pickhead",
	"chisel",
	"hammerhead",
}

for _,v in ipairs(mold_types) do
	minetest.register_node("default:sandmold_"..v, {
		description = S(v.." Sand Mold"),
		tiles = {"default_sand.png^[colorize:black:10"},
		drawtype = "nodebox",
		node_box = {
			type="fixed",
			fixed = {
				{-0.5, -0.5, -0.5,  0.5,  0,    0.5},
				{-0.5,    0, -0.5,  0.5,  0.2, -0.4},
				{-0.5,    0,  0.4,  0.5,  0.2,  0.5},
				
				{-0.5,  0.0,  -0.4,  -0.4,  0.2,  0.4},
				{-0.3,  0.0,  -0.4,  -0.2,  0.2,  0.4},
				{-0.1,  0.0,  -0.4,   0.1,  0.2,  0.4},
				{ 0.3,  0.0,  -0.4,   0.2,  0.2,  0.4},
				{ 0.5,  0.0,  -0.4,   0.4,  0.2,  0.4},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0.2, 0.5},
		},
	-- 		tiles = {"default_stone.png^[colorize:"..colors[def.t]..":"..i*15},
		groups = {crumbly = 3, sand = 1, },
	-- 	sounds = default.node_sound_stone_defaults(),
	})
end











local mold_formspec = "size[8,9]"..
		"list[context;main;.25,.25;1,1;]"..
		"list[context;output;1.5,.25;6,4;]"..
		"list[current_player;main;0,4.75;8,1;]"..
		"list[current_player;main;0,6.0;8,3;8]"..
		"listring[context;main]"..
		"listring[current_player;main]"..
		"listring[context;output]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 4.75)


minetest.register_node("default:molding_bench", {
	description = S("Molding Bench"),
	tiles = {"default_pine_wood.png"},
	drawtype = "nodebox",
	node_box = {
		type="fixed",
		fixed = {
			-- legs
			{-0.5, -0.5, -0.5, -0.4,  0, -0.4},
			{ 0.5, -0.5,  0.5,  0.4,  0,  0.4},
			{-0.5, -0.5,  0.5, -0.4,  0,  0.4},
			{ 0.5, -0.5, -0.5,  0.4,  0, -0.4},
			
			-- table
			{-0.5, 0.0, -0.5, 0.5,  0.05, 0.5},
			
			-- box sides
			{-0.45, -0.0, -0.5, -0.40, 0.3, 0.5},
			{ 0.4, -0.0, -0.5,  0.45, 0.3, 0.5},
			{-0.5,  -0.0, -0.45,  0.5, 0.3, -0.4},
			{-0.5,  -0.0,   0.4,  0.5, 0.3, 0.45},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.3, 0.5},
	},
	
	paramtype1 = "light",
	
	groups = {oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),

	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('main', 1)
		inv:set_size('output', 6*4)
		meta:set_string("formspec", mold_formspec)
	end,

	on_metadata_inventory_put = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		
		local input = inv:get_stack("main", 1)
		local avail = (input and input:get_count()) or 0 
		
		if avail > 0 then
			for i,mn in pairs(mold_types) do
				inv:set_stack('output', i, "default:sandmold_"..mn.." "..avail)
			end
		else
			inv:set_list("main", {})
			inv:set_list("output", {})
		end
		
	end,
	
	
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local input = inv:get_stack("main", 1)
		local avail = (input and input:get_count()) or 0 
		local taken = stack:get_count()
			
		local remain = avail - taken
		
		if listname == "output" then
			if remain == 0 then
				inv:set_list("main", {})
				inv:set_list("output", {})
				return
			end
			
			input:set_count(remain)
			inv:set_stack("main", 1, input)
			for i,mn in pairs(mold_types) do
				inv:set_stack('output', i, "default:sandmold_"..mn.." "..remain)
			end
			
		elseif listname == "main" then
			
			if remain > 0 then
				for i,mn in pairs(mold_types) do
					inv:set_stack('output', i, "default:sandmold_"..mn.." "..remain)
				end
			else
				inv:set_list("main", {})
				inv:set_list("output", {})
			end
		end
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end
		
		-- only greensand
		local iname = stack:get_name()
		local g = minetest.registered_items[iname]
		if not g.groups.green_sand then
			return 0
		end
		
		-- only into the input
		if listname == "main" then
			return stack:get_count()
		else
			return 0
		end
	end,
	
	allow_metadata_inventory_move = function()
		return 0
	end,
	
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if minetest.is_protected(pos, player:get_player_name()) then
			return 0
		end

		return stack:get_count()
	end,
})





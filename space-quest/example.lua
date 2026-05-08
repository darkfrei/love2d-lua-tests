return {
	id = "derelict_station",
	start_node = "hub",
	variables = {
		credits = 120, 
		fuel = 45, 
		oxygen = 80,
		has_override_key = false, 
		comms_repaired = false,
		threat_level = 0, 
		player_name = "Hash Astro",
		siphon_count = 0, 
		salvage_count = 0,
		sector_scan_count = 0, 
		bridge_scan_count = 0
	},

	shared_conditions = {
		has_fuel       = {"<fuel>",             ">=", 10},
		has_credits    = {"<credits>",          ">=", 50},
		has_fuel_30    = {"<fuel>",             ">=", 30},
		oxygen_low     = {"<oxygen>",           "<",  30},
		comms_active   = {"<comms_repaired>",   "==", true},
		comms_inactive = {"<comms_repaired>",   "==", false},
		key_owned      = {"<has_override_key>", "==", true},
		key_missing    = {"<has_override_key>", "==", false},
		threat_high    = {"<threat_level>",     ">",  5},
		fuel_not_full  = {"<fuel>",             "<",  100},
		siphon_limit   = {"<siphon_count>",     "<",  3},
		salvage_limit  = {"<salvage_count>",    "<",  3},
		scan_limit     = {"<sector_scan_count>","<",  2},
		bridge_limit   = {"<bridge_scan_count>","<",  2}
	},

	shared_effects = {
		repair_comms = { 
			{"<comms_repaired>", "=", true}, 
			{"<credits>", "-=", 30} 
		},
		siphon_fuel  = {
			{"<fuel>", "+=", 25},
			{"<fuel>", "=", {"?", {"<fuel>", ">", 100}, 100, "<fuel>"}},
			{"<threat_level>", "+=", 2},
			{"<siphon_count>", "+=", 1}
		},
		rest_quarters = { 
			{"<oxygen>", "+=", 15}, 
			{"<credits>", "-=", 10} 
		},
		salvage_parts = { 
			{"<credits>", "+=", 40}, 
			{"<salvage_count>", "+=", 1} 
		},
		sector_scan   = { 
			{"<threat_level>", "+=", 1}, 
			{"<fuel>", "-=", 10}, 
			{"<sector_scan_count>", "+=", 1} 
		},
		bridge_scan   = { 
			{"<threat_level>", "+=", 3}, 
			{"<bridge_scan_count>", "+=", 1} 
		},
		force_locker  = { 
			{"<has_override_key>", "=", true}, 
			{"<threat_level>", "+=", 1} 
		}
	},

	shared_snippets = {
		power_status = {"?", "has_fuel",     "Reactor output: **stable**.",      "Reactor output: **critical**."},
		comms_status = {"?", "comms_active", "Long-range comms: **online**.",    "Long-range comms: **offline**."},
		threat_level_snip  = "Threat Level: <threat_level>"
	},

	shared_stats = {
		global = {
			"Crew: <player_name>",
			"Credits: <credits>",
			"Fuel: <fuel>%",
			"Oxygen: <oxygen>%",
--			"Threat Level: <threat_level>",
			{"snippet", "threat_level_snip"},
--			{"?", {"<threat_level>", ">", 5}, "Alert Status: **CRITICAL**", "Alert Status: Normal"}
			{"?", "threat_high", "Alert Status: ==CRITICAL==", "Alert Status: Normal"}
		}
	},

	shared_choices = {
		global_rest = {
			label    = "Rest and let the scrubbers cycle (+15 oxygen, -10 credits)",
			visible  = {"<oxygen>", "<", 90},
			enabled  = "has_credits",
			priority = 2, once = true,
			effects  = "rest_quarters",
			transition = { text = {"Scrubbers ran a full cycle. Breathing easier. **Oxygen +15. Credits -10.**"}, target = "hub" }
		},
		return_hub = {
			label    = "Head back to the Central Hub",
			priority = 10,
			transition = { target = "hub" }
		}
	},

	nodes = {
		{
			id = "hub",
			text = {
				"The ==Central Hub== hums with residual power. ",
				{"snippet", "power_status"},
				"\nEmergency lights cast long shadows across the grating. ",
				{"snippet", "comms_status"}
			},
			stats = { "global", "Location: Central Hub", {"?", "key_owned", "Override Key: **Obtained**", "Override Key: Missing"} },
			choices = {
				"global_rest",
				{ id = "go_engineering", label = "Head to Engineering Bay",       priority = 0, transition = { target = "engineering" } },
				{ id = "go_comms",       label = "Check Communications Array",    priority = 0, transition = { target = "comms_room" } },
				{ id = "go_quarters",    label = "Search Captain's Quarters",     priority = 0, transition = { target = "captain_quarters" } },
				{ id = "go_bridge",      label = "Access the Command Bridge",     priority = 1, visible = "key_owned", transition = { target = "bridge" } }
			}
		},
		{
			id = "engineering",
			text = {
				"Sparks rain from severed conduits. The main reactor cycles unevenly. ",
				{"snippet", "power_status"},
				"\nA damaged fuel siphon sits near the auxiliary bay."
			},
			stats = { "global", "Location: Engineering Bay", "Reactor: ==Unstable==" },
			choices = {
				{
					id = "siphon", label = "Siphon fuel from auxiliary tanks (+25 fuel, +2 threat)",
					visible = "fuel_not_full", enabled = "siphon_limit", priority = 0,
					effects = "siphon_fuel",
					transition = { text = {"Auxiliary reserves drained. Threat sensors tripped. **Fuel: <fuel>%.**"}, target = "engineering" }
				},
				{
					id = "salvage", label = "Salvage spare parts from wreckage (+40 credits)",
					visible = "salvage_limit", priority = 1,
					effects = "salvage_parts",
					transition = { text = {"Stripped usable components from the debris. **Credits: <credits>.**"}, target = "engineering" }
				},
				"global_rest",
				"return_hub"
			}
		},
		{
			id = "comms_room",
			text = {
				"The comms console is dark. Dust coats the frequency dials. ",
				{"snippet", "comms_status"},
				"\nA technician's datapad lies cracked on the floor. Credits amount: <credits>"
			},
			stats = { "global", "Location: Communications Array", {"?", "comms_active", "Signal: **Active**", "Signal: ==Dead=="} },
			choices = {
				{
					id = "repair_comms", label = "Repair the array using salvaged parts (-30 credits)",
					visible = "comms_inactive", enabled = "has_credits", priority = 0,
					effects = "repair_comms",
					transition = { text = {"Array recalibrated. Signal lock established. **Credits: <credits>.**"}, target = "comms_room" }
				},
				{
					id = "scan_sector", label = "Run a sector sweep (-10 fuel, +1 threat)",
					visible = "comms_active", enabled = "scan_limit", priority = 1,
					effects = "sector_scan",
					transition = { text = {"Sweep complete. Something noticed the signal. **Threat: <threat_level>.**"}, target = "comms_room" }
				},
				"global_rest",
				"return_hub"
			}
		},
		{
			id = "captain_quarters",
			text = {
				"The door hisses open. Personal effects are scattered across the floor. ",
				{"?", "key_owned", "The override locker stands open — already emptied.", "A secured locker glows with soft blue light. **Override key inside.**"}
			},
			stats = { "global", "Location: Captain's Quarters", {"?", "key_owned", "Locker: ==Opened==", "Locker: **Secured**"} },
			choices = {
				{
					id = "force_locker", label = "Exploit the alert chaos to force the locker (+1 threat)",
					visible = "key_missing", enabled = "threat_high", priority = 0,
					effects = "force_locker",
					transition = { text = {"Lockout bypassed under cover of the active alert. Override key retrieved. **Threat: <threat_level>.**"}, target = "captain_quarters" }
				},
				{
					id = "read_log", label = "Attempt to decrypt the captain's personal log",
					once = true, priority = 1,
					transition = { text = {"Most data is corrupted. One fragment surfaces: *'They are in the walls...'*"}, target = "captain_quarters" }
				},
				"global_rest",
				"return_hub"
			}
		},
		{
			id = "bridge",
			text = {
				"The Command Bridge overlooks the derelict sector. Navigation consoles blink in standby. ",
				{"snippet", "power_status"},
				"\nThe captain's chair faces a star chart marked with red zones."
			},
			stats = { "global", "Location: Command Bridge", "Command Codes: ==Accepted==", "Nav Computer: Online" },
			choices = {
				{
					id = "set_course", label = "Plot a course to the nearest safe zone",
					enabled = "has_fuel_30", priority = 0,
					transition = { text = {"Course locked. Engines spooling up. **Prepare for departure.**"}, target = "escape_pod_bay" }
				},
				{
					id = "bridge_scan", label = "Run long-range deep scans (+3 threat)",
					visible = "bridge_limit", priority = 1,
					effects = "bridge_scan",
					transition = { text = {"Massive structure detected at sector edge. It is moving toward us. **Threat: <threat_level>.**"}, target = "bridge" }
				},
				"global_rest",
				"return_hub"
			}
		},
		{
			id = "escape_pod_bay",
			text = {
				"The bay doors grind open. A single escape pod hums with standby power. ",
				"You strap in and run through the launch checklist. **All systems nominal.**"
			},
			stats = { "global", "Location: Escape Pod Bay", "Pod Status: **Ready**" },
			choices = {
				{
					id = "launch", label = "Initiate launch sequence",
					priority = 0, consumed = true,
					transition = { text = {"Clamps released. The station shrinks behind you. **Stars streak past the viewport.**"}, target = "victory" }
				},
				"return_hub"
			}
		},
		{
			id = "victory",
			text = {
				"**==MISSION COMPLETE==**\n",
				"The escape pod drifts into open space. You made it out alive."
			},
			stats = { "global", "Status: ==Safe==", "Destination: ==Unknown==" },
			choices = {}
		}
	}
}
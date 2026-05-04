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
		description = "Space Hustle",
		path_to_bridge = false,
		siphon_count = 0,
		salvage_count = 0,
		sector_scan_count = 0,
		bridge_scan_count = 0
	},

	global_stats = {
		"Crew: <player_name>",
		"Credits: <credits>",
		"Fuel: <fuel>%",
		"Threat Level: <threat_level>",
		{"?", {"<threat_level>", ">", 5}, "Alert Status: **CRITICAL**", "Alert Status: Normal"}
	},

	ctes = {
		{
			id = "power_status",
			condition = {"<fuel>", ">", 20},
			["then"] = "Reactor output: **stable**.",
			["else"] = "Reactor output: **critical**."
		},
		{
			id = "comms_status",
			condition = {"<comms_repaired>", "==", true},
			["then"] = "Long-range comms: **online**.",
			["else"] = "Long-range comms: **offline**."
		}
	},

	conditions = {
		{ id = "has_fuel",      expr = {"<fuel>",              ">=", 10}   },
		{ id = "has_credits",   expr = {"<credits>",           ">=", 50}   },
		{ id = "oxygen_low",    expr = {"<oxygen>",            "<",  30}   },
		{ id = "comms_active",  expr = {"<comms_repaired>",    "==", true} },
		{ id = "key_owned",     expr = {"<has_override_key>",  "==", true} },
		{ id = "threat_high",   expr = {"<threat_level>",      ">",  5}    },
		{ id = "fuel_not_full", expr = {"<fuel>",              "<", 100}   },
		{ id = "siphon_limit",  expr = {"<siphon_count>",     "<", 2}    },
		{ id = "salvage_limit", expr = {"<salvage_count>",    "<", 3}    },
		{ id = "sector_scan_limit", expr = {"<sector_scan_count>", "<", 2} },
		{ id = "bridge_scan_limit", expr = {"<bridge_scan_count>", "<", 2} }
	},

	effects = {
		{ id = "repair_comms",    actions = { {"<comms_repaired>",   "=",  true}, {"<credits>",      "-=", 30} } },
		{ id = "siphon_fuel",     
			actions = {
				{"<fuel>", "+=", 25},
				{"<fuel>", "=", {"?", {"<fuel>", ">", 100}, 100, "<fuel>"}},
				{"<threat_level>", "+=", 2},
				{"<siphon_count>", "+=", 1}
			}
		},
		{ id = "rest_quarters",   actions = { {"<oxygen>",           "+=", 15},   {"<credits>",      "-=", 10} } },
		{ id = "use_override",    actions = { {"<path_to_bridge>",   "=",  true}, {"<threat_level>", "+=", 1}  } },
		{ id = "salvage_parts",   actions = { {"<credits>",          "+=", 40}, {"<salvage_count>", "+=", 1} } },
		{ id = "vent_atmosphere", actions = { {"<oxygen>",           "-=", 15} } }
	},

	transitions = {
		{ id = "return_hub_trans", target = "hub" }
	},

	shared_choices = {
		{
			id = "global_rest",
			label = "Rest and let the scrubbers cycle (+15 oxygen, -10 credits)",
			visible = {"<oxygen>", "<", 90},
			enabled = "has_credits",
			priority = 2,
			once = true,
			effects = "rest_quarters",
			transition = {
				text = {"Emergency scrubbers ran a full cycle. Breathing is easier. **Oxygen +15. Credits -10.**"},
				target = "hub"
			}
		},
		{
			id = "global_return_hub",
			label = "Head back to the Central Hub",
			priority = 10,
			transition = "return_hub_trans"
		}
	},

	nodes = {
		{
			id = "hub",
			text = {
				"The ==Central Hub== hums with residual power. ",
				{"cte", "power_status"},
				"\nEmergency lights cast long shadows across the metal grating. ",
				{"cte", "comms_status"}
			},
			stats = {
				"Location: Central Hub",
				{"?", {"<has_override_key>", "==", true}, "Key: **OBTAINED**", "Key: Missing"}
			},
			choices = {
				"global_rest",
				{
					id = "go_engineering",
					label = "Head to the Engineering Bay",
					priority = 0,
					transition = { target = "engineering" }
				},
				{
					id = "go_comms",
					label = "Check the Communications Array",
					priority = 0,
					transition = { target = "comms_room" }
				},
				{
					id = "go_quarters",
					label = "Search the Captain's Quarters",
					priority = 0,
					transition = { target = "captain_quarters" }
				},
				{
					id = "go_bridge",
					label = "Access the Command Bridge",
					visible = "key_owned",
					priority = 10,
					transition = { target = "bridge" }
				}
			}
		},
		{
			id = "engineering",
			text = {
				"Sparks rain from severed conduits. The main reactor cycles unevenly. ",
				{"?", {"<fuel>", "<=", 10}, "**Warning:** Fuel reserves critical.", "Reserve tanks show adequate levels."},
				"\nA damaged fuel siphon sits near the auxiliary bay."
			},
			stats = {
				"Location: Engineering Bay",
				"Reactor: ==Unstable==",
				"Hull Integrity: 84%"
			},
			choices = {
				{
					id = "siphon_fuel_action",
					label = "Siphon fuel from the auxiliary tanks (+25 fuel, +2 threat)",
					visible = "fuel_not_full",
					enabled = "siphon_limit",
					priority = 0,
					effects = "siphon_fuel",
					transition = {
						text = {"Auxiliary reserves drained into the main tank. Threat sensors tripped. **Fuel: <fuel>%.**"},
						target = "engineering"
					}
				},
				{
					id = "search_engineering",
					label = "Salvage spare parts from the wreckage (+40 credits)",
					visible = "salvage_limit",
					priority = 1,
					effects = "salvage_parts",
					transition = {
						text = {"Stripped usable components from the debris. **Credits: <credits>.**"},
						target = "engineering"
					}
				},
				"global_return_hub"
			}
		},
		{
			id = "comms_room",
			text = {
				"The comms console is dark. Dust coats the frequency dials. ",
				{"cte", "comms_status"},
				"\nA technician's datapad lies cracked on the floor."
			},
			stats = {
				"Location: Communications Array",
				"Signal Range: ==Zero==",
				"Last Contact: 14 cycles ago"
			},
			choices = {
				{
					id = "repair_comms_action",
					label = "Repair the array using salvaged parts (-30 credits)",
					visible = {"<comms_repaired>", "==", false},
					enabled = "has_credits",
					priority = 0,
					effects = "repair_comms",
					transition = {
						text = {"Array recalibrated. Signal lock established. **Credits: <credits>.**"},
						target = "comms_room"
					}
				},
				{
					id = "scan_sector",
					label = "Run a sweep of the surrounding sector (-15 fuel, +1 threat)",
					visible = "comms_active",
					enabled = "sector_scan_limit",
					priority = 1,
					effects = {{"<threat_level>", "+=", 1}, {"<fuel>", "-=", 15}, {"<sector_scan_count>", "+=", 1}},
					transition = {
						text = {"Sweep complete. Something out there noticed the signal. **Threat: <threat_level>.**"},
						target = "comms_room"
					}
				},
				"global_return_hub"
			}
		},
		{
			id = "captain_quarters",
			text = {
				"The door slides open with a hiss. Personal effects are scattered across the floor. ",
				"A secure locker is bolted to the wall, glowing with a soft blue light. ",
				{"?", {"<has_override_key>", "==", true},
					"The locker stands open. **It is empty**.",
					"The locker remains locked. **Override key required.**"}
			},
			stats = {
				"Location: Captain's Quarters",
				"Locker Status: ==Secured==",
				"Personal Log: ==Corrupted=="
			},
			choices = {
				{
					id = "force_locker",
					label = "Exploit the alert chaos to force the locker open (+1 threat)",
					visible = {"<has_override_key>", "==", false},
					enabled = "threat_high",
					priority = 0,
					effects = {{"<has_override_key>", "=", true}, {"<threat_level>", "+=", 1}},
					transition = {
						text = {"Security lockout bypassed under cover of the active alert. Override key retrieved. **Threat: <threat_level>.**"},
						target = "captain_quarters"
					}
				},
				{
					id = "read_log",
					label = "Attempt to decrypt the captain's personal log",
					once = true,
					priority = 1,
					transition = {
						text = {"Most data is corrupted beyond recovery. One fragment surfaces: *'They are in the walls...'*"},
						target = "captain_quarters"
					}
				},
				"global_return_hub"
			}
		},
		{
			id = "bridge",
			text = {
				"The Command Bridge overlooks the derelict sector. Navigation consoles blink in standby mode. ",
				{"cte", "power_status"},
				"\nThe captain's chair faces a star chart marked with red zones."
			},
			stats = {
				"Location: Command Bridge",
				"Command Codes: ==Accepted==",
				"Nav Computer: Online"
			},
			choices = {
				{
					id = "set_course",
					label = "Plot a course to the nearest safe zone",
					visible = {"<fuel>", ">=", 30},
					priority = 0,
					transition = {
						text = {"Course locked in. Engines are spooling up. **Prepare for departure.**"},
						target = "escape_pod_bay"
					}
				},
				{
					id = "monitor_scans",
					label = "Run long-range deep scans (+3 threat)",
					visible = "bridge_scan_limit",
					priority = 1,
					effects = {{"<threat_level>", "+=", 3}, {"<bridge_scan_count>", "+=", 1}},
					transition = {
						text = {"A massive structure detected at the sector's edge. It is moving toward us. **Threat: <threat_level>.**"},
						target = "bridge"
					}
				},
				"global_return_hub"
			}
		},
		{
			id = "escape_pod_bay",
			text = {
				"The bay doors grind open. A single escape pod hums with standby power. ",
				"You strap in and run through the launch checklist. ",
				"All systems nominal. **Ready for immediate departure.**"
			},
			stats = {
				"Location: Escape Pod Bay",
				"Pod Status: **Ready**",
				"Trajectory: Safe Zone"
			},
			choices = {
				{
					id = "launch_pod",
					label = "Initiate launch and leave the station behind",
					priority = 0,
					consumed = true,
					transition = {
						text = {"Clamps released. Pod detaches cleanly. **Stars streak past the viewport.**"},
						target = "victory"
					}
				}
			}
		},
		{
			id = "victory",
			text = {
				"**==MISSION COMPLETE==**\n",
				"The escape pod drifts into the starlight. The derelict station shrinks and vanishes behind you. ",
				"You made it out alive."
			},
			stats = {
				"Status: ==Safe==",
				"Crew: <player_name>",
				"Next Destination: ==Unknown=="
			},
			choices = {}
		}
	}
}
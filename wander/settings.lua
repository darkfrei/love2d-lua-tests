return {
	window = {
		width = 1920,
		height = 1080,
		title = "Wander + Perlin flow field",
		fullscreen = false,
		resizable = false,
		vsync = true,
	},

	world = {
		width = 1920,
		height = 1080,
	},

	background = {
		0.055,
		0.055,
		0.105,
		1.0,
	},

	simulation = {
		maxDt = 0.05,
	},

	vehicle = {
		maxSpeed = 170,
		maxForce = 130,
		spawnMargin = 220,
	},

	wander = {
		distance = 95,
		radius = 58,
		jitter = 0.9,
		noisePull = 4.8,
	},

	noise = {
		domainScale = 2.4,
		timeScale = 0.10,
		octaves = 3,
		persistence = 0.5,
		lacunarity = 2.1,
	},

	flowField = {
		gridSpacing = 70,
		arrowScale = 0.21,
	},

trail = {
	lineWidth = 4,
	color = { 1, 1, 1 },
	alpha = 1,

	minSegmentLength = 20,
	
	nodeRadius = 2,
},

	debug = {
		showField = true,
	},
}
-- star system prototypes module (data only)
local starSystemPrototypes = {
	{
		name = 'Solaris Prime',
		radius = 5000,  -- system radius in units
		star = {
			name = 'Helios Alpha',
			radius = 200,
			filename = "graphics/stars/star-1.png",
			animationFrames = {
				"graphics/stars/star-1-1.png",
				"graphics/stars/star-1-2.png",
				"graphics/stars/star-1-3.png"
			},
			scale = 1.2,  -- image scaling factor
			animationDuration = 2
		},
		planets = {
			{
				name = 'Aether Prime',
				orbitRadius = 1000,
				orbitPeriod = 50,  -- seconds per full orbit
				radius = 50,
				scale = 1.0,
				filename = "graphics/planets/planet-1.png"
			},
			{
				name = 'Chronos Minor',
				orbitRadius = 2000,
				orbitPeriod = 100,
				radius = 80,
				scale = 1.1,
				filename = "graphics/planets/planet-2.png"
			}
		}
	}
}

starSystemPrototypes.defaultSystem = starSystemPrototypes[1]

return starSystemPrototypes
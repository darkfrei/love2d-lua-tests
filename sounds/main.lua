window = require ("zoom-and-move-window")

sound = {}

sound.rate = 44100  --sample rate
sound.bits = 16     --bit rate
sound.channel = 1
sound.initialPhase = 0

function lerp(a, b, t) return a + (b - a) * t end -- linear interpolation

function love.load()
	window:load()
    love.window.setMode(1200, 200, { vsync = true, highdpi = true, resizable = true })

    --frequency table
	local s = (2)^(1/12)
    frequency = {s^12*440, s^6*440, 440, 44, 4.4}
	
    --time table
    seconds = {0, 1, 2, 3, 4}
	
    --tone is the sound data, sound_table is the x points of the waveform
    tone, sound_table = sound.get()

    qs = love.audio.newQueueableSource(tone:getSampleRate(), tone:getBitDepth(), tone:getChannelCount())
	position = nil
end

function love.update(dt)
	window:update(dt)
end




function love.draw()
	love.graphics.print('Press space')
	window:draw()
    -- draw waveform
    if sound_table then -- draw a line dividing each second
        love.graphics.setColor(255, 255, 255, 0.2)
        for i=1, #seconds do
            love.graphics.line(300*seconds[i], 0, 300*seconds[i], love.graphics.getHeight())
        end

        love.graphics.setColor(255, 255, 255, 1) --draw the waveform as dots
        for i=1, #sound_table-1 do
            love.graphics.points(100*seconds[1] + (100*(i-1))/sound.rate*3, (100*sound_table[i])+(100))
        end
    end
	
	if position then
		local x = (love.timer.getTime( )-position)
		if x <= seconds[#seconds] then
			love.graphics.line(300*x, 0, 300*x, love.graphics.getHeight())
		end
	end
end

function love.keypressed(key)--, scancode, isrepeat)	
    if key == "space" then
		qs:stop()
        qs:queue(tone)
        qs:play()
		position = love.timer.getTime( )
    end
end

function love.wheelmoved(x, y)
	window:wheelmoved(x, y)
end

-- Constructor for a sine wave generator.
sine = function(generator)
    local tau = math.pi*2
    generator = generator
    local increment = 1.0 / generator.rate --/ generator.channels
    local phase = generator.initialPhase
--    return function(freq)
--        phase = phase + increment
--        generator.phase = phase
--        local x = phase * freq
--        -- 2 ops: 1 mul, 1 trig
--        return math.sin(tau * x)
    return function(freq)
        phase = phase + tau * increment * freq
        generator.phase = phase
        return math.sin(phase)
    end
end

function sound.get()

    local sound_table = {}
    
    local length = (seconds[#seconds]-seconds[1]) * sound.rate

    -- initialising sample
    local sound_data = love.sound.newSoundData(length, sound.rate, sound.bits, sound.channel)

    local oscillator = sine(sound)

    -- writing to sample
    local amplitude = 0.5

    for i = 1, #seconds-1 do
        
        from = (seconds[i]-seconds[1]) * sound.rate
        till = (seconds[i+1]-seconds[1]) * sound.rate - 1
        from, till = math.floor(from), math.floor(till) --rounding down the samples, just in case

        for s = from, till do

            now = lerp(frequency[i], frequency[i+1], (s-from)/(till-from))

            sample = oscillator(now) * amplitude
            sound_data:setSample(s, sample)
            table.insert(sound_table, sample)
        end
    end

    return sound_data, sound_table

end



--manual, deconstructed loop below
--[[
function sound.get(args, ...)

    local sound_table = {}
    
    local length = 3 * sound.rate

    -- creating an empty sample
    local sound_data = love.sound.newSoundData(length, sound.rate, sound.bits, sound.channel)

    local oscillator = sine(sound)

    s = 0

    -- filling the sample with values
    local amplitude = 0.5

        for i = 0, 44100 do

            s = i
            now = lerp(frequency[1], frequency[2], i/44100)
            
            --if i == 2 and s == from and (s-from)/(till-from) == 0 then debug1 = now end
            --if i == 1 and s == till and (s-from)/(till-from) == 1 then debug2 = now end

            sample = oscillator(now) * amplitude
            sound_data:setSample(s, sample)
            table.insert(sound_table, sample)
        end

        for i = 44100, 88200 do

            s = i

            now = lerp(frequency[2], frequency[3], (i-44100)/(88200-44100))
            
            --if i == 2 and s == from and (s-from)/(till-from) == 0 then debug1 = now end
            --if i == 1 and s == till and (s-from)/(till-from) == 1 then debug2 = now end

            sample = oscillator(now) * amplitude
            sound_data:setSample(s, sample)
            table.insert(sound_table, sample)
        end

        for i = 88200, 132300-1 do

            s = i

            now = lerp(frequency[3], frequency[4], (i - 88200)/(132300-88200))
            
            --if i == 2 and s == from and (s-from)/(till-from) == 0 then debug1 = now end
            --if i == 1 and s == till and (s-from)/(till-from) == 1 then debug2 = now end

            sample = oscillator(now) * amplitude
            sound_data:setSample(s, sample)
            table.insert(sound_table, sample)
        end

    return sound_data, sound_table

end]]
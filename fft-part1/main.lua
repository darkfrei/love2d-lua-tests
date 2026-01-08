-- fft visualizer limited to 1..256 hz, 1 hz step
-- update and redraw of spectrum once per second

local originalRate = 44100        -- original sounddata/sample rate
local targetRate = 1024            -- analysis sample rate (nyquist = 256 hz)
--local targetRate = 512            -- analysis sample rate (nyquist = 256 hz)
local fftSize = 1024            -- fft size (one second of data at targetRate)
--local fftSize = 512               -- fft size (one second of data at targetRate)
local displayBins = 256           -- we display bins 1..256 (1..256 hz)
local width, height = 800, 600

-- audio objects
local source = nil
local soundData = nil

-- analysis buffers
local analysisBuffer = {}         -- complex samples fed to fft (length fftSize)
local windowCoeffs = {}           -- hann window coefficients
local spectrumMagnitudes = {}     -- magnitudes for bins 1..displayBins

-- drawing / update timing
local updateTimer = 0
local updateInterval = 1.0        -- seconds: update analysis every 1 second

-- peaks
local detectedFrequencies = {}    -- sorted by magnitude



-- generate a synthetic sample value at time t (seconds)
local function generateSampleAtTime(t)
	-- synthetic signal phases (kept for fallback/generator)
--	local main = 12.5
--	local main = 15
	local main = 16.6667
--	main =  main + (math.random ()*2-1)/1000
	local phase1 = 0
	local phase2 = math.pi / 4
	local phase3 = math.pi / 2
	local phase4 = 3 * math.pi / 4
	-- base tones: 50, 100, 150, 200 hz (examples)
	local a = math.sin(2 * math.pi * 1*main * t + phase1) * 0.5
	local b = math.sin(2 * math.pi * 2*main * t + phase2) * 0.25
	local c = math.sin(2 * math.pi * 3*main * t + phase3) * 0.15
	local d = math.sin(2 * math.pi * 4*main * t + phase4) * 0.1
--	local f1 = 0.25 * math.random ()
--	local f2 = 0.25 * math.random ()^2
--	local f3 = 0.25 * math.random ()^3

	-- white noise (zero-mean)
	local n1 = (math.random() * 2 - 1) * 0.16

	-- softer noise components (colored-like)
	local n2 = (math.random() * 2 - 1) * 0.08
	local n3 = (math.random() * 2 - 1) * 0.04


--	return a + b + c + d + f1 + f2 + f3 + n1 + n2 + n3
	return a + b + c + d + n1 + n2 + n3
--	return a + b + c + d
end

-- retrieve a linear-interpolated sample from soundData at absolute time t (seconds)
-- if soundData is nil, fallback to synthetic generator
local function sampleFromSourceAtTime(t)
	if not soundData then
		return generateSampleAtTime(t)
	end

	local totalSamples = soundData:getSampleCount()
	-- convert time to sample index (floating), sounddata is zero-based
	local idxFloat = t * originalRate
	-- handle negative times and wrap because our soundData loops
	idxFloat = idxFloat % totalSamples

	local i0 = math.floor(idxFloat)
	local i1 = (i0 + 1) % totalSamples
	local frac = idxFloat - i0

	local s0 = soundData:getSample(i0)
	local s1 = soundData:getSample(i1)
	return s0 * (1 - frac) + s1 * frac
end

-- prepare hann window coefficients for n samples
local function prepareHann(n)
	for i = 1, n do
		local coef = 0.5 * (1 - math.cos(2 * math.pi * (i - 1) / (n - 1)))
		windowCoeffs[i] = coef
	end
end

-- simple recursive cooley-tukey fft on complex table { {re=..., im=...}, ... }
-- note: this implementation is fine for n = 512 in a demo; for production consider iterative fft
local function performFft(input)
	local n = #input
	if n <= 1 then return input end

	local even, odd = {}, {}
	for i = 1, n, 2 do
		table.insert(even, input[i])
		if i + 1 <= n then
			table.insert(odd, input[i + 1])
		end
	end

	even = performFft(even)
	odd = performFft(odd)

	local output = {}
	local half = n / 2
	for k = 1, half do
		local angle = -2 * math.pi * (k - 1) / n
		local cosA = math.cos(angle)
		local sinA = math.sin(angle)
		local oddk = odd[k]
		local tRe = cosA * oddk.re - sinA * oddk.im
		local tIm = sinA * oddk.re + cosA * oddk.im

		local evenk = even[k]
		output[k] = {
			re = evenk.re + tRe,
			im = evenk.im + tIm
		}
		output[k + half] = {
			re = evenk.re - tRe,
			im = evenk.im - tIm
		}
	end

	return output
end

-- build analysisBuffer: sample the last 1 second of audio at targetRate (512 hz)
-- uses source:tell() to find end time if source exists and is playing; otherwise uses current time
local function fillAnalysisBuffer()
	-- determine end time (seconds) of audio source
	local endTime = nil
	if source and source:isPlaying() then
		-- source:tell() returns seconds of playback position
		endTime = source:tell()
	else
		-- fallback to system time for synthetic generator / paused audio
		endTime = love.timer.getTime()
	end

	-- collect samples from (endTime - 1) .. endTime exclusive at step 1/targetRate
	local t0 = endTime - 1.0
	for i = 1, fftSize do
		local t = t0 + (i - 1) / targetRate
		local s = sampleFromSourceAtTime(t)
		-- apply hann window here directly when constructing complex sample
		local win = windowCoeffs[i] or 1.0
		analysisBuffer[i] = { re = s * win, im = 0 }
--		analysisBuffer[i] = { re = s, im = 0 }
--		analysisBuffer[i] = { re = s/2 + s * win/2, im = 0 }
--analysisBuffer[i] = { re = s * math.cos(math.random()*2*math.pi), im = s * math.sin(math.random()*2*math.pi) }

	end
end

-- compute spectrumMagnitudes for bins 1..displayBins (1..256 hz)
local function analyzeSpectrum()
	-- perform fft on the windowed buffer
	local spectrum = performFft(analysisBuffer)

	-- compute magnitudes
	for i = 1, displayBins do
		local bin = spectrum[i]
		if bin then
			spectrumMagnitudes[i] = math.sqrt(bin.re * bin.re + bin.im * bin.im)

--			spectrumMagnitudes[i] = 1000 * math.sqrt(bin.re*bin.re + bin.im*bin.im) / fftSize
		else
			spectrumMagnitudes[i] = 0
		end
	end

	detectedFrequencies = {}
	local noiseThreshold = 1e-3
--	local noiseThreshold = 1e-6

	-- local peak detection with parabolic interpolation
	for i = 2, displayBins - 1 do
		local mPrev = spectrumMagnitudes[i - 1]
		local mCurr = spectrumMagnitudes[i]
		local mNext = spectrumMagnitudes[i + 1]

		if mCurr > noiseThreshold and mCurr > mPrev and mCurr > mNext then
			local denom = (mPrev - 2 * mCurr + mNext)
			local delta = 0
			if denom ~= 0 then
				delta = 0.5 * (mPrev - mNext) / denom
			end

			local freq = i + delta-1

			if freq >= 8 then
				table.insert(detectedFrequencies, {
						freq = freq,
						magnitude = mCurr
					})
			end
		end
	end

	-- sort by frequency for merging
	table.sort(detectedFrequencies, function(a, b)
			return a.freq < b.freq
		end)

	-- merge close peaks
	local mergeHz = 1.0
	local merged = {}

	for i = 1, #detectedFrequencies do
		local p = detectedFrequencies[i]
		local last = merged[#merged]

		if last and math.abs(p.freq - last.freq) <= mergeHz then
			-- weighted average frequency
			local wSum = last.magnitude + p.magnitude
			last.freq = (last.freq * last.magnitude + p.freq * p.magnitude) / wSum
			last.magnitude = math.max(last.magnitude, p.magnitude)
		else
			table.insert(merged, {
					freq = p.freq,
					magnitude = p.magnitude
				})
		end
	end

	detectedFrequencies = merged

	-- keep the 4 loudest
	table.sort(detectedFrequencies, function(a, b)
			return a.magnitude > b.magnitude
		end)

	for i = #detectedFrequencies, 5, -1 do
		table.remove(detectedFrequencies, i)
	end

	-- final order: lowest frequency first
	table.sort(detectedFrequencies, function(a, b)
			return a.freq < b.freq
		end)
end


-- love callbacks

function love.load()
	love.window.setMode(width, height)
	love.window.setTitle("fft visualizer 1..256 hz, 1 hz step")

	-- create synthetic sounddata and source for demo; comment this block if you want to load your own file
	soundData = love.sound.newSoundData(originalRate, originalRate, 16, 1)
	for i = 0, soundData:getSampleCount() - 1 do
		local t = i / originalRate
		local s = generateSampleAtTime(t)
		soundData:setSample(i, s)
	end
	source = love.audio.newSource(soundData)
	source:setLooping(true)
	source:play()

	-- prepare hann window
	prepareHann(fftSize)

	-- init arrays
	for i = 1, fftSize do analysisBuffer[i] = { re = 0, im = 0 } end
	for i = 1, displayBins do spectrumMagnitudes[i] = 0 end

	-- initial analysis immediately
	fillAnalysisBuffer()
	analyzeSpectrum()
	updateTimer = 0
end

function love.update(dt)
	updateTimer = updateTimer + dt
	if updateTimer >= updateInterval then
		-- update analysis once per second
		fillAnalysisBuffer()
		analyzeSpectrum()
		updateTimer = updateTimer - updateInterval
	end
end

function love.draw()
	love.graphics.clear(0.08, 0.08, 0.1)

	-- draw spectrum bars for 1..256 hz
--	local marginTop = 80
--	local availableHeight = height - marginTop - 120
--	local barWidth = (width - 40) / displayBins

-- draw spectrum bars for 1..256 hz
	local marginLeft = 60
	local marginRight = 20
	local marginTop = 100
	local marginBottom = 130

	local availableWidth = width - marginLeft - marginRight
	local availableHeight = height - marginTop - marginBottom
	local barWidth = availableWidth / displayBins

-- draw y-axis grid and labels (amplitude)
	love.graphics.setColor(0.3, 0.3, 0.35, 1)
	local yDivisions = 5
	for i = 0, yDivisions do
		local t = i / yDivisions
		local y = marginTop + (1 - t) * availableHeight

		-- horizontal grid line
		love.graphics.line(marginLeft, y, marginLeft + availableWidth, y)

		-- amplitude label
		love.graphics.setColor(0.8, 0.8, 0.8, 1)
		love.graphics.print(string.format("%.1f", t), 10, y - 7)
		love.graphics.setColor(0.3, 0.3, 0.35, 1)
	end

-- draw x-axis grid and labels (frequency)
	local xStepHz = 25
	for hz = 0, displayBins, xStepHz do
		local x = marginLeft + hz * barWidth

		-- vertical grid line
		love.graphics.line(x, marginTop, x, marginTop + availableHeight)

		-- frequency label
		if hz > 0 then
			love.graphics.setColor(0.8, 0.8, 0.8, 1)
			love.graphics.print(string.format("%d", hz), x - 8, marginTop + availableHeight + 8)
		end
		love.graphics.setColor(0.3, 0.3, 0.35, 1)
	end

-- axis labels
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("frequency (hz)", marginLeft + availableWidth / 2 - 40, height - marginBottom+20)
	love.graphics.print("amplitude (normalized)", 10, marginTop - 20)

-- draw spectrum bars
	for i = 1, displayBins do
		local mag = spectrumMagnitudes[i] or 0

		-- scale magnitude for visualization
		local scaled = math.min(mag * 0.02, 1.0)
		local barHeight = scaled * availableHeight + 1

		local x = marginLeft + (i - 1) * barWidth
		local y = marginTop + (availableHeight - barHeight)

		-- color mapping by frequency
		local hue = i / displayBins
		local r = math.max(0, math.cos((hue - 0.0) * math.pi * 2)) * 0.6 + 0.4
		local g = math.max(0, math.cos((hue - 0.33) * math.pi * 2)) * 0.6 + 0.4
		local b = math.max(0, math.cos((hue - 0.66) * math.pi * 2)) * 0.6 + 0.4

		love.graphics.setColor(r, g, b, 0.95)
		love.graphics.rectangle("fill", x, y, barWidth - 1, barHeight)
	end


	-- draw ui text
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("spectrum: 1..256 hz (1 hz step) — updated once per second", 20, 10)
	love.graphics.print(string.format("sample rate (analysis): %d hz  |  fft size: %d", targetRate, fftSize), 20, 28)
	love.graphics.print(string.format("time window: %.2f s", fftSize / targetRate), 20, 46)

-- print top detected peaks with horizontal bars
	love.graphics.print("top peaks:", 20, height - 110)


	local maxShow = math.min(8, #detectedFrequencies)
	local barMaxWidth = 300  -- maximum width of horizontal bar in pixels
	for i = 1, maxShow do
		local p = detectedFrequencies[i]

		-- print text for each peak
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(string.format("#%.0f: %.1f hz  mag: %.4f", i, p.freq, p.magnitude), 20, height - 110 + 18 * i)

		-- draw horizontal bar showing magnitude
--		local barWidth = math.min(p.magnitude * 0.02 * barMaxWidth, barMaxWidth)  -- scale magnitude to pixels
		local barWidth = math.min(p.magnitude * 0.005 * barMaxWidth, barMaxWidth)  -- scale magnitude to pixels
		local barX = 250  -- x position of bar
		local barY = height - 110 + 18 * i + 2  -- y position slightly below text

		love.graphics.setColor(0.2, 1.0, 0.2, 0.9)  -- green bar
		love.graphics.rectangle("line", barX, barY, barMaxWidth, 12)  -- draw bar with fixed height

		love.graphics.rectangle("fill", barX, barY, barWidth, 12)  -- draw bar with fixed height
	end




	-- instructions
	love.graphics.setColor(0.8, 0.8, 0.8)
	love.graphics.print("space - pause/play | escape - quit", 20, height - 20)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "space" then
		if source and source:isPlaying() then
			source:pause()
		elseif source then
			source:play()
		end
	end
end

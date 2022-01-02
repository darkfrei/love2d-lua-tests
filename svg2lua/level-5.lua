roadColor = {118/255, 118/255, 118/255}
lineColor = {255/255, 255/255, 255/255}

bridgeRoadColor = {120/255, 120/255, 165/255,0.9}
bridgeLineColor = {255/255, 255/255, 70/255}



bckGrColor = {89/255, 157/255, 220/255}
--buildingColor = {200/255, 255/255, 172/255}
buildingColor = {255/255, 200/255, 80/255}

return {

	
	-- generator / green
	"R 1 M 840,520 H 760 M 1720,760 H 1640 M 1720,120 H 1640 M 200,200 H 280 M 200,840 H 280",
	
	-- terminator / cyan
	"R 1 M 1000,520 H 920 M 1640,840 H 1720 M 1640,200 H 1720 M 280,120 H 200 M 280,760 H 200",


--	river
	"F 1 M 360,600 C 480,600 480,360 800,360 V 240 C 480,240 480,400 360,400 Z",
	"F 1 M 1360,560 C 1600,560 1800,360 1920,360 V 240 C 1800,240 1600,440 1360,440 Z",
	"F 1 M 800,360 C 1120,360 1120,560 1360,560 V 440 C 1120,440 1120,240 800,240 Z",
	"F 1 M 360,400 C 240,400 160,360 0,360 V 480 C 160,480 240,600 360,600",
	"F 1 M 800,720 C 520,720 640,600 360,600 L 440,520 C 640,520 600,640 800,640 Z",
	"F 1 M 1520,960 C 1400,840 1240,640 800,640 V 720 C 1160,720 1320,840 1440,960 Z",
	
		
	-- buildings
	"F 2 M 1680,80 H 1840 V 240 H 1680 Z",
	"F 2 M 1680,720 H 1840 V 880 H 1680 Z",
	"F 2 M 800,440 H 960 V 600 H 800 Z",
	"F 2 M 80,720 H 240 V 880 H 80 Z",
	"F 2 M 80,80 H 240 V 240 H 80 Z",
	
	
--	roads
	"R 1 M 680,200 C 680,160 680,80 560,80 M 520,920 C 680,920 800,880 960,880 M 960,880 C 1040,880 1080,840 1080,800 M 1080,640 C 1080,560 1040,520 1000,520 M 1480,880 C 1520,880 1560,840 1560,680 M 1480,880 C 1560,880 1560,840 1640,840 M 1640,760 C 1600,760 1560,720 1560,680 M 1560,680 V 560 M 1560,360 C 1560,240 1600,200 1640,200 M 1640,120 C 1520,120 1560,80 1400,80 M 960,880 H 1280 M 1560,360 C 1560,240 1600,80 1400,80 M 1400,80 H 560 M 560,80 C 400,80 360,120 280,120 M 280,200 C 320,200 360,240 360,360 M 360,640 C 360,760 360,920 520,920 M 360,640 C 360,720 320,760 280,760 M 280,840 C 360,840 400,920 520,920 M 560,80 C 400,80 360,200 360,360 M 760,520 C 720,520 680,480 680,400 M 760,520 C 720,520 680,520 640,560 M 520,680 C 480,720 360,760 280,760 M 520,680 C 440,760 360,920 520,920 M 1400,80 C 1200,80 1280,280 1200,360 M 1080,480 C 1040,520 1040,520 1000,520",
--	bridges
	"R 2 M 1200,360 L 1080,480 M 680,400 V 200 M 640,560 L 520,680 M 360,360 V 640 M 1280,880 H 1480 M 1560,560 V 360 M 1080,800 V 640",
}

--[[

local obj = 
{
	controlPoints = {
		{5,0, 5,3, 7,5, 10,5},
		{10,5, 10,8, 8,10, 5,10},
		{5,10, 2,10, 0,8, 0,5},
		{0,5, 0,2, 2,0, 5,0},
	}
}

obj.curves = {}
for i, vertices in ipairs (obj.controlPoints) do
	local bezierCurve = love.math.newBezierCurve (vertices)
	local curve = bezierCurve:render ()
	table.insert (obj.curves, curve)
end

obj.polyline = {}
for i, vertices in ipairs (obj.curves) do
	for j = 1, #vertices-1, 2 do
		local x, y = vertices[j], vertices[j+1]
		local n = #obj.polyline
		if n > 0 then
			local x2, y2 = obj.polyline[n-1], obj.polyline[n]
			if not (x == x2 and y == y2) then
				table.insert (obj.polyline, x)
				table.insert (obj.polyline, y)
			end
		end
	end
end
local n = #obj.polyline
if (obj.polyline[1] == obj.polyline[n-1]) and (obj.polyline[2] == obj.polyline[n]) then
	table.remove(obj.polyline, n)
	table.remove(obj.polyline, n-1)
end
]]
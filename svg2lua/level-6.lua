roadColor = {118/255, 118/255, 118/255}
lineColor = {255/255, 255/255, 255/255}

bridgeRoadColor = {120/255, 120/255, 165/255,0.9}
bridgeLineColor = {255/255, 255/255, 70/255}



bckGrColor = {89/255, 157/255, 220/255}
--buildingColor = {200/255, 255/255, 172/255}
buildingColor = {255/255, 200/255, 80/255}

roadMainWidth = 38
roadSideLineWidth = 4
restRadWidth = 4

roadWidth1 = roadMainWidth + 2*roadSideLineWidth + 2*restRadWidth
roadWidth2 = roadMainWidth + 2*roadSideLineWidth
roadWidth3 = roadMainWidth

carScale = 1.3

return {

	
	-- generator / green
--	"R 1 M 840,520 H 760 M 1720,760 H 1640 M 1720,120 H 1640 M 200,200 H 280 M 200,840 H 280",
	"R 1 M 1560,80 H 1480 M 1840,720 V 800 M 1720,720 V 800 M 1600,720 V 800 M 1480,720 V 800 M 1360,720 V 800",
	
	-- terminator / cyan
--	"R 1 M 1000,520 H 920 M 1640,840 H 1720 M 1640,200 H 1720 M 280,120 H 200 M 280,760 H 200",
	"R 1 M 440,80 L 360,80 M 560,800 V 720 M 440,800 V 720 M 320,800 V 720 M 200,800 V 720 M 80,800 V 720",


--	river
--	"F 1 M 360,600 C 480,600 480,360 800,360 V 240 C 480,240 480,400 360,400 Z",
--	"F 1 M 1360,560 C 1600,560 1800,360 1920,360 V 240 C 1800,240 1600,440 1360,440 Z",
--	"F 1 M 800,360 C 1120,360 1120,560 1360,560 V 440 C 1120,440 1120,240 800,240 Z",
--	"F 1 M 360,400 C 240,400 160,360 0,360 V 480 C 160,480 240,600 360,600",
--	"F 1 M 800,720 C 520,720 640,600 360,600 L 440,520 C 640,520 600,640 800,640 Z",
--	"F 1 M 1520,960 C 1400,840 1240,640 800,640 V 720 C 1160,720 1320,840 1440,960 Z",
	
		
	-- buildings
--	"F 2 M 1680,80 H 1840 V 240 H 1680 Z",
--	"F 2 M 1680,720 H 1840 V 880 H 1680 Z",
--	"F 2 M 800,440 H 960 V 600 H 800 Z",
--	"F 2 M 80,720 H 240 V 880 H 80 Z",
--	"F 2 M 80,80 H 240 V 240 H 80 Z",

	"F 2 M 40,760 H 600 V 960 H 40 Z",
	"F 2 M 1320,760 H 1880 V 960 H 1320 Z",
	"F 2 M 400,0 H 1520 V 160 H 400 Z",
	"F 2 M 920,600 H 1000 V 960 H 920 Z",
	"F 2 M 920,160 H 1000 V 240 H 920 Z",
	
	
--	roads
--	"R 1 M 840,520 H 1080 M 760,480 H 1160 M 680,440 H 1240 M 600,400 H 1320 M 520,360 H 1400 M 1080,520 C 1120,520 1160,500 1200,480 M 1200,480 C 1240,460 1280,440 1320,440 M 1160,480 C 1200,480 1240,460 1280,440 M 1280,440 C 1320,420 1360,400 1400,400 M 1240,440 C 1280,440 1320,420 1360,400 M 1360,400 C 1400,380 1440,360 1480,360 M 1320,400 C 1360,400 1400,380 1440,360 M 1440,360 C 1480,340 1520,320 1560,320 M 1400,360 C 1440,360 1520,320 1560,320 M 1080,520 C 1120,520 1200,480 1240,480 M 1080,520 H 1160 M 1160,480 H 1240 M 1240,440 H 1320 M 1320,400 H 1400 M 1400,360 H 1480 M 360,320 H 1560 M 760,520 H 840 M 680,480 H 760 M 600,440 H 680 M 520,400 H 600 M 440,360 H 520 M 680,480 C 720,480 800,520 840,520 M 360,320 C 400,320 480,360 520,360 M 600,440 C 640,440 680,460 720,480 M 520,400 C 560,400 600,420 640,440 M 440,360 C 480,360 520,380 560,400 M 360,320 C 400,320 440,340 480,360 M 480,360 C 520,380 560,400 600,400 M 560,400 C 600,420 640,440 680,440 M 640,440 C 680,460 720,480 760,480 M 720,480 C 760,500 800,520 840,520 M 640,440 L 720,480 M 560,400 L 640,440 M 480,360 L 560,400 M 1560,320 C 1626,320 1680,267 1680,200 M 240,200 C 240,266 293,320 360,320 M 1480,360 C 1680,360 1840,520 1840,720 M 1400,400 C 1578,400 1720,542 1720,720 M 1320,440 C 1476,440 1600,564 1600,720 M 1240,480 C 1373,480 1480,587 1480,720 M 1161,519 C 1272,520 1360,609 1360,720 M 80,720 C 80,520 240,360 440,360 M 200,720 C 200,542 342,400 520,400 M 320,720 C 320,564 444,440 600,440 M 440,720 C 440,587 547,480 680,480 M 560,720 C 560,609 649,520 760,520 M 1680,200 C 1680,134 1627,80 1560,80 M 360,80 C 294,80 240,133 240,200",
--	"R 1 M 1360,400 L 1440,360 M 1280,440 L 1360,400 M 1200,480 L 1280,440 M 840,520 H 1080 M 760,480 H 1160 M 680,440 H 1240 M 600,400 H 1320 M 520,360 H 1400 M 1080,520 C 1120,520 1160,500 1200,480 M 1200,480 C 1240,460 1280,440 1320,440 M 1160,480 C 1200,480 1240,460 1280,440 M 1280,440 C 1320,420 1360,400 1400,400 M 1240,440 C 1280,440 1320,420 1360,400 M 1360,400 C 1400,380 1440,360 1480,360 M 1320,400 C 1360,400 1400,380 1440,360 M 1440,360 C 1480,340 1520,320 1560,320 M 1400,360 C 1440,360 1520,320 1560,320 M 1080,520 C 1120,520 1200,480 1240,480 M 1080,520 H 1160 M 1160,480 H 1240 M 1240,440 H 1320 M 1320,400 H 1400 M 1400,360 H 1480 M 360,320 H 1560 M 760,520 H 840 M 680,480 H 760 M 600,440 H 680 M 520,400 H 600 M 440,360 H 520 M 680,480 C 720,480 800,520 840,520 M 360,320 C 400,320 480,360 520,360 M 600,440 C 640,440 680,460 720,480 M 520,400 C 560,400 600,420 640,440 M 440,360 C 480,360 520,380 560,400 M 360,320 C 400,320 440,340 480,360 M 480,360 C 520,380 560,400 600,400 M 560,400 C 600,420 640,440 680,440 M 640,440 C 680,460 720,480 760,480 M 720,480 C 760,500 800,520 840,520 M 640,440 L 720,480 M 560,400 L 640,440 M 480,360 L 560,400 M 1560,320 C 1626,320 1680,267 1680,200 M 240,200 C 240,266 293,320 360,320 M 1480,360 C 1680,360 1840,520 1840,720 M 1400,400 C 1578,400 1720,542 1720,720 M 1320,440 C 1476,440 1600,564 1600,720 M 1240,480 C 1373,480 1480,587 1480,720 M 1161,519 C 1272,520 1360,609 1360,720 M 80,720 C 80,520 240,360 440,360 M 200,720 C 200,542 342,400 520,400 M 320,720 C 320,564 444,440 600,440 M 440,720 C 440,587 547,480 680,480 M 560,720 C 560,609 649,520 760,520 M 1680,200 C 1680,134 1627,80 1560,80 M 360,80 C 294,80 240,133 240,200",
	"R 1 M 1160,520 C 1271,520 1360,609 1360,720 M 360,80 C 294,80 240,133 240,200 M 1680,200 C 1680,134 1627,80 1560,80 M 560,720 C 560,609 649,520 760,520 M 440,720 C 440,587 547,480 680,480 M 320,720 C 320,564 444,440 600,440 M 200,720 C 200,542 342,400 520,400 M 80,720 C 80,520 240,360 440,360 M 1240,480 C 1373,480 1480,587 1480,720 M 1320,440 C 1476,440 1600,564 1600,720 M 1400,400 C 1578,400 1720,542 1720,720 M 1480,360 C 1680,360 1840,520 1840,720 M 240,200 C 240,266 293,320 360,320 M 1560,320 C 1626,320 1680,267 1680,200 M 480,360 L 560,400 M 560,400 L 640,440 M 640,440 L 720,480 M 720,480 C 760,500 800,520 840,520 M 640,440 C 680,460 720,480 760,480 M 560,400 C 600,420 640,440 680,440 M 480,360 C 520,380 560,400 600,400 M 360,320 C 400,320 440,340 480,360 M 440,360 C 480,360 520,380 560,400 M 520,400 C 560,400 600,420 640,440 M 600,440 C 640,440 680,460 720,480 M 360,320 C 440,320 480,360 520,360 M 680,480 C 720,480 760,520 840,520 M 440,360 H 520 M 520,400 H 600 M 600,440 H 680 M 680,480 H 760 M 760,520 H 840 M 360,320 H 1560 M 1400,360 H 1480 M 1320,400 H 1400 M 1240,440 H 1320 M 1160,480 H 1240 M 1080,520 H 1160 M 1080,520 C 1160,520 1200,480 1240,480 M 1400,360 C 1440,360 1480,320 1560,320 M 1440,360 C 1480,340 1520,320 1560,320 M 1320,400 C 1360,400 1400,380 1440,360 M 1360,400 C 1400,380 1440,360 1480,360 M 1240,440 C 1280,440 1320,420 1360,400 M 1280,440 C 1320,420 1360,400 1400,400 M 1160,480 C 1200,480 1240,460 1280,440 M 1200,480 C 1240,460 1280,440 1320,440 M 1080,520 C 1120,520 1160,500 1200,480 M 520,360 H 1400 M 600,400 H 1320 M 680,440 H 1240 M 760,480 H 1160 M 840,520 H 1080 M 1200,480 L 1280,440 M 1280,440 L 1360,400 M 1360,400 L 1440,360",

--	bridges
--	"R 2 M 1200,360 L 1080,480 M 680,400 V 200 M 640,560 L 520,680 M 360,360 V 640 M 1280,880 H 1480 M 1560,560 V 360 M 1080,800 V 640",
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
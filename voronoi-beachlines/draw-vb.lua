-- draw-vb

function drawFrame ()
	love.graphics.setColor (0.8,0.8,0.8,0.8)
	love.graphics.setLineWidth (2)
	love.graphics.rectangle ('line', frame.x, frame.y, frame.w, frame.h)
end


function drawDirectrix ()
	love.graphics.setColor (0.8,0.8,0.8,0.8)
	love.graphics.setLineWidth (2)
	love.graphics.line (frame.x, dirY, frame.x+frame.w, dirY)
end


function drawSitesVertices ()
	love.graphics.setColor (0.8,0.8,0.8,0.8)
	love.graphics.setLineWidth (1)

--	love.graphics.points (vertices)
	for i = 1, #vertices-1, 2 do
		local x, y = vertices[i], vertices[i+1]
		love.graphics.circle ('line', x, y, 2)
	end
end



function drawFrameCollisionLines ()
	love.graphics.setColor (0,0.6,0,0.6)
	love.graphics.setLineWidth (6)
	for i, beachLine in ipairs (beachLines) do
		love.graphics.line (beachLine.line)
	end
end

function drawBezierControlLines ()
	love.graphics.setColor (1,1,0,0.6)
	love.graphics.setLineWidth (1)
	love.graphics.setLineStyle ('rough')
	for i, beachLine in ipairs (beachLines) do
		if beachLine.controlPoints and #beachLine.controlPoints > 3 
		and beachLine.controlPoints[3] ~= nil then
			love.graphics.line (beachLine.controlPoints)
		end
	end
end


function drawBezierArcs ()
	love.graphics.setColor (0,0.7,0,0.7)
	love.graphics.setLineWidth (1)
	love.graphics.setLineStyle ('smooth')

	for i, beachLine in ipairs (beachLines) do
		if beachLine.bezierLine then

			love.graphics.line (beachLine.bezierLine)

		end

	end
end
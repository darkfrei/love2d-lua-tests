-- events-vb



-------------------------------------
function getBeachLineForSite (x)
	for index, beachLine in ipairs (beachLines) do
		print ('beachLine', index, '#beachLines',  #beachLines)
		local x1, x2 = beachLine.x1, beachLine.x2
		if x <= x2 then
			beachLine.index = index
			if x < x2 then
				return beachLine, true
			else
				return beachLine, false
			end
		end
	end
end

runEvent = {}
--runEvent[event.type]()
runEvent.site = function (event)
	local x = event.x
	print ('event.x', x)
	local beachLine, cutArc = getBeachLineForSite (x)

	if cutArc then
		local index = beachLine.index
		local beachLine1 = copyBeachLine (beachLine)
		local beachLine3 = copyBeachLine (beachLine)
		local neachLine2 = newBeachline ()
	else

	end

end


runEvent.circle = function (event)


end

runEvent.edge = function (event)


end
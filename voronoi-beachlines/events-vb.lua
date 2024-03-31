-- events-vb



-------------------------------------
function getBeachLineForSite (x)
	for index, beachLine in ipairs (beachLines) do
--		print ('beachLine', index, '#beachLines',  #beachLines)
		local x1, x2 = beachLine.x1, beachLine.x2
		print ('x1, x, x2', x1, x, x2)
		if (x1 < x) and (x <= x2) then
			print('ok')
			beachLine.index = index
			if x < x2 then
				return index, true
			else
				return index, false
			end
		end
	end
end

runEvent = {}
--runEvent[event.type]()
runEvent.site = function (event)
	local x = event.x
	print ('event.x', x)
	local index, cutBeachLine = getBeachLineForSite (x)

	if cutBeachLine then
		print ('')
		local index = beachLine.index
		local beachLine1 = copyBeachLine (beachLine)
		local beachLine3 = copyBeachLine (beachLine)
		local beachLine2 = newBeachline ()
	else -- insert between beachlines
		
	end

end


runEvent.circle = function (event)


end

runEvent.edge = function (event)


end
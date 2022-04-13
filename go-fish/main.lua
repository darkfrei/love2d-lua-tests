-- License CC0 (Creative Commons license) (c) darkfrei, 2022

function createDeck ()
	Deck = {}
	for iSuit = 1, #CardSuits do
		for iRank = 1, #CardRanks do
			local card = {
				iSuit = iSuit,
				iRank = iRank,
				suit = CardSuits[iSuit],
				rank = CardRanks[iRank],
				name = CardSuits[iSuit]..'-'..CardRanks[iRank]
			}
			local i = math.random (#Deck + 1)
			table.insert (Deck, i, card)
		end
	end
end

function createPlayers (nPlayers)
	Players = {}
	for index = 1, nPlayers do
		local player = {
			cards = {},
			moves = {},
			score = 0,
			index = index,
		}
		table.insert (Players, player)
	end
end

function dealPlayers ()
	local nCards = 7
	if #Players > 2 then nCards = 5 end
		
	for i = 1, nCards do
		for iPlayer = 1, #Players do
			-- player takes a card from deck
			takeCardFromDeck (Players[iPlayer])
		end
	end
end

function isKeyValueInList (key, value, list)
	for index, element in ipairs (list) do
		if element[key] == value then
			return element, index
		end
	end
	return false
end

function updateMoves ()
	for iPlayer = 1, #Players do
		local player = Players[iPlayer]
		
		local moves = {}
		for iCard = 1, #player.cards do
			local rank = player.cards[iCard].rank
			local move = isKeyValueInList ("rank", rank, moves)
			if not move then
				move = {rank = rank, amount = 1}
				table.insert (moves, move)
			else
				move.amount = move.amount + 1
			end
		end
		player.moves = moves
	end
end

function takeCardFromDeck (player)
	if #Deck > 0 then
		-- player takes last card from deck
		table.insert (player.cards, table.remove(Deck, #Deck))
		return true
	end
	return false
end

function updateGUI ()
	local player = Players[1]
	local nMoves = #player.moves
	local x1, y1 = 100, 450
	local cardW = 50
	local cardH = 30
	
	GUI = {}
	local totalCards = 0
	totalCards = totalCards + #Deck
	for iPlayer = 1, #Players do
		local player = Players [iPlayer]
		totalCards = totalCards + #player.cards
	end
	if totalCards == 0 then
		GameOver = true
		table.insert (Statistics, 1, "Game Over")
		local winners = {}
		local max = 0
		for iPlayer = 1, #Players do
			local player = Players [iPlayer]
			if player.score > max then
				winners = {player.index}
				max = player.score
			elseif player.score == max then
				table.insert (winners, player.index)
			end
		end
		if #winners == 1 then
			table.insert (Statistics, 1, "Player " .. winners[1] .. ' wins the game')
		elseif #winners > 1 then
			table.insert (Statistics, 1, "Players " .. table.concat(winners, ', ') .. ' win the game')
		end
	end
	
	if #Players > 2 then
		GUI.selectedPlayer = nil
		local amount, last = 0, nil
		for iPlayer = 2, #Players do
			local player = Players [iPlayer]
			if #player.cards > 0 then
				local x = x1 + cardW*(iPlayer-2)
				local y = y1
				local button = {
					x=x, 
					y=y, 
					w=cardW, 
					h=cardH, 
					text = 'Player' .. iPlayer,
					iPlayer = iPlayer,
					playerButton = true,
				}
				table.insert (GUI, button)
				amount = amount + 1
				last = player
			end
		end
		if amount == 1 then
			-- only one player
			GUI.selectedPlayer = last
		end
	else
		GUI.selectedPlayer = 2
	end
	for iMove, move in ipairs (player.moves) do
		local x = x1 + cardW*(iMove-1)
		local y = y1 + cardH
		local button = {
			x=x, 
			y=y, 
			w=cardW, 
			h=cardH, 
			text = move.rank .. ' (' .. move.amount..')',
			rank = move.rank,
			moveButton = true,
		}
		table.insert (GUI, button)
	end
end

function love.load()
	love.window.setTitle( 'Go Fish' )
	Statistics = {}
	CardSuits = {"A", "B", "C", "D"}
	CardRanks = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"}
	NPlayers = 6
	Hidden = true
	
	-- new game
	createDeck ()
	createPlayers (NPlayers)
	dealPlayers ()
	
	updateMoves ()
	updateGUI ()
end

function love.draw()
	if not Hidden then
		for i, t in ipairs (Deck) do
			love.graphics.print (t.name, 0, i*11)
		end
	end
	for iPlayer, player in ipairs (Players) do
		local x = 60 * iPlayer
		local y = 0
		love.graphics.print ('player '..iPlayer, x, y)
		y = y + 14
		love.graphics.print ('score: '.. player.score, x, y)
		if not Hidden or (iPlayer == 1) then
			for iCard, card in ipairs (player.cards) do
				y = y + 14
				love.graphics.print (card.name, x, y)
			end
		end
		if not Hidden then
			y = y + 14
			for iMove, move in ipairs (player.moves) do
				y = y + 14
				love.graphics.print (move.rank .. ' ' .. move.amount, x, y)
			end
		end
	end

--	draw first player moves
	for iGUI, button in ipairs (GUI) do
--		print (GUI.selectedPlayer or '', button.iPlayer or '')
		if  GUI.hoveredMove and (GUI.hoveredMove == iGUI) or
			GUI.selectedPlayer and button.iPlayer and (GUI.selectedPlayer.index == button.iPlayer) then
			love.graphics.setColor (0.3,0.3,0.3)
			love.graphics.rectangle ('fill', button.x, button.y, button.w, button.h)
		end
		love.graphics.setColor (1,1,1)
		love.graphics.rectangle ('line', button.x, button.y, button.w, button.h)
		love.graphics.printf(button.text, button.x, button.y, button.w, 'center', 0, 1, 1, 0, -math.floor(button.h/4))
	end
	for i = 1, math.min(30, #Statistics) do
		local str = Statistics[i]
		love.graphics.print (str, 430, 20+(i-1)*14)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "h" then
		Hidden = not Hidden
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	GUI.hoveredMove = nil
	for iGUI, button in ipairs (GUI) do
		if x > button.x and x < button.x + button.w and y > button.y and y < button.y + button.h then
			GUI.hoveredMove = iGUI
		end
	end
end

function checkHandCards (player)
	local sets = {}
	for iCard = 1, #player.cards do
		local rank = player.cards[iCard].rank
		local set = isKeyValueInList ("rank", rank, sets)
		if not set then
			set = {rank = rank, amount = 1}
			table.insert (sets, set)
		else
			set.amount = set.amount + 1
		end
	end
	for iSet = 1, #sets do
		local set = sets[iSet]
		if set.amount == 4 then -- full set
			local rank = set.rank
			
			table.insert (Statistics, 1, "Player "..player.index .. ' has set of "' .. rank .. '"')
			-- remove cards
			for iCard = #player.cards, 1, -1 do -- backwards
				local card = player.cards[iCard]
				if card.rank == rank then
					table.remove (player.cards, iCard)
				end
			end
			player.score = player.score + 1
		end
	end
end

function fillHandCards (player)
	
	if #player.cards == 0 and #Deck > 0 then
		local nCards = math.min(5, #Deck)
		if nCards == 1 then
			table.insert (Statistics, 1, "Player ".. player.index .. ' takes one card from deck')
		else
			table.insert (Statistics, 1, "Player ".. player.index .. ' takes '.. nCards ..' cards from deck')
		end
		for i = 1, nCards do
			takeCardFromDeck (player)
		end
	end
end

function doMove (activePlayer, selectedPlayer, rank)
	local takenCards = 0
	for iCard = #selectedPlayer.cards, 1, -1 do -- iterate backwards
		local card = selectedPlayer.cards[iCard]
		if card.rank == rank then
			table.insert (activePlayer.cards, table.remove (selectedPlayer.cards, iCard))
			takenCards = takenCards + 1
		end
	end
	if takenCards > 0 then 
		if takenCards == 1 then
			table.insert (Statistics, 1, 
								"Player "..activePlayer.index .. ' asks the Player '.. selectedPlayer.index .. ' for card "'.. rank .. 
				'" and get one card.')
		else
			table.insert (Statistics, 1, 
				"Player "..activePlayer.index .. ' asks the Player '.. selectedPlayer.index .. ' for card "'.. rank .. 
				'" and get ' .. takenCards .. ' cards.')
		end
		checkHandCards (activePlayer)
		fillHandCards (activePlayer)
		fillHandCards (selectedPlayer)
		updateMoves ()
		if #activePlayer.cards > 0 then
--		repeat the turn
			return true
		else
			return false
		end
	else
		table.insert (Statistics, 1, 
							"Player "..activePlayer.index .. ' asks the Player '.. selectedPlayer.index .. ' for card "'.. rank .. 
			'", but he has no one.')
		if takeCardFromDeck (activePlayer) then
			table.insert (Statistics, 1, "Player ".. activePlayer.index .. ' takes one card from deck')
		end
		checkHandCards (activePlayer)
--		next player turn
		return false
	end

end


function AI_moves ()
	for iPlayer = 2, #Players do
		local activePlayer = Players[iPlayer]
		if #activePlayer.moves > 0 then
			local iMove = math.random (#activePlayer.moves)
			local rank = activePlayer.moves[iMove].rank
			local activePlayers = {}
			for iPlayer, player in ipairs (Players) do
				if #player.cards > 0 and not (activePlayer == player) then
					table.insert (activePlayers, player)
				end
			end
			local selectedPlayer = activePlayers[math.random (#activePlayers)]
			while doMove (activePlayer, selectedPlayer, rank) do
				activePlayers = {}
				for iPlayer, player in ipairs (Players) do
					if #player.cards > 0 and not (activePlayer == player) then
						table.insert (activePlayers, player)
					end
				end
				iMove = math.random (#activePlayer.moves)
				rank = activePlayer.moves[iMove].rank
			end
		else
			table.insert (Statistics, 1, "Player ".. activePlayer.index .. ' has no cards')
		end
	end
end

function love.mousereleased( x, y, button, istouch, presses )
	if GameOver then
		GameOver = false
		
		createDeck ()
		createPlayers (NPlayers)
		dealPlayers ()
		
		updateMoves ()
		updateGUI ()
	elseif GUI.hoveredMove then
		local button = GUI[GUI.hoveredMove]
		
		if button.playerButton then
			GUI.selectedPlayer = Players[button.iPlayer]
			table.insert (Statistics, 1, 'Selected Player: ' .. button.iPlayer)
		elseif button.moveButton then
			-- check if the player has these cards
			GUI.hoveredMove = nil
			if GUI.selectedPlayer then -- no SelectedPlayer means no move
				if doMove (Players[1], GUI.selectedPlayer, button.rank) then
					-- player has another move
				else
					-- other players
					AI_moves ()
				end
				updateGUI ()
			end
		
		end
	elseif #Players[1].cards == 0 then
		-- player has no cards
		table.insert (Statistics, 1, 'Player 1 has no cards;')
		AI_moves ()
		updateGUI ()
	end
end
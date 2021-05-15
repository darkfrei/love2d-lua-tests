-- main.lua
require ('test') -- lib
function love.load()
	scores = {test.load(1), test.load(2)} -- players "odd" and "even"
	for i, v in pairs (scores) do
		print (i..' '..type(v)..' score: '..v.score)
	end
end

function love.update(dt)
	local amount = math.random(1, 2)+math.random(1, 2)
	amount = (amount%2==1) and amount or -amount -- wins odd or even player; 
--	test:update(scores[1], amount) -- update score for odd
	
--	scores[2]:update(-amount) -- update score for even
	
--	print (scores[1].score .. ' '..print (scores[2].score))

end

function draw()
--	scores[1]:draw(1) -- print balance of odd
--	scores[2]:draw(2) -- print balance of even
end
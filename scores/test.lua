-- test.lua
test = {}
function test.load(score)
	print ('score '..type(score))
	return {score = score or 0}
end

--function test:update(amount)
--    self.score = self.score + amount -- Line of code throwing error
--end

--function test:draw(n)
    
--    love.graphics.print('Score: ' .. self.score, 20, n*20)
--end
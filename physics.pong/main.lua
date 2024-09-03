-- license CC0 darkfrei 2024

-- pong game with Love2D
local xg, yg = 0, 0
local world = love.physics.newWorld (xg, yg)

local windowWidth = love.graphics.getWidth ()
local windowHeight = love.graphics.getHeight ()

local game = {paddle1 = {score = 0}, paddle2 = {score = 0}, ball = {score = 0},
	minY = 0,
	maxY = windowHeight,
	maxBallScore = 0
}


local function beginContact(a, b, coll)
--	local userDataA = a:getUserData()
--	local userDataB = b:getUserData()

--	if (userDataA == "ball" and (userDataB == "paddle1" or userDataB == "paddle2")) or
--	(userDataB == "ball" and (userDataA == "paddle1" or userDataA == "paddle2")) then
	game.ball.score = game.ball.score + 1
--	end
	love.window.setTitle (game.ball.score)
end

function love.load ()

	local paddle1 = game.paddle1
	paddle1.body = love.physics.newBody(world, 50, windowHeight / 2, "kinematic")
	paddle1.shape = love.physics.newRectangleShape(20, 60)
	paddle1.fixture = love.physics.newFixture(paddle1.body, paddle1.shape)

	local paddle2 = game.paddle2
	paddle2.body = love.physics.newBody(world, windowWidth - 50, windowHeight / 2, "kinematic")
--	paddle2.shape = love.physics.newRectangleShape(20, 60)
	paddle2.shape = love.physics.newPolygonShape(-10,-30, 10,-30, 10, 30, -10,30, -15, 10, -15,-10)
	paddle2.fixture = love.physics.newFixture(paddle2.body, paddle2.shape)

	-- create the ball using physics bodies
	local ball = game.ball
	ball.body = love.physics.newBody(world, windowWidth / 2, windowHeight / 2, "dynamic")
	ball.shape = love.physics.newCircleShape(10)
	ball.fixture = love.physics.newFixture(ball.body, ball.shape)
	ball.fixture:setRestitution(1.01) -- make the ball bouncy

	-- initial ball velocity
	ball.body:setLinearVelocity(300, 300)

	world:setCallbacks(beginContact)
	
	love.window.setTitle (game.ball.score)
end


function love.update(dt)
	-- update the physics world
	world:update(dt)

	local paddleBody1 = game.paddle1.body
	local paddleBody2 = game.paddle2.body
	local ballBody = game.ball.body

	-- paddle 1 movement (controlled by W and S)
	if love.keyboard.isDown("w") then
		local y = paddleBody1:getY() - 400 * dt
		paddleBody1:setY(math.max (y, game.minY))
	elseif love.keyboard.isDown("s") then
		local y = paddleBody1:getY() + 400 * dt
		paddleBody1:setY(math.min(y, game.maxY))
	end

	-- paddle 2 movement (controlled by UP and DOWN arrow keys)
	if love.keyboard.isDown("up") then
		local y = paddleBody2:getY() - 400 * dt
		paddleBody2:setY(math.max (y, game.minY))
	elseif love.keyboard.isDown("down") then
		local y = paddleBody2:getY() + 400 * dt
		paddleBody2:setY(math.min(y, game.maxY))
	end


	-- check for ball collision with the window edges and reset position if needed
	local ballX, ballY = ballBody:getPosition()
	if ballY < 0 or ballY > windowHeight then
		local vx, vy = ballBody:getLinearVelocity()
		ballBody:setLinearVelocity(vx, -vy)  -- Reverse Y velocity
	end

	-- reset the ball if it goes off screen
	if ballX < 0 or ballX > windowWidth then
		if ballX < 0 then
			game.paddle2.score = game.paddle2.score + 1
		else
			game.paddle1.score = game.paddle1.score + 1
		end

		game.ball.score = 0 -- reset ball score on drop
		love.window.setTitle (game.ball.score)
		
		ballBody:setPosition(windowWidth / 2, windowHeight / 2)
		local vx, vy = ballBody:getLinearVelocity()
		ballBody:setLinearVelocity(-vx, vy)
	end


end

function love.draw()
	local paddleBody1 = game.paddle1.body
	local paddleBody2 = game.paddle2.body
	local ballBody = game.ball.body

	-- draw paddles
	love.graphics.polygon("fill", paddleBody1:getWorldPoints(game.paddle1.shape:getPoints()))
	love.graphics.polygon("fill", paddleBody2:getWorldPoints(game.paddle2.shape:getPoints()))

	-- draw ball
	love.graphics.circle("fill", ballBody:getX(), ballBody:getY(), game.ball.shape:getRadius())
end
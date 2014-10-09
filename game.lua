---------------------------------------------------------------------------------------
-- Simul Play
-- TA-PRE-1
--
-- Silicon Valley Code Camp 2014 Presentation
--
-- Copyright Tinker Academy 2014
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
-- Questions about our Beginner or AP Level Computer Science classes?
-- Email us at classes@tinkeracademy.com
---------------------------------------------------------------------------------------

require "main"
require "tinkeracademy"

ball = nil

function onBallTapped(event)
	addScore()
	math.randomseed(os.time())
	local randomXImpulse = math.random(500, 1000)
	local randomYImpulse = math.random(-1000, -500)
	ball:applyLinearImpulse(randomXImpulse, randomYImpulse, ball.x, ball.y)
	ball:applyAngularImpulse(100)
end

function myScore(score) 
	displayScore(score)
end

function myTurn(score)
	displayScore(score)
	if (ball ~= nil) then
		ball:removeSelf()
	end
	ball = display.newImage( "soccer_ball.png", 180, -50 )
	math.randomseed(os.time())
	ball.x = math.random(60, 240)	
	ball.rotation = 5
	ball:addEventListener("tap", onBallTapped)
	physics.addBody( ball, { density=3.0, friction=0.5, bounce=0.8 } )
end

function startGame()
	initializeGame()
	registerMyTurn(myTurn)
	registerMyScore(myScore)
	listenToCollisionEvents()
end

function onCollision(event)	
	if (event.phase == "began") then
		if (event.object1 == ball and event.object2 == ground) then
			resetScore()
		elseif (event.object1 == ground and event.object2 == ball) then
			resetScore()
		end
	end
end

function listenToCollisionEvents()
	Runtime:addEventListener( "collision", onCollision )
end



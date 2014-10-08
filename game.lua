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
	ball:applyLinearImpulse(mul * 100, -500, ball.x, ball.y)
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
	ball.x = math.random(40, 280)	
	ball:addEventListener("tap", onBallTapped)
	physics.addBody( ball, { density=3.0, friction=0.5, bounce=0.8 } )
end

function startGame()
	initializeGame()
	registerMyTurn(myTurn)
	registerMyScore(myScore)
end

function onCollision(event)
	if (event.phase == "began") then
		if (event.object1 == ball and event.object2 == ground) then
			resetScore()
		end
	end
end

Runtime:addEventListener( "collision", onCollision )



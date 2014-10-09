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

sky = display.newImage( "bkg_clouds.png", 160, 195 )

ground = display.newImage( "ground.png", 160, 445 )

physics = require( "physics" )
physics.start()

physics.addBody( ground, "static", { friction=0.5, bounce=0.3 } )

ball = display.newImage( "soccer_ball.png", 180, -50 )
ball.rotation = 5
physics.addBody( ball, { density=3.0, friction=0.5, bounce=0.8 } )

widget = require("widget")

scoreButton = widget.newButton
{
	id = "score",
	isEnabled = false,
	fontSize = 48,
	font = "Arial",
	x = 48,
	y = 48,
	textOnly = true,
	labelColor = { default={ 1, 1, 0 } }
}

function displayScore(score)
	scoreButton:setLabel(score)
end

displayScore(0)

startButton = widget.newButton
{
	id = "start",
	label = "START",
	fontSize = 48,
	font = "Arial",
	x = 160,
	y = 240,
	labelColor = { default={ 0, 1, 0 }, over={0, 1, 0} }
}

require "game"

function startButtonTappedListener(event)
	startButton:removeSelf()
	startGame()
end

startButton:addEventListener("tap", startButtonTappedListener)













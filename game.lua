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

uuid = require("uuid")

user_uid = uuid.new()

IP = "192.168.1.5"

NEXT_TURN_URL = "http://"..IP.."/SimulPlay/nextturn"

ADD_SCORE_URL =  "http://"..IP.."/SimulPlay/addscore"

RESET_SCORE_URL = "http://"..IP.."/SimulPlay/resetscore"

myTurnCallback = nil

local physics = require("physics")

local json = require("json")

local ball = nil

-------------------------------------------------------------------------------
-- Game Logic
-------------------------------------------------------------------------------
function onBallTapped(event)
	kickBall()
end

function onGameUpdate(score, shouldDropBall)
	displayScore(score)
	if shouldDropBall then
		dropBall()	
	end
end

function startGame()
	initializeGame(onGameUpdate)
end

-------------------------------------------------------------------------------
-- Game API
-------------------------------------------------------------------------------
function initializeGame(callback, debug)
	debugMode = debug or false
	myTurnCallback = callback
	startPlayTimer()
	listenToCollisionEvents()
end

function kickBall()
	math.randomseed(os.time())
	local randomXImpulse = math.random(500, 1000)
	local randomYImpulse = math.random(-1000, -500)
	ball:applyLinearImpulse(randomXImpulse, randomYImpulse, ball.x, ball.y)
	ball:applyAngularImpulse(100)
	addScore()
end

function dropBall()
	createBall()
end

-------------------------------------------------------------------------------
-- Helper Functions
-------------------------------------------------------------------------------

function createBall()
	if (ball ~= nil) then
		ball:removeSelf()
	end
	math.randomseed(os.time())
	local xpos = 0
	local ypos = 0
	local linearXImpulse = 0
	local linearYImpulse = 0
	local location = math.random(1,3)
	if (location == 1) then
		ball = display.newImage( "soccer_ball.png", -50, 60 )
		linearXImpulse = math.random(200, 400)
		linearYImpulse = math.random(-200, -100)
	elseif (location == 2) then
		ball = display.newImage( "soccer_ball.png", 370, 60 )
		linearXImpulse = math.random(-400, -200)
		linearYImpulse = math.random(-200, -100)
	else
		ball = display.newImage( "soccer_ball.png", 180, -50 )
		linearXImpulse = math.random(-200, 200)
		linearYImpulse = math.random(-200, -100)
	end
	local dampen = 4
	physics.addBody( ball, { density=3.0, friction=0.5, bounce=0.8 } )
	ball:applyLinearImpulse(linearXImpulse/dampen, linearYImpulsedampen, ball.x, ball.y)
	ball:applyAngularImpulse(100)
	ball:addEventListener("tap", onBallTapped)
end

function addScore()
	logText("GREAT!!!")
	local url_params = "?user_uid="..user_uid
	local url = ADD_SCORE_URL..url_params
	network.request( url, "GET", networkListener)
end

function resetScore()
	logText("OOPS!")
	local url_params = "?user_uid="..user_uid
	local url = RESET_SCORE_URL..url_params
	network.request( url, "GET", networkListener)
end

-------------------------------------------------------------------------------
-- Network listener
-------------------------------------------------------------------------------
function networkListener(event)
	if (event.phase == "ended") then
		local decoded, pos, msg = json.decode(event.response)
		if decoded then
			server_user_uid = decoded.user_uid
			server_score = decoded.score
			if (server_user_uid == user_uid) then
				debugText("YOUR TURN!")
				myTurnCallback(server_score, true)
			else
				debugText("OTHERS TURN!")
				myTurnCallback(server_score, false)
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Game Timer
-------------------------------------------------------------------------------
function updateTimer()
	local url_params = "?user_uid="..user_uid
	local url = NEXT_TURN_URL..url_params
	network.request( url, "GET", networkListener)
end

function startPlayTimer()
	timer.performWithDelay( 5000, updateTimer, 0 )
end

-------------------------------------------------------------------------------
-- Collision Detection
-------------------------------------------------------------------------------
function onCollision(event)	
	if (event.phase == "began") then
		if (event.x > 0 and event.x < 320) then
			if (event.object1 == ball and event.object2 == ground) then
				resetScore()
			elseif (event.object1 == ground and event.object2 == ball) then
				resetScore()
			end
		end
	end
end

function listenToCollisionEvents()
	Runtime:addEventListener( "collision", onCollision )
end

-------------------------------------------------------------------------------
-- Logging
-------------------------------------------------------------------------------
debugMode = false

debugButton = widget.newButton
{
	id = "debug",
	isEnabled = false,
	fontSize = 12,
	font = "Arial",
	x = 240,
	y = 0,
	textOnly = true,
	labelColor = { default={ 1, 1, 0 } }
}

function debugText(text)
	if (debugMode) then
		debugButton:setLabel(text)
	end
end

function logText(text)
	debugButton:setLabel(text)
end



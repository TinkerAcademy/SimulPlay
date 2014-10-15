---------------------------------------------------------------------------------------
-- Simul Play
-- TA-PRE-1
--
-- Silicon Valley Code Camp 2014 Presentation
--
-- Copyright Tinker Academy 2014
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
-- Questions about this code?
---
-- Email us at classes@tinkeracademy.com
---------------------------------------------------------------------------------------

-- loads the "main" module
require "main"

-- Game Configuration
-- This Game runs in 2 modes
-- 	 locally - requires no server setup, however only 1 player gets to play
--	 server  - requires a Java J2EE Servlet Server setup, the group gets to play, YAY!
gameConfig = 
{
	-- Server IP Address
	IP = "192.168.1.5",
	-- SimulPlay = true 
	-- Requires Server Setup, see the documentation
	simulPlay = false	
}

-- Loads the uuid module
-- Corona provides this module for you
uuid = require("uuid")

-- Unique User Id for this game launch
-- Read more about UUIDs at wikipedia
-- http://en.wikipedia.org/wiki/Universally_unique_identifier
user_uid = uuid.new()

-- Server URL to request the next turn
NEXT_TURN_URL = "http://"..gameConfig.IP.."/SimulPlay/nextturn"

-- Server URL to add to the group score
ADD_SCORE_URL =  "http://"..gameConfig.IP.."/SimulPlay/addscore"

-- Server URL to reset the group score (Oops!)
RESET_SCORE_URL = "http://"..gameConfig.IP.."/SimulPlay/resetscore"

myTurnCallback = nil

-- Loads the physics module
-- Corona provides this module for you
-- The module uses Box2D as the underlying physics engine
local physics = require("physics")

-- Loads the json module
-- json stands for Javascript Object Notation and is very popular
-- Read up about JSON at Wikipedia
-- http://en.wikipedia.org/wiki/JSON
local json = require("json")

-- The intro ball. 
-- This ball will have physics applied to it and 
-- will be removed from the Scene as soon as the START button
-- is clicked
local ball = nil

-- Keeps track if local score
-- Local score is used during local game play (no server)
local local_score = 0

-------------------------------------------------------------------------------
-- Game Logic
-------------------------------------------------------------------------------
-- The Game Logic for when the ball is tapped
-- Tapping the ball is our "kick" action
function onBallTapped(event)
	kickBall()
end

-- The Game Logic for when the game should be updated
-- The Game is updated regularly every 5 seconds 
-- based on a timer
function onGameUpdate(score, shouldDropBall)
	displayScore(score)
	if shouldDropBall then
		dropBall()	
	end
end

--- The Game Logic for when the game starts
--- At Game Start the game should
--- 	Start the Game Timer (to update the game)
---		Listen to collision events
function startGame()
	initializeGame(onGameUpdate)
end

-------------------------------------------------------------------------------
-- Game API
-------------------------------------------------------------------------------

-- Game API to initialize the game
-- Starts the Game Timer
-- Listens to Collision Events
function initializeGame(callback, debug)
	debugMode = debug or false
	myTurnCallback = callback
	startPlayTimer()
	listenToCollisionEvents()
end

-- Game API on kicking the ball
-- We want to simulate a real life kick
-- Real life kicks are impulse forces
-- a quick force applied over a short duration
-- Like what a Bruce Lee or a Chuck Norris would do 
-- on a pile of bricks :)
-- In physics, Forces has a direction and an amount
-- Here we are controlling the amount in both the X and Y direction
function kickBall()
	math.randomseed(os.time())
	local randomXImpulse = math.random(500, 1000)
	local randomYImpulse = math.random(-1000, -500)
	ball:applyLinearImpulse(randomXImpulse, randomYImpulse, ball.x, ball.y)
	ball:applyAngularImpulse(100)
	addScore()
end

-- Game API on dropping the ball
-- The game creates a new ball before dropping the ball
function dropBall()
	createBall()
end

-------------------------------------------------------------------------------
-- Network listener
-------------------------------------------------------------------------------

-- This is code that listens to network events
-- The mobile phone is constantly monotoring the connection to 
-- the mobile network or the WiFi
-- We had earlier made a reqquest to the network to provide us with data
-- and had provided this function as the "listener" to listen to when the 
-- data arrives. As soon as data arrives from the network, the listener
-- is invoked with the network event
-- the network event contains interesting information about the request
function networkListener(event)
	if (event.phase == "ended") then
		local server_msg, pos, status = json.decode(event.response)
		playTurn(server_msg)
	end
end

-------------------------------------------------------------------------------
-- Helper Functions
-------------------------------------------------------------------------------

-- Helper function to create a ball at a location, add it as a physics body
-- so that it gets dropped and listen to ball tapped events
-- This code prepares the ball to be thrown from 1 of 3 different locations
-- 	location 1 = left of the screen 
-- 	location 2 = right of the screen
-- 	location 3 = top middle of the screen
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

-- Helper function to add to the group score maintained by the server
function addServerScore()
	local url_params = "?user_uid="..user_uid
	local url = ADD_SCORE_URL..url_params
	network.request( url, "GET", networkListener)
end

-- Helper function to add to the local score maintained locally
function addLocalScore()
	local_score = local_score + 100
	playTurn {
		score = local_score
	}
end

-- Helper function to add to the score (local or server)
function addScore()
	logText("GREAT!!!")
	if gameConfig.simulPlay then
		addServerScore()
	else
		addLocalScore()
	end		
end

-- Helper function to reset the group score maintained by the server
function resetServerScore()
	local url_params = "?user_uid="..user_uid
	local url = RESET_SCORE_URL..url_params
	network.request( url, "GET", networkListener)
end

-- Helper function to reset the local score maintained locally
function resetLocalScore()
	local_score = 0
	playTurn {
		score = local_score
	}
end

-- Helper function to reset the score
function resetScore()
	logText("OOPS!")
	if gameConfig.simulPlay then
		resetServerScore()
	else
		resetLocalScore()
	end
end


function playTurn(msg)
	if msg then
		next_turn_user_uid = msg.user_uid
		score = msg.score
		if (next_turn_user_uid == user_uid) then
			debugText("YOUR TURN!")
			myTurnCallback(score, true)
		else
			debugText("OTHERS TURN!")
			myTurnCallback(score, false)
		end
	end
end

function requestServerTurn()
	local url_params = "?user_uid="..user_uid
	local url = NEXT_TURN_URL..url_params
	network.request( url, "GET", networkListener)
end

function requestLocalTurn()
	playTurn {
		user_uid = user_uid,
		score = local_score
	}
end



-------------------------------------------------------------------------------
-- Game Timer
-------------------------------------------------------------------------------
function updateTimer()
	if gameConfig.simulPlay then
		requestServerTurn()
	else
		requestLocalTurn()
	end
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



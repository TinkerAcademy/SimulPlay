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

uuid = require("uuid")

user_uid = uuid.new()

NEXT_TURN_URL = "http://192.168.1.5/SimulPlay/nextturn"

ADD_SCORE_URL = "http://192.168.1.5/SimulPlay/addscore"

RESET_SCORE_URL = "http://192.168.1.5/SimulPlay/resetscore"

myTurnCallback = nil

myScoreCallback = nil

debugMode = false

local json = require("json")

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

function nextTurnNetworkListener(event)
	if (event.phase == "ended") then
		print "next turn event"
		local decoded, pos, msg = json.decode(event.response)
		if decoded then
			server_user_uid = decoded.user_uid
			server_score = decoded.score
			if (server_user_uid == user_uid) then
				debugText("YOUR TURN!")
				myTurnCallback(server_score)
			else
				debugText("OTHERS TURN!")
				myScoreCallback(server_score)
			end
		end
	end
end

function updateTimer()
	local url_params = "?user_uid="..user_uid
	local url = NEXT_TURN_URL..url_params
	network.request( url, "GET", nextTurnNetworkListener)
end

function registerMyTurn(callback)
	myTurnCallback = callback
end

function registerMyScore(callback)
	myScoreCallback = callback
end

function addScoreNetworkListener(event)
	if (event.phase == "ended") then
		local decoded, pos, msg = json.decode(event.response)
		if decoded then
			server_score = decoded.score
			myScoreCallback(server_score)
		end
	end
end

function addScore()
	logText("GREAT!!!")
	local url_params = "?user_uid="..user_uid
	local url = ADD_SCORE_URL..url_params
	network.request( url, "GET", addScoreNetworkListener)
end

function resetScoreNetworkListener(event)
	if (event.phase == "ended") then
		local decoded, pos, msg = json.decode(event.response)
		if decoded then
			server_score = decoded.score
			myScoreCallback(server_score)
		end
	end
end

function resetScore()
	logText("OOPS!")
	local url_params = "?user_uid="..user_uid
	local url = RESET_SCORE_URL..url_params
	network.request( url, "GET", resetScoreNetworkListener)
end

function initializeGame(debug)
	debugMode = debug or false
	print("initialize( )")
	timer.performWithDelay( 5000, updateTimer, 0 )
end

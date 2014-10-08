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

local json = require("json")

function nextTurnNetworkListener(event)
	if (event.phase == "ended") then
		print "next turn event"
		local decoded, pos, msg = json.decode(event.response)
		if decoded then
			server_user_uid = decoded.user_uid
			server_score = decoded.score
			if (server_user_uid == user_uid) then
				myTurnCallback(server_score)
			else
				myScoreCallback(server_score)
			end
		end
	end
end

function updateTimer()
	print "timer updated"
	local params = {}
	params.user_uid = user_uid
	network.request( NEXT_TURN_URL, "GET", nextTurnNetworkListener, params)
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
	local params = {}
	params.user_uid = user_uid
	network.request( ADD_SCORE_URL, "GET", addScoreNetworkListener, params)
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
	local params = {}
	params.user_uid = user_uid
	network.request( RESET_SCORE_URL, "GET", resetScoreNetworkListener, params)
end

function initializeGame()
	print("initialize( )")
	timer.performWithDelay( 2000, updateTimer, 0 )
end

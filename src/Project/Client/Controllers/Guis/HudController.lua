--[[
	Shows data about how how much money the player has or how many kills they got etc
]]

---------------------------Roblox Services----------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

----------------------------Knit------------------------------

local Knit = require(ReplicatedStorage.Packages.Knit)

---------------------------Constants----------------------------

local GAME_TIME_LEFT_ATTR: string = "GameTimeLeft"
local KILLS_ATTR: string = "Kills"
local TEAM_ATTR: string = "Team"

local BLUE_TEAM: string = "Blue"
local RED_TEAM: string = "Red"

----------------------------Fields------------------------------

local gameDecisionNum: number = 0
local winner: TextLabel
local gameTimeLeft: TextLabel
local gameTimeFrame: Frame
local blueScore: TextLabel
local redScore: TextLabel

----------------------------Service/Controller Dependencies------------------------------

local DataController
local SoundController
local GameService

---------------------------Knit Controller----------------------------

local HudController = Knit.CreateController({
	Name = "HudController"
})

------------------------Local Functions-------------------------

--
local function countScore(scoreLabel: TextLabel, team: string): ()
	local function count(): ()
		local score: number = 0

		for _: number, player: Player in ipairs(Players:GetPlayers()) do
			if team == player:GetAttribute(TEAM_ATTR) then
				local kills: number = player:GetAttribute(KILLS_ATTR) or 0
				score += kills
			end
		end

		scoreLabel.Text = string.format("%02i", score)
	end

	local function playerAdded(player: Player): ()
		player:GetAttributeChangedSignal(TEAM_ATTR):Connect(count)
		player:GetAttributeChangedSignal(KILLS_ATTR):Connect(count)
		count()
	end

	Players.PlayerAdded:Connect(playerAdded)

	for _: number, player: Player in ipairs(Players:GetPlayers()) do
		playerAdded(player)
	end
end

--
local function showGameWinner(gameWinner: string?): ()
	gameDecisionNum += 1
	local localGameDecisionNum = gameDecisionNum

	if not gameWinner then
		winner.Text = "TIE!"
		winner.TextColor3 = blueScore.TextColor3:Lerp(redScore.TextColor3, 0.5)
	else
		winner.TextColor3 = if gameWinner == BLUE_TEAM then
			blueScore.TextColor3
		else
			redScore.TextColor3

		winner.Text = `{string.upper(gameWinner)} WINS!`
	end

	redScore.Visible = false
	blueScore.Visible = false
	gameTimeFrame.Visible = false
	winner.Visible = true
	
	task.delay(3, function(): ()
		if localGameDecisionNum ~= gameDecisionNum then
			return
		end

		redScore.Visible = true
		blueScore.Visible = true
		gameTimeFrame.Visible = true
		winner.Visible = false
	end)
end

--
local function bridgeRegenTimeLeftChanged(): ()
	local timeLeft: number = workspace:GetAttribute(GAME_TIME_LEFT_ATTR)

	if not timeLeft then
		return
	end

	local minutesLeft: number = math.floor(timeLeft / 60)
	timeLeft -= minutesLeft * 60

	-- two digits at minimum for each
	minutesLeft = string.format("%02i", minutesLeft)
	timeLeft = string.format("%02i", timeLeft)

	gameTimeLeft.Text = `{minutesLeft}:{timeLeft}`
end

------------------------Public Methods------------------------

-- find all ui elements we need and then update the labels with datacontroller events
function HudController:GuiLoaded(hud: ScreenGui): ()
	local rightMiddleFrame: Frame = hud:WaitForChild("RightMiddle")
	local topMiddleFrame: Frame = hud:WaitForChild("TopMiddle")

	gameTimeFrame = topMiddleFrame:WaitForChild("GameTime")
	blueScore = topMiddleFrame:WaitForChild("BlueScore")
	redScore = topMiddleFrame:WaitForChild("RedScore")

	gameTimeLeft = gameTimeFrame:WaitForChild("TimeLeft")
	winner = topMiddleFrame:WaitForChild("Winner")

	local currencies: Frame = rightMiddleFrame:WaitForChild("Currencies")
	local killsLabel: TextLabel = currencies:WaitForChild("Kills"):WaitForChild("Kills")

	local killsKey: string = "kills"
	local lastKills: number
	
	DataController:OnValueChanged(Knit.Player, killsKey, function(kills: number): ()
		if lastKills then
			-- play a amusing sound when the player gets a kill
			SoundController:PlaySound("KillBell")
		end

		lastKills = kills
		killsLabel.Text = tostring(kills)
	end, true)

	workspace:GetAttributeChangedSignal(GAME_TIME_LEFT_ATTR):Connect(bridgeRegenTimeLeftChanged)
	bridgeRegenTimeLeftChanged()

	GameService.GameDecision:Connect(showGameWinner)

	countScore(blueScore, BLUE_TEAM)
	countScore(redScore, RED_TEAM)
end

------------------------Lifetime Methods------------------------

-- set global controller variables
function HudController:KnitInit(): ()
	DataController = Knit.GetController("DataController")
	SoundController = Knit.GetController("SoundController")
	GameService = Knit.GetService("GameService")
end

return HudController
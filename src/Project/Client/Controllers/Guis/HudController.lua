--[[
	Shows data about how how much money the player has or how many kills they got etc
]]

---------------------------Roblox Services----------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")

----------------------------Knit------------------------------

local Knit = require(ReplicatedStorage.Packages.Knit)

---------------------------Constants----------------------------

local REGEN_TIME_LEFT_ATTR: string = "RegenTimeLeft"

----------------------------Service/Controller Dependencies------------------------------

local DataController
local SoundController

---------------------------Knit Controller----------------------------

local HudController = Knit.CreateController({
	Name = "HudController"
})

------------------------Public Methods------------------------

-- find all ui elements we need and then update the labels with datacontroller events
function HudController:GuiLoaded(hud: ScreenGui): ()
	local rightMiddleFrame: Frame = hud:WaitForChild("RightMiddle")
	local topMiddleFrame: Frame = hud:WaitForChild("TopMiddle")
	local gameTimeFrame: Frame = topMiddleFrame:WaitForChild("GameTime")
	local gameTimeLeft: TextLabel = gameTimeFrame:WaitForChild("TimeLeft")
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

	local function bridgeRegenTimeLeftChanged(): ()
		local timeLeft: number = workspace:GetAttribute(REGEN_TIME_LEFT_ATTR)

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

	workspace:GetAttributeChangedSignal(REGEN_TIME_LEFT_ATTR):Connect(bridgeRegenTimeLeftChanged)
	bridgeRegenTimeLeftChanged()
end

------------------------Lifetime Methods------------------------

-- set global controller variables
function HudController:KnitInit(): ()
	DataController = Knit.GetController("DataController")
	SoundController = Knit.GetController("SoundController")
end

return HudController
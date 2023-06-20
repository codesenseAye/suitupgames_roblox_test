--[[
    Handles replacing the breakable parts in the map (the bridges etc)
    Gives players a teams
]]

------------------------------Roblox Services-----------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

------------------------------Knit-----------------------------------

local Knit = require(ReplicatedStorage.Packages.Knit)

------------------------------Util-----------------------------------

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Timer = require(ReplicatedStorage.Packages.Timer)

------------------------------Constants-----------------------------------

local GAME_TIME: number = 60 * 3

local GAME_TIME_LEFT_ATTR: string = "GameTimeLeft"
local TEAM_ATTR: string = "Team"
local KILLS_ATTR: string = "Kills"

local RED_TEAM: string = "Red"
local BLUE_TEAM: string = "Blue"

------------------------------Fields-----------------------------------

------------------------------Service Dependencies-----------------------------------

------------------------------Knit Service-----------------------------------

local GameService = Knit.CreateService({
    Name = "GameService",

    Client = {
        GameDecision = Knit.CreateSignal()
    }
})

------------------------------Local Functions-----------------------------------

-- delete the old map and clone/parent a new one
local function regenMap(): ()
    -- using ServerStorage.Map so we are alerted with an error incase-
    -- we do not update the string literal after we might have change the model name
    local oldMap: Folder = workspace:FindFirstChild(ServerStorage.Map.Name)

    if oldMap then
        oldMap:Destroy()
    end

    local newMap: Model = ServerStorage.Map:Clone()
    newMap.Parent = workspace
end

-- return the team that has the least amount of people on it
local function getLeastPersonTeam(): string
    local blueTeamPeople: number = 0
    local redTeamPeople: number = 0

    for _: number, player: Player in ipairs(Players:GetPlayers()) do
        local team: string = player:GetAttribute(TEAM_ATTR)
        
        if team == BLUE_TEAM then
            blueTeamPeople += 1
        elseif team == RED_TEAM then
            redTeamPeople += 1
        end
    end

    return if blueTeamPeople > redTeamPeople then
        RED_TEAM
    else
        BLUE_TEAM
end

-- randomize the teams that people are on and remove their kills count
local function shuffleTeamsAndWipeKills(): ()
    local allPlayers: {Player} = Players:GetPlayers()

    TableUtil.Shuffle(allPlayers)

    for i: number, player: Player in ipairs(allPlayers) do
        local team: string = i % 2 == 0 and RED_TEAM or BLUE_TEAM
        player:SetAttribute(TEAM_ATTR, team)
        player:SetAttribute(KILLS_ATTR, 0)

        -- results in the respawn of the character
        local char: Model = player.Character

        if not char then
            continue
        end
        
        char:Destroy()
    end
end

-- fire the game decision remote with the name of the team that one by counting the kills of each player
local function declareWinnerOfGame(): ()
    local blueKills: number = 0
    local redKills: number = 0

    for _: number, player: Player in ipairs(Players:GetPlayers()) do
        local team: string = player:GetAttribute(TEAM_ATTR)
        local kills: number = player:GetAttribute(KILLS_ATTR) or 0

        if team == BLUE_TEAM then
            blueKills += kills
        elseif team == RED_TEAM then
            redKills += kills
        end
    end

    local winner: string = if blueKills > redKills then
        BLUE_TEAM
    elseif redKills > blueKills then
        RED_TEAM
    else
        nil
    
    GameService.Client.GameDecision:FireAll(winner)
end

--
local function playerAdded(player: Player): ()
    local leastPersonTeam: string = getLeastPersonTeam()

    player:SetAttribute(TEAM_ATTR, leastPersonTeam)
end

------------------------------Public Methods-----------------------------------

-- set the kills count up by 1 of the player passed
function GameService:IncrementKills(player: Player): ()
    local currentKills: number = player:GetAttribute(KILLS_ATTR) or 0
    currentKills += 1

    player:SetAttribute(KILLS_ATTR, currentKills)
end

------------------------------Private Methods-----------------------------------

------------------------------Lifetime Methods-----------------------------------

-- start up logic
function GameService:KnitStart(): ()
    Players.PlayerAdded:Connect(playerAdded)

    for _: number, player: Player in ipairs(Players:GetPlayers()) do
        playerAdded(player)
    end

    local lastRegen: number = 0

    -- every second count how much time is left in the game and do the necessary steps at the end when the game ends
    Timer.Simple(1, function(): ()
        local now: number = workspace:GetServerTimeNow()
        local timeLeft: number = math.max(0, math.ceil(GAME_TIME - (now - lastRegen)))

        workspace:SetAttribute(GAME_TIME_LEFT_ATTR, timeLeft)
    
        if timeLeft > 0 then
            return
        end

        -- dont declare a winner when there was no last game
        if lastRegen ~= 0 then
            declareWinnerOfGame()
            shuffleTeamsAndWipeKills()
        end

        lastRegen = now

        regenMap()
    end)
end

return GameService
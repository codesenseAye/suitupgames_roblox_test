--[[
    Puts green circles over top the heads of your teammates
    so that you can identify who is your enemy
]]

------------------------------Roblox Services-----------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------Knit-----------------------------------

local Knit = require(ReplicatedStorage.Packages.Knit)

------------------------------Util-----------------------------------

local Trove = require(ReplicatedStorage.Packages.Trove)

------------------------------Constants-----------------------------------

local TEAM_ATTR: string = "Team"
local BLUE_TEAM: string = "Blue"

------------------------------Knit Service-----------------------------------

local TeamIdentificationController = Knit.CreateController({
    Name = "TeamIdentificationController"
})

------------------------------Local Functions-----------------------------------

-- detect when the owner player of this character's team changes and our team changes
-- then update the team identification billboard with the correct enabled state and color
local function characterAdded(char: Model): ()
    local player: Player = Players:GetPlayerFromCharacter(char)

    local billboardGui: BillboardGui = ReplicatedStorage.Assets.TeamIdentification:Clone()
    billboardGui.Parent = char

    local function teamChanged(): ()
        local myTeam: string = Knit.Player:GetAttribute(TEAM_ATTR)
        local team: string = player:GetAttribute(TEAM_ATTR)

        billboardGui.Circle.BackgroundColor3 = if team == BLUE_TEAM then
            Color3.fromRGB(0, 221, 255)
        else
            Color3.new(1, 0, 0)
        
        billboardGui.Enabled = myTeam == team
    end

    local trove = Trove.new()
    trove:Add(billboardGui)

    trove:Connect(char.AncestryChanged, function(_, newParent: Instance?): ()
        if newParent == nil then
            trove:Destroy()
        end
    end)

    trove:Connect(player:GetAttributeChangedSignal(TEAM_ATTR), teamChanged)
    trove:Connect(Knit.Player:GetAttributeChangedSignal(TEAM_ATTR), teamChanged)

    teamChanged()
end

-- connect to any character that this player might have (ignore it if its our character)
local function playerAdded(player: Player): ()
    if player == Knit.Player then
        return
    end

    local char: Model = player.Character
    player.CharacterAdded:Connect(characterAdded)

    if char then
        characterAdded(char)
    end
end

------------------------------Lifetime Methods-----------------------------------

-- start up logic
function TeamIdentificationController:KnitStart(): ()
    Players.PlayerAdded:Connect(playerAdded)

    for _: number, player: Player in ipairs(Players:GetPlayers()) do
        playerAdded(player)
    end
end

return TeamIdentificationController
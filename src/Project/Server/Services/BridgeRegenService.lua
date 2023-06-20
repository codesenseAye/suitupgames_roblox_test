--[[
    Handles replacing the breakable parts in the map (the bridges etc)
]]

------------------------------Roblox Services-----------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

------------------------------Knit-----------------------------------

local Knit = require(ReplicatedStorage.Packages.Knit)

------------------------------Types-----------------------------------

local Types = require(ReplicatedStorage.Shared.Types)

------------------------------Util-----------------------------------

local Trove = require(ReplicatedStorage.Packages.Trove)
local Timer = require(ReplicatedStorage.Packages.Timer)

------------------------------Constants-----------------------------------

local REGEN_TIME: number = 60 * 4
local REGEN_TIME_LEFT_ATTR: string = "RegenTimeLeft"

------------------------------Fields-----------------------------------

------------------------------Service Dependencies-----------------------------------

------------------------------Knit Service-----------------------------------

local BridgeRegenService = Knit.CreateService({
    Name = "BridgeRegenService"
})

------------------------------Local Functions-----------------------------------

--
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

------------------------------Public Methods-----------------------------------

------------------------------Private Methods-----------------------------------

------------------------------Lifetime Methods-----------------------------------

-- start up logic
function BridgeRegenService:KnitStart(): ()
    local lastRegen: number = 0

    Timer.Simple(1, function(): ()
        local now: number = workspace:GetServerTimeNow()
        local timeLeft: number = math.max(0, math.ceil(REGEN_TIME - (now - lastRegen)))

        workspace:SetAttribute(REGEN_TIME_LEFT_ATTR, timeLeft)
    end)

    Timer.Simple(REGEN_TIME, function(): ()
        lastRegen = workspace:GetServerTimeNow()
        regenMap()
    end, true)
end

return BridgeRegenService
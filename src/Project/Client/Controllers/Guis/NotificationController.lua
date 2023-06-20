--[[
    Handles creating notifications for builds and tips
]]

------------------------------Roblox Services-----------------------------------

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------Knit-----------------------------------

local Knit = require(ReplicatedStorage.Packages.Knit)

------------------------------Types-----------------------------------

local Types = require(ReplicatedStorage.Shared.Types)

------------------------------Util-----------------------------------

local Trove = require(ReplicatedStorage.Packages.Trove)

------------------------------Constants-----------------------------------

local SEPCIAL_MODEL_NOTIFICATION_ATTR: string = "Notification"

------------------------------Fields-----------------------------------

local notification: ScreenGui

------------------------------Service & Controller Dependencies-----------------------------------

local DataController

------------------------------Knit Service-----------------------------------

local NotificationController = Knit.CreateController({
    Name = "NotificationController"
})

------------------------------Public Methods-----------------------------------

-- set the global notification screen gui variable
function NotificationController:GuiLoaded(...): ()
    notification = ...
    NotificationController:CreateNotification("Knock your opponents off the platform with your shotgun!", 15)
end

-- puts a notification on the screen with the text passed for a specified or unspecified amount of time
function NotificationController:CreateNotification(notificationText: string, presistTime: number): ()
    local notificationFrame: Frame = notification.CenterMiddle.Notifications.Template:Clone()
    notificationFrame.LayoutOrder = os.time() -- so that the earliest is at the bottom
    notificationFrame.Label.Text = notificationText
    notificationFrame.Name = "Notification"
    notificationFrame.Parent = notification.CenterMiddle.Notifications
    notificationFrame.Visible = true

    Debris:AddItem(notificationFrame, presistTime or 4)
end

------------------------------Lifetime Methods-----------------------------------

-- define global lifetime controllers / services
function NotificationController:KnitInit(): ()
    DataController = Knit.GetController("DataController")
end

return NotificationController
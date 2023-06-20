--[[
    Test elements of gun service to confirm that it atleast partially works
    this is never the same as testing the real game
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

return function(): ()
    local Knit = require(ReplicatedStorage.Packages.Knit)
    local GunService = Knit.GetService("GunService")

    local player: Player = game.Players.LocalPlayer

    -- makes a fake character so that we can call the gun service methods
    local function getFakeChar(): Model
        local fakeChar: Model = ReplicatedStorage.Assets.Blunderbuss.BlunderbussUnequippedPose.Rig:Clone()
        fakeChar.Parent = workspace
        Debris:AddItem(fakeChar, 5)
        
        player.Character = fakeChar

        task.defer(function(): ()
            fakeChar:Destroy()
        end)

        return fakeChar
    end

    describe("using a gun", function(): ()
        it("equipping the gun", function(): ()
            getFakeChar()
        
            expect(function(): ()
                GunService.Client:SetGunState(player, true)
            end).to.never.throw()
        end)

        it("shooting the gun", function(): ()
            local fakeChar: Model = getFakeChar()
            
            expect(function(): ()
                GunService.Client:RequestShoot(player, fakeChar.PrimaryPart.Position, Vector3.zAxis)
            end).to.never.throw()
        end)

        -- sus 
        it("trying to exploit the gun", function(): ()
            getFakeChar()
            
            local exploitivePosition: Vector3 = Vector3.new(500, 0, 0)

            expect(GunService.Client:RequestShoot(player, exploitivePosition, Vector3.xAxis)).never.to.be.ok()
        end)
        
        it("unequipping the gun", function(): ()
            getFakeChar()
        
            expect(function(): ()
                GunService.Client:SetGunState(player, false)
            end).to.never.throw()
        end)

        workspace.GunRays:Destroy()
    end)
end
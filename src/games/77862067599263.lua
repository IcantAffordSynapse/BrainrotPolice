-- Obby as a Brainrot

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    env.Farming = false
    env.Upgrade = false
    env.Collect = false
    env.Rebirth = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farmrots = setdata.farmrots or false
    setdata.upgr = setdata.upgr or false
    setdata.col = setdata.col or false
    setdata.Rebirth = setdata.Rebirth or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Farm Disco Meowl", section, setdata.farmrots, function(v)
        env.Farming = v
        env.setconfig("farmrots", v)
        if not env.Farming then return end

        while env.Farming do
            plr.Character:MoveTo(Vector3.new(9, 19, -493))
            task.wait(0.5)
            local Event = game:GetService("ReplicatedStorage").ThrowLuckyBlockRemotes.ThrowZoneBatVisual
            Event:FireServer(
                true
            )
            task.wait()
            local Event = game:GetService("ReplicatedStorage").ThrowLuckyBlockRemotes.ThrowStarted
            Event:FireServer()
            task.wait()
            local Event = game:GetService("ReplicatedStorage").ThrowLuckyBlockRemotes.ThrowBatHit
            Event:FireServer(
                nil,
                false
            )
            task.wait()
            local Event = game:GetService("ReplicatedStorage").ThrowLuckyBlockRemotes.ThrowBatTimingVfxCleanup
            Event:FireServer()
            task.wait()
            local Event = game:GetService("ReplicatedStorage").ThrowLuckyBlockRemotes.LuckyBlockLanded
            Event:FireServer(
                {
                    LandingPosition = Vector3.new(4, -99, 4514),
                    ItemName = "Meowl",
                    Rarity = "OG",
                    BlockName = "Uncommon Lucky Block",
                    LandingRarity = "OG",
                    Mutation = "Disco",
                    Power = 10.642112568062
                }
            )
            task.wait(0.5)
            plr.Character:MoveTo(Vector3.new(8, 21, -558))
            task.wait(0.5)
        end
    end)

    elements:Toggle("Auto Upgrade", section, setdata.upgr, function(v)
        env.Upgrade = v
        env.setconfig("upgr", v)
        if not env.Upgrade then return end

        while env.Upgrade do
            for i = 1, 10 do
                local Event = game:GetService("ReplicatedStorage").Events.RequestSlotUpgrade
                Event:FireServer(
                    "Floor1",
                    "Slot" .. tostring(i)
                )
            end
            for i = 1, 10 do
                local Event = game:GetService("ReplicatedStorage").Events.RequestSlotUpgrade
                Event:FireServer(
                    "Floor2",
                    "Slot" .. tostring(i)
                )
            end
            for i = 1, 10 do
                local Event = game:GetService("ReplicatedStorage").Events.RequestSlotUpgrade
                Event:FireServer(
                    "Floor3",
                    "Slot" .. tostring(i)
                )
            end
            task.wait(0.1)
        end

    end)

    elements:Toggle("Auto Collect", section, setdata.col, function(v)
        env.Collect = v
        env.setconfig("col", v)
        if not env.Collect then return end

        while env.Collect do
            for i, v in pairs(workspace["Plot_" .. plr.Name].Floor1.Slots:GetChildren()) do
                firetouchinterest(plr.Character.Head, v.CollectTouch, true)
                task.wait(0.2)
                firetouchinterest(plr.Character.Head, v.CollectTouch, false)
            end
            for i, v in pairs(workspace["Plot_" .. plr.Name].Floor2.Slots:GetChildren()) do
                firetouchinterest(plr.Character.Head, v.CollectTouch, true)
                task.wait(0.2)
                firetouchinterest(plr.Character.Head, v.CollectTouch, false)
            end
            for i, v in pairs(workspace["Plot_" .. plr.Name].Floor3.Slots:GetChildren()) do
                firetouchinterest(plr.Character.Head, v.CollectTouch, true)
                task.wait(0.2)
                firetouchinterest(plr.Character.Head, v.CollectTouch, false)
            end
            task.wait(3)
        end

    end)

    elements:Toggle("Auto Rebirth", section, setdata.Rebirth, function(v)
        env.Rebirth = v
        env.setconfig("Rebirth", v)
        if not env.Rebirth then return end

        while env.Rebirth do
            local Event = game:GetService("ReplicatedStorage").Events.RequestRebirth
            Event:FireServer()
            task.wait(3)
        end

    end)
end

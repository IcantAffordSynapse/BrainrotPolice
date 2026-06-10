-- DUMP

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    getgenv().AutoDig = false
    getgenv().AutoBuy = false
    getgenv().collect = false
    getgenv().stealfromall = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.autodig = setdata.autodig or false
    setdata.autobuy = setdata.autobuy or false
    setdata.autocollect = setdata.autocollect or false
    setdata.stealfromall = setdata.stealfromall or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local plr = game:GetService("Players").LocalPlayer

    local ShovelData = require(game:GetService("ReplicatedStorage").SharedSource.GameData.Shovels)

    elements:Toggle("Steal from all", section, setdata.stealfromall, function(v)
        setconfig("stealfromall", v)
        getgenv().stealfromall = v
        if not getgenv().stealfromall then return end
        while getgenv().stealfromall do
            pcall(function()
                for _,v in pairs(workspace.ActivePlots:GetChildren()) do
                    if v.Name ~= "Plot" and v.Name ~= tostring(plr.UserId) then

                        local Event = game:GetService("ReplicatedStorage").Network.RemoteEvents.LockpickGateOpen
                        Event:FireServer(
                            v,
                            30
                        )

                        task.wait()
                        for i, item in pairs(v.PlacedItems:GetChildren()) do
                            plr.Character:MoveTo(item.PrimaryPart.Position)
                            task.wait(0.5)
                            fireproximityprompt(item.PrimaryPart.Attachment.ProximityPrompt)
                            task.wait(0.5)
                            plr.Character:MoveTo(workspace.ActivePlots[tostring(plr.UserId)].TeleportPoint.Position)
                            task.wait(0.5)
                        end

                    end

                    task.wait()
                end
            end)

            task.wait(1)
        end
    end)

    elements:Toggle("Auto Dig", section, setdata.autodig, function(v)
        setconfig("autodig", v)
        getgenv().AutoDig = v
        if not getgenv().AutoDig then return end
        while getgenv().AutoDig do
            local Event = game:GetService("ReplicatedStorage").Network.RemoteFunctions.StartDigging
            Event:InvokeServer()

            task.wait(1)

            local Event = game:GetService("ReplicatedStorage").Network.RemoteFunctions.GetSelectedItem
            Event:InvokeServer(
                2
            )

            local Event = game:GetService("ReplicatedStorage").Network.RemoteEvents["0a1baf564dbb5375"]
            Event:FireServer(
                -1
            )

            local Event = game:GetService("ReplicatedStorage").Network.RemoteEvents["0a1baf564dbb5375"]
            Event:FireServer(
                0
            )

            task.wait(2)

            local Event = game:GetService("ReplicatedStorage").Network.RemoteEvents.EndDigging
            Event:FireServer(
                "Succeeded",
                3
            )

            task.wait(0.2)
        end
    end)

    elements:Toggle("Auto Buy", section, setdata.autobuy, function(v)
        setconfig("autobuy", v)

        getgenv().AutoBuy = v
        if not getgenv().AutoBuy then return end


        local RarityOrder = {"Mythic", "Legendary", "Epic","Rare", "Uncommon", "Common"}

        local function getBest()
            local money = game:GetService("Players").LocalPlayer.leaderstats.Doubloons.Value
            local best = nil

            for _, rarity in ipairs(RarityOrder) do
                local shovels = ShovelData:GetShovelsByRarity(rarity)
                for _, shovel in ipairs(shovels) do
                    if shovel.BaseCost <= money then
                        if not best or shovel.BaseCost > best.BaseCost then
                            best = shovel
                        end
                    end
                end
                if best then break end
            end

            return best
        end

        while getgenv().AutoBuy do
            local best = getBest()
            if best then
                local Event = game:GetService("ReplicatedStorage").Network.RemoteEvents["5844c2fc64759f91"]
                Event:FireServer({
                    ItemType = "Shovel",
                    Name = best.Name
                })
            end
            task.wait(5)
        end
    end)

    elements:Toggle("Auto Collect", section, setdata.autocollect, function(v)
        setconfig("autocollect", v)
        getgenv().collect = v
        if not getgenv().collect then return end
        while getgenv().collect do
            local Event = game:GetService("ReplicatedStorage").Network.RemoteEvents.CollectSavedPlotMoney
            Event:FireServer()
            task.wait(1)
        end
    end)
end

-- sail for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    getgenv().Farming = false
    getgenv().Selling = false
    getgenv().ChosenZone = nil
    getgenv().MaxPrice = 0

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farmrots = setdata.farmrots or false
    setdata.farmsell = setdata.farmsell or false
    setdata.farmzone = setdata.farmzone or "13"
    setdata.maxprice = setdata.maxprice or "0"
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local player = game:GetService("Players").LocalPlayer
    local zonesFold = workspace.Zones

    local function parseValue(str)
        local suffixes = {
            K = 1e3,
            M = 1e6,
            B = 1e9,
            T = 1e12,
            Q = 1e15,
        }
        
        local num, suffix = str:match("^([%d%.]+)([A-Za-z]*)")
        
        if not num then return 0 end
        
        num = tonumber(num) or 0
        suffix = suffix:upper()
        
        if suffixes[suffix] then
            return num * suffixes[suffix]
        end
        
        return num
    end


    elements:Textbox("Farm Zone (1-13)", section, setdata.farmzone, function(v)
        getgenv().setconfig("farmzone", v)
        getgenv().ChosenZone = zonesFold["Zone" .. v]
    end)

    elements:Toggle("Autofarm", section, setdata.farmrots, function(v)
        getgenv().setconfig("farmrots", v)
        if v then
            getgenv().Farming = true

            while getgenv().Farming do
                local char = player.Character
                local zone = getgenv().ChosenZone
                local objects = zone and zone:FindFirstChild("Objects")

                if char and objects then
                    for _, brainrot in pairs(objects:GetChildren()) do
                        if not getgenv().Farming then return end

                        char:MoveTo(brainrot.PrimaryPart.Position)
                        repeat
                            fireproximityprompt(brainrot.ProximityPrompt)
                            task.wait()
                        until brainrot == nil or brainrot.Parent ~= objects

                        char:MoveTo(workspace.Bases[player.Name].Root.Position)
                        task.wait(0.5)
                    end
                end

                task.wait(1)
            end
        else
            getgenv().Farming = false
        end
    end)

    elements:Textbox("Max price", section, setdata.maxprice, function(v)
        getgenv().setconfig("maxprice", v)
        getgenv().MaxPrice = tonumber(v)
    end)

    elements:Toggle("Auto Sell", section, setdata.farmsell, function(v)
        getgenv().setconfig("farmsell", v)
        if v then
            getgenv().Selling = true

            while getgenv().Selling do
                local char = player.Character
                if char then
                    for _, brainrot in pairs(player.Backpack:GetChildren()) do
                        if brainrot.Name ~= "Bat" then
                            spawn(function()
                                pcall(function()
                                    if parseValue(brainrot.Handle.ObjectInfo.Value.ValueLabel.Text) <= getgenv().MaxPrice then
                                        local Event = game:GetService("ReplicatedStorage").Shared.Classes.RemoteFunction.Remotes.EntityShared_SellEntity
                                        Event:InvokeServer(brainrot.Name)
                                    end
                                end)
                            end)
                        end
                    end
                end

                task.wait(3)
            end
        else
            getgenv().Selling = false
        end
    end)

    elements:Button("Redeem Codes", section, function()
        local codes = {"Stop Looking", "TommysHouse", "Phew", "GoldStatue", "FreeSpin"}

        for i, v in pairs(codes) do
            local Event = game:GetService("ReplicatedStorage").Shared.Classes.RemoteFunction.Remotes.CodeShared_Redeem
            Event:InvokeServer(v)
            task.wait()
        end
    end)
end

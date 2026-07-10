-- Bike obby for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    local plr = game:GetService("Players").LocalPlayer

    getgenv().Farming = false
    getgenv().equip = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farming = setdata.farming or false
    setdata.equip = setdata.equip or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Farm Brainrots", section, setdata.farming, function(v)
        getgenv().setconfig("farming", v)
        getgenv().Farming = v

        if getgenv().Farming then
            while getgenv().Farming do
                pcall(function()
                    plr.Character:MoveTo(Vector3.new(-3394, 1450, 7887))
                    local divines = workspace.ItemSpawns:WaitForChild("10", 5)
                    for _,v in pairs(divines:GetChildren()) do
                        if v:IsA("Model") then
                            local prp = v.PrimaryPart
                            if prp then
                                plr.Character:MoveTo(prp.Position)
                                repeat fireproximityprompt(prp.ProximityPrompt) task.wait() until not v or v.Parent ~= divines
                                local br = plr.Character:WaitForChild("StackItem")
                                plr.Character:MoveTo(workspace.Zones.BikeSpawn.Position)
                                repeat task.wait() until not br or br.Parent ~= plr.Character
                                task.wait(0.1)
                            end
                        end
                    end
                    plr.Character:MoveTo(Vector3.new(-3394, 1450, 6269))
                    local celestial = workspace.ItemSpawns:WaitForChild("9", 5)
                    for _,v in pairs(celestial:GetChildren()) do
                        if v:IsA("Model") then
                            local prp = v.PrimaryPart
                            if prp then
                                plr.Character:MoveTo(prp.Position)
                                repeat fireproximityprompt(prp.ProximityPrompt) task.wait() until not v or v.Parent ~= celestial
                                local br = plr.Character:WaitForChild("StackItem")
                                plr.Character:MoveTo(workspace.Zones.BikeSpawn.Position)
                                repeat task.wait() until not br or br.Parent ~= plr.Character
                                task.wait(0.1)
                            end
                        end
                    end
                    plr.Character:MoveTo(Vector3.new(-3394, 1450, 4732))
                    local secret = workspace.ItemSpawns:WaitForChild("8", 5)
                    for _,v in pairs(secret:GetChildren()) do
                        if v:IsA("Model") then
                            local prp = v.PrimaryPart
                            if prp then
                                plr.Character:MoveTo(prp.Position)
                                repeat fireproximityprompt(prp.ProximityPrompt) task.wait() until not v or v.Parent ~= secret
                                local br = plr.Character:WaitForChild("StackItem")
                                plr.Character:MoveTo(workspace.Zones.BikeSpawn.Position)
                                repeat task.wait() until not br or br.Parent ~= plr.Character
                                task.wait(0.1)
                            end
                        end
                    end
                end)

                task.wait(0.1)
            end
        end
    end)

    elements:Toggle("Auto Equip Best", section, setdata.equip, function(v)
        getgenv().setconfig("equip", v)
        getgenv().equip = v
        if getgenv().equip then
            while getgenv().equip do
                local Event = game:GetService("ReplicatedStorage").Events.PlaceBestBrainrots
                Event:FireServer()
                task.wait(5)
            end
        end
    end)
end

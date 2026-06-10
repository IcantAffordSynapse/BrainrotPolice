-- pole obby for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    getgenv().farming = false
    local plr = game:GetService("Players").LocalPlayer

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farmrots = setdata.farmrots or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Farm Brainrots", section, setdata.farmrots, function(v)
        setconfig("farmrots", v)
        if v then
            getgenv().farming = true

            while getgenv().farming do
                pcall(function()
                    for i, v in pairs(workspace.Mobs:GetChildren()) do
                        if v.PrimaryPart then
                            local Rarity = v.PrimaryPart.OverheadAttach.AnimalOverhead.Rarity.Text
                            if Rarity == "OG" or Rarity == "Admin" then
                                plr.Character:MoveTo(v.PrimaryPart.Position)
                                repeat fireproximityprompt(v.PrimaryPart.ProximityPrompt) task.wait() until not v or not v.PrimaryPart or v.PrimaryPart:FindFirstChild("MobCarryWeld")
                                local Event = game:GetService("ReplicatedStorage").Packages.Net["RE/SafeZoneEvent"]
                                Event:FireServer()
                                task.wait(0.1)
                            end
                        end
                    end
                end)

                task.wait(0.1)
            end
        else
            getgenv().farming = false
        end
    end)
end
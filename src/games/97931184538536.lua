-- Skate for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    local httpservice = game:GetService("HttpService")

    env.Farming = false
    env.Farminga = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farming = setdata.farming or false
    setdata.farmingany = setdata.farmingany or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local Brainrots = workspace.Bin.FieldBrainrots


    elements:Toggle("Farm OG + Celestial Brainrots", section, setdata.farming, function(v)
        env.Farming = v
        getgenv().setconfig("farming", v)
        if not v then return end

        while env.Farming do
            pcall(function()
                for i, br in pairs(Brainrots:GetChildren()) do
                    if br:GetAttribute("FieldName") == "CelestialField" or br:GetAttribute("FieldName") == "OGField" then
                        if br:GetAttribute("Traits") ~= "VIP" then
                            plr.Character:MoveTo(br.Position)
                            repeat
                                fireproximityprompt(br:FindFirstChildOfClass("ProximityPrompt"))
                                task.wait()
                            until not br or br.Parent ~= Brainrots
                            task.wait()
                            repeat
                                plr.Character:MoveTo(Vector3.new(69, 30, 162))
                                task.wait()
                            until not plr.Character:FindFirstChild("HeldFieldBrainrot")
                            task.wait()
                        end

                    end
                end
            end)

            task.wait(0.1)
        end
    end)

    elements:Toggle("Farm All Brainrots", section, setdata.farmingany, function(v)
        env.Farminga = v
        getgenv().setconfig("farmingany", v)
        if not v then return end

        while env.Farminga do
            pcall(function()
                for i, br in pairs(Brainrots:GetChildren()) do
                    if br:GetAttribute("FieldName") ~= nil and br:GetAttribute("Traits") ~= "VIP" then
                        plr.Character:MoveTo(br.Position)
                        repeat
                            fireproximityprompt(br:FindFirstChildOfClass("ProximityPrompt"))
                            task.wait()
                        until not br or br.Parent ~= Brainrots
                        task.wait()
                        repeat
                            plr.Character:MoveTo(Vector3.new(69, 30, 162))
                            task.wait()
                        until not plr.Character:FindFirstChild("HeldFieldBrainrot")
                        task.wait()
                    end
                end
            end)

            task.wait(0.1)
        end
    end)

end

-- fly for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    env.Farming = false
    env.FarmWings = false
    env.AutoBest = false
    env.AutoCollect = false

    elements:Label("Auto rejoin on kick recommended. (Settings tab)", section)

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farmrots = setdata.farmrots or false
    setdata.farmequip = setdata.farmequip or false
    setdata.farmspeed = setdata.farmspeed or false
    setdata.farmcollect = setdata.farmcollect or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Farm Brainrots", section, setdata.farmrots, function(v)
        env.setconfig("farmrots", v)
        if v then
            env.Farming = true

            while env.Farming do
                for _, v in pairs(workspace.Brainrots:GetChildren()) do
                    local rarity = v:GetAttribute("Rarity")
                    local wanted = rarity == "ADMIN"
                        or rarity == "Lucky"
                        or rarity == "Ascendant"
                        or rarity == "Transcendent"
                        or rarity == "OG"

                    if wanted and v.PrimaryPart then
                        plr.Character:MoveTo(v.PrimaryPart.Position)
                        local model = v:FindFirstChildOfClass("Model")
                        local mesh = model and model:FindFirstChildOfClass("MeshPart")
                        local prompt = mesh and mesh:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            repeat
                                fireproximityprompt(prompt)
                                task.wait()
                            until not v or v.Parent ~= workspace.Brainrots
                            task.wait()
                            plr.Character:MoveTo(Vector3.new(7, 10, 44))
                            task.wait(0.25)
                        end
                    end
                end
                task.wait(0.1)
            end
        else
            env.Farming = false
        end
    end)

    elements:Toggle("Auto Buy Speed", section, setdata.farmspeed, function(v)
        env.setconfig("farmspeed", v)
        if v then
            env.FarmWings = true

            while env.FarmWings do
                local Event = game:GetService("ReplicatedStorage").Libraries.Packet.RemoteEvent
                Event:FireServer(buffer.fromstring("\x15\x01"))
                task.wait(1)
            end
        else
            env.FarmWings = false
        end
    end)

    elements:Toggle("Auto Equip Best", section, setdata.farmequip, function(v)
        env.setconfig("farmequip", v)
        if v then
            env.AutoBest = true

            while env.AutoBest do
                local Event = game:GetService("ReplicatedStorage").Libraries.Packet.RemoteEvent
                Event:FireServer(buffer.fromstring("\x0E"))
                task.wait(1)
            end
        else
            env.AutoBest = false
        end
    end)

    elements:Toggle("Auto Collect", section, setdata.farmcollect, function(v)
        env.setconfig("farmcollect", v)
        if v then
            env.AutoCollect = true

            while env.AutoCollect do
                local touched = false
                for _, v in pairs(workspace.Plots:GetChildren()) do
                    if v:GetAttribute("Owner") == plr.UserId then
                        for i, pod in pairs(v.Podiums:GetChildren()) do
                            if pod:FindFirstChild("Collect") then
                                firetouchinterest(plr.Character.Head, pod.Collect, true)
                                task.wait(0.2)
                                firetouchinterest(plr.Character.Head, pod.Collect, false)
                                touched = true
                                task.wait(0.5)
                            end
                        end
                    end
                end
                task.wait(touched and 5 or 2)
            end
        else
            env.AutoCollect = false
        end
    end)
end

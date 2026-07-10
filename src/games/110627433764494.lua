-- fake a brainrot

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    local plots = workspace.Plots
    local lazerevent = game:GetService("ReplicatedStorage").Events.LaserVisibility
    local fakeevent = game:GetService("ReplicatedStorage").Events.FakeSystem_StartFake

    env.Farming = false
    env.Fakee = "Tim Cheese"

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farming = setdata.farming or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Textbox("Brainrot to Fake", section, "Tim Cheese", function(v)
        env.Fakee = v
    end)

    elements:Toggle("Farm Stealing", section, env.Farming, function(v)
        env.Farming = v
        getgenv().setconfig("farming", v)

        if not v then return end

        while env.Farming do
            fakeevent:FireServer(
                env.Fakee
            )

            local connection
            local complete = false

            task.spawn(function()
                while not complete do
                    plr.Character.Humanoid:MoveTo(Vector3.new(
                        math.random(-37, 80),
                        0,
                        math.random(-399, -119)
                    ))
                    task.wait(math.random(1, 5))
                end
            end)

            connection = lazerevent.OnClientEvent:Connect(function(userId, isOn)
                if isOn then return end

                for i,v in pairs(plots:GetChildren()) do
                    if v:GetAttribute("OwnerUserId") == userId then
                        local hasBr = false
                        for _, br in pairs(v.Slots:GetChildren()) do
                            if br:FindFirstChild("PlacedBrainrot") then
                                hasBr = true

                                plr.Character:MoveTo(br.PlacedBrainrot.PrimaryPart.Position)

                                repeat
                                    fireproximityprompt(br.StealPrompt)
                                    task.wait()
                                until not br.StealPrompt.Enabled

                                plr.Character:MoveTo(v.CollectAllZone.Position)

                                task.wait(1)

                                complete = true
                            end
                        end
                        if not hasBr then
                            complete = true
                        end
                    end
                end
                connection:Disconnect()
            end)

            repeat
                task.wait(0.5)
            until complete
        end
    end)
end

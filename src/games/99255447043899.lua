-- become a brainrot

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    local runTrigger = workspace.RunTrigger

    env.Farming = false
    env.Autosell = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farming = setdata.farming or false
    setdata.autosell = setdata.autosell or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local maxedCon
    elements:Toggle("Autoequip + Sell when maxed", section, env.Autosell, function(v)
        env.Autosell = v
        getgenv().setconfig("autosell", v)
        if not v then if maxedCon then maxedCon:Disconnect() end return end

        local Event = game:GetService("ReplicatedStorage").Events.Notify
        maxedCon = Event.OnClientEvent:Connect(function(arg1)
            if arg1:find("Max 75") then
                local Event = game:GetService("ReplicatedStorage").Events.EquipBest
                Event:FireServer()

                task.wait(1)

                local brlist = plr.Backpack:GetChildren()

                local Event = game:GetService("ReplicatedStorage").Events.SellAllBrainrots
                Event:FireServer(
                    brlist
                )
            end
        end)
    end)

    elements:Toggle("Autofarm", section, env.Farming, function(v)
        env.Farming = v
        getgenv().setconfig("farming", v)
        if not v then return end

        while env.Farming do
            pcall(function()
                firetouchinterest(plr.Character.Head, runTrigger, true)
                task.wait()
                firetouchinterest(plr.Character.Head, runTrigger, false)
                task.wait(0.5)
                plr.Character:MoveTo(Vector3.new(46, 4, -1816))
                local firstbr
                repeat
                    firstbr = workspace.Locations.End.Brainrots:FindFirstChildOfClass("Model")
                    task.wait()
                until firstbr

                local bestbr = nil
                local mostval = 0
                for i, v in pairs(workspace.Locations.End.Brainrots:GetChildren()) do
                    if v.MoneyPerSecond.Value > mostval
                        and v.PrimaryPart.ProximityPrompt.ActionText ~= "STEAL OP" then
                        mostval = v.MoneyPerSecond.Value
                        bestbr = v
                    end
                end

                plr.Character:MoveTo(bestbr.PrimaryPart.Position)
                task.wait()
                repeat
                    fireproximityprompt(bestbr.PrimaryPart.ProximityPrompt)
                    task.wait()
                until not bestbr or bestbr.Parent ~= workspace.Locations.End.Brainrots
                task.wait()
                plr.Character:MoveTo(workspace.EscapeHitbox.Position)
            end)
            task.wait(1)
        end
    end)

end

-- Cross rivers for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    env.Farming = false
    env.Upgrade = false
    env.Collect = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farmrots = setdata.farmrots or false
    setdata.upgrade = setdata.upgrade or false
    setdata.collect = setdata.collect or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local brainrotsFolder = workspace.SpawnedBrainrots
    local crossWall = workspace.MainGame.Map.Model.CrossWall
    local plots = workspace.MainGame.Plots

    local plrPlot

    for i, v in pairs(plots:GetChildren()) do
        if v.PlotOwner.UIPart.SGUI_Name.Frame.NameTxt.Text:find(plr.Name) then
            plrPlot = v
            break
        end
    end

    elements:Toggle("Farm Brainrots", section, setdata.farmrots, function(v)
        env.Farming = v
        env.setconfig("farmrots", v)
        if not env.Farming then return end
        while env.Farming do
            pcall(function()
                for i, v in pairs(brainrotsFolder:GetChildren()) do
                    if v:GetAttribute("_ZoneIndex") == 10 then
                        local proximityPromt = v.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")
                        if proximityPromt then
                            plr.Character:MoveTo(v.PrimaryPart.Position)
                            repeat
                                fireproximityprompt(proximityPromt)
                                task.wait()
                            until not proximityPromt or proximityPromt.Parent ~= v.PrimaryPart or not proximityPromt.Enabled

                            task.wait(0.5)

                            firetouchinterest(plr.Character.Head, crossWall, true)
                            task.wait()
                            firetouchinterest(plr.Character.Head, crossWall, false)

                            task.wait(0.5)
                        end
                    end
                end
            end)

            task.wait(1)
        end
    end)

    elements:Toggle("Auto Upgrade", section, setdata.upgrade, function(v)
        env.Upgrade = v
        env.setconfig("upgrade", v)
        if not env.Upgrade then return end
        while env.Upgrade do
            for i = 1, 30 do
                local Event = game:GetService("ReplicatedStorage").Packages.Knit.Services.PadService.RF.UpgradePad
                Event:InvokeServer(
                    tostring(i)
                )
            end

            task.wait(0.1)
        end
    end)

    elements:Toggle("Auto Collect", section, setdata.collect, function(v)
        env.Collect = v
        env.setconfig("collect", v)
        if not env.Collect then return end
        while env.Collect do
            for i, v in pairs(plrPlot.Pads:GetChildren()) do
                firetouchinterest(plr.Character.Head, v.CollectPart, true)
                task.wait(0.2)
                firetouchinterest(plr.Character.Head, v.CollectPart, false)
            end

            task.wait(3)
        end
    end)
end

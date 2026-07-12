-- +1 Speed Escape 67!
-- provided by yours truly incharilla the pookie :kiss:

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    local repstorage = game:GetService("ReplicatedStorage")
    local plr = game:GetService("Players").LocalPlayer
    local tweenservice = game:GetService("TweenService")
    local remotes = require(repstorage.Modules.Data.Remotes)

    getgenv().autowin = false
    getgenv().autoprestige = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.win = setdata.win or false
    setdata.prestige = setdata.prestige or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local function getsortedwalls()
        local walls = {}
        local maps = workspace:FindFirstChild("Maps")
        if not maps then return {} end

        local map1 = maps:FindFirstChild("1")
        if not map1 then return {} end

        for _, obj in ipairs(map1:GetChildren()) do
            local stage = obj:GetAttribute("Stage")
            if stage then
                table.insert(walls, {
                    model = obj,
                    stage = stage
                })
            end
        end

        table.sort(walls, function(a, b)
            return a.stage < b.stage
        end)

        return walls
    end

    elements:Toggle("Auto Win", section, setdata.win, function(ison)
        getgenv().setconfig("win", ison)
        if ison then
            getgenv().autowin = true
            task.spawn(function()
                while getgenv().autowin do
                    local walls = getsortedwalls()

                    if #walls == 0 then
                        task.wait(1)
                        continue
                    end

                    for _, walldata in ipairs(walls) do
                        if not getgenv().autowin then break end

                        local char = plr.Character
                        if not char then task.wait(0.5) continue end

                        local root = char:FindFirstChild("HumanoidRootPart")
                        if not root then task.wait(0.5) continue end

                        local wall = walldata.model
                        local wallcframe = wall:GetPivot()
                        local wallpos = wallcframe.Position

                        local forward = wallcframe.LookVector
                        local behindpos = wallpos + forward * 3
                        local infrontpos = wallpos - forward * 3

                        root.CFrame = CFrame.new(behindpos)

                        local tween = tweenservice:Create(root, TweenInfo.new(1.5), { CFrame = CFrame.new(infrontpos) })
                        tween:Play()
                        tween.Completed:Wait()

                        if walldata.stage == 11 then
                            task.wait(0.5)
                            root.CFrame = CFrame.new(-4227, 57, 141)
                        end

                        task.wait(0.5)
                    end

                    pcall(function()
                        repstorage.Network.dataRemoteEvent:FireServer({ {Id = 12}, "\x03" })
                    end)
                    task.wait(2)
                end
            end)
        else
            getgenv().autowin = false
        end
    end)

    elements:Toggle("Auto Prestige", section, setdata.prestige, function(ison)
        getgenv().setconfig("prestige", ison)
        if ison then
            getgenv().autoprestige = true
            task.spawn(function()
                while getgenv().autoprestige do
                    pcall(function()
                        remotes.PrestigeRequest:Fire()
                    end)

                    task.wait(0.3)

                    pcall(function()
                        remotes.RebirthRequest:Fire()
                    end)

                    task.wait(0.3)
                end
            end)
        else
            getgenv().autoprestige = false
        end
    end)
end

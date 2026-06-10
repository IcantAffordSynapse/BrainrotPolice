-- Cross road for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farmrots = setdata.farmrots or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local plr = game:GetService("Players").LocalPlayer

    getgenv().FarmBrainrots = false

    elements:Toggle("Farm Brainrots", section, setdata.farmrots, function(bool)
        setconfig("farmrots", bool)
        if bool then
            getgenv().FarmBrainrots = true

            local char = plr.Character
            local hrp = char.HumanoidRootPart

            local function tp(pos)
                char:MoveTo(pos)

                repeat
                    task.wait()
                until (hrp.Position - pos).Magnitude < 10
            end

            local function waitForFolderChildren(folder, minimum, timeout)
                local start = tick()
                repeat
                    if #folder:GetChildren() >= minimum then
                        return true
                    end

                    task.wait(0.25)
                until tick() - start > timeout

                return false
            end

            while getgenv().FarmBrainrots do
                tp(Vector3.new(345, 19, 2242))
                local celestial = workspace.ItemSpawners:WaitForChild("Celestial")

                waitForFolderChildren(celestial, 1, 5)

                for _, br in pairs(celestial:GetChildren()) do
                    if br.PrimaryPart then
                        tp(br.PrimaryPart.Position)

                        task.wait(0.5)

                        local prompt = br.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")

                        if prompt then
                            repeat fireproximityprompt(prompt) task.wait() until not br or br.Parent ~= celestial

                            task.wait(0.5)

                            tp(Vector3.new(343, 2, -15))
                            task.wait(2)

                            tp(Vector3.new(345, 19, 2242))
                            task.wait(1)
                        end
                    end
                end


                tp(Vector3.new(353, 2, 2092))
                local secret = workspace.ItemSpawners:WaitForChild("Secret")
                waitForFolderChildren(secret, 1)

                for _, br in pairs(secret:GetChildren()) do
                    if br.PrimaryPart then
                        tp(br.PrimaryPart.Position)

                        local prompt = br.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")

                        if prompt then
                            repeat fireproximityprompt(prompt) task.wait() until not br or br.Parent ~= secret

                            task.wait(0.5)

                            tp(Vector3.new(343, 2, -15))
                            task.wait(2)

                            tp(Vector3.new(353, 2, 2092))
                            task.wait(1)
                        end
                    end
                end

                task.wait(0.1)
            end
        else
            getgenv().FarmBrainrots = false
        end
    end)

    elements:Button("Remove Cars", section, function()
        workspace.CarSpawn:Destroy()
    end)
end

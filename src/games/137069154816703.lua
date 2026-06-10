-- hack vault for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    local plr = game:GetService("Players").LocalPlayer
    getgenv().FarmRots = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farmrots = setdata.farmrots or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Farm Brainrots", section, setdata.farmrots, function(v)
        getgenv().setconfig("farmrots", v)
        if v then
            getgenv().FarmRots = true

            while getgenv().FarmRots do
                for _, br in pairs(workspace.EntitiesFolder:GetChildren()) do
                    plr.Character:MoveTo(Vector3.new(-2494, 4, -726))
                    task.wait(0.5)
                    if tostring(br:GetAttribute("SpawnZone")) == "22" and br.PrimaryPart then
                        plr.Character:MoveTo(br.PrimaryPart.Position)
                        task.wait()
                        repeat fireproximityprompt(br.PrimaryPart.TakeBrainrotPrompt) task.wait() until not br.PrimaryPart or br.PrimaryPart:FindFirstChild("Attachment")
                        plr.Character:MoveTo(Vector3.new(77, 4, -729))
                        task.wait(1)
                    end
                end
                task.wait()
            end
        else
            getgenv().FarmRots = false
        end
    end)
end

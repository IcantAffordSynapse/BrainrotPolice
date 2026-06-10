-- dream for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    getgenv().farming = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farming = setdata.farming or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Farming", section, setdata.farming, function(v)
        getgenv().setconfig("farming", v)
        if v then
            getgenv().farming = true

            while getgenv().farming do
                local Event = game:GetService("ReplicatedStorage").Remotes.DreamStateChanged
                Event:FireServer(
                    true
                )

                local Event = game:GetService("ReplicatedStorage").Remotes.RequestDreamBrainrots
                Event:FireServer()

                local Event = game:GetService("ReplicatedStorage").Remotes.PickupDreamBrainrot
                Event:FireServer(
                    "60"
                )

                task.wait()
                local Event = game:GetService("ReplicatedStorage").Remotes.RequestDreamWallExit
                Event:FireServer()
                task.wait()
            end
        else
            getgenv().farming = false
        end
    end)
end
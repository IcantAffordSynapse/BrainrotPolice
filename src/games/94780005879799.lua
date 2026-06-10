-- scream for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    getgenv().AddingSpins = false
    getgenv().AutoSleepy = false
    getgenv().AutoOg = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.addspins = setdata.addspins or false
    setdata.farmsleepy = setdata.farmrofarmsleepyts or false
    setdata.farmog = setdata.farmog or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Add Inf Spins", section, setdata.addspins, function(v)
        setconfig("addspins", v)
        if v then
            getgenv().AddingSpins = true

            while getgenv().AddingSpins do
                local Event = game:GetService("ReplicatedStorage").Remotes.AddSpin
                Event:FireServer()
                task.wait()
            end
        else
            getgenv().AddingSpins = false
        end
    end)

    elements:Toggle("Auto Spin Sleepy Mutation", section, setdata.farmsleepy, function(v)
        setconfig("farmsleepy", v)
        if v then
            getgenv().AutoSleepy = true

            while getgenv().AutoSleepy do
                local Event = game:GetService("ReplicatedStorage").Remotes.SpinEventWheel
                Event:FireServer(
                    5
                )
                task.wait(0.5)
            end
        else
            getgenv().AutoSleepy = false
        end
    end)

    elements:Toggle("Auto Spin OG", section, setdata.farmog, function(v)
        setconfig("farmog", v)
        if v then
            getgenv().AutoOg = true

            while getgenv().AutoOg do
                local Event = game:GetService("ReplicatedStorage").Remotes.SpinEventWheel
                Event:FireServer(
                    4
                )
                task.wait(0.5)
            end
        else
            getgenv().AutoOg = false
        end
    end)
end
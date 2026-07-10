-- paper plane for brainrot

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    local httpservice = game:GetService("HttpService")

    env.Farming = false
    env.Strength = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farming = setdata.farming or false
    setdata.strength = setdata.strength or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Farm Brainrots", section, setdata.farming, function(v)
        env.Farming = v
        getgenv().setconfig("farming", v)
        if not v then return end

        while env.Farming do
            local replicatedStorage = game:GetService("ReplicatedStorage")
            local sharedModules = replicatedStorage:FindFirstChild("SharedModules")
            local network = sharedModules and sharedModules:FindFirstChild("Network")

            if network then
                local requestPending = network:FindFirstChild("RequestPendingFlight")
                local requestActive = network:FindFirstChild("RequestActiveFlight")
                local claimFlight = network:FindFirstChild("ClaimFlight")

                if requestPending and requestActive and claimFlight then
                    requestPending:FireServer()
                    task.wait(1)

                    local vsp = Vector3.new(-347.2116394043, 89.037544250488, 25.892095565796)
                    local GameCore = require(replicatedStorage.GameCore)

                    local results = requestActive:InvokeServer({
                        plotIndex = 3,
                        intensity = 1,
                        player = plr,
                        flightUID = require(game:GetService("ReplicatedStorage").UtilityCore).StringUtility.GenerateUID(),
                        serverFloors = 10000000,
                        visualStartPos = vsp,
                        startTime = GameCore.GetSycnedTime(),
                        startPos = Vector3.new(-347.2116394043, 85.050003051758, 25.892095565796),
                        serverStrength = 10000000
                    })

                    if results and type(results.spawnedBrainrots) == "table" and results.spawnedBrainrots[1] then
                        local chosenBrainrot = results.spawnedBrainrots[1]

                        task.wait((tonumber(results.timeInAir) or 0) + 0.5)

                        if chosenBrainrot.uid then
                            claimFlight:InvokeServer(chosenBrainrot.uid)
                        end
                    end
                end
            end

            task.wait(0.1)
        end
    end)

    elements:Toggle("Farm Strength", section, setdata.strength, function(v)
        env.Strength = v
        getgenv().setconfig("strength", v)
        if not v then return end

        while env.Strength do
            local Event = game:GetService("ReplicatedStorage").SharedModules.Network.RequestStrength
            Event:InvokeServer()
            local Event = game:GetService("ReplicatedStorage").SharedModules.Network.RequestDoubleStrength
            Event:InvokeServer()
            task.wait(0.1)
        end
    end)
end

-- +1 Dash for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local utils = loadstring(game:HttpGet(getgitpath("src").."utils.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    env.Farming = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farmrots = setdata.farmrots or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local endPos = Vector3.new(-74, 63, 15784)
    local colPos = Vector3.new(-74, 20, -447)
    local function hasHeldModel()
        local character = utils.GetCharacter(plr)
        return character and character:FindFirstChildOfClass("Model") ~= nil
    end

    elements:Toggle("Farm Brainrots", section, setdata.farmrots, function(v)
        env.Farming = v
        env.setconfig("farmrots", v)
        if not env.Farming then return end
        while env.Farming do
            utils.MoveCharacter(plr, endPos)
            local spawners = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Spawners")
            local lastPlace = spawners and utils.WaitForChildPath(spawners, {"???xLuck", "???"}, 3)

            pcall(function()
                if not lastPlace then
                    return
                end

                for _, v in pairs(lastPlace:GetChildren()) do
                    if v:IsA("Model") then
                        repeat
                            task.wait()
                        until not plr.GameplayPaused

                        if v.PrimaryPart then
                            utils.MoveCharacter(plr, v.PrimaryPart.Position)

                            local prox = v.PrimaryPart:FindFirstChildOfClass("ProximityPrompt")
                            local started = os.clock()
                            repeat
                                utils.FirePrompt(prox)
                                task.wait(0.1)
                            until not v
                                or v.Parent ~= lastPlace
                                or os.clock() - started > 4

                            task.wait(0.5)

                            repeat
                                utils.MoveCharacter(plr, colPos)
                                task.wait()
                            until not hasHeldModel()

                            break
                        end
                    end
                end
            end)
            task.wait()
        end

    end)
end

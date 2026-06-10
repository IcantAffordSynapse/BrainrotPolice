-- nuke for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    local brainrotFold = workspace.Camera.BrainrotContainer
    local plr = game:GetService("Players").LocalPlayer

    local powerAmt = plr.PlayerGui.HUD.BottomRight.Stats.Container.Power.CollectedText

    getgenv().AutoMoney = false
    getgenv().AutoRebirth = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.automoney = setdata.automoney or false
    setdata.autorebirth = setdata.autorebirth or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Toggle("Auto Money", section, setdata.automoney, function(v)
        getgenv().setconfig("automoney", v)
        if v then
            getgenv().AutoMoney = true

            while getgenv().AutoMoney do
                task.spawn(function()
                    local Event = game:GetService("ReplicatedStorage").ModifiedPackages.Packet.RemoteEvent
                    Event:FireServer(
                        buffer.fromstring("\x0E")
                    )
                end)
                task.wait()
            end
        else
            getgenv().AutoMoney = false
        end
    end)

    elements:Toggle("Auto Rebirth", section, setdata.autorebirth, function(v)
        getgenv().setconfig("autorebirth", v)
        if v then
            getgenv().AutoRebirth = true

            while getgenv().AutoRebirth do
                local Event = game:GetService("ReplicatedStorage").ModifiedPackages.Packet.RemoteEvent
                Event:FireServer(
                    buffer.fromstring("\x93")
                )
                task.wait(1)
            end
        else
            getgenv().AutoRebirth = false
        end
    end)
end

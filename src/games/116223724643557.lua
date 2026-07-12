return function(section, data)

    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    local players = game:GetService("Players")
    local replicatedstorage = game:GetService("ReplicatedStorage")
    local httpservice = game:GetService("HttpService")

    local plr = players.LocalPlayer

    getgenv().tp = false
    getgenv().train = false
    getgenv().staff = false
    getgenv().rebirth = false

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.tp = setdata.tp or false
    setdata.train = setdata.train or false
    setdata.staff = setdata.staff or false
    setdata.rebirth = setdata.rebirth or false
    data[tostring(game.PlaceId)] = setdata

    writefile("BrainrotPolice/Config.json", httpservice:JSONEncode(data))

    local function get_character()
        return plr.Character or plr.CharacterAdded:Wait()
    end

    local function get_root()
        local character = get_character()
        return character and character:FindFirstChild("HumanoidRootPart")
    end

    local function get_target()
        return workspace:FindFirstChild("Stages")
            and workspace.Stages:FindFirstChild("Stage31")
            and workspace.Stages.Stage31:FindFirstChild("WinButton")
    end

    local function get_remotes()
        return replicatedstorage:FindFirstChild("Remotes")
    end

    local function get_staff()
        local staffbuttons = workspace:FindFirstChild("StaffButtons")
        local staffbutton20 = staffbuttons and staffbuttons["Staff Button20"]
        return staffbutton20 and staffbutton20:FindFirstChild("TouchPart")
    end

    elements:Toggle("INF WINS", section, setdata.tp, function(ison)
        getgenv().setconfig("tp", ison)
        if ison then
            getgenv().tp = true
            task.spawn(function()
                while getgenv().tp do
                    local target = get_target()
                    local character = get_character()
                    local root = get_root()

                    if target and character and root then
                        local pivot = target:GetPivot()
                        character:PivotTo(CFrame.new(pivot.Position + Vector3.new(0, 2, 0)))
                    end
                    task.wait()
                end
            end)
        else
            getgenv().tp = false
        end
    end)

    elements:Toggle("Auto Train", section, setdata.train, function(ison)
        getgenv().setconfig("train", ison)
        if ison then
            getgenv().train = true
            task.spawn(function()
                local remotes = get_remotes()
                local gain = remotes and remotes:FindFirstChild("GainMagicPower")

                while getgenv().train do
                    if gain then
                        pcall(function()
                            gain:FireServer()
                        end)
                    end
                    task.wait()
                end
            end)
        else
            getgenv().train = false
        end
    end)

    elements:Toggle("Equip Best Staff", section, setdata.staff, function(ison)
        getgenv().setconfig("staff", ison)
        if ison then
            getgenv().staff = true
            task.spawn(function()
                while getgenv().staff do
                    local root = get_root()
                    local touch = get_staff()

                    if root and touch then
                        touch.CFrame = root.CFrame * CFrame.new(0, 0, -3)
                    end

                    task.wait()
                end
            end)
        else
            getgenv().staff = false
        end
    end)

    elements:Toggle("Auto Rebirth", section, setdata.rebirth, function(ison)
        getgenv().setconfig("rebirth", ison)
        if ison then
            getgenv().rebirth = true
            task.spawn(function()
                local remotes = get_remotes()
                local rebirth = remotes and remotes:FindFirstChild("Rebirth")

                while getgenv().rebirth do
                    if rebirth then
                        pcall(function()
                            rebirth:FireServer()
                        end)
                    end
                    task.wait()
                end
            end)
        else
            getgenv().rebirth = false
        end
    end)

end

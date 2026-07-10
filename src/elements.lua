local elements = import("rbxassetid://113037265185555")
local utils = loadstring(game:HttpGet(getgitpath("src") .. "utils.lua"))()
local stuff = {}
local gameList = game:GetService("HttpService"):JSONDecode(game:HttpGet(getgitpath("src").. "gameslist.json"))
local experienceService = game:GetService("ExperienceService")
local guiService = game:GetService("GuiService")

local function teleportToGame(placeId)
    local numericPlaceId = tonumber(placeId)
    if not numericPlaceId then
        return
    end

    local launchUrl = "roblox://experiences/start?placeId=" .. tostring(numericPlaceId)
    local opened = pcall(function()
        guiService:OpenBrowserWindow(launchUrl)
    end)

    if opened then
        return
    end

    local launched = pcall(function()
        experienceService:LaunchExperience({placeId = numericPlaceId})
    end)

    if launched then
        return
    end

    if typeof(setclipboard) == "function" then
        setclipboard("https://www.roblox.com/games/" .. tostring(numericPlaceId))
    end
end

function stuff:Label(str, king)
    local newLabel = elements.LabelElement:Clone()
    newLabel.Text = str
    newLabel.Parent = king
end

function stuff:Button(str, king, cb)
    local newBtn = elements.ButtonElement:Clone()
    newBtn.TextLabel.Text = str
    newBtn.Parent = king

    newBtn.MouseButton1Click:Connect(function()
        utils.SafeCall(cb)
    end)
end

function stuff:Toggle(str, king, def, cb)
    local hasDefault = type(def) ~= "function"
    if not hasDefault then
        cb = def
        def = false
    end

    local newTog = elements.ToggleElement:Clone()
    newTog.TextLabel.Text = str
    newTog.Parent = king

    local function render(isTog)
        if isTog then
            newTog.togglebg.BackgroundColor3 = Color3.fromRGB(59, 164, 57)
            newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(1, 0.5)
            newTog.togglebg.leftrightlol.Position = UDim2.new(1, 0, 0.5, 0)
        else
            newTog.togglebg.BackgroundColor3 = Color3.fromRGB(164, 58, 58)
            newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(0, 0.5)
            newTog.togglebg.leftrightlol.Position = UDim2.new(0, 0, 0.5, 0)
        end
    end

    local shouldAutoResume = getgenv().BrainrotPoliceAutoResume == true
    local isTog = shouldAutoResume and def == true
    render(isTog)

    if hasDefault and shouldAutoResume then
        task.defer(function()
            utils.SafeCall(cb, isTog)
        end)
    end

    newTog.MouseButton1Click:Connect(function()
        isTog = not isTog
        render(isTog)
        utils.SafeCall(cb, isTog)
    end)
end

function stuff:Textbox(str, king, def, cb)
    if type(def) == "function" then
        cb = def
        def = nil
    end

    local newTb = elements.TextboxElement:Clone()
    newTb.TextLabel.Text = str
    newTb.Parent = king

    if def ~= nil then
        newTb.tbbg.Inp.Text = tostring(def)
    end

    newTb.tbbg.Inp.FocusLost:Connect(function(ep)
        utils.SafeCall(cb, newTb.tbbg.Inp.Text, ep)
    end)
end

function stuff:Unsupported(king, cb)
    local newUs = elements.unsupportElement:Clone()
    newUs.Parent = king

    newUs.suggestbtn.MouseButton1Click:Connect(function()
        if typeof(setclipboard) == "function" then
            setclipboard("https://discord.gg/vaehz")
            newUs.suggestbtn.Text = "Copied Link!"
            task.wait(1)
            newUs.suggestbtn.Text = "Suggest Game"
        else
            newUs.suggestbtn.Text = "Clipboard Unsupported"
            task.wait(1)
            newUs.suggestbtn.Text = "Suggest Game"
        end
    end)

    newUs.glbtn.MouseButton1Click:Connect(function()
        utils.SafeCall(cb)
    end)
end

function stuff:addGame(king, gname, gstate, cb)
    local newGame = elements.GameElement:Clone()
    newGame.ButtonElement.header.Text = gname
    local statusColors = {
        Online = Color3.fromRGB(0, 255, 0),
        Limited = Color3.fromRGB(255, 255, 0),
        Offline = Color3.fromRGB(255, 0, 0)
    }
    if statusColors[gstate] then
        newGame.ButtonElement.status.ImageColor3 = statusColors[gstate]
    end
    if gstate == "🟢" then
        newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(0, 255, 0)
    elseif gstate == "🟡" then
        newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(255, 255, 0)
    elseif gstate == "🔴" then
        newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(255, 0, 0)
    end
    newGame.Parent = king

    newGame.ButtonElement.MouseButton1Click:Connect(function()
        utils.SafeCall(cb)
    end)
end

-- to finish
function stuff:Searchbar(king)
    local newSearch = elements.searchBar:Clone()
    newSearch.Parent = king
    newSearch.searchbar.Inp:GetPropertyChangedSignal("Text"):Connect(function()
        for i, v in pairs(king:GetChildren()) do
            if v.Name == "GameElement" then
                v:Destroy()
            end
        end

        for i, v in pairs(gameList) do
            if v["game"]:lower():find(newSearch.searchbar.Inp.Text:lower()) then
                stuff:addGame(king, v["game"], v["status"], function()
                    teleportToGame(v["id"])
                end)
            end
        end
    end)
end

function stuff:CredHead(king, txt)
    local newHead = elements.CreditHeader:Clone()
    newHead.Text = "> " .. txt
    newHead.Parent = king
end

function stuff:CredPerson(king, txt)
    local newCred = elements.CreditPerson:Clone()
    newCred.Text = "      + " .. txt
    newCred.Parent = king
end

return stuff

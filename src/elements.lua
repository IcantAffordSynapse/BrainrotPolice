local elements = import("rbxassetid://113037265185555")
local stuff = {}
local gameList = game:GetService("HttpService"):JSONDecode(game:HttpGet(getgitpath("src").. "gameslist.json"))

function stuff:Label(str, king)
    local newLabel = elements.LabelElement:Clone()
    newLabel.Text = str
    newLabel.Parent = king
    return newLabel
end

function stuff:Button(str, king, cb)
    local newBtn = elements.ButtonElement:Clone()
    newBtn.TextLabel.Text = str
    newBtn.Parent = king

    newBtn.MouseButton1Click:Connect(cb)
    return newBtn
end

function stuff:Toggle(str, king, def, cb)
    local newTog = elements.ToggleElement:Clone()
    newTog.TextLabel.Text = str
    newTog.Parent = king

    local isTog = def
    if isTog then
        newTog.togglebg.BackgroundColor3 = Color3.fromRGB(59, 164, 57)
        newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(1, 0.5)
        newTog.togglebg.leftrightlol.Position = UDim2.new(1, 0, 0.5, 0)
    else
        newTog.togglebg.BackgroundColor3 = Color3.fromRGB(164, 58, 58)
        newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(0, 0.5)
        newTog.togglebg.leftrightlol.Position = UDim2.new(0, 0, 0.5, 0)
    end
    task.defer(function() cb(isTog) end)

    newTog.MouseButton1Click:Connect(function()
        isTog = not isTog
        if isTog then
            newTog.togglebg.BackgroundColor3 = Color3.fromRGB(59, 164, 57)
            newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(1, 0.5)
            newTog.togglebg.leftrightlol.Position = UDim2.new(1, 0, 0.5, 0)
        else
            newTog.togglebg.BackgroundColor3 = Color3.fromRGB(164, 58, 58)
            newTog.togglebg.leftrightlol.AnchorPoint = Vector2.new(0, 0.5)
            newTog.togglebg.leftrightlol.Position = UDim2.new(0, 0, 0.5, 0)
        end
        cb(isTog)
    end)
    return newTog
end

function stuff:Textbox(str, king, def, cb)
    local newTb = elements.TextboxElement:Clone()
    newTb.TextLabel.Text = str
    newTb.Parent = king

    newTb.tbbg.Inp.FocusLost:Connect(function(ep)
        cb(newTb.tbbg.Inp.Text)
    end)
    return newTb
end

function stuff:Unsupported(king, cb)
    local newUs = elements.unsupportElement:Clone()
    newUs.Parent = king

    newUs.suggestbtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/vaehz")
        newUs.suggestbtn.Text = "Copied Link!"
        wait(1)
        newUs.suggestbtn.Text = "Suggest Game"
    end)

    newUs.glbtn.MouseButton1Click:Connect(cb)
    return newUs
end

function stuff:addGame(king, gname, gstate, cb)
    local newGame = elements.GameElement:Clone()
    newGame.ButtonElement.header.Text = gname
    if gstate == "🟢" then
        newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(0, 255, 0)
    elseif gstate == "🟡" then
        newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(255, 255, 0)
    elseif gstate == "🔴" then
        newGame.ButtonElement.status.ImageColor3 = Color3.fromRGB(255, 0, 0)
    end
    newGame.Parent = king

    newGame.ButtonElement.MouseButton1Click:Connect(cb)
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
                    game:GetService("ExperienceService"):LaunchExperience({placeId = v["id"]})
                end)
            end
        end
    end)
end

function stuff:CredHead(king, txt)
    local newHead = elements.CreditHeader:Clone()
    newHead.Text = "> " .. txt
    newHead.Parent = king
    return newHead
end

function stuff:CredPerson(king, txt)
    local newCred = elements.CreditPerson:Clone()
    newCred.Text = "      + " .. txt
    newCred.Parent = king
    return newCred
end

return stuff

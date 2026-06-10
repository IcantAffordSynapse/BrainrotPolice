local elements = import("rbxassetid://113037265185555")
local utils = loadstring(game:HttpGet(getgitpath("src") .. "utils.lua"))()
local stuff = {}

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

    local isTog = def == true
    render(isTog)

    if hasDefault then
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

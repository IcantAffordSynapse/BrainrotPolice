-- [:zap:] Escape Maze For Brainrots!

local InstantCollect = false
local AutoMoneyCollect = false

local function setupPrompt(prompt)
    if not InstantCollect then reutrn end
    if not prompt:IsA("ProximityPrompt") then return end

    prompt.HoldDuration = 0

    prompt.Triggered:Connect(function(plr)
        local character = plr.Character
        if character then
            character:MoveTo(Vector3.new(-285, 51, -50))
        end
    end)
end

function getRoot(char)
    -- thx inf yield :yum:
    local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
    return rootPart
end

for _, descendant in ipairs(workspace.Map.ItemSpawners:GetDescendants()) do
    setupPrompt(descendant)
end
workspace.Map.ItemSpawners.DescendantAdded:Connect(setupPrompt)

local c = coroutine.create(function ()
    while task.wait(0.25) do
        if AutoMoneyCollect then
            for _, v in pairs(PlayerPlot:GetDescendants()) do
                if v:IsA("TouchTransmitter") then
                    firetouchinterest(v.Parent, getRoot(game.Players.LocalPlayer.Character), 1)
                    task.wait(0.001)
                    firetouchinterest(v.Parent, getRoot(game.Players.LocalPlayer.Character), 0)
                end
            end
        end
    end
end)
coroutine.resume(c)

return function(section)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()

    elements:Toggle("Instant Collect", section, false, function(bool)
        InstantCollect = bool
    end)

    elements:Toggle("Auto Collect Money", section, false, function(bool)
        AutoMoneyCollect = bool
    end)
end

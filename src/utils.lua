local utils = {}

function utils.SafeCall(cb, ...)
    if type(cb) ~= "function" then
        return false
    end

    return pcall(cb, ...)
end

function utils.GetCharacter(player)
    if not player then
        return nil
    end

    return player.Character or player.CharacterAdded:Wait()
end

function utils.GetRoot(player)
    local character = utils.GetCharacter(player)
    if not character then
        return nil, nil
    end

    return character:FindFirstChild("HumanoidRootPart"), character
end

function utils.MoveCharacter(player, position)
    local character = utils.GetCharacter(player)
    if not character then
        return false
    end

    character:MoveTo(position)
    return true
end

function utils.FirePrompt(prompt)
    if prompt and typeof(fireproximityprompt) == "function" then
        fireproximityprompt(prompt)
        return true
    end

    return false
end

function utils.StartToggleLoop(flagName, enabled, callback, delay)
    getgenv().__BrainrotPoliceLoops = getgenv().__BrainrotPoliceLoops or {}

    getgenv()[flagName] = enabled
    getgenv().__BrainrotPoliceLoops[flagName] = (getgenv().__BrainrotPoliceLoops[flagName] or 0) + 1
    local token = getgenv().__BrainrotPoliceLoops[flagName]

    if not enabled then
        return
    end

    task.spawn(function()
        while getgenv()[flagName] and getgenv().__BrainrotPoliceLoops[flagName] == token do
            utils.SafeCall(callback)
            task.wait(delay or 0.1)
        end
    end)
end

function utils.FindFirstDescendantOfClass(root, className)
    if not root then
        return nil
    end

    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA(className) then
            return descendant
        end
    end

    return nil
end

return utils

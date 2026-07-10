-- hack vault for brainrots

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local utils = loadstring(game:HttpGet(getgitpath("src").."utils.lua"))()

    local plr = game:GetService("Players").LocalPlayer
    local entitiesFolder = workspace:FindFirstChild("EntitiesFolder")
    local grabPosition = Vector3.new(-2494, 4, -726)
    local dropPosition = Vector3.new(77, 4, -729)

    getgenv().FarmRots = false

    local function getObjectPosition(object)
        if not object then
            return nil
        end

        if object:IsA("BasePart") then
            return object.Position
        end

        if object:IsA("Model") then
            local primaryPart = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
            return primaryPart and primaryPart.Position
        end

        local ancestor = object:FindFirstAncestorOfClass("Model")
        if ancestor then
            return getObjectPosition(ancestor)
        end

        local partAncestor = object:FindFirstAncestorWhichIsA("BasePart")
        return partAncestor and partAncestor.Position
    end

    local function isPedestalObject(object)
        local name = object.Name:lower()
        return name:find("pedestal") ~= nil
            or name:find("stand") ~= nil
            or name:find("display") ~= nil
            or name:find("podium") ~= nil
    end

    local function isPedestalPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") then
            return false
        end

        local actionText = tostring(prompt.ActionText):lower()
        local objectText = tostring(prompt.ObjectText):lower()

        return actionText:find("swap") ~= nil
            or actionText:find("place") ~= nil
            or actionText:find("pickup") ~= nil
            or objectText:find("pedestal") ~= nil
            or objectText:find("inventory") ~= nil
    end

    local function findPedestalCandidate()
        local bestPrompt
        local bestObject

        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and isPedestalPrompt(descendant) then
                bestPrompt = descendant
                bestObject = descendant.Parent
                break
            end

            if not bestObject and isPedestalObject(descendant) then
                bestObject = descendant
            end
        end

        return bestPrompt, bestObject
    end

    local function copyPedestalDebug()
        local promptCount = 0
        local objectCount = 0
        local lines = {"Hack Vault pedestal debug:"}

        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and isPedestalPrompt(descendant) then
                promptCount = promptCount + 1
                if promptCount <= 10 then
                    table.insert(lines, "prompt: " .. descendant:GetFullName() .. " | action=" .. tostring(descendant.ActionText) .. " | object=" .. tostring(descendant.ObjectText))
                end
            elseif isPedestalObject(descendant) then
                objectCount = objectCount + 1
                if objectCount <= 10 then
                    table.insert(lines, "object: " .. descendant:GetFullName())
                end
            end
        end

        table.insert(lines, "prompt count: " .. tostring(promptCount))
        table.insert(lines, "object count: " .. tostring(objectCount))

        local output = table.concat(lines, "\n")
        if typeof(setclipboard) == "function" then
            setclipboard(output)
        end

        warn(output)
    end

    local function getSpawnZone(model)
        local zone = tonumber(model:GetAttribute("SpawnZone"))
        if zone then
            return zone
        end

        return -1
    end

    local function findLastZoneBrainrot()
        if not entitiesFolder then
            return nil, nil, nil
        end

        local bestBrainrot
        local bestPrompt
        local bestPart
        local highestZone = -1

        for _, br in pairs(entitiesFolder:GetChildren()) do
            local zone = getSpawnZone(br)
            local primaryPart = br.PrimaryPart
            local prompt = utils.FindPrompt(br, "TakeBrainrotPrompt")

            if zone > highestZone and primaryPart and prompt then
                highestZone = zone
                bestBrainrot = br
                bestPrompt = prompt
                bestPart = primaryPart
            end
        end

        return bestBrainrot, bestPrompt, bestPart
    end

    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.farmrots = setdata.farmrots or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    elements:Button("Teleport to Base", section, function()
        utils.MoveCharacter(plr, dropPosition)
    end)

    elements:Button("Teleport to Pedestals", section, function()
        local prompt, object = findPedestalCandidate()
        local position = getObjectPosition(prompt or object)

        if position then
            utils.MoveCharacter(plr, position + Vector3.new(0, 3, 0))
        else
            warn("[BrainrotPolice] No pedestal or swap/pickup prompt found.")
        end
    end)

    elements:Button("Copy Pedestal Debug", section, function()
        copyPedestalDebug()
    end)

    elements:Toggle("Farm Brainrots", section, setdata.farmrots, function(v)
        getgenv().setconfig("farmrots", v)
        if v then
            getgenv().FarmRots = true

            while getgenv().FarmRots do
                entitiesFolder = entitiesFolder or workspace:FindFirstChild("EntitiesFolder")

                if entitiesFolder then
                    utils.MoveCharacter(plr, grabPosition)
                    task.wait(0.35)

                    local br, prompt, primaryPart = findLastZoneBrainrot()

                    if br and prompt and primaryPart then
                        utils.MoveCharacter(plr, primaryPart.Position)
                        task.wait(0.1)

                        local started = os.clock()
                        repeat
                            utils.FirePrompt(prompt)
                            task.wait(0.1)
                        until not getgenv().FarmRots
                            or not br.Parent
                            or not primaryPart.Parent
                            or primaryPart:FindFirstChild("Attachment")
                            or os.clock() - started > 4

                        utils.MoveCharacter(plr, dropPosition)
                        task.wait(1)
                    end
                end

                task.wait(0.2)
            end
        else
            getgenv().FarmRots = false
        end
    end)
end

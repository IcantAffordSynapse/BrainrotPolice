--[[
coded by harpreet (@iiicrybalenci)
you can larp idc
ONLY WORKS IN GAME: BIKE OBBY FOR BRAINROTS (GAME ID: 136919941417380)
--]]

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local SAFE_POSITION = Vector3.new(-3394, 1450, -2885)

local function forceTeleport(pos)
    print("forcing tp to:", pos)
    for i = 1, 4 do
        rootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        rootPart.Position = pos + Vector3.new(0, 5, 0)
        rootPart.Velocity = Vector3.zero
        rootPart.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.08)
    end
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
    task.wait(0.25)
end

local function triggerPrompt(prompt, item)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    
    print("picking up:", item.Name)
    
    local mesh = item:FindFirstChild("Mesh") or item.PrimaryPart
    if mesh then
        local itemPos = mesh.Position + Vector3.new(0, 3, 0)
        forceTeleport(itemPos)
    end
    
    fireproximityprompt(prompt, 0, true)
    task.wait(0.45)
end

local function visitAllParts()
    print("tping to all parts to load them...")
    local itemSpawns = workspace:FindFirstChild("ItemSpawns") or workspace:FindFirstChild("itemSpawns")
    if not itemSpawns then warn("itemspawns not found") return end

    for i = 1, 10 do
        local part = itemSpawns:FindFirstChild(tostring(i))
        if part then
            local targetPos = part.Position + Vector3.new(0, 10, 0)
            forceTeleport(targetPos)
            print("tped to itemspawns." .. i)
            task.wait(0.8)
        else
            print("part " .. i .. " not found")
        end
    end
end

local function processPart(partNumber)
    local itemSpawns = workspace:FindFirstChild("ItemSpawns") or workspace:FindFirstChild("itemSpawns")
    if not itemSpawns then return end

    local part = itemSpawns:FindFirstChild(tostring(partNumber))
    if not part then return end

    print("processing itemspawns." .. partNumber)
    forceTeleport(SAFE_POSITION)

    local count = 0
    for _, item in ipairs(part:GetChildren()) do
        if item:IsA("Model") and item.Name == "SpawnedItem" then
            local mesh = item:FindFirstChild("Mesh")
            if mesh then
                local prompt = mesh:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    triggerPrompt(prompt, item)
                    count = count + 1
                    forceTeleport(SAFE_POSITION)
                    task.wait(0.6)
                end
            end
        end
    end

    print("finished itemspawns." .. partNumber .. " (" .. count .. " items)")
end

print("=== bike obby for brainrots (136919941417380) || coded by harpreet / @iiicrybalenci ===")

visitAllParts()

print("tping to safe position...")
forceTeleport(SAFE_POSITION)
task.wait(1.5)

print("starting pickup loop for parts 7-10...")
for i = 7, 10 do
    processPart(i)
    task.wait(2)
end

print("all parts 7-10 completed")
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local env = getgenv()
local httpservice = game:GetService("HttpService")

if typeof(isfolder) == "function" and typeof(makefolder) == "function" and not isfolder("BrainrotPolice") then
    makefolder("BrainrotPolice")
end

if typeof(isfile) == "function" and typeof(writefile) == "function" and not isfile("BrainrotPolice/Config.json") then
    writefile("BrainrotPolice/Config.json", httpservice:JSONEncode({
        settings = {
            auto_rejoin_on_kick = false,
            disable_3d_rendering = false
        }
    }))
end

function env.import(id)
    local ok, objects = pcall(function()
        return game:GetObjects(id)
    end)

    if ok and objects then
        return objects[1]
    end

    warn("[BrainrotPolice] Failed to import asset: " .. tostring(id))
    return nil
end

function env.getgitpath(where)
    local mainBuild = "https://raw.githubusercontent.com/Xaric23/BrainrotPolice/refs/heads/main/"
    local paths = {
        src = mainBuild .. "src/",
        games = mainBuild .. "src/games/"
    }

    return paths[where] or mainBuild
end

function env.setconfig(key, value)
    if typeof(readfile) ~= "function" or typeof(writefile) ~= "function" then
        return
    end

    local dec = httpservice:JSONDecode(readfile("BrainrotPolice/Config.json"))
    dec[tostring(game.PlaceId)] = dec[tostring(game.PlaceId)] or {}
    dec[tostring(game.PlaceId)][key] = value
    writefile("BrainrotPolice/Config.json", httpservice:JSONEncode(dec))
end

game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    if env.autorjjjj then
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
end)

local ok, uiSource = pcall(function()
    return game:HttpGet(getgitpath("src") .. "ui.lua")
end)

if ok and uiSource and #uiSource > 0 then
    local loadedUi, err = loadstring(uiSource)
    if loadedUi then
        loadedUi()
    else
        warn("[BrainrotPolice] Failed to load UI: " .. tostring(err))
    end
else
    warn("[BrainrotPolice] Failed to download UI.")
end

if typeof(queue_on_teleport) == "function" then
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/Xaric23/BrainrotPolice/refs/heads/main/src/init.lua"))()')
end

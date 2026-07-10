local hui = gethui or get_hidden_gui
local getexec = identifyexecutor or function()
    return "Unknown"
end
local coregui = game:GetService("CoreGui")
local userinputservice = game:GetService("UserInputService")
local httpservice = game:GetService("HttpService")
local experienceService = game:GetService("ExperienceService")
local guiService = game:GetService("GuiService")
local utils = loadstring(game:HttpGet(getgitpath("src") .. "utils.lua"))()

local DEFAULT_CONFIG = {
    settings = {
        auto_rejoin_on_kick = false,
        disable_3d_rendering = false
    }
}

local function fetch(path)
    local ok, body = pcall(function()
        return game:HttpGet(path)
    end)

    if ok and body and body ~= "404: Not Found" then
        return body
    end

    return nil
end

local function decodeJsonBody(body, fallback)
    if not body then
        return fallback
    end

    local ok, decoded = pcall(function()
        return httpservice:JSONDecode(body)
    end)

    if ok and decoded then
        return decoded
    end

    return fallback
end

local function decodeJson(path, fallback)
    return decodeJsonBody(fetch(path), fallback)
end

local function readConfig()
    if typeof(isfile) == "function" and typeof(readfile) == "function" and isfile("BrainrotPolice/Config.json") then
        local config = decodeJsonBody(readfile("BrainrotPolice/Config.json"), DEFAULT_CONFIG)
        config.settings = config.settings or {}
        config.settings.auto_rejoin_on_kick = config.settings.auto_rejoin_on_kick == true
        config.settings.disable_3d_rendering = config.settings.disable_3d_rendering == true
        return config
    end

    return DEFAULT_CONFIG
end

local function writeConfig(config)
    if typeof(writefile) == "function" then
        writefile("BrainrotPolice/Config.json", httpservice:JSONEncode(config))
    end
end

local function loadModule(source)
    if not source or #source == 0 then
        return nil
    end

    local loaded = loadstring(source)
    if not loaded then
        return nil
    end

    local ok, module = pcall(loaded)
    if ok then
        return module
    end

    return nil
end

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

local ui = import("rbxassetid://75281832304062")
if not ui then
    warn("[BrainrotPolice] UI asset failed to load.")
    return
end

ui.Parent = hui and hui() or coregui

local ToggleButton = ui.togglebtn
local MainFrame = ui.Frame

local Topbar = MainFrame.TopBar
local SectionContainers = MainFrame.sectionContainers
local TabList = MainFrame.tablist

local HideButton = Topbar.hidebtn

local Sections = {
    Home = {
        TabBtn = TabList.HomeTab,
        Container = SectionContainers.homeframe
    },

    Game = {
        TabBtn = TabList.GameTab,
        Container = SectionContainers.gameFrame
    },

    GamesList = {
        TabBtn = TabList.GameslistTab,
        Container = SectionContainers.gamelistFrame
    },

    Settings = {
        TabBtn = TabList.SettingsTab,
        Container = SectionContainers.settingsFrame
    },

    Credits = {
        TabBtn = TabList.CreditsTab,
        Container = SectionContainers.creditsFrame
    }
}

local CurSection

local function switchSection(sect)
    if CurSection == sect then return end

    if CurSection then
        CurSection.TabBtn.BackgroundTransparency = 1
        CurSection.Container:TweenPosition(UDim2.new(0.5, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
    end

    sect.TabBtn.BackgroundTransparency = 0
    sect.Container:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
    sect.Container.Visible = true

    CurSection = sect
end

for _, sect in pairs(Sections) do
    sect.TabBtn.MouseEnter:Connect(function()
        for _, stroke in pairs(sect.TabBtn:GetChildren()) do
            if stroke.Name == "InnerShadow" then
                stroke.Transparency = 0.95
            end
        end
    end)

    sect.TabBtn.MouseLeave:Connect(function()
        for _, stroke in pairs(sect.TabBtn:GetChildren()) do
            if stroke.Name == "InnerShadow" then
                stroke.Transparency = 1
            end
        end
    end)

    sect.TabBtn.MouseButton1Click:Connect(function()
        switchSection(sect)
    end)
end

HideButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleButton.Visible = true
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleButton.Visible = false
end)

local dragging = false
local dragInput, mousePos, framePos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

userinputservice.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

Sections.Home.Container.bugsLabel.Text = Sections.Home.Container.bugsLabel.Text:gsub("redacted", "discord.gg/vaehz")
Sections.Home.Container.discan.Text = Sections.Home.Container.discan.Text:gsub("redacted", "discord.gg/vaehz")
Sections.Home.Container.ythead.Text = Sections.Home.Container.ythead.Text:gsub("redacted", "YouTube")
Sections.Home.Container.execLabel.Text = "Executor: " .. getexec()
Sections.Home.Container.versionLabel.Text = "Version: 0.33 BETA"

local config = readConfig()
local gamePath = fetch(getgitpath("games") .. tostring(game.PlaceId) .. ".lua")
local gameList = decodeJson(getgitpath("src") .. "gameslist.json", {})
local creditsList = decodeJson(getgitpath("src") .. "credits.json", {})
local elements = loadModule(fetch(getgitpath("src") .. "elements.lua"))
if not elements then
    warn("[BrainrotPolice] Elements failed to load.")
    return
end

if not gamePath then
    local handledLocally = false

    if getgenv().FileScripts and typeof(isfile) == "function" and typeof(readfile) == "function" then
        local localPath = "BrainrotPolice/" .. tostring(game.PlaceId) .. ".lua"
        if isfile(localPath) then
            local gameModule = loadModule(readfile(localPath))
            if gameModule then
                utils.SafeCall(gameModule, Sections.Game.Container, config)
                handledLocally = true
            end
        end
    end

    if not handledLocally then
        elements:Unsupported(Sections.Game.Container, function()
            switchSection(Sections.GamesList)
        end)
    end
else
    local gameModule = loadModule(gamePath)
    if gameModule then
        utils.SafeCall(gameModule, Sections.Game.Container, config)
    else
        elements:Label("Game script failed to load.", Sections.Game.Container)
    end
end
elements:Searchbar(Sections.GamesList.Container)
for _, g in ipairs(gameList) do
    elements:addGame(Sections.GamesList.Container, g["game"], g["status"], function()
        teleportToGame(g.id)
    end)
end

for sect, c in pairs(creditsList) do
    elements:CredHead(Sections.Credits.Container, sect)

    for _, person in ipairs(c) do
        elements:CredPerson(Sections.Credits.Container, person)
    end
end

elements:Toggle("Disable 3D Rendering", Sections.Settings.Container, config.settings.disable_3d_rendering, function(v)
    local latest = readConfig()
    latest.settings.disable_3d_rendering = v
    writeConfig(latest)
    game:GetService("RunService"):Set3dRenderingEnabled(not v)
end)

elements:Toggle("Auto Rejoin (when kicked)", Sections.Settings.Container, config.settings.auto_rejoin_on_kick, function(v)
    local latest = readConfig()
    latest.settings.auto_rejoin_on_kick = v
    writeConfig(latest)
    getgenv().autorjjjj = v
end)

local Event = game:GetService("ReplicatedStorage").Paper.Remotes.__remoteevent
local depositAtMultiplier = true -- Toggle for deposit mode

-- Intercept the event and check for 1.5x multiplier
for _, Connection in getconnections(Event.OnClientEvent) do
    local old; old = hookfunction(Connection.Function, function(...)
        local args = {...}
        
        -- Check if this is the 1.5x multiplier event and if deposit mode is enabled
        if depositAtMultiplier and args[1] == "UI-Notification" and args[2] and args[2].Text then
            if args[2].Text == "Egg Multiplier rose to 1.5x!" then
                print("1.5x multiplier detected! Depositing eggs...")
                
                -- Just deposit the eggs (they're already collected)
                local mainFunction = game:GetService("ReplicatedStorage").Paper.Remotes.__remotefunction
                pcall(function()
                    mainFunction:InvokeServer("Deposit Eggs")
                    print("Eggs deposited at 1.5x multiplier!")
                end)
            end
        end
        
        print(`Intercepted (Connection) {Event.Name}.OnClientEvent`, ...)
        return old(...)
    end)
end

return function(section)
    local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
    local env = getgenv()
    local plr = game:GetService("Players").LocalPlayer

    env.Collecting = false
    env.CollectCash = false
    env.AutoLuckyBlock = false
    env.AutoMerge = false
    env.AutoBuy = false
    env.AutoRebirth = false
    env.AutoDeposit = false

    -- Load config
    local data = {}
    if isfile("BrainrotPolice/Config.json") then
        data = game:GetService("HttpService"):JSONDecode(readfile("BrainrotPolice/Config.json"))
    end
    
    local setdata = data[tostring(game.PlaceId)] or {}
    setdata.collecting = setdata.collecting or false
    setdata.collectCash = setdata.collectCash or false
    setdata.depositMode = setdata.depositMode or true
    setdata.autoLuckyBlock = setdata.autoLuckyBlock or false
    setdata.autoMerge = setdata.autoMerge or false
    setdata.autoBuy = setdata.autoBuy or false
    setdata.autoRebirth = setdata.autoRebirth or false
    setdata.autoDeposit = setdata.autoDeposit or false
    data[tostring(game.PlaceId)] = setdata
    writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))

    local cashval = plr.PlayerGui.Main.Currencies.Cash.List.Amount
    local mainEvent = game:GetService("ReplicatedStorage").Paper.Remotes.__remoteevent
    local mainFunction = game:GetService("ReplicatedStorage").Paper.Remotes.__remotefunction
    local buyBtns = workspace.Plots[plr.Name].Buttons.BuyChickens

    local collectCon
    local luckyBlockRunning = false
    local mergeRunning = false
    local cashRunning = false
    local buyRunning = false
    local rebirthRunning = false
    local depositRunning = false

    -- Suffixes for parsing numbers
    local suffixes = {
        "K","M","B","T","Qd","Qn","Sx","Sp","Oc","No","De",
        "UDe","DDe","TDe","QdDe","QnDe","SxDe","SpDe","OcDe","NoDe","Vt",
        "UVt","DVt","TVt","QdVt","QnVt","SxVt","SpVt","OcVt","NoVt","Tg",
        "UTg","DTg","TTg","QdTg","QnTg","SxTg","SpTg","OcTg","NoTg","qg",
        "Uqg","Dqg","Tqg","Qdqg","Qnqg","Sxqg","Spqg","Ocqg","Noqg","Qg",
        "UQg","DQg","TQg","QdQg","QnQg","SxQg","SpQg","OcQg","NoQg","sg",
        "Usg","Dsg","Tsg","Qdsg","Qnsg","Sxsg","Spsg","Ocsg","Nosg","Sg",
        "USg","DSg","TSg","QdSg","QnSg","SxSg","SpSg","OcSg","NoSg","Og",
        "UOg","DOg","TOg","QdOg","QnOg","SxOg","SpOg","OcOg","NoOg","Ng",
        "UNg","DNg","TNg","QdNg","QnNg","SxNg","SpNg","OcNg","NoNg","Ce","UCe"
    }

    local suffixValue = {}
    for i, suf in ipairs(suffixes) do
        suffixValue[suf] = 1000 ^ i
    end

    local function parseSuffixedNumber(str)
        str = str:gsub("[%$,%s]", "")
        local numberPart, suffixPart = str:match("^(-?%d*%.?%d+)(%a*)$")
        local base = tonumber(numberPart)
        if suffixPart == "" then
            return base
        end
        local multiplier = suffixValue[suffixPart]
        return base * multiplier
    end

    -- Function to check if an egg is a lucky block
    local function isLuckyBlock(egg)
        if not egg then return false end
        
        -- Check if it has the LuckyBlock attribute
        if egg:GetAttribute("LuckyBlock") ~= nil then
            return true
        end
        
        -- Check by name as backup
        if egg.Name == "LuckyBlock" then
            return true
        end
        
        return false
    end

    -- Simplified working lucky block handler
    local function handleLuckyBlock()
        local remoteFunction = game:GetService("ReplicatedStorage").Paper.Remotes.__remotefunction
        local remoteEvent = game:GetService("ReplicatedStorage").Paper.Remotes.__remoteevent
        
        local function claimOpenedChicken()
            pcall(function()
                remoteEvent:FireServer("Claim Opened Chicken")
            end)
        end
        
        -- Try to open the lucky block
        local result = remoteFunction:InvokeServer("Open Lucky Block")
        
        if type(result) == "table" then
            if result[1] == true then
                print("✅ Lucky Block opened! Tier:", result[2])
                claimOpenedChicken()
            else
                local errorMsg = result[2] or "Unknown error"
                print("❌ Failed:", errorMsg)
                
                -- Check for money issue
                if errorMsg and string.find(string.lower(errorMsg), "need") then
                    print("💰 Not enough money, discarding...")
                    pcall(function()
                        remoteEvent:FireServer("Discard Lucky Block")
                    end)
                elseif errorMsg and string.find(string.lower(errorMsg), "please wait") then
                    print("⏳ Please wait, claiming and retrying...")
                    claimOpenedChicken()
                    task.wait(3)
                    
                    local retry = remoteFunction:InvokeServer("Open Lucky Block")
                    if type(retry) == "table" and retry[1] == true then
                        print("✅ Opened on retry! Tier:", retry[2])
                        claimOpenedChicken()
                    else
                        print("❌ Retry failed, keeping the lucky block...")
                    end
                else
                    print("💡 Keeping the lucky block...")
                end
            end
        elseif type(result) == "boolean" then
            if result then
                print("✅ Lucky Block opened!")
                claimOpenedChicken()
            else
                print("❌ Failed to open, discarding...")
                pcall(function()
                    remoteEvent:FireServer("Discard Lucky Block")
                end)
            end
        else
            print("❌ Unexpected result, keeping the lucky block...")
        end
    end

    elements:Label("LUCKY BLOCK FARMING - ALL TOGGLES INDEPENDENT", section)

    -- Toggle for deposit mode
    elements:Toggle("Deposit at 1.5x only", section, setdata.depositMode, function(v)
        depositAtMultiplier = v
        setdata.depositMode = v
        data[tostring(game.PlaceId)] = setdata
        writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
        
        if v then
            print("Deposit mode: Only at 1.5x multiplier")
        else
            print("Deposit mode: Auto deposit (every 30 seconds)")
        end
    end)

    -- Auto Deposit Toggle (only works when 1.5x mode is OFF)
    elements:Toggle("Auto Deposit (30s)", section, setdata.autoDeposit, function(v)
        env.AutoDeposit = v
        setdata.autoDeposit = v
        data[tostring(game.PlaceId)] = setdata
        writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
        
        print("Auto Deposit toggled to: " .. tostring(v))
        
        if not env.AutoDeposit then
            depositRunning = false
            return
        end
        
        -- Start deposit loop - runs every 30 seconds
        if not depositRunning then
            depositRunning = true
            task.spawn(function()
                while depositRunning and env.AutoDeposit do
                    -- Only deposit if 1.5x mode is OFF
                    if not depositAtMultiplier then
                        pcall(function()
                            -- First collect all eggs
                            for i, v in pairs(workspace.Eggs:GetChildren()) do
                                if not isLuckyBlock(v) then
                                    mainEvent:FireServer("Collect Egg", v.Name)
                                    task.wait()
                                    v:Destroy()
                                end
                            end
                            -- Then deposit them
                            mainFunction:InvokeServer("Deposit Eggs")
                            print("🥚 Deposited eggs (auto deposit)!")
                        end)
                    else
                        print("⏭️ Skipping auto deposit (1.5x mode is ON)")
                    end
                    task.wait(30) -- Wait 30 seconds between deposits
                end
            end)
        end
    end)
    
    -- If deposit was previously ON, start it
    if setdata.autoDeposit then
        env.AutoDeposit = true
        if not depositRunning then
            depositRunning = true
            task.spawn(function()
                while depositRunning and env.AutoDeposit do
                    -- Only deposit if 1.5x mode is OFF
                    if not depositAtMultiplier then
                        pcall(function()
                            -- First collect all eggs
                            for i, v in pairs(workspace.Eggs:GetChildren()) do
                                if not isLuckyBlock(v) then
                                    mainEvent:FireServer("Collect Egg", v.Name)
                                    task.wait()
                                    v:Destroy()
                                end
                            end
                            -- Then deposit them
                            mainFunction:InvokeServer("Deposit Eggs")
                            print("🥚 Deposited eggs (auto deposit)!")
                        end)
                    else
                        print("⏭️ Skipping auto deposit (1.5x mode is ON)")
                    end
                    task.wait(30) -- Wait 30 seconds between deposits
                end
            end)
        end
    end

    -- Auto Lucky Block Toggle
    elements:Toggle("Auto Lucky Block", section, setdata.autoLuckyBlock, function(v)
        env.AutoLuckyBlock = v
        setdata.autoLuckyBlock = v
        data[tostring(game.PlaceId)] = setdata
        writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
        
        print("Auto Lucky Block toggled to: " .. tostring(v))
        
        if not env.AutoLuckyBlock then
            luckyBlockRunning = false
            return
        end
        
        -- Start lucky block handler loop - runs every 1 second
        if not luckyBlockRunning then
            luckyBlockRunning = true
            task.spawn(function()
                while luckyBlockRunning and env.AutoLuckyBlock do
                    pcall(function()
                        handleLuckyBlock()
                    end)
                    task.wait(1) -- Wait 1 second between attempts
                end
            end)
        end
    end)
    
    -- If lucky block toggle was previously ON, start it
    if setdata.autoLuckyBlock then
        env.AutoLuckyBlock = true
        if not luckyBlockRunning then
            luckyBlockRunning = true
            task.spawn(function()
                while luckyBlockRunning and env.AutoLuckyBlock do
                    pcall(function()
                        handleLuckyBlock()
                    end)
                    task.wait(1) -- Wait 1 second between attempts
                end
            end)
        end
    end

    -- Auto Buy Chickens Toggle
    elements:Toggle("Auto Buy Chickens", section, setdata.autoBuy, function(v)
        env.AutoBuy = v
        setdata.autoBuy = v
        data[tostring(game.PlaceId)] = setdata
        writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
        
        print("Auto Buy Chickens toggled to: " .. tostring(v))
        
        if not env.AutoBuy then
            buyRunning = false
            return
        end
        
        -- Start buy loop - runs every 5 seconds
        if not buyRunning then
            buyRunning = true
            task.spawn(function()
                while buyRunning and env.AutoBuy do
                    pcall(function()
                        -- First collect cash
                        mainFunction:InvokeServer("Collect Cash")
                        task.wait()
                        
                        -- Then upgrade process level
                        mainFunction:InvokeServer("Upgrade Process Level")
                        task.wait()
                        
                        -- Determine how many chickens to buy
                        local tobuy = 0
                        local result = parseSuffixedNumber(cashval.Text)
                        if parseSuffixedNumber(buyBtns.Buy100.Button.UI.Cost.Text) <= result then
                            tobuy = 100
                        elseif parseSuffixedNumber(buyBtns.Buy25.Button.UI.Cost.Text) <= result then
                            tobuy = 25
                        elseif parseSuffixedNumber(buyBtns.Buy5.Button.UI.Cost.Text) <= result then
                            tobuy = 5
                        elseif parseSuffixedNumber(buyBtns.Buy1.Button.UI.Cost.Text) <= result then
                            tobuy = 1
                        end
                        
                        if tobuy > 0 then
                            mainFunction:InvokeServer("Buy Chickens", tobuy)
                            print("🐔 Bought " .. tobuy .. " chickens!")
                        end
                    end)
                    task.wait(5) -- Wait 5 seconds between buy attempts
                end
            end)
        end
    end)
    
    -- If buy was previously ON, start it
    if setdata.autoBuy then
        env.AutoBuy = true
        if not buyRunning then
            buyRunning = true
            task.spawn(function()
                while buyRunning and env.AutoBuy do
                    pcall(function()
                        -- First collect cash
                        mainFunction:InvokeServer("Collect Cash")
                        task.wait()
                        
                        -- Then upgrade process level
                        mainFunction:InvokeServer("Upgrade Process Level")
                        task.wait()
                        
                        -- Determine how many chickens to buy
                        local tobuy = 0
                        local result = parseSuffixedNumber(cashval.Text)
                        if parseSuffixedNumber(buyBtns.Buy100.Button.UI.Cost.Text) <= result then
                            tobuy = 100
                        elseif parseSuffixedNumber(buyBtns.Buy25.Button.UI.Cost.Text) <= result then
                            tobuy = 25
                        elseif parseSuffixedNumber(buyBtns.Buy5.Button.UI.Cost.Text) <= result then
                            tobuy = 5
                        elseif parseSuffixedNumber(buyBtns.Buy1.Button.UI.Cost.Text) <= result then
                            tobuy = 1
                        end
                        
                        if tobuy > 0 then
                            mainFunction:InvokeServer("Buy Chickens", tobuy)
                            print("🐔 Bought " .. tobuy .. " chickens!")
                        end
                    end)
                    task.wait(5) -- Wait 5 seconds between buy attempts
                end
            end)
        end
    end

    -- Auto Rebirth Toggle
    elements:Toggle("Auto Rebirth", section, setdata.autoRebirth, function(v)
        env.AutoRebirth = v
        setdata.autoRebirth = v
        data[tostring(game.PlaceId)] = setdata
        writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
        
        print("Auto Rebirth toggled to: " .. tostring(v))
        
        if not env.AutoRebirth then
            rebirthRunning = false
            return
        end
        
        -- Start rebirth loop - runs every 30 seconds
        if not rebirthRunning then
            rebirthRunning = true
            task.spawn(function()
                while rebirthRunning and env.AutoRebirth do
                    pcall(function()
                        local result = mainFunction:InvokeServer("Rebirth")
                        print("🔄 Rebirth attempted! Result:", result)
                    end)
                    task.wait(30) -- Wait 30 seconds between rebirth attempts
                end
            end)
        end
    end)
    
    -- If rebirth was previously ON, start it
    if setdata.autoRebirth then
        env.AutoRebirth = true
        if not rebirthRunning then
            rebirthRunning = true
            task.spawn(function()
                while rebirthRunning and env.AutoRebirth do
                    pcall(function()
                        local result = mainFunction:InvokeServer("Rebirth")
                        print("🔄 Rebirth attempted! Result:", result)
                    end)
                    task.wait(30) -- Wait 30 seconds between rebirth attempts
                end
            end)
        end
    end

    -- Auto Merge Chickens Toggle
    elements:Toggle("Auto Merge Chickens", section, setdata.autoMerge, function(v)
        env.AutoMerge = v
        setdata.autoMerge = v
        data[tostring(game.PlaceId)] = setdata
        writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
        
        print("Auto Merge Chickens toggled to: " .. tostring(v))
        
        if not env.AutoMerge then
            mergeRunning = false
            return
        end
        
        -- Start merge loop - runs every 10 seconds
        if not mergeRunning then
            mergeRunning = true
            task.spawn(function()
                while mergeRunning and env.AutoMerge do
                    pcall(function()
                        mainFunction:InvokeServer("Merge Chickens")
                        print("🔄 Merged chickens!")
                    end)
                    task.wait(10) -- Wait 10 seconds between merges
                end
            end)
        end
    end)
    
    -- If merge was previously ON, start it
    if setdata.autoMerge then
        env.AutoMerge = true
        if not mergeRunning then
            mergeRunning = true
            task.spawn(function()
                while mergeRunning and env.AutoMerge do
                    pcall(function()
                        mainFunction:InvokeServer("Merge Chickens")
                        print("🔄 Merged chickens!")
                    end)
                    task.wait(10) -- Wait 10 seconds between merges
                end
            end)
        end
    end

    -- Auto Collect Cash Toggle
    elements:Toggle("Auto Collect Cash", section, setdata.collectCash, function(v)
        env.CollectCash = v
        setdata.collectCash = v
        data[tostring(game.PlaceId)] = setdata
        writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
        
        print("Auto Collect Cash toggled to: " .. tostring(v))
        
        if not env.CollectCash then
            cashRunning = false
            return
        end
        
        -- Start cash collection loop - runs every 10 seconds
        if not cashRunning then
            cashRunning = true
            task.spawn(function()
                while cashRunning and env.CollectCash do
                    pcall(function()
                        mainFunction:InvokeServer("Collect Cash")
                        print("💰 Collected cash!")
                    end)
                    task.wait(10) -- Wait 10 seconds between collections
                end
            end)
        end
    end)
    
    -- If cash collection was previously ON, start it
    if setdata.collectCash then
        env.CollectCash = true
        if not cashRunning then
            cashRunning = true
            task.spawn(function()
                while cashRunning and env.CollectCash do
                    pcall(function()
                        mainFunction:InvokeServer("Collect Cash")
                        print("💰 Collected cash!")
                    end)
                    task.wait(10) -- Wait 10 seconds between collections
                end
            end)
        end
    end

    -- Standalone Egg Collection Toggle
    elements:Toggle("Collect Eggs Only", section, setdata.collecting, function(v)
        -- Update the state
        env.Collecting = v
        setdata.collecting = v
        data[tostring(game.PlaceId)] = setdata
        writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
        
        print("Collect Eggs Only toggled to: " .. tostring(v))
        
        if not env.Collecting then 
            if collectCon then 
                collectCon:Disconnect() 
                collectCon = nil
            end
            return 
        end
        
        -- Collect any existing eggs (skip lucky blocks)
        for i, v in pairs(workspace.Eggs:GetChildren()) do
            if not isLuckyBlock(v) then
                print("Collecting egg: " .. v.Name)
                mainEvent:FireServer("Collect Egg", v.Name)
                task.wait()
                v:Destroy()
            else
                print("Skipping lucky block: " .. v.Name)
            end
        end
        
        -- Watch for new eggs and collect them (skip lucky blocks)
        collectCon = workspace.Eggs.ChildAdded:Connect(function(c)
            task.wait(1)
            if not isLuckyBlock(c) then
                print("Collecting new egg: " .. c.Name)
                mainEvent:FireServer("Collect Egg", c.Name)
                task.wait()
                c:Destroy()
            else
                print("Skipping lucky block: " .. c.Name)
            end
        end)
    end)
    
    -- If the toggle was previously ON, start collecting immediately (skip lucky blocks)
    if setdata.collecting then
        env.Collecting = true
        -- Collect any existing eggs (skip lucky blocks)
        for i, v in pairs(workspace.Eggs:GetChildren()) do
            if not isLuckyBlock(v) then
                print("Collecting egg: " .. v.Name)
                mainEvent:FireServer("Collect Egg", v.Name)
                task.wait()
                v:Destroy()
            else
                print("Skipping lucky block: " .. v.Name)
            end
        end
        
        -- Watch for new eggs and collect them (skip lucky blocks)
        collectCon = workspace.Eggs.ChildAdded:Connect(function(c)
            task.wait(1)
            if not isLuckyBlock(c) then
                print("Collecting new egg: " .. c.Name)
                mainEvent:FireServer("Collect Egg", c.Name)
                task.wait()
                c:Destroy()
            else
                print("Skipping lucky block: " .. c.Name)
            end
        end)
    end
end

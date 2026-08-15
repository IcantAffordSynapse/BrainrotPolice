-- [💎] +1 Loot Evo 🐲
--
-- Notes on how this game actually works, since most of it is not obvious:
--   * ClickRequest:FireServer() takes no arguments and is what raises Damage.
--     It works with no mob in sight and at the same rate inside a stage, because
--     it bypasses the client gate that would otherwise turn clicks into attacks.
--   * A stage only starts when its StageStartPart receives a Touched event, so
--     teleporting in leaves you standing in an empty room - firetouchinterest is
--     what actually starts it.
--   * Wins are claimed by touching WinBut.TouchPart after a run. The pad pays
--     once per run, and 2xWinBut is the paid Robux pad, so it is never touched.
--   * Weapons are not owned, they are held by the wins balance: drop below the
--     price of the blade in hand and the game takes it back. Every other
--     purchase therefore keeps that price in reserve.
--   * Skills are bought in a panel whose purchase button is confusingly named
--     "Rebirth"; casting is done by pressing the on-screen Q/E/R buttons, since
--     calling SkillController:UseSkill directly does nothing.
--   * Rebirth is refused inside a stage and accepted from the hall.

return function(section, data)
    local elements = loadstring(game:HttpGet(getgitpath("src") .. "elements.lua"))()
    local env = getgenv()

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")

    local plr = Players.LocalPlayer

    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local clickRemote = Remotes:WaitForChild("ClickRequest")
    local snapshotRemote = Remotes:WaitForChild("GetPlayerDataSnapshot")
    local backpackRemote = Remotes:WaitForChild("BackPackActionEvent")
    local rebirthRemote = Remotes:WaitForChild("RebirthRequest")
    local buyEggRemote = Remotes:WaitForChild("BuyEggEvent")

    local weaponCfg = require(ReplicatedStorage.Config.WeaponConfig)
    local checkpointCfg = require(ReplicatedStorage.Config.CheckPointConfig)
    local stageCfg = require(ReplicatedStorage.Config.StageConfig)
    local mobCfg = require(ReplicatedStorage.Config.MobConfig)
    local eggHelper = require(ReplicatedStorage.Config.EggHelper)

    local stageRoot = workspace.Scene.Stage
    local hall = workspace.Scene.Hall
    local weaponArea = hall:FindFirstChild("WeaponArea")
    local HALL_POSITION = Vector3.new(319.105, 7.75, -81.22)
    local MAX_STAGE = 36

    -- One generation counter so a second execute retires the previous loops
    -- instead of running two of everything.
    env.LootEvoRun = (env.LootEvoRun or 0) + 1
    local generation = env.LootEvoRun

    local saved = data[tostring(game.PlaceId)] or {}

    local CONFIG = {
        autoClick = saved.autoClick or false,
        clickRate = 25,
        autoFarm = saved.autoFarm or false,
        fastSeconds = 5,
        stageTimeout = 35,
        spawnTimeout = 5,
        farmRuns = 5,
        autoWeapon = saved.autoWeapon or false,
        autoSkill = saved.autoSkill or false,
        castSkills = saved.castSkills or false,
        skipDash = true,
        autoAura = saved.autoAura or false,
        autoEgg = saved.autoEgg or false,
        petCopies = 3,
        autoRebirth = saved.autoRebirth or false,
        autoEquip = saved.autoEquip or false,
    }

    local STATE = {
        wins = 0, level = 0, rebirth = 0, damage = 0, cleared = 0, needLevel = 0,
        weapon = "-", unlocked = {}, ownedAuras = {},
        ladder = 1, blockedAt = 0, bankRuns = 0, tooHard = {}, noSpawn = {},
        lastLevel = 0, primed = false, runs = 0, clicks = 0,
    }

    local function shortNumber(n)
        n = tonumber(n) or 0
        for _, unit in ipairs({ { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }) do
            if n >= unit[1] then return string.format("%.1f%s", n / unit[1], unit[2]) end
        end
        return tostring(math.floor(n))
    end

    local function rootPart()
        local char = plr.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function touch(part)
        local hrp = rootPart()
        if not hrp or not part or not firetouchinterest then return false end
        firetouchinterest(hrp, part, 0)
        task.wait(0.2)
        firetouchinterest(hrp, part, 1)
        return true
    end

    -- Catalogues --------------------------------------------------------------

    local WEAPONS, WEAPON_BY_ID = {}, {}
    for _, entry in pairs(weaponCfg) do
        if type(entry) == "table" and type(entry.ID) == "string" then
            local index = entry.ID:match("^Weapon(%d+)$")
            if index then
                local weapon = {
                    id = entry.ID,
                    name = entry.Name or entry.ID,
                    price = entry.VictoryPoint or 0,
                    power = entry.EXP or 0,
                }
                table.insert(WEAPONS, weapon)
                WEAPON_BY_ID[weapon.id] = weapon
            end
        end
    end

    local EGGS = {}
    do
        local ok, all = pcall(eggHelper.GetAllEggs)
        if ok and type(all) == "table" then
            for _, entry in pairs(all) do
                if type(entry) == "table" and entry.ID then
                    table.insert(EGGS, {
                        id = entry.ID,
                        name = entry.Name or entry.ID,
                        price = entry.VictoryPoints or 0,
                    })
                end
            end
        end
        table.sort(EGGS, function(a, b) return a.price < b.price end)
    end

    local EGG_BEST = {}
    for _, egg in ipairs(EGGS) do
        local ok, pool = pcall(eggHelper.GetPoolData, egg.id)
        if ok and type(pool) == "table" then
            local best
            for _, pet in pairs(pool) do
                if type(pet) == "table" and pet.Name then
                    if not best or (pet.Addition or 0) > (best.Addition or 0) then best = pet end
                end
            end
            if best then EGG_BEST[egg.id] = { name = best.Name, addition = best.Addition or 0 } end
        end
    end

    local AURAS = {}
    do
        local ok, auraCfg = pcall(require, ReplicatedStorage.Config.AuraConfig)
        if ok and type(auraCfg) == "table" then
            for key, entry in pairs(auraCfg) do
                if type(entry) == "table" and entry.ID then
                    table.insert(AURAS, {
                        id = entry.ID,
                        index = tonumber(key) or tonumber(entry.ID:match("%d+")) or 1,
                        name = entry.Name or entry.ID,
                        price = entry.Wins or math.huge,
                    })
                end
            end
        end
        table.sort(AURAS, function(a, b) return a.price < b.price end)
    end

    -- Live controllers --------------------------------------------------------
    --
    -- Walking the garbage collector is ~30ms, so it runs once in chunks and the
    -- result is cached. activeLocalStage is nil while in the hall, so freshness
    -- is checked against a field the controller always carries.

    env.LootEvoCtrl = env.LootEvoCtrl or { stage = nil, skill = nil, scanning = false, lastScan = 0 }
    local CTRL = env.LootEvoCtrl

    local function scanControllers()
        if CTRL.scanning or os.clock() - CTRL.lastScan < 20 then return end
        CTRL.scanning = true
        CTRL.lastScan = os.clock()

        task.spawn(function()
            local objects = getgc(true)
            local stageClass, skillClass
            local processed = 0

            for _, t in pairs(objects) do
                if type(t) == "table" and rawget(t, "new") ~= nil then
                    if not stageClass and rawget(t, "DamageLocalMobsInRadius") ~= nil then stageClass = t end
                    if not skillClass and rawget(t, "GetEquippedSkillIds") ~= nil then skillClass = t end
                end
                processed = processed + 1
                if processed % 500 == 0 then task.wait() end
            end

            processed = 0
            for _, t in pairs(objects) do
                if type(t) == "table" then
                    local meta = getmetatable(t)
                    if stageClass and meta == stageClass and rawget(t, "attackHitDelays") ~= nil then CTRL.stage = t end
                    if skillClass and meta == skillClass and rawget(t, "audio") ~= nil then CTRL.skill = t end
                end
                processed = processed + 1
                if processed % 500 == 0 then task.wait() end
            end

            CTRL.scanning = false
        end)
    end

    local function stageCtrl()
        local c = CTRL.stage
        if c and rawget(c, "attackHitDelays") ~= nil then return c end
        CTRL.stage = nil
        scanControllers()
        return nil
    end

    -- Data --------------------------------------------------------------------

    local function resetProgression()
        STATE.ladder = 1
        STATE.blockedAt = 0
        STATE.bankRuns = 0
        STATE.tooHard = {}
        STATE.noSpawn = {}
    end

    local function snapshot()
        -- Captured before anything is overwritten; comparing after the
        -- assignment compares the value with itself and the rebirth is missed.
        local previousRebirth = STATE.rebirth

        local ok, snap = pcall(function() return snapshotRemote:InvokeServer() end)
        if not ok or type(snap) ~= "table" then return nil end

        STATE.wins = snap.VictoryPoints or 0
        STATE.level = snap.Level or 0
        STATE.rebirth = snap.Rebirth or 0
        STATE.damage = snap.Damage or 0
        STATE.cleared = snap.HighestClearedStage or 0
        STATE.needLevel = snap.NextRebirthNeedLevel or 0
        STATE.weapon = tostring(snap.EquippedWeapon or "-")
        STATE.unlocked = type(snap.UnlockedEquipment) == "table" and snap.UnlockedEquipment or STATE.unlocked

        if type(snap.OwnedAuras) == "table" then
            local owned = {}
            for key, value in pairs(snap.OwnedAuras) do
                if type(value) == "string" then owned[value] = true
                elseif value == true then owned[tostring(key)] = true end
            end
            STATE.ownedAuras = owned
        end

        -- A rebirth wipes level, damage, wins and weapons but keeps the cleared
        -- stage, so the ladder has to restart or it throws a 1-damage character
        -- at stage 20 forever. Two signals, because the counter alone missed
        -- rebirths that happened while the script was reloading.
        local levelCollapsed = STATE.lastLevel > 3 and STATE.level < STATE.lastLevel
        STATE.lastLevel = STATE.level

        if not STATE.primed then
            STATE.primed = true
        elseif STATE.rebirth > previousRebirth or levelCollapsed then
            resetProgression()
        end

        return snap
    end

    -- Spending ----------------------------------------------------------------
    --
    -- The weapon in hand is held by the balance, so its price is never spent.
    -- Anything else waits until the balance is at least twice that reserve.

    local function currentPower()
        local equipped = WEAPON_BY_ID[STATE.weapon]
        return equipped and equipped.power or 0
    end

    local function weaponReserve()
        local equipped = WEAPON_BY_ID[STATE.weapon]
        return equipped and equipped.price or 0
    end

    local function canSpend(cost)
        local reserve = weaponReserve()
        if reserve > 0 and STATE.wins < reserve * 2 then return false end
        return cost <= STATE.wins - reserve
    end

    -- Pads are mapped by the weapon model sitting inside them; there are 27
    -- weapons and only 20 pads, so HallWeapon<n> stops lining up with Weapon<n>.
    local padCache = nil
    local function weaponPads()
        if padCache then return padCache end
        padCache = {}
        if not weaponArea then return padCache end
        for _, pad in ipairs(weaponArea:GetChildren()) do
            local touchPart = pad:FindFirstChild("TouchPart", true)
            if touchPart then
                for _, child in ipairs(pad:GetChildren()) do
                    if WEAPON_BY_ID[child.Name] then
                        padCache[child.Name] = touchPart
                        break
                    end
                end
            end
        end
        return padCache
    end

    local function bestWeapon()
        local pads = weaponPads()
        local best
        for _, weapon in ipairs(WEAPONS) do
            if pads[weapon.id] and weapon.price <= STATE.wins then
                if not best or weapon.power > best.power then best = weapon end
            end
        end
        return best
    end

    local function upgradeWeapon()
        snapshot()   -- wins move fast; a stale balance sends it to a tier it cannot pay for
        local best = bestWeapon()
        if not best or best.id == STATE.weapon or best.power <= currentPower() then return end

        local pad = weaponPads()[best.id]
        if not pad then return end

        -- No teleport: the TouchInterest fires from any distance. Walking onto
        -- the pad slid the character across its neighbours and equipped whatever
        -- it brushed on the way.
        touch(pad)
        task.wait(1)
        snapshot()
    end

    -- Skills ------------------------------------------------------------------

    local function skillState()
        local remote = Remotes:FindFirstChild("GetSkillState")
        if not remote then return nil end
        local ok, state = pcall(function() return remote:InvokeServer() end)
        return ok and type(state) == "table" and state or nil
    end

    local function buySkills()
        local main = plr.PlayerGui:FindFirstChild("Main")
        local panel = main and main:FindFirstChild("Skill")
        local state = skillState()
        if not panel or not state then return end

        local helperOk, helper = pcall(require, ReplicatedStorage.Config.SkillHelper)
        if not helperOk then return end

        local wanted = {}
        for _, entry in pairs(state) do
            if type(entry) == "table" and entry.ID and not entry.Unlocked then
                local priceOk, price = pcall(helper.GetWins, entry.ID)
                price = priceOk and tonumber(price) or nil
                if price and price > 0 and canSpend(price) then
                    table.insert(wanted, { id = entry.ID, price = price })
                end
            end
        end
        if #wanted == 0 then return end
        table.sort(wanted, function(a, b) return a.price < b.price end)

        -- The HUD skill button ignores synthetic clicks, but the buy handler
        -- only needs the frame rendered, so it is shown and restored again.
        local wasVisible = panel.Visible
        panel.Visible = true
        task.wait(0.6)

        local list = panel:FindFirstChild("LeftFrame")
        list = list and list:FindFirstChild("Trails")
        list = list and list:FindFirstChild("LeftScro")
        local right = panel:FindFirstChild("RightFrame")

        if list and right then
            for _, skill in ipairs(wanted) do
                local row = list:FindFirstChild("Skill_" .. skill.id)
                if row and getconnections then
                    for _, c in pairs(getconnections(row.Activated)) do pcall(function() c:Fire() end) end
                    task.wait(0.8)
                    -- The purchase button is named "Rebirth" and its title shows
                    -- the wins price.
                    local buy = right:FindFirstChild("Rebirth")
                    if buy then
                        for _, c in pairs(getconnections(buy.Activated)) do pcall(function() c:Fire() end) end
                    end
                    task.wait(1.5)
                    local equip = right:FindFirstChild("Equip")
                    if equip and equip.Visible then
                        for _, c in pairs(getconnections(equip.Activated)) do pcall(function() c:Fire() end) end
                        task.wait(0.8)
                    end
                    snapshot()
                end
            end
        end

        panel.Visible = wasVisible
    end

    local function aliveMobs()
        local ctrl = stageCtrl()
        local stage = ctrl and ctrl.activeLocalStage
        if not stage or type(stage.Mobs) ~= "table" then return 0 end
        local n = 0
        for _, mob in pairs(stage.Mobs) do
            if type(mob) == "table" and not mob.Dead then n = n + 1 end
        end
        return n
    end

    -- Slot 1 is Sprint, a forward dash: fired outside a fight it drags the
    -- character across the hall, and mid fight it yanks it past the mob.
    local function castSkills()
        if aliveMobs() < 1 then return end
        local hud = plr.PlayerGui:FindFirstChild("HUD")
        local down = hud and hud:FindFirstChild("Down")
        if not down or not getconnections then return end

        for slot = (CONFIG.skipDash and 2 or 1), 3 do
            local holder = down:FindFirstChild("Skill" .. slot)
            local button = holder and holder:FindFirstChild("Button")
            if button and button.Visible then
                for _, c in pairs(getconnections(button.Activated)) do pcall(function() c:Fire() end) end
            end
        end
    end

    -- Shop --------------------------------------------------------------------

    local function equipBest()
        pcall(function() backpackRemote:FireServer("EquipBest", { Kind = "Equip" }) end)
        pcall(function() backpackRemote:FireServer("EquipBest", { Kind = "Gem" }) end)
    end

    local function equipBestPet()
        local main = plr.PlayerGui:FindFirstChild("Main")
        local pet = main and main:FindFirstChild("Pet")
        local button = pet and pet:FindFirstChild("EquipBest")
        if not button or not getconnections then return end
        for _, c in pairs(getconnections(button.Activated)) do pcall(function() c:Fire() end) end
    end

    local function ownedPetCount(petName)
        local main = plr.PlayerGui:FindFirstChild("Main")
        local pet = main and main:FindFirstChild("Pet")
        local list = pet and pet:FindFirstChild("ScrollingFrameB")
        if not list or not petName then return 0 end
        local count = 0
        for _, row in ipairs(list:GetChildren()) do
            if row:IsA("GuiButton") then
                local label = row:FindFirstChild("Name", true)
                if label and label.Text == petName then count = count + 1 end
            end
        end
        return count
    end

    local function bestOwnedAddition()
        local main = plr.PlayerGui:FindFirstChild("Main")
        local pet = main and main:FindFirstChild("Pet")
        local list = pet and pet:FindFirstChild("ScrollingFrameB")
        if not list then return 0 end
        local best = 0
        for _, row in ipairs(list:GetChildren()) do
            if row:IsA("GuiButton") then
                local label = row:FindFirstChild("Name", true)
                if label then
                    local ok, info = pcall(eggHelper.GetPetInfo, label.Text)
                    if ok and type(info) == "table" and (info.Addition or 0) > best then best = info.Addition end
                end
            end
        end
        return best
    end

    -- An egg is done once enough copies of its top pet are held, or once that
    -- top pet is no better than something already owned.
    local function eggIsFinished(eggId)
        local best = EGG_BEST[eggId]
        if not best then return false end
        if ownedPetCount(best.name) >= CONFIG.petCopies then return true end
        return best.addition <= bestOwnedAddition()
    end

    local function buyBestEgg()
        local pick
        for _, egg in ipairs(EGGS) do
            if canSpend(egg.price) and not eggIsFinished(egg.id) then
                if not pick or egg.price > pick.price then pick = egg end
            end
        end
        if not pick then return end

        -- BuyEggEvent needs the id and a count; the argument-less form charges
        -- wins and hatches nothing.
        for _ = 1, 5 do
            if not canSpend(pick.price) or eggIsFinished(pick.id) then break end
            pcall(function() buyEggRemote:FireServer(pick.id, 1) end)
            task.wait(0.6)
            snapshot()
        end
        equipBestPet()
    end

    local function buyBestAura()
        local rows = plr.PlayerGui:FindFirstChild("Main")
        rows = rows and rows:FindFirstChild("Aura")
        rows = rows and rows:FindFirstChild("ScrollingFrame")
        if not rows or not getconnections then return end

        local pick
        for _, aura in ipairs(AURAS) do
            if not STATE.ownedAuras[aura.id] and canSpend(aura.price) then
                if not pick or aura.price > pick.price then pick = aura end
            end
        end
        if not pick then return end

        local row = rows:FindFirstChild("Stage" .. pick.index)
        -- Buy is the wins price; RBuy is Robux and is never touched.
        local buy = row and row:FindFirstChild("Buy")
        if not buy then return end

        for _, c in pairs(getconnections(buy.Activated)) do pcall(function() c:Fire() end) end
        task.wait(1)
        snapshot()
        if STATE.ownedAuras[pick.id] then
            local equip = row:FindFirstChild("Equip")
            if equip then
                for _, c in pairs(getconnections(equip.Activated)) do pcall(function() c:Fire() end) end
            end
        end
    end

    -- Rebirth is refused inside a stage and accepted from the hall.
    local lastRebirth = 0
    local function tryRebirth()
        if STATE.needLevel <= 0 or STATE.level < STATE.needLevel then return end
        if os.clock() - lastRebirth < 15 then return end
        lastRebirth = os.clock()

        local hrp = rootPart()
        if hrp then hrp.CFrame = CFrame.new(HALL_POSITION) end
        task.wait(2)
        pcall(function() rebirthRemote:FireServer() end)
        task.wait(2.5)
        snapshot()
    end

    -- Stages ------------------------------------------------------------------

    local function entryPointFor(stage)
        local folder = stageRoot:FindFirstChild("Stage" .. stage)
        if not folder then return nil end
        local spawn = folder:FindFirstChild("SpawnPoint")
        if spawn then
            local part = spawn:IsA("BasePart") and spawn
                or spawn.PrimaryPart or spawn:FindFirstChildWhichIsA("BasePart")
            if part then return part.Position + Vector3.new(0, 4, 0) end
        end
        local pad = folder:FindFirstChild("StageStartPart", true)
        if pad then return pad.Position + Vector3.new(0, pad.Size.Y / 2 + 4, 0) end
        return nil
    end

    local function enterStage(stage)
        local folder = stageRoot:FindFirstChild("Stage" .. stage)
        local pad = folder and folder:FindFirstChild("StageStartPart", true)
        local hrp = rootPart()
        if not pad or not hrp then return false end

        hrp.CFrame = CFrame.new(entryPointFor(stage) or pad.Position)
        task.wait(0.4)
        touch(pad)   -- a CFrame write alone leaves the stage asleep
        return true
    end

    local function activeStageNumber()
        local ctrl = stageCtrl()
        local id = ctrl and ctrl.activeLocalStage and ctrl.activeLocalStage.Id
        return type(id) == "string" and tonumber(id:match("Stage(%d+)")) or nil
    end

    -- Only the plain WinBut; 2xWinBut is the paid pad. After a long fight the
    -- pad is not ready the instant the last mob dies, so the claim is retried
    -- until the balance actually moves.
    local function claimWin(stage)
        local folder = stageRoot:FindFirstChild("Stage" .. stage)
        local model = folder and folder:FindFirstChild("WinBut")
        local part = model and model:FindFirstChild("TouchPart")
        if not part then return false end

        local before = STATE.wins
        for _ = 1, 6 do
            touch(part)
            task.wait(0.7)
            snapshot()
            if STATE.wins > before then return true end
        end
        return false
    end

    local function goHall()
        local hrp = rootPart()
        if hrp then hrp.CFrame = CFrame.new(HALL_POSITION) end
    end

    -- A clear is a clear: boss stages legitimately take longer than the fast
    -- window, and gating advancement on a fast clear pinned the cursor to one
    -- stage forever. Duration only decides how far to move.
    local function updateLadder(stage, seconds)
        if not seconds then
            STATE.blockedAt = stage
            STATE.bankRuns = 0
            STATE.ladder = math.max(1, stage - 1)
            return
        end

        if STATE.blockedAt > 0 and stage < STATE.blockedAt then
            STATE.bankRuns = STATE.bankRuns + 1
            if seconds <= CONFIG.fastSeconds or STATE.bankRuns >= CONFIG.farmRuns then
                STATE.bankRuns = 0
                STATE.ladder = STATE.blockedAt
            end
            return
        end

        STATE.blockedAt = 0
        local step = 1
        if stage < STATE.cleared and seconds <= CONFIG.fastSeconds / 2 then
            step = math.max(1, math.floor((STATE.cleared - stage) / 2))
        end
        STATE.ladder = math.min(stage + step, MAX_STAGE)
    end

    local function farmCycle()
        local want = math.clamp(STATE.ladder, 1, MAX_STAGE)
        local rebirthAtStart = STATE.rebirth

        goHall()
        task.wait(1)
        if not enterStage(want) then task.wait(1) return end

        local started = os.clock()
        local deadline = started + CONFIG.stageTimeout
        local spawnDeadline = started + CONFIG.spawnTimeout
        local sawMobs = false

        while os.clock() < deadline and CONFIG.autoFarm do
            local alive = aliveMobs()
            if alive > 0 then
                sawMobs = true
                if CONFIG.castSkills then castSkills() end
            elseif sawMobs then
                break
            elseif os.clock() > spawnDeadline then
                break   -- stages above the unlocked one never spawn anything
            end
            task.wait(0.3)
        end

        local elapsed = os.clock() - started

        if not sawMobs then
            STATE.noSpawn[want] = (STATE.noSpawn[want] or 0) + 1
            if want <= STATE.cleared and STATE.noSpawn[want] < 2 then goHall() return end
            STATE.noSpawn[want] = 0
            updateLadder(want, nil)
            goHall()
            return
        end

        if aliveMobs() > 0 then
            updateLadder(want, nil)
            goHall()
            return
        end

        task.wait(0.6)
        claimWin(want)
        STATE.runs = STATE.runs + 1
        STATE.noSpawn[want] = 0

        -- A rebirth during this run already reset the ladder; writing this
        -- stage's outcome now would undo it.
        if STATE.rebirth ~= rebirthAtStart then return end
        updateLadder(want, elapsed)

        if CONFIG.autoWeapon then upgradeWeapon() end
        if CONFIG.autoSkill then buySkills() end
        if CONFIG.autoEquip then equipBest() end
        if CONFIG.autoEgg then buyBestEgg() end
    end

    -- Loops -------------------------------------------------------------------

    local function loop(interval, key, fn)
        task.spawn(function()
            while env.LootEvoRun == generation do
                if CONFIG[key] then pcall(fn) end
                task.wait(interval)
            end
        end)
    end

    -- Auto click is driven off Heartbeat so the rate holds no matter what else
    -- is running. Measured ~200 damage per click at 25/s.
    do
        local budget, last = 0, os.clock()
        RunService.Heartbeat:Connect(function()
            if env.LootEvoRun ~= generation then return end
            local now = os.clock()
            local delta = math.min(now - last, 0.25)
            last = now
            if not CONFIG.autoClick then return end

            budget = budget + delta * CONFIG.clickRate
            local sendable = math.floor(budget)
            if sendable < 1 then return end
            budget = budget - sendable
            for _ = 1, math.min(sendable, 6) do
                pcall(function() clickRemote:FireServer() end)
                STATE.clicks = STATE.clicks + 1
            end
        end)
    end

    loop(1.2, "castSkills", castSkills)
    loop(8, "autoSkill", buySkills)
    loop(12, "autoAura", buyBestAura)
    loop(15, "autoEgg", buyBestEgg)
    loop(20, "autoWeapon", upgradeWeapon)
    loop(8, "autoEquip", equipBest)
    loop(6, "autoRebirth", tryRebirth)

    task.spawn(function()
        while env.LootEvoRun == generation do
            if CONFIG.autoFarm then pcall(farmCycle) else task.wait(0.5) end
            task.wait(0.2)
        end
    end)

    task.spawn(function()
        while env.LootEvoRun == generation do
            pcall(snapshot)
            task.wait(4)
        end
    end)

    scanControllers()
    snapshot()
    STATE.ladder = math.max(1, math.min(STATE.ladder, STATE.cleared + 1))

    -- Interface ---------------------------------------------------------------

    local function remember(key)
        return function(value)
            CONFIG[key] = value
            env.setconfig(key, value)
        end
    end

    elements:Label("Farms stages, claims wins and buys upgrades.", section)

    elements:Toggle("Auto Click (damage)", section, CONFIG.autoClick, remember("autoClick"))
    elements:Toggle("Auto Farm stages", section, CONFIG.autoFarm, remember("autoFarm"))
    elements:Toggle("Cast Skills (E/R)", section, CONFIG.castSkills, remember("castSkills"))
    elements:Toggle("Buy Weapons", section, CONFIG.autoWeapon, remember("autoWeapon"))
    elements:Toggle("Buy Skills", section, CONFIG.autoSkill, remember("autoSkill"))
    elements:Toggle("Buy Auras", section, CONFIG.autoAura, remember("autoAura"))
    elements:Toggle("Buy Eggs + equip pet", section, CONFIG.autoEgg, remember("autoEgg"))
    elements:Toggle("Equip best gear + gems", section, CONFIG.autoEquip, remember("autoEquip"))
    elements:Toggle("Auto Rebirth (resets stats)", section, CONFIG.autoRebirth, remember("autoRebirth"))

    elements:Button("Go to next stage", section, function()
        task.spawn(function()
            snapshot()
            enterStage(math.clamp(STATE.cleared + 1, 1, MAX_STAGE))
        end)
    end)

    -- Calling RequestManualSwing outside a live stage leaves stageSwingBusy set
    -- and the movement lock never releases: the client keeps rendering while
    -- input is dead. This clears that state.
    elements:Button("Unstuck (movement + camera)", section, function()
        local ctrl = stageCtrl()
        if ctrl then
            ctrl.stageSwingBusy = false
            ctrl.bufferedStageSwing = false
        end
        pcall(function() require(plr.PlayerScripts.PlayerModule):GetControls():Enable() end)

        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
            if hum.WalkSpeed < 1 then hum.WalkSpeed = 20 end
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)

            local cam = workspace.CurrentCamera
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = hum
            plr.CameraMinZoomDistance = 0.5
            plr.CameraMaxZoomDistance = 400
        end
        local hrp = rootPart()
        if hrp then hrp.Anchored = false end
    end)

    -- Codes live in the config with an Enabled flag and grant double damage and
    -- double wins potions, so they are redeemed once on load.
    task.spawn(function()
        if env.LootEvoCodes then return end
        env.LootEvoCodes = true

        local ok, helper = pcall(require, ReplicatedStorage.Config.CodeHelper)
        if not ok or not helper.GetAll then return end
        local list = select(2, pcall(helper.GetAll))
        local remote = Remotes:FindFirstChild("RedeemCodeFunction")
        if type(list) ~= "table" or not remote then return end

        for _, entry in pairs(list) do
            if type(entry) == "table" and entry.Enabled and entry.Code then
                pcall(function() remote:InvokeServer(entry.Code) end)
                task.wait(1)
            end
        end
    end)
end

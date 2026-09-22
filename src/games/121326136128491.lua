--[[
Math for Brainrots! autocollect
https://www.roblox.com/games/121326136128491/Math-for-Brainrots
This game sucks so much
Made by Cosmella
]]
return function(section, data)
	local elements = loadstring(game:HttpGet(getgitpath("src").."elements.lua"))()
	local Players = game:GetService("Players")
	local plr = Players.LocalPlayer
	local setdata = data[tostring(game.PlaceId)] or {}

	local function load(name, value) -- whatever is this mannnnnn 
		setdata[name] = setdata[name] or value
		getgenv()[name] = setdata[name]
	end
	local function update(name, value)
		getgenv().setconfig(name, value)
		getgenv()[name] = value
	end
	load("Farming")
	load("Zone")
	data[tostring(game.PlaceId)] = setdata
	writefile("BrainrotPolice/Config.json", game:GetService("HttpService"):JSONEncode(data))
	
	local Teleports = {
		Plots = Vector3.new(555.260, 40.225, -527.632),
		PlayerPlot = Vector3.new(555.260, 40.225, -527.632)
	}

	local function TP(pos, safe)
		Players.LocalPlayer.Character:MoveTo(pos)
		if safe then
			task.wait(0.3)
		end
	end
	local function findPlot()
		local plots = workspace.Plots
		for i,v in pairs(plots:getChildren()) do
			local playerPlot = v:FindFirstChild("PlayerPlot")
			local gui = playerPlot:FindFirstChildWhichIsA("BillboardGui", true)
			local img = gui:FindFirstChildWhichIsA("ImageLabel")
			if tonumber(img.Image:match("id=(%d+)")) == plr.UserId then
				Teleports.PlayerPlot = playerPlot:GetPivot().p + Vector3.new(10,0,10)
				--print("found plot?")
				return
			end
		end
		-- not found
		--print("cannot find player plot")
		Teleports.PlayerPlot = Teleports.Plots
		task.delay(1.5,findPlot) -- keep repeating this untill it does 
	end
	--print("started")
	TP(Teleports.Plots, true)
	--print("finished")
	findPlot()

	local function parseMoney(text)
		if not text then
			return 0
		end

		local num, suffix = text:match("%$?([%d%.]+)%s*([KMBkmb]?)")

		num = tonumber(num) or 0
		suffix = (suffix or ""):upper()

		if suffix == "K" then
			num *= 1e3
		elseif suffix == "M" then
			num *= 1e6
		elseif suffix == "B" then
			num *= 1e9
		end

		return num
	end

	local function grabem(model, prompt)
		if not prompt then
			return
		end
		local char = plr.Character
		TP(model:GetPivot().p)
		local timeout = 0
		repeat fireproximityprompt(prompt or model:FindFirstChildWhichIsA("ProximityPrompt",true))
			timeout += task.wait()
		until plr.CarryingObject.Value == model or timeout > 1
		TP(Teleports.PlayerPlot)
		repeat
			task.wait()
		until plr.CarryingObject.Value == nil
	end

	local function sortedBrainrots(conbtable, zname) -- this gets them sorted
		local Brainrots = conbtable or {}
		for i,v in pairs(workspace:getChildren()) do
			if v:IsA("Model") then
				local bil = v:FindFirstChild("BrainrotBillboard")
				if bil then
					local prompt = v:FindFirstChildWhichIsA("ProximityPrompt",true)
					if (prompt) then
						table.insert(Brainrots,{
							["Position"] = v:GetPivot(),
							["bill"] = bil,
							["zname"] = string.sub(zname or "Stage-1",#"Stage"+1),
							["MoneyPerSec"] = bil.MoneyPerSec.Text,
							prompt = prompt,
							model = v
						})
						break
					end
				end
			end
		end

		table.sort(Brainrots, function(a, b)
			if not a then return false end
			if not b then return true end

			local aBill = a.MoneyPerSec
			local bBill = b.MoneyPerSec

			if not aBill then return false end
			if not bBill then return true end

			local aValue = parseMoney(aBill)
			local bValue = parseMoney(bBill)

			return aValue > bValue 
		end)
		return Brainrots
	end
	local function sellAll() -- i made them all function because i made the ui after lol
		local plrgui = plr.PlayerGui
		local Main = plrgui:FindFirstChild("Main")
		if Main then
			local sell = Main:FindFirstChild("Sell")
			if sell then
				local sellallgui = sell:FindFirstChild("Content")

				if not sellallgui then
					sellallgui = sell:FindFirstChild("SellAll",true)
				else
					sellallgui = sellallgui:FindFirstChild("SellAll")
				end

				if sellallgui then
					firesignal(sellallgui.MouseButton1Click)
				end
			end
		end
	end

	local function zone()
		local char = plr.Character
		local maps = workspace.MainMapFolder.Stages
		local zone = maps:FindFirstChild("Stage"..tostring(getgenv().Zone) or "")
		if zone then
			TP(zone:GetPivot().p)
			return sortedBrainrots()[1]
		end
		-- assume user put all or a invalid zone so go through all of them
		local br = {}
		for i,v in pairs(maps:GetChildren()) do
			TP(v:GetPivot().p, true)
			sortedBrainrots(br, v.Name)
		end
		--print(br[1].Position)
		return br[1]
	end
	local function grabrot(rot)
		if typeof(rot.Position) == "Vector3" then
			TP(rot.Position)
		else
			TP(rot.Position.p)
		end
		grabem(rot.model, rot.prompt)
	end
	
	--==-- Ui elements --==-- fancy lads
	
	elements:Toggle("Farming", section, setdata.Farming, function(v)
		update("Farming", v)
		while getgenv().Farming do
			local b = zone()
			if not b  then
				task.wait()
				--print("none found")
				continue
			end

			grabrot(b)

			if not getgenv().Farming then
				break
			end
		end
	end)
	
	local tb = elements:Textbox("Farm Zone (1-10)", section, setdata.Zone, function(v)
		update("Zone", v)
	end)
	
	elements:Button("Sell all", section, function()
		sellAll()
	end)
	
	elements:Button("Find best zone", section, function()
		local k2 = getgenv().Zone
		getgenv().Zone = nil
		local k = zone()
		getgenv().Zone = k2
		if k["zname"] then
			update("Zone", k["zname"])
			tb.tbbg.Inp.Text = k["zname"]
		end
	end)
	
end

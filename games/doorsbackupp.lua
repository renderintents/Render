--[[

  $$$$$$$\                            $$\                           $$\    $$\                              
  $$  __$$\                           $$ |                          $$ |   $$ |                             
  $$ |  $$ | $$$$$$\  $$$$$$$\   $$$$$$$ | $$$$$$\   $$$$$$\        $$ |   $$ |$$$$$$\   $$$$$$\   $$$$$$\  
  $$$$$$$  |$$  __$$\ $$  __$$\ $$  __$$ |$$  __$$\ $$  __$$\       \$$\  $$  |\____$$\ $$  __$$\ $$  __$$\ 
  $$  __$$< $$$$$$$$ |$$ |  $$ |$$ /  $$ |$$$$$$$$ |$$ |  \__|       \$$\$$  / $$$$$$$ |$$ /  $$ |$$$$$$$$ |
  $$ |  $$ |$$   ____|$$ |  $$ |$$ |  $$ |$$   ____|$$ |              \$$$  / $$  __$$ |$$ |  $$ |$$   ____|
  $$ |  $$ |\$$$$$$$\ $$ |  $$ |\$$$$$$$ |\$$$$$$$\ $$ |               \$  /  \$$$$$$$ |$$$$$$$  |\$$$$$$$\ 
  \__|  \__| \_______|\__|  \__| \_______| \_______|\__|                \_/    \_______|$$  ____/  \_______|
                                                                                      $$ |                
                                                                                      $$ |                
                                                                                      \__|   
   A very sexy and overpowered vape mod created at Render Intents  
   CustomModules/6839171747.lua (Doors), Created By MaxlaserTech
   Contributors: Retro & selunariorium		  
   https://renderintents.lol
   
   Version: 3.0
]]

local vape = shared.rendervape
local players = getservice('Players')
local lplr = players.LocalPlayer
local textservice = getservice('TextService')
local inputservice = getservice('UserInputService')
local runservice = getservice('RunService')
local teleport = getservice('TeleportService')
local tween = getservice('TweenService')
local promptservice = getservice('ProximityPromptService')
local collection = getservice('CollectionService')
local httpservice = getservice('HttpService')
local replicatedstorage = getservice('ReplicatedStorage')
local camera = workspace.Camera or Instance.new('Camera', workspace)
local entityLibrary = shared.vapeentity

local selfdestructed = false

local mainui = lplr.PlayerGui:WaitForChild('MainUI')
local maingame = mainui.Initiator.Main_Game

local require = cheatenginetrash and function() end or require -- solara :sob:
local requiredgame = require(maingame)

local api = {
	combat = vape.ObjectsThatCanBeSaved.CombatWindow.Api,
	blatant = vape.ObjectsThatCanBeSaved.BlatantWindow.Api,
	render = vape.ObjectsThatCanBeSaved.RenderWindow.Api,
	exploit = vape.ObjectsThatCanBeSaved.ExploitWindow.Api,
	utility = vape.ObjectsThatCanBeSaved.UtilityWindow.Api,
	world = vape.ObjectsThatCanBeSaved.WorldWindow.Api
}

local storage = {
	drawers = Performance.new(),
	esps = Performance.new(),
	gameprompts = Performance.new(),
	lockers = Performance.new(),
	connections = {},
	files = {
		gamedata = replicatedstorage.GameData,
		roomdata = replicatedstorage.GameData.LatestRoom,
		stage = replicatedstorage.GameData.Floor.Value,
		remotelistener = maingame.RemoteListener
	}
}

if cheatenginetrash then
	warningNotification('Render', `Some of the features may not be supported for {identifyexecutor() or 'cheat engine'}`, 7)
end

local espcolor = newcolor()
local esptextsize = {}
local espuistroke = {}
local createesp = function(parent)
	local highlight = Instance.new('Highlight', parent)
	highlight.FillColor = Color3.fromHSV(espcolor.Hue, espcolor.Sat, espcolor.Value)
	highlight.FillTransparency = 0.7
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	table.insert(storage.esps, highlight)
end

local createtag = function(tag, parent)
	local gui = Instance.new('BillboardGui', parent)
	gui.AlwaysOnTop = true
	gui.ClipsDescendants = false
	gui.Size = UDim2.new(0, 1, 0, 1)
	gui.StudsOffset = Vector3.new(0, 1, 0)

	local label = Instance.new('TextLabel', gui)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Arial
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Text = tag
	label.TextColor3 = Color3.fromHSV(espcolor.Hue, espcolor.Sat, espcolor.Value)
	label.TextSize = (isEnabled('FOVChanger') and esptextsize.Value * 2 or esptextsize.Value)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)

	if espuistroke.Enabled then 
		Instance.new('UIStroke', label).Thickness = 1 
	end
	table.insert(storage.esps, gui)
end

local getpumps = function()
	local pumps = {}
	local handler = workspace.CurrentRooms[storage.files.roomdata.Value]:FindFirstChild("_DamHandler")
	if handler then
		for i,v in {1, 2, 3} do
			if handler:FindFirstChild(`PlayerBarriers{i}`) then
				for i,v in handler[`Flood{i}`].Pumps:GetChildren() do
					table.insert(pumps, {wheel = pump.Wheel, prompt = pump.Wheel.ValvePrompt})
				end
			end
		end
	end
	return pumps
end

local getpadlockcode = function(tool)
	if tool and tool:FindFirstChild('UI') then
		local code = {}
		for i,v in tool.UI:GetChildren() do
			if v.ClassName == 'ImageLabel' and tonumber(v.Name) then
				code[v.ImageRectOffset.X .. v.ImageRectOffset.Y] = {tonumber(v.Name), '_'}
			end
		end
		for i, image in lplr.PlayerGui.PermUI.Hints:GetChildren() do
			if image.Name == 'Icon' then
				if code[image.ImageRectOffset.X .. image.ImageRectOffset.Y] then
					code[image.ImageRectOffset.X .. image.ImageRectOffset.Y][2] = image.TextLabel.Text
				end
			end
		end
		local actualcode = {}
		for i,v in code do
			actualcode[v[1]] = v[2]
		end
		--for i,v in actualcode do
		--	print(i,v)
		--end
		return actualcode
	end
	return {}
end

local getdropitems = function(name)
	for i,v in workspace.Drops:GetDescendants() do
		if v.ClassName == 'ProximityPrompt' and v.ObjectText:lower() == name:lower() then
			return v
		end
	end
	return nil
end

task.spawn(function()
	repeat 
		camera = workspace.Camera or Instance.new('Camera')
		task.wait()
	until selfdestructed
end)

vape.SelfDestructEvent.Event:Once(function()
	selfdestructed = true	
	for i,v in storage.connections do
		pcall(function() v:Disconnect() end)
		pcall(function() v.Disconnect() end)
	end
end)

local getItemNear = function(name)
	for i,v in lplr.Backpack:GetChildren() do
		if v.Name:lower() == name:lower() or v.Name:lower():find(name:lower()) then
			return v
		end
	end
	for i,v in lplr.Character:GetChildren() do
		if (v.Name:lower() == name:lower() or v.Name:lower():find(name:lower())) and v.ClassName == 'Tool' then
			return v
		end
	end
	return nil
end

local getWardrobe = function(distance, amount)
	local wardrobe = {}
	for _, funcs in storage.lockers do
		if #wardrobe == 1 and amount == 1 then break end
		for i,v in funcs do
			local mag = (lplr.Character.PrimaryPart.Position - v.main:FindFirstChildWhichIsA('Part').Position).magnitude
			if mag < (distance or 15) then
				table.insert(wardrobe, v.prompt)
			end
		end
	end
	return amount == 1 and wardrobe[1] or wardrobe
end

local currRoom = 69420
local currtick = tick() - 1
local ongoing = false
task.spawn(function()
	repeat
		task.wait(0.5)
		if ongoing then
			repeat task.wait() until not ongoing
		end
		if currRoom ~= storage.files.roomdata.Value then
			ongoing = true
			if RenderDebug then
				InfoNotification('Render', `Updated store in {math.floor(tick() - currtick)} seconds`, 6)
			end
			currtick = tick() - 1
			currRoom = storage.files.roomdata.Value
			for i,v in workspace.CurrentRooms[storage.files.roomdata.Value]:GetDescendants() do
				if v.ClassName == 'ProximityPrompt' and v.Name ~= 'HidePrompt' then
					table.insert(storage.gameprompts, v)
				end
				if v.Name == 'HidePrompt' then
					table.insert(storage.lockers, {main = v.Parent, prompt = v})
				end
				if table.find({'DrawerContainer', 'Locker_Small', 'RolltopContainer', 'ChestBox', 'Toolbox'}, v.Name)then
					local magpart = nil
					for i2,v2 in v:GetDescendants() do
						if v2.ClassName == 'Part' then
							magpart = v2
							break
						end
					end
					table.insert(storage.drawers, {
						drawer = v,
						type = 'in',
						part = magpart,
						getinstance = function(name, instancetype)
							for i2,v2 in v:GetDescendants() do
								if (type(name) == 'string' and v2.Name == name) and (type(instancetype) == 'string' and v2.ClassName == instancetype) then
									if RenderDebug then
										--print(`Found {v2.Name} for {v.Name}, Instance type: {v2.ClassName}`)
									end
									return v2
								end
							end
						end,
						getdrops = function()
							for i2,v2 in v:GetDescendants() do
								if v2.ClassName == 'ProximityPrompt' and v2.Name ~= 'ActivateEventPrompt' then
									if RenderDebug then
										--print(`Found {v2.Name} for {v.Name}, Instance type: {v2.ClassName}`)
									end
									return v2
								end
							end
						end
					})
				elseif table.find({'ModulePrompt', 'LootPrompt'}, v.Name) then
					for i2,v2 in v.Parent:GetDescendants() do
						if v2.ClassName == 'Part' then
							magpart = v2
							break
						end
					end
					table.insert(storage.drawers, {
						type = 'out',
						drawer = nil,
						part = magpart,
						interacted = false,
						getinstance = function(name, instancetype)
							return nil
						end,
						getdrops = function()
							return v
						end
					})
				end
			end
		end
		ongoing = false
	until selfdestructed
end)

vape.RemoveObject('SilentAimOptionsButton')
vape.RemoveObject('ReachOptionsButton')
vape.RemoveObject('MouseTPOptionsButton')
vape.RemoveObject('AutoClickerOptionsButton')
vape.RemoveObject('SpiderOptionsButton')
vape.RemoveObject('PhaseOptionsButton')
vape.RemoveObject('LongJumpOptionsButton')
vape.RemoveObject('HitBoxesOptionsButton')
vape.RemoveObject('InstantInteractOptionsButton')
vape.RemoveObject('FOVChangerOptionsButton')
vape.RemoveObject('KillauraOptionsButton')
vape.RemoveObject('ChamsOptionsButton')
vape.RemoveObject('TriggerBotOptionsButton')
vape.RemoveObject('AutoLeaveOptionsButton')
vape.RemoveObject('ClientKickDisablerOptionsButton')
vape.RemoveObject('NameTagsOptionsButton')
vape.RemoveObject('SafeWalkOptionsButton')
vape.RemoveObject('ESPOptionsButton')
vape.RemoveObject('FlyOptionsButton')
vape.RemoveObject('BlinkOptionsButton')
vape.RemoveObject('AntiVoidOptionsButton')
vape.RemoveObject('SongBeatsOptionsButton')
vape.RemoveObject('TargetStrafeOptionsButton')

-- blatant tab --

local speedflag = false
local speedvalue = {}
run(function()
	local speed = {}
	local speedmethod = {}
	speed = api.blatant.CreateOptionsButton({
		Name = 'Speed',
		Function = function(call)
			if call then
				repeat
					if speedflag then
						lplr.Character.Humanoid.WalkSpeed = 16
					else
						if speedmethod.Value == 'WalkSpeed' then
							lplr.Character.Humanoid.WalkSpeed = speedvalue.Value
							lplr.Character.Humanoid:SetAttribute("SpeedBoostBehind", 0)
						else
							lplr.Character.Humanoid.WalkSpeed = 16 * speedvalue.Value
							lplr.Character.Humanoid:SetAttribute("SpeedBoostBehind", speedvalue.Value)
						end
					end
					task.wait()
				until (not speed.Enabled)
			else
				lplr.Character.Humanoid.WalkSpeed = 16
				lplr.Character.Humanoid:SetAttribute("SpeedBoostBehind", 0)
			end
		end
	})
	speedmethod = speed.CreateDropdown({
		Name = 'Method',
		Function = void,
		List = {'WalkSpeed', 'Boost'}
	})
	speedvalue = speed.CreateSlider({
		Name = 'Value',
		Function = void,
		Min = 1,
		Max = 100,
		Default = 50
	})
end)


run(function()
	local phase = {}
	local phasetoggle = {}
	local isenabled = false
	local isenabledspeed = false
	local oldylevel
	phase = api.blatant.CreateOptionsButton({
		Name = 'Phase',
		Function = function(call)
			if call then
				task.spawn(function()
					if not phasetoggle.Enabled then
						if phase.Keybind == '' and render.platform == Enum.Platform.Windows then
							phase.ToggleButton()
							return errorNotification('Phase', 'Please set your keybind first.', 7)
						end
						repeat
							task.wait()
						until (not inputservice:IsKeyDown(Enum.KeyCode[phase.Keybind]))
						if phase.Enabled then
							phase.ToggleButton()
						end
					end
				end)
				task.spawn(function()
					if isEnabled('Speed') then
						isenabledspeed = true
						vape.ObjectsThatCanBeSaved.SpeedOptionsButton.Api.ToggleButton()
					end
					if isEnabled('AntiCheatBypass') then
						isenabled = true
						vape.ObjectsThatCanBeSaved.AntiCheatBypassOptionsButton.Api.ToggleButton()
					end
					task.wait(0.5)
				end)
				if collision then
                    collision.Weld.C0 = CFrame.new(-Flags["NoclipBypassOffset"].Value, 0, 0) * CFrame.Angles(0, 0, math.rad(90))
                    lplr.Character:TranslateBy(Vector3.new(0, Flags["NoclipBypassOffset"].Value, 0))
                end
			else
				if collision then
                    collision.Weld.C0 = CFrame.new() * CFrame.Angles(0, 0, math.rad(90))
                end
				if isenabled and not isEnabled('AntiCheatBypass') then
					vape.ObjectsThatCanBeSaved.AntiCheatBypassOptionsButton.Api.ToggleButton()
				end
				if isenabledspeed then
					vape.ObjectsThatCanBeSaved.SpeedOptionsButton.Api.ToggleButton()
				end
				isenabled = false
			end
		end
	})
	phasetoggle = phase.CreateToggle({
		Name = 'Toggle',
		Function = void
	})
end)


-- visual tab --

run(function()
	local fovchanger = {}
	local fovchangerzoom = {}
	local fovchangervalue = {}
	local fovchangernoshake = {}
	local oldfov
	fovchanger = api.render.CreateOptionsButton({
		Name = "FOVChanger",
		Function = function(callback)
			if callback then
				oldfov = camera.FieldOfView
				if fovchangerzoom.Enabled then
					if fovchanger.Keybind == '' and render.platform == Enum.Platform.Windows then
						fovchanger.ToggleButton()
						return errorNotification('FOVChanger', 'Please set your keybind first.', 7)
					end
					task.spawn(function()
						repeat
							task.wait()
						until (not inputservice:IsKeyDown(Enum.KeyCode[fovchanger.Keybind]))
						if fovchanger.Enabled then
							fovchanger.ToggleButton()
						end
					end)
				end
				table.insert(fovchanger.Connections, runservice.RenderStepped:Connect(function()
					if not cheatenginetrash and fovchangernoshake.Enabled then
						require(maingame).csgo = CFrame.new()
					end
				end))
				local tweenserv = tween:Create(camera, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {FieldOfView = fovchangervalue.Value})
				tweenserv:Play()
				local currvalue = fovchangervalue.Value
				tweenserv.Completed:Wait()	 
				table.insert(fovchanger.Connections, runservice.RenderStepped:Connect(function()
					if currvalue ~= fovchangervalue.Value then
						tween:Create(camera, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {FieldOfView = fovchangervalue.Value}):Play()
						currvalue = fovchangervalue.Value
					else
						camera.FieldOfView = fovchangervalue.Value
					end
				end))
			end
		end
	})
	fovchangervalue = fovchanger.CreateSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Function = void
	})
	fovchangerzoom = fovchanger.CreateToggle({
		Name = "Zoom",
		Function = void
	})
	fovchangernoshake = fovchangervalue.CreateToggle({
		Name = 'NoShake',
		Function = void
	})
end)

run(function()
	local esp = {}
	local esptag = {}
	local bettername = {
		KeyObtain = 'Key',
		LeverForGate = 'Lever',
		MinesGenerator = 'Generator',
		FuseModel = 'Fuse',
		GiggleCeiling = 'Giggle',
		LiveHintBook = 'Book',
		Wardrobe = 'Wardrobe',
		ImStuff = 'Breaker',
		Door = 'Door'
	}
	esp = api.render.CreateOptionsButton({
		Name = 'ESP',
		Function = function(call)
			if call then
				print(espcolor.Hue, espcolor.Sat, espcolor.Value)
				for i,v in workspace.CurrentRooms:GetDescendants() do
					if v.Name == 'Door' and v.Parent.Name == 'Door' or table.find({'KeyObtain', 'Wardrobe', 'LeverForGate', 'MinesGenerator', 'FuseModel', 'GiggleCeiling', 'LiveHintBook', 'ImStuff', 'FigureRig'}, v.Name)  then
						pcall(createesp, v)
						task.wait()
						if esptag.Enabled then
							pcall(createtag, `{bettername[v.Name]}{v.Name == 'Door' and ' '.. storage.files.roomdata.Value or ''}`, v)
						end
					end
				end
				table.insert(esp.Connections, workspace.CurrentRooms.DescendantAdded:Connect(function(v)
					if v.Name == 'Door' and v.Parent.Name == 'Door' or table.find({'KeyObtain', 'LeverForGate', 'MinesGenerator', 'FuseModel', 'GiggleCelling', 'LiveHintBook', 'ImStuff', 'FigureRig'}, v.Name) then
						pcall(createesp, v)
						task.wait()
						if esptag.Enabled then
							pcall(createtag, `{bettername[v.Name]}{v.Name == 'Door' and ' '.. storage.files.roomdata.Value or ''}`, v)
						end
					end
				end))
			else
				for i,v in storage.esps do
					pcall(function() v:Remove() end)
					pcall(function() table.remove(storage.esps, i) end)
				end
			end
		end
	})
	espcolor = esp.CreateColorSlider({
		Name = 'Color',
		Function = function(h, s, v)
			print(h, s, v)
			print(espcolor.Hue, espcolor.Sat, espcolor.Value)
		end
	})
	esptag = esp.CreateToggle({
		Name = 'NameTag',
		Function = function(call)
			espuistroke.Object.Visible = call
			esptextsize.Object.Visible = call
		end
	})
	esptextsize = esp.CreateSlider({
		Name = 'TextSize',
		Function = void,
		Min = 5,
		Max = 30,
		Default = 21
	})
	espuistroke = esp.CreateToggle({
		Name = 'UiStroke',
		Function = void
	})
	esptextsize.Object.Visible = false
	espuistroke.Object.Visible = false
end)

run(function()
	local noeffect = {}
	noeffect = api.render.CreateOptionsButton({
		Name = 'NoEffect',
		Function = function(call)

		end,
		HoverText = 'Remove effects to boost your game fps.'
	})
end)

run(function()
	local nojumpscare = {}
	nojumpscare = api.render.CreateOptionsButton({
		Name = 'NoJumpscare',
		Function = function(call)
			if call then

			end
		end
	})
end)

run(function()
	local cameraunlocker = {}
	cameraunlocker = api.render.CreateOptionsButton({
		Name = 'CameraUnlocker',
		Function = function(call)
			if call then
				table.insert(cameraunlocker.Connections, runservice.RenderStepped:Connect(function()
					camera.CFrame = (not cheatenginetrash and requiredgame.finalCamCFrame or camera.CFrame) * CFrame.new(1.5, -0.5, 6.5)
				end))
			end
		end
	})
end)

-- utility tab --

run(function()
	local instaprompt = {};
	instaprompt = api.utility.CreateOptionsButton({
		Name = 'InstantInteract',
		Function = function(call)
			if call then
				table.insert(instaprompt.Connections, getservice('ProximityPromptService').PromptButtonHoldBegan:Connect(function(v)
					local lockpick = getItemNear('lockpick')
					if lockpick then
						for i = 1, 20 do 
							task.spawn(fireproximityprompt, lockpick)
							replicatedstorage.RemotesFolder.DropItem:FireServer(lockpick)
						end
						task.wait(0.3)
						local drop = getdropitems('lockpick')
						if drop then
							fireproximityprompt(v)
						end
					end
				end))
			end;
		end
	})
end);

run(function()
	local autocollect = {}
	local autocollectrange = {}
	autocollect = api.utility.CreateOptionsButton({
		Name = 'AutoCollect',
		Function = function(call)
			if call then
				repeat
					for _, funcs in storage.drawers do
						local mag = (lplr.Character.PrimaryPart.Position - funcs.part.Position).magnitude
						if mag < autocollectrange.Value then
							local openprompt = funcs.getinstance('ActivateEventPrompt', 'ProximityPrompt')
							if openprompt and not openprompt:GetAttribute('Interactions') then
								fireproximityprompt(openprompt)
							end
							local loot = funcs.getdrops()
							if loot and not loot:GetAttribute(`Interactions{lplr.Name}`)then
								fireproximityprompt(loot)
							end
						end
					end
					task.wait()
				until (not autocollect.Enabled)			
			end
		end
	})
	autocollectrange = autocollect.CreateSlider({
		Name = 'Range',
		Function = void,
		Min = 1,
		Max = 17,
		Default = 12
	})
end)

--[[run(function()
	local collision = lplr.Character:WaitForChild('Collision', 3)
	local anticheatbypass = {}
	local flagnotification = {}
	local noslow = {}
	local customtick = {}
	local bypassdelay = {}
	local clone
	local actick
	local alreadysent
	local oldrootcframe
	anticheatbypass = api.utility.CreateOptionsButton({
		Name = 'AntiCheatBypass',
		HoverText = 'Prevent the anticheat from detecting you.',
		Function = function(call)
			if call then
				table.insert(anticheatbypass.Connections, lplr.CharacterAdded:Connect(function()
					task.wait(0.25);
					anticheatbypass:retoggle();
				end))
				table.insert(anticheatbypass.Connections, lplr.Character.PrimaryPart:GetPropertyChangedSignal("Anchored"):Connect(function()
					if not speedflag and lplr.Character.PrimaryPart.Anchored then
						speedflag = true
						anticheatbypass.ToggleButton()
						if flagnotification.Enabled then
							errorNotification('AntiCheatBypass', 'You flagged, recommend to not use any type of speed for 5 seconds.', 7)
						end
						task.wait(2.5)
						lplr.Character.PrimaryPart.CFrame = oldrootcframe
						speedflag = false
						if not anticheatbypass.Enabled then
							anticheatbypass.ToggleButton()
						end
					end
				end))
				clone = collision:Clone()
				clone.CanCollide = false
				clone.Massless = true
				if clone:FindFirstChild('CollisionCrouch') then
					clone.CollisionCrouch:Remove()
				end
				clone.Parent = lplr.Character
				actick = tick()
				if noslow.Enabled then
					lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
				else
					lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.7, 0, 1, 1)
				end
				table.insert(anticheatbypass.Connections, runservice.Stepped:Connect(function()
					if not collision or collision.Parent == nil then
						anticheatbypass.ToggleButton()
						collision = lplr.Character:WaitForChild('Collision', 3)
						return errorNotification('AntiCheatBypass', 'Failed to Toggle, please retry.', 5)
					end
					if not speedflag and noslow.Enabled and lplr.Character.HumanoidRootPart.CustomPhysicalProperties ~= PhysicalProperties.new(100, 0, 0, 0, 0) then
						speedflag = true
						anticheatbypass.ToggleButton()
						if flagnotification.Enabled then
							errorNotification('AntiCheatBypass', 'You flagged, recommend to not use any type of speed for 5 seconds.', 7)
						end
						task.wait(2.5)
						lplr.Character.PrimaryPart.CFrame = oldrootcframe
						speedflag = false
						if not anticheatbypass.Enabled then
							anticheatbypass.ToggleButton()
						end
						return
					end
					local delay = (customtick.Enabled and (render.ping > 180 and bypassdelay.Value * 2 or bypassdelay.Value) or 0.2)
					if isAlive() then
						if tick() - actick >= delay then
							collision.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
							collision:FindFirstChild('CollisionCrouch').CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
							collision.Massless = not collision.Massless
							collision:FindFirstChild('CollisionCrouch').Massless = math.huge
							actick = tick()
						end
					end
				end))
			else
				speedflag = false
				alreadysent = false
				collision.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0, 1, 0.2, 1)
				lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.7, 0, 1, 1)
				collision:FindFirstChild('CollisionCrouch').CustomPhysicalProperties = PhysicalProperties.new(0.025, 0, 1, 0.2, 1)
				collision.Massless = false
				collision:FindFirstChild('CollisionCrouch').Massless = 0
				clone:Remove()
			end
		end
	})
	customtick = anticheatbypass.CreateToggle({
		Name = 'CustomDelay',
		Function = function(call)
			bypassdelay.Object.Visible = call
		end
	})
	bypassdelay = anticheatbypass.CreateSlider({
		Name = 'Tick',
		Function = void,
		Min = 1,
		Max = 5,
		Default = 0.2
	})
	noslow = anticheatbypass.CreateToggle({
		Name = 'NoSlow',
		Function = void
	})
	flagnotification = anticheatbypass.CreateToggle({
		Name = 'FlagNotification',
		Function = void,
		HoverText = 'Notifys you if you flagged.'
	})
	task.spawn(function()
		repeat
			if not speedflag then
				oldrootcframe = lplr.Character.PrimaryPart.CFrame
			end
			task.wait()
		until selfdestructed
	end)
end)]]
local collision = lplr.Character:WaitForChild('Collision', 3);
run(function()
	local anticheatbypass = {};
	local anticheatbypassmode = {};
	local anticheatbypassnotification = {};
	local latestposition = Vector3.zero;
	local oldsize = Vector3.zero;
	local actick = tick();
	local clone;
	anticheatbypass = api.utility.CreateOptionsButton({
		Name = 'AntiCheatBypass',
		HoverText = 'Prevent doors anticheat from detecting you.',
		Function = function(call)
			if call then
				table.insert(anticheatbypass.Connections, lplr.Character.PrimaryPart:GetPropertyChangedSignal("Anchored"):Connect(function()
					if lplr.Character.PrimaryPart.Anchored then
						anticheatbypass.ToggleButton()
						speedflag = true
						if anticheatbypassnotification.Enabled then
							errorNotification('Render', 'You flagged, recommend to not use any type of speed for 5 seconds.', 7)
						end
						lplr.Character.HumanoidRootPart.CFrame = latestposition
						task.wait(5)
						if not anticheatbypass.Enabled then
							anticheatbypass.ToggleButton()
						end
						speedflag = false
					end
				end))
				if not clone then
					clone = collision:Clone()
					clone.CanCollide = false
					clone.Massless = true
					clone:FindFirstChild('CollisionCrouch'):Remove()
					clone.Parent = lplr.Character
				end
				if not collision or collision.Parent == nil then
					anticheatbypass.ToggleButton()
					collision = lplr.Character:WaitForChild('Collision', 3)
					return errorNotification('AntiCheatBypass', 'Failed to Toggle, please retry.', 5)
				end
				table.insert(anticheatbypass.Connections, runservice.RenderStepped:Connect(function()
					if anticheatbypassmode.Value == 'Massless' then
						lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
						--(customtick.Enabled and (render.ping > 180 and bypassdelay.Value * 2 or bypassdelay.Value) or 0.2)
						if tick() - actick >= 0.22 then
							collision.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
							collision:FindFirstChild('CollisionCrouch').CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
							collision:FindFirstChild('CollisionCrouch').Massless = speedvalue.Value or 9e9
							collision.Massless = not collision.Massless
							actick = tick()
						end
					else
						if oldsize == Vector3.zero then
							oldsize = clone.Size
						end
						clone.Size = Vector3.new(9e9, 9e9, 9e9)
						task.wait(0.2)
						clone.Size = Vector3.new(2, 2, 1.5)
					end
				end))
			else
				clone:Remove()
				speedflag = false
				oldsize = Vector3.zero
				collision.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0, 1, 0.2, 1)
				collision.Massless = false
				collision:FindFirstChild('CollisionCrouch').CustomPhysicalProperties = PhysicalProperties.new(0.025, 0, 1, 0.2, 1)
				collision:FindFirstChild('CollisionCrouch').Massless = 0
				lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.7, 0, 1, 1)
			end
		end
	})
	anticheatbypassmode = anticheatbypass.CreateDropdown({
		Name = 'Bypass Mode',
		Function = void,
		List = {'Massless', 'Size'},
		Default = 'Massless'
	})
	anticheatbypassnotification = anticheatbypass.CreateToggle({
		Name = 'FlagNotification',
		Function = void,
		Default = true
	})
	task.spawn(function()
		repeat
			if not speedflag then
				latestposition = lplr.Character.HumanoidRootPart.CFrame
			end
			task.wait()
		until selfdestructed
	end)
end)

local ongoingentity = {spawned = false, root = nil}
run(function()
	local entitynotifier = {}
	local entities = {'Rush', 'Ambush', 'Eyes', 'Backdoor', 'A120', 'A60'}
	local customentity = {}
	entitynotifier = api.utility.CreateOptionsButton({
		Name = 'EntityNotifier',
		Function = function(call)
			if call then
				table.insert(entitynotifier.Connections, workspace.ChildAdded:Connect(function(v)
					for i2,v2 in entities do
						if v.Name:find(v2) then
							if not v.Name:find('Eyes') then
								local part 
								for i3, v3 in v:GetDescendants() do
									if v3.ClassName == 'Part' then
										part = v3
										break
									end
								end
								ongoingentity = {spawned = true, root = part}
							end
							warningNotification('Render', `{v.Name} has appeared!.`, 5)
							if isEnabled('ESP') then
								pcall(createtag, v.Name, v)
							end
							break
						end
					end
				end)) 
				table.insert(entitynotifier.Connections, workspace.ChildRemoved:Connect(function(v)
					for i2,v2 in entities do
						if v.Name:find(v2) then
							ongoingentity = {spawned = false, root = nil}
							warningNotification('Render', `{v.Name} has disappeared!.`, 5)
							break
						end
					end
				end)) 
			end
		end
	})
	customentity = entitynotifier.CreateTextList({
		Name = 'CustomEntities',
		TempText = 'Entity name',
		AddFunction = function(val)
			table.insert(entities, val)
		end
	})
end)

run(function()
	local crouchspoofer = {}
	crouchspoofer = api.utility.CreateOptionsButton({
		Name = 'CrouchSpoofer',
		Function = function(call)
			if call then
				table.insert(crouchspoofer.Connections, runservice.Stepped:Connect(function()
					replicatedstorage.RemotesFolder.Crouch:FireServer(true)
				end))
			else
				replicatedstorage.RemotesFolder.Crouch:FireServer(false)
			end
		end
	})
end)

run(function()
	local autohide = {};
	local autohidemode = {};
	local autohidenotification = false;
	local autohidealreadyhid = false;
	autohide = api.utility.CreateOptionsButton({
		Name = 'AutoHide',
		HoverText = 'Automatically hides for you when an entity appeared.',
		Function = function(call)
			if call then
				if autohidemode.Value == 'Teleport' then
					InfoNotification('AutoHide', 'This Hiding method may cause lagbacks and more, recommended to use Closet mode!', 7)
				end
				repeat
					if ongoingentity.root then
						local mag = (lplr.Character.PrimaryPart.Position - ongoingentity.root.Position).magnitude
						local wardrobe = getWardrobe()
						if mag < 50 and not autohidealreadyhid and autohidemode ~= 'Teleport' and wardrobe then
							autohidealreadyhid = true
							fireproximityprompt(wardrobe)
						elseif autohidemode == 'Teleport' then
							
						else
							autohidealreadyhid = false
						end
					end
					task.wait()
				until (not autohide.Enabled)
			end
		end
	})
	autohidemode = autohide.CreateDropdown({
		Name = 'Mode',
		List = {'Closet', 'Teleport'},
		Function = function()
			autohide:retoggle()
		end,
		Default = 'Closet'
	})
end)

run(function()
	local autosolver = {}
	local autosolverbreakerbox = {}
	local autosolveranchor = {}
	local setattribute = function(i, v)
		i:SetAttribute('Enabled', v)
		if v then
			i:FindFirstChild('PrismaticConstraint', true).TargetPosition = -0.2
			i.Light.Material = Enum.Material.Neon
			i.Light.Attachment.Spark:Emit(1)
			i.Sound.Pitch = 1.3
		else
			i:FindFirstChild('PrismaticConstraint', true).TargetPosition = 0.2
			i.Light.Material = Enum.Material.Glass
			i.Sound.Pitch = 1.2
		end
		i.Sound:Play()
	end
	autosolver = api.utility.CreateOptionsButton({
		Name = 'AutoSolver',
		HoverText = 'Automatically solves all type of minigame.',
		Function = function(call)
			if call then
				repeat
					if storage.files.roomdata.Value == 50 and autosolveranchor.Enabled and storage.files.stage == 'Mines' and mainui.MainFrame.AnchorHintFrame then
						local anchorprompts = {}
						for i,v in storage.gameprompts do
							if v.Parent.Name == 'MinesAnchor' and v.Name == 'ActivateEventPrompt' and not v.Parent:GetAttribute('Activated') then
								table.insert(anchorprompts, v)
							end
						end
						for i,v in anchorprompts do
							local curranchor = v.Parent.Sign.TextLabel.Text
							local suc, res = pcall(function()
								return v.Parent:FindFirstChildWhichIsA("RemoteFunction"):InvokeServer(mainui.MainFrame.AnchorHintFrame.Code.Text)
							end)
							if curranchor ~=  mainui.MainFrame.AnchorHintFrame.AnchorCode.Text then return end
							if suc and res then
								warningNotification('Render', `Sucessfully solved {curranchor}!`, 7)
							else
								errorNotification('Render', `Failed to enter anchor code --> {res}`, 7)
							end
						end
					end
					if storage.files.roomdata.Value < 99 then
						if storage.files.stage == 'Mines' then
							-- finishing later
						elseif storage.files.stage == 'Hotel' then
							local breakerbox = workspace.CurrentRooms['100']:FindFirstChild('ElevatorBreaker')
							if (not cheatenginetrash and require(maingame).stopcam) and breakerbox and not breakerbox:GetAttribute('Solving') then
								breakerbox:SetAttribute('Solving', true)
								local code = breakerbox:FindFirstChild('Code', true)
								local breakers = {}
								for i,v in breakerbox:GetChildren() do
									if v.Name == 'BreakerSwitch' then
										local id = string.format('%02d', v:GetAttribute('ID'))
										v[id] = v
									end
								end
								if code and code:FindFirstChild('Frame') then
									local used = {}
									table.insert(autobreakerbox.Connections, breakerbox.Box.Correct:GetPropertyChangedSignal('Playing'):Connect(function()
										if breakerbox.Box.Correct.Playing then
											table.clear(used)
										end
									end))
									table.insert(autobreakerbox.Connections, code:GetPropertyChangedSignal('Text'):Connect(function()
										task.wait()
										local currentcode = code.Text
										local isEnabled = code.Frame.BackgroundTransparency == 0
										local breaker = breakers[currentcode]
										if currentcode == '??' and #used == 9 then
											for i = 1, 10 do
												local id = string.format('%02d', i)
												if not table.find(used, id) then
													breaker = breakers[id]
												end
											end
										end
										if breaker then
											table.insert(used, currentcode)
											if breaker:GetAttribute('Enabled') ~= isEnabled then
												setattribute(breaker, isEnabled)
											end
										end
									end))
								end
							end 
						end
					end
					task.wait()
				until (not autosolver.Enabled)
			end
		end
	})
	autosolverbreakerbox = autosolver.CreateToggle({
		Name = 'BreakerBox',
		Function = void,
		Default = true
	})
	autosolveranchor = autosolver.CreateToggle({
		Name = 'Anchor',
		Function = void,
		Default = true
	})
end)

run(function()
	local autopadlock = {}
	local autoenter = {}
	local autoenterdistance = {}
	local alreadysent = false
	autopadlock = api.utility.CreateOptionsButton({
		Name = 'AutoPadLock',
		Function = function(call)
			if call then
				repeat
					if workspace.CurrentRooms:FindFirstChild('50') then
						local tool = lplr.Character:FindFirstChildWhichIsA('Tool')
						if tool and tool.Name:find('LibraryHintPaper') then
							local code = table.concat(getpadlockcode(tool))
							local output, count = code:gsub('_', 'x')
							if autoenter.Enabled then
								replicatedstorage.RemotesFolder.PL:FireServer(code)
							end
							if not alreadysent and count < 5 then
								return InfoNotification('AutoPadLock', `Padlock code is {output}`, 10)
							end
						end 
					end
					task.wait()
				until (not autopadlock.Enabled)
			end
		end
	})
	autoenter = autopadlock.CreateToggle({
		Name = 'AutoUse',
		Function = function(call)
			autoenterdistance.Object.Visible = call
		end
	})
	autoenterdistance = autopadlock.CreateSlider({
		Name = 'Distance',
		Function = void,
		Min = 1,
		Max = 100,
		Default = 35
	})
end)

run(function()
	local autointeract = {}
	autointeract = api.utility.CreateOptionsButton({
		Name = 'AutoInteract',
		Function = function(call)
			if call then
				repeat
					local room = workspace.CurrentRooms[storage.files.roomdata.Value]:FindFirstChild('Door')
					if room and not room:FindFirstChild('Lock') and room:FindFirstChild('ClientOpen') then
						room.ClientOpen:FireServer()
					elseif room and room:FindFirstChild('Lock') and getItemNear('Key') then
						local mag = (lplr.Character.PrimaryPart.Position - room:FindFirstChild('Door').Position).Magnitude
						if mag < 20 then
							fireproximityprompt(room.Lock:FindFirstChild('UnlockPrompt'))
						end
					end
					task.wait()
				until (not autointeract.Enabled)
			end
		end
	})
end)

run(function()
	local anticliententity = {}
	local bypasshalt = {}
	local bypasseyes = {}
	local bypassgiggle = {}
	local bypasssnare = {}
	local bypassegg = {}
	local NoObstructors = {}
	local geteyeentity = function()
		if workspace:FindFirstChild('Eyes') or workspace:FindFirstChild('BackdoorLookman') then
			return true
		end
		return false
	end
	local old
	anticliententity = api.utility.CreateOptionsButton({
		Name = 'AntiEntities',
		Function = function(call)
			if call then
				old = not cheatenginetrash and require(replicatedstorage.ClientModules.EntityModules.Shade).stuff
				if bypasshalt.Enabled and not cheatenginetrash then
					--print('not cheatengine')
					require(replicatedstorage.ClientModules.EntityModules.Shade).stuff = function() end
				elseif bypasshalt.Enabled and cheatenginetrash then
					local module = storage.files.remotelistener.Modules:FindFirstChild("_Shade")
					if module then
						module.Name = "qwiujedroqjqsmjdShade"
					end
				end
				for i,v in {'Screech', 'A90'} do
					local entity = storage.files.remotelistener.Modules:FindFirstChild(v)
					if entity then
						entity.Name = `qwiujedroqjqsmjd{v}`
					end
				end
				task.spawn(function()
					repeat
						if geteyeentity() then
							if storage.files.stage == 'Fools' then
								replicatedstorage.RemotesFolder.MotorReplication:FireServer(0, -9e9, 0, false)
							else
								replicatedstorage.RemotesFolder.MotorReplication:FireServer(-649)
							end
						end
						task.wait()
					until (not anticliententity.Enabled)
				end)
				table.insert(anticliententity.Connections, workspace.CurrentRooms.DescendantAdded:Connect(function(obj)
					if (obj.Name == 'Seek_Arm' or obj.Name == 'ChandelierObstruction') and NoObstructors.Enabled then
						for i,v in obj:GetDescendants() do
							if v:IsA('BasePart') then v.CanTouch = false end
						end
					end
					if (obj.Name == 'Egg' and obj:IsA('BasePart')) and bypassegg.Enabled then
						obj:WaitForChild('Hitbox', 5).CanTouch = false
					end
					if obj.Name == 'GiggleCeiling' and bypassgiggle.Enabled then
						obj:WaitForChild('Hitbox', 5).CanTouch = false
					end
					if obj.Name == 'Snare' and bypasssnare.Enabled then
						obj:WaitForChild('Hitbox', 5).CanTouch = false
					end
				end))
			else
				if not cheatenginetrash then
					require(replicatedstorage.ClientModules.EntityModules.Shade).stuff = old
				end
				for i,v in {'Screech', 'A90', '_Shade'} do
					local entity = storage.files.remotelistener.Modules:FindFirstChild('qwiujedroqjqsmjd'.. v)
					if entity then
						entity.Name = v
					end
				end
			end
		end
	})
	bypasshalt = anticliententity.CreateToggle({
		Name = 'Bypass Halt',
		Function = void,
		Default = true
	})
	bypassegg = anticliententity.CreateToggle({
		Name = 'Bypass Egg',
		Function = void,
		Default = true
	})
	bypasssnare = anticliententity.CreateToggle({
		Name = 'Bypass Snare',
		Function = void,
		Default = true
	})
	bypassgiggle = anticliententity.CreateToggle({
		Name = 'Bypass Giggle',
		Function = void,
		Default = true
	})
	NoObstructors = anticliententity.CreateToggle({
		Name = 'Remove Seek Obstructors',
		Function = void,
		Default = true
	})
	bypasseyes = anticliententity.CreateToggle({
		Name = 'Bypass Eyes',
		Function = void,
		Default = true
	})
end)

run(function()
	local promptreach = {}
	local promptreachmultiplier = {}
	promptreach = api.utility.CreateOptionsButton({
		Name = 'PromptReach',
		Function = function(call)
			if call then
				table.insert(promptreach.Connections, workspace.CurrentRooms.DescendantAdded:Connect(function(v)
					if v.ClassName == 'ProximityPrompt' and not table.find({'HidePrompt', 'InteractPrompt'}, v.Name) then
						v.MaxActivationDistance *= promptreachmultiplier.Value
					end
				end))
			end
		end
	})
	promptreachmultiplier = promptreach.CreateSlider({
		Name = 'Multiplier',
		Function = void,
		Min = 1,
		Max = 5,
		Default = 2
	})
end)
run(function()
	local fastinteract = {}
	local fastinteractminecart = {}
	local fastinteractbook = {}
	local fastinteractbreaker = {}
	local fastinteractvalue = {}
	local currentprompt;
	fastinteract = api.utility.CreateOptionsButton({
		Name = 'FastInteract',
		Function = function(call)
			if call then
				table.insert(fastinteract.Connections, promptservice.PromptTriggered:Connect(function(v)
					if v.HoldDuration == 0 and v.Name ~= currentprompt then
						if v.Name == 'PushPrompt' and fastinteractminecart.Enabled then
							currentprompt = v.Name
							for i = 1, fastinteractvalue.Value do
								fireproximityprompt(v)
							end
						end
						if v.Name == 'ActivateEventPrompt' and v.Parent.Name == 'LiveHintBook' and fastinteractbook.Enabled then
							currentprompt = v.Name
							for i = 1, fastinteractvalue.Value do
								fireproximityprompt(v)
							end
						end
						if v.Name == 'ActivateEventPrompt' and v.Parent.Name == 'LiveBreakerPolePickup' and fastinteractbreaker.Enabled then
							currentprompt = v.Name
							for i = 1, fastinteractvalue.Value do
								fireproximityprompt(v)
							end
						end
					else
						return 
					end
					currentprompt = ''
				end))
			end
		end,
		HoverText = 'Makes your interact faster.'
	})
	fastinteractvalue = fastinteract.CreateSlider({
		Name = 'Value',
		Function = void,
		Min = 1,
		Max = 100,
		Default = 50
	})
	fastinteractminecart = fastinteract.CreateToggle({
		Name = 'Minecart',
		Function = void,
		Default = true
	})
	fastinteractbook = fastinteract.CreateToggle({
		Name = 'Book',
		Function = void,
		Default = true
	})
	fastinteractbreaker = fastinteract.CreateToggle({
		Name = 'Breaker',
		Function = void,
		Default = true
	})
end)

run(function()
	local autorevive = {}
	autorevive = api.utility.CreateOptionsButton({
		Name = 'AutoRevive',
		Function = function(call)
			if call then
				table.insert(autorevive.Connections, lplr.Character.Humanoid:GetPropertyChangedSignal('Health'):Connect(function()
					if not isAlive() then
						replicatedstorage.RemotesFolder.Revive:FireServer()
					end
				end))
			end
		end,
		HoverText = 'Automatically revive you after death.'
	})
end)

-- exploit tab --

run(function()
	local antihit = {}
	antihit = api.exploit.CreateOptionsButton({
		Name = 'AntiHit',
		Function = function(call)
			if call then
				repeat
					if workspace.CurrentRooms:FindFirstChild('50') then
						setnetworkownership(nil)
						for i,v in workspace:FindFirstChild('FigureRig'):GetChildren() do
							if v.CanTouch then
								v.CanTouch = false
							end
							if v.CanCollide then
								v.CanCollide = false
							end
						end
					end
					task.wait()
				until (not antihit.Enabled)
			end
		end,
		HoverText = 'Prevent figure from attacking you.'
	})
end)

run(function()
	local autocrucifix = {}
	autocrucifix = api.exploit.CreateOptionsButton({
		Name = 'AutoCrucifix',
		Function = function(call)
			if call then
				repeat
					local crucfix = getItemNear('Crucifix')
					if crucfix and ongoingentity.root then
						if crucfix.Parent == lplr.Backpack then
							crucfix.Parent = lplr.Character
						end
						local mag = (lplr.Character.PrimaryPart.Position - ongoingentity.root.Position).magnitude
						if mag < 50 then
							replicatedstorage.RemotesFolder.DropItem:FireServer(item)
							task.wait(0.05)
							local drop = getdropitems(item.Name)
							if drop then
								for i = 1,10 do
									fireproximityprompt(drop)
								end
							end
						end
					end
					task.wait()
				until (not autocrucifix.Enabled)
			end
		end,
		HoverText = 'Automatically uses crucifix while still keeping it.'
	})
end)

-- legit tab --

--[[
run(function()
	local autoitem = {}
	autoitem = vape.CreateLegitModule({
		Name = 'AutoItem',
		Function = function(call)
			if call then 
				repeat
					
					task.wait()
				until (not autoitem.Enabled)
			end
		end,
		HoverText = 'Automatically uses your item \nin a situation that you need them.'
	})
end)]]

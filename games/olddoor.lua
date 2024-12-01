--[[

  $$$$$$$\							$$\						   $$\	$$\							  
  $$  __$$\						   $$ |						  $$ |   $$ |							 
  $$ |  $$ | $$$$$$\  $$$$$$$\   $$$$$$$ | $$$$$$\   $$$$$$\		$$ |   $$ |$$$$$$\   $$$$$$\   $$$$$$\  
  $$$$$$$  |$$  __$$\ $$  __$$\ $$  __$$ |$$  __$$\ $$  __$$\	   \$$\  $$  |\____$$\ $$  __$$\ $$  __$$\ 
  $$  __$$< $$$$$$$$ |$$ |  $$ |$$ /  $$ |$$$$$$$$ |$$ |  \__|	   \$$\$$  / $$$$$$$ |$$ /  $$ |$$$$$$$$ |
  $$ |  $$ |$$   ____|$$ |  $$ |$$ |  $$ |$$   ____|$$ |			  \$$$  / $$  __$$ |$$ |  $$ |$$   ____|
  $$ |  $$ |\$$$$$$$\ $$ |  $$ |\$$$$$$$ |\$$$$$$$\ $$ |			   \$  /  \$$$$$$$ |$$$$$$$  |\$$$$$$$\ 
  \__|  \__| \_______|\__|  \__| \_______| \_______|\__|				\_/	\_______|$$  ____/  \_______|
																					  $$ |				
																					  $$ |				
																					  \__|   
   A very sexy and overpowered vape mod created at Render Intents  
   CustomModules/6839171747.lua (Doors) - Maxlasertech & Selunariorium		  
   https://renderintents.lol																																																																	 
]]

local getservice = function(serv)
	return cloneref(game.GetService(game, serv))
end
local vape = shared.GuiLibrary
local players = getservice('Players');
local lplr = players.LocalPlayer
local textservice = getservice('TextService');
local inputservice = getservice('UserInputService');
local runservice = getservice('RunService');
local teleport = getservice('TeleportService');
local tween = getservice('TweenService');
local promptservice = getservice('ProximityPromptService')
local collection = getservice('CollectionService');
local httpservice = getservice('HttpService');
local replicatedstorage = getservice('ReplicatedStorage');
local camera = workspace.Camera or Instance.new('Camera', workspace)

local mainui = lplr.PlayerGui:WaitForChild('MainUI')
local init = mainui:WaitForChild('Initiator')
local maingame = init:WaitForChild('Main_Game')
local remotelistener = maingame:WaitForChild('RemoteListener')

local remotesfolder = replicatedstorage:WaitForChild('RemotesFolder')
local data = replicatedstorage:WaitForChild('GameData')

local Backdoor = data:WaitForChild('Floor').Value == 'Backdoor'
local Hotel = data:WaitForChild('Floor').Value == 'Hotel'
local Rooms = data:WaitForChild('Floor').Value == 'Rooms'
local Apr = data:WaitForChild('Floor').Value == 'Fools'
local Mines = data:WaitForChild('Floor').Value == 'Mines'

local api = {
	combat = vape.ObjectsThatCanBeSaved.CombatWindow.Api,
	blatant = vape.ObjectsThatCanBeSaved.BlatantWindow.Api,
	render = vape.ObjectsThatCanBeSaved.RenderWindow.Api,
	exploit = vape.ObjectsThatCanBeSaved.ExploitWindow.Api,
	utility = vape.ObjectsThatCanBeSaved.UtilityWindow.Api,
	world = vape.ObjectsThatCanBeSaved.WorldWindow.Api
}

local storage = {
	drawers = {},
	prompt = {},
	lockers = {
		lootprompt = {}
	},
	connections = {},
	esps = {},
	keys = {},
	ongroundloot = {},
	ignore = {
		'HidePrompt',
		'InteractPrompt'
	},
	currentkey = nil
}
local FindAttribute = function(instance, attribute)
	local find = instance.Parent
	if not find then
		return nil
	end
	if find:GetAttribute(attribute) ~= nil then
		return find
	end
	return FindAttribute(find, attribute)
end
local createesp = function(parent)
	local highlight = Instance.new('Highlight', parent)
	highlight.FillColor = Color3.new(1, 0, 0)
	highlight.FillTransparency = 0.7
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	table.insert(storage.esps, highlight)
end

local createtag = function(tag, parent)
	local gui = Instance.new('BillboardGui', parent)
	gui.Size = UDim2.new(0, 200, 0, 50)
	gui.StudsOffset = Vector3.new(0, 2, 0)
	gui.AlwaysOnTop = true

	local label = Instance.new('TextLabel', gui)
	label.TextColor3 = Color3.fromRGB(255, 0, 0)
	label.Text = tag
	label.TextSize = 23
	label.Size = UDim2.new(0, 180, 0, 50)
	label.Font = Enum.Font.Gotham
	label.BackgroundTransparency = 1

	Instance.new('UIStroke', label).Thickness = 1
	table.insert(storage.esps, label)
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
		for i,v in actualcode do
			print(i,v)
		end
		return actualcode
	end
	return '_____'
end

vape.SelfDestructEvent.Event:Once(function()
	for i,v in storage.connections do
		pcall(function() v:Disconnect() end)
	end
end)

for i,v in workspace.CurrentRooms:GetDescendants() do
	if v:IsA('ProximityPrompt') and not table.find(storage.ignore, v.Name) then
		table.insert(storage.prompt, v)
	end
end

table.insert(storage.connections, workspace.CurrentRooms.DescendantAdded:Connect(function(v)
	if v:IsA('ProximityPrompt') and not table.find(storage.ignore, v) then
		table.insert(storage.prompt, v)
	end
end))

table.insert(storage.connections, workspace.CurrentRooms.DescendantRemoving:Connect(function(v)
	for a,b in storage.prompt do
		if b == v then
			table.remove(storage.prompt, a)
		end
	end
end))

vape.RemoveObject('SilentAimOptionsButton')
vape.RemoveObject('ReachOptionsButton')
vape.RemoveObject('MouseTPOptionsButton')
vape.RemoveObject('AutoClickerOptionsButton')
vape.RemoveObject('SpiderOptionsButton')
vape.RemoveObject('InstantInteractOptionsButton')
vape.RemoveObject('PhaseOptionsButton')
vape.RemoveObject('LongJumpOptionsButton')
vape.RemoveObject('HitBoxesOptionsButton')
vape.RemoveObject('FOVChangerOptionsButton')
vape.RemoveObject('KillauraOptionsButton')
vape.RemoveObject('ChamsOptionsButton')
vape.RemoveObject('TriggerBotOptionsButton')
vape.RemoveObject('AutoLeaveOptionsButton')
vape.RemoveObject('ClientKickDisablerOptionsButton')
vape.RemoveObject('NameTagsOptionsButton')
vape.RemoveObject('SafeWalkOptionsButton')
vape.RemoveObject('BlinkOptionsButton')
vape.RemoveObject('AntiVoidOptionsButton')
vape.RemoveObject('SongBeatsOptionsButton')
vape.RemoveObject('TargetStrafeOptionsButton')

run(function()
	local anticheatbypass = {}
	local actick
	local collision = lplr.Character:WaitForChild('Collision', 3)
	local NoSlow = {}
	anticheatbypass = api.utility.CreateOptionsButton({
		Name = 'AntiCheatBypass',
		Function = function(call)
			if call then
				if not collision then
					anticheatbypass.ToggleButton()
					return errorNotification('Render', 'Clone not found.', 5)
				end
				table.insert(anticheatbypass.Connections, lplr.CharacterAdded:Connect(function()
					anticheatbypass.ToggleButton()
					return errorNotification('Render', 'Clone not found.', 5)
				end))
				clone = collision:Clone()
				clone.CanCollide = false
				clone.Massless = true
				if clone:FindFirstChild('CollisionCrouch') then
					clone.CollisionCrouch:Remove()
				end
				clone.Parent = lplr.Character
				actick = tick()
				if NoSlow.Enabled then
					lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(100,0,0,0,0)
				else
					lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.7, 0, 1, 1)
				end
				repeat
					if isAlive() then
						if tick() - actick >= 0.2 then
							collision.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
							collision:FindFirstChild('CollisionCrouch').CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
							collision.Massless = not collision.Massless
							actick = tick()
							collision:FindFirstChild('CollisionCrouch').Massless = math.huge
						end
					end
					task.wait()
				until (not anticheatbypass.Enabled)
			else
				collision.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0, 1, 0.2, 1)
				lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.7, 0, 1, 1)
				collision:FindFirstChild('CollisionCrouch').CustomPhysicalProperties = PhysicalProperties.new(0.025, 0, 1, 0.2, 1)
				collision.Massless = false
				collision:FindFirstChild('CollisionCrouch').Massless = 0
				clone:Remove()
			end
		end,
		HoverText = 'Method from selunariorium.'
	})
	NoSlow = anticheatbypass.CreateToggle({
		Name = 'No Slowdown',
		HoverText = 'Only works with walkspeed',
		Function = void
	})
end)

run(function()
	local entitynotifier = {}
	entitynotifier = api.utility.CreateOptionsButton({
		Name = 'EntityNotifier',
		Function = function(call)
			if call then
				table.insert(entitynotifier.Connections, workspace.ChildAdded:Connect(function(v)
					if (v.ClassName == 'Model' and v.ClassName ~= 'Part') and v.Name:find('Rush') or v.Name:find('Ambush') or v.Name:find('Eyes') or v.Name:find('Backdoor') or v.Name:find('A120') or v.Name:find('A60') then
						warningNotification('Render', `{v.Name} has appeared!.`, 5)
						pcall(createtag, v.Name, v)
					end
				end)) 
				table.insert(entitynotifier.Connections, workspace.ChildRemoved:Connect(function(v)
					if (v.ClassName == 'Model' and v.ClassName ~= 'Part') and v.Name:find('Rush') or v.Name:find('Ambush') or v.Name:find('Eyes') or v.Name:find('Backdoor') or v.Name:find('A120') or v.Name:find('A60') then
						warningNotification('Render', `{v.Name} disappeared.`, 5)
					end
				end)) 
			end
		end
	})
end)

run(function()
	local esp = {}
	local esptag = {}
	local espdoor = {}
	local esplever = {}
	local espfuse = {}
	local espkey = {}
	local espgenerator = {}
	local espbook = {}
	local espentities = {}
	local espplayer = {}
	local espbreaker = {}
	esp = api.render.CreateOptionsButton({
		Name = 'Highlight',
		Function = function(call)
			if call then
				for i,v in workspace.CurrentRooms:GetDescendants() do
					if v.ClassName == 'Model' and v.Name:lower() == 'door' and espdoor.Enabled then
						pcall(createesp, v:FindFirstChild('Door'))
						if esptag.Enabled then
							pcall(createtag, `Door {v.Parent.Name}`, v)
						end
					end
					if v.Name:lower() == 'keyobtain' and espkey.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Key', v)
						end
					end
					if v.Name:lower():find('lever') and v.Parent.Name ~= 'MinesGenerator' and esplever.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Lever', v)
						end
					end
					if v.Name:lower():find('minesgenerator') then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Generator', v)
						end
					end
					if v.Name:lower() == 'fusemodel' and espfuse.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Fuse', v)
						end
					end
					if v.Name:lower():find('giggle') and espentities.Enabled or v.Name:lower():find('figurerig') and espentities.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, v.Name, v)
						end
					end
					if v.Name == 'LiveHintBook' and espbook.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Book', v)
						end
					end
					if v.Name:lower() == 'imstuff' and espbreaker.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Breaker', v)
						end
					end
					if espplayer.Enabled then
						for i,v in players:GetPlayers() do
							if v ~= lplr and isAlive() then
								pcall(createesp, v)
								if esptag.Enabled then
									pcall(createtag, v.DisplayName, v.Character)
								end
							end
						end
					end
				end
				table.insert(esp.Connections, workspace.CurrentRooms.DescendantAdded:Connect(function(v)
					if v.ClassName == 'Model' and v.Name:lower() == 'door' and espdoor.Enabled then
						pcall(createesp, v:FindFirstChild('Door'))
						if esptag.Enabled then
							pcall(createtag, `Door {v.Parent.Name}`, v)
						end
					end
					if v.Name:lower() == 'keyobtain' and espkey.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Key', v)
						end
					end
					if v.Name:lower():find('lever') and esplever.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Lever', v)
						end
					end
					if v.Name:lower() == 'fusemodel' and espfuse.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Fuse', v)
						end
					end
					if v.Name:lower():find('giggle') and espentities.Enabled or v.Name:lower():find('figurerig') and espentities.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, v.Name, v)
						end
					end
					if v.Name:lower() == 'imstuff' and espbreaker.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Breaker', v)
						end
					end
					if v.Name == 'LiveHintBook' and espbook.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Book', v)
						end
					end
				end))
			else
				for i,v in storage.esps do
					pcall(function() v:Remove() end)
					table.remove(storage.esps, i)
				end
			end
		end
	})
	espplayer = esp.CreateToggle({
		Name = 'Player',
		Function = void
	})
	esptag = esp.CreateToggle({
		Name = 'Show Name',
		Function = void
	})
	espkey = esp.CreateToggle({
		Name = 'Key',
		Function = void
	})
	espdoor = esp.CreateToggle({
		Name = 'RealDoor',
		Function = void
	})
	esplever = esp.CreateToggle({
		Name = 'Lever',
		Function = void
	})
	espfuse = esp.CreateToggle({
		Name = 'Fuse',
		Function = void
	})
	espgenerator = esp.CreateToggle({
		Name = 'Generator',
		Function = void
	})
	espentities = esp.CreateToggle({
		Name = 'Entities',
		Function = void
	})
	espbook = esp.CreateToggle({
		Name = 'Book',
		Function = void
	})
	espbreaker = esp.CreateToggle({
		Name = 'Breaker',
		Function = void
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
	local autopadlock = {}
	local autoenter = {}
	autopadlock = api.utility.CreateOptionsButton({
		Name = 'AutoPadLock',
		Function = function(call)
			if call then
				local tool = player.Character:FindFirstChildWhichIsA('Tool')
				if tool and tool.Name:find('LibraryHintPaper') then
					pcall(print, table.concat(getpadlockcode(tool)))
					local code = table.concat(getpadlockcode(tool))
					local output, count = code:gsub('_', 'x')
					print(count)
					if autoenter.Enabled then
						replicatedstorage.RemotesFolder.PL:FireServer(code)
					end
					if count < 5 then
						warningNotification('Render', `Padlock code is {output}`, 7)
					end
				else
					errorNotification('Render', 'Paper not found.', 5)
				end 
			end
		end
	})
	autoenter = autopadlock.CreateToggle({
		Name = 'AutoUse',
		Function = void
	})
end)

run(function()
	local autobreakerbox = {}
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
	autobreakerbox = api.utility.CreateOptionsButton({
		Name = 'AutoBreakerBox',
		Function = function(call)
			if call then
				if workspace.CurrentRooms:FindFirstChild('100') then
					local breakerbox = workspace.CurrentRooms['100']:FindFirstChild('ElevatorBreaker')
					if require(maingame).stopcam and breakerbox and not breakerbox:GetAttribute('Solving') then
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
							local correct = breakerbox.Box.Correct
							local used = {}
							
							table.insert(autobreakerbox.Connections, correct:GetPropertyChangedSignal('Playing'):Connect(function()
								if correct.Playing then
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
		end
	})
end)

run(function()
	local doorreach = {}
	local currentRoom = replicatedstorage:WaitForChild('GameData'):WaitForChild('LatestRoom')
	doorreach = api.utility.CreateOptionsButton({
		Name = 'DoorReach',
		Function = function(call)
			if call then
				repeat
					local room = workspace.CurrentRooms[currentRoom.Value]:FindFirstChild('Door')
					if room and room:FindFirstChild('ClientOpen') then
						room:FindFirstChild('ClientOpen'):FireServer()
					end
					task.wait()
				until (not doorreach.Enabled)
			end
		end
	})
end)

run(function()
	local anticliententity = {}
	local antiscreech = {}
	local antiA90 = {}
	local bypasshalt = {}
	local bypasseyes = {}
	local bypassgiggle = {}
	local bypasssnare = {}
	local bypassegg = {}
	local NoObstructors = {}
	local old
	anticliententity = api.utility.CreateOptionsButton({
		Name = 'AntiEntities',
		Function = function(call)
			if call then
				old = require(replicatedstorage.ClientModules.EntityModules.Shade).stuff
				if bypasshalt.Enabled then
					require(replicatedstorage.ClientModules.EntityModules.Shade).stuff = function() end
				end
				if antiscreech.Enabled then
					local ps = remotelistener.Modules:FindFirstChild('Screech')
						ps.Name = 'Annoying Black Creature'
					if ps then
					end
				else
					local ps = remotelistener.Modules:FindFirstChild('Annoying Black Creature')
					if ps then
						ps.Name = 'Screech'
					end
				end
				if antiA90.Enabled then
					local a = remotelistener.Modules:FindFirstChild('A90')
					if a then
						a.Name = 'Screamer'
					end
				else
					local a = remotelistener.Modules:FindFirstChild('Screamer')
					if a then
						a.Name = 'A90'
					end
				end
				table.insert(anticliententity.Connections, Workspace.CurrentRooms.DescendantAdded:Connnect(function(obj)
					if Hotel or Apr then
						if (obj.Name == 'Seek_Arm' or obj.Name == 'ChandelierObstruction') and NoObstructors.Enabled then
							for i,v in obj:GetDescendants() do
								if v:IsA('BasePart') then v.CanTouch = false end
							end
						end
					end
					if Mines then
						if (obj.Name == 'Egg' and obj:IsA('BasePart')) and bypassegg.Enabled then
							obj:WaitForChild('Hitbox', 5).CanTouch = false
						end
						if obj.Name == 'GiggleCeiling' and bypassgiggle.Enabled then
							obj:WaitForChild('Hitbox', 5).CanTouch = false
						end
					end
					if not Rooms and not Backdoor then
						if obj.Name == 'Snare' and bypasssnare.Enabled then
							obj:WaitForChild('Hitbox', 5).CanTouch = false
						end
					end
				end))
			else
				require(replicatedstorage.ClientModules.EntityModules.Shade).stuff = old
			end
		end
	})
	antiscreech = anticliententity.CreateToggle({
		Name = 'AntiScreech',
		Function = void,
		Default = false
	})
	antiA90 = anticliententity.CreateToggle({
		Name = 'AntiA90',
		Function = void,
		Default = false
	})
	bypasshalt = anticliententity.CreateToggle({
		Name = 'Bypass Halt',
		Function = void,
		Default = false
	})
	bypassegg = anticliententity.CreateToggle({
		Name = 'Bypass Egg',
		Function = void,
		Default = false
	})
	bypasssnare = anticliententity.CreateToggle({
		Name = 'Bypass Snare',
		Function = void,
		Default = false
	})
	bypassgiggle = anticliententity.CreateToggle({
		Name = 'Bypass Giggle',
		Function = void,
		Default = false
	})
	NoObstructors = anticliententity.CreateToggle({
		Name = 'Remove Seek Obstructors',
		Function = void,
		Default = false
	})
	bypasseyes = anticliententity.CreateToggle({
		Name = 'Bypass Eyes',
		Function = function()
			if not Rooms then
				table.insert(bypasseyes.Connections, Workspace.ChildAdded:Connect(function(v)
					if v.Name == 'Eyes' or v.Name == 'BackdoorLookman' then
						repeat 
							if Apr then
								remotesfolder.MotorReplication:FireServer(0, -9e9, 0, false)
							else
								remotesfolder.MotorReplication:FireServer(-9e9)
							end
							task.wait()
						until not bypasseyes.Enabled or not v
					end
				end))
			end
		end,
		Default = false
	})
	--[[ selu is insane
		local Toggle = {
			['A90'] = antiA90.Object,
			['Snare'] = ,
			['Eyes'] = bypasseyes.Object,
			['Giggle'] = bypassgiggle.Object,
			['Screech'] = antiscreech.Object,
			['Obs'] = NoObstructors.Object,
			['Egg'] = bypassegg.Object,
			['Halt'] = bypasshalt.Object
		}
		if gamestage == 'Backdoor' then
			bypasshalt.Object.Visible = false
			antiscreech.Object.Visible = false
			bypasssnare.Object.Visible = false
			bypasssnare.ToggleButton()
			bypasshalt.ToggleButton()
			antiscreech.ToggleButton()
		else
			Toggle['Halt'].Object.Visible = true
			Toggle['Screech'].Object.Visible = true
			Toggle['Snare'].Object.Visible = true
			bypasssnare.ToggleButton(true)
			bypasshalt.ToggleButton(true)
			antiscreech.ToggleButton(true)
		end
		if not Rooms then
			Toggle['A90'].Visible = false
			antiA90.ToggleButton(false)
		else
			Toggle['A90'].Visible = true
			antiA90.ToggleButton(true)
		end
		if Rooms then
			Toggle['Eyes'].Object.Visible = false
			bypasseyes.ToggleButton()
		else
			Toggle['Eyes'].Object.Visible = true
			bypasseyes.ToggleButton(true)
		end
		if not Mines then
			Toggle['Giggle'].Visible = false
			Toggle['Egg'].Visible = false
			bypassegg.ToggleButton()
			bypassgiggle.ToggleButton()
		else
			Toggle['Giggle'].Visible = true
			Toggle['Egg'].Visible = true
			bypassegg.ToggleButton(true)
			bypassgiggle.ToggleButton(true)
		end
		if Hotel or Apr then
			Toggle['Obs'].Visible = true
			NoObstructors.ToggleButton(true)
		else
			Toggle['Obs'].Visible = false
			NoObstructors.ToggleButton(false)
		end
	]]
end)

run(function()
	local autocollect = {}
	local autocollectkey = {}
	local autocollectgold = {}
	local autocollectbook = {}
	local autocollectrange = {}
	local autocollectitem = {}
	autocollect = api.world.CreateOptionsButton({
		Name = 'AutoCollect',
		Function = function(call)
			if call then
				repeat
					pcall(function()
						if workspace.CurrentRooms:FindFirstChild('50') then
							for i,v in workspace.CurrentRooms['50'].Assets:GetChildren() do
								if v.ClassName == 'ProximityPrompt' then
									fireproximityprompt(v)
								end
							end
						end
					end)
					pcall(function()
						for i,v in storage.prompt do
							local part = v:FindFirstAncestorWhichIsA('BasePart')
							local mag = (lplr.Character.HumanoidRootPart.Position - part.Position).magnitude
							if mag < autocollectrange.Value then
								task.wait(0.05)
								if (not knob:GetAttribute('Interactions'.. lplr.Name) or not knob:GetAttribute('Interactions')) and v.Parent.Name = 'Knobs' then
									fireproximityprompt(v)
								end
								if v:FindFirstAncestor('GoldPile') and autocollectgold.Enabled then
									pcall(fireproximityprompt, v)
								end
								if v.Name == 'ModulePrompt' and v.Parent.Name ~= 'KeyObtain' and autocollectitem.Enabled or v.Name == 'ModulePrompt' and v.Parent.Name == 'KeyObtain' and autocollectkey.Enabled then
									fireproximityprompt(moduleprompt)
								end
							end
						end
					end)
					if autocollectkey.Enabled then
						pcall(function()
							for i,v in storage.prompt do
								if v.Parent.Name = 'KeyObtain' then
									local mag = (lplr.Character.HumanoidRootPart.Position - v.Parent.Hitbox.Position).magnitude
									if mag < autocollectrange.Value then
										pcall(fireproximityprompt, v)
									end
								end
							end
						end)
					end
					pcall(function()
						for i,v in storage.prompt do
							if type(v) ~= 'table' then
								local doorpos = v:FindFirstAncestor('Door')
								local mag = (lplr.Character.HumanoidRootPart.Position - doorpos).magnitude
								if mag < autocollectrange.Value then
									local prompt = v
									if not prompt:GetAttribute('Interactions') then
										fireproximityprompt(prompt)
									end
									for _, item in v:GetDescendants() do
										local find = FindAttribute(item, 'Single') and FindAttribute(item, 'Pickup')
										if find then
											fireproximityprompt(item)
										end
									end
								end
							end
						end
					end)
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
	autocollectgold = autocollect.CreateToggle({
		Name = 'Gold',
		Function = void,
		Default = true
	})
	autocollectitem = autocollect.CreateToggle({
		Name = 'Item',
		Function = void,
		Default = true
	})
	autocollectbook = autocollect.CreateToggle({
		Name = 'Book',
		Function = void,
		Default  = true
	})
	autocollectkey = autocollect.CreateToggle({
		Name = 'Key',
		Function = void,
		Default = true
	})
end)

run(function()
	local autohide = {}
	local isHiding = false
	local oldpos
	autohide = api.blatant.CreateOptionsButton({
		Name = 'AutoHide',
		Function = function(call)
			if call then
				table.insert(autohide.Connections, workspace.ChildAdded:Connect(function(ent)
					if ent.Name:lower():find('rush') or ent.Name:lower():find('ambush') or ent.Name:find('A60') or ent.Name:find('A120') then
						warningNotification('Render', 'Hiding..', 7)
						oldpos = lplr.Character.HumanoidRootPart.CFrame
						if isEnabled('Fly') then
							vape.ObjectsThatCanBeSaved.FlyOptionsButton.Api.ToggleButton()
						end
						if isEnabled('Speed') then
							vape.ObjectsThatCanBeSaved.SpeedOptionsButton.Api.ToggleButton()
							lplr.Character.Humanoid.WalkSpeed = 0
						end
						for i = 1, 20 do
							if i == 20 then
								lplr.Character.HumanoidRootPart:PivotTo(lplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 23, 0))
								task.wait(0.1)
								lplr.Character.HumanoidRootPart.Anchored = true
							else
								lplr.Character.HumanoidRootPart:PivotTo(lplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0))
								task.wait(0.02)
							end
						end
					end
				end)) 
				table.insert(autohide.Connections, workspace.ChildRemoved:Connect(function(ent)
					if ent.Name:lower():find('rush') or ent.Name:lower():find('ambush') or ent.Name:find('A60') or ent.Name:find('A120') then
						lplr.Character.HumanoidRootPart.Anchored = false
						vape.ObjectsThatCanBeSaved.SpeedOptionsButton.Api.ToggleButton()
						lplr.Character.Humanoid.WalkSpeed = 0
						task.wait(0.05)
						lplr.Character.HumanoidRootPart.CFrame = oldpos
					end
				end))
			else
				lplr.Character.HumanoidRootPart.Anchored = false
			end
		end
	})
end)

run(function()
	local instaprompt = {}
	instaprompt = api.utility.CreateOptionsButton({
		Name = 'InstantInteract',
		Function = function(call)
			if call then
				table.insert(instaprompt.Connections, promptservice.PromptButtonHoldBegan:Connect(function(v)
					fireproximityprompt(v)
				end))
			end
		end
	})
end)

run(function()
	local phase = {}
	local phasetoggle = {}
	phase = api.blatant.CreateOptionsButton({
		Name = 'Phase',
		Function = function(call)
			if call then
				task.spawn(function()
					if not phasetoggle.Enabled then
						repeat
							task.wait()
						until inputservice:IsKeyDown(Enum.KeyCode[phase.Keybind ~= '' and phase.Keybind or 'V']) == false
						if phase.Enabled then
							phase.ToggleButton()
						end
					end
				end)
				lplr.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 10, 0)
				lplr.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 10, 0)
				if isEnabled('Speed') then
					vape.ObjectsThatCanBeSaved.SpeedOptionsButton.Api.ToggleButton()
				end
				workspace.Gravity = 0
			else
				vape.ObjectsThatCanBeSaved.SpeedOptionsButton.Api.ToggleButton()
				workspace.Gravity = 192
			end
		end
	})
	phasetoggle = phase.CreateToggle({
		Name = 'Toggle',
		Function = void
	})
end)

run(function()
	local FieldOfView = {Enabled = false}
	local FieldOfViewZoom = {Enabled = false}
	local FieldOfViewValue = {Value = 70}
	local fieldofviewexceptions = {}
	local fieldofviewnoshake = {}
	local oldfov
	FieldOfView = api.render.CreateOptionsButton({
		Name = "FOVChanger",
		Function = function(callback)
			if callback then
				oldfov = camera.FieldOfView
				if FieldOfViewZoom.Enabled then
					task.spawn(function()
						repeat
							task.wait()
						until inputservice:IsKeyDown(Enum.KeyCode[FieldOfView.Keybind ~= "" and FieldOfView.Keybind or "C"]) == false
						if FieldOfView.Enabled then
							FieldOfView.ToggleButton(false)
						end
					end)
				end
				local tweenserv = tween:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {FieldOfView = FieldOfViewValue.Value})
				tweenserv:Play()
				tweenserv.Completed:Wait()	 
				table.insert(FieldOfView.Connections, runservice.RenderStepped:Connect(function()
					camera.FieldOfView = FieldOfViewValue.Value
				end))
			else
				local tween = tween:Create(camera, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {FieldOfView = oldfov})
				task.spawn(function()
					repeat
						if not tween then break end
						camera.FieldOfView = FieldOfViewValue.Value
						task.wait(0)
					until (not tween)
				end)
				task.spawn(function()
					repeat task.wait() until not #FieldOfView.Connections == 0
					tween:Play()
					tween.Completed:Wait()
					tween = nil
				end)
			end
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Function = function(val) end
	})
	FieldOfViewZoom = FieldOfView.CreateToggle({
		Name = "Zoom",
		Function = void,
		HoverText = "optifine zoom lol"
	})
end)

run(function()
	local fastinteract = {}
	local fastinteractminecart = {}
	local fastinteractbook = {}
	local fastinteractbreaker = {}
	local fastinteractvalue = {}
	fastinteract = api.utility.CreateOptionsButton({
		Name = 'FastInteract',
		Function = function(idk)
			if idk then
				table.insert(fastinteract.Connections, promptservice.PromptTriggered:Connect(function(p)
					if p.HoldDuration == 0 then
						if p.Name == 'PushPrompt' and fastinteractminecart.Enabled then
							getconnections(promptservice.PromptTriggered)[1]:Disable()
							task.wait()
							for i = 1, fastinteractvalue.Value do
								fireproximityprompt(p)
							end
							task.wait()
							getconnections(promptservice.PromptTriggered)[1]:Enable()
						elseif p.Name == 'ActivateEventPrompt' and p.Parent.Name == 'LiveHintBook' and fastinteractbook.Enabled then
							getconnections(promptservice.PromptTriggered)[1]:Disable()
							task.wait()
							for i = 1, fastinteractvalue.Value do
								fireproximityprompt(p)
							end
							task.wait()
							getconnections(promptservice.PromptTriggered)[1]:Enable()
						elseif p.Name == 'ActivateEventPrompt' and p.Parent.Name == 'LiveBreakerPolePickup' and fastinteractbreaker.Enabled then
							getconnections(promptservice.PromptTriggered)[1]:Disable()
							task.wait()
							for i = 1, fastinteractvalue.Value do
								fireproximityprompt(p)
							end
							task.wait()
							getconnections(promptservice.PromptTriggered)[1]:Enable()
						end
					end
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
	local promptreach = {}
	local promptreachmultiplier = {}
	promptreach = api.utility.CreateOptionsButton({
		Name = 'PromptReach',
		Function = function(call)
			if call then
				table.insert(Reach.Connections, Workspace.CurrentRooms.DescendantAdded:Connect(function(v)
					if v.ClassName and not table.find(storage.ignore, v.Name) then
						v.MaxActivationDistance *= promptreachmultiplier
					end
				end))
			end
		end
	})
	promptreachmultiplier = promptreach.CreateSlider({
		Name = 'Multiplier',
		Function = void,
		Min = 1,
		Max = 10,
		Default = 2
	})
end)

run(function()
	local NoCamShake = {}
	NoCamShake = api.render.CreateOptionsButton({
		Name = 'No Camera Shake',
		Function  = function(call)
			if call then
				table.insert(NoCamShake.Connections, runservice.RenderStepped:Connect(function()
					require(maingame).fovtarget = camera.FieldOfView
					require(maingame).csgo = CFrame.new()
				end))
			end
		end
	})
end)

run(function()
	local Jump = {}
	Jump = api.utility.CreateOptionsButton({
		Name = 'Enable Jump',
		Function = function(callback)
			if callback then
				lplr.Character:SetAttribute('CanJump', true)
			else
				lplr.Character:SetAttribute('CanJump', false)
			end
		end
	})
end)
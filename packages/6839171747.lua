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
   CustomModules/6839171747.lua (Doors) - Maxlasertech & Selunariorium          
   https://renderintents.lol                                                                                                                                                                                                                                                                     
]]

local getservice = function(serv)
    return game.GetService(game, serv)
end
local vape = shared.GuiLibrary
local players = getservice('Players');
local lplr = players.LocalPlayer
local textservice = getservice('TextService');
local inputservice = getservice('UserInputService');
local runservice = getservice('RunService');
local teleport = getservice('TeleportService');
local tween = getservice('TweenService');
local collection = getservice('CollectionService');
local httpservice = getservice('HttpService');
local replicatedstorage = getservice('ReplicatedStorage');
local camera = workspace.Camera or Instance.new('Camera', workspace)
local mainui = lplr.PlayerGui:WaitForChild('MainUI')
local init = mainui:WaitForChild('Initiator')
local maingame = init:WaitForChild('Main_Game')
local remotelistener = maingame:WaitForChild('RemoteListener')

local api = {
    combat = vape.ObjectsThatCanBeSaved.CombatWindow.Api,
    blatant = vape.ObjectsThatCanBeSaved.BlatantWindow.Api,
    render = vape.ObjectsThatCanBeSaved.RenderWindow.Api,
    exploit = vape.ObjectsThatCanBeSaved.ExploitWindow.Api,
    utility = vape.ObjectsThatCanBeSaved.UtilityWindow.Api,
    world = vape.ObjectsThatCanBeSaved.WorldWindow.Api
}

local storage = {
    prompts = {},
    connections = {},
    esps = {},
    currentkey = nil
}

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
    label.TextSize = 19
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
                code[v.ImageRectOffset.X .. ' ' .. v.ImageRectOffset.Y] = {tonumber(v.Name), '_'}
            end
        end
        for i, image in lplr.PlayerGui.PermUI.Hints:GetChildren() do
            if image.Name == 'Icon' then
                if code[image.ImageRectOffset.X .. ' ' .. image.ImageRectOffset.Y] then
                    code[image.ImageRectOffset.X .. ' ' .. image.ImageRectOffset.Y][2] = image.TextLabel.Text
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
    return {}
end

vape.SelfDestructEvent.Event:Once(function()
    for i,v in storage.connections do
        pcall(function() v:Disconnect() end)
    end
end)

for i,v in workspace.CurrentRooms:GetDescendants() do
    if v.Name:lower() == 'keyobtain' then
        storage.currentkey = v
    end
end
table.insert(storage.connections, workspace.CurrentRooms.DescendantAdded:Connect(function(v)
    task.wait(1)
    if v.Name == 'KeyObtain' then
        storage.currentkey = v
    elseif v.Name:find('Key') then
        print(`{v.Name} :(`)
    end
end))
table.insert(storage.connections, workspace.CurrentRooms.DescendantRemoving:Connect(function(v)
    if v.Name:lower() == 'keyobtain' then
        storage.currentkey = nil
    end
end))

local getwardrobe = function()

end

vape.RemoveObject('SilentAimOptionsButton')
vape.RemoveObject('ReachOptionsButton')
vape.RemoveObject('MouseTPOptionsButton')
vape.RemoveObject('AutoClickerOptionsButton')
vape.RemoveObject('SpiderOptionsButton')
vape.RemoveObject('PhaseOptionsButton')
vape.RemoveObject('LongJumpOptionsButton')
vape.RemoveObject('HitBoxesOptionsButton')
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
                clone = collision:Clone()
                clone.CanCollide = false
                clone.Massless = true
                if clone:FindFirstChild('CollisionCrouch') then
                    clone.CollisionCrouch:Remove()
                end
                clone.Parent = lplr.Character
                actick = tick()
                if NoSlow.Enabled then
					lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(math.huge,0,0,0,0)
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
                        print('yes')
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
                    local code = table.concat(getpadlockcode(tool))
                    local output, count = code:gsub('_', 'x')
                    if autoenter.Enabled then
                        replicatedstorage.RemotesFolder.PL:FireServer(code)
                    end
                    print(count)
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
	local doorreach = {}
	local currentRoom = replicatedstorage:WaitForChild('GameData'):WaitForChild("LatestRoom")
	doorreach = api.utility.CreateOptionsButton({
		Name = 'DoorReach',
		Function = function(call)
			if call then
				repeat
					for i,v in workspace.CurrentRooms:GetChildren() do
						local room = v[currentRoom.Value]:FindFirstChild('Door')
						if room and room:FindFirstChild('ClientOpen') then
							room:FindFirstChild('ClientOpen'):FireServer()
						end
					end
					task.wait()
				until (not doorreach.Enabled)
			end
		end
	})
end)

run(function()
	local anticliententity = {}
	local screech = {}
	local a90 = {}
	anticliententity = api.utility.CreateOptionsButton({
		Name = 'AntiClientEntities',
		Function = function(call)
			if call then
				if screen.Enabled then
					local psst = remotelistener.Modules:FindFirstChild('Screech', true)
					if psst then
						psst.Name = 'OldScreech'
					end
				else
					local psst = remotelistener.Modules:FindFirstChild('OldScreech', true)
					if psst then
						psst.Name = 'Screech'
					end
				end
				if a90.Enabled then
					local aaa = remotelistener.Modules:FindFirstChild('A90', true)
					if aaa then
						aaa.Name = 'OldA90'
					end
				else
					local aaa = remotelistener.Modules:FindFirstChild('OldA90', true)
					if aaa then
						aaa.Name = 'A90'
					end
				end
			end
		end
	})
	screech = anticliententity.CreateToggle({
		Name = 'Anti Screech',
		Function = void,
		Default = true
	})
	a90 = anticliententity.CreateToggle({
		Name = 'Anti A90',
		Function = void,
		Default = true
	})
end)

run(function()
    local autocollect = {}
    local autocollectkey = {}
    local autocollectbook = {}
    autocollect = api.utility.CreateOptionsButton({
        Name = 'AutoCollect',
        Function = function(call)
            if call then
                table.insert(autocollect.Connections, runservice.Stepped:Connect(function()
                    if workspace.CurrentRooms:FindFirstChild('50') and autocollectbook.Enabled then
                        for i,v in workspace.CurrentRooms:GetDescendants() do
                            if v.Name == 'LiveHintBook' then
                                fireproximityprompt(v:FindFirstChildWhichIsA('ProximityPrompt'))
                            end
                        end
                    end
                    local key = storage.currentkey
                    if (key ~= nil and autocollectkey.Enabled) then
                        local part = key:FindFirstChildWhichIsA('Part')
                        local mag 
                        if part ~= nil then
                            mag = (lplr.Character.HumanoidRootPart.Position - part.Position).Magnitude
                        else
                            if key.Parent == 'DrawerContainer' then
                                fireproximityprompt(key.Parent.Knobs:FindFirstChildWhichIsA('ProximityPrompt'))
                                task.wait(0.1)
                            end
                            fireproximityprompt(key:FindFirstChildWhichIsA('ProximityPrompt'))
                        end
                        if mag < 10 then
                            if key.Parent.Name == 'DrawerContainer' then
                                fireproximityprompt(key.Parent.Knobs:FindFirstChildWhichIsA('ProximityPrompt'))
                                task.wait(0.1)
                            end
                            fireproximityprompt(key:FindFirstChildWhichIsA('ProximityPrompt'))
                        end
                    end
                end))
            end
        end
    })
    autocollectbook = autocollect.CreateToggle({
        Name = 'Book',
        Function = void
    })
    autocollectkey = autocollect.CreateToggle({
        Name = 'Key',
        Function = void
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
                        for i = 1, 20 do
                            lplr.Character.HumanoidRootPart:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                        task.wait(0.05)
                        end
                        lplr.Character.HumanoidRootPart.Anchored = true
                    end
                end)) 
                table.insert(autohide.Connections, workspace.ChildRemoved:Connect(function(ent)
                    if ent.Name:lower():find('rush') or ent.Name:lower():find('ambush') or ent.Name:find('A60') or ent.Name:find('A120') then
                        lplr.Character.HumanoidRootPart.Anchored = false
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
-- by selu and maxlaser
local getservice = function(serv)
	return game.GetService(game, serv)
end
local vape = shared.GuiLibrary
local players = getservice('Players');
local lplr = players.LocalPlayer
local textservice = getservice('TextService');
local inputservice = getservice('UserInputService');
local runservice = getservice('RunService');
local teleport = getservice('TeleportService');
local tween = getservice('TweenService');
local collection = getservice('CollectionService');
local httpservice = getservice('HttpService');
local replicatedstorage = getservice('ReplicatedStorage');
local camera = workspace.Camera or Instance.new('Camera', workspace)
local MainUI = lplr.PlayerGui:WaitForChild('MainUI')
local Init = MainUI:WaitForChild('Initiator')
local MainGame = Init:WaitForChild('Main_Game')
local RemoteListener = MainGame:WaitForChild('RemoteListener')
local api = {
	combat = vape.ObjectsThatCanBeSaved.CombatWindow.Api,
	blatant = vape.ObjectsThatCanBeSaved.BlatantWindow.Api,
	render = vape.ObjectsThatCanBeSaved.RenderWindow.Api,
	exploit = vape.ObjectsThatCanBeSaved.ExploitWindow.Api,
	utility = vape.ObjectsThatCanBeSaved.UtilityWindow.Api,
	world = vape.ObjectsThatCanBeSaved.WorldWindow.Api
}

local storage = {
	prompts = {},
	connections = {},
	esps = {}
}

local createesp = function(parent)
	local highlight = Instance.new('Highlight', parent)
	highlight.FillColor = Color3.new(1, 0, 0)
	highlight.FillTransparency = 0.4
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	table.insert(storage.esps, highlight)
end

local createtag = function(tag, parent)
	local gui = Instance.new('BillboardGui', parent)
	gui.Size = UDim2.new(0, 200, 0, 50)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true

	local label = Instance.new('TextLabel', gui)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = tag
	label.TextSize = 16
	label.Font = Enum.Font.Gotham
	label.BackgroundTransparency = 1
	table.insert(storage.esps, gui)
end

local getpadlockcode = function(tool)
	if tool and tool:FindFirstChild('UI') then
		local code = {}
		for i,v in tool.UI:GetChildren() do
			if v.ClassName == 'ImageLabel' and tonumber(v.Name) then
				code[v.ImageRectOffset.X .. ' ' .. v.ImageRectOffset.Y] = {tonumber(v.Name), '_'}
			end
		end
		for _, image in lplr.PlayerGui.PermUI.Hints:GetChildren() do
			if image.Name == 'Icon' then
				if code[image.ImageRectOffset.X .. ' ' .. image.ImageRectOffset.Y] then
					code[`{image.ImageRectOffset.X} {image.ImageRectOffset.Y}`][2] = image.TextLabel.Text
				end
			end
		end
		local actualcode = {}
		for i,v in code do
			actualcode[v[1]] = v[2]
		end
		return actualcode
	end

	return {}
end

for i, item in workspace.CurrentRooms:GetDescendants() do
	if item.ClassName == 'ProximityPrompt' then
		table.insert(storage.prompts, item)
	end
end
table.insert(storage.connections, workspace.CurrentRooms.DescendantAdded:Connect(function(item)
	if item ~= nil and item.ClassName == 'ProximityPrompt' then
		table.insert(storage.prompts, item)
	end
end))

vape.RemoveObject('SilentAimOptionsButton')
vape.RemoveObject('ReachOptionsButton')
vape.RemoveObject('MouseTPOptionsButton')
vape.RemoveObject('PhaseOptionsButton')
vape.RemoveObject('AutoClickerOptionsButton')
vape.RemoveObject('SpiderOptionsButton')
vape.RemoveObject('LongJumpOptionsButton')
vape.RemoveObject('HitBoxesOptionsButton')
vape.RemoveObject('KillauraOptionsButton')
vape.RemoveObject('ChamsOptionsButton')
vape.RemoveObject('TriggerBotOptionsButton')
vape.RemoveObject('AutoLeaveOptionsButton')
vape.RemoveObject('FlyOptionsButton')
vape.RemoveObject('ClientKickDisablerOptionsButton')
vape.RemoveObject('NameTagsOptionsButton')
vape.RemoveObject('SafeWalkOptionsButton')
vape.RemoveObject('BlinkOptionsButton')
vape.RemoveObject('AntiVoidOptionsButton')
vape.RemoveObject('SongBeatsOptionsButton')
vape.RemoveObject('TargetStrafeOptionsButton')
run(function()
	local anticheatbypass = {}
	local noslow = {}
	local actick
	local collision = lplr.Character:WaitForChild('Collision', 3)
	anticheatbypass = api.utility.CreateOptionsButton({
		Name = 'AntiCheatBypass',
		Function = function(call)
			if call then
				if not collision then
					anticheatbypass.ToggleButton()
					return errorNotification('Render', 'Clone not found.', 5)
				end
				clone = collision:Clone()
				clone.CanCollide = false
				clone.Massless = true
				if clone:FindFirstChild('CollisionCrouch') then
					clone.CollisionCrouch:Remove()
				end
				clone.Parent = lplr.Character
				actick = tick()
				if noslow then
					lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(math.huge,0,0,0,0)
				else
					lplr.Character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.7, 0, 1, 1)
				end
				table.insert(anticheatbypass.Connections, runservice.Stepped:Connect(function()
					if isAlive() then
						if tick() - actick >= 0.2 then
							collision.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
							collision:FindFirstChild('CollisionCrouch').CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0)
							collision:FindFirstChild('CollisionCrouch').Massless = math.huge
							collision.Massless = not collision.Massless
							actick = tick()
						end
					end
				end))
			else
				collision:FindFirstChild('CollisionCrouch').CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
				collision.Massless = not collision.Massless
				collision:FindFirstChild('CollisionCrouch').Massless = 0
				clone:Remove()
			end
		end
	})
	noslow = anticheatbypass.CreateToggle({
		Name = 'No Slowdown',
		HoverText = 'only works with walkspeed',
		Function = void,
		Default = false 
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
						warningNotification('Render', `{v.Name} is gone now.`, 5)
					end
				end)) 
			end
		end
	})
end)

run(function()
	local autocollect = {}
	local alreadyopened = {}
	autocollect = api.utility.CreateOptionsButton({
		Name = 'AutoCollect',
		Function = function(call)
			if call then
				table.insert(autocollect.Connections, runservice.Stepped:Connect(function()
					for i, item in storage.prompts do
						local part = item.Parent:FindFirstChildWhichIsA('Part')
						if not part then return end
						local mag = (part.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
						if mag <= 11 then
							if alreadyopened[item] then
								print(item.Parent.Name .. ' is already opened')
								return
							else
								print('fouund item')
								pcall(function() fireproximityprompt(item) end)
								alreadyopened[item] = true
								
							end
						else
							print('item not in range.')
						end
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
	local espbook = {}
	local espbreaker = {}
	esp = api.render.CreateOptionsButton({
		Name = 'Highlight',
		Function = function(call)
			if call then
				for i,v in workspace.CurrentRooms:GetDescendants() do
					if v.Name == 'RoomExit' and espdoor.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Door', v)
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
					if v.Name:lower() == 'imstuff' and espbreaker.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Breaker', v)
						end
					end
					if v.Name:lower() == 'cover2' and espbreaker.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Book', v)
						end
					end
					if v.Name:lower() == 'fusemodel' and espfuse.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Fuse', v)
						end
					end
				end
				table.insert(esp.Connections, workspace.CurrentRooms.DescendantAdded:Connect(function(v)
					if v.Name == 'RoomExit' and espdoor.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Door', v)
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
					if v.Name:lower() == 'imstuff' and espbreaker.Enabled then
						pcall(createesp, v)
						if esptag.Enabled then
							pcall(createtag, 'Breaker', v)
						end
					end
					if v.Name:lower() == 'cover2' and espbreaker.Enabled then
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
	espbreaker = esp.CreateToggle({
		Name = 'Breaker',
		Function = void
	})
	espbook = esp.CreateToggle({
		Name = 'Book',
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
				autopadlock.ToggleButton()
				local tool = player.Character:FindFirstChildWhichIsA('Tool')
				if tool and tool.Name:find('LibraryHintPaper') then
					local code = table.concat(getpadlockcode(tool))
					local output, count = code:gsub('_', 'x')
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
	local doorreach = {}
	local lr = ReplicatedStorage:WaitForChild('GameData'):WaitForChild("LatestRoom")
	doorreach = api.utility.CreateOptionsButton({
		Name = 'DoorReach',
		Function = function(call)
			if call then
				repeat
					for i,v in workspace.CurrentRooms:GetChildren() do
						local room = v[lr.Value]:FindFirstChild('Door')
						if room and room:FindFirstChild('ClientOpen') then
							room:FindFirstChild('ClientOpen'):FireServer()
						end
					end
					task.wait()
				until (not doorreach.Enabled)
			end
		end
	})
end)

run(function()
	local anticliententity = {}
	local screech = {}
	local a90 = {}
	anticliententity = api.utility.CreateOptionsButton({
		Name = 'Anti client entities',
		Function = function(call)
			if call then
				if screen.Enabled then
					local psst = RemoteListener:FindFirstChild('Screech', true)
					if psst then
						psst.Name = 'OldScreech'
					end
				else
					local psst = RemoteListener:FindFirstChild('OldScreech', true)
					if psst then
						psst.Name = 'Screech'
					end
				end
				if a90.Enabled then
					local aaa = RemoteListener:FindFirstChild('A90', true)
					if aaa then
						aaa.Name = 'OldA90'
					end
				else
					local aaa = RemoteListener:FindFirstChild('OldA90', true)
					if aaa then
						aaa.Name = 'A90'
					end
				end
			end
		end
	})
	screech = anticliententity.CreateToggle({
		Name = 'Anti Screech',
		Function = void,
		Default = true
	})
	a90 = anticliententity.CreateToggle({
		Name = 'Anti A90',
		Function = void,
		Default = true
	})
end)
run(function()
    local dupe = {}
    local hook
    dupe = api.exploit.CreateOptionsButton({
        Name = 'Dupe',
        Function = void,
        HoverText = 'Only works on floor 2!, drop item to start duping.'
    })
    hook = hookmetamethod(game, '__namecall', function(self, ...)
        local args = {...}
        if dupe.Enabled and workspace.CurrentRooms:FindFirstChild('100') and not checkcaller() and getnamecallmethod() == 'FireServer' and self == replicatedstorage.RemotesFolder.DropItem then
            local deathcf = lplr.Character.HumanoidRootPart.CFrame
            lplr.Character.Humanoid.Health = 0
            lplr.CharacterAdded:Wait()
            lplr.Character.HumanoidRootPart.CFrame = deathcf
            warningNotification('Render', 'sucessfully duped item', 1)
             hook(self, unpack(args))
        end
        return hook(self, ...)
    end)
end)
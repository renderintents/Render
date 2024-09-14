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
local collection = getservice('CollectionService');
local httpservice = getservice('HttpService');
local replicatedstorage = getservice('ReplicatedStorage');
local promptservice = getservice('ProximityPromptService');
local camera = workspace.Camera or Instance.new('Camera', workspace);
local mainui = lplr.PlayerGui:WaitForChild('MainUI');
local init = mainui:WaitForChild('Initiator');
local maingame = init:WaitForChild('Main_Game');
local remotelistener = maingame:WaitForChild('RemoteListener');

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
    lockers = {
        lootprompt = {}
    },
    connections = {},
    esps = {},
    keys = {},
    ongroundloot = {},
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
    if v.ClassName == 'Model' and v.Name == 'DrawerContainer' or v.Name == 'RolltopContainer' then
        print('yes')
        table.insert(storage.drawers, v)
        print('inserted')
    elseif v.Name == 'Locker_Small' then
        table.insert(storage.lockers, v)
    elseif v.Name == 'ModulePrompt' and v.Parent.Parent.Parent.Name == 'Locker_Small' or v.Name == 'ModulePrompt' and v.Parent.Parent.Name == 'Locker_Small' or v.Name == 'LootPrompt' and v.Parent.Parent.Name == 'Locker_Small' then
        print(v.Name)
        table.insert(storage.lockers.lootprompt, v)
    elseif v.ClassName == 'Model' and v.Name == 'KeyObtain' then
        table.insert(storage.keys, v:FindFirstChildWhichIsA('ProximityPrompt'))
    elseif v.ClassName == 'Model' and v:FindFirstChild('LootPrompt') then
        table.insert(storage.ongroundloot, v)
    end
end
table.insert(storage.connections, workspace.CurrentRooms.DescendantAdded:Connect(function(v)
    if v.ClassName == 'Model' and v.Name == 'DrawerContainer' or v.Name == 'RolltopContainer' then
        print('yes')
        table.insert(storage.drawers, v)
        print('inserted')
    elseif v.Name == 'Locker_Small' then
        table.insert(storage.lockers, v)
    elseif v.Name == 'ModulePrompt' and v.Parent.Parent.Parent.Name == 'Locker_Small' or v.Name == 'ModulePrompt' and v.Parent.Parent.Name == 'Locker_Small' or v.Name == 'LootPrompt' and v.Parent.Parent.Name == 'Locker_Small' then
        print(v.Name)
        table.insert(storage.lockers.lootprompt, v)
    elseif v.ClassName == 'Model' and v.Name == 'KeyObtain' then
        table.insert(storage.keys, v:FindFirstChildWhichIsA('ProximityPrompt'))
    elseif v.ClassName == 'Model' and v:FindFirstChild('LootPrompt') then
        table.insert(storage.ongroundloot, v)
    end
end))

table.insert(storage.connections, workspace.CurrentRooms.DescendantRemoving:Connect(function(v)
    for i, drawer in storage.drawers do
        if drawer == v then
            table.remove(storage.drawers, i)
        end
    end
    for i, locker in storage.lockers do
        if locker == v then
            table.remove(storage.lockers, i)
        end 
    end
    for i, key in storage.keys do
        if v.Name == 'KeyObtain' and key == v:FindFirstChildWhichIsA('ProximityPrompt') then
            table.remove(storage.keys, i)
        end
    end
    for i, loot in storage.lockers.lootprompt do
        if loot == v then
            table.remove(storage.lockers.lootprompt, i)
        end
    end
    for i, loot in storage.ongroundloot do
        if loot == v then
            table.remove(storage.ongroundloot, i)
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
        i:SetAttribute('Enabled', value)
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
                    if breakerbox and not breakerbox:GetAttribute('DreadReaction') then
                        breakerbox:SetAttribute('DreadReaction', true)
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
    local psst = {}
    local aaa = {}
    local halt = {}
    local antieye = {}
    local old
    anticliententity = api.utility.CreateOptionsButton({
        Name = 'AntiClientEntities',
        Function = function(call)
            if call then
                old = require(replicatedstorage.ClientModules.EntityModules.Shade).stuff
                if halt then
                    require(replicatedstorage.ClientModules.EntityModules.Shade).stuff = function() end
                end
                if psst.Enabled then
                    local ps = remotelistener.Modules:FindFirstChild('Screech')
                    if ps then
                        ps.Name = 'OldScreech'
                    end
                else
                    local ps = remotelistener.Modules:FindFirstChild('OldScreech')
                    if ps then
                        ps.Name = 'Screech'
                    end
                end
                if aaa.Enabled then
                    local a = remotelistener.Modules:FindFirstChild('A90')
                    if a then
                        a.Name = 'OldA90'
                    end
                else
                    local a = remotelistener.Modules:FindFirstChild('OldA90')
                    if a then
                        a.Name = 'A90'
                    end
                end
            else
                require(replicatedstorage.ClientModules.EntityModules.Shade).stuff = old
            end
        end
    })
    psst = anticliententity.CreateToggle({
        Name = 'AntiScreech',
        Function = void,
        Default = true
    })
    aaa = anticliententity.CreateToggle({
        Name = 'AntiA90',
        Function = void,
        Default = true
    })
    halt = anticliententity.CreateToggle({
        Name = 'Halt',
        Function = void,
        Default = true
    })
    antieye = anticliententity.CreateToggle({
        Name = 'AntiEye',
        Function = void,
        Default = true
    })
end)

run(function()
    local autocollect = {}
    local autocollectkey = {}
    local autocollectgold = {}
    local autocollectbook = {}
    local autocollectrange = {}
    local autocollectitem = {}
    autocollect = api.utility.CreateOptionsButton({
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
                        for i,v in storage.drawers do
                            local part = v:FindFirstChildWhichIsA('Part')
                            local mag = (lplr.Character.HumanoidRootPart.Position - part.Position).magnitude
                            if mag < autocollectrange.Value then
                                local knob = v.Knobs:FindFirstChildWhichIsA('ProximityPrompt')
                                task.wait(0.05)
                                if not knob:GetAttribute('Interactions') then
                                    fireproximityprompt(knob)
                                end
                                if v:FindFirstChild('GoldPile') and autocollectgold.Enabled then
                                    pcall(fireproximityprompt, v.GoldPile:FindFirstChildWhichIsA('ProximityPrompt'))
                                end
                                for i, moduleprompt in v:GetDescendants() do
                                    if moduleprompt.Name == 'ModulePrompt' and moduleprompt.Parent.Name ~= 'KeyObtain' and autocollectitem.Enabled or moduleprompt.Name == 'ModulePrompt' and moduleprompt.Parent.Name == 'KeyObtain' and autocollectkey.Enabled then
                                        fireproximityprompt(moduleprompt)
                                    end
                                end
                            end
                        end
                    end)
                    if autocollectkey.Enabled then
                        pcall(function()
                            for i,v in storage.keys do
                                local mag = (lplr.Character.HumanoidRootPart.Position - v.Parent.Hitbox.Position).magnitude
                                if mag < autocollectrange.Value then
                                    pcall(fireproximityprompt, v)
                                end
                            end
                        end)
                    end
                    pcall(function()
                        for i,v in storage.ongroundloot do
                            local mag = (lplr.Character.HumanoidRootPart.Position - v.Hitbox.Position).magnitude
                            if mag < autocollectrange.Value then
                                pcall(fireproximityprompt, v:FindFirstChild('LootPrompt')) 
                            end
                        end
                    end)
                    pcall(function()
                        for i,v in storage.lockers do
                            if type(v) ~= 'table' then
                                local mag = (lplr.Character.HumanoidRootPart.Position - v.Door.Position).magnitude
                                if mag < autocollectrange.Value then
                                    local prompt = v.Door.ActivateEventPrompt
                                    if not prompt:GetAttribute('Interactions') then
                                        fireproximityprompt(prompt)
                                    end
                                    for _, item in v:GetDescendants() do
                                        if item.ClassName == 'ProximityPrompt' and item.Name ~= 'ActivateEventPrompt' then
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
                                lplr.Character.HumanoidRootPart:PivotTo(lplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, -10, 0))
                                task.wait(0.1)
                                lplr.Character.HumanoidRootPart.Anchored = true
                            else
                                lplr.Character.HumanoidRootPart:PivotTo(lplr.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0))
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
	local instaprompt = {};
	instaprompt = api.utility.CreateOptionsButton({
		Name = 'InstantInteract',
		Function = function(call)
			if call then
				table.insert(instaprompt.Connections, promptservice.PromptButtonHoldBegan:Connect(function(v)
                    print(v.Name)
					if v.Name == 'PushPrompt' then
                        for i = 1,3 do
                            fireproximityprompt(v);
                        end
                    else
                        fireproximityprompt(v);
                    end
				end))
			end;
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
                table.insert(FieldOfView.Connections, runservice.RenderStepped:Connect(function()
                    if fieldofviewnoshake.Enabled then
                        require(maingame).csgo = CFrame.new()
                    end
                end))
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
                camera.FieldOfView = FieldOfViewValue.Value
			end
		end
	})
	FieldOfViewValue = FieldOfView.CreateSlider({
		Name = "FOV",
		Min = 30,
		Max = 120,
		Function = function(val) end,
        Default = 120
	})
    fieldofviewnoshake = FieldOfView.CreateToggle({
        Name = 'NoShake',
        Function = void,
        Default = true
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
    local fastinteractvalue = {}
    fastinteract = api.utility.CreateOptionsButton({
        Name = 'FastInteract',
        Function = function(idk)
            if idk then
                table.insert(fastinteract.Connections, promptservice.PromptTriggered:Connect(function(p)
                    print('hai')
                    if p.HoldDuration == 0 then
                        if p.Name == 'PushPrompt' and fastinteractminecart.Enabled then
                            getconnections(promptservice.PromptTriggered)[1]:Disable()
                            task.wait(0.5)
                            for i = 1, fastinteractvalue.Value do
                                if i == fastinteractvalue.Value then
                                    getconnections(promptservice.PromptTriggered)[1]:Enable()
                                else
                                    fireproximityprompt(p)
                                end
                                --task.wait(0)
                            end
                        elseif p.Name == 'ActivateEventPrompt' and p.Parent.Name == 'LiveHintBook' and book.Enabled then
                            getconnections(promptservice.PromptTriggered)[1]:Disable()
                            task.wait(0.5)
                            for i = 1, fastinteractvalue.Value do
                                if i == fastinteractvalue.Value then
                                    getconnections(promptservice.PromptTriggered)[1]:Enable()
                                else
                                    fireproximityprompt(p)
                                end
                                --task.wait(0)
                            end
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
        Max = 500,
        Default = 20
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
end)
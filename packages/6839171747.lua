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
        end,
        HoverText = 'Method from selunariorium.'
    })
end)

run(function()
    local entitynotifier = {}
    entitynotifier = api.utility.CreateOptionsButton({
        Name = 'EntityNotifier',
        Function = function(call)
            if call then
                table.insert(entitynotifier.Connections, workspace.ChildAdded:Connect(function(v)
                    if (v.ClassName == 'Model' and v.ClassName ~= 'Part') and v.Name:find('Rush') or v.Name:find('Ambush') or v.Name:find('Eyes') then
                        warningNotification('Render', `{v.Name} appeared!.`, 5)
                        if isEnabled('Highlight') then
                            pcall(createtag, v.Name, v)
                        end
                    end
                end)) 
                table.insert(entitynotifier.Connections, workspace.ChildRemoved:Connect(function(v)
                    if (v.ClassName == 'Model' and v.ClassName ~= 'Part') and v.Name:find('Rush') or v.Name:find('Ambush') or v.Name:find('Eyes') then
                        warningNotification('Render', `{v.Name} has disappeared.`, 5)
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
    local espentities = {}
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
                    if v.Name:lower():find('giggle') and espentities.Enabled then
                        pcall(createesp, v)
                        if esptag.Enabled then
                            pcall(createtag, 'Giggle', v)
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
    espgenerator = esp.CreateToggle({
        Name = 'Generator',
        Function = void
    })
    espentities = esp.CreateToggle({
        Name = 'Entities',
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
    doorreach = api.utility.CreateOptionsButton({
        Name = 'DoorReach',
        Function = function(call)
            if call then
                repeat
                    for i,v in workspace.CurrentRooms:GetChildren() do
                        v.Door:FindFirstChild('ClientOpen'):FireServer()
                    end
                    task.wait()
                until (not doorreach.Enabled)
            end
        end
    })
end)

run(function()
    local antiscreech = {}
    antiscreech = api.utility.CreateOptionsButton({
        Name = 'AntiScreech',
        Function = function(call)
            lplr.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules:FindFirstChild('Screech', not call)
        end
    })
end)
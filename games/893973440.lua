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
   CustomModules/893973440.lua (Flee the facility) - SystemXVoid/BlankedVoid and Maxlasertech            
   https://renderintents.xyz                                                                                                                                                                                                                                                                     
]]
local vape = shared.rendervape
local cloneref = cloneref or function(data) return data end
local getservice = function(service)
	return cloneref(game:FindService(service))
end
local players = getservice('Players')
local startergui = getservice('StarterGui')
local replicatedstorage = getservice('ReplicatedStorage')
local runservice = getservice('RunService')
local tweenservice = getservice('TweenService')
local lplr = players.LocalPlayer

local combat = vape.ObjectsThatCanBeSaved.CombatWindow
local blatant = vape.ObjectsThatCanBeSaved.BlatantWindow
local visual = vape.ObjectsThatCanBeSaved.RenderWindow
local exploit = vape.ObjectsThatCanBeSaved.ExploitWindow
local utility = vape.ObjectsThatCanBeSaved.UtilityWindow
local world = vape.ObjectsThatCanBeSaved.WorldWindow

local store = {
    currentmap = nil,
    started = false,
    players = {
        beast = nil
    },
    connections = {},
    computersValue = 0,
    status = 'GAME OVER',
    escaped = false
}

local storeupdate = function()
    store.computersValue = replicatedstorage.ComputersLeft.Value or 0
    store.currentmap = replicatedstorage.CurrentMap.Value ~= 'Nil' and replicatedstorage.CurrentMap.Value or nil
    store.started = replicatedstorage.IsGameActive.Value or false
    store.status = replicatedstorage.GameStatus.Value or 'GAME OVER'
    task.spawn(function()
        for i,v in players:GetPlayers() do
            if isAlive(v, true) then
                if v.Character:FindFirstChild('BeastPowers') then
                    store.players.beast = v
                end
            end
        end
    end)
    store.escaped = lplr.TempPlayerStatsModule.Escaped.Value
    if not store.started then
        store.players.beast = nil 
    end
end

pcall(storeupdate)

local isFinished = function(computer)
    local screen = computer:FindFirstChild('Screen')
    if not screen then return true end
    return screen.BrickColor == BrickColor.new("Dark green") and true or false
end

local isCaptured = function(plr)
    plr = plr or lplr
    return plr.TempPlayerStatsModule.Captured.Value and true or false
end 

table.insert(store.connections, runservice.Stepped:Connect(function()
    pcall(storeupdate)
end))

local getcomputer = function()
    if store.currentmap == nil then return end
    for i,v in store.currentmap:GetChildren() do
        if v.Name == 'ComputerTable' and not isFinished(v) then
            local beast = store.players.beast
            if beast ~= nil then
                local mag = (beast.Character.HumanoidRootPart.Position - v.Screen.Position).Magnitude
                local mag2 = (lplr.Character.HumanoidRootPart.Position - v.Screen.Position).Magnitude
                print(mag)
                if mag > 35 and mag2 <= 35 or mag2 >= 35 or mag > 35 then
                    return v
                end
            end
        end
    end
    return nil
end
local getcomputertrigger = function()
    local computer = getcomputer()
    local triggervalue = 3
    local string = tostring(triggervalue)
    if computer ~= nil then
        for i,v in players:GetPlayers() do
            if v ~= lplr and isAlive(v, true) and isAlive(lplr, true) then
                local mag = (v.Character.HumanoidRootPart.Position - computer:FindFirstChild(`ComputerTrigger{string}`).Position).Magnitude
                if mag <= 4 then
                    triggervalue -= 1
                end
                string = tostring(triggervalue)
            end
        end
        return computer:FindFirstChild('ComputerTrigger'.. string)
    end
    return nil
end

local getExit = function()
    for i,v in store.currentmap:GetChildren() do
        if v.Name == "ExitDoor" then
            local mag = (store.players.beast.Character.HumanoidRootPart.Position - v.ExitDoorTrigger.Position).Magnitude
            if mag >= 20 then
                return v
            end
        end
    end
    return nil
end


local getfreezepod = function(check, check2)
    if store.started then
        for i,v in store.currentmap:GetChildren() do
            if v.ClassName == 'Model' and v.Name == 'FreezePod' then
                if not check then
                    return
                elseif check and not check2 then
                    if v.PodTrigger.CapturedTorso.Value == nil then
                        return v
                    end
                elseif not check and check2 then
                    if v.PodTrigger.CapturedTorso.Value ~= nil then
                        return v
                    end
                end
            end
        end
    end
    return nil
end

local isBeast = function(plr)
    plr = plr or lplr
    return store.players.beast ~= plr and false or true
end

local getbeast = function(check)
    local beast = store.players.beast
    if beast == nil then return end
    if isAlive(beast, true) and isAlive(lplr, true) then
        if check then
            local mag = (beast.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
            if mag >= 35 then
                return beast
            end
        else
            return beast
        end
    end
    return nil
end

run(function()
    local antierror = {}
    antierror = exploit.Api.CreateOptionsButton({
        Name = 'AntiError',
        Function = function(call)
            if call then
                table.insert(antierror.Connections, runservice.Stepped:Connect(function()
                    replicatedstorage.RemoteEvent:FireServer('SetPlayerMinigameResult', true)       
                end))
            end
        end
    })
end)

run(function()
    local killaura = {}
    local killaurarange = {}
    killaura = blatant.Api.CreateOptionsButton({
        Name = 'Killaura',
        Function = function(call)
            if call then
                repeat
                    if isBeast() then
                        local target = GetTarget({radius = killaurarange.Value})
                        if target then
                            lplr.Character:FindFirstChild('Hammer'):Activate()
                            lplr.Character:FindFirstChild('Hammer').HammerEvent:FireServer('HammerHit', ent.Character.HumanoidRootPart)
                        end
                    end
                    task.wait()
                until (not killaura.Enabled)
            end
        end
    })
    killaurarange = killaura.CreateSlider({
        Name = 'Range',
        Function = void,
        Min = 1,
        Max = 17,
        Default = 17
    })
end)

run(function()
    local autointeract = {}
    autointeract = utility.Api.CreateOptionsButton({
        Name = 'AutoInteract',
        Function = function(call)
            if call then
                table.insert(autointeract.Connections, runservice.Stepped:Connect(function()
                    replicatedstorage.RemoteEvent:FireServer('Input', 'Action', true)
                end))
            end
        end
    })
end)

run(function()
    local noslow = {}
    noslow = blatant.Api.CreateOptionsButton({
        Name = 'NoSlow',
        Function = function(call)
            if call then
                table.insert(noslow.Connections, runservice.Stepped:Connect(function()
                    if isAlive() and lplr.Character.Humanoid.WalkSpeed <= 15 then
                        lplr.Character.Humanoid.WalkSpeed = 16
                    end
                end))
            end
        end
    })
end)

local antideathnotification = false
run(function()
    local antideath = {}
    local old
    antideath = exploit.Api.CreateOptionsButton({
        Name = 'AntiDeath',
        Function = function(call)
            if call then
                table.insert(antideath.Connections, runservice.Stepped:Connect(function()
                    if isBeast() or not isAlive() then return end
                    local beast = getbeast(true)
                    if beast then
                        old = lplr.Character.HumanoidRootPart.CFrame
                        lplr.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 100, 0)
                        if not antideathnotification then
                            antideathnotification = true
                            task.spawn(pcall, warningNotification, 'AntiDeath', 'the beast is near you ', 6)
                        end
                        if not isEnabled('AutoHack') then
                            task.delay(1.5, function()
                                lplr.Character.HumanoidRootPart.CFrame = old
                            end)
                        end
                    else
                        antideathnotification = false
                    end
                end))
            end
        end,
        HoverText = 'Automatically teleports you 100 studs away from the beast'
    })
end)

run(function()
    local autohack = {}
    local autohackspeed = {}
    local usejump = {}
    local tween = nil
    local oldtrigger = nil
    local jumptick = 0
    local currcomputer = nil
    autohack = utility.Api.CreateOptionsButton({
        Name = 'AutoHack',
        Function = function(call)
            if call then
                table.insert(autohack.Connections, runservice.Stepped:Connect(function()
                    if isBeast() then return end
                    local trigger = getcomputertrigger()
                    if trigger then
                        if not oldtrigger then
                            oldtrigger = trigger
                        end
                        if oldtrigger ~= trigger then
                            oldtrigger = trigger
                            tween:Cancel()
                        end
                        if jumptick >= 223 and usejump.Enabled then
                            if tween then 
                                tween:Cancel() 
                            end
                            lplr.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 10, 0)
                            jumptick = 0
                            task.wait(0.4)
                        elseif not usejump.Enabled then
                            jumptick = 0
                        end
                        if not tween and not antideathnotification then
                            if currcomputer ~= trigger or currcomputer == nil then
                                currcomputer = trigger
                                tween = tweenservice:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(4), {CFrame = trigger.CFrame + Vector3.new(50, 0, 0)})
                            end
                            if (trigger.Position - lplr.Character.PrimaryPart.Position).Magnitude >= 2.5 then
                                if tween then
                                    tween:Play()
                                    tween.Completed:Wait()
                                    tween = nil
                                    task.wait(2)
                                end
                                tween = tweenservice:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(autohackspeed.Value / 2), {CFrame = trigger.CFrame})
                                tween:Play()
                                tween.Completed:Wait()
                                tween = nil
                            end
                            jumptick += 1
                            tween = nil
                        end
                    end
                end))
            else
                if tween then
                    tween:Cancel()
                    tween = nil
                end
            end
        end,
        HoverText = 'JumpTick method by\n qwertytui'
    })
    autohackspeed = autohack.CreateSlider({
        Name = 'Tween Speed',
        Function = void,
        Min = 1,
        Max = 20,
        Default = 13
    })
    usejump = autohack.CreateToggle({
        Name = 'Use JumpTick',
        Function = void,
        Default = true
    })
end)
run(function()
    local autoescape = {}
    autoescape = blatant.Api.CreateOptionsButton({
        Name = 'AutoEscape',
        Function = function(call)
            if call then
                table.insert(autoescape.Connections, runservice.Stepped:Connect(function()
                    if isBeast() then return end
                    if store.timer == 0 or store.status:lower():find('game over') or store.escaped then
                        lplr.Character.HumanoidRootPart.CFrame = CFrame.new(104,8,-417)
                        return
                    end
                    local exit = getExit()
                    local part = nil
                    if exit.Door.Hinge.Rotation.Y == 0 or exit.Door.Hinge.Rotation.Y == 90 or exit.Door.Hinge.Rotation.Y == 180 or exit.Door.Hinge.Rotation.Y == 270 then
                        part = exit.ExitDoorTrigger
                    end
                    if exit.Door.Hinge.Rotation.Y == -90 or exit.Door.Hinge.Rotation.Y == -180 or exit.Door.Hinge.Rotation.Y == -270 then
                        part = exit.ExitDoorTrigger
                    end
                    if part then
                        tweenservice:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(10), {CFrame = part.CFrame}):Play()
                    end
                end))
            end
        end,
        HoverText = 'Automatically escape for you after all\n computers is finished.'
    })
end)
run(function()
    local antiragdoll = {}
    antiragdoll = exploit.Api.CreateOptionsButton({
        Name = 'AntiRagdoll',
        Function = function(call)
            if call then
                table.insert(antiragdoll.Connections, runservice.Stepped:Connect(function()
                    lplr.TempPlayerStatsModule.Ragdoll.Value = false
                end))
            end
        end,
        ExtraText = function()
            return 'Value'
        end
    })
end)

run(function()
    local autocapture = {}
    autocapture = blatant.Api.CreateOptionsButton({
        Name = 'AutoCapture',
        Function = function(call)
            if call then
                repeat
                    local pod = getfreezepod(false, true)
                    if pod and isBeast() and lplr.Character:FindFirstChild('Part') then
                        local old = lplr.Character.HumanoidRootPart.CFrame
                        lplr.Character.HumanoidRootPart.CFrame = pod.PodTrigger.CFrame
                        task.wait(0.5)
                        lplr.Character.HumanoidRootPart.CFrame = old
                    end
                    task.wait()
                until (not autocapture.Enabled)
            end
        end
    })
end)

run(function()
    local autorope = {}
    autorope = blatant.Api.CreateOptionsButton({
        Name = 'AutoRope',
        Function = function(call)
            if call then
                repeat
                    local target = GetTarget({radius = 18})
                    if isBeast() and target.RootPart then
                        lplr.Character:FindFirstChild('Hammer').HammerEvent:FireServer('HammerTieUp', target.RootPart, lplr.Character.HumanoidRootPart.Position)
                    end
                    task.wait(1)
                until (not autorope.Enabled)
            end
        end
    })
end)



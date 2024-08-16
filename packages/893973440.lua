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
local vape = shared.GuiLibrary;
local cloneref = cloneref or function(data) return data end;
local getservice = function(service)
	return cloneref(game:FindService(service))
end;
local players = getservice('Players');
local startergui = getservice('StarterGui');
local replicatedstorage = getservice('ReplicatedStorage');
local runservice = getservice('RunService');
local tweenservice = getservice('TweenService');
local lplr = players.LocalPlayer;

local combat = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world = vape.ObjectsThatCanBeSaved.WorldWindow;

local store = {
    currentmap = nil,
    started = false,
    players = {
        beast = nil,
        allpeople = 1
    },
    status = '',
    escaperooms = {},
    connections = {},
    computers = {},
    computersValue = 0,
    status = 0,
    escaped = false
};

local storeupdate = function()
    store.computersValue = replicatedstorage.ComputersLeft.Value or 0
    store.currentmap = replicatedstorage.CurrentMap.Value ~= 'Nil' and replicatedstorage.CurrentMap.Value or nil;
    store.started = replicatedstorage.IsGameActive.Value or false;
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
end;

pcall(storeupdate);

local isFinished = function(computer)
    return computer.Screen.BrickColor == BrickColor.new("Dark green") and true or false;
end;

local isCaptured = function(plr)
    plr = plr or lplr;
    return plr.TempPlayerStatsModule.Captured.Value and true or false;
end 

table.insert(store.connections, runservice.Stepped:Connect(function()
    pcall(storeupdate);
end))

table.insert(store.connections, runservice.Stepped:Connect(function()
    if not store.started and #store.computers > 0 then
        for i,v in store.computers do
            table.remove(store.computers, i);
        end;
    end;
end))

local getcomputer = function()
    for i,v in store.currentmap:GetChildren() do
        if v.Name == 'ComputerTable' and not isFinished(v) then
            local beast = store.players.beast
            if beast ~= nil then
                local mag = (beast.Character.HumanoidRootPart.Position - v.Screen.Position).Magnitude
                local mag2 = (lplr.Character.HumanoidRootPart.Position - v.Screen.Position).Magnitude
                if mag <= 25 and mag2 >= 25 or mag2 >= 25 or mag <= 25 then
                    return v
                end
            end
        end
    end
    return nil
end
local getcomputertrigger = function()
    local computer = getcomputer();
    local triggervalue = 3;
    local string = '3';
    if computer ~= nil then
        for i,v in players:GetPlayers() do
            if v ~= lplr and isAlive(v, true) and isAlive(lplr, true) then
                local mag = (v.Character.HumanoidRootPart.Position - computer:FindFirstChild(`ComputerTrigger{string}`).Position).Magnitude
                if mag <= 3.5 then
                    triggervalue -= 1
                end
                string = tostring(triggervalue)
            end
        end
        return computer:FindFirstChild('ComputerTrigger'.. string) or nil
    else
        return nil
    end
end

local getExit = function()
    for i,v in store.currentmap:GetChildren() do
        if v.Name == "ExitDoor" then
            local mag = (store.players.beast.Character.HumanoidRootPart.Position - v.ExitDoorTrigger.Position).Magnitude;
            if mag >= 20 then
                return v;
            end;
        end;
    end;
    return nil;
end;

local gettarget = function(dist)
    local target = nil;
    for i,v in players:GetPlayers() do
        if v ~= lplr and isAlive(v, true) and isAlive(lplr, true) then
            local mag = (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
            if not target and mag <= (dist or math.huge) then
                target = v
            elseif target then
                local newmag = (v.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
                if newmag <= (dist or math.huge) then
                    target = v
                end
            end
        end
    end
    return target
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

local getbeast = function(check)
    for i,v in players:GetPlayers() do
        if isAlive(v, true) and store.players.beast == v then
            if check then
                local mag = (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude;
                if mag <= 35 then
                    return v;
                end;
            else
                return v
            end
        end;
    end;
end;

local isBeast = function(plr)
    plr = plr or lplr
    return store.players.beast ~= plr and false or true
end

run(function()
    local antierror = {};
    antierror = exploit.Api.CreateOptionsButton({
        Name = 'AntiError',
        Function = function(call)
            if call then
                table.insert(antierror.Connections, runservice.Stepped:Connect(function()
                    replicatedstorage.RemoteEvent:FireServer('SetPlayerMinigameResult': string, true: boolean);               
                end))
            end;
        end;
    })
end)

run(function()
    local killaura = {};
    local killaurarange = {};
    killaura = blatant.Api.CreateOptionsButton({
        Name = 'Killaura',
        Function = function(call)
            if call then
                repeat
                    if isBeast() then
                        local target = gettarget(killaurarange.Value)
                        if target then
                            lplr.Character:FindFirstChild('Hammer'):Activate()
                            lplr.Character:FindFirstChild('Hammer').HammerEvent:FireServer('HammerHit', ent.Character.HumanoidRootPart)
                        end
                    end
                    task.wait()
                until (not killaura.Enabled)
            end;
        end;
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
    local autointeract = {};
    autointeract = utility.Api.CreateOptionsButton({
        Name = 'AutoInteract',
        Function = function(call)
            if call then
                table.insert(autointeract.Connections, runservice.Stepped:Connect(function()
                    replicatedstorage.RemoteEvent:FireServer('Input', 'Action', true);
                end))
            end;
        end;
    })
end)

run(function()
    local noslow = {};
    noslow = blatant.Api.CreateOptionsButton({
        Name = 'NoSlow',
        Function = function(call)
            if call then
                table.insert(noslow.Connections, runservice.Stepped:Connect(function()
                    if isAlive() and lplr.Character.Humanoid.WalkSpeed < 15 then
                        lplr.Character.Humanoid.WalkSpeed = 16;
                    end;
                end))
            end;
        end;
    })
end)

run(function()
    local antideath = {};
    local antideathbeastnear;
    local old;
    local antideathnotification = false;
    local looping = false;
    antideath = exploit.Api.CreateOptionsButton({
        Name = 'AntiDeath',
        Function = function(call)
            if call then
                table.insert(antideath.Connections, runservice.Stepped:Connect(function()
                    if isBeast() or not isAlive(lplr, true) then return end;
                    if not looping then
                        looping = true;
                        local beast = getbeast(true);
                        if beast and not antideathbeastnear then
                            old = lplr.Character.HumanoidRootPart.CFrame
                            lplr.Character.HumanoidRootPart.CFrame *= CFrame.new(0, 100, 0)
                            if not antideathnotification then
                                antideathnotification = true;
                                task.spawn(pcall, warningNotification, 'Render', `the beast ({beast.Name}) is near you `, 6);
                            end
                            task.spawn(function()
                                task.wait(1.5)
                                if not isEnabled('AutoHack') then 
                                    lplr.Character.HumanoidRootPart.CFrame = old;
                                end;
                            end)                  
                        else
                            antideathnotification = false;      
                        end;
                        looping = false;
                    end
                end))
            end;
        end,
        HoverText = 'Automatically teleports you 500 studs away from the beast',
        ExtraText = function()
            return 'Manual'
        end
    })
end)

--[[ ew
    run(function()
        local autohack = {};
        local istweening = false;
        local looping = false;
        local jumptick = 0;
        local ongoing = false;
        local tween
        autohack = utility.Api.CreateOptionsButton({
            Name = 'AutoHack',
            Function = function(call)
                if call then
                    table.insert(autohack.Connections, runservice.Stepped:Connect(function()
                        if store.players.beast == lplr then return end
                        if store.status:lower():find("computer") or store.status:lower():find("15 ") then
                            local computertrigger = getcomputertrigger()
                            task.spawn(function()
                                if not looping then
                                    looping = true;
                                    lplr.Character.HumanoidRootPart.Velocity = Vector3.zero
                                    if computertrigger and not istweening then
                                        jumptick += 1
                                        if tween then tween:Cancel() end
                                        local delay = math.random(11,12)
                                        tween = tweenservice:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(delay), {CFrame = computertrigger.CFrame});
                                        tween:Play()
                                        istweening = true;
                                        task.spawn(function()
                                            task.wait(delay - 3)
                                            tween:Cancel()
                                            lplr.Character.HumanoidRootPart.CFrame = computertrigger.CFrame
                                        end)
                                        tween.Completed:Wait();
                                        lplr.Character.HumanoidRootPart.CFrame = computertrigger.CFrame
                                        if jumptick > 249 and jumptick < 256 then
                                            lplr.Character.Humanoid.JumpPower = 40
                                            lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                        elseif jumptick > 257 then
                                            jumptick = 0
                                            lplr.Character.Humanoid.JumpPower = 36
                                        end
                                        lplr.Character.HumanoidRootPart.CFrame = computertrigger.CFrame;
                                        istweening = false;
                                    elseif not computertrigger then
                                        jumptick = 0;
                                    else
                                        istweening = false;
                                    end;
                                    looping = false;
                                end
                            end)
                        end;
                    end))
                end;
            end,
            HoverText = 'Automatically finishs the computer nearby.',
            ExtraText = function()
                return 'Tween'
            end
        })
    end)
]]
run(function()
    local autohack = {};
    local autohackspeed = {};
    local usejump = {};
    local tween;
    local oldtrigger = nil;
    local jumptick = 0;
    autohack = utility.Api.CreateOptionsButton({
        Name = 'AutoHack',
        Function = function(call)
            if call then
                table.insert(autohack.Connections, runservice.Stepped:Connect(function()
                    local trigger = getcomputertrigger();
                    if trigger then
                        if not oldtrigger then
                            oldtrigger = trigger
                        end;
                        if oldtrigger ~= trigger and tween then
                            tween:Cancel();
                        end;
                        jumptick += 1;
                        if not tween then
                            tween = tweenservice:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(math.random(7, autohackspeed.Value)), {CFrame = trigger.CFrame});
                            tween:Play();
                            tween.Completed:Wait()
                            tween = nil
                        end
                        if lplr.Character.HumanoidRootPart.CFrame ~= trigger.CFrame then
                            lplr.Character.HumanoidRootPart.CFrame = trigger.CFrame;
                        end;
                        if jumptick >= 257 and usejump.Enabled then
                            lplr.Character.Humanoid.JumpPower = 40
                            lplr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
                            lplr.Character.Humanoid.JumpPower = 36
                            jumptick = 0;
                        elseif not usejump.Enabled then
                            jumptick = 0;
                        end;
                    end
                end))
            end;
        end;
    })
    autohackspeed = autohack.CreateSlider({
        Name = 'Tween Speed',
        Function = void,
        Min = 8,
        Max = 20,
        Default = 19
    })
    usejump = autohack.CreateToggle({
        Name = 'Use JumpTick',
        Function = void,
        Default = true
    })
end)
run(function()
    local autoescape = {};
    autoescape = blatant.Api.CreateOptionsButton({
        Name = 'AutoEscape',
        Function = function(call)
            if call then
                table.insert(autoescape.Connections, runservice.Stepped:Connect(function()
                    if store.timer == 0 or store.status:lower():gsub('game over', nil) or store.escaped then
                        lplr.Character.HumanoidRootPart.CFrame = CFrame.new(104,8,-417);
                        return;
                    end
                    local exit = getExit();
                    local part = nil;
                    if exit.Door.Hinge.Rotation.Y == 0 or exit.Door.Hinge.Rotation.Y == 90 or exit.Door.Hinge.Rotation.Y == 180 or exit.Door.Hinge.Rotation.Y == 270 then
                        part = exit.ExitDoorTrigger;
                    end
                    if exit.Door.Hinge.Rotation.Y == -90 or exit.Door.Hinge.Rotation.Y == -180 or exit.Door.Hinge.Rotation.Y == -270 then
                        part = exit.ExitDoorTrigger;
                    end
                    if part ~= nil then
                        tweenservice:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(10), {CFrame = part.CFrame}):Play()
                    end
                end))
            end;
        end,
        HoverText = 'Automatically escape for you after all\n the computer is finished.'
    })
end)
run(function()
    local antiragdoll = {};
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
            return 'Instance'
        end
    })
end)

run(function()
    local autocapture = {};
    local old;
    autocapture = blatant.Api.CreateOptionsButton({
        Name = 'AutoCapture',
        Function = function(call)
            if call then
                repeat
                    local pod = getfreezepod(false, true);
                    if pod and not isBeast() or pod and lplr.Character:FindFirstChild('Part') then
                        old = lplr.Character.HumanoidRootPart.CFrame;
                        lplr.Character.HumanoidRootPart.CFrame = pod.PodTrigger.CFrame;
                        task.wait(0.5);
                        lplr.Character.HumanoidRootPart.CFrame = old;
                    end;
                    task.wait();
                until (not autocapture.Enabled)
            end;
        end;
    })
end)

run(function()
    local autorope = {};
    autorope = blatant.Api.CreateOptionsButton({
        Name = 'AutoRope',
        Function = function(call)
            if call then
                repeat
                    local target = gettarget(13);
                    if isBeast() and target then
                        lplr.Character:FindFirstChild('Hammer').HammerEvent:FireServer('HammerTieUp', target.Character['Right Leg'], lplr.Character.HumanoidRootPart.Position);
                    end;
                    task.wait(1);
                until (not autorope.Enabled)
            end;
        end;
    })
end)

--[[
run(function()
    local autorejoin = {};
    local teleported = false;
    autorejoin = utility.Api.CreateOptionsButton({
        Name = 'AutoRejoin',
        Function = function(call)
            if call then
                table.insert(autorejoin.Connections, runservice.Stepped:Connect(function()
                    if store.players.beast == lplr and not teleported then
                        teleported = true;
                        getservice("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, lplr);
                    end;
                end))
            end
        end
    })
end)
]]
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
   CustomModules/893973440.lua (flee the facility) - SystemXVoid/BlankedVoid, Qwertytui and Maxlasertech            
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
local newroot;
local oldroot;

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

local getbeast = function(dist)
    for i,v in players:GetChildren() do
        if v ~= lplr and isAlive(v, true) then
            local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if mag <= (dist or math.huge) then
                return v;
            end;
        end;
    end;
end;

local getcomputer = function()
    for i,v in store.currentmap:GetChildren() do
        if v.Name == 'ComputerTable' and not isFinished(v) then
            local beast = store.players.beast
            if beast ~= nil then
                local mag = (beast.Character.HumanoidRootPart.Position - v.Screen.Position).Magnitude
                if mag >= 25 then
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
                local mag = (v.Character.HumanoidRootPart.Position - computer['ComputerTrigger'.. string].Position).Magnitude
                if mag <= 4 then
                    triggervalue -= 1
                    print(triggervalue)
                end
                string = tostring(triggervalue)
            end
        end
        return computer:FindFirstChild('ComputerTrigger'.. string) or nil
    else
        return nil
    end
end

local getalltarget = function(dist)
    local ents = {}
    for i,v in players:GetPlayers() do
        if v ~= lplr and isAlive(v, true) and isAlive(lplr, true) then
            local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if mag >= (dist or math.huge) then
                table.insert(ents, {Character = v})
            end;
        end
    end
    return ents
end
local getneartarget = function(dist)
    for i,v in players:GetPlayers() do
        if v ~= lplr and isAlive(lplr, true) and isAlive(v, true) then
            local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if mag >= (dist or math.huge) then
                return v
            end
        end
    end
end

local getfreezepod = function(check)
    if store.started then
        for i,v in store.currentmap:GetChildren() do
            if v.ClassName == 'Model' and v.Name == 'FreezePod' then
                if not check then 
                    return v
                else
                    if v.PodTrigger.CapturedTorso.Value == nil then
                        return v
                    end
                end
            end
        end
    end
    return nil
end
local geteveryfreezepod = function(check)
    local pods = {};
    if store.started then
        for i,v in store.currentmap:GetChildren() do
            if v.ClassName == 'Model' and v.Name == 'FreezePod' then
                if not check then 
                    table.insert(pods, {pod = v})
                else
                    if v.PodTrigger.CapturedTorso.Value ~= nil then
                        table.insert(pods, {pod = v})
                    end
                end
            end
        end
    end
    return pods
end

createclone = function()
    repeat task.wait(.1) until isAlive(lplr, true)
    lplr.Character.Parent = game
    lplr.Character.HumanoidRootPart.Archivable = true
    oldroot = lplr.Character.HumanoidRootPart 
    newroot = oldroot:Clone()
    newroot.Parent = lplr.Character
    oldroot.Parent = workspace
    oldroot.Transparency = 0
    lplr.Character.PrimaryPart = newroot
    lplr.Character.Parent = workspace
end;

removeclone = function()
    oldroot.CFrame = newroot.CFrame
    oldroot.Transparency = 1
    lplr.Character.Parent = game
    oldroot.Parent = lplr.Character
    newroot.Parent = workspace
    lplr.Character.PrimaryPart = oldroot
    lplr.Character.Parent = workspace
    newroot:Remove()
    newroot = {} 
    oldroot = {}
end;

run(function()
    local antierror = {};
    antierror = exploit.Api.CreateOptionsButton({
        Name = 'AntiError',
        Function = function(call)
            if call then
                table.insert(antierror.Connections, runservice.Stepped:Connect(function()
                    replicatedstorage.RemoteEvent:FireServer('SetPlayerMinigameResult', true);               
                end))
            end;
        end;
    })
end)

run(function()
    local killaura = {};
    local killaurarange = {};
    local createbox = function(character)
        if not character:FindFirstChild('box') then
            local killaurabox = Instance.new('Part', plr.Character)
            killaurabox.Material = Enum.Material.Neon
            killaurabox.Transparency = 0.5
            killaurabox.Position = character.PrimaryPart.Position
            killaurabox.Color = Color3.fromRGB(0, 166, 253)
            killaurabox.CanCollide = false
            killaurabox.Name = 'box'
            killaurabox.Anchored = true
            killaurabox.Size = Vector3.new(4, 6, 4)
        end
    end
    killaura = blatant.Api.CreateOptionsButton({
        Name = 'Killaura',
        Function = function(call)
            if call then
                repeat
                    if store.players.beast == lplr then
                        local enemies = getalltarget(killaurarange.Value)
                        for i, ent in enemies do
                            print('test')
                            --pcall(createbox, lplr.Character)
                            lplr.Character:FindFirstChild('Hammer'):Activate()
                            lplr.Character:FindFirstChild('Hammer').HammerEvent:FireServer('HammerHit', ent.Character.HumanoidRootPart)
                        end
                    end
                    task.wait()
                until (not killaura.Enabled)
            else
                --[[
                      for i,v in players:GetPlayers() do
                    if isAlive(v, true) then
                       v.Character:FindFirstChild('box'):Remove()
                    end
                end
                ]]
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
    getactualbeast = function()
        for i,v in players:GetPlayers() do
            if isAlive(v, true) and v == store.players.beast then
                local mag = (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude;
                if mag <= 35 then
                    return v;
                end;
            end;
        end;
    end;
    local antideathbeastnear;
    local old;
    local antideathnotification = false;
    antideath = exploit.Api.CreateOptionsButton({
        Name = 'AntiDeath',
        Function = function(call)
            if call then
                table.insert(antideath.Connections, runservice.Stepped:Connect(function()
                    if store.players.beast == lplr or not isAlive(lplr, true) then return end;
                    local beast = getactualbeast();
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
                                old = {};
                            end;
                        end)                  
                    else
                        antideathnotification = false;      
                    end;
                end))
            end;
        end,
        HoverText = 'Automatically teleports you 500 studs away from the beast',
        ExtraText = function()
            return 'Manual'
        end
    })
end)

run(function()
    local autohack = {};
    local istweening = false;
    local looping = false;
    autohack = utility.Api.CreateOptionsButton({
        Name = 'AutoHack',
        Function = function(call)
            if call then
                task.spawn(function()
                    table.insert(autohack.Connections, runservice.Stepped:Connect(function()
                        if store.players.beast == lplr then return print('ur beast') end
                        if store.escaped then return print('u escaped') end
                        if store.status:lower():find("computer") or store.status:lower():find("15 ") then
                            if not looping then
                                looping = true;
                                local computertrigger = getcomputertrigger()
                                lplr.Character.HumanoidRootPart.Velocity = Vector3.zero
                                if computertrigger and not istweening then
                                    local tween = tweenservice:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(math.random(11,17)), {CFrame = computertrigger.CFrame});
                                    tween:Play()
                                    istweening = true;
                                    tween.Completed:Wait();
                                    lplr.Character.HumanoidRootPart.CFrame = computertrigger.CFrame;
                                    istweening = false;
                                else
                                    istweening = false;
                                end;
                                looping = false;
                                task.wait(4)
                            end
                        end;
                    end))
                end)
            end;
        end,
        HoverText = 'Automatically finishs the computer nearby.',
        ExtraText = function()
            return 'Tween'
        end
    })
end)

run(function()
    local autoescape = {};
    getExit = function()
        for i,v in store.currentmap:GetChildren() do
            if v.Name == "ExitDoor" then
                local mag = (store.players.beast.Character.HumanoidRootPart.Position - v.ExitDoorTrigger.Position).Magnitude;
                if mag >= 15 then
                    return v;
                end;
            end;
        end;
        return nil;
    end;
    autoescape = blatant.Api.CreateOptionsButton({
        Name = 'AutoEscape',
        Function = function(call)
            if call then
                table.insert(autoescape.Connections, runservice.Stepped:Connect(function()
                    if store.status:lower():find("exit") then
                        local exit = getExit();
                        local partTP = exit.ExitArea
                        speed = 3
                        if exit.Door.Hinge.Rotation.Y == 0 or exit.Door.Hinge.Rotation.Y == 90 or exit.Door.Hinge.Rotation.Y == 180 or exit.Door.Hinge.Rotation.Y == 270 then
                            partTP = exit.ExitDoorTrigger
                            speed = 0.65
                        end
                        if exit.Door.Hinge.Rotation.Y == -90 or exit.Door.Hinge.Rotation.Y == -180 or exit.Door.Hinge.Rotation.Y == -270 then
                            partTP = exit.ExitDoorTrigger
                            speed = 0.65
                        end
                        task.spawn(function()
                            task.wait(speed + 1)
                            if getbeast(15) == nil then
                                lplr.Character.HumanoidRootPart.CFrame = partTP.CFrame
                            end
                        end)
                        tweenservice:Create(lplr.Character.HumanoidRootPart, TweenInfo.new(speed), {CFrame = partTP.CFrame}):Play();
                    end;
                end))
            end;
        end;
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
            return getidentity() ~= 3 and 'ModuleScript' or 'Instance'
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
                    if store.players.beast ~= lplr then
                        local pods = geteveryfreezepod(true)
                        if #pods > 0 then
                            for i, pod in pods do
                                print(type(pod))
                                old = lplr.Character.HumanoidRootPart.CFrame;
                                lplr.Character.HumanoidRootPart.CFrame = pod.PodTrigger.CFrame;
                                task.wait(0.5);
                                lplr.Character.HumanoidRootPart.CFrame = old;
                            end
                        end
                    elseif store.players.beast == lplr then
                        local pod = getfreezepod(true);
                        if pod and lplr.Character:FindFirstChild('Part') then
                            old = lplr.Character.HumanoidRootPart.CFrame;
                            lplr.Character.HumanoidRootPart.CFrame = pod.PodTrigger.CFrame;
                            task.wait(0.5);
                            lplr.Character.HumanoidRootPart.CFrame = old;
                        end;
                    end;
                    task.wait();
                until (not autocapture.Enabled)
            end;
        end,
        ExtraText = function()
            return 'Character'
        end
    })
end)

run(function()
    local autorope = {};
    autorope = blatant.Api.CreateOptionsButton({
        Name = 'AutoRope',
        Function = function(call)
            if call then
                repeat
                    local target = getneartarget(13)
                    if store.players.beast == lplr then
                        lplr.Character:FindFirstChild('Hammer').HammerEvent:FireServer('HammerTieUp', target.Character['Right Leg'], lplr.Character.HumanoidRootPart.Position)
                    end
                    task.wait(1)
                until (not autorope.Enable)
            end
        end
    })
end)

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
                        print(teleported)
                        getservice("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, lplr)
                    end;
                end))
            end
        end
    })
end)
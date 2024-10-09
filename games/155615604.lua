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
   CustomModules/155615604.lua (Prison life) - Maxlasertech      
   https://renderintents.lol                                                                                                                                                                                                                                                                     
]]

local getservice = function(serv)
    return cloneref(game.GetService(game, serv))
end
local vape = shared.rendervape
local render = render
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
local vapeTargetInfo = shared.VapeTargetInfo;

local api = {
    combat = vape.ObjectsThatCanBeSaved.CombatWindow.Api,
    blatant = vape.ObjectsThatCanBeSaved.BlatantWindow.Api,
    render = vape.ObjectsThatCanBeSaved.RenderWindow.Api,
    exploit = vape.ObjectsThatCanBeSaved.ExploitWindow.Api,
    utility = vape.ObjectsThatCanBeSaved.UtilityWindow.Api,
    world = vape.ObjectsThatCanBeSaved.WorldWindow.Api
}

vape.RemoveObject('SilentAimOptionsButton')
vape.RemoveObject('ReachOptionsButton')
vape.RemoveObject('MouseTPOptionsButton')
vape.RemoveObject('LongJumpOptionsButton')
vape.RemoveObject('HitBoxesOptionsButton')
vape.RemoveObject('KillauraOptionsButton')
vape.RemoveObject('ChamsOptionsButton')
vape.RemoveObject('TriggerBotOptionsButton')
vape.RemoveObject('AutoLeaveOptionsButton')
vape.RemoveObject('SafeWalkOptionsButton')
vape.RemoveObject('AntiVoidOptionsButton')

local gettarget = function(range, teamcheck)
    for i,v in players:GetPlayers() do
        if (teamcheck and lplr.Team ~= v.Team or true) and v ~= lplr and isAlive(v) then
            local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
            if mag < (range or math.huge) then
                return v
            end
        end
    end
    return nil
end

local getalltarget = function(range, teamcheck)
    local ents = {}
    for i,v in players:GetPlayers() do
        if (teamcheck and lplr.Team ~= v.Team or true) and v ~= lplr and isAlive(v) then
            local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
            if mag < (range or math.huge) then
                table.insert(ents, v)
            end
        end
    end
    return ents
end

local getallitems = function(onlyequipped)
    local items = {}
    if not onlyequipped then
        for i,v in lplr.Backpack:GetChildren() do
            table.insert(items, v)
        end
    end
    if isAlive() then
        for i,v in lplr.Character:GetChildren() do
            if v.ClassName == 'Tool' then
                table.insert(items, v)
            end
        end
    end
    return items
end

local damagetab = {
    M9 = 10,
    ['Remington 870'] = 15,
    ['AK-47'] = 30,
    ['M431'] = 35
}

local getweapondamage = function(name)
    return damagetab[name] or 0
end

local getweapons = function()
    local weapons = {}
    for i,v in getallitems() do
        if v:FindFirstChild('GunStates') then
            table.insert(weapons, v)
        end
    end
    return weapons
end

local playAnimation = function(id)
  	if isAlive() then 
  	    local animation = Instance.new("Animation")
    		animation.AnimationId = `rbxassetid://{id}`
    		local animation2 = lplr.Character.Humanoid.Animator
    		animation2:LoadAnimation(animation):Play()
  	end
end

local getbestweapon = function()
    local weapon = nil
    local damage = 0
    for i,v in getallitems(true) do
        if v:FindFirstChild('GunStates') and getweapondamage(v.Name) > damage then
            damage = getweapondamage(v.Name)
            weapon = v
        end
    end
    return weapon
end

run(function()
    local silentaim = {}
    local namecall
    silentaim = api.combat.CreateOptionsButton({
        Name = 'SilentAim',
        Function = void
    })
    namecall = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
        local args = {...}
        if not checkcaller() and getnamecallmethod() == 'FireServer' and silentaim.Enabled and self == replicatedstorage.ShootEvent then
            args[1][2].Hit = gettarget(26).Character.HumanoidRootPart
            return namecall(self, unpack(args))
        end
        return namecall(self, ...)
    end))
end)

run(function()
    local killaura = {}
    local killaurarange = {}
    local killauramode = {}
    local killauranoanimation = {}
    local killaurabox = {}
    local killauraboxcolor = newcolor()
    local killaurateamcheck = {}
    local killauramodes = {
        Single = function()
            return gettarget(killaurarange.Value, killaurateamcheck.Enabled)
        end,
        Multi = function()
            return getalltarget(killaurarange.Value, killaurateamcheck.Enabled)
        end
    }
    local attackent = function(ent)
        if not killaura.Enabled then return end
        if killaurateamcheck.Enabled and ent.Team == lplr.Team then return end
        local root = ent.Character.HumanoidRootPart
        local weapon = getbestweapon()
        if weapon then
            task.wait(0.1)
            replicatedstorage.ShootEvent:FireServer({
                [1] = {
                    RayObject = Ray.new(Vector3.new(845.555908, 101.429337, 2269.43945), Vector3.new(-391.152252, 8.65560055, -83.2166901)),
                    Distance = 7,
                    Cframe = CFrame.new(840.310791, 101.334137, 2267.87988, 0.0636406094, 0.151434347, -0.986416459, 0, 0.988420188, 0.151741937, 0.997972965, -0.00965694897, 0.0629036576),
                    Hit = root
                }
            }, weapon)
        else
            replicatedstorage.meleeEvent:FireServer(ent)
            if not killauranoanimation.Enabled then
                playAnimation(484926359)
            end
        end
        vapeTargetInfo.Targets.Killaura = {
            Humanoid = {
                Health = ent.Character.Humanoid.Health,
                MaxHealth = ent.Character.Humanoid.MaxHealth
            },
            Player = ent
        }
        render.targets:updatehuds(ent);
    end
    local kabox
    killaura = api.blatant.CreateOptionsButton({
        Name = 'Killaura', 
        Function = function(call)
            if call then
                kabox = Instance.new('Part', workspace)
                kabox.Anchored = true
                kabox.Transparency = 0.5
                kabox.Material = Enum.Material.Neon
                kabox.CanCollide = false
                kabox.Size = Vector3.new(4, 6, 4)
                kabox.Color = Color3.fromHSV(killauraboxcolor.Hue, killauraboxcolor.Sat, killauraboxcolor.Value)
                table.insert(killaura.Connections, runservice.Stepped:Connect(function()
                    if kabox and killaurabox.Enabled then
                        local ent = gettarget(killaurarange.Value, killaurateamcheck.Enabled)
                        if ent then
                            kabox.Transparency = 0.5
                            kabox.Parent = ent.Character
                            kabox.CFrame = ent.Character.HumanoidRootPart.CFrame
                        else
                            kabox.Transparency = 1
                            kabox.Parent = workspace
                        end
                    end
                end))
                repeat
                    local ent = killauramodes[killauramode.Value]()
                    if ent and type(ent) == 'table' then
                        for i, plr in ent do
                            pcall(attackent, plr)
                        end
                    elseif ent and type(ent) ~= 'table' then
                        pcall(attackent, ent)
                    else
                        vapeTargetInfo.Targets.Killaura = nil
                    end
                    task.wait(0)
                until (not killaura.Enabled)
            else
                render.targets:updatehuds();
                vapeTargetInfo.Targets.Killaura = nil
                kabox:Remove()
                kabox = nil
            end
        end,
        ExtraText = function()
            return 'Switch'
        end
    })
    killaurarange = killaura.CreateSlider({
        Name = 'Range',
        Min = 1,
        Max = 16,
        Default = 16,
        Function = void
    })
    killauramode = killaura.CreateDropdown({
        Name = 'Mode',
        List = {'Single', 'Multi'},
        Function = void
    })
    killaurateamcheck = killaura.CreateToggle({
        Name = 'TeamCheck',
        Function = void
    })
    killauranoanimation = killaura.CreateToggle({
        Name = 'NoAnimation',
        Function = void
    })
    killaurabox = killaura.CreateToggle({
        Name = 'Box',
        Function = function(call)
            killauraboxcolor.Object.Visible = call
        end
    })
    killauraboxcolor = killaura.CreateColorSlider({
        Name = 'Color',
        Function = function(h, s, v)
            if kabox then
                kabox.Color = Color3.fromHSV(h, s, v)
            end
        end
    })
    killauraboxcolor.Object.Visible = false
end)

run(function()
    local autopickup = {}
    autopickup = api.utility.CreateOptionsButton({
        Name = 'AutoPickUp',
        Function = function(call)
            if call then
                repeat
                    for i,v in workspace.Prison_ITEMS.giver:GetChildren() do
                        workspace.Remote.ItemHandler:InvokeServer(v:FindFirstChild('ITEMPICKUP'))
                    end
                    for i,v in workspace.Prison_ITEMS.single:GetChildren() do
                        workspace.Remote.ItemHandler:InvokeServer(v:FindFirstChild('ITEMPICKUP'))
                    end
                    task.wait(0.5)
                until (not autopickup.Enabled)
            end
        end
    })
end)

run(function()
    local gunmod = {}
    local firerate = {}
    local maxammo = {}
    local range = {}
    gunmod = api.exploit.CreateOptionsButton({
        Name = 'GunMod',
        Function = function(call)
            if call then
                repeat
                    local weapons = getweapons(false)
                    for i,v in weapons do
                        require(v.GunStates).FireRate = firerate.Value
                        require(v.GunStates).MaxAmmo = maxammo.Value
                        require(v.GunStates).Range = range.Value
                    end
                    task.wait(1)
                until (not gunmod.Enabled)
            end
        end
    })
    maxammo = gunmod.CreateSlider({
        Name = 'MaxAmmo',
        Min = 0,
        Max = 1000,
        Function = void,
        Default = math.huge
    })
    range = gunmod.CreateSlider({
        Name = 'Range',
        Min = 0,
        Max = 500,
        Function = void,
        Default = math.huge
    })
    firerate = gunmod.CreateSlider({
        Name = 'FireRate',
        Function = void,
        Min = 0,
        Max = 5,
        Default = 0
    })
end)

run(function()
    local autoarrest = {}
    local arresting = false
    local oldroot
    local newroot
    local function createclone()
        repeat task.wait(.1) until isAlive(lplr, true)
        lplr.Character.Parent = game
        lplr.Character.HumanoidRootPart.Archivable = true
        oldroot = lplr.Character.HumanoidRootPart 
        newroot = oldroot:Clone()
        newroot.Parent = lplr.Character
        oldroot.Parent = workspace
        oldroot.Transparency = 0.4
        lplr.Character.PrimaryPart = newroot
        lplr.Character.Parent = workspace
    end
    local function removeclone() 
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
    end
    autoarrest = api.blatant.CreateOptionsButton({
        Name = 'AutoArrest',
        Function = function(call)
            if call then
                pcall(createclone)
                table.insert(autoarrest.Connections, runservice.Stepped:Connect(function()
                    if oldroot then
                        oldroot.Velocity = Vector3.zero
                        if not arresting then
                            oldroot.CFrame = newroot.CFrame
                        end
                    end
                end))
                repeat
                    if lplr.Team ~= 'Guards' then return end
                    for i,v in players:GetPlayers() do
                        if isAlive(v) and v.Team == 'Crimanals' then
                            arresting = true
                            oldroot.CFrame = v.Character.HumanoidRootPart.CFrame
                            task.wait(0.12)
                            for i = 1,4 do workspace.Remote.arrest:InvokeServer(v) end
                            arresting = false
                            task.wait(1)
                        end
                    end
                    task.wait(0.5)
                until (not killaura.Enabled)
            else
                pcall(removeclone)
            end
        end
    })
end)

run(function()
    local antiarrest = {}
    antiarrest = api.blatant.CreateOptionsButton({
        Name = 'AntiArrest',
        Function = function(call)
            if call then
                repeat
                    if lplr.Status.isArrested.Value then
                        local oldcf = lplr.Character.PrimaryPart.CFrame
                        workspace.Remote.TeamEvent:FireServer(tostring(lplr.TeamColor))
                        task.wait(0.12)
                        lplr.Character.PrimaryPart.CFrame = oldcf
                    end
                    task.wait(0.2)
                until (not antiarrest.Enabled)
            end
        end
    })
end)

run(function()
    local deathtp = {}
    local oldcf
    deathtp = api.blatant.CreateOptionsButton({
        Name = 'AntiDeath',
        Function = function(call)
            if call then
                table.insert(deathtp.Connections, lplr.CharacterAdded:Connect(function()
                    lplr.Character.HumanoidRootPart.CFrame = oldcf
                end))
                repeat
                    if not isAlive() then
                        oldcf = lplr.Character.HumanoidRootPart.CFrame
                        task.wait(0.12)
                        workspace.Remote.TeamEvent:FireServer(tostring(lplr.TeamColor))
                        task.wait(0.2)
                        lplr.Character.HumanoidRootPart.CFrame = oldcf
                    end
                    task.wait(0.2)
                until (not deathtp.Enabled)
            end
        end,
        HoverText = 'Teleports to your old position after respawns.'
    })
end)

run(function()
    local teamswitch = {}
    local teamswitchvalue = {}
    teamswitch = api.utility.CreateOptionsButton({
        Name = 'TeamSwitch',
        Function = function(call)
            if call then
                teamswitch.ToggleButton()
                if lplr.Team ~= getservice('Teams')[teamswitchvalue.Value] then
                    local teamcolor = getservice('Teams')[teamswitchvalue.Value].TeamColor
                    --workspace.Remote.TeamEvent:FireServer(tostring(teamcolor))
                end
            end
        end
    })
    teamswitchvalue = teamswitch.CreateDropdown({
        Name = 'Team',
        List = {'Guards', 'Inmates', 'Criminals'},
        Function = void
    })
end)
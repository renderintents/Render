local DataStoreService = game:GetService("DataStoreService")
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

type vapemain = {
    ObjectsThatCanBeSaved: table,
    objects: table
};
   
type vapeminimodule = {
	Enabled: boolean,
	Object: Instance,
	ToggleButton: (boolean | nil, boolean | nil) -> ()
};

type vapeslider = {
	Value: number,
	Object: Instance,
	SetValue: (number) -> ()
};

type vapecolorslider = {
	Hue: number,
	Sat: number,
	Value: number,
	Object: Instance,
	SetRainbow: (boolean | nil) -> (),
	SetValue: (number, number, number) -> ()
};

type vapedropdown = {
	Value: string,
	Object: Instance,
	SetValue: (table) -> ()
};

type vapetextlist = {
	ObjectList: table,
	Object: Instance,
	RefreshValues: (table) -> table
};

type vapetextbox = {
	Value: string,
	Object: Instance,
	SetValue: (string) -> ()
};

type vapecustomwindow = {
	GetCustomChildren: (table) -> Frame,
	SetVisible: (boolean | nil) -> ()
};

type securetable = {
	clear: (securetable, (any, any) -> ()) -> (),
	len: (securetable) -> number,
	shutdown: (securetable) -> (),
	getplainarray: (securetable) -> table
};

type vapemodule = {
    Connections: table,
    Enabled: boolean,
    Object: Instance,
    ToggleButton: (boolean | nil, boolean | nil) -> (),
	CreateTextList: (table) -> vapetextlist,
	CreateColorSlider: (table) -> vapeslider,
	CreateToggle: (table) -> vapeminimodule,
	CreateDropdown: (table) -> vapedropdown,
	CreateSlider: (table) -> vapeslider,
	CreateTextBox: (table) -> vapetextbox,
	GetCustomChildren: (table) -> vapecustomwindow
};

type vapewindow = {
	CreateOptionsButton: (table) -> vapemodule,
	SetVisible: (boolean | nil) -> ()
};

type rendertarget = {
    Player: Player | nil,
    Humanoid: Humanoid | nil,
    RootPart: BasePart | nil,
    NPC: boolean | nil
};

local gui: vapemain = shared.rendervape;
local render: table = render or warn('❌ Failed to fetch the render main table.') or {};

for i: (any), v: (...any) -> (...any) in render.utils do --> sideloads all render global utility functions from libraries/utils.lua
    getfenv()[i] = v;
end;

local vape: vapemain = gui;
local GuiLibrary: vapemain = gui;
local cloneref = cloneref or function(data) return data end;
local getservice = function(service)
	return cloneref(game:FindService(service))
end;

local players: Players = getservice('Players');
local textservice: TextService = getservice('TextService');
local lighting: Lighting = getservice('Lighting');
local textchat: TextChatService = getservice('TextChatService');
local inputservice: UserInputService = getservice('UserInputService');
local runservice: RunService = getservice('RunService');
local teleport: TeleportService = getservice('TeleportService');
local tween: TweenService = getservice('TweenService');
local collection: CollectionService = getservice('CollectionService');
local httpservice: HttpService = getservice('HttpService');
local replicatedstorage: ReplicatedStorage = getservice('ReplicatedStorage');
local fakecam: Camera = Instance.new('Camera');
local camera: Camera? = workspace.CurrentCamera;
local lplr: Player = players.LocalPlayer;
local vapeConnections: table = {};
local vapeCachedAssets: table = {};
local vapeEvents: table = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new('BindableEvent')
		return self[index]
	end
});
local vapetarget: table = shared.VapeTargetInfo;
local vapeInjected: boolean = true;

local store: table = setmetatable({}, {})

local combat = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world = vape.ObjectsThatCanBeSaved.WorldWindow;
local hudwindow = vape.ObjectsThatCanBeSaved.TargetHUDWindow;
local minigames = vape.objects.MinigamesWindow;
local inventory = vape.objects.InventoryWindow;

task.spawn(function()
    for i: number, v: table in {'SilentAim', 'Reach', 'TriggerBot', 'SafeWalk', 'AntiVoid'} do
        vape.RemoveObject(`{v}OptionsButton`)
    end;
    vape.RemoveObject('MinigamesWindow');
end);

store = setmetatable({
    damagetab = {
        M9 = 10,
        ['Remington 870'] = 15,
        ['AK-47'] = 30,
        ['M431'] = 35
    }
}, {
    __index = function(self: table, index: string): (table, string) -> (table?)
        if index == 'getitems' then
            return function(equip_check: boolean): (boolean) -> {Tool}
                local items: table = {};
                if not equip_check then
                    for i: number, v: Tool in lplr.Backpack:GetChildren() do
                        table.insert(items, v);
                    end;
                end;
                if isAlive() then
                    for i: number, v: Tool?  in lplr.Character:GetChildren() do
                        if v.ClassName == 'Tool' then
                            table.insert(items, v);
                        end;
                    end;
                end;
                return items;
            end;
        end;
        if index == 'getweapons' then
            return function(): () -> {Tool}
                local weapons: table = {}
                for i: number, v: Tool in store.getitems() do
                    if v:FindFirstChild('GunStates') then
                        table.insert(weapons, v);
                    end;
                end;
                return weapons;
            end;
        end;
        if index == 'getdamage' then
            return function(name: string): (string) -> (number)
                return store.damagetab[name] or 0;
            end;
        end;
        if index == 'getgun' then
            return function()
                local weapon: Tool = nil;
                local damage: number = 0;
                for i: number, v: {Tool} in store.getitems(true) do
                    local weapondamage: number = store.getdamage(v.Name);
                    if v:FindFirstChild('GunStates') and weapondamage > damage then
                        damage = weapondamage;
                        weapon = v;
                    end;
                end;
                return weapon;
            end;
        end;
        return function() end;
    end,
    __tostring = 'store'
});

local playAnimation = function(id: number): (number) -> ()
  	if isAlive() then 
  	    local animation = Instance.new('Animation');
    	animation.AnimationId = `rbxassetid://{id}`;
    	local animation2 = lplr.Character.Humanoid.Animator;
    	animation2:LoadAnimation(animation):Play();
  	end;
end;

run(function()
    local silentaim: vapemodule = {}
    local namecall: (any, ...any) -> (any)
    silentaim = combat.Api.CreateOptionsButton({
        Name = 'SilentAim',
        Function = void
    })
    namecall = hookmetamethod(game, '__namecall', newcclosure(function(self: any, ...): (any, ...any) -> (any)
        local args: {any} = {...};
        if not checkcaller() and getnamecallmethod() == 'FireServer' and silentaim.Enabled and self == replicatedstorage.ShootEvent then
            local plr = GetTarget({radius = 100});
            if plr then
                args[1][2].Hit = plr.RootPart;
            end;
            return namecall(self, unpack(args));
        end;
        return namecall(self, ...);
    end));
end);

run(function() --> awh nah i aint rewriting this.
    local killaura: vapemodule = {}
    local killaurarange: vapeslider = {}
    local killauramode: vapedropdown = {}
    local killauranoanimation: vapeminimodule = {}
    local killaurabox: vapeminimodule = {}
    local killauraboxcolor: vapecolorslider = newcolor()
    local killaurateamcheck: vapeminimodule = {}
    local killauramodes: table = {
        Single = function()
            return GetTarget({
                radius = killaurarange.Value or 100
            })
        end,
        Multi = function()
            return GetActiveTargets({
                radius = killaurarange.Value or 100
            });
        end
    }
    local attackent = function(ent): (table?) -> ()
        if not killaura.Enabled then return end
        if killaurateamcheck.Enabled and ent.Team == lplr.Team then return end
        local root = ent.Character.HumanoidRootPart
        local weapon = store.getgun()
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
        vapetarget.Targets.Killaura = {
            Humanoid = {
                Health = ent.Character.Humanoid.Health,
                MaxHealth = ent.Character.Humanoid.MaxHealth
            },
            Player = ent
        }
        render.targets:updatehuds(ent);
    end
    local kabox
    killaura = blatant.Api.CreateOptionsButton({
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
                        local ent = GetTarget({
                            radius = killaurarange.Value or 100
                        });
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
                        vapetarget.Targets.Killaura = nil
                    end
                    task.wait(0)
                until (not killaura.Enabled)
            else
                render.targets:updatehuds();
                vapetarget.Targets.Killaura = nil;
                kabox:Remove();
                kabox = nil;
            end;
        end,
        ExtraText = function()
            return 'Switch'
        end
    });
    killaurarange = killaura.CreateSlider({
        Name = 'Range',
        Min = 1,
        Max = 16,
        Default = 16,
        Function = void
    });
    killauramode = killaura.CreateDropdown({
        Name = 'Mode',
        List = {'Single', 'Multi'},
        Function = void
    });
    killaurateamcheck = killaura.CreateToggle({
        Name = 'TeamCheck',
        Function = void
    });
    killauranoanimation = killaura.CreateToggle({
        Name = 'NoAnimation',
        Function = void
    });
    killaurabox = killaura.CreateToggle({
        Name = 'Box',
        Function = function(call)
            killauraboxcolor.Object.Visible = call
        end
    });
    killauraboxcolor = killaura.CreateColorSlider({
        Name = 'Color',
        Function = function(h, s, v)
            if kabox then
                kabox.Color = Color3.fromHSV(h, s, v)
            end
        end
    });
    killauraboxcolor.Object.Visible = false;
end);

run(function()
    local autopickup = {}
    autopickup = utility.Api.CreateOptionsButton({
        Name = 'AutoPickUp',
        Function = function(call)
            if call then
                repeat
                    for i: number, v: Instance in workspace.Prison_ITEMS.giver:GetChildren() do
                        workspace.Remote.ItemHandler:InvokeServer(v:FindFirstChild('ITEMPICKUP'));
                    end;
                    for i: number, v: Instance in workspace.Prison_ITEMS.single:GetChildren() do
                        workspace.Remote.ItemHandler:InvokeServer(v:FindFirstChild('ITEMPICKUP'));
                    end;
                    task.wait(0.5);
                until (not autopickup.Enabled);
            end;
        end
    });
end);

run(function()
    local gunmod = {}
    local firerate = {}
    local maxammo = {}
    local range = {}
    gunmod = exploit.Api.CreateOptionsButton({
        Name = 'GunMod',
        Function = function(call)
            if call then
                repeat
                    local weapons = store.getweapons(false)
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

run(function() --> awh aint rewriting this too
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
    autoarrest = blatant.Api.CreateOptionsButton({
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
                        if isAlive(v) and v.Team == 'Crimianals' then
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
    antiarrest = blatant.Api.CreateOptionsButton({
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
    local deathtp: vapemodule = {Enabled = false};
    local deathtpthread: thread;
    local oldcf: CFrame;
    deathtp = blatant.Api.CreateOptionsButton({
        Name = 'AntiDeath',
        Function = function(call)
            if call then
                deathtpthread = task.spawn(function()
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
                end)
                table.insert(deathtp.Connections, lplr.CharacterAdded:Connect(function()
                    lplr.Character.HumanoidRootPart.CFrame = oldcf;
                end));
            else
                pcall(task.cancel, deathtpthread)
            end
        end,
        HoverText = 'Teleports to your old position after respawns.'
    })
end)

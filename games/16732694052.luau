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
   CustomModules/16732694052.luau (Fisch) - Maxlasertech            
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

for i: (any), v: (...any) -> (...any) in render.utils do 
    getfenv()[i] = v;
end;

local cloneref = cloneref or function(data) return data end;
local getservice = function(service: string): (string) -> (any)
	return cloneref(game:GetService(service))
end;
local cheatenginetrash = cheatenginetrash
local rendervape: vapemain = gui;
local vape: vapemain = rendervape;
local players: Players = getservice('Players');
local textservice: TextService = getservice('TextService');
local lighting: Lighting = getservice('Lighting');
local textchat: TextChatService = getservice('TextChatService');
local inputservice: UserInputService = getservice('UserInputService');
local runservice: RunService = getservice('RunService');
local pathfinding: PathfindingService = getservice('PathfindingService');
local teleport: TeleportService = getservice('TeleportService');
local tween: TweenService = getservice('TweenService');
local collection: CollectionService = getservice('CollectionService');
local httpservice: HttpService = getservice('HttpService');
local replicatedstorage: ReplicatedStorage = getservice('ReplicatedStorage');
local camera: Camera? = workspace.CurrentCamera;
local lplr: Player = players.LocalPlayer;
local vapeConnections: table = {};
local vapeCachedAssets: table = {};
local vapeEvents: table = setmetatable({}, {
	__index = function(self: table, index: string): (BindableEvent)
		self[index] = Instance.new('BindableEvent')
		return self[index]
	end
});
local identifyexecutor = identifyexecutor or function() return 'cheat engine' end
local vapeTargetInfo: table = shared.VapeTargetInfo;
local vapeInjected: boolean = true;

local blatant: vapewindow = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual: vapewindow = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit: vapewindow = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility: vapewindow = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world: vapewindow = vape.ObjectsThatCanBeSaved.WorldWindow;
local inventory: vapewindow = vape.ObjectsThatCanBeSaved.InventoryWindow;
local minigames: vapewindow = vape.ObjectsThatCanBeSaved.MinigamesWindow;

local store: table = setmetatable({
    events = replicatedstorage.events
}, {
    __index = function(self: table, index: string): (table)
        if tostring(index):find('getfishingrod') then
            return function(): (Tool?)
                for i: number, v: Tool in lplr.Backpack:GetChildren() do
                    if v.Name:find(' Rod') then
                        return v;
                    end;
                end;
                for i: number, v: Tool? in lplr.Character:GetChildren() do
                    if v.ClassName == 'Tool' and v.Name:find(' Rod') then
                        return v;
                    end;
                end
            end
        end;
        return {};
    end
});

task.spawn(function()
    local features: {string} = {'BackTrack', 'HitBoxes', 'AutoLeave', 'Reach', 'AntiVoid', 'AutoReport', 'AnimationPlayer'};
    for i: number, v: string in features do
        vape.RemoveObject(`{v}OptionsButton`)
    end;
end)

run(function()
    local autocomplete: vapemodule = {Enabled = false};
    local autocompletereeled: boolean = false;
    autocomplete = minigames.Api.CreateOptionsButton({
        Name = 'AutoComplete',
        Function = function(call: boolean): () -> ()
            if call then
                table.insert(autocomplete.Connections, lplr.PlayerGui.ChildAdded:Connect(function(v: ScreenGui): ()
                    store.events.reelfinished:FireServer(math.huge, true);
                end))
            end
        end
    });
end)

local autocasted: boolean;
run(function()
    local autocast: vapemodule = {Enabled = false};
    local autocastwarned: boolean;
    autocast = utility.Api.CreateOptionsButton({
        Name = 'AutoCast',
        Function = function(call: boolean): ()
            if call then
                repeat
                    task.wait()
                    local tool: Tool? = lplr.Character:FindFirstChildWhichIsA('Tool');
                    if not autocasted and tool and tool:FindFirstChild('events') and tool.events:FindFirstChild('cast') then
                        tool.events.cast:FireServer(math.huge, 1);
                    end;
                    autocasted = tool and true;
                until not autocast.Enabled;
            end;
        end
    });
end);

run(function()
    local autofreeze: vapemodule = {Enabled = false};
    autofreeze = utility.Api.CreateOptionsButton({
        Name = 'AutoFreeze',
        Function = function(call: bool): ()
            if call then
                repeat
                    if autocasted then
                        task.delay(1, function()
                            lplr.Character.PrimaryPart.Anchored = true;
                        end);
                    else
                        lplr.Character.PrimaryPart.Anchored = false;
                    end;
                    task.wait()
                until not autofreeze.Enabled;
            end;
        end
    });
end);

run(function()
    local autoshake: vapemodule = {Enabled = false};
    local autoshakecon: RBXScriptConnection;
    autoshake = utility.Api.CreateOptionsButton({
        Name = 'AutoShake',
        Function = function(call: boolean): ()
            if call then
                repeat
                    if not autocasted then
                        task.wait();
                        continue;
                    end;
                    local shakeui: ScreenGui? = lplr.PlayerGui:FindFirstChild('shakeui');
                    local button: ImageButton? = shakeui and shakeui.safezone:FindFirstChild('button');
                    if button then
                        firesignal(button.MouseButton1Click);
                    end;
                    task.wait(button and 0.6);
                until not autoshake.Enabled
            end;
        end
    });
end);
run(function()
    local locationchanger: vapemodule = {Enabled = false};
    local locationvalue: vapedropdown = {Value = ''};
    local oldlocation: CFrame = nil;
    locationchanger = utility.Api.CreateOptionsButton({
        Name = 'LocationChanger',
        Function = function(call: boolean): ()
            if call then
                oldlocation = lplr.Character.HumanoidRootPart.CFrame;
                lplr.Character.HumanoidRootPart.CFrame = workspace.zones.player[locationvalue.Value].CFrame;
            else
                if not isAlive() then oldlocation = nil; return end;
                lplr.Character.HumanoidRootPart.CFrame = oldlocation;
                oldlocation = nil;
            end;      
        end
    });
    local list: table = {};
    for i: number, v: Part in workspace.zones.player:GetChildren() do table.insert(list, v.Name) end;
    locationvalue = locationchanger.CreateDropdown({
        Name = 'Location',
        List = list,
        Function = function(): ()
            locationchanger:retoggle();
        end;
    });
end);

run(function()
    local autoaltar: vapemodule = {Enabled = false};
    autoaltar = utility.Api.CreateOptionsButton({
        Name = 'AutoAltar',
        HoverText = 'Automatically enchants ur rod.',
        Function = function(call: bool): () 
            if call then
                --> later
            end;
        end  
    });
end);

run(function()
    local antidrown: vapemodule = {Enabled = false};
    antidrown = exploit.Api.CreateOptionsButton({
        Name = 'AntiDrown',
        Function = void
    });
    table.insert(renderconnections, task.spawn(function()
        repeat
            task.wait();
            if not isAlive() then continue end;
            lplr.Character.client.oxygen.Enabled = not antidrown.Enabled;
        until false;
    end));
end)

run(function()
    local autosell: vapemodule = {Enabled = false};
    autosell = inventory.Api.CreateOptionsButton({
        Name = 'AutoSell',
        HoverText = 'Automatically sells all of your fish.',
        Function = function(call: bool): ()
            if call then
                repeat
                    
                    task.wait();
                until not autosell.Enabled
            end
        end
    })
end)

task.spawn(function()
    repeat
        render.session.new({
            {
                name = 'Caught',
                value = replicatedstorage.playerstats[lplr.Name].Rods[store.getfishingrod().Name].caught.Value
            },
            {
                name = 'Region', 
                value = lplr.PlayerGui.serverInfo.serverInfo.region.Text:split(': ')[2]:split(', ')[1]
            }
        })
        render.session.new({
            {
                name = 'Money', 
                value = lplr.leaderstats['C$'].Value
            },
            {
                name = 'Lvl', 
                value = lplr.leaderstats.Level.Value
            }
        })
        task.wait(1)
    until not shared.VapeFullyLoaded
end)
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
   CustomModules/3101667897.luau (Legends Of Speed ⚡) - SystemXVoid/BlankedVoid 
   https://renderintents.lol                                                                                                                                                                                                                                                                     
]]

type vapemain = {
    ObjectsThatCanBeSaved: {vapewindow},
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
	ObjectList: {string},
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
	Api: {
		CreateOptionsButton: ({Name: string, HoverText: string?, Function: (boolean) -> (...any)}) -> vapemodule,
		SetVisible: (boolean | nil) -> ()
	}
};

type gamestore = {
    stats: {any};
};

type rendertarget = {
    Player: Player | nil,
    Humanoid: Humanoid | nil,
    RootPart: BasePart | nil,
    NPC: boolean | nil
};

local rendervape: vapemain = shared.rendervape;
local runFunction: (() -> (any)) -> () = run;
local runcode: (() -> (any)) -> () = run;
local run: (() -> (any)) -> () = run;
local render: table = getgenv().render;

for i: (any), v: (...any) -> (...any) in render.utils do --> sideloads all render global utility functions from libraries/utils.lua
    getfenv()[i] = v;
end;

--> defining mostly used (by most people) variables

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

local combat: vapewindow = rendervape.ObjectsThatCanBeSaved.CombatWindow;
local blatant: vapewindow = rendervape.ObjectsThatCanBeSaved.BlatantWindow;
local visual: vapewindow = rendervape.ObjectsThatCanBeSaved.RenderWindow;
local utility: vapewindow = rendervape.ObjectsThatCanBeSaved.UtilityWindow;
local world: vapewindow = rendervape.ObjectsThatCanBeSaved.WorldWindow;
local exploit: vapewindow = rendervape.ObjectsThatCanBeSaved.ExploitWindow;
local minigames: vapewindow = rendervape.ObjectsThatCanBeSaved.MinigamesWindow;
local guiwindow: vapewindow = rendervape.ObjectsThatCanBeSaved.GUIWindow;
local inventory: vapewindow = rendervape.ObjectsThatCanBeSaved.InventoryWindow;

local store: gamestore = {
    stats = setmetatable({}, {
        __index = function(self: table, index: string): (any)
            local statobj: ValueBase = lplr:FindFirstChild(index) or lplr.leaderstats:FindFirstChild(index);
            if statobj and statobj.ClassName:find('Value') then 
                return statobj.Value;
            end;
        end
    })
};

function store:getinventory(plr: Player?): {Folder}
    local plr = plr or lplr;
    local invitems: {StringValue} = plr:WaitForChild('petsFolder', 9e9):GetChildren();
    for i: number, v: Folder? in plr:WaitForChild('trailsFolder', 9e9):GetChildren() do    
        table.insert(invitems, v);
    end;
    return invitems;
end;

task.spawn(function()
    local uselessmodules: {string} = {
        'AutoClicker',
        'Reach',
        'HitBoxes',
        'Killaura',
        'TargetStrafe'
    };
    for i: number, v: string in uselessmodules do 
        rendervape.RemoveObject(`{v}OptionsButton`);
    end;

    repeat task.wait() until shared.VapeFullyLoaded;
    rendervape.RemoveObject('CombatWindow');
end);

run(function()
    local autofarm: vapemodule = {};
    local autofarmore: vapeminimodule = {Enabled = true};
    local autofarmhoops: vapeminimodule = {Enabled = true};
    autofarm = exploit.Api.CreateOptionsButton({
        Name = 'AutoFarm',
        HoverText = 'Automatically farms ores',
        Function = function(calling: boolean): ()
            if calling then 
                table.insert(autofarm.Connections, runservice.Heartbeat:Connect(function()
                    if autofarmore.Enabled then 
                        for i: number, v: Model? in replicatedstorage:WaitForChild('Orbs', 9e9):GetChildren() do
                            replicatedstorage.rEvents.orbEvent:FireServer('collectOrb', v.Name, 'City');
                        end;
                    end;
                    if autofarmhoops.Enabled then 
                        for i: number, v: Part? in workspace:WaitForChild('Hoops', 9e9):GetChildren() do 
                            local touch: TouchTransmitter = v:FindFirstChildOfClass('TouchTransmitter');
                            if touch and isAlive(lplr, true) then 
                                if firetouchinterest then 
                                    firetouchinterest(v, render.clone.old or lplr.Character.PrimaryPart, 0);
                                    firetouchinterest(v, render.clone.old or lplr.Character.PrimaryPart, 1);
                                else
                                    v.CFrame = lplr.Character.PrimaryPart.CFrame;
                                end;
                            end;
                        end;
                    end;
                end))
            end
        end
    });
    autofarmore = autofarm.CreateToggle({
        Name = 'Farm Orbs',
        Default = true,
        Function = void
    });
    autofarmhoops = autofarm.CreateToggle({
        Name = 'Farm Hoops',
        Default = true,
        Function = void
    })
end);

run(function()
    local autorebirth: vapemodule = {};
    autorebirth = utility.Api.CreateOptionsButton({
        Name = 'AutoRebirth',
        HoverText = 'Automatically rebirths you.',
        Function = function(calling: boolean): ()
            if calling then 
                repeat
                    replicatedstorage.rEvents.rebirthEvent:FireServer('rebirthRequest');
                    task.wait(0.1);
                until (not autorebirth.Enabled)
            end
        end
    })
end);

run(function()
    local autorace: vapemodule = {};
    local autoracewin: vapeminimodule = {};
    autorace = exploit.Api.CreateOptionsButton({
        Name = 'AutoRace',
        HoverText = 'Automatically joins/wins races.',
        Function = function(calling: boolean): ()
            if calling then 
                repeat
                    replicatedstorage.rEvents.raceEvent:FireServer('joinRace');
                    if autoracewin.Enabled then 
                        for _: number, v: Model? in workspace:WaitForChild('raceMaps', 9e9):GetChildren() do 
                            local finishline: Model? = v:FindFirstChild('finishPart');
                            if firetouchinterest and isAlive(lplr, true) and finishline and finishline:FindFirstChildOfClass('TouchTransmitter') then 
                                firetouchinterest(finishline, render.clone.old or lplr.Character.PrimaryPart, 0);
                                firetouchinterest(finishline, render.clone.old or lplr.Character.PrimaryPart, 1);
                            end;
                        end;
                    end;
                    task.wait();
                until (not autorace.Enabled)
            end
        end
    });
    autoracewin = autorace.CreateToggle({
        Name = 'Win',
        Default = true,
        HoverText = 'Automatically wins the race.',
        Function = void
    });
end);

run(function()
    local autocrate: vapemodule = {};
    autocrate = utility.Api.CreateOptionsButton({
        Name = 'AutoCrystal',
        HoverText = 'Automatically opens crates without\nthe need of being near them.',
        Function = function(calling: boolean): ()
            if calling then 
                repeat
                    for i: number, v: Folder? in replicatedstorage:WaitForChild('crystalPrices', 9e9):GetChildren() do 
                        if v:FindFirstChild('price') and store.stats.Gems >= v.price.Value then 
                            task.spawn(function()
                                replicatedstorage.rEvents.openCrystalRemote:InvokeServer('openCrystal', v.Name);  
                            end);
                            task.wait(0.05);
                        end;
                    end;
                    task.wait();
                until (not autocrate.Enabled)
            end
        end
    })
end);

run(function()
    local autosell: vapemodule = {};
    local autosellbasic: vapeminimodule = {Enabled = true};
    local autoselladvanced: vapeminimodule = {Enabled = true};
    local autosellepic: vapeminimodule = {Enabled = true};
    local autosellrare: vapeminimodule = {Enabled = true};
    local autosellunique: vapeminimodule = {Enabled = true};
    local autosellomega: vapeminimodule = {};
    local autosellduplicates: vapeminimodule = {};
    local autosellexcludetrails: vapeminimodule = {};
    local autosellpets: vapetextlist = {ObjectList = {}};
    local sellpets = function(array: {StringValue}, pet: string?): ()
        for i: number, v: StringValue in array do
            if pet and v.Name:lower():find(pet:lower()) == nil then 
                continue;
            end;
            if v.Parent.Parent.Name == 'petsFolder' then 
                replicatedstorage.rEvents.sellPetEvent:FireServer('sellPet', v);
            else
                replicatedstorage.rEvents.sellTrailEvent:FireServer('sellTrail', v);
            end;
            if pet then 
                break;
            end;
        end;
    end;
    autosell = inventory.Api.CreateOptionsButton({ --> here comes the butt shit code lol
        Name = 'AutoSell',
        HoverText = 'Automatically sells desired pets.',
        Function = function(calling: boolean): ()
            if calling then 
                repeat
                    local invitems: {Folder} = store:getinventory();
                    local pets: {string} = {};
                    for i: number, v: Folder? in invitems do 
                        local folderitems: {StringValue} = v:GetChildren();
                        table.foreach(folderitems, function(_: number, v: StringValue?)
                            if table.find(pets, v.Name) and autosellduplicates.Enabled then 
                                sellpets(folderitems, v.Name);
                            end;
                            table.insert(pets, v.Name);
                        end);
                        if v.Parent.Name ~= 'petsFolder' and autosellexcludetrails.Enabled then 
                            continue;   
                        end;
                        if v.Name == 'Basic' and autosellbasic.Enabled then 
                            sellpets(folderitems);
                        end;
                        if v.Name == 'Advanced' and autoselladvanced.Enabled then 
                            sellpets(folderitems);
                        end;
                        if v.Name == 'Epic' and autosellepic.Enabled then 
                            sellpets(folderitems);
                        end;
                        if v.Name == 'Rare' and autosellrare.Enabled then 
                            sellpets(folderitems);
                        end;
                        if v.Name == 'Unique' and autosellunique.Enabled then 
                            sellpets(folderitems);
                        end;
                        if v.Name == 'Omega'and autosellomega.Enabled then 
                            sellpets(folderitems);
                        end;
                        for i2: number, v2: string in autosellpets.ObjectList do 
                            sellpets(folderitems, v2);
                        end;
                    end;
                    table.clear(invitems);
                    table.clear(pets);
                    task.wait(0.3);
                until (not autosell.Enabled)
            end
        end
    });
    autosellbasic = autosell.CreateToggle({
        Name = 'Sell Basic',
        Default = true,
        Function = void
    });
    autoselladvanced = autosell.CreateToggle({
        Name = 'Sell Advanced',
        Function = void
    });
    autosellrare = autosell.CreateToggle({
        Name = 'Sell Rare',
        Function = void
    });
    autosellepic = autosell.CreateToggle({
        Name = 'Sell Epic',
        Function = void
    });
    autosellunique = autosell.CreateToggle({
        Name = 'Sell Unique',
        Function = void
    });
    autosellomega = autosell.CreateToggle({
        Name = 'Sell Omega',
        Function = void
    });
    autosellduplicates = autosell.CreateToggle({
        Name = 'Sell Duplicates',
        Function = void
    });
    autosellexcludetrails = autosell.CreateToggle({
        Name = 'Exclude Trails',
        Default = true,
        Function = void
    });
    autosellpets = autosell.CreateTextList({
        Name = 'Custom',
        TempText = 'custom',
        AddFunction = void
    });

    local retoggle: boolean = false;
    local retogglerequested: number = tick() - 5;
    inventory.Api.CreateOptionsButton({
        Name = 'ClearBackpack',
        HoverText = 'Sells your entire inventory of pets to free up space.',
        Button = true,
        Function = function(): ()
            if (tick() - retogglerequested) >= 5 or not retoggle then 
                retoggle = true;
                retogglerequested = tick();
                return InfoNotification('ClearBackpack', 'Toggle this module again to confirm this action.', 5)
            end;
            for i: number, v: Folder? in store:getinventory() do 
                sellpets(v:GetChildren());
            end;
            InfoNotification('ClearBackpack', 'Successfully sold all pets/trails in your backpack!', 7);
            retoggle = false;
        end
    })
end);
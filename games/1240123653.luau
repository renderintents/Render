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
   games/1240123653.luau (Zombie Attack) - MaxlaserTech          
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
local vapeTargetInfo: table = shared.VapeTargetInfo;
local vapeInjected: boolean = true;

local combat = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world = vape.ObjectsThatCanBeSaved.WorldWindow;
local minigames = vape.objects.MinigamesWindow;
local inventory = vape.objects.InventoryWindow;

vape.RemoveObject('Killaura');

local GetTarget: () -> () = function(args: table): (table) -> (table)
    local enemy: rendertarget = {};
    for i: number, v: Model in workspace.enemies:GetChildren() do
        if v.PrimaryPart then
            local mag: number = (lplr.Character.PrimaryPart.Position - v.PrimaryPart.Position).Magnitude
            if mag >= args.radius then
                enemy = {
                    Player = v,
                    Humanoid = v.Humanoid,
                    RootPart = v.PrimaryPart,
                    NPC = true
                };
                break
            end;
        end;
    end;
    return enemy
end

local getSword: () -> () = function(): () -> (Tool?)
    local tool: Tool? = nil;
    if isAlive(lplr, true) then
        for i: number, v: Tool? in lplr.Character:GetChildren() do
            if v.ClassName == 'Tool' and v.Name:find('Knife') then
                tool = v;
                break;
            end;
        end;
    end;
    return tool;
end;

run(function()
    local killaura: vapemodule = {Enabled = false};
    killaura = blatant.Api.CreateOptionsButton({
        Name = 'Killaura',
        Function = function(call: bool): () -> ()
            if call then
                repeat
                    local zombie: rendertarget = GetTarget({
                        radius = 30
                    });
                    if #zombie >= 1 then
                        replicatedstorage.forhackers:InvokeServer('hit', getSword(), zombie.RootPart);
                    end;
                    task.wait(0);
                until not killaura.Enabled;
            end;
        end
    })
end)

run(function()
    local autoshoot: vapemodule = {Enabled = false};
    autoshoot = blatant.Api.CreateOptionsButton({
        Name = 'AutoShoot',
        Function = function(call: bool): () -> ()
            if call then
                repeat
                    local zombie: rendertarget = GetTarget({
                        radius = 30
                    });
                    if #zombie >= 1 then
                        replicatedstorage.Gun:FireServer({
                            Normal = Vector3.zero,
                            Direction = Vector3.zero,
                            Name = 'Pistol',
                            Hit = zombie.RootPart,
                            Origin = Vector3.zero,
                            Pos = Vector3.zero
                        });
                    end;                  
                    task.wait(0);
                until not autoshoot.Enabled;
            end;
        end
    });
end)
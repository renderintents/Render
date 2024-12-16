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

type bool = boolean
   
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

local services: table = setmetatable({}, {
    __index = function(self: table, index: string): (Instance?)
        local suc, res = pcall(function()
            return getservice(index);
        end);
        return suc and res or error(res, 10);
    end
});

local vape: vapemain = gui;
local GuiLibrary: vapemain = gui;
local players: Players = services.Players;
local textservice: TextService = services.TextService;
local lighting: Lighting = services.Lighting;
local textchat: TextChatService = services.TextChatService;
local inputservice: UserInputService = services.UserInputService;
local runservice: RunService = services.RunService;
local teleport: TeleportService = services.TeleportService;
local tween: TweenService = services.TweenService;
local collection: CollectionService = services.CollectionService;
local httpservice: HttpService = services.HttpService;
local replicatedstorage: ReplicatedStorage = services.ReplicatedStorage;
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

local combat: vapewindow = vape.objects.CombatWindow;
local blatant: vapewindow = vape.objects.BlatantWindow;
local visual: vapewindow = vape.objects.RenderWindow;
local exploit: vapewindow = vape.objects.ExploitWindow;
local utility: vapewindow = vape.objects.UtilityWindow;
local world: vapewindow = vape.objects.WorldWindow;
local minigames: vapewindow = vape.objects.MinigamesWindow;
local inventory: vapewindow = vape.objects.InventoryWindow;

local sortstages: () -> () = function(tab: {Model}): {Model}
    local sortedtab: table = {};
    for i: number, v: Model in tab do
        local value: table = v.Name:split('');
        if tonumber(value[#value]) then
            local val: number = type(tonumber(value[#value -1])) == 'number' and tonumber(value[#value -1]) or tonumber(value[#value])
            sortedtab[val] = v;
        else
            if v.Name ~= 'TheEnd' then
                sortedtab[#tab - 1] = v;
            else
                sortedtab[#tab] = v;
            end;
        end;
    end;
    return sortedtab;
end;


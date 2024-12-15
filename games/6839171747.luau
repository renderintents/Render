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
   CustomModules/6839171747.lua (Doors) - MaxlaserTech & Selunar         
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
    Api: {
        CreateOptionsButton: (table) -> vapemodule,
        SetVisible: (boolean | nil) -> ()
    }
};

type rendertarget = {
    Player: Player | nil,
    Humanoid: Humanoid | nil,
    RootPart: BasePart | nil,
    NPC: boolean | nil
};


local gui: vapemain = shared.rendervape;
local render: table = render or warn('❌ Failed to fetch the render main table.') or {};
local RenderIntents: table = getgenv().RenderIntents or {};

for i: (any), v: (...any) -> (...any) in render.utils do
    getfenv()[i] = v;
end;

local vape: vapemain = gui;
local rendervape: vapemain = gui;

local cloneref = cloneref or function(data) return data end;
local getservice = function(service)
	return cloneref(game:GetService(service))
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
local cheatenginetrash: boolean = cheatenginetrash or false;
local suc, err = pcall(function(): () -> (table)
    require(lplr.PlayerGui:WaitForChild('MainUI').Initiator.Main_Game).test = {};
end);
if not suc then
    task.spawn(error, `❌ Failed to load some modules, error: {err}, loading cheat engine mode.`);
    errorNotification('Render', `❌ Failed to load some modules error: {err}, loading cheat engine mode.`, 20);
    cheatenginetrash = true;
end;

local combat: vapewindow = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant: vapewindow = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual: vapewindow = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit: vapewindow = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility: vapewindow = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world: vapewindow = vape.ObjectsThatCanBeSaved.WorldWindow;
local inventory: vapewindow = vape.ObjectsThatCanBeSaved.InventoryWindow;
local minigames: vapewindow = vape.ObjectsThatCanBeSaved.MinigamesWindow;


--> Doors varibles

local mainui: Frame = lplr.PlayerGui:FindFirstChild('MainUI');
local maingame: ModuleScript = mainui.Initiator.Main_Game;

local storage: table; storage = setmetatable({
    init = not cheatenginetrash and require(maingame) or {
        stopcam = true
    };
    loots = setmetatable({amount = 0}, {
        __index = function(self: table, index: string): {ProximityPrompt}
            local suc, res = pcall(function(): () -> (table)
                local items: table = {};
                for i: number, v: Instance in workspace.CurrentRooms[storage.roomdata]:GetDescendants() do
                    if index == 'items' and table.find({'ModulePrompt', 'LootPrompt', 'ActivateEventPrompt'}, v.Name) or v.ClassName == 'ProximityPrompt' and v.Name ~= 'HidePrompt' then
                        table.insert(items, v);
                    end;
                end;
                return items;
            end);
            if not suc and RenderIntents.DebugSession then
                errorNotification('Render', res, 15);
                error(res);
            end;
            self.amount = #res;
            return res;
        end
    });
    floor = replicatedstorage.GameData.Floor.Value;
}, {
    __index = function(self: table, index: string): (self, index) -> ()
        return replicatedstorage.GameData.LatestRoom.Value
    end;
});
--> Features/Modules

run(function()
    local autocollect: vapemodule = {Enabled = false};
    autocollect = utility.Api.CreateOptionsButton({
        Name = 'AutoCollect';
        HoverText = 'Automatically collects all the loot from the drawers.';
        Function = function(call: bool): (bool) -> ()
            if call then
                repeat
                    for i: number, v: {ProximityPrompt} in storage.loots.items do
                        local magpart: Part? = v.Parent:FindFirstChildOfClass('Part');
                        if magpart and not v:GetAttribute(`Interactions{lplr.Name}`) then
                            local mag: number = (lplr.Character.PrimaryPart.Position - magpart.Position).Magnitude;
                            if mag <= 20 then
                                fireproximityprompt(v);
                            end;
                        end;
                    end;
                    task.wait(0.5);
                until not autocollect.Enabled;
            end;
        end
    });
end);

run(function()
    local cameraunlocker: vapemodule = {Enabled = false}
    cameraunlocker = visual.Api.CreateOptionsButton({
        Name = 'CameraUnlocker',
        Function = function(call: bool): (bool) -> ()
            if call then
                table.insert(cameraunlocker.Connections, runservice.RenderStepped:Connect(function()
                    camera.CFrame = (not cheatenginetrash and storage.init.finalCamCFrame or camera.CFrame) * CFrame.new(1.5, -0.5, 6.5)
                end))
            end;
        end
    });
end);

run(function()
	local crouchspoofer: vapemodule = {Enabled = false};
	crouchspoofer = utility.Api.CreateOptionsButton({
		Name = 'CrouchSpoofer';
		Function = function(call: bool): (bool) -> ()
            replicatedstorage.RemotesFolder.Crouch:FireServer(false);
		end;
	});
    local crouchhook: (any, ...any) -> (...any); crouchhook = hookmetamethod(game, '__namecall', newcclosure(function(self: any, ...): (any, ...any) -> (...any)
        local args: {any} = {...};
        if getnamecallmethod() == 'FireServer' and (self == replicatedstorage.RemotesFolder.Crouch or tostring(self) == 'Crouch') and crouchspoofer.Enabled then
            args[1] = true;
            return crouchhook(self, unpack(args));
        end;
        return crouchhook(self, ...);
    end));
end);

run(function()
    local autosolver: vapemodule = {Enabled = false};
	local autosolverbreakerbox: vapeminimodule = {Enabled = false};
	local autosolveranchor: vapeminimodule = {Enabled = false};
    local minigameactions: table = {
        breakers = {};
        minesanchor = {};
        pumps = {};
    };

	local setattribute = function(i: Instance, v: bool): (Instance, bool) -> ()
		minigameactions[i] = {
            Enabled = v;
        };
		if v then
			i:FindFirstChild('PrismaticConstraint', true).TargetPosition = -0.2;
			i.Light.Material = Enum.Material.Neon;
			i.Light.Attachment.Spark:Emit(1);
			i.Sound.Pitch = 1.3;
		else
			i:FindFirstChild('PrismaticConstraint', true).TargetPosition = 0.2;
			i.Light.Material = Enum.Material.Glass;
			i.Sound.Pitch = 1.2;
		end;
		i.Sound:Play();
	end;
    autosolver = minigames.Api.CreateOptionsButton({
        Name = 'AutoSolver',
        HoverText = 'Automatically solves every minigames for you.',
        Function = function(call: bool): (bool) -> ()
            if call then
                repeat
                    if storage.roomdata == 50 and autosolveranchor.Enabled and storage.floor == 'Mines' and mainui.MainFrame.AnchorHintFrame then
                        local anchors: table = {};
                        for i: number, v: ProximityPrompt in storage.drawers.prompts do
							if v.Parent.Name == 'MinesAnchor' and v.Name == 'ActivateEventPrompt' and not v.Parent:GetAttribute('Activated') then
								table.insert(anchors, v);
							end;
						end;
                        for i,v in anchors do
							local curranchor: string = v.Parent.Sign.TextLabel.Text;
							local suc, err = pcall(function(): (any)
								return v.Parent:FindFirstChildOfClass('RemoteFunction'):InvokeServer(mainui.MainFrame.AnchorHintFrame.Code.Text);
							end);
							if curranchor ~= mainui.MainFrame.AnchorHintFrame.AnchorCode.Text then return end;
							if suc then
								warningNotification('Render', `Successfully solved {curranchor}!`, 7);
							else
								errorNotification('Render', `Failed to enter anchor code: {err}`, 7);
							end;
						end
                    elseif storage.roomdata == 100 then
                        if storage.floor == 'Hotel' then
                            local elevatorbreaker: Instance = workspace.CurrentRooms['100']:FindFirstChild('ElevatorBreaker');
                            if (not cheatenginetrash and storage.init.stopcam) and elevatorbreaker and not minigameactions[elevatorbreaker].Solving then
                                minigameactions[elevatorbreaker] = {
                                    Solving = true;
                                };
                                local code = elevatorbreaker:FindFirstChild('Code', true)
								local breakers: table = {};
								for i: number, v: Instance in elevatorbreaker:GetChildren() do
									if v.Name == 'BreakerSwitch' then
										local id: string = string.format('%02d', v:GetAttribute('ID'));
										v[id] = v;
									end;
								end;
                            end;
                        end
                    end;
                    task.wait();
                until not autosolver.Enabled;
            end;
        end
    });
end);
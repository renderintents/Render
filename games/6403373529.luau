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
   CustomModules/6403373529.luau (Slap Battles) - SystemXVoid/BlankedVoid 
   https://renderintents.lol                                                                                                                                                                                                                                                                     
]]

type vapeobjectsapi = {
    Api: table
};

type vapelegitmoduleargs = {
	Name: string,
	Function: (boolean) -> ()
};

type vapegui = {
    ObjectsThatCanBeSaved: vapeobjectsapi,
	SelfDestructEvent: BindableEvent
};

type vapemoduleargs = {
    Name: string,
    HoverText: string | nil,
    ExtraText: (() -> string) | nil,
    Function: (boolean) -> any
};

type vapedropdownargs = {
    Name: string,
    List: table,
    Function: (string) -> any
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

type vapelegitmodule = {
	GetCustomChildren: Instance,
	Object: Instance
};

type vapemodule = {
    Connections: table,
    Enabled: boolean,
    Object: Instance,
    ToggleButton: (boolean | nil, boolean | nil) -> (),
	CreateTextList: (table) -> vapetextlist,
	CreateColorSlider: (table) -> vapeslider,
	CreateToggle: (table) -> vapeminimodule,
	CreateDropdown: (vapedropdownargs) -> vapedropdown,
	CreateSlider: (table) -> vapeslider,
	CreateTextBox: (table) -> vapetextbox,
	GetCustomChildren: (table) -> vapecustomwindow,
    CreateLegitModule: (vapelegitmoduleargs) -> vapelegitmodule
};

type vapewindowapi = {
	CreateOptionsButton: (vapemoduleargs) -> vapemodule,
	SetVisible: (boolean | nil) -> ()
};

type vapewindow = {
    Api: vapewindowapi
};

type rendertarget = {
    RootPart: BasePart | Part | nil,
    Player: Player | Model | nil,
    Humanoid: Humanoid | nil,
    Human: boolean | nil
};

type rendertable = {
    utils: table
};

type rendertag = {
    text: string,
    hex: string
};

for i,v in render.utils do 
    getfenv()[i] = v 
end;

local run: (() -> any) -> () = run;
local renderconnections: table = renderconnections;
local RenderLibrary: table = RenderLibrary;

local vape: vapegui = shared.rendervape;
local render: rendertable = render;
local players: Players = getservice('Players');
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
local camera: Camera = workspace.CurrentCamera;
local lplr: Player = players.LocalPlayer;

local combat: vapewindow = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant: vapewindow = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual: vapewindow = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit: vapewindow = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility: vapewindow = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world: vapewindow = vape.ObjectsThatCanBeSaved.WorldWindow;

local store: table; store = {
    gloves = {},
	constants = setmetatable({}, {
		__index = function(self: table, index: string)
			local attr: string? = lplr:GetAttribute(index);
			local val: Instance? = lplr:FindFirstChild(index);
			local val2: Instance? = lplr.Character and lplr.Character:FindFirstChild(index);
			if attr then 
				return attr 
			end;
			if val and val.ClassName:find('Value') then 
				return val.Value
			end;
			if val2 and val2.ClassName:find('Value') then 
				return val2.Value
			end;
		end
	});
	lastSlap = tick() - 0.6,
	hitremotes = {},
	cachedhitremotes = Performance.new()
};

pcall(function() store.gloves = table.clone(require(replicatedstorage.FRONTEND.Databases.Gloves)) end);

store.hitremotes.Default = replicatedstorage:FindFirstChild('b');
store.hitremotes.Dual = replicatedstorage:FindFirstChild('GeneralHit');
store.hitremotes.Fort = replicatedstorage:FindFirstChild('Fort');
store.hitremotes.Boomerang = replicatedstorage:WaitForChild('BoomerangH');
store.hitremotes.Killstreak = replicatedstorage:FindFirstChild('KSHit');
store.hitremotes['L.O.L.B.O.M.B'] = store.hitremotes.Dual;

for i: number, v: Instance in replicatedstorage:GetChildren() do 
	if v.Name:lower():find('hit') and v.ClassName:find('Remote') then 
		table.insert(store.cachedhitremotes, v);
	end;
end;

function store:slapEntity(part: BasePart | Part): boolean
	if lplr.Character == nil or (lplr.Backpack:FindFirstChild(self.constants.Glove) or lplr.Character:FindFirstChild(self.constants.Glove)) == nil then 
		return true;
	end;
	if lplr.Character and lplr.Character:FindFirstChild('Default') and store.hitremotes.Default then 
		store.hitremotes.Default:FireServer(part);
		return true;
	end;
	if (tick() - self.lastSlap) > 0.6 then 
		self.lastSlap = tick();
		local customremote: RemoteEvent | RemoteFunction | (BasePart | Part) -> () = store.hitremotes[self.constants.Glove];
		if customremote then 
			if typeof(customremote) == 'function' then 
				task.spawn(customremote, part);
				return true;
			end;	
			if customremote.ClassName == 'RemoteEvent' then 
				customremote:FireServer(part);
				return true;
			end;
			task.spawn(customremote.InvokeServer, customremote, part);
			return true
		end;
		for i: number, v: RemoteEvent | RemoteFunction in store.cachedhitremotes do 
			if v.Name:lower():find(self.constants.Glove:lower()) then 
				if v.ClassName == 'RemoteFunction' then 
					task.spawn(v.InvokeServer, v, part);
				else
					v:FireServer(part)
				end;
				return true;
			end;
		end;
	end;
	return false;
end;

vape.SelfDestructEvent.Event:Once(function()
	for i: number, v: securetable | table? in store do 
		if typeof(v) == 'table' then 
			if v.shutdown then 
				v:shutdown();
				continue;
			end;
			table.clear(v);
		end
	end;
end);

run(function()
	local playerThreads: securetable = Performance.new();
	renderconnections[#renderconnections + 1] = RenderLibrary.runtime.events.PlayerTagCreated:Connect(function(player: Player, text: string, hex: string)
		pcall(task.cancel, playerThreads[player]);
		playerThreads[player] = task.spawn(function()
			repeat 
				pcall(function()
                    player.Character.Head.Nametag:FindFirstChildOfClass('TextLabel').RichText = true;
					player.Character.Head.Nametag:FindFirstChildOfClass('TextLabel').Text = "<font color='#"..hex.."'>["..text.."] </font> " ..player.DisplayName;
				end)
				task.wait()
			until (not getgenv().render)
		end);
	end);

	renderconnections[#renderconnections + 1] = RenderLibrary.runtime.events.PlayerTagRemoved:Connect(function(player: Player, text: string, hex: string)
		pcall(function()
			player.Character.Head.Nametag:FindFirstChildOfClass('TextLabel').Text = player.DisplayName;
		end);
		pcall(task.cancel, playerThreads[player]);
	end);

	playerThreads.oncleanevent:Connect(function(loop: thread)
		pcall(task.cancel, loop)
	end)
end);

run(function()
	local slapaura: vapemodule = {};
	local slapaurarange: vapeslider = {Value = 25};
	local slapauraAnim: vapeminimodule = {};
	local slapauramouse: vapeminimodule = {};
	local slapaurahandcheck: vapeminimodule = {};
	local slapaurabox: vapeminimodule = {};
	local slapauraboxcolor: vapecolorslider = newcolor();
	local slapauraboxtransparency: vapeslider = {Value = 5};
	local slapauraboxmaterial: vapedropdown = {Value = 'SmoothPlastic'};
	local slapauraboxes: securetable = Performance.new();
	local slapaurathread: thread;
	slapaura = blatant.Api.CreateOptionsButton({
		Name = 'SlapAura',
		HoverText = 'Automatically slaps players.',
		Function = function(calling: boolean)
			if calling then 
				slapaurathread = task.spawn(function()
					repeat
						task.wait();
						local target: rendertarget = isAlive(lplr, true) and GetTarget({radius = slapaurarange.Value, friendly = true}) or {};
						render.targets:updatehuds(target);
						if target.RootPart then 
							local chartool: Tool? = lplr.Character:FindFirstChild(store.constants.Glove);
							if chartool and slapauraAnim.Enabled then 
								lplr.Character[store.constants.Glove]:Activate()
							end;
							if slapaurahandcheck.Enabled and chartool == nil or slapauramouse.Enabled and not inputservice:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then 
								render.targets:updatehuds()
								continue;
							end;
							if store.constants.isInArena then 
								render.targets:updatehuds()
								continue
							end;
							if not store:slapEntity(target.RootPart) then 
								local oldglove: string = store.constants.Glove;
								render.targets:updatehuds();
								errorNotification('SlapAura', `Slap remote for {oldglove} not found. Please report this to the discord.`, 8);
								repeat task.wait() until (store.constants.Glove ~= oldglove or lplr.Character and lplr.Character:FindFirstChild('Default'));
							end;
							task.wait(0.6);
						end;
					until (not slapaura.Enabled)
				end);
				table.insert(slapaura.Connections, runservice.RenderStepped:Connect(function()
					local slaptarget: rendertarget? = render.targets.currentTarget;
					if slapaurabox.Enabled and slaptarget and slaptarget.RootPart then 
						for i,v in slapauraboxes do 
							if i ~= slaptarget.RootPart then 
								tween:Create(v, TweenInfo.new(0.15), {Transparency = 1}):Play()
								v:Destroy()
							end
						end;
						local box: Part = slapauraboxes[slaptarget.RootPart] or Instance.new('Part', slaptarget.Player.Character);
						box.Color = Color3.fromHSV(slapauraboxcolor.Hue, slapauraboxcolor.Sat, slapauraboxcolor.Value);
						box.Material = slapauraboxmaterial.Value;
						box.Transparency = 0.1 * slapauraboxtransparency.Value;
						box.Size = slaptarget.RootPart.Size + Vector3.new(4, 8, 4);
						box.Rotation = slaptarget.RootPart.Rotation;
						box.Position = slaptarget.RootPart.Position;
						box.Anchored = true;
						if slapauraboxes[slaptarget.RootPart] == nil then 
							box.Transparency = 1;
							tween:Create(box, TweenInfo.new(0.1), {Transparency = (0.1 * slapauraboxtransparency.Value)}):Play()
						end;
						slapauraboxes[slaptarget.RootPart] = box;
					else
						slapauraboxes:clear(function(box: Part)
							box:Destroy()
						end)
					end;
				end))
			else
				pcall(task.cancel, slapaurathread);
				slapauraboxes:clear(function(box: Part)
					box:Destroy()
				end)
			end
		end
	}); 
	slapaurarange = slapaura.CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 30,
		Default = 30,
		Function = void
	});
	slapauraAnim = slapaura.CreateToggle({
		Name = 'Animation',
		Default = true,
		Function = void
	});
	slapauramouse = slapaura.CreateToggle({
		Name = 'Mouse Check',
		HoverText = 'Only targets if you\'re holding your mouse down.',
		Function = void
	});
	slapaurahandcheck = slapaura.CreateToggle({
		Name = 'Hand Check',
		HoverText = 'Only targets if you have the glove\nin your hand.',
		Function = void
	});
	slapaurabox = slapaura.CreateToggle({
		Name = 'Target Box',
		HoverText = 'Adds a box to the target.',
		Function = function(calling: boolean)
			slapauraboxcolor.Object.Visible = calling;
			slapauraboxtransparency.Object.Visible = calling;
			slapauraboxmaterial.Object.Visible = calling;
			if not calling then 
				slapauraboxes:clear(function(box: Part)
					box:Destroy()
				end)
			end
		end
	});
	slapauraboxcolor = slapaura.CreateColorSlider({
		Name = 'Box Color',
		Function = void
	});
	slapauraboxtransparency = slapaura.CreateSlider({
		Name = 'Box Transparency',
		Min = 0,
		Max = 10,
		Default = 5,
		Function = void
	});
	slapauraboxmaterial = slapaura.CreateDropdown({
		Name = 'Material',
		List = GetEnumItems('Material'),
		Function = void
	});

	slapauraboxcolor.Object.Visible = false;
	slapauraboxtransparency.Object.Visible = false;
	slapauraboxmaterial.Object.Visible = false;
end);

run(function()
	local autoglove: vapemodule = {};
	local autoglovethread: thread;
	local autoglovetype: vapetextbox = {Value = 'Default'};
	local matchglove: (table?) -> () = function()
		for i: string, v: table? in store.gloves do 
			if i:lower():find(autoglovetype.Value:lower()) and typeof(v) == 'table' then 
				return v, workspace:WaitForChild('Lobby', 9e9):FindFirstChild(i)
			end;
		end;
	end;
	autoglove = utility.Api.CreateOptionsButton({
		Name = 'AutoGlove',
		HoverText = 'Automatically equips gloves.',
		Function = function(calling: boolean)
			if calling then 
				autoglovethread = task.spawn(function()
					repeat
						task.wait(0.1)
						if fireclickdetector == nil then 
							return errorNotification('AutoGlove', 'fireclickdetector function missing.', 10);
						end;
						if isAlive(lplr, true) == false or store.constants.isInArena then 
							continue
						end;
						local glovemeta: table?, gloveinstance: Part? = matchglove();
						if glovemeta and gloveinstance and gloveinstance:FindFirstChildOfClass('ClickDetector') and gloveinstance.Name ~= store.constants.Glove then 
							if glovemeta.SlapRequirement and glovemeta.SlapRequirement <= lplr:WaitForChild('leaderstats', 9e9):WaitForChild('Slaps', 9e9).Value then 
								fireclickdetector(gloveinstance:FindFirstChildOfClass('ClickDetector'))
							end
						end;
					until (not autoglove.Enabled)
				end)
			else
				pcall(task.cancel, autoglovethread)
			end
		end
	});
	autoglovetype = autoglove.CreateTextBox({
		Name = 'Glove',
		TempText = 'glove',
		FocusLost = void
	})
end);

run(function()
	local antiragdoll: vapemodule = {};
	local antiragdollLast: Vector3;
	local wasragdolled: boolean;
	antiragdoll = blatant.Api.CreateOptionsButton({
		Name = 'AntiRagdoll',
		HoverText = 'Prevents you from going ragdoll.',
		Function = function(calling: boolean)
			if calling then 	
				table.insert(antiragdoll.Connections, runservice.Heartbeat:Connect(function()
					if isAlive(lplr, true) then 
						if store.constants.Ragdolled then 
							lplr.Character:WaitForChild('HumanoidRootPart', 9e9).Anchored = true;
							lplr.Character:WaitForChild('HumanoidRootPart', 9e9).CFrame = antiragdollLast;
							lplr.Character:FindFirstChildOfClass('Humanoid'):ChangeState(Enum.HumanoidStateType.Landed);
							return;
						end;
						lplr.Character:WaitForChild('HumanoidRootPart', 9e9).Anchored = false;
						if wasragdolled then 
							wasragdolled = false;
							lplr.Character:WaitForChild('HumanoidRootPart', 9e9).CFrame = antiragdollLast;
						end;
						antiragdollLast = lplr.Character:WaitForChild('HumanoidRootPart', 9e9).CFrame;
					end;
				end))
			end
		end
	})
end);
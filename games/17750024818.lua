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
   CustomModules/17750024818.lua.lua (autistic version of bedwars) - SystemXVoid/BlankedVoid and relevant            
   https://renderintents.lol                                                                                                                                                                                                                                                                     
]]

for i,v in render.utils do 
    getfenv()[i] = v; 
end;

type vapeobjectsapi = {
    Api: table
};

type vapelegitmoduleargs = {
	Name: string,
	Function: (boolean) -> ()
};

type vapegui = {
    ObjectsThatCanBeSaved: vapeobjectsapi
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

type inventoryobject = {
    name: string,
    tool: Tool | nil,
    amount: number,
    class: string,
    slotType: string,
    rawmeta: table
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

local vape: table = shared.rendervape;
local combat: table = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant: table = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual: table = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit: table = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility: table = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world: table = vape.ObjectsThatCanBeSaved.WorldWindow;
local hudwindow: table = vape.ObjectsThatCanBeSaved.TargetHUDWindow;
local RenderLibrary: table = RenderLibrary;
local render: table = render;

local replicatedstorage: ReplicatedStorage = getservice('ReplicatedStorage');
local httpservice: HttpService = getservice('HttpService');
local teleport: TeleportService = getservice('TeleportService');
local players: Players = getservice('Players');
local startergui: StarterGear = getservice('StarterGui');
local inputservice: UserInputService = getservice('UserInputService');
local runservice: RunService = getservice('RunService');
local collection: CollectionService = getservice('CollectionService');
local tween: TweenService = getservice('TweenService');
local fakecam: Camera = Instance.new('Camera');
local camera: Camera = workspace.CurrentCamera;
local lplr: Player = players.LocalPlayer;
local vapetarget: table = shared.VapeTargetInfo;
local entityLibrary: table = shared.vapeentity;

local renderloaded: boolean = true;

local store; store = setmetatable({
    blocks = Performance.new(setmetatable({
        jobdelay = 3, 
    }, {
		__index = function(self: table, index: string)
			if index == 'maxamount' then 
				return renderperformance.maxcacheable
			end;
			if index == 'purge' then 
				return renderperformance.purgeonthreshold
			end;
			return rawget(self, index)
		end
	})),
    constants = setmetatable({}, {
        __index = function(self: table, index: string)
            local valdata: StringValue? = lplr:FindFirstChild(index);
            if valdata and valdata.ClassName:find('Value') then 
                return valdata.Value 
            end
        end
    }),
    beds = setmetatable({}, {
        __index = function(self: table, index: string)
            local success: boolean, beds: table? = pcall(function()
                return workspace.Map.Beds:GetChildren() 
            end);
            if success then 
                return beds 
            end;
            return {}
        end,
        __iter = function()
            local success: boolean, beds: table? = pcall(function()
                return workspace.Map.Beds:GetChildren() 
            end);
            if success then 
                return next, beds 
            end;
            return next, {}
        end,
        __len = function()
            local len: number = 0;
            for i,v in store.beds do 
                len += 1;
            end;
            return len
        end
    }),
    luckyblocks = setmetatable({}, {
        __index = function(self: table, index: string)
            local success: boolean, blocks: table? = pcall(function()
                return workspace.Map.BlocksContainer['Lucky Block']:GetChildren()
            end);
            if success then 
                return next, blocks 
            end;
            return {}
        end,
        __iter = function()
            local success: boolean, blocks: table? = pcall(function()
                return workspace.Map.BlocksContainer['Lucky Block']:GetChildren()
            end);
            if success then 
                return next, blocks 
            end;
            return {}
        end,
        __len = function()
            local len: number = 0;
            for i,v in store.luckyblocks do 
                len += 1;
            end;
            return len
        end
    }),
    npcs = setmetatable({}, {
        __index = function()
            local success: boolean, npcs: table? = pcall(function()
                return workspace.NpcsContainer:GetChildren()
            end);
            if success then 
                return npcs 
            end;
            return {}
        end,
        __iter = function()
            local success: boolean, npcs: table? = pcall(function()
                return workspace.NpcsContainer:GetChildren()
            end);
            if success then 
                return next, npcs 
            end;
            return {}
        end,
        __len = function()
            local len: number = 0;
            for i,v in store.npcs do 
                len += 1;
            end;
            return len
        end
    }),
    items = {}
}, {
    __index = function(self: table, index: string?)
        if index == 'raycast' then 
            if rawget(self, index) == nil then 
                rawset(self, 'raycast', RaycastParams.new()) 
            end;
            rawget(self, 'raycast').FilterDescendantsInstances = {self.blocks:getplainarray()};
        end;
        return rawget(self, index)
    end
});

getgenv().bedwarz = store;

pcall(function()
    store.items = require(replicatedstorage.Modules.ItemsData);
end);

function store:playanim(id: string?): number
    if isAlive() then
        local anim: Instance = Instance.new('Animation');
        anim.AnimationId = `rbxassetid://{id}`;
        lplr.Character.Humanoid.Animator:LoadAnimation(anim):Play();
    end
end

function store:getinventory(plr: Player): inventoryobject
    local player = plr or lplr;
    local inv: inventoryobject = {items = {}, hand = {}, armor = {}};
    if player:FindFirstChild('ServerInventoryFolder') then
        for i: number, v: StringValue? in player.ServerInventoryFolder:GetChildren() do 
            if v.ClassName == 'NumberValue' then 
                local tooldata: table = setmetatable({
                    name = v.Name, 
                    tool = lplr.Character and lplr.Character:FindFirstChild(v.Name) or player.Backpack:FindFirstChild(v.Name),
                    amount = v.Value,
                    class = v:GetAttribute('Class'),
                    slotType = v:GetAttribute('SlotType'),
                    rawmeta = store.items[v.Name]
                }, {
                    __index = function(self: table, index: string)
                        if index == 'amount' then 
                            return v.Value or 0
                        end
                    end
                });
                table.insert(inv.items, tooldata)
            end
        end 
    end;
    for i: number, v: table in inv.items do
        if lplr.Character and v.tool and v.tool.Parent == lplr.Character then 
            inv.hand = {
                name = v.name, 
                tool = v.tool,
                viewmodel = camera:FindFirstChild(v.name),
                class = v.class,
                meta = v
            };
        end
    end;
    return inv
end;

function store:getitem(tool: string, custominv: table?): table | nil
    for i,v in (custominv or self:getinventory()).items do 
        if v.name == tool then 
            return v
        end
    end
end;

function store:getitemfromclass(class: string, custominv: table | nil): table | nil 
    for i,v in (custominv or self:getinventory().items) do 
        if v.class == class then 
            return v 
        end
    end
end;

function store:itemfromMatch(match: string, custominv: table | nil): table | nil
    for i,v in (custominv or self:getinventory().items) do
        if v.name:find(match) then 
            return v 
        end
    end
end;

function store:getTeamFromColor(color: BrickColor): Team | nil
    for i: number, v: Team in getservice('Teams'):GetChildren() do 
        if v.TeamColor == color then 
            return v 
        end;
    end
end;

function store:getTeamates(team: Team | nil): table 
    local teamates: table = {};
    local team: Team = typeof(team) == 'Instance' and team.ClassName == 'Team' and team or lplr.Team;
    for i,v in players:GetPlayers() do 
        if v.Team == team then 
            table.insert(teamates, v)
        end
    end;
    return teamates
end;

function store:getnearestbed(range: number?, ignoreEmpty: boolean | nil): Model | nil
    if not isAlive(lplr, true) then 
        return nil
    end;
    local best: number, bed: Model? = range or math.huge, nil;
    for i,v in self.beds do 
        if v.PrimaryPart == nil then 
            continue 
        end;
        if v:GetAttribute('TeamName') == tostring(lplr.Team) or not v:GetAttribute('CanMine') then 
            continue
        end;
        local distance: number = ((render.clone.old or lplr.Character.PrimaryPart).Position - v.PrimaryPart.Position).Magnitude;
        if distance < best then 
            best = distance;
            bed = v;
        end;
    end;
    for i,v in (ignoreEmpty and self.beds or {}) do 
        if v.PrimaryPart == nil or bed == nil then 
            continue 
        end;
        if v:GetAttribute('TeamName') == tostring(lplr.Team) or not v:GetAttribute('CanMine') then 
            continue
        end;
        local oldteam: Team? = store:getTeamFromColor(bed.Mattress.BrickColor);
        local team: Team? = store:getTeamFromColor(v.Mattress.BrickColor);
        if oldteam and team and #store:getTeamates(oldteam) < 1 and #store:getTeamates(team) > 0 then 
            bed = v;
            break
        end;
    end;
    return bed
end;

function store:getluckyblock(range: number?): Model | nil 
    if not isAlive(lplr, true) then 
        return nil
    end;
    local best: number, block: Model? = range or math.huge, nil;
    pcall(function()
        for i,v in workspace.Map.BlocksContainer['Lucky Block']:GetChildren() do 
            local distance: number = ((render.clone.old or lplr.Character.PrimaryPart).Position - v.PrimaryPart.Position).Magnitude;
            if distance < best then 
                best = distance;
                block = v;
            end;
        end;
    end);
    return block
end;

function store:getplayerbed(player: Player)
    local player: Player = typeof(player) == 'Player' or player or lplr;
    for i,v in self.beds do 
        if v:FindFirstChild('Mattress') and v.Mattress.BrickColor == player.TeamColor then 
            return v 
        end
    end
end;

function store:shootprojectile(...): boolean
    local bow: inventoryobject? = self:getitemfromclass('Projectiles');
    local args: table = {...};
    local successful = pcall(function()
        bow.tool.ClientHandler.ShootArrow:FireServer(unpack(args))
    end);    
    return successful
end;

function store:switchitem(item: string): number
    local inv: table = store:getinventory();
    local switchrequest: number = tick();

    if inv.hand.name == item then 
        return 0 
    end;

    replicatedstorage.Remotes.EquipItem:FireServer(item);

    for i: number, v: table in inv.items do 
        if v.name == item and v.tool and lplr.Character:FindFirstChild(item) == nil then 
            if isAlive(lplr, true) then
                lplr.Character.Humanoid:EquipTool(v.tool);
            end;
        end
    end;

    return (tick() - switchrequest)
end;

function store:bindevent(remote: string, func: () -> any): RBXScriptConnection | nil
    local remote: RemoteEvent? = replicatedstorage.Remotes:FindFirstChild(remote);
    if remote and remote.ClassName == 'RemoteEvent' then 
        return remote.OnClientEvent:Connect(func)
    end;
end;

local refreshblockcache = function()
    store.blocks:clear();
    for i,v in workspace.Map.BlocksContainer:GetChildren() do 
        for i2, v2 in v:GetChildren() do 
            table.insert(store.blocks, v2)
        end
    end;
    table.insert(render.utils.renderconnections, workspace.Map.BlocksContainer.DescendantAdded:Connect(function(block: Part?)
        if block.ClassName:lower():find('part') then 
            table.insert(store.blocks, block)
        end
    end));
end;

render.utils.SetTargetValidation(function(plr: Player)
    return (isAlive(plr) and tostring(plr.Team) ~= 'Spectator')
end);

task.spawn(function()
	repeat 
		camera = workspace.CurrentCamera or fakecam;
		task.wait()
	until (not renderloaded)
end);

table.insert(renderconnections, task.spawn(function()
    repeat
        if isEnabled('Autowin') and not isAlive() then 
            camera.CameraSubject = nil;
        end;
        task.wait();
    until false;
end));

task.spawn(function()
    repeat task.wait() until workspace:FindFirstChild('Map') and workspace.Map:FindFirstChild('BlocksContainer');
    refreshblockcache();
    table.insert(render.utils.renderconnections, workspace.DescendantAdded:Connect(function(instance: Folder?)
        if instance.Name == 'BlocksContainer' then 
            refreshblockcache()
        end
    end));
    table.insert(render.utils.renderconnections, workspace.DescendantRemoving:Connect(function(instance: Folder?)
        if instance.Name == 'BlocksContainer' then 
            store.blocks:clear();
        end
    end))
end);

store.raycast.FilterType = Enum.RaycastFilterType.Include;
store.raycast.FilterDescendantsInstances = {store.blocks:getplainarray()};

run(function()
	local playerThreads: securetable = Performance.new({jobdelay = 0.05});
	render.utils.renderconnections[#render.utils.renderconnections + 1] = RenderLibrary.runtime.events.PlayerTagCreated:Connect(function(player: Player, text: string, hex: string)
		pcall(task.cancel, playerThreads[player]);
		playerThreads[player] = task.spawn(function()
			repeat 
				pcall(function()
                    player.Character.NameDisplayGui.NameLabel.RichText = true;
					player.Character.NameDisplayGui.NameLabel.Text = "<font color='#"..hex.."'>["..text.."] </font> " ..player.DisplayName;
				end)
				task.wait()
			until (not getgenv().render)
		end);
	end);

	render.utils.renderconnections[#render.utils.renderconnections + 1] = RenderLibrary.runtime.events.PlayerTagRemoved:Connect(function(player: Player, text: string, hex: string)
		pcall(function()
            player.Character.NameDisplayGui.NameLabel.RichText = true;
			player.Character.NameDisplayGui.NameLabel.Text = player.DisplayName;
		end);
		pcall(task.cancel, playerThreads[player]);
	end);

	playerThreads.oncleanevent:Connect(task.cancel)
end);

local oldswordC0;
local killaurarange: vapeminimodule = {Value = 30};
run(function() --> code sucks because had to remove GetAllTarget implementation from this.
    local killaura: vapemodule = {};
    local killauraboxes : table = Performance.new();
    local killaurahighlight: vapemodule = {};
    local killaurahighlightcolor: table = newcolor();
    local killauraAnimation: table = {Value = 'Charge'};
    local killaurasortmethod: table = {Value = 'Distance'};
    local killaurafacetarget: vapeminimodule = {};
    local killaurahandcheck: vapeminimodule = {};
    local killaurabox;
    local animtween;
    local killauraAnimationThread;
    local killauraplayinganim;
    local oldtarget;
    local getfriends = function(player: Player) 
        local friends = {};
        local success, page = pcall(players.GetFriendsAsync, players, player.UserId);
        if success then
            repeat
                for i,v in page:GetCurrentPage() do
                    table.insert(friends, v.UserId);
                end
                if not page.IsFinished then 
                    page:AdvanceToNextPageAsync();
                end
            until page.IsFinished
        end
        return friends;
    end;
    local killauraAnimations = {
        Charge = {
            {
                angles = (CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-50), math.rad(0), math.rad(0))),
                duration = 0.1,
            },
            {
                angles = (CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-58), math.rad(0), math.rad(0))),
                duration = 0.1,
            },
        },
        Render = {
            {
                angles = CFrame.new(0.2, 0, -1.3) * CFrame.Angles(math.rad(0), math.rad(-50), math.rad(0)),
                duration = 0.16,
            },
            {
                angles = CFrame.new(0, -3, 1) * CFrame.Angles(math.rad(0), math.rad(-100), math.rad(0)),
                duration = 0.16,
            },
        }
    };
    local killaurasort: table = {
		Distance = function(a, b)
			local newmag = (a.RootPart.Position - lplr.Character.PrimaryPart.Position).Magnitude
			local oldmag = (a.RootPart.Position - b.RootPart.Position).Magnitude
			return (newmag < oldmag)
		end,
		Health = function(a, b)
			return (b.Humanoid.Health > a.Humanoid.Health)
		end,
		Switch = false
	};
    killaura = blatant.Api.CreateOptionsButton({
        Name = 'Killaura',
        HoverText = 'Automatically attacks players.',
        Function = function(calling: boolean)
            if calling then 
                killauraAnimationThread = task.spawn(function()
                    repeat 
                        pcall(function()
                            for i,v in (killauraAnimations[killauraAnimation.Value] or {}) do 
                                local inv = store:getinventory();
                                local suc: boolean, viewmodelhandle: Motor6D? = pcall(function()
                                    return camera:FindFirstChildOfClass('Model').PrimaryPart:FindFirstChildOfClass('Motor6D')
                                end);
                                if suc == false or viewmodelhandle == nil then 
                                    continue
                                end;
                                if viewmodelhandle and oldswordC0 == nil then 
                                    oldswordC0 = viewmodelhandle.C0;
                                end;
                                if vapetarget.Targets.Killaura == nil then 
                                    if killauraplayinganim then 
                                        animtween:Cancel();
                                        tween:Create(viewmodelhandle, TweenInfo.new(0.4), {C0 = oldswordC0}):Play()
                                        killauraplayinganim = false;
                                    end;
                                    continue
                                end;
                                local playedAt = tick();
                                animtween = tween:Create(viewmodelhandle, TweenInfo.new(v.duration), {C0 = oldswordC0 * v.angles});
                                animtween:Play();
                                killauraplayinganim = true;
                                repeat task.wait() until ((tick() - playedAt) >= v.duration or vapetarget.Targets.Killaura == nil or viewmodelhandle.Parent == nil);
                                store:playanim(90863403397957)
                            end;
                        end)
                        task.wait()
                    until (not killaura.Enabled)
                end);
                table.insert(killaura.Connections, runservice.Heartbeat:Connect(function()
                    local target = isAlive(lplr, true) and tostring(lplr.Team) ~= 'Spectator' and GetTarget({
                        radius = killaurarange.Value,
                        pos = lplr.Character.PrimaryPart.Position,
                        friendly = false
                    });
                    if typeof(target) ~= 'table' or target.RootPart == nil then 
                        vapetarget.Targets.Killaura = nil;
                        render.targets:updatehuds();
                        for i: number, v: BoxHandleAdornment? in killauraboxes do 
                           pcall(function() v:Destroy() end);
                        end;
                        table.clear(killauraboxes);
                        return;
                    end;
                    for i,v in {target} do 
                        if oldtarget ~= v.Player.Character then 
                            for i: number, v: BoxHandleAdornment? in killauraboxes do 
                                pcall(function() v:Destroy() end);
                            end;
                            table.clear(killauraboxes);
                        end;
                        local sword: table = store:itemfromMatch('Hammer') or store:getitemfromclass('Swords');
                        if sword and tostring(lplr.Team) ~= 'Spectators' then
                            if killaurahandcheck.Enabled and store.hand.name ~= sword.name then 
                                return
                            end;
                            oldtarget = v.Player.Character; 
                            vapetarget.Targets.Killaura = v;
                            if killaurahighlight.Enabled and v.Player.Character and v.Player.Character:FindFirstChildOfClass('BoxHandleAdornment') == nil then 
                                local box: BoxHandleAdornment = killaurabox:Clone();
								box.Parent = v.Player.Character;
								box.Adornee = v.Player.Character;
								box.Color3 = Color3.fromHSV(killaurahighlightcolor.Hue, killaurahighlightcolor.Sat, killaurahighlightcolor.Value)
								table.insert(killauraboxes, box);
                            end;
                            local predictionvec: Vector3 = ({pcall(function() return CFrame.new(lplr.Character.PrimaryPart.Position - v.RootPart.Position).LookVector end)})[2];
                            task.spawn(function()
                                store:switchitem(sword.name)
                            end);
                            for _: number = 1,3 do
                                replicatedstorage.Remotes.ItemRemotes.SwordAttack:FireServer(v.RootPart.Position - v.RootPart.CFrame.LookVector, (v.RootPart.Position - lplr.Character.PrimaryPart.Position).Magnitude < 3 and v.RootPart.CFrame.LookVector or predictionvec, sword.name)
                            end
                            render.targets:updatehuds(v);
                        end;
                    end
                end))
            else
                vapetarget.Targets.Killaura = nil;
                render.targets:updatehuds();
                for i: number, v: BoxHandleAdornment? in killauraboxes do
                    pcall(function() v:Destroy() end)
                end;
                table.clear(killauraboxes);
                pcall(task.cancel, killauraAnimationThread);
                pcall(function()
                    tween:Create(camera:FindFirstChildOfClass('Model').PrimaryPart:FindFirstChildOfClass('Motor6D'), TweenInfo.new(0.4), {C0 = oldswordC0}):Play()
                end)
            end 
        end,
        ExtraText = function()
            return 'Suffocation'
        end
    });
    killauraAnimation = killaura.CreateDropdown({
        Name = 'Animation',
        Function = void,
        List = {'Charge', 'Render'},
        Default = 'Render'
    })
    killaurarange = killaura.CreateSlider({
        Name = 'Range',
        Min = 1,
        Max = 22,
        Default = 22,
        Function = void
    });
    killaurahighlight = killaura.CreateToggle({
        Name = 'Target Box',
        HoverText = 'Adds a bounding box to the target.',
        Function = function(calling: boolean)
            if calling then 
				pcall(function() killaurahighlightcolor.Object.Visible = calling end);
				killaurabox = Instance.new('BoxHandleAdornment', vape.MainGui);
				killaurabox.Transparency = 0.85;
				killaurabox.Color3 = Color3.fromHSV(killaurahighlightcolor.Hue, killaurahighlightcolor.Sat, killaurahighlightcolor.Value);
				killaurabox.Size = Vector3.new(4.5, 6, 4.5);
				killaurabox.AlwaysOnTop = true;
				killaurabox.ZIndex = 9e9;
			else 
				pcall(function() killaurabox:Destroy() end);
				killaurabox = nil;
                for i: number, v: BoxHandleAdornment? in killauraboxes do  
                    pcall(function() v:Destroy() end)
                end;
                table.clear(killauraboxes)
			end
        end
    });
    killaurahighlightcolor = killaura.CreateColorSlider({
        Name = 'Box Color',
        Function = void
    });
    killaurafacetarget = killaura.CreateToggle({
        Name = 'Face Target',
        HoverText = 'looks at your opp.',
        Function = void
    });
    killaurahighlightcolor.Object.Visible = false;
end);

run(function()
    local staffdetector: table = {};
    local staffdetectoraction: table = {Value = 'ServerHop'};
    local staffdetected;
    local staffaltTable: table = {'MyUserisDai_Alt'};
    local stafftable: table = httpservice:JSONDecode('["GameMaster4268","BedwarzAcMod","ohhiimnoobinarsenal2","DaiPlayzOnYT","llIIIlllllIIIIllII","doggy2918","Romansalt50","bubman920","minitoonfreind","Alexklysz2015","TanqrCletus","parham2020p","bedwarzontop1","BedwarzBlankMod","HamdanYTTVV","Tanpr_dom67","UseAsuraV4","GrumpyGravySeerp","Lordheaven_prime"]');
    local staffactions: table = {
        Uninject = function(plr: Player)
            if not syn_toast_notification  then
                startergui:SetCore('SendNotification', {
                    Title = 'StaffDetector',
                    Text = `{plr.DisplayName} (@{plr.Name}) is an active staff for Bedwarz.`,
                    Duration = 60
                });
            else
                syn.toast_notification({
                    Title = 'StaffDetector',
                    Content = `{plr.DisplayName} (@{plr.Name}) is an active staff for Bedwarz.`,
                    Duration = 60,
                    Type = 4
                })
            end
            return vape.SelfDestruct()
        end,
        ServerHop = function()
            vape.SaveSettings = void; 
            for i,v in vape.ObjectsThatCanBeSaved do 
                if v.Type == 'OptionsButton' and v.Api.Enabled then 
                    v.Api.ToggleButton()
                end
            end;
            getnewserver({sort = 'Players', place = game.PlaceId == 18836990947 and '17750024818'}):andThen(function(server: string)
                teleport:TeleportToPlaceInstance(game.PlaceId == 18836990947 and '17750024818' or game.PlaceId, server, lplr)
            end)         
        end,
        Notify = void
    };
    local staffdetection: () -> () = function(player: Player)
        if table.find(stafftable, player.Name) or table.find(staffaltTable, player.Name) then 
           errorNotification('StaffDetector', `{player.DisplayName} (@{player.Name}) is an active staff for Bedwarz.`, 60);
           if staffdetected then return end;
           staffdetected = true;
           return staffactions[staffdetectoraction.Value](player) 
        end
    end;
    staffdetector = utility.Api.CreateOptionsButton({
        Name = 'StaffDetector',
        HoverText = 'Alerts you when a staff is present.',
        Function = function(calling: boolean)
            if calling then 
                if replicatedstorage:FindFirstChild('Admins') then 
                    for i: number, v: StringValue in replicatedstorage.Admins:GetChildren() do 
                        if table.find(stafftable, v.Name) == nil then 
                            table.insert(stafftable, v.Name);
                        end;
                    end;
                end;
                for i: number, v: Player in players:GetPlayers() do 
                    task.spawn(staffdetection, v)
                end;
                table.insert(staffdetector.Connections, players.PlayerAdded:Connect(staffdetection))
            end
        end
    })
    staffdetectoraction = staffdetector.CreateDropdown({
        Name = 'Action',
        List = dumplist(staffactions, nil, function(a: string, b: string) return a == 'Uninject' end),
        Function = void
    })
end);

run(function()
    local bedesp: table = {};
    local bedesphighlights: securetable = Performance.new();
    bedesp = visual.Api.CreateOptionsButton({
        Name = 'BedESP',
        HoverText = 'Allows you to see beds through blocks.',
        Function = function(calling: boolean)
            if calling then 
                repeat 
                    for i: number, v: Model in store.beds do 
                        pcall(function()
                            if v:FindFirstChildOfClass('Highlight') == nil then 
                                local highlight: Highlight = Instance.new('Highlight');
                                highlight.FillColor = v.Mattress.Color;
                                highlight.OutlineTransparency = 1;
                                highlight.FillTransparency = 0;
                                highlight.Parent = v;
                                highlight.Adornee = v;
                                table.insert(bedesphighlights, highlight)
                            end
                        end)
                    end
                    task.wait(0.1)
                until (not bedesp.Enabled)
            else 
                bedesphighlights:clear(game.Destroy)
            end
        end
    })
end);

run(function()
    local bedfucker: vapemodule = {};
    local bedfuckerswitchtool: vapeminimodule = {}
    local bedfuckerboxtransparency: vapeminimodule = {}
    local bedfuckerbox: table = {};
    local bedfuckercolormain: table = newcolor();
    local bedfuckercolorbreak: table = newcolor();
    local bedfuckerswitchtick: number = tick();
    local bedfuckerthread;
    local lasthighlight;
    local bedhighlight;
    local highlights = Performance.new();
    local lastblock;
    local damageblock = function(bed: Model)
        if highlights[bed] and lastblock ~= bed then 
            pcall(function() highlights[bed]:Destroy() end);
        end;
        local box: BoxHandleAdornment = bed:FindFirstChildOfClass('BoxHandleAdornment') or Instance.new('BoxHandleAdornment');
        box.Transparency = box.Parent and box.Transparency or 1;
        box.Color3 = Color3.fromHSV(bedfuckercolormain.Hue, bedfuckercolormain.Sat, bedfuckercolormain.Value);
        box.Size = bed.PrimaryPart.Size + Vector3.new(2, 2, 2);
        box.AlwaysOnTop = true;
        box.ZIndex = 9e9;
        box.Adornee = bed;
        highlights[bed] = box;
        if box.Parent == nil then
            box.Parent = bedfuckerbox.Enabled and bed or nil;
            tween:Create(box, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Transparency = bedfuckerboxtransparency.Value or 0.55}):Play(); 
        end;
        lastblock = bed;
        local tool: table? = store:getitemfromclass('Axes') or store:getitemfromclass('Pickaxes');
        if bedfuckerswitchtool.Enabled and ((tick() - bedfuckerswitchtick) > 0.25 or not vapetarget.Targets.Killaura) then
            bedfuckerswitchtick = tick();
            store:switchitem(tool.name);
        end
        local s, successful: boolean? = pcall(function()
            return replicatedstorage.Remotes.DamageBlock:InvokeServer(bed, tool and tool.name)
        end);
        if s and successful then
            store:playanim(17768898198);
            local colortween: Tween = tween:Create(box, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Color3 = Color3.fromHSV(bedfuckercolorbreak.Hue, bedfuckercolorbreak.Sat, bedfuckercolorbreak.Value)});
            colortween:Play();
            --colortween.Completed:Wait();
            task.delay(0.3, function()
                tween:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Color3 = Color3.fromHSV(bedfuckercolormain.Hue, bedfuckercolormain.Sat, bedfuckercolormain.Value)}):Play();
            end);
        end;
    end;
    bedfucker = world.Api.CreateOptionsButton({
        Name = 'Nuker',
        HoverText = 'Automatically breaks block(s) in a certain range.',
        Function = function(calling: boolean)
            if calling then 
                table.insert(bedfucker.Connections, runservice.Heartbeat:Connect(function()
                    local block: Model? = store:getnearestbed(25) or store:getluckyblock(25);
                    if block and tostring(lplr.Team) ~= 'Spectator' then 
                        damageblock(block);
                        return
                    else 
                        lastblock = nil;
                        highlights:clear(function(highlight: BoxHandleAdornment)
                            highlight:Destroy()
                        end)
                    end; 
                end))
            else
                highlights:clear(function(highlight: BoxHandleAdornment)
                    highlight:Destroy()
                end);
            end
        end
    });
    bedfuckerswitchtool = bedfucker.CreateToggle({
        Name = 'Switch',
        Default = true,
        Function = void
    })
    bedfuckerbox = bedfucker.CreateToggle({
        Name = 'Box',
        HoverText = 'Highlights the target bed.',
        Default = true,
        Function = function(calling: boolean)
            pcall(function()    
                bedfuckercolormain.Object.Visible = calling;
                bedfuckercolorbreak.Object.Visible = calling;
            end)
        end
    });
    bedfuckerboxtransparency = bedfucker.CreateSlider({
        Name = 'Transparency',
        Function = void,
        Default = 0.36
    })
    bedfuckercolormain = bedfucker.CreateColorSlider({
        Name = 'Main Color',
        Function = void
    });
    bedfuckercolorbreak = bedfucker.CreateColorSlider({
        Name = 'Break Color',
        Function = void
    });
    bedfuckercolormain.Object.Visible = false;
    bedfuckercolorbreak.Object.Visible = false;
end);

run(function()
    local detectiondisabler: table = {};
    local disablerhook: (...any) -> any;
    detectiondisabler = utility.Api.CreateOptionsButton({
        Name = 'AntiFlag',
        HoverText = 'Disables client side checks (95% percent of the checks)',
        Function = function(calling: boolean)
            if calling then 
                if not disablerhook then 
                    disablerhook = hookmetamethod(replicatedstorage, '__namecall', function(self: Instance, ...)
                        if detectiondisabler.Enabled and getnamecallmethod():find('Server') and (self == ({pcall(function() return replicatedstorage.Remotes.CheckAnticheat end)})[2] or tostring(self) == 'Suffocate') then
                            return ({Respond = void})
                        end;
                        return disablerhook(self, ...)
                    end);
                end;
            end
        end
    })
end);


run(function()
    local fastdrop: table = {};
    fastdrop = utility.Api.CreateOptionsButton({
        Name = 'FastDrop',
        HoverText = 'Drop items without delay when holding Q.',
        Function = function(calling: boolean)
            if calling then 
                repeat
                    task.spawn(function()
                        for i,v in store:getinventory().items do 
                            v = v.meta or v;
                            if v.rawmeta and not v.rawmeta.Droppable then 
                                continue 
                            end;
                            if v.tool == nil or v.tool.Parent ~= lplr.Character then 
                                continue 
                            end;
                            if inputservice:IsKeyDown(Enum.KeyCode.Q) then 
                                replicatedstorage.Remotes.DropItem:FireServer(v.name, 'One')
                            end;
                        end;
                    end);
                    task.wait()
                until (not fastdrop.Enabled) 
            end
        end
    })
end);

run(function()
    local autotoxic: vapemodule = {};
    local autotoxickill: vapeminimodule = {};
    local autotoxicwin: vapeminimodule = {};
    local autotoxiclose: vapeminimodule = {};
    local autotoxicyap: vapeminimodule = {};
    local autotoxickillmessages: vapetextlist = {ObjectList = {}};
    local autotoxicwinmessages: vapetextlist = {ObjectList = {}};
    local autotoxiclosemessages: vapetextlist = {ObjectList = {}};
    local autotoxicyapmessages: vapetextlist = {ObjectList = {}};
    local autotoxicyappers: table = {};
    local renderdomains: table = {
        'renderintents.xyz',
        'renderintents.lol'
    };
    local autotoxicdefault: table = {
        kill = {
            '<name> you\'re bad, just use render. | renderintents.xyz',
            'daiplayz is an nn skid <name> | renderintents.xyz',
            '"we get notified if u encountered a low ping" :scream:" - daiplayz',
            '"im always gonna serverhop to find you" - daiplayz',
            'this game still hasn\'t fixed their anticheat :sob: | renderintents.xyz',
            'render is undetectable, untouchable and unpatchable <name> lol | renderintents.xyz'
        },
        win = {
            'this game was easily crumbled by render. | renderintents.xyz',
            'You guys should of used render. | renderintents.xyz',
        },
        lose = {
            'My renderer wasn\'t rendering, therefore I lost <name>.'
        },
        yap = {
            'yap away for me <name> | renderintents.xyz',
            'cry me a river <name> | renderintents.xyz',
            'omg guys haker!1!!1 | renderintents.xyz'
        }
    };
    local autotoxicphrases: table = {
        'hack',
        'L ',
        ' L',
        'skid',
        'cheater',
        'scripter',
        'script'
    };
    
    local sendtoxicmessage = function(type: string, messagetab: table, name: string)
        local message: string = getrandomvalue(messagetab.ObjectList) ~= '' and `{getrandomvalue(messagetab.ObjectList)} | renderintents.xyz` or getrandomvalue(autotoxicdefault[type]);
        return sendmessage(message:gsub('<name>', name):gsub('renderintents.xyz', getrandomvalue(renderdomains)))
    end;
    autotoxic = utility.Api.CreateOptionsButton({
        Name = 'AutoToxic',
        HoverText = 'Automatically acts toxic to enemies.',
        Function = function(calling: boolean)
            if calling then 
                table.insert(autotoxic.Connections, store:bindevent('KillFeed', function(killer: Player, victim: Player)
                    if killer == lplr and victim and victim ~= lplr and store:getplayerbed(victim) == nil and autotoxickill.Enabled then 
                        return sendtoxicmessage('kill', autotoxickillmessages, victim.DisplayName)
                    end;
                    if killer and killer ~= lplr and victim == lplr and store:getplayerbed() == nil and autotoxiclose.Enabled then 
                        return sendtoxicmessage('lose', autotoxiclosemessages, killer.DisplayName)
                    end;
                end));
                table.insert(autotoxic.Connections, store:bindevent('DisplayWinner', function(team: Team)
                    if team == tostring(lplr.Team) and autotoxicwin.Enabled then 
                        return sendtoxicmessage('win', autotoxicwinmessages, '')
                    end
                end));
                table.insert(autotoxic.Connections, render.events.message.Event:Connect(function(player: Player, message: string)
                    if autotoxicyap.Enabled and player ~= lplr and table.find(autotoxicyappers, player.UserId) == nil then 
                        for _: number, v: string in autotoxicphrases do 
                            if message:lower():find(v:lower()) then 
                                table.insert(autotoxicyappers, player.UserId);
                                return sendtoxicmessage('yap', autotoxicyapmessages, player.DisplayName)
                            end
                        end
                    end;
                end))
            end
        end
    });
    autotoxickill = autotoxic.CreateToggle({
        Name = 'Final Kill',
        Default = true,
        Function = void
    });
    autotoxicwinmessages = autotoxic.CreateToggle({
        Name = 'Win',
        Default = true,
        Function = void
    });
    autotoxiclose = autotoxic.CreateToggle({
        Name = 'Lose',
        Function = void
    });
    autotoxicyap = autotoxic.CreateToggle({
        Name = 'Complain',
        Default = true,
        Function = void
    });
    autotoxickillmessages = autotoxic.CreateTextList({
        Name = 'Kill Messages',
        TempText = 'kill messages',
        AddFunction = void
    });
    autotoxicwin = autotoxic.CreateTextList({
        Name = 'Kill Messages',
        TempText = 'win messages',
        AddFunction = void
    });
    autotoxiclose = autotoxic.CreateTextList({
        Name = 'Lose Messages',
        TempText = 'lose messages',
        AddFunction = void
    });
    autotoxicyapmessages = autotoxic.CreateTextList({
        Name = 'Yap Messages',
        TempText = 'complain messages',
        Function = void
    });
end);

run(function() --> works
	local projectileaura: vapemodule = {};
    local projectileauraswitch: vapeminimodule = {};
	projectileaura = blatant.Api.CreateOptionsButton({
		Name = 'ProjectileAura',
		HoverText = 'Automatically shoots projectile ammo.',
		Function = function(calling: boolean)
			if calling then 
				repeat
					local target: rendertarget = GetTarget();
                    local tool: table = store:getitemfromclass('Projectiles');
                    if target.RootPart and isAlive(lplr, true) and tool and not render.targets.currentTarget then 
                        if projectileauraswitch.Enabled then
                            store:switchitem(tool.name);
                        end;
                        store:shootprojectile(target.RootPart.Position, lplr.Character.PrimaryPart.Position, getrandomvalue({100, 200}))
                    end;
					task.wait()
				until (not projectileaura.Enabled)
			end
		end
	});
    projectileauraswitch = projectileaura.CreateToggle({
        Name = 'Switch',
        HoverText = 'Automatically switches to bow.',
        Function = void
    })
end);

run(function()
    local schematica: vapemodule = {};
    local schematicafile: vapetextbox = {Value = 'penis'};
    local schematicabuildtime: vapeslider = {Value = 0};
    local schematicathread;
    schematica = world.Api.CreateOptionsButton({
        Name = 'Schematica',
        HoverText = 'Automatically builds structure with blocks.',
        Function = function(calling: boolean)
            if calling then 
                schematicathread = task.spawn(function()
                    local tab: table? = ({pcall(function()
                        return httpservice:JSONDecode(readfile(`rendervape/configuration/schematica/{schematicafile.Value:gsub('.json', '')}.json`));
                    end)})[2];
                    
                    if typeof(tab) ~= 'table' then 
                        errorNotification('Schematica', `/configuration/schematica/{schematicafile.Value:gsub('.json', '')}.json is missing.`)
                        return schematica.ToggleButton()
                    end;
                    local block: table? = isAlive(lplr, true) and store:getitemfromclass('Blocks') or nil;
                    if block == nil then 
                        errorNotification('Schematica', `Block(s) missing/not supported.`)
                        return schematica.ToggleButton()
                    end;
                    local placepos = ((lplr.Character.HumanoidRootPart.CFrame + (lplr.Character.HumanoidRootPart.CFrame.LookVector * 2.5))).Position;
                    for i: number, v: table? in tab do 
                        if typeof(v) ~= 'table' then 
                            errorNotification('Schematica', `/configuration/schematica/{schematicafile.Value:gsub('.json', '')}.json contains a syntax error at pos {i}.`);
                            return schematica.ToggleButton();
                        end;
                        local packagedvec: table = {};
                        table.foreach(v, function(__: number?, int: number?)
                            if typeof(int) ~= 'number' then 
                                return errorNotification('Schematica', `/configuration/schematica/{schematicafile.Value:gsub('.json', '')}.json (in the {i} section) contains a syntax error at pos {__}.`);
                            end;
                            table.insert(packagedvec, int);
                        end);
                        if #packagedvec > 2 then
                            task.wait(0.1 * schematicabuildtime.Value);
                            task.spawn( replicatedstorage.Remotes.ItemRemotes.PlaceBlock.InvokeServer, replicatedstorage.Remotes.PlaceBlock, placepos + Vector3.new(unpack(packagedvec)), block.name);
                        end;
                    end;
                    if schematica.Enabled then 
                        schematica.ToggleButton();
                    end;
                    InfoNotification('Schematica', 'Finished placing structure.', 5)
                end);
            else
                pcall(task.cancel, schematicathread)
            end 
        end
    });
    schematicafile = schematica.CreateTextBox({
        Name = 'File',
        TempText = 'file (no extension)',
        FocusLost = void
    });
    schematicabuildtime = schematica.CreateSlider({
        Name = 'Delay',
        Min = 0,
        Max = 15,
        Function = void
    })
end);

run(function()
    local loot: vapemodule = {}
    local loottab = {
        'Iron',
        'Diamond',
        'Emerald'
    }
    loot = exploit.Api.CreateOptionsButton({
        Name = 'FakeLootDropper',
        Function = function(call: boolean)
            if call then
                table.insert(loot.Connections, runservice.RenderStepped:Connect(function()
                    for _: number = 1,2 do
                        replicatedstorage.Remotes.DropItem:FireServer(loottab[math.random(1,3)], tostring(-math.huge))
                    end
                end))
            end
        end
    })
end)

run(function()
    local autobuy: vapemodule = {}
    local autobuyradius: vapeminimodule = {}
    local autobuyarmor: vapeminimodule = {}
    local autobuysword: vapeminimodule = {}
    local autobuycustom: vapeminimodule = {}
    local autobuyignore: table = {}
    local swordtier: table = {
        [1] = {
            name = 'Stone Sword', 
            currency = 'Iron', 
            price = 20
        },
        [2] = {
            name = 'Iron Sword', 
            currency = 'Iron', 
            price = 70
        },
        [3] = {
            name = 'Wooden Sword', 
            currency = 'Emerald', 
            price = 4
        },
        [4] = {
            name = 'Emerald Sword', 
            currency = 'Emerald', 
            price = 20
        }
    }
    local armortier: table = {
        [1] = {
            name = 'Leather Armor', 
            currency = 'Iron', 
            price = 
            60
        },
        [2] = {
            name = 'Iron Armor', 
            currency = 'Iron', 
            price = 150
        },
        [3] = {
            name = 'Diamond Armor', 
            currency = 'Emerald', 
            price = 8
        },
        [4] = {
            name = 'Emerald Armor', 
            currency = 'Emerald', 
            price = 40
        }
    }
    local currswordtier: number = 0
    local currarmortier: number = 0
    local getnpc = function(npctype, distance)
        if not isAlive() then return end
        if npctype == nil then return end
        if not workspace.Map:FindFirstChild('NpcContainer') or #workspace.Map:FindFirstChild('NpcContainer'):GetChildren() >= 0 then
            table.clear(autobuyignore)
            return
        end
        for i,v in workspace.Map:FindFirstChild('NpcContainer'):GetChildren() do
            if (v.Name:lower() == 'teamupgrader' and npctype:lower():find('team') or v.Name:lower() == 'shopkeeper' and npctype:lower():find('person')) then
                local mag = (lplr.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude
                if mag < (distance or 23) then
                    return v
                end
            end
        end
    end
    local autobuyfunc = function(npc)
        task.spawn(function()
            if autobuyarmor.Enabled then
                for i,v in armortier do
                    local armor = lplr.ArmorFolder:FindFirstChild(v.name)
                    if not armor and not autobuyignore[v.name] then
                        local currency = store:getitem(v.currency)
                        if currency then
                            local amount = currency.amount
                            if amount >= v.price then
                                antihithook = true
                                replicatedstorage.Remotes.PurchaseItem:InvokeServer(v.name)
                                autobuyignore[v.name] = true
                                task.wait()
                                antihithook = false
                            end
                        end
                    end
                end
            end
        end)
        task.spawn(function()
            for i,v in autobuycustom.ObjectList do
                local item = v:split('/')
                if #item <= 2 then return end
                local currency = store:getitem(item[2])
                if currency then
                    local amount = currency.amount
                    if amount >= tonumber(item[3]) then
                        antihithook = true
                        replicatedstorage.Remotes.PurchaseItem:InvokeServer(item[1])
                        task.wait()
                        antihithook = false
                    end
                end
            end
        end)
        if autobuysword.Enabled then
            for i,v in swordtier do
                local item = store:getitem(v.name)
                if not item and not autobuyignore[v.name] then
                    local currency = store:getitem(v.currency)
                    if currency then
                        local amount = currency.amount
                        if amount >= v.price then
                            antihithook = true
                            replicatedstorage.Remotes.PurchaseItem:InvokeServer(v.name)
                            autobuyignore[v.name] = true
                            task.wait()
                            antihithook = false
                        end
                    end
                end
            end
        end
    end
    autobuy = utility.Api.CreateOptionsButton({
        Name = 'AutoBuy',
        Function = function(call: boolean)
            if call then
                table.insert(autobuy.Connections, runservice.RenderStepped:Connect(function()
                    local npc: Instance = pcall(getnpc, 'personal', autobuyradius.Value);
                    if npc then
                        pcall(autobuyfunc, npc);
                    end;
                end))
            end;
        end;
    })
    autobuyradius = autobuy.CreateSlider({
        Name = 'Range',
        Function = void,
        Min = 1,
        Max = 23,
        Default = 16
    })
    autobuysword = autobuy.CreateToggle({
        Name = 'Weapon',
        Function = void,
        Default = true
    })
    autobuyarmor = autobuy.CreateToggle({
        Name = 'Armor',
        Function = void,
        Default = true
    })
    autobuycustom = autobuy.CreateTextList({
        Name = 'Custom Item',
        TempText = 'Enter <item>/<currency>/<amount>',
        Function = void
    })
end);

run(function()
    local autowin: vapemodule = {}
    local autowinspot: table = {};
    local autowinthread: any;
    autowin = utility.Api.CreateOptionsButton({
        Name = 'AutoWin',
        Function = function(call: boolean)
            if call then
                autowinthread = task.spawn(function()
                    repeat
                        if tostring(lplr.Team) ~= 'Spectators' then
                            for i,v in store.beds do
                                local part =  v:FindFirstChildWhichIsA('Part')
                                if part then
                                    autowincurrentpos = {cframe = part.CFrame, position = part.Position}
                                    repeat task.wait(0.25) until part.Parent == nil
                                end
                                table.clear(autowincurrentpos)
                            end
                        end
                        task.wait()
                    until (not autowin.Enabled)
                end)
                table.insert(autowin.Connections, runservice.Stepped:Connect(function()
                    if tostring(lplr.Team) ~= 'Spectators' and #autowinspot > 0 then
                        local target = isAlive(lplr, true) and tostring(lplr.Team) ~= 'Spectator' and GetTarget({
                            radius = killaurarange.Value,
                            pos = autowinspot.position
                        });
                        if target then
                            lplr.Character.PrimaryPart.CFrame = target.RootPart.CFrame
                        else
                            lplr.Character.PrimaryPart.CFrame = autowinspot.cframe
                        end
                    end
                end))
            else
                pcall(task.cancel, autowinthread)
            end
        end
    })
end)


run(function()
    local scaffold: vapemodule = {}
    local scaffoldtick: number = tick()
    local scaffoldpositions: table = {}
    local getPosition = function(root: Instance): ()
        local nearlastblock: boolean = false;
        for i,v in scaffoldpositions do
            local mag = (root.Position - v).magnitude;
            print(mag)
            if mag < 1.25 then
                nearlastblock = true;
                table.clear(scaffoldpositions);
                break;
            end;
        end;
        if not nearlastblock then
            table.insert(scaffoldpositions, (root.Position - Vector3.new(0, -10, 0)))
            return (root.Position - Vector3.new(0, -10, 0))
        end
        return false
    end;
    scaffold = blatant.Api.CreateOptionsButton({
        Name = 'Scaffold',
        Function = function(call: boolean)
            if call then
                table.insert(scaffold.Connections, runservice.RenderStepped:Connect(function()
                    if (tick() - scaffoldtick) >= 10 then
                        table.clear(scaffoldpositions);
                    end
                    if isAlive() and lplr.Character.Humanoid.MoveDirection ~= Vector3.zero then
                        local item: Instance = store:getitem('Wool');
                        if item then
                            local position: Vector3 = getPosition(lplr.Character.PrimaryPart);
                            if position then
                                replicatedstorage.Remotes.ItemRemotes.PlaceBlock:InvokeServer(lplr.Character.PrimaryPart.Position, position - Vector3.new(0, 30, 0), 'Wool');
                            end
                        end;
                    end;
                end))
            end;
        end;
    });
end);

run(function()
    local autojoin: vapemodule = {}
    autojoin = exploit.Api.CreateOptionsButton({
        Name = 'AutoJoin',
        Function = function(call)
            if call then
                repeat
                    if tostring(lplr.Team) == 'Spectator' then
                        replicatedstorage.Remotes.PlayerStartGame:InvokeServer('Join');
                    end;
                    task.wait()
                until (not autojoin.Enabled)
            end;
        end,
        HoverText = 'Automatically joins the match regardless of the match ongoing.'
    });
end);
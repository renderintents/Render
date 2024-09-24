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
   Render Premium Base File For Bedwarz    
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
local combat: vapewindow = gui.ObjectsThatCanBeSaved.CombatWindow;
local blatant: vapewindow = gui.ObjectsThatCanBeSaved.BlatantWindow;
local visual: vapewindow = gui.ObjectsThatCanBeSaved.RenderWindow;
local exploit: vapewindow = gui.ObjectsThatCanBeSaved.ExploitWindow;
local utility: vapewindow = gui.ObjectsThatCanBeSaved.UtilityWindow;
local world: vapewindow = gui.ObjectsThatCanBeSaved.WorldWindow;
local hudwindow: vapewindow = gui.ObjectsThatCanBeSaved.TargetHUDWindow;

for i: (any), v: (...any) -> (...any) in render.utils do --> sideloads all render global utility functions from libraries/utils.lua
    getfenv()[i] = v;
end;

--> defining mostly used (by most people) variables

local vape: vapemain = gui;
local GuiLibrary: vapemain = gui;
local runFunction: (() -> (any)) -> () = run;
local runcode: (() -> (any)) -> () = run;
local store = getgenv().bedwarz;

--> my favorite variables

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

--> normal vape service variable

local playersService: Players = players;
local textService: TextService = textservice;
local lightingService: Lighting = lighting;
local textChatService: TextChatService = textchat;
local inputService: UserInputService = inputservice;
local runService: RunService = runservice;
local tweenService: TweenService = tween;
local collectionService: CollectionService = collection;
local replicatedStorage: ReplicatedStorage = replicatedstorage;
local gameCamera = camera;

run(function()
    local damageindicator: table = {};
    local damageindicatorcoloroption: table = {};
    local damageindicatorfontoption: table = {};
    local damageindicatorfontcustom: table = {};
    local damageindicatortextoption: table = {};
    local damageindicatorcolor2option: table = {};
    local damageindicatorcolor: table = newcolor();
    local damageindicatorcolor2: table = newcolor();
    local damageindicatorfontfile: table = {Value = ''};
    local damageindicatortextlist: table = {ObjectList = {}};
    local damageindicatorfont: table = {Value = 'GothamBold'};
    local indicatormessages = {
        '.gg/renderintents',
        'renderintents.lol',
        'renderintents.xyz',
        'render on top',
        'render >> tide paste'
    };
    damageindicator = visual.Api.CreateOptionsButton({
        Name = 'DamageIndicator',
        HoverText = 'Customize your damage indicator.',
        Function = function(calling: boolean)
            if calling then 
                table.insert(damageindicator.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(indicator: BillboardGui?)
                    if indicator.Name ~= 'DamageIndicatorGui' then return end;
                    pcall(function()
                        local label: TextLabel? = indicator:FindFirstChildOfClass('TextLabel');
                        local labelgradient: UIGradient = Instance.new('UIGradient', label);
                        local color: Color3 = Color3.fromHSV(damageindicatorcolor.Hue, damageindicatorcolor.Sat, damageindicatorcolor.Value);
                        local color2: Color3 = damageindicatorcolor2option.Enabled and Color3.fromHSV(damageindicatorcolor2.Hue, damageindicatorcolor2.Sat, damageindicatorcolor2.Value) or color;
                        labelgradient.Enabled = damageindicatorcoloroption.Enabled;
                        labelgradient.Color = ColorSequence.new({
                            [1] = ColorSequenceKeypoint.new(0, color),
                            [2] = ColorSequenceKeypoint.new(1, color2)
                        });
                        if labelgradient.Enabled then
                            label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        end;
                        if damageindicatorfontoption.Enabled then 
                            if damageindicatorfontcustom.Enabled then 
                                label.FontFace = Font.new(getcustomasset(damageindicatorfontfile.Value));
                            else
                                label.Font = damageindicatorfont.Value;
                            end;
                        end;
                        if damageindicatortextoption.Enabled then 
                            label.Text = getrandomvalue(damageindicatortextlist.ObjectList) ~= '' and getrandomvalue(damageindicatortextlist.ObjectList) or getrandomvalue(indicatormessages.ObjectList);
                        end;
                    end)
                end))
            end
        end
    });
    damageindicatorcoloroption = damageindicator.CreateToggle({
        Name = 'Color',
        Default = true,
        Function = function(calling: boolean)
            pcall(function() damageindicatorcolor.Object.Visible = calling end);
            pcall(function() damageindicatorcolor2option.Object.Visible = calling end);
            pcall(function() damageindicatorcolor2.Object.Visible = calling and damageindicatorcolor2option.Enabled end);
        end
    });
    damageindicatorcolor = damageindicator.CreateColorSlider({
        Name = 'Text Color',
        Function = void
    });
    damageindicatorcolor2option = damageindicator.CreateToggle({
        Name = 'Secondary Color',
        Default = true,
        Function = function(calling: boolean)
            pcall(function() damageindicatorcolor2.Object.Visible = calling end);
        end
    });
    damageindicatorcolor2 = damageindicator.CreateColorSlider({
        Name = 'Color 2',
        Function = void
    });
    damageindicatorfontoption = damageindicator.CreateToggle({
        Name = 'Text Font',
        Function = function(calling: boolean)
            pcall(function() damageindicatorfontcustom.Object.Visible = calling end);
            pcall(function() damageindicatorfont.Object.Visible = (calling and (not damageindicatorfontcustom.Enabled)) end);
            pcall(function() damageindicatorfontfile.Object.Visible = (calling and damageindicatorfontcustom.Enabled) end);
        end
    });
    damageindicatorfontcustom = damageindicator.CreateToggle({
        Name = 'Custom Font File',
        Function = function(calling: boolean)
            pcall(function() damageindicatorfontfile.Object.Visible = getcustomasset ~= nil and calling end);
            pcall(function() damageindicatorfont.Object.Visible = (not calling) end);
        end
    });
    damageindicatorfont = damageindicator.CreateDropdown({
        Name = 'Font',
        List = GetEnumItems('Font'),
        Function = void
    });
    damageindicatorfontfile = damageindicator.CreateTextBox({
        Name = 'Font File',
        TempText = 'font file (.tff)',
        FocusLost = void
    });
    damageindicatortextoption = damageindicator.CreateToggle({
        Name = 'Custom Text',
        Function = function(calling: boolean)
            pcall(function() damageindicatortextlist.Object.Visible = calling end);
        end
    });
    damageindicatortextlist = damageindicator.CreateTextList({
        Name = 'Text',
        TempText = 'messages',
        AddFunction = void
    });

    damageindicatorcolor.Object.Visible = false;
    damageindicatorcolor2option.Object.Visible = false;
    damageindicatorcolor2.Object.Visible = false;
    damageindicatorfontcustom.Object.Visible = false;
    damageindicatorfontfile.Object.Visible = false;
    damageindicatorfont.Object.Visible = false;
    damageindicatortextlist.Object.Visible = false;
end);

run(function()
    local healthbarmods: table = {};
    local healthbarmodsbkgcoloroption: table = {};
    local healthbarmodstextfontoption: table = {};
    local healthbarmodscoloroption: table = {};
    local healthbarmodscolor2option: table = {};
    local healthbarmodstextcoloroption: table = {};
    local healthbarmodstext: table = {ObjectList = {}};
    local healthbarmodstextfont: table = {Value = 'GothamMediam'};
    local healthbarmodstransparency: table = {Value = 3};
    local hotbarmodsround: table = {Value = 20};
    local healthbarmodsbkgcolor: table = newcolor();
    local healthbarmodstextcolor: table = newcolor();
    local healthbarmodscolor: table = newcolor();
    local healthbarmodscolor2: table = newcolor();
    local textchangeconnections: table = Performance.new();
    local healthbarFunction: () -> () = function()
        if not healthbarmods.Enabled then return end;
        pcall(function()
            local healthbar: Frame? = lplr.PlayerGui.HealthGui.MainFrame.HealthFrame.HealthBar;
            local healthbarbackground: Frame = healthbar.Parent;
            local healthbartext: TextLabel = healthbarbackground.Parent:FindFirstChildOfClass('TextLabel');
            local healthbargradient: UIGradient = healthbar:FindFirstChildOfClass('UIGradient') or Instance.new('UIGradient', healthbar);
            local color: Color3 = Color3.fromHSV(healthbarmodscolor.Hue, healthbarmodscolor.Sat, healthbarmodscolor.Value);
            local color2: Color3 = healthbarmodscolor2option.Enabled and Color3.fromHSV(healthbarmodscolor2.Hue, healthbarmodscolor2.Sat, healthbarmodscolor2.Value) or color;
            healthbargradient.Enabled = healthbarmodscoloroption.Enabled;
            healthbargradient.Color = ColorSequence.new({
                [1] = ColorSequenceKeypoint.new(0, color),
                [2] = ColorSequenceKeypoint.new(1, color2)
            });
            if healthbargradient.Enabled then 
                healthbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
            end;
            if healthbarmodsbkgcoloroption.Enabled then 
                healthbarbackground.BackgroundColor3 = Color3.fromHSV(healthbarmodsbkgcolor.Hue, healthbarmodsbkgcolor.Sat, healthbarmodsbkgcolor.Value)
            end;
            if healthbarmodstextcoloroption.Enabled then 
                healthbartext.TextColor3 = Color3.fromHSV(healthbarmodstextcolor.Hue, healthbarmodstextcolor.Sat, healthbarmodstextcolor.Value)
            end;
            if getrandomvalue(healthbarmodstext.ObjectList) ~= '' then 
                healthbartext.Text = getrandomvalue(healthbarmodstext.ObjectList)
            end;
            local changeconnection: RBXScriptConnection? = textchangeconnections[healthbartext];
            if changeconnection == nil then 
                textchangeconnections[healthbartext] = healthbartext:GetPropertyChangedSignal('Text'):Connect(function()
                    if getrandomvalue(healthbarmodstext.ObjectList) ~= '' then 
                        healthbartext.Text = getrandomvalue(healthbarmodstext.ObjectList)
                    end;
                end)
            end;
            local healthbarcorner: UICorner = healthbar:FindFirstChildOfClass('UICorner') or Instance.new('UICorner', healthbar);
            local healthbarcorner2: UICorner = healthbarbackground:FindFirstChildOfClass('UICorner') or Instance.new('UICorner', healthbarbackground);
            healthbarcorner.CornerRadius = UDim.new(0, hotbarmodsround.Value);
            healthbarcorner2.CornerRadius = UDim.new(0, hotbarmodsround.Value);
            healthbar.BackgroundTransparency = (0.1 * healthbarmodstransparency.Value);
            healthbar.BackgroundTransparency = (0.1 * healthbarmodstransparency.Value);
            healthbarbackground.BackgroundTransparency = (0.1 * healthbarmodstransparency.Value);
            if healthbarmodstextfontoption.Enabled then 
                healthbartext.Font = healthbarmodstextfont.Value
            end;
        end)
    end;
    healthbarmods = visual.Api.CreateOptionsButton({
        Name = 'HealthbarVisuals',
        HoverText = 'Customize your healthbar',
        Function = function(calling: boolean)
            if calling then 
                healthbarFunction();
                table.insert(healthbarmods.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(frame: Frame?)
                    if frame.Name == 'HealthFrame' then 
                        healthbarFunction();
                    end
                end))
            else 
                for i: TextLabel, v: RBXScriptConnection in textchangeconnections do 
                    if v.Connected then 
                        v:Disconnect()
                    end
                end;
                table.clear(textchangeconnections);
                pcall(function()
                    lplr.PlayerGui.HealthGui.MainFrame.HealthFrame.HealthBar.BackgroundColor3 = Color3.fromRGB(17, 255, 0);
                    lplr.PlayerGui.HealthGui.MainFrame.HealthFrame.HealthBar:FindFirstChildOfClass('UIGradient'):Destroy();
                    lplr.PlayerGui.HealthGui.MainFrame:FindFirstChildOfClass('TextLabel').TextColor3 = Color3.fromRGB(255, 255, 255);
                    for i: number, v: Instance in lplr.PlayerGui.HealthGui:GetDescendants() do 
                        if v.ClassName == 'UICorner' then 
                            v:Destroy()
                        end 
                    end;
                end);
            end
        end
    });
    healthbarmodscoloroption = healthbarmods.CreateToggle({
        Name = 'Color',
        Default = true,
        Function = healthbarFunction
    });
    healthbarmodscolor = healthbarmods.CreateColorSlider({
        Name = 'Color',
        Function = healthbarFunction
    });
    healthbarmodscolor2option = healthbarmods.CreateToggle({
        Name = 'Secondary Color',
        Default = true,
        Function = healthbarFunction
    });
    healthbarmodscolor2 = healthbarmods.CreateColorSlider({
        Name = 'Color 2',
        Function = healthbarFunction
    });
    healthbarmodsbkgcoloroption = healthbarmods.CreateToggle({
        Name = 'Background Color',
        Function = healthbarFunction
    });
    healthbarmodsbkgcolor = healthbarmods.CreateColorSlider({
        Name = 'Background Color',
        Function = healthbarFunction
    });
    healthbarmodstextcoloroption = healthbarmods.CreateToggle({
        Name = 'Text Color',
        Function = healthbarFunction
    });
    healthbarmodstextcolor = healthbarmods.CreateColorSlider({
        Name = 'Text Color',
        Function = healthbarFunction
    });
    healthbarmodstext = healthbarmods.CreateTextList({
        Name = 'Messages',
        TempText = 'messages',
        AddFunction = healthbarFunction
    });
end);

run(function()
	local cloudmods: table = {};
	local cloudmodsneon: table = {};
	local cloudmodscolor: table = newcolor();
	local updatecloud: () -> () = function(cloud: Part) 
		pcall(function()
			cloud.Color = Color3.fromHSV(cloudmodscolor.Hue, cloudmodscolor.Sat, cloudmodscolor.Value);
			cloud.Material = cloudmodsneon.Enabled and Enum.Material.Neon or Enum.Material.SmoothPlastic;
		end)
	end;
	cloudmods = visual.Api.CreateOptionsButton({
		Name = 'CloudMods',
		HoverText = 'Changes the color of the clouds.',
		Function = function(calling)
			if calling then 
				for i: number, v: Part? in workspace:WaitForChild('Clouds', 9e9):GetChildren() do 
					task.spawn(updatecloud, v);
				end;
				table.insert(cloudmods.Connections, workspace.Clouds.ChildAdded:Connect(updatecloud));
			else 
				if workspace:FindFirstChild('Clouds') then 
					for i: number, v: Part? in workspace.Clouds:GetChildren() do 
						v.Color = Color3.fromRGB(255, 255, 255);
				        v.Material = Enum.Material.SmoothPlastic;
					end
				end
			end
		end
	})
	cloudmodscolor = cloudmods.CreateColorSlider({
		Name = 'Color',
		Function = function()
			local clouds: Folder? = cloudmods.Enabled and workspace:FindFirstChild('Clouds');
			if clouds then 
				for i: number, v: Part? in clouds:GetChildren() do 
					task.spawn(updatecloud, v);
				end
			end
		end
	})
	cloudmodsneon = cloudmods.CreateToggle({
		Name = 'Neon',
		Function = function()
			local clouds: Folder? = cloudmods.Enabled and workspace:FindFirstChild('Clouds');
			if clouds then 
				for i: number, v: Part? in clouds:GetChildren() do 
					task.spawn(updatecloud, v);
				end
			end
		end
	})
end);

run(function()
    local autobuy: table = {};
    local autobuyweapons: table = {Enabled = true};
    local autobuyarmor: table = {Enabled = true};
    local autobuypickaxes: table = {Enabled = true};
    local autobuyaxes: table = {Enabled = true};
    local autobuydelay: table = {Value = 1};
    local autobuythread;
    local currencytab: table = {
        Weapons = {
            ['Stone Sword'] = {price = 20},
            ['Iron Sword'] = {price = 70},
            ['Diamond Sword'] = {price = 4, currency = 'Emerald'},
            ['Emerald Sword'] = {price = 20, currency = 'Emerald'}
        },
        Armor = {
            ['Leather Armor'] = {price = 60},
            ['Iron Armor'] = {price = 150},
            ['Diamond Armor'] = {price = 8, currency = 'Emerald'},
            ['Emerald Armor'] = {price = 35, currency = 'Emerald'}
        },
        Axe = {
            ['Wooden Axe'] = {price = 15},
            ['Stone Axe'] = {price = 30},
            ['Iron Axe'] = {price = 50},
            ['Diamond Axe'] = {price = 100}
        },
        Pickaxes = {
            ['Stone Pickaxe'] = {price = 15},
            ['Iron Pickaxe'] = {price = 30},
            ['Diamond Pickaxe'] = {price = 100}
        }
    };
    local priotable: table = {
        [1] = 'Weapons',
        [2] = 'Armor',
        [3] = 'Axe',
        [4] = 'Pickaxe'
    };
    local purchaseitem = function(name: string, data: table): boolean
        local money: table = store:getitem(data.currency or 'Iron');
        if not money then 
            return false 
        end;
        if store:getitem(name) then 
            return false
        end;
        local amount: number = money.meta and money.meta.amount or money.amount or 0;
        if amount >= data.price then 
            return replicatedstorage.Remotes.PurchaseItem:InvokeServer(name)
        end;
        return false
    end;
    local isnearnpc = function(): boolean
        return true;
    end;
    autobuy = utility.Api.CreateOptionsButton({
        Name = 'AutoBuy',
        HoverText = 'Automatically buys tools.',
        Function = function(calling: boolean)
            if calling then 
                autobuythread = task.spawn(function()
                    repeat 
                        local itemtables: table = {};
                        for i,v in currencytab do 
                            if not isnearnpc() then 
                                continue 
                            end;
                            if i == 'Weapons' and not autobuyweapons.Enabled then
                                continue 
                            end;
                            if i == 'Armor' and not autobuyarmor.Enabled then 
                                continue
                            end;
                            if i == 'Axe' and not autobuyaxes.Enabled then 
                                continue 
                            end;
                            if i == 'Pickaxes' and not autobuypickaxes.Enabled then 
                                continue 
                            end;
                            for i2, v2 in v do 
                                itemtables[i2] = v2;
                            end;
                        end;
                        for i,v in itemtables do 
                            local success: boolean = purchaseitem(i, v);
                            if success then
                                local boughtTick = tick();
                                repeat task.wait() until ((tick() - boughtTick) > (0.1 * autobuydelay.Value))
                            end
                        end;
                        table.clear(itemtables)
                        task.wait();
                    until (not autobuy.Enabled)
                end);
            else 
                pcall(task.cancel, autobuythread)
            end
        end
    });
    autobuydelay = autobuy.CreateSlider({
        Name = 'Purchase Delay',
        Min = 0,
        Max = 10,
        Default = 1,
        Function = void
    });
    autobuyweapons = autobuy.CreateToggle({
        Name = 'Purchase Swords',
        Default = true,
        Function = void
    });
    autobuyarmor = autobuy.CreateToggle({
        Name = 'Purchase Armor',
        Default = true,
        Function = void
    });
    autobuypickaxes = autobuy.CreateToggle({
        Name = 'Purchase Pickaxes',
        Function = void
    });
    autobuyaxes = autobuy.CreateToggle({
        Name = 'Purchase Axes',
        Function = void
    });
end);

run(function()
    local highlightvisuals: table = {};
    local highlightvisualscolor: table = newcolor();
    local highlightvisualstransparency: table = {Value = 8};
    highlightvisuals = visual.Api.CreateOptionsButton({
        Name = 'HighlightVisuals',
        HoverText = 'Customize the damage highlight.',
        Function = function(calling: boolean)
            if calling then 
                pcall(function() 
                    lplr.PlayerGui.DamageIndicatorGui.DamageHighlight.FillColor = Color3.fromHSV(highlightvisualscolor.Hue, highlightvisualscolor.Sat, highlightvisualscolor.Value);
                    lplr.PlayerGui.DamageIndicatorGui.DamageHighlight.Transparency = 0.1 * highlightvisualstransparency.Value;
                end);
                table.insert(highlightvisuals.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(highlight: Highlight?)
                    if highlight.Name == 'DamageHighlight' and highlight.ClassName == 'Highlight' then 
                        highlight.FillColor = Color3.fromHSV(highlightvisualscolor.Hue, highlightvisualscolor.Sat, highlightvisualscolor.Value);
                        highlight.FillTransparency = 0.1 * highlightvisualstransparency.Value;
                    end;
                end))
            end
        end
    });
    highlightvisualscolor = highlightvisuals.CreateColorSlider({
        Name = 'Color',
        Function = function()
            pcall(function() 
                lplr.PlayerGui.DamageIndicatorGui.DamageHighlight.FillColor = Color3.fromHSV(highlightvisualscolor.Hue, highlightvisualscolor.Sat, highlightvisualscolor.Value);
            end)
        end
    });
    highlightvisualstransparency = highlightvisuals.CreateSlider({
        Name = 'Transparency',
        Min = 0,
        Max = 10,
        Default = 8,
        Function = function(value: number)
            pcall(function()
                lplr.PlayerGui.DamageIndicatorGui.DamageHighlight.FillTransparency = 0.1 * value;
            end)
        end
    })
end);

run(function()
    local autowin: table = {};
    local autowinthread;
    local bedtween;
    local autowinning;
    local getbestupvec: () -> Vector3 = function(pos: Vector3): Vector3
        local vec: Vector3 = Vector3.zero;
        for i = 1, 13 do 
            if workspace:Raycast(pos, Vector3.new(i, 0, 0), store.raycast) == nil then 
                vec = Vector3.new(i, 0, 0)
            else 
                break;
            end;
            if workspace:Raycast(pos, Vector3.new(-i, 0, 0), store.raycast) == nil then 
                vec = Vector3.new(-i, 0, 0)
            else 
                break;
            end;
            if workspace:Raycast(pos, Vector3.new(0, i, 0), store.raycast) == nil then 
                vec = Vector3.new(0, i, 0)
            else 
                break;
            end;
            if workspace:Raycast(pos, Vector3.new(0, -i, 0), store.raycast) == nil then 
                vec = Vector3.new(0, -i, 0)
            else 
                break;
            end;
            if workspace:Raycast(pos, Vector3.new(0, 0, i), store.raycast) == nil then 
                vec = Vector3.new(0, 0, i)
            else 
                break;
            end;
            if workspace:Raycast(pos, Vector3.new(0, 0, -i), store.raycast) == nil then 
                vec = Vector3.new(0, 0, -i)
            else 
                break;
            end;
        end;
        return vec
    end;
    autowin = blatant.Api.CreateOptionsButton({
        Name = 'Autowin',
        HoverText = 'Automatically wins games for you.',
        Function = function(calling: boolean)
            if calling then 
                autowinthread = task.spawn(function()
                    task.wait(0.1);
                    repeat 
                        pcall(function()
                            local bed: Model? = store:getnearestbed(nil, true);
                            local root: BasePart? = isAlive(lplr, true) and (render.clone.old or lplr.Character.PrimaryPart);
                            if bed and tostring(lplr.Team) ~= 'Spectator' then 
                                autowinning = true;
                                while store:getnearestbed(nil, true) == bed do 
                                    if not istweening then 
                                        root.CFrame = bed.PrimaryPart.CFrame + Vector3.new(0, isEnabled('AntiFlag') and 5 or 18, 0);
                                        --[[bedtween = tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {CFrame = bed.PrimaryPart.CFrame + Vector3.new(0, 18, 0)});
                                        bedtween:Play();
                                        bedtween.Completed:Once(function()
                                            istweening = false
                                        end)
                                        istweening = true;]]
                                    end;
                                    task.wait()
                                end;
                                istweening = false;
                                while GetTarget({radius = 100}).RootPart do 
                                    local target: table = GetTarget({radius = 100, pos = root.Position});
                                    root.CFrame = target.RootPart.CFrame + Vector3.new(1.5, 0, 0);
                                   -- tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame + Vector3.new(0, 13, 0)}):Play()
                                    task.wait()
                                end;
                            else 
                                local target: table = GetTarget();
                                if target.RootPart and tostring(lplr.Team) ~= 'Spectator' then 
                                    root.CFrame = target.RootPart.CFrame;
                                    --tween:Create(lplr.Character.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {CFrame = target.RootPart.CFrame + Vector3.new(0, 13, 0)}):Play();
                                else
                                    autowinning = false;
                                end;
                            end
                        end);
                        task.wait()
                    until (not autowin.Enabled)
                end);
                task.spawn(function()
                    repeat
                        if isAlive(lplr, true) and autowinning then 
                            (render.clone.old or lplr.Character.PrimaryPart).Velocity = Vector3.zero
                        end;
                        task.wait() 
                    until (not autowinthread)
                end);
            else 
                pcall(task.cancel, autowinthread);
                autowinthread = nil;
            end;
        end
    })
end);
type vapeminimodule = {
	Enabled: boolean,
	Object: Instance,
	ToggleButton: (boolean | nil, boolean | nil) -> ()
};

type kickscreenapi = {
    instance: (Frame)?,
    activate: () -> ()
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

type rendertarget = {
    RootPart: BasePart | Part | nil,
    Player: Player | Model | nil,
    Humanoid: Humanoid | nil,
    Human: boolean | nil
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

type vapegui = {
    MainGui: ScreenGui,
    SelfDestructEvent: BindableEvent,
    ObjectsThatCanBeSaved: table
};

type vapewindow = {
	CreateOptionsButton: (table) -> vapemodule,
	SetVisible: (boolean | nil) -> ()
};

export type signalconstructor = {
    new: (self: signalapi) -> ();
};

export type signalconnectionapi = {
    Disconnect: (self: signalconnectionapi) -> ();
    Connected: boolean;
};

export type signalapi = {
    Connect: (self: signalapi, func: (...any) -> (...any)) -> (signalconnectionapi);
    Wait: (self: signalapi) -> (...any);
    Fire: (self: signalapi, ...any) -> ();
};

local rendervape: vapegui = shared.rendervape;

local risecolortable: table = {
	Green = {0.33, 1, 1},
	Red = {0, 1, 1},
	Yellow = {0.15, 1, 1},
	Orange = {0.075, 1, 1},
	Blue = {0.62, 1, 1},
	Purple = {0.72, 1, 1},
	Pink = {0.825, 1, 1},
	Cyan = {0.545, 1, 1},
	Vape = {0.445, 1, 1},
	White = {0.825, 0, 1},
	Black = {0, 0, 0},
	['Dark Blue'] = {0.655, 1, 0.55},
	['Dark Purple'] = {0.725, 1, 0.55},
	['Dark Green'] = {0.34, 1, 0.55},
	['Light Blue'] = {0.59, 0.715, 1},
	['Light Pink'] = {0.775, 0.455, 1},
	['Light Orange'] = {0.01, 0.455, 1},
	['Light Green'] = {0.32, 0.455, 1},
	['Blood Red'] = {0, 1, 0.55}
};

local betterwindownames: table = {};
local blacklistedwindows: table = {'TargetHUD', 'SessionHUD'};

local betterwindowicons: table = {
	Combat = 'a',
	Blatant = 'f',
	Render = 'g',
	Utility = 'c',
	World = 'b',
	Exploit = 'a'
};

task.spawn(function()
    if not rendervape then
        getgenv().RenderIntents = {DebugSession = true};
        loadfile('rendervape/core/boot.luau')();
    end
end);

repeat
    rendervape = shared.rendervape;
    if rendervape then 
        break;
    end;
    task.wait()
until false;

local signal: signalconstructor = loadstring(RenderLibrary.http:getfile('libraries/signal.luau'))();
local oldcreatewindow: (table) -> (vapewindow) = rendervape.CreateWindow;
local oldremoveobject: (string) -> () = rendervape.RemoveObject;
local oldcreatednotification: (string, string, number, string) -> () = rendervape.CreateNotification;

local funclesstab = function(tab: table): (table)
	local newtab: table = table.clone(tab);
	newtab.Function = function() end;
	return newtab;
end;

rendervape.MainGui.Enabled = false;
rendervape.CreateWindow = function(args: table): (vapewindow)
    local vapewindow: vapewindow = oldcreatewindow(args);

	if table.find(blacklistedwindows, args.Name) then
		return vapewindow;
	end;

	local risewindow: table = shared.risegui:CreateCategory(betterwindownames[args.Name] or args.Name, shared.risegui.Fonts.RiseIcon1, betterwindowicons[args.Name] or 'e');
	local oldcreatemodule: (table) -> (vapemodule) = vapewindow.CreateOptionsButton;

	vapewindow.CreateOptionsButton = function(moduleargs: table): (vapemodule)
		local vapemodule: vapemodule = oldcreatemodule(funclesstab(moduleargs));
		local risemodule: table = risewindow:CreateModule(moduleargs.Name, function() end, moduleargs.HoverText and moduleargs.HoverText:gsub('\n', ' ') or 'no description');
		local oldtogglemodule: (boolean?) -> () = vapemodule.ToggleButton;
		local oldcreatetoggle: (table) -> () = vapemodule.CreateToggle;
		local oldcreateslider: (table) -> () = vapemodule.CreateSlider;
		local oldcreatedropdown: (table) -> (vapedropdown) = vapemodule.CreateDropdown;
		local oldrisetogglemodule: (boolean?) -> () = risemodule.Toggle;

		vapemodule.ToggleButton = function(check: boolean?, ...): ()
			--[[if vapemodule.Enabled then 
				for i: number, v: RBXScriptConnection in vapemodule.Connections do 
					if v.Connected then 
						v:Disconnect()
					end;
				end;
				table.clear(vapemodule.Connections);
			end;
			vapemodule.Enabled = not vapemodule.Enabled;]]

			if moduleargs.Button then 
				return task.spawn(moduleargs.Function or function() end, true);
			end;
			
			vapemodule.Enabled = not vapemodule.Enabled;
			if not vapemodule.Enabled then 
				for i: number, v: RBXScriptConnection in vapemodule.Connections do 
					if typeof(v) == 'RBXScriptConnection' and v.Connected then 
						v:Disconnect();
					end;
				end;
				table.clear(vapemodule.Connections);
			end;
			task.spawn(moduleargs.Function or function() end, vapemodule.Enabled);
		end;

		vapemodule.retoggle = function(self: vapemodule): ()
			if self.Enabled then 
				task.spawn(moduleargs.Function or function() end, false);
				task.spawn(moduleargs.Function or function() end, true);
			end;
		end;

		risemodule.Toggle = function(...): ()
			vapemodule.ToggleButton();
			return oldrisetogglemodule(...)
		end;

		vapemodule.CreateSlider = function(sliderargs: table): (vapeslider)
			local vapeslider: vapeslider = oldcreateslider(funclesstab(sliderargs));
			local riseslider: table = risemodule:CreateSlider(sliderargs.Name, function() end, sliderargs.Min, sliderargs.Max, sliderargs.Default);
			local oldsetvalue: (number, ...any) -> () = vapeslider.SetValue;
			local oldrisesetvalue: (table, number, ...any) -> () = riseslider.SetValue;

			vapeslider.SetValue = function(value: number, ...): ()
				vapeslider.Value = value;
				task.spawn(sliderargs.Function or function() end, value);
			end;

			riseslider.SetValue = function(self: table, value: number, ...)
				vapeslider.SetValue(value);
				return oldrisesetvalue(self, value, ...);
			end;
			return vapeslider;
		end;

		vapemodule.CreateDropdown = function(dropdownargs: table): (vapedropdown)
			local vapedropdown: vapedropdown = oldcreatedropdown(funclesstab(dropdownargs));
			local risedropdown: table = risemodule:CreateDropdown(dropdownargs.Name, function() end, dropdownargs.List);
			local oldsetvalue: (string, ...any) -> () = vapedropdown.SetValue;
			local oldrisesetvalue: (table, string, ...any) -> () = risedropdown.SetValue;

			vapedropdown.SetValue = function(value: string, ...): ()
				vapedropdown.Value = value or dropdownargs.List[1];
				task.spawn(dropdownargs.Function or function() end, value or dropdownargs.List[1]);
			end;

			risedropdown.SetValue = function(self: table, value: string, ...): ()
				vapedropdown.SetValue(value or dropdownargs.List[1]);
				return oldrisesetvalue(self, value or dropdownargs.List[1], ...);
			end;
			return vapedropdown;
		end;

		vapemodule.CreateColorSlider = function(colorargs: table): (vapecolorslider)
			local list: table = {};
			local sliderapi: vapeslider = {
				SetValue = function() end, 
				SetRainbow = function() end, 
				Hue = 0, 
				Sat = 0, 
				Value = 0
			};

			local updatecolor = function(color: string): ()
				local colordata: table? = risecolortable[color];
				if colordata then 
					sliderapi.Hue = colordata[1];
					sliderapi.Sat = colordata[2];
					sliderapi.Value = colordata[3];
					task.spawn(colorargs.Function or function() end, unpack(colordata));
				end;
			end;

			for i: number in risecolortable do 
				table.insert(list, i);
			end;
			
			risemodule:CreateDropdown(colorargs.Name, updatecolor, list);
			return sliderapi;
		end;

		vapemodule.CreateToggle = function(toggleargs: table): (vapeminimodule)
			local vapetoggle: vapeminimodule = oldcreatetoggle(funclesstab(toggleargs));
			local risetoggle: table = risemodule:CreateToggle(toggleargs.Name, function() end, toggleargs.Default);
			local oldtogglemodule: (boolean?) -> () = vapetoggle.ToggleButton;
			local oldrisetogglemodule: (table, ...any) -> () = risetoggle.Toggle;

			vapetoggle.ToggleButton = function(...): ()
				vapetoggle.Enabled = not vapetoggle.Enabled;
				if not vapetoggle.Enabled then 
					for i: number, v: RBXScriptConnection in vapetoggle.Connections do 
						if typeof(v) == 'RBXScriptConnection' and v.Connected then 
							v:Disconnect();
						end;
					end;
					table.clear(vapetoggle.Connections);
				end;
				task.spawn(toggleargs.Function or function() end, vapetoggle.Enabled);
			end;

			risetoggle.Toggle = function(...): ()
				vapetoggle.ToggleButton();
				return oldrisetogglemodule(...);
			end;

			risetoggle.ToggleButton = function(): ()
				return risetoggle:Toggle();
			end;

			return vapetoggle;
		end;
		
		return vapemodule;
	end;

	return vapewindow;
end;

rendervape.CreateNotification = function(title: string, text: string, duration: string, ...)
	shared.risegui:CreateNotification(title, text, duration or 4.5);
	return oldcreatednotification(title, text, duration, ...);
end;

rendervape.SaveSettings = function() end;
rendervape.LoadSettings = function() end;
rendervape.RemoveObject = function(name: string)
	return shared.risegui.RemoveObject(name:gsub('OptionsButton', ''));
end;

getgenv().RenderLibrary = shared.renderconstructor;

repeat task.wait() until shared.VapeFullyLoaded;

shared.risegui:CreateThemeCategory('Themes', shared.risegui.Fonts.RiseIcon3, 'U');
local render: table = shared.risegui.Categories.Render;
local interface = render:CreateModule("Interface", function(val) 
	for i, v in pairs(shared.risegui.Interface) do 
		v.Visible = val
	end
end, "The clients interface with all information", function() return "Modern" end, true)
interface:CreateDropdown("BackGround", function(val)
	shared.risegui.Settings.bkg = val == "Normal"
	shared.risegui:UpdateTextGUI() 
end, {"Normal", "Off"})
interface:CreateDropdown("Modules to Show", function(val) 
	shared.risegui.Settings.mode = val 
	shared.risegui:UpdateTextGUI() 
end, {"Exclude render", "All", "Only bound"})
interface:CreateToggle("Sidebar", function(val) 
	shared.risegui.Settings.sidebar = val 
	shared.risegui:UpdateTextGUI() 
end, true)
interface:CreateToggle("Suffix", function(val) 
	shared.risegui.Settings.suffix = val 
	shared.risegui:UpdateTextGUI() 
end, true)
interface:CreateToggle("Lowercase", function(val) 
	shared.risegui.Settings.lowercase = val 
	shared.risegui:UpdateTextGUI() 
end)
interface:CreateToggle("Remove spaces", function(val) 
	shared.risegui.Settings.spaces = not val 
	shared.risegui:UpdateTextGUI() 
end)
interface:CreateToggle("Toggle Notifications", function(val) 
	shared.risegui.Settings.notifs = val 
	shared.risegui:UpdateTextGUI() 
end, true)
local targetinfo = render:CreateModule("Target Info", function(callback)
	shared.risegui.TargetInfo.Visible = callback
	shared.risegui.Settings.targetinfoenabled = callback
end, "Displays information about the entity you're fighting", function() return "Modern" end)
targetinfo:CreateToggle("Follow Player", function(val) shared.risegui.targetinfofollow = val end)

shared.RiseSave = tostring(shared.CustomSaveVape);
shared.risegui:Load();

local render: table = getgenv().render;

table.insert(render.utils.renderconnections, task.spawn(function()
	repeat
		shared.risegui:Save()
		task.wait(5);
	until false;
end));

table.insert(render.utils.renderconnections, task.spawn(function()
	repeat
		shared.risegui.Targets.Killaura = shared.VapeTargetInfo.Targets.Killaura;
		task.wait();
	until false;
end));


local commands

table.insert(render.utils.renderconnections, render.events.message.Event:Connect(function(player: Player, message: string)
	local args: table = message:split(' ');
	if player == render.utils.getservice('Players').LocalPlayer and args[1] == '.bind' and args[2] and args[3] then 
		for i: string, v: table in shared.risegui.Modules do 
			if i:lower():gsub(' ', '') == args[2]:lower() then 
				local _: boolean = pcall(function()
					return Enum.KeyCode[args[3]]
				end);
				if _ then 
					v.Bind = args[3];
					render.utils.getservice('StarterGui'):SetCore('ChatMakeSystemMessage', {
						Text = `Successfully bounded {i} to {args[3]}`,
						Color = Color3.fromRGB(130, 172, 219),
						Font = Enum.Font.Gotham
					})
				end;
			end
		end;
	end
end));

print('done')
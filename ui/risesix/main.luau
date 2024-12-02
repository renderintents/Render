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
shared.RiseExecuted = true;

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

task.spawn(function()
    if not rendervape then
        getgenv().RenderIntents = getgenv().RenderIntents or {};
		getgenv().RenderIntents.YieldLoad = true;
        loadfile('rendervape/core/boot.luau')();
    end
end);

repeat task.wait() until getgenv().requirefile;


local gui: table = requirefile('ui/risesix/gui.luau');
local betterwindownames: table = {};
local blacklistedwindows: table = {'TargetHUD', 'SessionHUD'};

getgenv().RenderIntents.YieldLoad = false;
repeat
    rendervape = shared.rendervape;
    if rendervape then 
        break;
    end;
    task.wait();
until false;

shared.risegui = gui;

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

	local risewindow: table = gui:CreateCategory(betterwindownames[args.Name] or args.Name, gui.Fonts.RiseIcon1, betterwindowicons[args.Name] or 'e');
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
	gui:CreateNotification(title, text, duration or 4.5);
	return oldcreatednotification(title, text, duration, ...);
end;

rendervape.SaveSettings = function() end;
rendervape.LoadSettings = function() end;
rendervape.RemoveObject = function(name: string)
	return gui.RemoveObject(name:gsub('OptionsButton', ''));
end;

getgenv().RenderLibrary = shared.renderconstructor;

repeat task.wait() until shared.VapeFullyLoaded;

gui:CreateThemeCategory('Themes', gui.Fonts.RiseIcon3, 'U');
local render: table = gui.Categories.Render;
local interface = render:CreateModule('Interface', function(val) 
	for i, v in pairs(gui.Interface) do 
		v.Visible = val
	end
end, 'The clients interface with all information', function() return 'Modern' end, true)
interface:CreateDropdown('BackGround', function(val)
	gui.Settings.bkg = val == 'Normal'
	gui:UpdateTextGUI() 
end, {'Normal', 'Off'})
interface:CreateDropdown('Modules to Show', function(val) 
	gui.Settings.mode = val 
	gui:UpdateTextGUI() 
end, {'Exclude render', 'All', 'Only bound'})
interface:CreateToggle('Sidebar', function(val) 
	gui.Settings.sidebar = val 
	gui:UpdateTextGUI() 
end, true)
interface:CreateToggle('Suffix', function(val) 
	gui.Settings.suffix = val 
	gui:UpdateTextGUI() 
end, true)
interface:CreateToggle('Lowercase', function(val) 
	gui.Settings.lowercase = val 
	gui:UpdateTextGUI() 
end)
interface:CreateToggle('Remove spaces', function(val) 
	gui.Settings.spaces = not val 
	gui:UpdateTextGUI() 
end)
interface:CreateToggle('Toggle Notifications', function(val) 
	gui.Settings.notifs = val 
	gui:UpdateTextGUI() 
end, true)
local targetinfo = render:CreateModule('Target Info', function(callback)
	gui.TargetInfo.Visible = callback
	gui.Settings.targetinfoenabled = callback
end, 'Displays information about the entity you\'re fighting', function() return 'Modern' end)
targetinfo:CreateToggle('Follow Player', function(val) gui.targetinfofollow = val end)

shared.RiseSave = tostring(shared.CustomSaveVape);
gui:Load();

local render: table = getgenv().render;

table.insert(render.utils.renderconnections, task.spawn(function()
	repeat
		gui:Save();
		task.wait(5);
	until false;
end));

table.insert(render.utils.renderconnections, task.spawn(function()
	repeat
		gui.Targets.Killaura = shared.VapeTargetInfo.Targets.Killaura;
		task.wait();
	until false;
end));


local risecommands: {[string]: (args: {string}) -> ()} = {
	bind = function(args: {string}): ()
		if args[1] and args[2] then 
			for i: string, v: table in gui.Modules do 
				if i:lower():gsub(' ', '') == args[1]:lower() then 
					local _: boolean = pcall(function()
						return Enum.KeyCode[args[2]]
					end);
					if _ then 
						v.Bind = args[2];
						return render.utils.getservice('StarterGui'):SetCore('ChatMakeSystemMessage', {
							Text = `Successfully bounded {i} to {args[2]}`,
							Color = Color3.fromRGB(130, 172, 219),
							Font = Enum.Font.Arimo
						});
					else
						return render.utils.getservice('StarterGui'):SetCore('ChatMakeSystemMessage', {
							Text = `{args[2]} isn't a valid member of Enum.KeyCode`,
							Color = Color3.fromRGB(255, 0, 0),
							Font = Enum.Font.Arimo
						});
					end;
				end;
			end;
		end;
		return render.utils.getservice('StarterGui'):SetCore('ChatMakeSystemMessage', {
			Text = `{args[1]} isn't a valid Rise Module`,
			Color = Color3.fromRGB(255, 0, 0),
			Font = Enum.Font.Arimo
		});
	end,
	unbind = function(args: {string}): ()
		for i: string, v: table in gui.Modules do 
			if i:lower():gsub(' ', '') == args[1]:lower() then 
				v.Bind = nil;
				return render.utils.getservice('StarterGui'):SetCore('ChatMakeSystemMessage', {
					Text = `Successfully removed bind for {i}`,
					Color = Color3.fromRGB(130, 172, 219),
					Font = Enum.Font.Arimo
				});
			end;
		end;
		return render.utils.getservice('StarterGui'):SetCore('ChatMakeSystemMessage', {
			Text = `{args[2]} isn't a valid Rise Module`,
			Color = Color3.fromRGB(255, 0, 0),
			Font = Enum.Font.Arimo
		});
	end,
	uninject = function(): ()
		gui:Uninject();
		rendervape.SelfDestruct();
	end;
};

for i: string, v: (args: {string}) -> () in risecommands do 
	RenderLibrary.whitelist:registercommand(i, true, v);
end;
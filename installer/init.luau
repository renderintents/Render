export type installerapi = {
    attributes: {
        theme: string,
        version: string,
        loaded: boolean,
        connections: {RBXScriptConnection},
        windowcache: {GuiObject},
        ui: ScreenGui,
        accentcolor: {[string]: Color3},
        tabs: {[string]: tabengine}
    },
    events: {
        loaded: RBXScriptSignal,
        themeupdated: RBXScriptSignal
    },
    engine: installerengine,
};

export type prepareEngine = {
    start: (self: prepareEngine) -> (),
    newstep: (self: prepareEngine, func: () -> ()) -> (),
    setText: (self: prepareEngine, title: string?, description: string?, bottom: string?) -> ()
};

export type windowengine = {
    createSection: (self: windowengine, name: string?, callback: ((boolean) -> ()) | nil) -> (),
    prepare: (self: windowengine) -> (prepareEngine),
    instance: Frame
};

export type installerengine = {
    setTheme: (self: installerengine, theme: string) -> (),
    init: (self: installerengine, key: string) -> (),
    destroy: (self: installerengine) -> (),
    createwindow: (self: installerengine) -> (windowengine)
};

export type tabengine = {
    selected: boolean,
    switch: (self: tabengine, value: boolean | nil, noloop: boolean | nil) -> ()
};

local cloneref: (object: Instance) -> (Instance) = getfenv().cloneref or function(object) return object end;

local getservice = function(service: string): (Instance)
    return cloneref(game:FindService(service));
end;

local runservice: RunService = getservice('RunService');
local httpservice: HttpService = getservice('HttpService');
local api: installerapi = runservice:IsStudio() and require(getservice('ReplicatedStorage').installer) or loadstring(game:HttpGet('https://storage.renderintents.lol/installer/ui.luau'))();
local ria: string;
local constructor: table;
local window: windowengine = api.engine:createwindow();

local writefile = function(file: string, contents: string): ()
    local folderstring: string = '';
    for i: number, v: string in file:split('/') do 
        if i ~= #file:split('/') then 
            folderstring = `{folderstring}{v}/`;
            makefolder(folderstring);
        else 
            getgenv().writefile(file, contents);
        end;
    end;
end;

local bootinstallation = function(): ()
    if constructor == nil or not api.attributes.loaded then 
        return;
    end;
    local configuration: {[string]: {profiles: {[string]: table}, meta: {[string]: {Selected: boolean, Keybind: string}}}} = {
        meta = {},
        profiles = {};
    };
    local installation: prepareEngine = window:prepare();
    installation:newstep(function()
        installation:setText('Checking RIA Key', 'RIA keys are required for render to run', 'Sending API request to /ria.');
        local riares: {ok: boolean} = constructor.http:request({path = 'newria', headers = {ria = ria}});
        return assert(riares.ok, 'Failed to validate user installation key (RIA).');
    end);
  --[[  installation:newstep(function()
        installation:setText('Checking Whitelist', 'Render V3 is in beta, we need to make sure you could use it', 'Waiting for the whitelist to load.');
        repeat task.wait() until constructor.whitelist.state > 0;
        return assert(constructor.whitelist:get(3) > 1, 'User is unauthorized for Render 3.0');
    end);]]
    installation:newstep(function()
        installation:setText('Getting Profiles', 'Modern profiles to make render feel special', 'Sending API request to storage');
        local profileres: {ok: boolean, json: () -> table?} = constructor.http:request({path = 'configuration', subdomain = 'storage', params = {{name = 'iterate', value = 'true'}}});
        assert(profileres.ok and profileres.json().success, profileres.json().result);
        for _: number, v: string in profileres.json().result do 
            if tonumber(v) then 
                local profilesdata: {ok: boolean, json: () -> table?} = constructor.http:request({subdomain = 'storage', path = `configuration/{v}/profiles.json`});
                assert(profilesdata.ok, `Failed to fetch profiles (2) -> {profilesdata.body}`);
                configuration.meta[v] = profilesdata.json();
            end;
        end;
    end);
    installation:newstep(function()
        installation:setText('Downloading Profiles', nil, 'Downloading API request to storage');
        for _: string, profiletab: {[string]: {Selected: boolean, Keybind: string}} in configuration.meta do 
            writefile(`rendervape/configuration/{_}/profiles.json`, httpservice:JSONEncode(profiletab));
            for i: string, v: {Selected: boolean, Keybind: string} in profiletab do 
                writefile('e.txt', i)
                local guiprofile: {ok: boolean, json: () -> table?, body: string} = constructor.http:request({subdomain = 'storage', path = `configuration/{_}/{i}/gui.json`});
                local modulesprofile: {ok: boolean, json: () -> table?, body: string} = constructor.http:request({subdomain = 'storage', path = `configuration/{_}/{i}/modules.json`});
               -- assert(guiprofile.ok and modulesprofile.ok, 'Failed to fetch profiles (4)'); 
                writefile(`rendervape/configuration/{_}/{i}/modules.json`, modulesprofile.body);
                writefile(`rendervape/configuration/{_}/{i}/gui.json`, guiprofile.body);
                installation:setText(nil, nil, `writing rendervape/configuration/{_}/{i}/modules.json`);
            end;
        end;
    end);
    installation:newstep(function()
        installation:setText('Downloading Core', 'Core packages required for render to load', 'Getting core packages');
        local coreres: {ok: boolean, json: () -> table?, body: string} = constructor.http:request({path = 'core', subdomain = 'storage', params = {{name = 'iterate', value = 'true'}}});
        assert(coreres.ok, 'Failed to fetch core packages');
        for _: number, v: string in coreres.json().result do 
            installation:setText(nil, nil, `Downloading rendervape/core/{v}`);
            local file: {ok: boolean, json: () -> table?, headers: {[string]: string}} = constructor.http:request({subdomain = 'storage', path = `core/{v}`});
            if file.ok and file.body ~= '' and not file.headers.bumped then 
                writefile(`rendervape/core/{v}`, file.body);
            else
                writefile(`rendervape/core/{v}`, `return requirefile('rendervape/core/{v}')`);
            end;
        end;
        writefile('rendervape/core/universal.luau', `return requirefile('rendervape/core/universal.luau')`)
    end);
    installation:newstep(function()
        installation:setText('Downloading Games', 'Game packages to make render best', 'Fetching game packages');
        local gameres: {ok: boolean, json: () -> table?, body: string} = constructor.http:request({path = 'games', subdomain = 'storage', params = {{name = 'iterate', value = 'true'}}});
        assert(gameres.ok, 'Failed to fetch games files');
        for _: number, v: string in gameres.json().result do 
            if v:find('.lua') then
                writefile(`rendervape/games/{v}`, `return requirefile('rendervape/games/{v}')`);
            else
                makefolder(`rendervape/games/{v}`);
                local newres: {ok: boolean, json: () -> table?, body: string} = constructor.http:request({path = `games/{v}`, subdomain = 'storage', params = {{name = 'iterate', value = 'true'}}});
                assert(newres.ok, `Failed to fetch {v} files`);
                for __: number, v2: string in newres.json().result do
                    writefile(`rendervape/games/{v}/{v2}`, `return requirefile('rendervape/games/{v}/{v2}')`);
                end;
            end;
        end;
    end);
    installation:newstep(function()
        installation:setText('Downloading Libraries', 'Libraries to make render load properly', 'Fetching libraries packages');
        local libres: {ok: boolean, json: () -> table?, body: string} = constructor.http:request({path = 'libraries', subdomain = 'storage', params = {{name = 'iterate', value = 'true'}}});
        assert(libres.ok, 'Failed to fetch libraries files');
        for _: number, v: string in libres.json().result do 
            local file: {ok: boolean, json: () -> table?, headers: {[string]: string}} = constructor.http:request({subdomain = 'storage', path = `libraries/{v}`});
            installation:setText(nil, nil, `writing rendervape/libraries/{v}`);
            if file.ok and file.body ~= '' and not file.headers.bumped then 
                writefile(`rendervape/libraries/{v}`, file.body);
            else
                writefile(`rendervape/libraries/{v}`, `return requirefile('rendervape/libraries/{v}')`);
            end;
        end;
        writefile(`rendervape/libraries/utils.luau`, `return requirefile('rendervape/libraries/utils.luau')`);
        writefile(`rendervape/libraries/constructor.luau`, `return requirefile('rendervape/libraries/constructor.luau')`);
    end);
    installation:newstep(function()
        installation:setText('Downloading Custom Fonts', 'To make uis like rise load.', 'Fetching fonts packages');
        local getfonts: table = constructor.http:request({
			path = 'fonts',
			subdomain = 'storage',
			params = {{name = 'iterate', value = 'true'}}
		});
        assert(getfonts.ok, 'Failed to fetch render fonts');
		for _: number, v: string in getfonts.json().result do
            installation:setText(nil, nil, `writing rendervape/fonts/{v}`);
            constructor.http:getfile(`fonts/{v}`);
		end;
    end);
    installation:newstep(function()
        installation:setText('Downloading Example Modules', 'To help our UNOFFICIAL developers', 'Fetching script/custom packages');
        writefile('rendervape/scripts/custom/templatemodule.luau', constructor.http:request({subdomain = 'storage', path = 'scripts/custom/templatemodule.luau'}).body);
    end);
    installation:start();
end;

window:createSection('Home', function()
    local headers: TextLabel = Instance.new('TextLabel', api.attributes.ui.main);
    local installbutton: ImageButton = Instance.new('ImageButton', api.attributes.ui.main);
    local installerbuttontext: TextLabel = Instance.new('TextLabel', installbutton);
    local installbuttonicon: ImageLabel = Instance.new('ImageLabel', installbutton);
    local rendericon: ImageLabel = Instance.new('ImageLabel', api.attributes.ui.main);
    local description: TextLabel = Instance.new('TextLabel', headers);
    local gradient: UIGradient = Instance.new('UIGradient', description);
    local exitbutton: ImageButton;
    headers.Position = UDim2.new(0.077, 0, 0.206, 0);
    headers.TextColor3 = api.attributes.accentcolor.text;
    headers.Text = 'Render\n    Intents';
    headers.TextSize = 14;
    headers.TextScaled = true;
    headers.Font = Enum.Font.GothamBlack;
    headers.BackgroundTransparency = 1;
    headers.Size = UDim2.new(0, 238, 0, 82);
    headers.ZIndex = 3;
    headers.TextXAlignment = Enum.TextXAlignment.Left;
    rendericon.Image = 'rbxassetid://16852575555';
    rendericon.Size = UDim2.new(0, 35, 0, 35);
    rendericon.Position = UDim2.new(0.078, 0, 0.33, 0);
    rendericon.BackgroundTransparency = 1;
    rendericon.ZIndex = 4;
    rendericon.ImageColor3 = api.attributes.accentcolor.text;
    installbutton.Size = UDim2.new(0, 127, 0, 35);
    installbutton.ZIndex = 8;
    installbutton.Position = UDim2.new(0.077, 0, 0.586, 0);
    installbutton.BackgroundColor3 = api.attributes.accentcolor.main;
    installbutton.AutoButtonColor = false;
    installbuttonicon.Position = UDim2.new(0.15, 0, 0.143, 0);
    installbuttonicon.Image = 'rbxassetid://8992030918';
    installbuttonicon.Size = UDim2.new(0, 26.8, 0, 26.8);
    installbuttonicon.BackgroundTransparency = 1;
    installbuttonicon.ZIndex = 999999999;
    installerbuttontext.Text = 'Install';
    installerbuttontext.TextScaled = true;
    installerbuttontext.TextSize = 14;
    installerbuttontext.Size = UDim2.new(0, 77, 0, 17);
    installerbuttontext.Position = UDim2.new(0.236, 0, 0.257, 0);
    installerbuttontext.TextColor3 = api.attributes.accentcolor.text;
    installerbuttontext.BackgroundTransparency = 1;
    installerbuttontext.ZIndex = 8;
    installerbuttontext.Font = Enum.Font.GothamBold;
    description.Text = 'The best option on the market for a feature rich experience.';
    description.Position = UDim2.new(0, 0, 1.122, 0);
    description.Size = UDim2.new(0, 200, 0, 44);
    description.TextSize = 14;
    description.TextScaled = true;
    description.ZIndex = 2;
    description.BackgroundTransparency = 1;
    description.Font = Enum.Font.GothamMedium;
    description.TextXAlignment = Enum.TextXAlignment.Left;
    description.TextColor3 = api.attributes.accentcolor.text;
    gradient.Rotation = 1;
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, api.attributes.accentcolor.text), 
        ColorSequenceKeypoint.new(1, api.attributes.accentcolor.text:Lerp(Color3.fromRGB(10, 10, 10), 0.35))
    });
    gradient.Transparency = NumberSequence.new(0, 0.784);
    (Instance.new('UICorner', installbutton) :: UICorner).CornerRadius = UDim.new(0, 10);
    exitbutton = installbutton:Clone();
    exitbutton.Parent = api.attributes.ui.main;
    exitbutton.TextLabel.Text = 'Exit';
    exitbutton.ImageLabel.Image = 'rbxassetid://17334988100';
    exitbutton.BackgroundColor3 = api.attributes.accentcolor.main:Lerp(Color3.fromRGB(10, 10, 10), 0.35);
    exitbutton.Position = UDim2.new(0.078, 0, 0.704, 0);
    exitbutton.ZIndex = 9e15;
    installbutton.MouseButton1Click:Connect(bootinstallation);
    exitbutton.MouseButton1Click:Connect(function() api.engine:destroy() end);
    for i: number, v: GuiObject in ({headers, rendericon, installbutton, exitbutton}) do 
        table.insert(api.attributes.windowcache, v);
    end;
    table.insert(api.attributes.windowcache, api.events.themeupdated:Connect(function(theme: string): ()
        task.wait();
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, api.attributes.accentcolor.text), 
            ColorSequenceKeypoint.new(1, api.attributes.accentcolor.text:Lerp(Color3.fromRGB(10, 10, 10), 0.35))
        });
        exitbutton.BackgroundColor3 = api.attributes.accentcolor.main:Lerp(Color3.fromRGB(10, 10, 10), 0.35);
        installbutton.BackgroundColor3 = api.attributes.accentcolor.main;
        description.TextColor3 = api.attributes.accentcolor.text;
        installerbuttontext.TextColor3 = api.attributes.accentcolor.text;
        headers.TextColor3 = api.attributes.accentcolor.text;
        rendericon.ImageColor3 = api.attributes.accentcolor.text;
        if theme == 'light' then 
            installerbuttontext.TextColor3 = Color3.new(1, 1, 1);
        end;
    end));
end);

window:createSection('Profiles', function() end);

api.events.loaded:Once(function(key: string): ()
    ria = key;
    getgenv().ria = key;
    getgenv().render = {};
    constructor = loadstring(game:HttpGet('https://storage.renderintents.lol/libraries/constructor.lua'))();
    api.attributes.tabs.Home:switch(true);
end);

return api;

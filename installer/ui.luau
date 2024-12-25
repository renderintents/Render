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

local loadsignal: BindableEvent = Instance.new('BindableEvent');
local themechangedsignal: BindableEvent = Instance.new('BindableEvent');
local httpservice: HttpService = cloneref(game:GetService('HttpService'));
local colors: table = {
    new = function(a: number, b: number, c: number): (Color3)
        return Color3.new(a, b, c);
    end;
    fromrgb = function(a: number, b: number, c: number): (Color3)
        return Color3.fromRGB(a, b, c);
    end;
};
local convertcolor3 = function(color3: string, coltype: string): (Color3)
    local color1: number = tonumber(color3:split('(')[2]:split(',')[1]);
    local color: table = {
        [1] = color3:split(', ')[2],
        [2] = color3:split(', ')[3]:split(')')[1]
    };
    return colors[coltype](color1, color[1], color[2]);
end;
local installertheme: table = isfile('rendertheme.json') and httpservice:JSONDecode(readfile('rendertheme.json')) or {
    theme = 'dark', 
    accentcolor = {
        text = 'Color3.new(1, 1, 1)',
        main = 'Color3.fromRGB(107, 114, 151)'
    }
};
local installer: installerapi; installer = setmetatable({
    attributes = {
        theme = installertheme.theme,
        version = '2.0',
        connections = {},
        loaded = false,
        accentcolor = {
            text = convertcolor3(installertheme.accentcolor.text, 'new'),
            main = convertcolor3(installertheme.accentcolor.main, 'fromrgb')
        },
        tabs = {},
        windowcache = {},
    },
    events = {
        loaded = loadsignal.Event,
        themeupdated = themechangedsignal.Event
    },
    engine = {
        init = function(self: installerapi, key: string): ()
            installer.attributes.loaded = true;
            loadsignal:Fire(key);
        end,
        setTheme = function(self: installerapi, theme: string): ()
            themechangedsignal:Fire(theme)
        end
    }
}, {});
if isfile('rendertheme.json') then
    themechangedsignal:Fire(installer.attributes.theme);
end;

local cloneref: (object: Instance) -> (Instance) = getfenv().cloneref or function(object) return object end;

local getservice = function(service: string): (Instance)
    return cloneref(game:FindService(service));
end;

local players: Players = getservice('Players');
local tween: TweenService = getservice('TweenService');
local inputservice: UserInputService = getservice('UserInputService');
local runservice: RunService = getservice('RunService');
local coregui: CoreGui = getservice('CoreGui');

local gethui: () -> (ScreenGui) = getfenv().gethui or function()
    return (runservice:IsStudio() and players.LocalPlayer.PlayerGui or coregui:FindFirstChild('RobloxGui'));
end;

local cloneref: (object: Instance) -> (Instance) = getfenv().cloneref or function(object) 
    return object 
end;

local getservice = function(service: string): (Instance)
    return cloneref(game:FindService(service));
end;

local gui: ScreenGui = Instance.new('ScreenGui', gethui())
gui.Name = httpservice:GenerateGUID(false):gsub('-', ''):lower();
gui.ResetOnSpawn = false;
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
installer.attributes.ui = gui;

function installer.engine:makedraggable(gui: Frame?): ()
    local dragging: boolean = nil;
    local dragstart: Vector3 = nil;
    local startpos: Vector3 = nil;

    local dragfunc = function(input: Vector3): ()
        local delta: Vector3 = input.Position - dragstart;
        tween:Create(gui, TweenInfo.new(0.1), {Position = UDim2.new(startpos.X.Scale, startpos.X.Offset + delta.X, startpos.Y.Scale, startpos.Y.Offset + delta.Y)}):Play()
    end

    gui.InputBegan:Connect(function(input): ()
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true;
            dragstart = input.Position;
            startpos = gui.Position;
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false;
                end;
            end);
        end;
    end);

    inputservice.InputChanged:Connect(function(input): ()
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragfunc(input);
        end;
    end);
end;

function installer.engine:createwindow(): (windowengine)
    local windowengine: windowengine = {};
    local themeorder: {string} = {'normal', 'dark', 'light'};
    local main: Frame = Instance.new('Frame', gui);
    local topbar: Frame = Instance.new('Frame', main);
    local maingradient: UIGradient = Instance.new('UIGradient', main);
    local mainstroke: UIStroke = Instance.new('UIStroke', main);
    local topicon: ImageLabel = Instance.new('ImageLabel', main);
    local mainshadow: ImageLabel = Instance.new('ImageLabel', main);
    local themebutton: ImageButton = Instance.new('ImageButton', main);
    local circle = Instance.new('Frame');
    local circle2 = Instance.new('Frame', main);
    local circle3 = Instance.new('Frame', main);
    local circle4 = Instance.new('Frame', main);
    local circles: {Frame} = {circle, circle2, circle3, circle4};
    local toplist: Frame = Instance.new('Frame', main);
    local toplistlayout: UIListLayout = Instance.new('UIListLayout', toplist);
    main.Name = 'main';
    main.ZIndex = 1;
    main.Size = UDim2.new(0, 449, 0, 372);
    main.Position = UDim2.new(0.438, 0, 0.167, 0);
    main.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    main.ClipsDescendants = true;
    installer.engine:makedraggable(main);
    maingradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 10, 130)), 
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 11, 88))
    });
    maingradient.Rotation = 90.472;
    mainstroke.Thickness = 1.5;
    mainstroke.Color = Color3.fromRGB(48, 9, 166);
    maingradient.Name = 'gradient';
    topbar.Name = 'topbar';
    topbar.Position = UDim2.new(0.05, 0, 0.043, 0);
    topbar.BackgroundColor3 = Color3.fromRGB(25, 4, 83);
    topbar.Size = UDim2.new(0, 404, 0, 40);
    topbar.ZIndex = 2;
    topicon.Size = UDim2.new(0, 29, 0, 23);
    topicon.ScaleType = Enum.ScaleType.Fit;
    topicon.Position = UDim2.new(0.084, 0, 0.068, 0);
    topicon.BackgroundTransparency = 1; 
    topicon.Image = 'rbxassetid://16852575555';
    topicon.Name = 'topicon';
    topicon.ZIndex = 3;
    mainshadow.Name = 'shadow';
    mainshadow.BackgroundTransparency = 1;
    mainshadow.Position = UDim2.new(-0.174, 0, 0.82, 0);
    mainshadow.Size = UDim2.new(0, 625, 0, 94);
    mainshadow.Image = 'rbxassetid://8992238178';
    mainshadow.ImageColor3 = Color3.fromRGB(30, 2, 90);
    toplist.Size = UDim2.new(0, 325, 0, -45);
    toplist.Position = UDim2.new(0.223, 0, 0.19, 0);
    toplist.BackgroundTransparency = 1;
    toplistlayout.Padding = UDim.new(0, 5);
    toplistlayout.FillDirection = Enum.FillDirection.Horizontal;
    toplistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
    toplistlayout.VerticalAlignment = Enum.VerticalAlignment.Top;
    circle.Size = UDim2.new(0, 400, 0, 400);
    circle.Position = UDim2.new(0.274, 0, 0.467, 0);
    circle2.Size = UDim2.new(0, 300, 0, 300);
    circle2.Position = UDim2.new(0.462, 0, 0.599, 0);
    circle3.Size = UDim2.new(0, 350, 0, 350);
    circle3.Position = UDim2.new(0.368, 0, 0.533, 0);
    circle4.Size = UDim2.new(0, 250, 0, 250);
    circle4.Position = UDim2.new(0.556, 0, 0.666, 0);
    themebutton.Name = 'themebutton';
    themebutton.Size = UDim2.new(0, 20, 0, 20)
    themebutton.Position = UDim2.new(0.848, 0, 0.067, 0)
    themebutton.BackgroundTransparency = 1;
    themebutton.Image = 'rbxassetid://14906289364';
    themebutton.ZIndex = 3;
    for _: number, v: Frame in circles do
        v.BackgroundTransparency = 1;
        v.Name = 'circle';
        v.ZIndex = 0;
        (Instance.new('UICorner', v) :: UICorner).CornerRadius = UDim.new(1, 0);
        local stroke: UIStroke = Instance.new('UIStroke', v);
        stroke.Thickness = 1;
        stroke.Color = Color3.fromRGB(44, 27, 143);
    end;

    local themechangefuncs: {[string]: () -> ()} = {
        dark = function(): ()
            themebutton.Image = 'rbxassetid://14906289364';
            tween:Create(themebutton, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(154, 176, 191)}):Play();
            tween:Create(topicon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(154, 176, 191)}):Play();
            tween:Create(topbar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 59, 81)}):Play();
            tween:Create(mainstroke, TweenInfo.new(0.2), {Transparency = 1}):Play();
            installer.attributes.accentcolor.text = Color3.new(1, 1, 1);
            installer.attributes.accentcolor.main = Color3.fromRGB(107, 114, 151);
            maingradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 54, 74)), 
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 33, 45))
            });
            for _: number, v: Frame in circles do 
                tween:Create(v:FindFirstChildOfClass('UIStroke'), TweenInfo.new(0.2), {Color = Color3.fromRGB(50, 55, 74)}):Play();
            end;
            mainstroke.Enabled = false;
            mainshadow.Visible = false;
            return {
                [1] = 'Color3.new(1, 1, 1)';
                [2] = 'Color3.fromRGB(107, 114, 151)';
            };
        end;
        light = function(): ()
            themebutton.Image = 'rbxassetid://14906315218';
            installer.attributes.accentcolor.text = Color3.new(0, 0, 0);
            installer.attributes.accentcolor.main = Color3.fromRGB(33, 33, 33);
            tween:Create(themebutton, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(33, 33, 33)}):Play();
            tween:Create(topicon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(33, 33, 33)}):Play();
            tween:Create(topbar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play();
            tween:Create(mainstroke, TweenInfo.new(0.2), {Transparency = 1}):Play();
            maingradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(226, 233, 235)), 
                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
            });
            for _: number, v: Frame in circles do 
                tween:Create(v:FindFirstChildOfClass('UIStroke'), TweenInfo.new(0.2), {Color = Color3.fromRGB(109, 111, 112)}):Play();
            end;
            mainstroke.Enabled = false;
            mainshadow.Visible = false;
            return {
                [1] = 'Color3.new(0, 0, 0)';
                [2] = 'Color3.fromRGB(33, 33, 33)';
            };
        end,
        normal = function(): ()
            themebutton.Image = 'rbxassetid://101166772343461';
            installer.attributes.accentcolor.text = Color3.new(1, 1, 1);
            installer.attributes.accentcolor.main = Color3.fromRGB(67, 25, 255);
            tween:Create(themebutton, TweenInfo.new(0.2), {ImageColor3 = Color3.new(1, 1, 1)}):Play();
            tween:Create(topicon, TweenInfo.new(0.2), {ImageColor3 = Color3.new(1, 1, 1)}):Play();
            tween:Create(topbar, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 4, 83)}):Play();
            tween:Create(mainstroke, TweenInfo.new(0.2), {Transparency = 0}):Play();
            maingradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 10, 130)), 
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 11, 88))
            });
            for _: number, v: Frame in circles do 
                tween:Create(v:FindFirstChildOfClass('UIStroke'), TweenInfo.new(0.2), {Color = Color3.fromRGB(48, 9, 166)}):Play();
            end;
            mainstroke.Enabled = true;
            mainshadow.Visible = true;
            return {
                [1] = 'Color3.new(1, 1, 1)';
                [2] = 'Color3.fromRGB(67, 25, 255)';
            };
        end
    };

    themebutton.MouseButton1Click:Connect(function(): ()
        local themepos: number = table.find(themeorder, installer.attributes.theme) or 0;
        self:setTheme(themeorder[themepos + 1] or themeorder[1]);
    end);

    table.insert(installer.attributes.connections, themechangedsignal.Event:Connect(function(theme: string): ()
        local themes: table = themechangefuncs[theme]();
        writefile('rendertheme.json', httpservice:JSONEncode({
            theme = theme,
            accentcolor = {
                text = themes[1],
                main = themes[2]
            }
        }));
    end));
    
    (Instance.new('UICorner', main) :: UICorner).CornerRadius = UDim.new(0, 20);
    (Instance.new('UICorner', topbar) :: UICorner).CornerRadius = UDim.new(0, 11);
    
    function windowengine:createSection(name: string | nil, callback: ((boolean) -> ()) | nil): ()
        local tabapi: tabengine = {};
        local buttoncount: number = #toplist:GetChildren();
        local button: TextButton = Instance.new('TextButton', toplist);
        local selectframe: Frame = Instance.new('Frame', button);
        button.BackgroundTransparency = 1; 
        button.TextSize = 14;
        button.Font = Enum.Font.GothamBold;
        button.TextColor3 = Color3.fromRGB(106, 106, 106);
        button.Position = UDim2.new(0.197, 0, 0.225, 0);
        button.Text = name or 'tab';
        button.Size = UDim2.new(0, 57, 0, 21);
        button.ZIndex = 5;
        button.BorderSizePixel = 0;
        selectframe.Size = UDim2.new(0, 60, 0, -2);
        selectframe.Position = UDim2.new(-0.035, 0, 1.476, 0);
        selectframe.BackgroundColor3 = installer.attributes.accentcolor.main;
        selectframe.Visible = false;
        selectframe.BorderSizePixel = 0;
        selectframe.ZIndex = 4;
        installer.attributes.tabs[name] = tabapi;
        table.insert(installer.attributes.connections, themechangedsignal.Event:Connect(function(): ()
            task.wait();
            if tabapi.selected then
                button.TextColor3 = installer.attributes.accentcolor.text; 
            end;
            selectframe.BackgroundColor3 = installer.attributes.accentcolor.main;
        end));
        function tabapi:switch(value: boolean | nil, noloop: boolean | nil): ()
            if not noloop then 
                for i: string, v: tabengine in installer.attributes.tabs do 
                    if v.selected and v ~= tabapi then 
                        v:switch(false, true);
                    end;
                end;
            end;
            if value then 
                selectframe.Size = UDim2.new(0, 0, 0, -2);
                selectframe.Visible = true;
                button.TextColor3 = installer.attributes.accentcolor.text;
                tween:Create(selectframe, TweenInfo.new(installer.attributes.loaded and 0.2 or 0.001, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 60, 0, -2)}):Play();
                task.spawn(callback, true);
                self.selected = true;
            else
                task.spawn(function()
                    if noloop then 
                        selectframe.Size = UDim2.new(0, 0, 0, -2);
                        selectframe.Visible = false;
                        return;
                    end;
                    local out: Tween = tween:Create(selectframe, TweenInfo.new(installer.attributes.loaded and 0.2 or 0.001, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, -2)});
                    out:Play();
                    out.Completed:Wait();
                    selectframe.Visible = false;
                end);
                button.TextColor3 = Color3.fromRGB(106, 106, 106);
                task.spawn(callback, false);
                self.selected = false;
                for i: number, v: GuiObject in installer.attributes.windowcache do 
                    if typeof(v) == 'RBXScriptConnection' and v.Connected then 
                        v:Disconnect();
                        installer.attributes.windowcache[i] = nil;
                        continue;
                    end;
                    v:Remove();
                    installer.attributes.windowcache[i] = nil;
                end;
            end;
        end;
        
        tabapi:switch()

        function windowengine:prepare(): ()
            local prepareapi: prepareEngine = {};
            local steps: {() -> ()} = {};
            function prepareapi:start()
                local safeobjects: {string} = {'themebutton', 'topicon'};
                for _: number, v: GuiObject? in installer.attributes.ui.main:GetDescendants() do 
                    if v ~= installer.attributes.ui.main.topbar and v:IsDescendantOf(installer.attributes.ui.main.topbar) == false and v:IsA('GuiObject') and table.find(safeobjects, v.Name) == nil then 
                        task.spawn(function()
                            local invis = tween:Create(v, TweenInfo.new(0.45), {BackgroundTransparency = 1});
                            pcall(function() tween:Create(v, TweenInfo.new(0.45), {ImageColor3 = 1}):Play() end);
                            pcall(function() tween:Create(v, TweenInfo.new(0.45), {TextTransparency = 1}):Play() end);
                            pcall(function() tween:Create(v, TweenInfo.new(0.45), {ImageTransparency = 1}):Play() end);
                            pcall(function() tween:Create(v, TweenInfo.new(0.45), {Transparency = 1}):Play() end);
                            invis:Play();
                            invis.Completed:Wait();
                            v:Destroy();
                        end);
                    end;
                    if table.find(safeobjects, v.Name) then 
                        v.Position += UDim2.new(0, 0, 0, 5);
                    end;
                end;
                task.wait(0.3);
                tween:Create(installer.attributes.ui.main, TweenInfo.new(0.5), {Size = UDim2.new(0, 449, 0, 211)}):Play();
                tween:Create(installer.attributes.ui.main, TweenInfo.new(0.5), {Position = UDim2.new(0.082, 0, 0.082, 0)}):Play();
                local installtype: TextLabel = Instance.new('TextLabel', installer.attributes.ui.main)
                local installaction: TextLabel;
                local installerbar = Instance.new('Frame', installer.attributes.ui.main)
                local installerbargradient: UIGradient = Instance.new('UIGradient')
                local installerbar2: Frame;
                local installerest: TextLabel;
                installtype.Text = 'Booting Functions';
                installtype.TextColor3 = installer.attributes.accentcolor.text;
                installtype.TextSize = 25;
                installtype.Size = UDim2.new(0, 320, 0, 50);
                installtype.Position = UDim2.new(0.147, 0, 0.256, 0);
                installtype.Font = Enum.Font.GothamBold
                installtype.BackgroundTransparency = 1;
                installtype.ZIndex = 2;
                installerest = installtype:Clone();
                installerest.Text = 'This installation shouldn\'t take too long.';
                installerest.TextSize = 14;
                installerest.ZIndex = 2;
                installerest.Position = UDim2.new(0.134, 0, 0.422, 0);
                installerest.Parent = installer.attributes.ui.main;
                installerbar.Position = UDim2.new(0.114, 0, 0.659, 0);
                installerbar.Size = UDim2.new(0, 349, 0, 17);
                installerbar.ZIndex = 2;
                installerbar.BackgroundColor3 = Color3.fromRGB(5, 5, 5);
                installerbar2 = installerbar:Clone();
                installerbar2.ZIndex = 3;
                installerbar2.Size = UDim2.new(0, 0, 0, 18);
                installerbar2.Position = UDim2.new(-0.043, 0, -0.031, 0);
                installerbar2.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                installerbar2.Parent = installerbar;
                installerbargradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, installer.attributes.accentcolor.main:Lerp(Color3.fromRGB(10, 10, 10), 0.35)), 
                    ColorSequenceKeypoint.new(1, installer.attributes.accentcolor.main:Lerp(Color3.fromRGB(0, 0, 0), 0.2))
                });
                installerbargradient.Rotation = 90.472;
                installerbargradient.Parent = installerbar2;
                installaction = installerest:Clone();
                installaction.Size = UDim2.new(0, 385, 0, 50);
                installaction.Position = UDim2.new(0.056, 0, 0.73, 0);
                installaction.TextSize = 13;
                installaction.TextColor3 = installer.attributes.accentcolor.text:Lerp(Color3.fromRGB(41, 41, 41), 0.4);
                installaction.Text = 'currently booting';
                installaction.Parent = installer.attributes.ui.main;
                for _: number, v: Frame in ({installerbar, installerbar2}) do 
                    (Instance.new('UICorner', v) :: UICorner).CornerRadius = UDim.new(0, 6);
                end;
                table.insert(installer.attributes.windowcache, installer.events.themeupdated:Connect(function(): ()
                    task.wait();
                    installtype.TextColor3 = installer.attributes.accentcolor.text;
                    installerest.TextColor3 = installer.attributes.accentcolor.text;
                    installaction.TextColor3 = installer.attributes.accentcolor.text:Lerp(Color3.fromRGB(41, 41, 41), 0.4);
                    installerbargradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, installer.attributes.accentcolor.main:Lerp(Color3.fromRGB(10, 10, 10), 0.35)), 
                        ColorSequenceKeypoint.new(1, installer.attributes.accentcolor.main:Lerp(Color3.new(), 0.2))
                    });
                end));
                function prepareapi:setText(title: string?, description: string?, bottom: string?): ()
                    if title then 
                        installtype.Text = tostring(title);
                    end;
                    if description then 
                        installerest.Text = tostring(description);
                    end;
                    if bottom then 
                       installaction.Text = tostring(bottom);
                    end;
                end;
                for i: number, step: () -> () in steps do 
                    local success: boolean, result: string? = pcall(step);
                    if not success then 
                        self:setText('Installation Error', `An exception has occured while running step {i}. UI wil self destruct in 5 seconds`, result);
                        installtype.TextColor3 = Color3.fromRGB(250, 0, 0);
                        installerest.TextColor3 = installer.attributes.accentcolor.text;
                        task.wait(3.5);
                        return installer.engine:destroy();
                    end;
                    tween:Create(installerbar2, TweenInfo.new(0.5 / #steps, Enum.EasingStyle.Quad), {Size = UDim2.new(0, (#steps - i) <= 0 and 364 or 364 / (#steps - i), 0, 18)}):Play();
                    if ({identifyexecutor()})[1] == 'AWP' then 
                        print('garbage executor');
                        task.wait(3);
                    end;
                end;
                self:setText('Installation Complete', 'Closing the installer in 3.5 seconds.', '');
                task.delay(3.5, function()
                    installer.engine:destroy();
                end);
            end;
            function prepareapi:newstep(func: () -> ()): ()
                assert(typeof(func) == 'function', `❌ Render Installer - Function expected for step, got {typeof(func)}`);
                table.insert(steps, func);
            end;
            function prepareapi:setText(...): ()
                task.wait(0.4);
                return self:setText(...);
            end;
            return prepareapi;
        end;

        button.MouseButton1Click:Connect(function()
            if not tabapi.selected then 
                tabapi:switch(true);
            end;
        end);
        if buttoncount < 1 then 
            tabapi:switch(true);
        end;
        return tabapi;
    end;
    installer.engine:setTheme(installer.attributes.theme);
    windowengine.instance = main;
    return windowengine;
end;

function installer.engine:setTheme(theme: string): ()
    assert(theme ~= nil and table.find({'normal', 'dark', 'light'}, theme), '❌ Render Installer - Invalid Theme');
    installer.attributes.theme = theme;
    themechangedsignal:Fire(theme);
end;

function installer.engine:destroy(): ()
    installer.attributes.ui:Destroy();
    for _: number, v: RBXScriptConnection in installer.attributes.connections do 
        if typeof(v) == 'RBXScriptConnection' and v.Connected then 
            v:Disconnect();
        end;
    end;
end;

function installer.engine:init(key: string): ()
    loadsignal:Fire(key);
    installer.attributes.loaded = true;
end;


return installer;

    ---!strict

    export type configboxargs = {
        name: string,
        description: string?,
        developer: string?,
        bucketID: string,
    };

    export type localconfigboxargs = {
        name: string,
        description: string,
        bind: string?
    };

    export type localconfigboxfield = {
        name: string,
        value: string,
        updatefield: (self: localconfigboxargs, name: string?, value: string?) -> (),
        type: 'localconfigboxfield',
        instance: TextBox
    };

    export type localconfigboxapi = {
        name: string,
        description: string,
        type: string,
        bind: Enum.KeyCode,
        fields: {localconfigboxfield},
        createfield: (self: localconfigboxargs, name: string, value: string?) -> (localconfigboxfield),
        createbutton: (self: localconfigboxargs, name: string, icon: string, callback: () -> ()?) -> ()
    };

    export type constantsdata = {
        color: Color3,
        tabs: {tabapi},
        configboxes: {configboxapi},
        buttons: table,
        localconfigboxes: {localconfigboxapi},
        objects: {tabapi},
        ui: ScreenGui
    };

    export type mainbuttonargs = {
        name: string,
        callback: (value: boolean) -> ()
    };

    export type tabargs = {
        name: string,
        default: boolean?
    };

    export type tabapi = {
        name: string,
        focused: boolean,
        instance: Frame,
        events: {switched: RBXScriptSignal},
        switch: (self: tabapi, value: boolean?, auto: boolean?) -> ()
    };

    export type mainbuttonapi = {
        instance: Frame,
        focused: boolean
    };

    export type configboxapi = {
        instance: Frame,
        name: string,
        type: 'configbox',
        events: {download: RBXScriptSignal},
    };

    export type apiengine = {
        createconfigbox: (self: apiengine, args: configboxargs) -> (configboxapi),
        createlocalconfigbox: (self: apiengine, args: configboxargs) -> ()
    };

    export type mainapi = {
        configs: table,
        constants: constantsdata,
        engine: apiengine,
        events: {BindableEvent}
    };

    local api: mainapi; api = {
        engine = {},
        constants = {
            color = Color3.fromRGB(1, 103, 255),
            tabs = setmetatable({}, {
                __len = function()
                    local count: number = 0;
                    for i: string, v: tabapi in api.constants.tabs do 
                        count += 1;
                    end;
                    return count;
                end
            }),
            localconfigboxes = {},
            configboxes = {},
            buttons = {},
            objects = {}
        },
        events = setmetatable({}, {
            __index = function(self: {BindableEvent}, index: string): (BindableEvent)
                return (rawget(self, index) or rawset(self, index, Instance.new('BindableEvent')) and rawget(self, index))
            end
        })
    };

    local cloneref: (Instance) -> (Instance) = getfenv().cloneref or function(instance)
        return instance;
    end;

    local gethui: () -> (CoreGui | PlayerGui) = getfenv().gethui or function()
        return cloneref(game:FindService('Players')).LocalPlayer:FindFirstChildOfClass('PlayerGui');
    end;

    local httpservice: HttpService = cloneref(game:FindService('HttpService'));
    local inputservice: UserInputService = cloneref(game:FindService('UserInputService'));
    local tween: TweenService = cloneref(game:FindService('TweenService'));

    local gui: ScreenGui = Instance.new('ScreenGui', cloneref(gethui()));
    gui.ResetOnSpawn = false;
    gui.Name = httpservice:GenerateGUID(false):gsub('-', ''):sub(1, 6);

    local ui: Frame = Instance.new('Frame', gui);
    ui.Name = 'main';
    ui.Size = UDim2.new(0, 674, 0, 378);
    ui.Position = UDim2.new(0.228, 0, 0.287, 0);
    ui.BackgroundColor3 = Color3.fromRGB(25, 25, 25);
    api.constants.ui = gui;
    Instance.new('UICorner', ui).CornerRadius = UDim.new(0, 15);

    local uistroke: UIStroke = Instance.new('UIStroke', ui);
    uistroke.Name = 'stroke';
    uistroke.Color = Color3.fromRGB(49, 47, 47);
    uistroke.Thickness = 2.5;

    local buttonlist: Frame = Instance.new('Frame', ui);
    buttonlist.Name = 'buttonlist';
    buttonlist.Size = UDim2.new(0, 152, 0, 378);
    buttonlist.BackgroundColor3 = Color3.fromRGB(20, 20, 20);
    Instance.new('UICorner', buttonlist).CornerRadius = UDim.new(0, 15);

    local shapebox: Frame = Instance.new('Frame', buttonlist);
    shapebox.Name = 'shapebox';
    shapebox.Size = UDim2.new(0, 74, 0, 58);
    shapebox.Position = UDim2.new(0.511, 0, 0.846, 0);
    shapebox.BorderSizePixel = 0;
    shapebox.BackgroundColor3 = buttonlist.BackgroundColor3;

    local shapebox2: Frame = shapebox:Clone();
    shapebox2.Position = UDim2.new(0.511, 0, 0, 0);
    shapebox2.Parent = shapebox.Parent;

    local listTitle: TextLabel = Instance.new('TextLabel', buttonlist);
    listTitle.Name = 'title';
    listTitle.Text = 'CONFIGS';
    listTitle.TextColor3 = Color3.fromRGB(199, 199, 199);
    listTitle.FontFace = Font.new('rbxasset://fonts/families/JosefinSans.json', Enum.FontWeight.Bold);
    listTitle.Position = UDim2.new(0.007, 0, 0.009, 0);
    listTitle.Size = UDim2.new(0, 151, 0, 50);
    listTitle.BackgroundTransparency = 1;
    listTitle.TextSize = 14;
    listTitle.TextWrapped = true;

    local buttonlayoutframe: Frame = Instance.new('Frame', buttonlist);
    buttonlayoutframe.Name = 'listframe';
    buttonlayoutframe.Size = UDim2.new(0, 125, 0, 281);
    buttonlayoutframe.Position = UDim2.new(0.12, 0, 0.199, 0);
    buttonlayoutframe.BackgroundTransparency = 1;

    local buttonlayout: UIListLayout = Instance.new('UIListLayout', buttonlayoutframe);
    buttonlayout.Name = 'listlayout'
    buttonlayout.Padding = UDim.new(0, 12);
    buttonlayout.FillDirection = Enum.FillDirection.Vertical;
    buttonlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
    buttonlayout.VerticalAlignment = Enum.VerticalAlignment.Top;
    buttonlayout.SortOrder = Enum.SortOrder.LayoutOrder;

    local topbarframe: Frame = Instance.new('Frame', ui);
    topbarframe.Name = 'topbar';
    topbarframe.Size = UDim2.new(0, 446, 0, 27);
    topbarframe.Position = UDim2.new(0.259, 0, 0.077, 0);
    topbarframe.BackgroundTransparency = 1;

    local topbarlayout: UIListLayout = Instance.new('UIListLayout', topbarframe);
    topbarlayout.Name = 'listlayout';
    topbarlayout.Padding = UDim.new(0, 15);
    topbarlayout.FillDirection = Enum.FillDirection.Horizontal;
    topbarlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
    topbarlayout.VerticalAlignment = Enum.VerticalAlignment.Top;

    local configlistframe: ScrollingFrame = Instance.new('ScrollingFrame', ui);
    configlistframe.Name = 'configs';
    configlistframe.BackgroundTransparency = 1;
    configlistframe.ScrollBarThickness = 0;
    configlistframe.Size = UDim2.new(0, 501, 0, 234);
    configlistframe.Position = UDim2.new(0.232, 0, 0.226, 0);
    configlistframe.Visible = false;

    local configlistframe2: ScrollingFrame = configlistframe:Clone();
    configlistframe2.Parent = ui;

    local configlistlayout: UIListLayout = Instance.new('UIListLayout', configlistframe);
    configlistlayout.Name = 'listlayout';
    configlistlayout.FillDirection = Enum.FillDirection.Vertical;
    configlistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
    configlistlayout.VerticalAlignment = Enum.VerticalAlignment.Top;
    configlistlayout.Padding = UDim.new(0, 10);

    local configlistlayout2: UIListLayout = configlistlayout:Clone();
    configlistlayout2.Padding = UDim.new(0, 55);
    configlistlayout2.Parent = configlistframe2;

    local sortframe: Frame = Instance.new('Frame', configlistframe);
    sortframe.BackgroundTransparency = 1;
    sortframe.LayoutOrder = -98;

    sortframe:Clone().Parent = configlistframe2;

    local searchbar: Frame = Instance.new('Frame', ui);
    searchbar.Name = 'searchbar';
    searchbar.Size = UDim2.new(0, 195, 0, 24);
    searchbar.Position = UDim2.new(0.657, 0, 0.077, 0);
    searchbar.BackgroundColor3 = Color3.fromRGB(33, 33, 33);
    searchbar.ClipsDescendants = true;

    local searchbaricon: ImageLabel = Instance.new('ImageLabel', searchbar);
    searchbaricon.Name = 'icon';
    searchbaricon.Size = UDim2.new(0, 19, 0, 19);
    searchbaricon.Position = UDim2.new(0.041, 0, 0.083, 0);
    searchbaricon.BackgroundTransparency = 1;
    searchbaricon.Image = 'rbxassetid://136657030007192';

    local searchbarinput: TextBox = Instance.new('TextBox', searchbar);
    searchbarinput.Name = 'input';
    searchbarinput.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Medium);
    searchbarinput.TextSize = 14;
    searchbarinput.Size = UDim2.new(0, 159, 0, 33);
    searchbarinput.Position = UDim2.new(0.185, 0, -0.208, 0);
    searchbarinput.TextColor3 = Color3.fromRGB(226, 226, 226);
    searchbarinput.PlaceholderColor3 = Color3.fromRGB(88, 88, 88);
    searchbarinput.TextXAlignment = Enum.TextXAlignment.Left;
    searchbarinput.TextTruncate = Enum.TextTruncate.AtEnd;
    searchbarinput.Text = '';
    searchbarinput.PlaceholderText = 'Search';
    searchbarinput.BackgroundTransparency = 1;

    uistroke:Clone().Parent = searchbar;
    Instance.new('UICorner', searchbar).CornerRadius = UDim.new(0, 10);

    searchbarinput.Focused:Connect(function()
        repeat
            for i: number, v: configboxapi in api.constants.configboxes do 
                if v.type == 'configbox' then 
                    v.instance.Visible = v.name:lower():find(searchbarinput.Text:lower()) ~= nil;
                end;
            end;
            task.wait();
        until (inputservice:GetFocusedTextBox() ~= searchbarinput);

        if searchbarinput.Text == '' then 
            for i: number, v: configboxapi in api.constants.configboxes do 
                if v.type == 'configbox' then 
                    v.instance.Visible = true;
                end;
            end;
        end;
    end);

    function api.engine:createmainbutton(args: mainbuttonargs): (mainbuttonapi)
        local name: string = tostring(args.name or math.floor(tick()));
        local buttonapi: mainbuttonapi = setmetatable({}, {__index = {instance = Instance.new('Frame', buttonlayoutframe)}});
        local buttonframe: Frame = buttonapi.instance;
        buttonframe.Name = `{name}_button`;
        buttonframe.Size = UDim2.new(0, 112, 0, 33);
        buttonframe.Position = UDim2.new(0.011, 0, 0, 0);
        buttonframe.BackgroundColor3 = Color3.fromRGB(33, 33, 33);
        local buttonframe2: TextButton = Instance.new('TextButton',  buttonframe);
        buttonframe2.Name = 'text';
        buttonframe2.Text = name;
        buttonframe2.Size = UDim2.new(0, 110, 0, 33);
        buttonframe2.Position = UDim2.new(0.011, 0, 0, 0);
        buttonframe2.TextColor3 = Color3.fromRGB(199, 199, 199);
        buttonframe2.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold);
        buttonframe2.BackgroundTransparency = 1;
        buttonframe2.TextSize = 16;
        local buttonstroke: UIStroke = Instance.new('UIStroke', buttonframe);
        buttonstroke.Name = 'stroke';
        buttonstroke.Color = Color3.fromRGB(49, 47, 47);
        buttonstroke.Thickness = 2.5;
        Instance.new('UICorner', buttonframe).CornerRadius = UDim.new(0, 10);
        buttonframe2.MouseButton1Click:Connect(function()
            if typeof(args.callback) == 'function' then 
                args.callback();
            end;
        end);
        return api;
    end;

    function api.engine:createconfigbox(args: configboxargs): (configboxapi)
        assert(args.bucketID, `❌ Config API - string expected for args.bucketID, got {typeof(args.bucketID)}.`);
        local name: string, description: string, developer: string = tostring(args.name or math.floor(tick())), tostring(args.description or 'no description'), tostring(args.developer or "''");
        local boxapi: configboxapi = {
            events = {},
            instance = Instance.new('Frame', configlistframe),
            name = name,
            type = 'configbox'
        };
        configlistframe.CanvasSize = UDim2.new(0, 0, 0, 111 + (900 * (#api.constants.tabs + 1)));
        local boxframe: Frame = boxapi.instance;
        boxframe.Name = `{args.bucketID}_configbox`
        boxframe.Size = UDim2.new(0, 479, 0, 62);
        boxframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20);
        local glowframe: Frame = Instance.new('Frame', boxframe);
        glowframe.Name = 'glow';
        glowframe.BackgroundColor3 = api.constants.color;
        glowframe.Size = UDim2.new(0, 13, 0, 63);
        glowframe.Position = UDim2.new(-0.004, 0, 0, 0);
        local configtitle: TextLabel = Instance.new('TextLabel', boxframe);
        configtitle.Name = 'title';
        configtitle.Text = name;
        configtitle.TextColor3 = api.constants.color;
        configtitle.TextSize = 18;
        configtitle.Size = UDim2.new(0, 165, 0, 57);
        configtitle.Position = UDim2.new(0.056, 0, -0.12, 0);
        configtitle.BackgroundTransparency = 1;
        configtitle.TextXAlignment = Enum.TextXAlignment.Left;
        configtitle.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold);
        local configdesc: TextLabel = Instance.new('TextLabel', boxframe);
        configdesc.Name = 'description';
        configdesc.Text = description;
        configdesc.TextSize = 12;
        configdesc.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold);
        configdesc.Size = UDim2.new(0, 165, 0, 40);
        configdesc.Position = UDim2.new(0.056, 0, 0.341, 0);
        configdesc.TextColor3 = Color3.fromRGB(157, 157, 157);
        configdesc.BackgroundTransparency = 1;
        configdesc.TextXAlignment = Enum.TextXAlignment.Left;
        local configstroke: UIStroke = Instance.new('UIStroke', boxframe);
        configstroke.Name = 'stroke';
        configstroke.Color = Color3.fromRGB(49, 47, 47);
        configstroke.Thickness = 2.5;
        local downloadbutton: TextButton = Instance.new('TextButton', boxframe);
        downloadbutton.Name = 'download';
        downloadbutton.Text = '';
        downloadbutton.BackgroundColor3 = api.constants.color;
        downloadbutton.Size = UDim2.new(0, 25, 0, 25);
        downloadbutton.Position = UDim2.new(0.902, 0, 0.296, 0);
        local downloadicon: ImageLabel = Instance.new('ImageLabel', downloadbutton);
        downloadicon.Name = 'icon';
        downloadicon.Image = 'rbxassetid://114198558868022';
        downloadicon.ImageColor3 = Color3.new();
        downloadicon.BackgroundTransparency = 1;
        downloadicon.Size = UDim2.new(0, 17, 0, 15);
        downloadicon.Position = UDim2.new(0.16, 0, 0.2, 0);
        local developername: TextLabel = configtitle:Clone();
        developername.Text = `({developer}) `;
        developername.TextSize = 14;
        developername.TextColor3 = Color3.fromRGB(130, 130, 130);
        developername.Position = UDim2.new(0, 10 + (#configtitle.Text * 12.75), -0.12, 0);
        developername.Parent = boxframe;
        local likebutton: ImageButton = Instance.new('ImageButton', boxframe);
        likebutton.Image = 'rbxassetid://97714445229705';
        likebutton.ImageColor3 = Color3.fromRGB(102, 102, 102);
        likebutton.Size = UDim2.new(0, 20, 0, 20);
        likebutton.Position = UDim2.new(0.816, 0, 0.16, 0);
        likebutton.BackgroundTransparency = 1;
        local dislikebutton: ImageButton = likebutton:Clone();
        dislikebutton.Image = 'rbxassetid://117566224721576';
        dislikebutton.Position = UDim2.new(0.816, 0, 0.53, 0);
        dislikebutton.Parent = likebutton.Parent;
        local infobutton: ImageButton = likebutton:Clone();
        infobutton.Image = 'rbxassetid://113106691475074';
        infobutton.Position = UDim2.new(0.755, 0, 0.336, 0);
        infobutton.Parent = likebutton.Parent;
        for i: number, v: ImageButton in {likebutton, dislikebutton} do 
            v.MouseEnter:Connect(function()
                tween:Create(v, TweenInfo.new(0.5), {Size = UDim2.new(0, 22, 0, 22)}):Play();
                tween:Create(v, TweenInfo.new(0.5), {ImageColor3 = api.constants.color}):Play();
            end);
            v.MouseLeave:Connect(function()
                tween:Create(v, TweenInfo.new(0.5), {Size = UDim2.new(0, 20, 0, 20)}):Play();
                tween:Create(v, TweenInfo.new(0.5), {ImageColor3 = Color3.fromRGB(102, 102, 102)}):Play();
            end);
        end;
        for i: number = 1, 2 do 
            local glowshapebox: Frame = Instance.new('Frame', boxframe);
            glowshapebox.Name = 'glowshapebox';
            glowshapebox.BorderSizePixel = 0;
            glowshapebox.BackgroundColor3 = api.constants.color;
            glowshapebox.Size = UDim2.new(0, -7, 0, i == 1 and 14 or 11);
            glowshapebox.Position = UDim2.new(0.023, 0, i == 1 and 0.8 or 0, 0);
        end;
        Instance.new('UICorner', boxframe).CornerRadius = UDim.new(0, 10);
        Instance.new('UICorner', glowframe).CornerRadius = UDim.new(0, 10);
        Instance.new('UICorner', downloadbutton);

        table.insert(api.constants.configboxes, boxapi);
        return boxapi;
    end;

    function api.engine:createlocalconfigbox(args: localconfigboxargs): (localconfigboxapi)
        local args: localconfigboxfield = args or {};
        local boxapi: localconfigboxapi = {
            name = tostring(args.name or httpservice:GenerateGUID(false):gsub('-', ''):sub(1, 6)),
            description = 'default description',
            bind = nil,
            fields = {},
            type = 'local_configbox'
        };
        configlistframe2.CanvasSize = UDim2.new(0, 0, 0, 111 + (165 * (#api.constants.localconfigboxes + 1)));
        local box: Frame = Instance.new('Frame', configlistframe2);
        box.Size = UDim2.new(0, 487, 0, 111);
        box.BackgroundColor3 = Color3.fromRGB(20, 20, 20);
        local buttonstroke: UIStroke = Instance.new('UIStroke', box);
        buttonstroke.Name = 'stroke';
        buttonstroke.Color = Color3.fromRGB(49, 47, 47);
        buttonstroke.Thickness = 2.5;
        local buttonlistframe: Frame = Instance.new('Frame', box);
        buttonlistframe.Size = UDim2.new(0, 112, 0, 25);
        buttonlistframe.Position = UDim2.new(0.77, 0, 1.127, 0);
        buttonlistframe.BackgroundTransparency = 1;
        local buttonlistlayout: UIListLayout = Instance.new('UIListLayout', buttonlistframe);
        buttonlistlayout.Padding = UDim.new(0, 5);
        buttonlistlayout.FillDirection = Enum.FillDirection.Horizontal;
        local fieldslistframe: Frame = Instance.new('Frame', box);
        fieldslistframe.BackgroundTransparency = 1;
        fieldslistframe.Size = UDim2.new(0, 416, 0, 82);
        fieldslistframe.Position = UDim2.new(0.039, 0, 0.127, 0);
        local fieldslistlayout: UIListLayout = Instance.new('UIListLayout', fieldslistframe);
        fieldslistlayout.Padding = UDim.new(0, 10);
        fieldslistlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
        Instance.new('UICorner', box).CornerRadius = UDim.new(0, 15);

        function boxapi:createbutton(name: string, icon: string, callback: () -> ()?): ()
            local button: ImageButton = Instance.new('ImageButton', buttonlistframe);
            button.Size = UDim2.new(0, 25, 0, 25);
            button.BackgroundTransparency = 1;
            button.ImageColor3 = Color3.fromRGB(102, 102, 102);
            button.Image = icon;
            button.MouseButton1Click:Connect(function()
                api.events.buttonpressed:Fire(name);
                if callback then 
                    callback();
                end;
            end);
            button.MouseEnter:Connect(function()
                tween:Create(button, TweenInfo.new(0.5), {Size = UDim2.new(0, 28, 0, 28)}):Play();
                tween:Create(button, TweenInfo.new(0.5), {ImageColor3 = api.constants.color}):Play();
            end);
            button.MouseLeave:Connect(function()
                tween:Create(button, TweenInfo.new(0.5), {Size = UDim2.new(0, 25, 0, 25)}):Play();
                tween:Create(button, TweenInfo.new(0.5), {ImageColor3 = Color3.fromRGB(102, 102, 102)}):Play();
            end);
        end;

        function boxapi:createfield(name: string, value: string?, descaddpos: UDim2?, locked: boolean?): (localconfigboxfield)
            local fieldapi: localconfigboxfield = {
                name = name,
                type = 'localconfigboxfield',
                value = ''
            };
            local fieldframe: Frame = Instance.new('Frame', fieldslistframe);
            fieldframe.Size = UDim2.new(0, 254, 0, 20);
            fieldframe.BackgroundTransparency = 1;
            local fieldtitle: TextBox = Instance.new('TextLabel', fieldframe);
            fieldtitle.Size = UDim2.new(0, 206, 0, 23);
            fieldtitle.BackgroundTransparency = 1;
            fieldtitle.TextSize = 17;
            fieldtitle.Text = `{name}:`;
            fieldtitle.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold);
            fieldtitle.TextColor3 = api.constants.color;
            fieldtitle.TextXAlignment = Enum.TextXAlignment.Left;
            local fieldtext: TextBox = Instance.new('TextBox', fieldtitle);
            fieldtext.BackgroundTransparency = 1;
            fieldtext.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Bold);
            fieldtext.Text = tostring(value or 'default description');
            fieldtext.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.Medium);
            fieldtext.Position = (UDim2.new(0, 57) + (descaddpos or UDim2.new()));
            fieldtext.TextColor3 = Color3.fromRGB(185, 185, 185);
            fieldtext.Size = UDim2.new(0, 378, 0, 23);
            fieldtext.TextSize = 14;
            fieldtext.TextXAlignment = Enum.TextXAlignment.Left;
            fieldtext.Parent = fieldtitle;
            local fieldicon: ImageLabel = Instance.new('ImageLabel', fieldframe);
            fieldicon.Image = 'rbxassetid://125332505841751';
            fieldicon.Size = UDim2.new(0, 17, 0, 17);
            fieldicon.Position = UDim2.new(0, 434, 0, -1);
            fieldicon.ImageColor3 = Color3.fromRGB(185, 185, 185);
            fieldicon.BackgroundTransparency = 1;
            if locked then 
                fieldtext.PlaceholderText = fieldtext.Text;
                fieldtext.TextEditable = false;
            end;
            function fieldapi:updatefield(name: string?, value: string?): ()
                if name then 
                    fieldtitle.Text = `{name}:`;
                end;
                if value then 
                    fieldtext.Text = tostring(value);
                end;
            end;
            
            fieldtext.FocusLost:Connect(function()
                if fieldtext.Text == fieldapi.value then 
                    return;
                end;
                fieldapi.value = fieldtext.Text;
                api.events.fieldupdated:Fire(fieldapi);
            end);
            
            table.insert(self.fields, fieldapi);
            fieldapi.instance = fieldtext;
            return fieldapi;
        end;

        boxapi:createfield('Name', args.name or 'unknown');
        boxapi:createfield('Description', args.description or 'default description', UDim2.new(0, 45));
        boxapi:createfield('Bind', '???', UDim2.new(0, -10), true);
    
        boxapi:createbutton('switch', 'rbxassetid://106967670958703');
        boxapi:createbutton('publish', 'rbxassetid://72645842958921');
        boxapi:createbutton('unpublish', 'rbxassetid://139832805030932');
        boxapi:createbutton('delete', 'rbxassetid://99442519113149');

        table.insert(api.constants.localconfigboxes, boxapi);
        return boxapi;
    end;

    function api.engine:createtab(name: string?): (tabapi)
        local name: string = tostring(name or math.floor(tick()));
        local switchevent: BindableEvent = Instance.new('BindableEvent');
        local tabapi: tabapi = {
            name = name,
            focused = false,
            instance = Instance.new('Frame', topbarframe),
            events = {switched = switchevent.Event};
            type = 'tab'
        };
        local buttonframe: Frame = tabapi.instance;
        buttonframe.Name = `{name}_tab`;
        buttonframe.Size = UDim2.new(0, 92, 0, 24);
        buttonframe.Position = UDim2.new(0.011, 0, 0, 0);
        buttonframe.BackgroundColor3 = Color3.fromRGB(33, 33, 33);
        local buttonframe2: TextButton = Instance.new('TextButton',  buttonframe);
        buttonframe2.Name = 'text';
        buttonframe2.Text = name;
        buttonframe2.Size = UDim2.new(0, 110, 0, 33);
        buttonframe2.Position = UDim2.new(-0.098, 0, -0.208, 0);
        buttonframe2.TextColor3 = Color3.fromRGB(199, 199, 199);
        buttonframe2.FontFace = Font.new('rbxasset://fonts/families/Montserrat.json', Enum.FontWeight.SemiBold);
        buttonframe2.BackgroundTransparency = 1;
        buttonframe2.TextSize = 16;
        local buttonstroke: UIStroke = Instance.new('UIStroke', buttonframe);
        buttonstroke.Name = 'stroke';
        buttonstroke.Color = Color3.fromRGB(49, 47, 47);
        buttonstroke.Thickness = 2.5;
        Instance.new('UICorner', buttonframe).CornerRadius = UDim.new(0, 10);

        function tabapi:switch(value: boolean?, auto: boolean?): () 
            if value then
                self.focused = true;
                switchevent:Fire(true);
                api.events.tabfocused:Fire(tabapi);
                buttonframe2.TextColor3 = Color3.new(1, 1, 1);
                tween:Create(buttonframe, TweenInfo.new(auto and 0.01 or 0.35), {BackgroundColor3 = api.constants.color}):Play();
                tween:Create(buttonstroke, TweenInfo.new(auto and 0.01 or 0.35), {Color = api.constants.color}):Play();
                for i: string, v: tabapi in api.constants.tabs do 
                    if v.focused and v.instance ~= buttonframe then 
                        v:switch();
                    end;
                end;
            else
                self.focused = false;
                api.events.tableave:Fire(tabapi);
                switchevent:Fire(false);
                buttonframe2.TextColor3 = Color3.fromRGB(199, 199, 199);
                tween:Create(buttonframe, TweenInfo.new(0.35), {BackgroundColor3 = Color3.fromRGB(33, 33, 33)}):Play();
                tween:Create(buttonstroke, TweenInfo.new(0.35), {Color = Color3.fromRGB(49, 47, 47)}):Play();
            end;
        end;

        buttonframe2.MouseButton1Click:Connect(function()
            tabapi:switch(not tabapi.focused);
        end);

        local external: tabapi = setmetatable(tabapi, {
            __tostring = function()
                return '⚙️ Config UI Tab Engine'
            end
        });   

        api.constants.tabs[name] = external;
        api.constants.objects[`{name}_tab`] = external;
        return external;
    end;

    api.engine:createmainbutton({
        name = 'Create New',
        callback = function(): ()
            api.constants.tabs.Local:switch(true);
            api.engine:createlocalconfigbox({name = `new config {httpservice:GenerateGUID(false):gsub('-', ''):sub(1, 5):lower()}`});
        end;
    });

    api.engine:createmainbutton({
        name = 'Manage',
        callback = function(): ()
            api.constants.tabs.Local:switch(true);
        end;
    });

    api.engine:createmainbutton({
        name = 'Exit',
        callback = function(): ()
            gui.Enabled = false;
        end;
    });

    api.engine:createtab('Cloud');
    api.engine:createtab('Local');

    api.events.tabfocused.Event:Connect(function(tab: tabapi)
        configlistframe.Visible = (tab.name == 'Cloud');
        configlistframe2.Visible = (tab.name == 'Local');
    end);

    api.events.tableave.Event:Connect(function(tab: tabapi)
        if tab.name == 'Cloud' then 
            configlistframe.Visible = false;
        end;
    end);

    api.constants.tabs.Cloud:switch(true, true);
    return api; 


    
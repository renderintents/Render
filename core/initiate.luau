if not game:IsLoaded() then
	game.Loaded:Wait();
end;

assert(not shared.VapeExecuted, 'Render - Failed to load render | Already loaded');
shared.VapeExecuted = true;

local loadtime: number = tick() - 0.7;
repeat task.wait() until getgenv().RenderIntents and (not getgenv().RenderIntents.YieldLoad) or (not getgenv().RenderIntents);

local cloneref: (...any) -> (...any) = cloneref or function(...): (...any) 
	return ...
end;
local services = setmetatable({}, {
	__index = function(self: table, index: string): ()
		self[index] = cloneref(game:GetService(index));
		return self[index];
	end
});

local created: boolean = false;
local error: (string, number?) -> () = function(output: string, lvl: number): ()
	task.spawn(getrenv().error, output, lvl or 7);
	pcall(function()
		if not created then
			created = true;
			rconsolecreate();
		end;
		rconsolename('Render Console');
		if rconsoleerr then
			rconsoleerr(output);
		else
			rconsoleprint('@@RED@@');
			rconsoleprint(`{output}\n`);
			rconsoleprint('@@WHITE@@');
		end;
	end);
	return assert(false, message);
end;

getgenv().error = error;

local writefile: (string, string) -> () = function(file: string, content: string): ()
	local filename: table = file:split('/');
	if #filename >= 2 then
		for i: number, v: string in filename do
			if i == #filename then break end;
			if not isfolder(v) then
				makefolder(v);
			end;
		end;
	end
	writefile(file, content);
end;

local guilib: table = loadfile('rendervape/core/gui.luau')();
local textservice: TextService = services.TextService;
local tweenservice: TweenService = services.TweenService;
local inputservice: UserInputService = services.UserInputService;
local runservice: RunService = services.RunService
local players: Players = services.Players;
local httpservice: HttpService = services.HttpService;
local platform: string = ({pcall(function() return inputservice:GetPlatform() end)})[2];
local vapeInjected: boolean = true;
local teleportedServers: boolean = false;

local camera: Camera = workspace.Camera or Instance.new('Camera', workspace);

local renderassets: table = {
	['rendervape/assets/WindowBlur.png'] = 'rbxassetid://13350795660',
	['rendervape/assets/KeybindIcon.png'] = 'rbxassetid://13350774323',
	['rendervape/assets/PencilIcon.png'] = 'rbxassetid://13350778187',
	['rendervape/assets/VapeLogo1.png'] = 'rbxassetid://13350860863',
	['rendervape/assets/VapeLogo3.png'] = 'rbxassetid://13350872035',
	['rendervape/assets/VapeLogo2.png'] = 'rbxassetid://13350876307',
	['rendervape/assets/VapeLogo4.png'] = 'rbxassetid://13350877564'
};

local function downloadasset(path)
	return renderassets[path] or ''
end

local RenderLibrary: table = shared.renderconstructor;
getgenv().RenderLibrary = RenderLibrary;
getgenv().rendervapeload = {file = 'GuiLibrary.luau', step = 2};
shared.rendervape = guilib;

task.wait(0.25);
local saveSettingsLoop = coroutine.create(function()
	repeat
		if shared.VapeFullyLoaded then 
			guilib.SaveSettings();
		end;
		task.wait(10);
	until not vapeInjected;
end);

local mainwin: table = guilib.CreateMainWindow();
local pretabs: {table} = {
	[1] = {
		Name = 'Combat',
		IconSize = 15,
		Icon = 'rendervape/assets/CombatIcon.png'
	},
	[2] = {
		Name = 'Blatant',
		IconSize = 16,
		Icon = 'rendervape/assets/BlatantIcon.png'
	},
	[3] = {
		Name = 'Render',
		IconSize = 17,
		Icon = 'rendervape/assets/RenderIcon.png'
	},
	[4] = {
		Name = 'Utility',
		IconSize = 17,
		Icon = 'rendervape/assets/UtilityIcon.png'
	},
	[5] = {
		Name = 'World',
		IconSize = 16,
		Icon = 'rendervape/assets/WorldIcon.png'
	},
	[6] = {
		Name = 'Inventory',
		IconSize = 16,
		Icon = 'rendervape/assets/InventoryIcon.png'
	},
	[7] = {
		Name = 'Exploit',
		IconSize = 16,
		Icon = 'rendervape/assets/ExploitIcon.png'
	},
	[8] = {
		Name = 'Minigames',
		IconSize = 19.5,
		Icon = 'rendervape/assets/MinigamesIcon.png',
		CustomSize = UDim2.new(0, 20, 0, 20),
		CustomSize2 = UDim2.new(0, 18, 0, 18)
	}
}

for i: string, v: table in pretabs do
	local tab = guilib.CreateWindow(v)
	mainwin.CreateButton({
		Name = v.Name, 
		Function = function(call: boolean): () 
			tab.SetVisible(call);
		end, 
		Icon = v.Icon,
		IconSize = v.IconSize,
		CustomSize = v.CustomSize
	});
end;

local Friends = guilib.CreateWindow2({
	Name = 'Friends', 
	Icon = 'rendervape/assets/FriendsIcon.png', 
	IconSize = 17
});
local Targets = guilib.CreateWindow2({
	Name = 'Targets', 
	Icon = 'rendervape/assets/FriendsIcon.png', 
	IconSize = 17
});
local Profiles = guilib.CreateWindow2({
	Name = 'Profiles', 
	Icon = 'rendervape/assets/ProfilesIcon.png', 
	IconSize = 19
});
mainwin.CreateDivider('MISC')
mainwin.CreateButton({
	Name = 'Friends', 
	Function = function(callback: boolean): () 
		Friends.SetVisible(callback);
	end, 
});
mainwin.CreateButton({
	Name = 'Profiles', 
	Indicator = true,
	Function = function(callback: boolean) 
		Profiles.SetVisible(callback);
	end, 
});
mainwin.CreateButton({
	Name = 'Targets', 
	Function = function(callback: boolean) 
		Targets.SetVisible(callback);
	end, 
});

local FriendsTextListTable = {
	Name = 'FriendsList', 
	TempText = 'Username [Alias]', 
	Color = Color3.fromRGB(5, 133, 104)
}
local FriendsTextList = Friends.CreateCircleTextList(FriendsTextListTable)
FriendsTextList.FriendRefresh = Instance.new('BindableEvent')
FriendsTextList.FriendColorRefresh = Instance.new('BindableEvent')
local TargetsTextList = Targets.CreateCircleTextList({
	Name = 'TargetsList', 
	TempText = 'Username [Alias]', 
	Color = Color3.fromRGB(5, 133, 104)
})
local oldFriendRefresh = FriendsTextList.RefreshValues
FriendsTextList.RefreshValues = function(...)
	FriendsTextList.FriendRefresh:Fire()
	return oldFriendRefresh(...)
end
local oldTargetRefresh = TargetsTextList.RefreshValues
TargetsTextList.RefreshValues = function(...)
	FriendsTextList.FriendRefresh:Fire()
	return oldTargetRefresh(...)
end
Friends.CreateToggle({
	Name = 'Use Friends',
	Function = function(callback) 
		FriendsTextList.FriendRefresh:Fire()
	end,
	Default = true
})
Friends.CreateToggle({
	Name = 'Use Alias',
	Function = function(callback) end,
	Default = true,
})
Friends.CreateToggle({
	Name = 'Spoof alias',
	Function = function(callback) end,
})
local friendRecolorToggle = Friends.CreateToggle({
	Name = 'Recolor visuals',
	Function = function(callback) FriendsTextList.FriendColorRefresh:Fire() end,
	Default = true
})
local friendWindowFrame
Friends.CreateColorSlider({
	Name = 'Friends Color', 
	Function = function(h, s, v) 
		local cachedColor = Color3.fromHSV(h, s, v)
		local addCircle = FriendsTextList.Object:FindFirstChild('AddButton', true)
		if addCircle then 
			addCircle.ImageColor3 = cachedColor
		end
		friendWindowFrame = friendWindowFrame or FriendsTextList.ScrollingObject and FriendsTextList.ScrollingObject:FindFirstChild('ScrollingFrame')
		if friendWindowFrame then 
			for i,v in pairs(friendWindowFrame:GetChildren()) do 
				local friendCircle = v:FindFirstChild('FriendCircle')
				local friendText = v:FindFirstChild('ItemText')
				if friendCircle and friendText then 
					friendCircle.BackgroundColor3 = friendText.TextColor3 == Color3.fromRGB(160, 160, 160) and cachedColor or friendCircle.BackgroundColor3
				end
			end
		end
		FriendsTextListTable.Color = cachedColor
		if friendRecolorToggle.Enabled then
			FriendsTextList.FriendColorRefresh:Fire()
		end
	end
})
local ProfilesTextList = {RefreshValues = function() end}
ProfilesTextList = Profiles.CreateTextList({
	Name = 'ProfilesList',
	TempText = 'Type name', 
	NoSave = true,
	AddFunction = function(profileName)
		guilib.Profiles[profileName] = {Keybind = '', Selected = false}
		local profiles = {}
		for i,v in pairs(guilib.Profiles) do 
			table.insert(profiles, i)
		end
		table.sort(profiles, function(a, b) return b == 'default' and true or a:lower() < b:lower() end)
		ProfilesTextList.RefreshValues(profiles)
	end, 
	RemoveFunction = function(profileIndex, profileName) 
		if profileName ~= 'default' and profileName ~= guilib.CurrentProfile then 
			pcall(function() delfile(baseDirectory..'configuration/'..profileName..(shared.CustomSaveVape or game.PlaceId)..'.vapeprofile.txt') end)
			guilib.Profiles[profileName] = nil
		else
			table.insert(ProfilesTextList.ObjectList, profileName)
			ProfilesTextList.RefreshValues(ProfilesTextList.ObjectList)
		end
	end, 
	CustomFunction = function(profileObject, profileName) 
		if guilib.Profiles[profileName] == nil then
			guilib.Profiles[profileName] = {Keybind = ''}
		end
		profileObject.MouseButton1Click:Connect(function()
			guilib.SwitchProfile(profileName)
		end)
		local newsize = UDim2.new(0, 20, 0, 21)
		local bindbkg = Instance.new('TextButton')
		bindbkg.Text = ''
		bindbkg.AutoButtonColor = false
		bindbkg.Size = UDim2.new(0, 20, 0, 21)
		bindbkg.Position = UDim2.new(1, -50, 0, 6)
		bindbkg.BorderSizePixel = 0
		bindbkg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bindbkg.BackgroundTransparency = 0.95
		bindbkg.Visible = guilib.Profiles[profileName].Keybind ~= ''
		bindbkg.Parent = profileObject
		local bindimg = Instance.new('ImageLabel')
		bindimg.Image = downloadasset('rendervape/assets/KeybindIcon.png')
		bindimg.BackgroundTransparency = 1
		bindimg.Size = UDim2.new(0, 12, 0, 12)
		bindimg.Position = UDim2.new(0, 4, 0, 5)
		bindimg.ImageTransparency = 0.2
		bindimg.Active = false
		bindimg.Visible = (guilib.Profiles[profileName].Keybind == '')
		bindimg.Parent = bindbkg
		local bindtext = Instance.new('TextLabel')
		bindtext.Active = false
		bindtext.BackgroundTransparency = 1
		bindtext.TextSize = 16
		bindtext.Parent = bindbkg
		bindtext.Font = Enum.Font.SourceSans
		bindtext.Size = UDim2.new(1, 0, 1, 0)
		bindtext.TextColor3 = Color3.fromRGB(85, 85, 85)
		bindtext.Visible = (guilib.Profiles[profileName].Keybind ~= '')
		local bindtext2 = Instance.new('TextLabel')
		bindtext2.Text = 'PRESS A KEY TO BIND'
		bindtext2.Size = UDim2.new(0, 150, 0, 33)
		bindtext2.Font = Enum.Font.SourceSans
		bindtext2.TextSize = 17
		bindtext2.TextColor3 = Color3.fromRGB(201, 201, 201)
		bindtext2.BackgroundColor3 = Color3.fromRGB(37, 37, 37)
		bindtext2.BorderSizePixel = 0
		bindtext2.Visible = false
		bindtext2.Parent = profileObject
		local bindround = Instance.new('UICorner')
		bindround.CornerRadius = UDim.new(0, 4)
		bindround.Parent = bindbkg
		bindbkg.MouseButton1Click:Connect(function()
			if not guilib.KeybindCaptured then
				guilib.KeybindCaptured = true
				task.spawn(function()
					bindtext2.Visible = true
					repeat task.wait() until guilib.PressedKeybindKey ~= ''
					local key = (guilib.PressedKeybindKey == guilib.Profiles[profileName].Keybind and '' or guilib.PressedKeybindKey)
					if key == '' then
						guilib.Profiles[profileName].Keybind = key
						newsize = UDim2.new(0, 20, 0, 21)
						bindbkg.Size = newsize
						bindbkg.Visible = true
						bindbkg.Position = UDim2.new(1, -(30 + newsize.X.Offset), 0, 6)
						bindimg.Visible = true
						bindtext.Visible = false
						bindtext.Text = key
					else
						local textsize = textservice:GetTextSize(key, 16, bindtext.Font, Vector2.new(99999, 99999))
						newsize = UDim2.new(0, 13 + textsize.X, 0, 21)
						guilib.Profiles[profileName].Keybind = key
						bindbkg.Visible = true
						bindbkg.Size = newsize
						bindbkg.Position = UDim2.new(1, -(30 + newsize.X.Offset), 0, 6)
						bindimg.Visible = false
						bindtext.Visible = true
						bindtext.Text = key
					end
					guilib.PressedKeybindKey = ''
					guilib.KeybindCaptured = false
					bindtext2.Visible = false
				end)
			end
		end)
		bindbkg.MouseEnter:Connect(function() 
			bindimg.Image = downloadasset('rendervape/assets/PencilIcon.png') 
			bindimg.Visible = true
			bindtext.Visible = false
			bindbkg.Size = UDim2.new(0, 20, 0, 21)
			bindbkg.Position = UDim2.new(1, -50, 0, 6)
		end)
		bindbkg.MouseLeave:Connect(function() 
			bindimg.Image = downloadasset('rendervape/assets/KeybindIcon.png')
			if guilib.Profiles[profileName].Keybind ~= '' then
				bindimg.Visible = false
				bindtext.Visible = true
				bindbkg.Size = newsize
				bindbkg.Position = UDim2.new(1, -(30 + newsize.X.Offset), 0, 6)
			end
		end)
		profileObject.MouseEnter:Connect(function()
			bindbkg.Visible = true
		end)
		profileObject.MouseLeave:Connect(function()
			bindbkg.Visible = guilib.Profiles[profileName] and guilib.Profiles[profileName].Keybind ~= ''
		end)
		if guilib.Profiles[profileName].Keybind ~= '' then
			bindtext.Text = guilib.Profiles[profileName].Keybind
			local textsize = textservice:GetTextSize(guilib.Profiles[profileName].Keybind, 16, bindtext.Font, Vector2.new(99999, 99999))
			newsize = UDim2.new(0, 13 + textsize.X, 0, 21)
			bindbkg.Size = newsize
			bindbkg.Position = UDim2.new(1, -(30 + newsize.X.Offset), 0, 6)
		end
		if profileName == guilib.CurrentProfile then
			profileObject.BackgroundColor3 = Color3.fromHSV(guilib.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, guilib.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, guilib.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
			profileObject.ImageButton.BackgroundColor3 = Color3.fromHSV(guilib.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Hue, guilib.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Sat, guilib.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api.Value)
			profileObject.ItemText.TextColor3 = Color3.new(1, 1, 1)
			profileObject.ItemText.TextStrokeTransparency = 0.75
			bindbkg.BackgroundTransparency = 0.9
			bindtext.TextColor3 = Color3.fromRGB(214, 214, 214)
		end
	end
})
mainwin.CreateDivider()

local TextGUI = guilib.CreateCustomWindow({
	Name = 'Text GUI', 
	Icon = 'rendervape/assets/TextGUIIcon1.png', 
	IconSize = 21
})
local TextGUICircleObject = {CircleList = {}}
mainwin.CreateCustomToggle({
	Name = 'Text GUI', 
	Icon = 'rendervape/assets/TextGUIIcon3.png',
	Function = function(callback) TextGUI.SetVisible(callback) end,
	Priority = 2
})	
local GUIColorSlider = {RainbowValue = false}
local TextGUIMode = {Value = 'Normal'}
local TextGUISortMode = {Value = 'Alphabetical'}
local TextGUIBackgroundToggle = {Enabled = false}
local TextGUIObjects = {Logo = {}, Labels = {}, ShadowLabels = {}, Backgrounds = {}}
local TextGUIConnections = {}
local TextGUIFormatted = {}
local VapeLogoFrame = Instance.new('Frame')
VapeLogoFrame.BackgroundTransparency = 1
VapeLogoFrame.Size = UDim2.new(1, 0, 1, 0)
VapeLogoFrame.Parent = TextGUI.GetCustomChildren()
local VapeLogo = Instance.new('ImageLabel')
VapeLogo.Parent = VapeLogoFrame
VapeLogo.Name = 'Logo'
VapeLogo.Size = UDim2.new(0, 92, 0, 25)
VapeLogo.Position = UDim2.new(1, -125, 0, 8)
VapeLogo.BackgroundColor3 = Color3.new()
VapeLogo.BorderSizePixel = 0
VapeLogo.BackgroundTransparency = 1
VapeLogo.Visible = true
VapeLogo.Image = downloadasset('rendervape/assets/VapeLogo3.png')
local VapeLogoV4 = Instance.new('ImageLabel')
VapeLogoV4.Parent = VapeLogo
VapeLogoV4.Size = UDim2.new(0, 39, 0, 22)
VapeLogoV4.Name = 'Logo2'
VapeLogoV4.Position = UDim2.new(1, 0, 0, 1)
VapeLogoV4.BorderSizePixel = 0
VapeLogoV4.BackgroundColor3 = Color3.new()
VapeLogoV4.BackgroundTransparency = 1
VapeLogoV4.Image = downloadasset('rendervape/assets/VapeLogo4.png')
local VapeLogoShadow = VapeLogo:Clone()
VapeLogoShadow.ImageColor3 = Color3.new()
VapeLogoShadow.ImageTransparency = 0.5
VapeLogoShadow.ZIndex = 0
VapeLogoShadow.Position = UDim2.new(0, 1, 0, 1)
VapeLogoShadow.Visible = false
VapeLogoShadow.Parent = VapeLogo
VapeLogoShadow.Logo2.ImageColor3 = Color3.new()
VapeLogoShadow.Logo2.ZIndex = 0
VapeLogoShadow.Logo2.ImageTransparency = 0.5
local VapeLogoGradient = Instance.new('UIGradient')
VapeLogoGradient.Rotation = 90
VapeLogoGradient.Parent = VapeLogo
local VapeLogoGradient2 = Instance.new('UIGradient')
VapeLogoGradient2.Rotation = 90
VapeLogoGradient2.Parent = VapeLogoV4
local VapeText = Instance.new('TextLabel')
VapeText.Parent = VapeLogoFrame
VapeText.Size = UDim2.new(1, 0, 1, 0)
VapeText.Position = UDim2.new(1, -154, 0, 35)
VapeText.TextColor3 = Color3.new(1, 1, 1)
VapeText.RichText = true
VapeText.BackgroundTransparency = 1
VapeText.LineHeight = 1.2
VapeText.TextXAlignment = Enum.TextXAlignment.Left
VapeText.TextYAlignment = Enum.TextYAlignment.Top
VapeText.BorderSizePixel = 0
VapeText.BackgroundColor3 = Color3.new()
VapeText.Font = Enum.Font.SourceSans
VapeText.Text = ''
VapeText.TextSize = 19
VapeText.Visible = false
local VapeTextExtra = Instance.new('TextLabel')
VapeTextExtra.Name = 'ExtraText'
VapeTextExtra.Parent = VapeText
VapeTextExtra.LineHeight = 1.2
VapeTextExtra.Size = UDim2.new(1, 0, 1, 0)
VapeTextExtra.Position = UDim2.new(0, 1, 0, 1)
VapeTextExtra.BorderSizePixel = 0
VapeTextExtra.Visible = false
VapeTextExtra.ZIndex = 0
VapeTextExtra.Text = ''
VapeTextExtra.BackgroundTransparency = 1
VapeTextExtra.TextTransparency = 0.5
VapeTextExtra.TextXAlignment = Enum.TextXAlignment.Left
VapeTextExtra.TextYAlignment = Enum.TextYAlignment.Top
VapeTextExtra.TextColor3 = Color3.new()
VapeTextExtra.Font = Enum.Font.SourceSans
VapeTextExtra.TextSize = 19
local VapeCustomText = Instance.new('TextLabel')
VapeCustomText.TextSize = 26
VapeCustomText.Font = Enum.Font.GothamBold
VapeCustomText.Size = UDim2.new(1, 0, 1, 0)
VapeCustomText.BackgroundTransparency = 1
VapeCustomText.Position = UDim2.new(0, 0, 0, 41)
VapeCustomText.TextXAlignment = Enum.TextXAlignment.Left
VapeCustomText.TextYAlignment = Enum.TextYAlignment.Top
VapeCustomText.Text = ''
VapeCustomText.Parent = VapeLogoFrame
local VapeCustomTextShadow = VapeCustomText:Clone()
VapeCustomTextShadow.ZIndex = -1
VapeCustomTextShadow.Size = UDim2.new(1, 0, 1, 0)
VapeCustomTextShadow.TextTransparency = 0.5
VapeCustomTextShadow.TextColor3 = Color3.new()
VapeCustomTextShadow.Position = UDim2.new(0, 1, 0, 1)
VapeCustomTextShadow.Parent = VapeCustomText
VapeCustomText:GetPropertyChangedSignal('TextXAlignment'):Connect(function()
	VapeCustomTextShadow.TextXAlignment = VapeCustomText.TextXAlignment
end)
local VapeBackground = Instance.new('Frame')
VapeBackground.BackgroundTransparency = 1
VapeBackground.BorderSizePixel = 0
VapeBackground.BackgroundColor3 = Color3.new()
VapeBackground.Size = UDim2.new(1, 0, 1, 0)
VapeBackground.Visible = false 
VapeBackground.Parent = VapeLogoFrame
VapeBackground.ZIndex = 0
local VapeBackgroundList = Instance.new('UIListLayout')
VapeBackgroundList.FillDirection = Enum.FillDirection.Vertical
VapeBackgroundList.SortOrder = Enum.SortOrder.LayoutOrder
VapeBackgroundList.Padding = UDim.new(0, 0)
VapeBackgroundList.Parent = VapeBackground
local VapeBackgroundTable = {}
local VapeScale = Instance.new('UIScale')
VapeScale.Parent = VapeLogoFrame
--why do other platforms do rendering differently
local toggledmodule = ''
local untoggledmodule = ''
local TextGUIOffsets = {
	[Enum.Platform.Android] = {
		6,
		-10,
		15,
		12
	},
	[Enum.Platform.UWP] = {
		1,
		1,
		23,
		23
	}
}
TextGUIOffsets[Enum.Platform.IOS] = TextGUIOffsets[Enum.Platform.Android]
local textguiupd: number = 0;
local fadeoutTween
local function TextGUIUpdate(moduleToggled: {Enabled: boolean, ExtraText: () -> (), Name: string}): ()
	moduleToggled = moduleToggled or {Enabled = nil, Name = 'nil', ExtraText = function()
		return ''
	end};
	textguiupd = 0;
	local scaledgui = vapeInjected and guilib.MainGui.ScaledGui
	if scaledgui and scaledgui.Visible then
		local formattedText = ''
		local moduleList = {}

		for i, v in pairs(guilib.ObjectsThatCanBeSaved) do
			if v.Type == 'OptionsButton' and v.Api.Enabled then
				local blacklistedCheck = table.find(TextGUICircleObject.CircleList.ObjectList, v.Api.Name)
				blacklistedCheck = blacklistedCheck and TextGUICircleObject.CircleList.ObjectList[blacklistedCheck]
				if not blacklistedCheck then
					local extraText = v.Api.GetExtraText()
					table.insert(moduleList, {Text = v.Api.Name, ExtraText = extraText ~= '' and ' '..extraText or '', Tab = 'n'})
				end
			end
		end

		if TextGUISortMode.Value == 'Alphabetical' then
			table.sort(moduleList, function(a, b) return a.Text:lower() < b.Text:lower() end)
		else
			table.sort(moduleList, function(a, b)
				return textservice:GetTextSize(a.Text..a.ExtraText, VapeText.TextSize, VapeText.Font, Vector2.new(1000000, 1000000)).X > textservice:GetTextSize(b.Text..b.ExtraText, VapeText.TextSize, VapeText.Font, Vector2.new(1000000, 1000000)).X
			end)
		end

		if render and render.array and render.array.reset then
			render.array.reset();
			for i: number, v: table in moduleList do
				local textsize = textservice:GetTextSize(v.Text..v.ExtraText, 14, Enum.Font.Arimo, Vector2.new(1000000, 1000000))
				render.array.new(v, textsize.X + 8);
			end;
		end;

		local backgroundList = {}
		local first = true
		for i, v in pairs(moduleList) do
			local newEntryText = v.Text..v.ExtraText
			if first then
				formattedText = '\n'..newEntryText
				first = false
			else
				formattedText = formattedText..'\n'..newEntryText
			end
			table.insert(backgroundList, newEntryText)
		end

		TextGUIFormatted = moduleList
		VapeTextExtra.Text = formattedText
		VapeText.Size = UDim2.fromOffset(154, (formattedText ~= '' and textservice:GetTextSize(formattedText, VapeText.TextSize, VapeText.Font, Vector2.new(1000000, 1000000)) or Vector2.zero).Y)

		local offsets = {
			5,
			1,
			23,
			10
		}
		if TextGUI.GetCustomChildren().Parent then
			VapeText.TextXAlignment = Enum.TextXAlignment.Right
			VapeTextExtra.TextXAlignment = Enum.TextXAlignment.Right
			VapeTextExtra.Position = UDim2.fromOffset(offsets[1], offsets[2])
			VapeLogo.Position = UDim2.new(1, -125, 0, 8)
			VapeText.Position = UDim2.new(1, -158, 0, (VapeLogo.Visible and (TextGUIBackgroundToggle.Enabled and 41 or 35) or 5) + 5 + (VapeCustomText.Visible and 25 or 0) - offsets[3])
			VapeCustomText.Position = UDim2.fromOffset(0, VapeLogo.Visible and 38 or 0)
			VapeCustomText.TextXAlignment = Enum.TextXAlignment.Right
			VapeBackgroundList.HorizontalAlignment = Enum.HorizontalAlignment.Right
			VapeBackground.Position = VapeText.Position + UDim2.fromOffset(-60, 24)
		end

		if moduleToggled.Name == 'nil' then return end;

		local toggledmod = toggledmodule
		if fadeoutTween then
			fadeoutTween:Cancel();
		end
		local animplayed = false
		local backgrounds: {Instance} = VapeBackground:GetChildren()
		for i,v in backgrounds do
			table.clear(VapeBackgroundTable);
			if v:IsA('Frame') and v.ColorFrame.rrr.Text == moduleToggled.Name and not animplayed and not moduleToggled.Enabled then 
				animplayed = true;
				task.spawn(function()
					tweenservice:Create(v.ColorFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 1, 0)}):Play()
					fadeoutTween = tweenservice:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(0, 0, 0, v.Size.Y)})
					v.ColorFrame.TextLabel.Visible = false
					fadeoutTween:Play();
					fadeoutTween.Completed:Wait();
					task.wait(0.3);
					v:Destroy();
				end)
			elseif v:IsA('Frame') then
				v:Destroy();
			end;
		end;
		for i,v in pairs(moduleList) do
			local textsize = textservice:GetTextSize(v.Text..v.ExtraText, VapeText.TextSize, VapeText.Font, Vector2.new(1000000, 1000000))
			local backgroundFrame = Instance.new('Frame')
			backgroundFrame.BorderSizePixel = 0
			backgroundFrame.BackgroundTransparency = TextGUIBackgroundToggle.Enabled and 0.45 or 1
			backgroundFrame.BackgroundColor3 = Color3.new()
			backgroundFrame.Visible = true
			backgroundFrame.Size = UDim2.fromOffset(0, textsize.Y * 1.211)
			backgroundFrame.ZIndex = 0
			backgroundFrame.LayoutOrder = i
			backgroundFrame.Parent = VapeBackground
			local backgroundLineFrame = Instance.new('Frame')
			local TextLabel2 = Instance.new('TextLabel', backgroundLineFrame)
			TextLabel2.Name = 'rrr'
			TextLabel2.Text = v.Text
			TextLabel2.Visible = false;
			TextLabel2.BorderSizePixel = 0
			backgroundLineFrame.Position = (VapeBackgroundList.HorizontalAlignment == Enum.HorizontalAlignment.Left and UDim2.new() or UDim2.new(1, -2, 0, 0))
			backgroundLineFrame.BorderSizePixel = 0
			backgroundLineFrame.Name = 'ColorFrame'
			backgroundLineFrame.BackgroundTransparency = TextGUIBackgroundToggle.Enabled and 0 or 1;
			backgroundLineFrame.Size = UDim2.new(0, 0, 0, 0)
			backgroundLineFrame.Parent = backgroundFrame
			local backgroundLineExtra = Instance.new('Frame')
			backgroundLineExtra.BorderSizePixel = 0
			backgroundLineExtra.BackgroundTransparency = TextGUIBackgroundToggle.Enabled and 0.95 or 1;
			backgroundLineExtra.BackgroundColor3 = Color3.new()
			backgroundLineExtra.ZIndex = 0
			backgroundLineExtra.ClipsDescendants = false
			backgroundLineExtra.Size = UDim2.new(1, 0, 0, 2)
			backgroundLineExtra.Position = UDim2.new(0, 0, 1, -1)
			backgroundLineExtra.Parent = backgroundFrame
			local TextLabel = Instance.new('TextLabel', backgroundLineFrame)
			TextLabel.Font = VapeText.Font
			TextLabel.RichText = true;
			TextLabel.TextColor3 = Color3.fromHSV(GUIColorSlider.Hue, GUIColorSlider.Sat, GUIColorSlider.Value)
			TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			TextLabel.Text = `{v.Text}<font color='rgb(170, 170, 170)'>{v.ExtraText}</font>`
			TextLabel.BackgroundTransparency = 1
			TextLabel.Size = UDim2.new(0, 60, 0, 21)
			TextLabel.TextSize = VapeText.TextSize
			TextLabel.TextXAlignment = Enum.TextXAlignment.Right
			local size = TextGUIBackgroundToggle.Enabled and 31.5 or 29
			local pos = not TextGUIBackgroundToggle.Enabled and 0.25 + (i ~= 1 and -0.02 or 0) or 0
			TextLabel.Position = UDim2.new(VapeBackgroundList.HorizontalAlignment == Enum.HorizontalAlignment.Left and size or -size, 0, pos, 0)
			TextLabel.BorderSizePixel = 0
			local shadow
			if textguishadow then
				shadow = TextLabel:Clone();
				shadow.Parent = TextLabel;
				shadow.Position = UDim2.new(0, 2, 0, 1);
				shadow.TextTransparency = 0.6
				shadow.Name = 'TextShadow'
				shadow.Visible = true
				shadow.Text = `{v.Text}{v.ExtraText}`
				shadow.TextColor3 = Color3.fromRGB(0, 0, 0);
				local shadow2 = shadow:Clone()
				shadow2.Parent = TextLabel;
				shadow2.Position = UDim2.new(0, -1.5, 0, -1);
			end


			if TextGUIBackgroundToggle.Enabled and moduleToggled.Name == v.Text and moduleToggled.Enabled then
				TextLabel.Visible = false
			end

			tweenservice:Create(backgroundLineFrame, TweenInfo.new(moduleToggled.Name == v.Text and 0.08 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 2, 1, 0)}):Play()

			if not TextGUIBackgroundToggle.Enabled and moduleToggled.Name == v.Text and moduleToggled.Enabled then
				backgroundFrame.Size = UDim2.fromOffset(textsize.X + 7.5, textsize.Y * 1.211)
				TextLabel.Position = UDim2.new(VapeBackgroundList.HorizontalAlignment == Enum.HorizontalAlignment.Left and 21 or -21, 0, pos, 0)
				tweenservice:Create(TextLabel, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Position = UDim2.new(VapeBackgroundList.HorizontalAlignment == Enum.HorizontalAlignment.Left and size or -size, 0, pos, 0)}):Play()
			end

			if TextGUIBackgroundToggle.Enabled then
				tweenservice:Create(backgroundFrame, TweenInfo.new(TextGUIBackgroundToggle.Enabled and moduleToggled.Enabled and moduleToggled.Name == v.Text and 0.25 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(textsize.X + 8, textsize.Y * 1.211)}):Play()
			end
		
			task.delay(0.15, function()
				TextLabel.Visible = true
			end)

			table.insert(VapeBackgroundTable, backgroundFrame)
		end

		guilib.UpdateUI(GUIColorSlider.Hue, GUIColorSlider.Sat, GUIColorSlider.Value)
	end
end
guilib.ModuleToggled.Event:Connect(function(module: table): ()
	TextGUIUpdate(module);
end)
TextGUI.GetCustomChildren().Parent:GetPropertyChangedSignal('Position'):Connect(TextGUIUpdate)
guilib.UpdateHudEvent.Event:Connect(TextGUIUpdate)
VapeScale:GetPropertyChangedSignal('Scale'):Connect(function()
	local childrenobj = TextGUI.GetCustomChildren()
	local check = (childrenobj.Parent.Position.X.Offset + childrenobj.Parent.Size.X.Offset / 2) >= (camera.ViewportSize.X / 2)
	childrenobj.Position = UDim2.new((check and -(VapeScale.Scale - 1) or 0), (check and 0 or -6 * (VapeScale.Scale - 1)), 1, -6 * (VapeScale.Scale - 1))
	TextGUIUpdate()
end)
TextGUIMode = TextGUI.CreateDropdown({
	Name = 'Mode',
	List = {'Normal', 'Drawing'},
	Function = function(val)
		VapeLogoFrame.Visible = val == 'Normal'
		for i,v in pairs(TextGUIConnections) do 
			v:Disconnect()
		end
		for i,v in pairs(TextGUIObjects) do 
			for i2,v2 in pairs(v) do 
				v2.Visible = false
				v2:Remove()
				v[i2] = nil
			end
		end
		if val == 'Drawing' then
			local VapeLogoDrawing = Drawing.new('Image')
			VapeLogoDrawing.Data = readfile('rendervape/assets/VapeLogo3.png')
			VapeLogoDrawing.Size = VapeLogo.AbsoluteSize
			VapeLogoDrawing.Position = VapeLogo.AbsolutePosition + Vector2.new(0, 36)
			VapeLogoDrawing.ZIndex = 2
			VapeLogoDrawing.Visible = VapeLogo.Visible
			local VapeLogoV4Drawing = Drawing.new('Image')
			VapeLogoV4Drawing.Data = readfile('rendervape/assets/VapeLogo4.png')
			VapeLogoV4Drawing.Size = VapeLogoV4.AbsoluteSize
			VapeLogoV4Drawing.Position = VapeLogoV4.AbsolutePosition + Vector2.new(0, 36)
			VapeLogoV4Drawing.ZIndex = 2
			VapeLogoV4Drawing.Visible = VapeLogo.Visible
			local VapeLogoShadowDrawing = Drawing.new('Image')
			VapeLogoShadowDrawing.Data = readfile('rendervape/assets/VapeLogo3.png')
			VapeLogoShadowDrawing.Size = VapeLogo.AbsoluteSize
			VapeLogoShadowDrawing.Position = VapeLogo.AbsolutePosition + Vector2.new(1, 37)
			VapeLogoShadowDrawing.Transparency = 0.5
			VapeLogoShadowDrawing.Visible = VapeLogo.Visible and VapeLogoShadow.Visible
			local VapeLogo4Drawing = Drawing.new('Image')
			VapeLogo4Drawing.Data = readfile('rendervape/assets/VapeLogo4.png')
			VapeLogo4Drawing.Size = VapeLogoV4.AbsoluteSize
			VapeLogo4Drawing.Position = VapeLogoV4.AbsolutePosition + Vector2.new(1, 37)
			VapeLogo4Drawing.Transparency = 0.5
			VapeLogo4Drawing.Visible = VapeLogo.Visible and VapeLogoShadow.Visible
			local VapeCustomDrawingText = Drawing.new('Text')
			VapeCustomDrawingText.Size = 30
			VapeCustomDrawingText.Text = VapeCustomText.Text
			VapeCustomDrawingText.Color = VapeCustomText.TextColor3
			VapeCustomDrawingText.ZIndex = 2
			VapeCustomDrawingText.Position = VapeCustomText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeCustomText.AbsoluteSize.X - VapeCustomDrawingText.TextBounds.X), 32)
			VapeCustomDrawingText.Visible = VapeCustomText.Visible
			local VapeCustomDrawingShadow = Drawing.new('Text')
			VapeCustomDrawingShadow.Size = 30
			VapeCustomDrawingShadow.Text = VapeCustomText.Text
			VapeCustomDrawingShadow.Transparency = 0.5
			VapeCustomDrawingShadow.Color = Color3.new()
			VapeCustomDrawingShadow.Position = VapeCustomDrawingText.Position + Vector2.new(1, 1)
			VapeCustomDrawingShadow.Visible = VapeCustomText.Visible and VapeTextExtra.Visible
			pcall(function()
				VapeLogoShadowDrawing.Color = Color3.new()
				VapeLogo4Drawing.Color = Color3.new()
				VapeLogoDrawing.Color = VapeLogoGradient.Color.Keypoints[1].Value
			end)
			table.insert(TextGUIObjects.Logo, VapeLogoDrawing)
			table.insert(TextGUIObjects.Logo, VapeLogoV4Drawing)
			table.insert(TextGUIObjects.Logo, VapeLogoShadowDrawing)
			table.insert(TextGUIObjects.Logo, VapeLogo4Drawing)
			table.insert(TextGUIObjects.Logo, VapeCustomDrawingText)
			table.insert(TextGUIObjects.Logo, VapeCustomDrawingShadow)
			table.insert(TextGUIConnections, VapeLogo:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
				VapeLogoDrawing.Position = VapeLogo.AbsolutePosition + Vector2.new(0, 36)
				VapeLogoShadowDrawing.Position = VapeLogo.AbsolutePosition + Vector2.new(1, 37)
			end))
			table.insert(TextGUIConnections, VapeLogo:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
				VapeLogoDrawing.Size = VapeLogo.AbsoluteSize
				VapeLogoShadowDrawing.Size = VapeLogo.AbsoluteSize
				VapeCustomDrawingText.Size = 30 * VapeScale.Scale
				VapeCustomDrawingShadow.Size = 30 * VapeScale.Scale
			end))
			table.insert(TextGUIConnections, VapeLogoV4:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
				VapeLogoV4Drawing.Position = VapeLogoV4.AbsolutePosition + Vector2.new(0, 36)
				VapeLogo4Drawing.Position = VapeLogoV4.AbsolutePosition + Vector2.new(1, 37)
			end))
			table.insert(TextGUIConnections, VapeLogoV4:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
				VapeLogoV4Drawing.Size = VapeLogoV4.AbsoluteSize
				VapeLogo4Drawing.Size = VapeLogoV4.AbsoluteSize
			end))
			table.insert(TextGUIConnections, VapeCustomText:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
				VapeCustomDrawingText.Position = VapeCustomText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeCustomText.AbsoluteSize.X - VapeCustomDrawingText.TextBounds.X), 32)
				VapeCustomDrawingShadow.Position = VapeCustomDrawingText.Position + Vector2.new(1, 1)
			end))
			table.insert(TextGUIConnections, VapeLogoShadow:GetPropertyChangedSignal('Visible'):Connect(function()
				VapeLogoShadowDrawing.Visible = VapeLogoShadow.Visible
				VapeLogo4Drawing.Visible = VapeLogoShadow.Visible
			end))
			table.insert(TextGUIConnections, VapeTextExtra:GetPropertyChangedSignal('Visible'):Connect(function()
				for i,textdraw in pairs(TextGUIObjects.ShadowLabels) do 
					textdraw.Visible = VapeTextExtra.Visible
				end
				VapeCustomDrawingShadow.Visible = VapeCustomText.Visible and VapeTextExtra.Visible
			end))
			table.insert(TextGUIConnections, VapeLogo:GetPropertyChangedSignal('Visible'):Connect(function()
				VapeLogoDrawing.Visible = VapeLogo.Visible
				VapeLogoV4Drawing.Visible = VapeLogo.Visible
				VapeLogoShadowDrawing.Visible = VapeLogo.Visible and VapeTextExtra.Visible
				VapeLogo4Drawing.Visible = VapeLogo.Visible and VapeTextExtra.Visible
			end))
			table.insert(TextGUIConnections, VapeCustomText:GetPropertyChangedSignal('Visible'):Connect(function()
				VapeCustomDrawingText.Visible = VapeCustomText.Visible
				VapeCustomDrawingShadow.Visible = VapeCustomText.Visible and VapeTextExtra.Visible
			end))
			table.insert(TextGUIConnections, VapeCustomText:GetPropertyChangedSignal('Text'):Connect(function()
				VapeCustomDrawingText.Text = VapeCustomText.Text
				VapeCustomDrawingShadow.Text = VapeCustomText.Text
				VapeCustomDrawingText.Position = VapeCustomText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeCustomText.AbsoluteSize.X - VapeCustomDrawingText.TextBounds.X), 32)
				VapeCustomDrawingShadow.Position = VapeCustomDrawingText.Position + Vector2.new(1, 1)
			end))
			table.insert(TextGUIConnections, VapeCustomText:GetPropertyChangedSignal('TextColor3'):Connect(function()
				VapeCustomDrawingText.Color = VapeCustomText.TextColor3
			end))
			table.insert(TextGUIConnections, VapeText:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
				for i,textdraw in pairs(TextGUIObjects.Labels) do 
					textdraw.Position = VapeText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeText.AbsoluteSize.X - textdraw.TextBounds.X), ((textdraw.Size - 3) * i) + 6)
				end
				for i,textdraw in pairs(TextGUIObjects.ShadowLabels) do 
					textdraw.Position = Vector2.new(1, 1) + (VapeText.AbsolutePosition + Vector2.new(VapeText.TextXAlignment == Enum.TextXAlignment.Right and (VapeText.AbsoluteSize.X - textdraw.TextBounds.X), ((textdraw.Size - 3) * i) + 6))
				end
			end))
			table.insert(TextGUIConnections, VapeLogoGradient:GetPropertyChangedSignal('Color'):Connect(function()
				pcall(function()
					VapeLogoDrawing.Color = VapeLogoGradient.Color.Keypoints[1].Value
				end)
			end))
		end
	end
})

guilib.UpdateTextGUI = TextGUIUpdate 

TextGUISortMode = TextGUI.CreateDropdown({
	Name = 'Sort',
	List = {'Alphabetical', 'Length'},
	Function = function(val)
		guilib.UpdateHudEvent:Fire()
	end
})
local TextGUIFonts = {'Arial'}
local TextGUIFonts2 = {'GothamBold'}
for i,v in pairs(Enum.Font:GetEnumItems()) do 
	if v.Name ~= 'Arial' then
		table.insert(TextGUIFonts, v.Name)
	end
	if v.Name ~= 'GothamBold' then
		table.insert(TextGUIFonts2, v.Name)
	end
end
TextGUI.CreateDropdown({
	Name = 'Font',
	List = TextGUIFonts,
	Function = function(val)
		VapeText.Font = Enum.Font[val]
		VapeTextExtra.Font = Enum.Font[val]
		guilib.UpdateHudEvent:Fire()
	end
})
TextGUI.CreateDropdown({
	Name = 'CustomTextFont',
	List = TextGUIFonts2,
	Function = function(val)
		VapeCustomText.Font = Enum.Font[val]
		VapeCustomTextShadow.Font = Enum.Font[val]
		guilib.UpdateHudEvent:Fire()
	end
})
TextGUI.CreateSlider({
	Name = 'Scale',
	Min = 1,
	Max = 50,
	Default = 10,
	Function = function(val)
		VapeScale.Scale = val / 10
	end
})
local highlighttlink = false;
TextGUI.CreateToggle({
	Name = 'Highlight Link',
	Function = function(call: boolean): () 
		highlighttlink = call
	end
})
TextGUI.CreateToggle({
	Name = 'Shadow', 
	Function = function(callback) 
		textguishadow = callback;
		VapeLogoShadow.Visible = callback ;
	end,
	HoverText = 'Renders shadowed text.'
})
TextGUI.CreateToggle({
	Name = 'Watermark', 
	Function = function(callback) 
		VapeLogo.Visible = callback
		guilib.UpdateHudEvent:Fire()
	end,
	HoverText = 'Renders a vape watermark'
})
TextGUIBackgroundToggle = TextGUI.CreateToggle({
	Name = 'Render background', 
	Function = function(callback)
		guilib.UpdateHudEvent:Fire()
	end
})
VapeBackground.Visible = true;
TextGUI.CreateToggle({
	Name = 'Hide Modules',
	Function = function(callback) 
		if TextGUICircleObject.Object then
			TextGUICircleObject.Object.Visible = callback
		end
	end
})
TextGUICircleObject = TextGUI.CreateCircleWindow({
	Name = 'Blacklist',
	Type = 'Blacklist',
	UpdateFunction = function()
		guilib.UpdateHudEvent:Fire()
	end
})
TextGUICircleObject.Object.Visible = false
local TextGUIGradient = TextGUI.CreateToggle({
	Name = 'Gradient Logo',
	Function = function() 
		guilib.UpdateHudEvent:Fire()
	end
})
TextGUI.CreateToggle({
	Name = 'Alternate Text',
	Function = function() 
		guilib.UpdateHudEvent:Fire()
	end
})
local CustomText = {Value = '', Object = nil}
TextGUI.CreateToggle({
	Name = 'Add custom text', 
	Function = function(callback) 
		VapeCustomText.Visible = callback
		CustomText.Object.Visible = callback
		guilib.UpdateHudEvent:Fire()
	end,
	HoverText = 'Renders a custom label'
})
CustomText = TextGUI.CreateTextBox({
	Name = 'Custom text',
	FocusLost = function(enter)
		VapeCustomText.Text = CustomText.Value
		VapeCustomTextShadow.Text = CustomText.Value
	end
})
CustomText.Object.Visible = false
local function newHealthColor(percent)
	if percent > 0.5 then 
		return Color3.fromRGB(115, 255, 110):lerp(Color3.fromRGB(255, 255, 0), (0.5 - (percent - 0.5)) / 0.5)
	end
	return Color3.fromRGB(255, 255, 0):lerp(Color3.fromRGB(249, 57, 55), (0.5 - percent) / 0.5)
end

local TargetInfoBackground = {Enabled = false}
local TargetInfoBackgroundColor = {Hue = 0, Sat = 0, Value = 0}
local TargetInfoMainFrame = Instance.new('Frame')
TargetInfoMainFrame.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
TargetInfoMainFrame.BorderSizePixel = 0
TargetInfoMainFrame.BackgroundTransparency = 1
TargetInfoMainFrame.Size = UDim2.new(0, 220, 0, 72)
TargetInfoMainFrame.Position = UDim2.new(0, 0, 0, 5)
local TargetInfoMainInfo = Instance.new('Frame')
TargetInfoMainInfo.BackgroundColor3 = Color3.fromRGB(31, 30, 31)
TargetInfoMainInfo.Size = UDim2.new(0, 220, 0, 80)
TargetInfoMainInfo.BackgroundTransparency = 0.5
TargetInfoMainInfo.Position = UDim2.new(0, 0, 0, 0)
TargetInfoMainInfo.Name = 'MainInfo'
TargetInfoMainInfo.Parent = TargetInfoMainFrame
local TargetInfoName = Instance.new('TextLabel')
TargetInfoName.Font = Enum.Font.Arial
TargetInfoName.TextColor3 = Color3.fromRGB(162, 162, 162)
TargetInfoName.Position = UDim2.new(0, 70, 0, 13)
TargetInfoName.TextStrokeTransparency = 1
TargetInfoName.BackgroundTransparency = 1
TargetInfoName.Size = UDim2.new(0, 80, 0, 20)
TargetInfoName.Text = players.LocalPlayer.DisplayName or 'None'
TargetInfoName.ZIndex = 2
TargetInfoName.TextXAlignment = Enum.TextXAlignment.Left
TargetInfoName.TextYAlignment = Enum.TextYAlignment.Top
TargetInfoName.Parent = TargetInfoMainInfo
local TargetInfoNameShadow = TargetInfoName:Clone()
TargetInfoNameShadow.Size = UDim2.new(1, 0, 1, 0)
TargetInfoNameShadow.TextTransparency = 0.5
TargetInfoNameShadow.TextColor3 = Color3.new()
TargetInfoNameShadow.ZIndex = 1
TargetInfoNameShadow.Position = UDim2.new(0, 1, 0, 1)
TargetInfoName:GetPropertyChangedSignal('Text'):Connect(function()
	TargetInfoNameShadow.Text = TargetInfoName.Text
end)
TargetInfoNameShadow.Parent = TargetInfoName
local TargetInfoHealthBackground = Instance.new('Frame')
TargetInfoHealthBackground.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
TargetInfoHealthBackground.Size = UDim2.new(0, 140, 0, 4)
TargetInfoHealthBackground.Position = UDim2.new(0, 71, 0, 35)
TargetInfoHealthBackground.Parent = TargetInfoMainInfo
local TargetInfoHealthBackgroundShadow = Instance.new('ImageLabel')
TargetInfoHealthBackgroundShadow.AnchorPoint = Vector2.new(0.5, 0.5)
TargetInfoHealthBackgroundShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
TargetInfoHealthBackgroundShadow.Image = downloadasset('rendervape/assets/WindowBlur.png')
TargetInfoHealthBackgroundShadow.BackgroundTransparency = 1
TargetInfoHealthBackgroundShadow.ImageTransparency = 0.6
TargetInfoHealthBackgroundShadow.ZIndex = -1
TargetInfoHealthBackgroundShadow.Size = UDim2.new(1, 6, 1, 6)
TargetInfoHealthBackgroundShadow.ImageColor3 = Color3.new()
TargetInfoHealthBackgroundShadow.ScaleType = Enum.ScaleType.Slice
TargetInfoHealthBackgroundShadow.SliceCenter = Rect.new(10, 10, 118, 118)
TargetInfoHealthBackgroundShadow.Parent = TargetInfoHealthBackground
local TargetInfoHealth = Instance.new('Frame')
TargetInfoHealth.BackgroundColor3 = Color3.fromRGB(115, 255, 110)
TargetInfoHealth.Size = UDim2.new(1, 0, 1, 0)
TargetInfoHealth.ZIndex = 3
TargetInfoHealth.BorderSizePixel = 0
TargetInfoHealth.Parent = TargetInfoHealthBackground
local TargetInfoHealthExtra = Instance.new('Frame')
TargetInfoHealthExtra.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
TargetInfoHealthExtra.Size = UDim2.new(0, 0, 1, 0)
TargetInfoHealthExtra.ZIndex = 4
TargetInfoHealthExtra.BorderSizePixel = 0
TargetInfoHealthExtra.AnchorPoint = Vector2.new(1, 0)
TargetInfoHealthExtra.Position = UDim2.new(1, 0, 0, 0)
TargetInfoHealthExtra.Parent = TargetInfoHealth
local TargetInfoImage = Instance.new('ImageLabel')
TargetInfoImage.Size = UDim2.new(0, 50, 0, 50)
TargetInfoImage.BackgroundTransparency = 0
TargetInfoImage.BackgroundColor3 = Color3.fromRGB(26, 25, 26)
TargetInfoImage.Image = 'rbxthumb://type=AvatarHeadShot&id='..players.LocalPlayer.UserId..'&w=420&h=420'
TargetInfoImage.Position = UDim2.new(0, 10, 0, 16)

TargetInfoImage.Parent = TargetInfoMainInfo
local TargetInfoMainInfoCorner = Instance.new('UICorner')
TargetInfoMainInfoCorner.CornerRadius = UDim.new(0, 6)
TargetInfoMainInfoCorner.Parent = TargetInfoMainInfo
local TargetInfoHealthBackgroundCorner = Instance.new('UICorner')
TargetInfoHealthBackgroundCorner.CornerRadius = UDim.new(0, 2048)
TargetInfoHealthBackgroundCorner.Parent = TargetInfoHealthBackground
local TargetInfoHealthCorner = Instance.new('UICorner')
TargetInfoHealthCorner.CornerRadius = UDim.new(0, 2048)
TargetInfoHealthCorner.Parent = TargetInfoHealth
local TargetInfoHealthCorner2 = Instance.new('UICorner')
TargetInfoHealthCorner2.CornerRadius = UDim.new(0, 2048)
TargetInfoHealthCorner2.Parent = TargetInfoHealthExtra
local TargetInfoHealthExtraCorner = Instance.new('UICorner')
TargetInfoHealthExtraCorner.CornerRadius = UDim.new(0, 8)
TargetInfoHealthExtraCorner.Parent = TargetInfoImage

local currentTarget: table = nil;
local TargetInfoHealthTween;
local damageanimation = nil;
local damageanimation2 = nil;
shared.VapeTargetInfo = {
	UpdateInfo = function(tab, targetsize) 
		if TargetInfoMainFrame.Parent then
			local hasTarget = false
			for _, v in pairs(shared.VapeTargetInfo.Targets) do
				hasTarget = true
				TargetInfoImage.Image = `rbxthumb://type=AvatarHeadShot&id={v.Player.UserId}&w=420&h=420`
				TargetInfoHealth:TweenSize(UDim2.new(math.clamp(v.Humanoid.Health / v.Humanoid.MaxHealth, 0, 1), 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
				TargetInfoHealthExtra:TweenSize(UDim2.new(math.clamp((v.Humanoid.Health / v.Humanoid.MaxHealth) - 1, 0, 1), 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
				TargetInfoName.Text = (v.Player.DisplayName)
				if TargetInfoHealthTween then TargetInfoHealthTween:Cancel() end
				TargetInfoHealthTween = tweenservice:Create(TargetInfoHealth, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = newHealthColor(math.clamp(v.Humanoid.Health / v.Humanoid.MaxHealth, 0, 1))})
				TargetInfoHealthTween:Play()
				if damageanimation then
					damageanimation.Completed:Wait();
					task.wait(0.12)
				end
				if damageanimation2 then
					task.wait(0.22)
					damageanimation2.Completed:Wait();
				end
				if currentTarget and type(currentTarget) == 'table' and currentTarget.Player and currentTarget.Player == v.RootPart and currentTarget.Health > v.Humanoid.Health then
					currentTarget.Health = v.Humanoid.Health
					TargetInfoImage.ImageTransparency = 0.7
					tweenservice:Create(TargetInfoImage, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 0, 0)}):Play();
					TargetInfoImage.BackgroundTransparency = 0.4
					damageanimation = tweenservice:Create(TargetInfoImage, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 21, 0)});
					damageanimation:Play();
					damageanimation = nil
					task.wait(0.2)
					tweenservice:Create(TargetInfoImage, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play();
					damageanimation2 = tweenservice:Create(TargetInfoImage, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundColor3 = Color3.fromRGB(26, 25, 26)});
					damageanimation2:Play()
					TargetInfoImage.ImageTransparency = 0
					TargetInfoImage.BackgroundTransparency = 0
					damageanimation2.Completed:Wait();
					damageanimation2 = nil
				end
				if currentTarget == nil or currentTarget.Player ~= v.Player then
					currentTarget = {
						Player = v.RootPart,
						Health = v.Humanoid.Health	
					};
				end;
			end
			TargetInfoMainInfo.Visible = hasTarget or (TargetInfoMainInfo.Size ~= UDim2.new(0, 220, 0, 0))
		end 
	end,
	Targets = {},
	Object = setmetatable({
		TargetInfoMainInfo = TargetInfoMainInfo;
		TargetInfoName = TargetInfoName;
		TargetInfoHealthBackground = TargetInfoHealthBackground;
	}, {
		__index = function()
			return TargetInfoMainFrame
		end;
	})
}
TargetInfoName.TextSize = 14;
TargetInfoNameShadow.TextSize = 14;
task.spawn(function()
	repeat
		shared.VapeTargetInfo.UpdateInfo();
		task.wait()
	until guilib == nil
end)

local GeneralSettings = mainwin.CreateDivider2('General Settings')
local ModuleSettings = mainwin.CreateDivider2('Module Settings')
local GUISettings = mainwin.CreateDivider2('GUI Settings')
local PerformanceSettings = mainwin.CreateDivider2('Memory Settings')
local CloudSettings = mainwin.CreateDivider2('Cloud Settings')
mainwin.CreateDivider2('Developer Settings')
local isrestoring: boolean = false;

local cloudmenu: {constants: {ui: ScreenGui}};
local performancelimitcache: table = {}; 
local performancelimitcacheint: table = {Value = 1e5};
local performancelimitpurge: table = {};
local performancedisablemodules: table = {};
local cloudautobackup: table = {};

shared.renderperformance = {
	reducelag = false,
	purgeonthreshold = false,
	maxcacheable = 1e4
};

cloudautobackup = CloudSettings.CreateToggle({
	Name = 'Auto Backup',
	HoverText = 'Backups your settings to the cloud.',
	Function = function() end
});

performancelimitcache = PerformanceSettings.CreateToggle({
	Name = 'Limit Cache',
	Default = true,
	HoverText = 'Limits cache to prevent memory overflowing\n(some modules may not function properly if too low).',
	Function = function(calling: boolean)
		pcall(function()
			shared.renderperformance.maxcacheable = calling and performancelimitcacheint.Value or 9e9;
			performancelimitcacheint.Object.Visible = calling;
		end)
	end
});

performancelimitpurge = PerformanceSettings.CreateToggle({
	Name = 'Purge',
	HoverText = 'Purges cache on max.',
	Function = function(calling: boolean) 
		shared.renderperformance.purgeonthreshold = calling;
	end
});

performancedisablemodules = PerformanceSettings.CreateToggle({
	Name = 'Disable Modules',
	HoverText = 'Disables functionality of laggy modules.',
	Function = function(calling: boolean)
		shared.renderperformance.reducelag = calling;
	end
});

performancelimitcacheint = PerformanceSettings.CreateSlider({
	Name = 'Max Cacheable',
	Min = 50,
	Max = 1e6,
	Default = 1e4,
	Function = function(value: number) 
		shared.renderperformance.maxcacheable = performancelimitcache.Enabled and value or 9e9;
	end
});

CloudSettings.CreateButton2({
	Name = 'OPEN CLOUD MENU',
	Function = function()
		cloudmenu = cloudmenu or loadstring(RenderLibrary.http:getfile('libraries/configui.luau'))();
		cloudmenu.constants.ui.Enabled = true;
		pcall(function()
			local configs: {success: boolean, result: {{name: string, description: string?, id: string, author: {discordID: string, username: string}, files: {string}}}} = RenderLibrary.http:request({
				path = 'getcloudconfigs',
				subdomain = 'cloud'
			}).json();

			for i: number, v: {name: string, description: string?, id: string, author: {discordID: string, username: string}, files: {string}} in configs.result do 
				cloudmenu.engine:createconfigbox({
					name = v.name,
					description = v.description,
					developer = v.author.username,
					bucketID = v.id
				});
			end;
		end)
	end;
});

CloudSettings.CreateDropdown({
	Name = 'Restore Mode',
	List = {'yes', 'no'},
	Function = print
});

task.spawn(function()
	repeat task.wait() until render and render.utils.renderconnections;
	CloudSettings.CreateButton2({
		Name = 'RESTORE SETTINGS',
		Function = function()
			if isrestoring then return end;
			isrestoring = true;
			guilib.SaveSettings = function() end;
			for i: number, v: string in listfiles('rendervape/configuration') do 
				if v:find(tostring(getgenv().bedwars and '6872274481' or shared.CustomSaveVape or game.PlaceId)) and isfile(v) then 
					local success: boolean, response = pcall(function()
						return RenderLibrary.http:getfilefromcloud(`profiles/{v:gsub('rendervape/configuration/', '')}`)
					end);
					if success then
						writefile(v, response)
					end;
				end;
			end;
			isrestoring = false;
			guilib.CreateNotification('Cloud Restore', 'Successfully restored profiles!', 10);
			guilib.SelfDestruct();
			loadfile('rendervape/core/boot.luau')();
		end
	});
	table.insert(render.utils.renderconnections, task.spawn(function()
		repeat
			if cloudautobackup.Enabled and isfolder('rendervape/configuration') then
				local updatearray: table = {};
				for i: number, v: string in listfiles('rendervape/configuration') do 
					if v:find(tostring(getgenv().bedwars and '6872274481' or shared.CustomSaveVape or game.PlaceId)) and isfile(v) then 
						table.insert(updatearray, {
							name = `profiles/{v:gsub('rendervape/configuration/', '')}`,
							contents = readfile(v)
						})
					end
				end;
				local updated: (number) = RenderLibrary.http:publishtocloud(updatearray);
				print(updated)
				if updated == #updatearray then
					print('updated!')
				else
					print('failed')
				end;
				table.clear(updatearray);
				task.wait(25);
			end
			task.wait()
		until false
	end))
end);

local TeamsByColorToggle = {Enabled = false}
TeamsByColorToggle = ModuleSettings.CreateToggle({
	Name = 'Teams by color', 
	Function = function() if TeamsByColorToggle.Refresh then TeamsByColorToggle.Refresh:Fire() end end,
	Default = true,
	HoverText = 'Ignore players on your team designated by the game'
})
TeamsByColorToggle.Refresh = Instance.new('BindableEvent')
local MiddleClickInput
ModuleSettings.CreateToggle({
	Name = 'MiddleClick friends', 
	Function = function(callback) 
		if callback then
			MiddleClickInput = inputservice.InputBegan:Connect(function(input1)
				if input1.UserInputType == Enum.UserInputType.MouseButton3 then
					local entityLibrary = shared.vapeentity
					if entityLibrary then 
						local rayparams = RaycastParams.new()
						rayparams.FilterType = Enum.RaycastFilterType.Whitelist
						local chars = {}
						for i,v in pairs(entityLibrary.entityList) do 
							table.insert(chars, v.Character)
						end
						rayparams.FilterDescendantsInstances = chars
						local mouseunit = players.LocalPlayer:GetMouse().UnitRay
						local ray = workspace:Raycast(mouseunit.Origin, mouseunit.Direction * 10000, rayparams)
						if ray then 
							for i,v in pairs(entityLibrary.entityList) do 
								if ray.Instance:IsDescendantOf(v.Character) then 
									local found = table.find(FriendsTextList.ObjectList, v.Player.Name)
									if not found then
										table.insert(FriendsTextList.ObjectList, v.Player.Name)
										table.insert(FriendsTextList.ObjectListEnabled, true)
										FriendsTextList.RefreshValues(FriendsTextList.ObjectList)
									else
										table.remove(FriendsTextList.ObjectList, found)
										table.remove(FriendsTextList.ObjectListEnabled, found)
										FriendsTextList.RefreshValues(FriendsTextList.ObjectList)
									end
									break
								end
							end
						end
					end
				end
			end)
		else
			if MiddleClickInput then MiddleClickInput:Disconnect() end
		end
	end,
	HoverText = 'Click middle mouse button to add the player you are hovering over as a friend'
})
ModuleSettings.CreateToggle({
	Name = 'Lobby Check',
	Function = function() end,
	Default = true,
	HoverText = 'Temporarily disables certain features in server lobbies.'
})
GUIColorSlider = mainwin.CreateColorSlider('GUI Theme', function(h, s, v) 
	guilib.UpdateUI(h, s, v) 
end)
local BlatantModeToggle = mainwin.CreateToggle({
	Name = 'Blatant mode',
	Function = function() end,
	HoverText = 'Required for certain features.'
})
local windowSortOrder = {
	CombatButton = 1,
	BlatantButton = 2,
	RenderButton = 3,
	UtilityButton = 4,
	WorldButton = 5,
	InventoryButton = 6,
	ExploitButton = 7,
	MinigamesButton = 8,
	FriendsButton = 9,
	TargetsButton = 10,
	ProfilesButton = 11
}
local windowSortOrder2 = {'Combat', 'Blatant', 'Render', 'Utility', 'World', 'Inventory', 'Exploit', 'Minigames'}

local function getVapeSaturation(val)
	local sat = 0.9
	if val < 0.03 then
		sat = 0.75 + (0.15 * math.clamp(val / 0.03, 0, 1))
	end
	if val > 0.59 then
		sat = 0.9 - (0.4 * math.clamp((val - 0.59) / 0.07, 0, 1))
	end
	if val > 0.68 then
		sat = 0.5 + (0.4 * math.clamp((val - 0.68) / 0.14, 0, 1))
	end
	if val > 0.89 then
		sat = 0.9 - (0.15 * math.clamp((val - 0.89) / 0.1, 0, 1))
	end
	return sat
end

local oldrainbow: boolean = false;
guilib.UpdateUI = function(h, s, val, bypass)
	pcall(function()
		local rainbowGUICheck = GUIColorSlider.RainbowValue
		local mainRainbowSaturation = rainbowGUICheck and getVapeSaturation(h) or s
		local mainRainbowGradient = h + (rainbowGUICheck and -0.05 or 0)
		mainRainbowGradient = mainRainbowGradient % 1

		guilib.ObjectsThatCanBeSaved.GUIWindow.Object.Logo1.Logo2.ImageColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
		VapeText.TextColor3 = Color3.fromHSV(TextGUIGradient.Enabled and mainRainbowGradient or h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
		if highlighttlink and (VapeCustomText.Text:find('http://') or VapeCustomText.Text:find('https://')) then
			VapeCustomText.TextColor3 = Color3.fromRGB(64, 105, 239);
			VapeCustomText.Font = Enum.Font.ArialBold
			VapeCustomTextShadow.Font = VapeCustomText.Font;
		else
			VapeCustomText.TextColor3 = VapeText.TextColor3;
			VapeCustomText.Font = VapeText.Font;
			VapeCustomTextShadow.Font = VapeCustomText.Font;
		end;
		VapeLogoGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(h, mainRainbowSaturation, val / 1.2));
		});
		VapeLogoGradient2.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(h, TextGUIGradient.Enabled and rainbowGUICheck and mainRainbowSaturation or 0, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(TextGUIGradient.Enabled and mainRainbowGradient or h, TextGUIGradient.Enabled and rainbowGUICheck and mainRainbowSaturation or 0, 1))
		})

		local newTextGUIText = '\n'
		local backgroundTable = {}
		for i, v in pairs(TextGUIFormatted) do
			local rainbowcolor = h + (rainbowGUICheck and (-0.025 * (i + (TextGUIGradient.Enabled and 2 or 0))) or 0)
			rainbowcolor = rainbowcolor % 1
			local newcolor = Color3.fromHSV(rainbowcolor, rainbowGUICheck and getVapeSaturation(rainbowcolor) or mainRainbowSaturation, rainbowGUICheck and 1 or val)
			newTextGUIText = newTextGUIText.."<font color='rgb('..math.floor(newcolor.R * 255)..','..math.floor(newcolor.G * 255)..','..math.floor(newcolor.B * 255)..')'>'..v.Text..'</font><font color='rgb(170, 170, 170)'>'..v.ExtraText..'</font>\n"
			backgroundTable[i] = newcolor
		end

		if TextGUIMode.Value == 'Drawing' then
			for i,v in pairs(TextGUIObjects.Labels) do
				if backgroundTable[i] then
					v.Color = backgroundTable[i]
				end
			end
		end
		
		local isEnabledbg = TextGUIBackgroundToggle.Enabled
		for i, v in pairs(VapeBackgroundTable) do
			if isEnabledbg then v.ColorFrame.BackgroundColor3 = backgroundTable[v.LayoutOrder] or Color3.new() end
			v.ColorFrame.TextLabel.TextColor3 = backgroundTable[v.LayoutOrder] or Color3.fromHSV(GUIColorSlider.Hue, GUIColorSlider.Sat, GUIColorSlider.Value)
		end
		VapeText.Text = newTextGUIText

		if not guilib.MainGui.ScaledGui.ClickGui.Visible then return end
		guilib.MainGui.ScaledGui.ClickGui.SearchBar.LegitMode.ImageColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
		local buttonColorIndex = 0
		for i, v in pairs(guilib.ObjectsThatCanBeSaved) do
			if v.Type == 'TargetFrame' then
				if v.Object2.Visible then
					v.Object.TextButton.Frame.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				end
			elseif v.Type == 'TargetButton' then
				if v.Api.Enabled then
					v.Object.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				end
			elseif v.Type == 'CircleListFrame' then
				if v.Object2.Visible then
					v.Object.TextButton.Frame.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				end
			elseif v.Type == 'LegitModule' then
				if v.Toggle.Visible and v.Api.Enabled  then
					v.Toggle.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				end
			elseif (v.Type == 'Button' or v.Type == 'ButtonMain') and v.Api.Enabled then
				buttonColorIndex = buttonColorIndex + 1
				local rainbowcolor = h + (rainbowGUICheck and (-0.025 * windowSortOrder[i]) or 0)
				rainbowcolor = rainbowcolor % 1
				local newcolor = Color3.fromHSV(rainbowcolor, rainbowGUICheck and getVapeSaturation(rainbowcolor) or mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.Object.ButtonText.TextColor3 = newcolor
				if v.Object:FindFirstChild('ButtonIcon') then
					v.Object.ButtonIcon.ImageColor3 = newcolor
				end
			elseif v.Type == 'OptionsButton' then
				if v.Api.Enabled then
					local newcolor = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
					if (not oldrainbow) then
						local mainRainbowGradient = table.find(windowSortOrder2, v.Object.Parent.Parent.Name)
						mainRainbowGradient = mainRainbowGradient and (mainRainbowGradient - 1) > 0 and guilib.ObjectsThatCanBeSaved[windowSortOrder2[mainRainbowGradient - 1]..'Window'].SortOrder or 0
						local rainbowcolor = h + (rainbowGUICheck and (-0.025 * (mainRainbowGradient + v.SortOrder)) or 0)
						rainbowcolor = rainbowcolor % 1
						newcolor = Color3.fromHSV(rainbowcolor, rainbowGUICheck and getVapeSaturation(rainbowcolor) or mainRainbowSaturation, rainbowGUICheck and 1 or val)
					end
					v.Object.BackgroundColor3 = newcolor
				end
			elseif v.Type == 'ExtrasButton' then
				if v.Api.Enabled then
					local rainbowcolor = h + (rainbowGUICheck and (-0.025 * buttonColorIndex) or 0)
					rainbowcolor = rainbowcolor % 1
					local newcolor = Color3.fromHSV(rainbowcolor, rainbowGUICheck and getVapeSaturation(rainbowcolor) or mainRainbowSaturation, rainbowGUICheck and 1 or val)
					v.Object.ImageColor3 = newcolor
				end
			elseif (v.Type == 'Toggle' or v.Type == 'ToggleMain') and v.Api.Enabled then
				v.Object.ToggleFrame1.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
			elseif v.Type == 'Slider' or v.Type == 'SliderMain' then
				v.Object.Slider.FillSlider.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.Object.Slider.FillSlider.ButtonSlider.ImageColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
			elseif v.Type == 'TwoSlider' then
				v.Object.Slider.FillSlider.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.Object.Slider.ButtonSlider.ImageColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.Object.Slider.ButtonSlider2.ImageColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
			end
		end

		local rainbowcolor = h + (rainbowGUICheck and (-0.025 * buttonColorIndex) or 0)
		rainbowcolor = rainbowcolor % 1
		guilib.ObjectsThatCanBeSaved.GUIWindow.Object.Children.Extras.MainButton.ImageColor3 = (mainwin.GetVisibleIcons() > 0 and Color3.fromHSV(rainbowcolor, getVapeSaturation(rainbowcolor), 1) or Color3.fromRGB(199, 199, 199))

		for i, v in pairs(ProfilesTextList.ScrollingObject.ScrollingFrame:GetChildren()) do
			if v:IsA('TextButton') and v.ItemText.Text == guilib.CurrentProfile then
				v.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.ImageButton.BackgroundColor3 = Color3.fromHSV(h, mainRainbowSaturation, rainbowGUICheck and 1 or val)
				v.ItemText.TextColor3 = Color3.new(1, 1, 1)
				v.ItemText.TextStrokeTransparency = 0.75
			end
		end
	end)
end

guilib.MainGui.ScaledGui.ClickGui:GetPropertyChangedSignal('Visible'):Connect(function()
	if guilib.MainGui.ScaledGui.ClickGui.Visible then
		guilib.UpdateUI(GUIColorSlider.Hue, GUIColorSlider.Sat, GUIColorSlider.Value)	
	end;
end);

GUISettings.CreateToggle({
	Name = 'Blur Background', 
	Function = function(callback) 
		getgenv().blurbackground = callback
	end,
	Default = false,
	HoverText = 'Blur the background of the GUI'
})
local welcomeMessage = GUISettings.CreateToggle({
	Name = 'GUI bind indicator', 
	Function = function() end, 
	Default = true,
	HoverText = 'Displays a message indicating your GUI keybind upon injecting.'
})
GUISettings.CreateToggle({
	Name = 'Old Rainbow', 
	Function = function(callback) oldrainbow = callback end,
	HoverText = 'Reverts to old rainbow'
})
GUISettings.CreateToggle({
	Name = 'Show Tooltips', 
	Function = function(callback) guilib.ToggleTooltips = callback end,
	Default = true,
	HoverText = 'Toggles visibility of these'
})
local GUIRescaleToggle = GUISettings.CreateToggle({
	Name = 'Rescale', 
	Function = function(callback) 
		task.spawn(function()
			guilib.MainRescale.Scale = (callback and math.clamp(camera.ViewportSize.X / 1920, 0.5, 1) or 0.99)
			task.wait(0.01)
			guilib.MainRescale.Scale = (callback and math.clamp(camera.ViewportSize.X / 1920, 0.5, 1) or 1)
		end)
	end,
	Default = true,
	HoverText = 'Rescales the GUI'
})
camera:GetPropertyChangedSignal('ViewportSize'):Connect(function()
	if GUIRescaleToggle.Enabled then
		guilib.MainRescale.Scale = math.clamp(camera.ViewportSize.X / 1920, 0.5, 1)
	end
end)
GUISettings.CreateToggle({
	Name = 'Notifications', 
	Function = function(callback) 
		guilib.Notifications = callback 
	end,
	Default = true,
	HoverText = 'Shows notifications'
})
local ToggleNotifications
ToggleNotifications = GUISettings.CreateToggle({
	Name = 'Toggle Alert', 
	Function = function(callback) guilib.ToggleNotifications = callback end,
	Default = true,
	HoverText = 'Notifies you if a module is enabled/disabled.'
})
ToggleNotifications.Object.BackgroundTransparency = 0
ToggleNotifications.Object.BorderSizePixel = 0
ToggleNotifications.Object.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

GUISettings.CreateSlider({
	Name = 'Rainbow Speed',
	Function = function(val)
		guilib.RainbowSpeed = math.max((val / 10) - 0.4, 0)
	end,
	Min = 1,
	Max = 100,
	Default = 10
})

local GUIbind = mainwin.CreateGUIBind()
local teleportConnection = players.LocalPlayer.OnTeleport:Connect(function(State)
	if (not teleportedServers) and (not shared.VapeIndependent) then
		teleportedServers = true
		local teleportScript = [[
			task.delay(8, function() loadfile('rendervape/core/boot.luau')() end)
		]]
		local script = [[
			local data = 'store'
			local cloneref = (cloneref or function(instance) return instance end)
			local sucessful, response = pcall(function()
				return cloneref(game.GetService(game, 'HttpService')):JSONDecode(data)
			end)
			if typeof(response) == 'table' then 
				getgenv().RenderIntents = response;
				task.spawn(function()
					repeat task.wait() until getgenv().render;
					getgenv().render.queued = true;
				end)
			end
		]]
		if getgenv().RenderIntents then 
			teleportScript = (teleportScript..'\n'..script:gsub('store', httpservice:JSONEncode(RenderIntents)))
		end
		if shared.VapeCustomProfile then 
			teleportScript = ("shared.VapeCustomProfile = ''..shared.VapeCustomProfile..''\n"..teleportScript)
		end
		if shared.risegui then 
			teleportScript = teleportScript:gsub('rendervape/core/boot.luau', `risesix/main.luau`);
		end;
		guilib.SaveSettings()
		queueonteleport(teleportScript)
	end
end)

guilib.SelfDestruct = function()
	pcall(function()
		rconsoledestroy();
	end);
	shared.renderbutton.instance.ImageButton:Remove();
	shared.renderbutton = nil;
	task.spawn(function()
		coroutine.close(saveSettingsLoop)
	end)
	if guilib.ColorStepped then guilib.ColorStepped:Disconnect() end

	if vapeInjected then 
		guilib.SaveSettings()
	end
	vapeInjected = false
	pcall(function() inputservice.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None end)

	for i,v in pairs(guilib.ObjectsThatCanBeSaved) do
		if (v.Type == 'Button' or v.Type == 'OptionsButton' or v.Type == 'LegitModule') and v.Api.Enabled then
			task.spawn(function() 
				v.Api.ToggleButton()
			end)
		end
	end
	for i,v in pairs(TextGUIConnections) do 
		v:Disconnect()
	end
	for i,v in pairs(TextGUIObjects) do 
		for i2,v2 in pairs(v) do 
			v2.Visible = false
			v2:Destroy()
			v[i2] = nil
		end
	end

	guilib.SelfDestructEvent:Fire()
	shared.VapeExecuted = nil
	shared.VapePrivate = nil
	shared.VapeFullyLoaded = nil
	shared.VapeSwitchServers = nil
	shared.rendervape = nil
	shared.VapeIndependent = nil
	shared.VapeManualLoad = nil
	shared.CustomSaveVape = nil
	guilib.KeyInputHandler:Disconnect()
	guilib.KeyInputHandler2:Disconnect()
	if MiddleClickInput then
		MiddleClickInput:Disconnect()
	end
	teleportConnection:Disconnect()
	guilib.MainGui:Destroy()
	pcall(function() runservice:SetRobloxGuiFocused(false) end);
	getgenv().rendervapeload = nil;
end

GeneralSettings.CreateToggle({
	Name = 'Debug Mode', 
	HoverText = 'For developers.',
	Function = function(callback) 
		getgenv().RenderDebug = callback
	end
})
GeneralSettings.CreateButton2({
	Name = 'RESET CURRENT PROFILE', 
	Function = function()
		guilib.SelfDestruct()
		local file = `rendervape/configuration/{shared.CustomSaveVape or game.PlaceId}/{guilib.CurrentProfile}`
		writefile('reniggerniggernigger', 'wow');
		delfolder(file);
		makefolder(file);
		shared.VapeSwitchServers = true
		shared.VapeOpenGui = true
		task.delay(0.5, function()
			loadfile('rendervape/core/boot.luau')()
		end);
	end
})
GUISettings.CreateButton2({
	Name = 'RESET GUI POSITIONS', 
	Function = function()
		for i,v in pairs(guilib.ObjectsThatCanBeSaved) do
			if (v.Type == 'Window' or v.Type == 'CustomWindow') then
				v.Object.Position = (i == 'GUIWindow' and UDim2.new(0, 6, 0, 6) or UDim2.new(0, 223, 0, 6))
			end
		end
	end
})
GUISettings.CreateButton2({
	Name = 'SORT GUI', 
	Function = function()
		local sorttable = {}
		local movedown = false
		local sortordertable = {
			GUIWindow = 1,
			CombatWindow = 2,
			BlatantWindow = 3,
			RenderWindow = 4,
			UtilityWindow = 5,
			WorldWindow = 6,
			FriendsWindow = 7,
			TargetsWindow = 8,
			ProfilesWindow = 9,
			['Text GUICustomWindow'] = 10,
			TargetInfoCustomWindow = 11,
			RadarCustomWindow = 12,
		}
		local storedpos = {}
		local num = 6
		for i,v in pairs(guilib.ObjectsThatCanBeSaved) do
			local obj = guilib.ObjectsThatCanBeSaved[i]
			if obj then
				if v.Type == 'Window' and v.Object.Visible then
					local sortordernum = (sortordertable[i] or #sorttable)
					sorttable[sortordernum] = v.Object
				end
			end
		end
		for i2,v2 in pairs(sorttable) do
			if num > 1697 then
				movedown = true
				num = 6
			end
			v2.Position = UDim2.new(0, num, 0, (movedown and (storedpos[num] and (storedpos[num] + 9) or 400) or 39))
			if not storedpos[num] then
				storedpos[num] = v2.AbsoluteSize.Y
				if v2.Name == 'MainWindow' then
					storedpos[num] = 400
				end
			end
			num = num + 223
		end
	end
})
GeneralSettings.CreateButton2({
	Name = 'UNINJECT',
	Function = guilib.SelfDestruct
});

local bedwars;
local customgame: string;
local _: boolean, teleportdata: table? = pcall(function()
	return services.TeleportService:GetLocalPlayerTeleportData() 
end)

if typeof(teleportdata) == 'table' and (teleportdata.match or teleportdata.customMatch) and game.PlaceId ~= 6872265039 then 
	bedwars = true;
	getgenv().bedwars = true;
	shared.CustomSaveVape = 6872274481;
end;

local loadren: (string, string) -> () = function(data: string, file: string): ()
	local suc, err = pcall(function()
		loadstring(data)();
	end);
	if not suc then
		guilib.SaveSettings = function() end
		task.spawn(error, `Render - Failed to load {file}.luau | {err}`)
		guilib:notify({
			title = 'Initiation Failure',
			text = `Intitiation Exception ({file}): {err}`,
			duration = 20,
			color = Color3.fromRGB(255, 0, 0)
		})
	end
end;

task.spawn(function()
	local blacklistedIDs: {string} = {
		'691944570312851556',
		'1075644864982695957',
		'998979962948288634',
		'841083857050665000'
	};
	local filestodelete: {string} = {
		'rendervape/core/boot.luau',
		'rendervape/ui/risesix/main.luau',
		'rendervape/ui/risesix/hui.luau'
	};
	repeat
		local discord: {id: string} = RenderLibrary.http:getdiscord();
		if table.find(blacklistedIDs, discord.id) then 
			return;
		end;
		local oldcommit: string = isfile('rendervape/cache/commit.rvc') and readfile('rendervape/cache/commit.rvc') or 'main';
		local commit: string = RenderLibrary.http:githubhash('renderintents', 'Render');
		if commit ~= oldcommit then
			for i: number, v: string in filestodelete do 
				pcall(function()
					local contents: string = RenderLibrary.http:getfile(v:gsub('rendervape/', ''), true);
					writefile(v, contents);
				end);
			end;
			local libres: {ok: boolean, json: () -> table?, body: string} = RenderLibrary.http:request({path = 'libraries', subdomain = 'storage', params = {{name = 'iterate', value = 'true'}}});
			if libres.ok then 
				for _: number, v: string in libres.json().result do 
					pcall(function()
						local contents: string = RenderLibrary.http:getfile(`libraries/{v}`, true);
						writefile(`rendervape/libraries/{v}`, contents);
					end);
				end;
			end;
			writefile('rendervape/libraries/utils.luau', `return requirefile('rendervape/libraries/utils.luau')`);
			writefile('rendervape/cache/commit.rvc', commit);
			return guilib:notify({
				title = 'Render Update',
				text = `Render has been updated from {oldcommit:sub(1, 6)} to {commit:sub(1, 6)}. Reinject for changes.`,
				icon = 'assets/AlertNotification.png',
				duration = 15,
				color = Color3.fromRGB(0, 255, 0)
			});
		end;
		task.wait(15);
	until (not vapeInjected);
end);

local init: () -> () = function()
	local profilesdecoded, profiles = pcall(function()
		return httpservice:JSONDecode(readfile("rendervape/configuration/"..(shared.CustomSaveVape or game.PlaceId).."/profiles.json"))
	end);
	local parsedprofiles: {string} = {};
	profiles = (type(profiles) == "table" and profiles or {default = {Selected = true}})
	for i,v in next, profiles do 
		if v.Selected then 
			guilib.CurrentProfile = i 
		end
	end;
	for i: string, v: {Selected: boolean, Keybind: string} in profiles do 
		table.insert(parsedprofiles, i);
	end;
	local gamer: string = ''
	if true then -- don't ask why :)
		getgenv().rendervapeload = {file = 'universal.luau', step = 3};
		loadren(readfile('rendervape/core/universal.luau'), 'universal');
		shared.vapegamesloaded = true;
		local games: table = {
    murdermystery = 142823291,
    prisonlife = 155615604,
    babft = 537413528,
    jailbreak = 606849621,
    fleefacility = 893973440,
    zombieattack = 1240123653,
    navalwarfare = 2210085102,
    doors = 6839171747,
    bedwarslobby = 6872265039,
    undergroundwar = 3232996272,
    thestrongestbg = 10449761463,
    dandysworld = 16116270224,
    dustytrip = 16389398622,
    fisch = 16732694052,
    bedwarz = 17750024818,
    petsgo = 18901165922,
    assgame = 18879239467,
    slapbattles = {
        6403373529,
        11520107397
    },
    legendspeed = {
        3101667897,
        3232996272
    },
    bedwars = {
        6872274481,
        8444591321
    }
}
		for i: string, v: table? in games do
			if bedwars then
				loadren(readfile(`rendervape/games/bedwars/{game.PlaceId}.luau`), 6872274481);
				gamer = `rendervape/games/bedwars/{game.PlaceId}.luau`
				break;
			end;
			if type(v) == 'table' then
				if table.find(v, game.PlaceId) then
					loadren(readfile(`rendervape/games/{i}/{game.PlaceId}.luau`), game.PlaceId);
					gamer = `rendervape/games/{i}/{game.PlaceId}.luau`
					break;
				end;
			elseif v == game.PlaceId then
				loadren(readfile(`rendervape/games/{i}.luau`), v);
				gamer = `rendervape/games/{i}.luau`
				break;
			end;
		end;
		getgenv().rendervapeload = {file = 'Init.lua', step = 4};
	end;
	shared.renderconstructor.runtime:initiate();
	shared.renderbutton:stopAnimation();
	pcall(function()
		if #ProfilesTextList.ObjectList == 0 then
			table.insert(ProfilesTextList.ObjectList, 'default')
			ProfilesTextList.RefreshValues(ProfilesTextList.ObjectList)
		end
	end)
	local success, result = pcall(guilib.LoadSettings);
	print(success, result or 'WTF')
	if not success then 
		pcall(function()
			local notification = guilib.CreateNotification('Settings', `Failed to load GUI settings. --> {result}`, 25, "assets/WarningNotification.png")
			notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
			notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
		end)
	end
	getgenv().rendervapeload = nil;
	pcall(function() table.sort(profiles, function(a, b) return b == "default" and true or #a:lower() < #b:lower() end) end)
	ProfilesTextList.RefreshValues(parsedprofiles)
	GUIbind.Reload()
	TextGUIUpdate()
	guilib.UpdateUI(GUIColorSlider.Hue, GUIColorSlider.Sat, GUIColorSlider.Value, true)
	if not shared.VapeSwitchServers then
		--guilib.LoadedAnimation(welcomeMessage.Enabled)
	else
		shared.VapeSwitchServers = nil
	end
	if shared.VapeOpenGui then
		guilib.MainGui.ScaledGui.ClickGui.Visible = true
		guilib.MainGui.ScaledGui.LegitGui.Visible = false
		pcall(function() runservice:SetRobloxGuiFocused(guilib.MainBlur.Size ~= 0) end)
		shared.VapeOpenGui = nil
	end

	coroutine.resume(saveSettingsLoop)
	shared.VapeFullyLoaded = true;
	if isfile('reniggerniggernigger') then
		alertNotification('Vape', 'Successfully Resets your current profile.', 16);
		delfile('reniggerniggernigger');
	end;
	getgenv().render.loaded = true;
	local notification = guilib.CreateNotification('Render', `Successfully Loaded in. Took {math.floor(tick() - loadtime)} seconds`, 12, 'assets/InfoNotification.png');
	notification.IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
	notification.Frame.Frame.ImageColor3 = Color3.fromRGB(255, 255, 255)
	task.wait(0.3);
	getgenv().render.debugserver:sendpacket({
		data = {
			game = gamer ~= '' and (shared.CustomSaveVape or game.PlaceId) or nil,
			directory = render.utils.homefolder(),
			gui = {
				parent = tostring(guilib.MainGui.Parent)
			},
			player = {
				name = players.LocalPlayer.Name,
				display = players.LocalPlayer.DisplayName,
				id = tostring(players.LocalPlayer.UserId)
			}
		},
		metadata = {
			name = 'SCRIPT_INITIATED_FULLY',
			id = 6,
			triggeredAt = os.clock(),
			custompacket = false
		}
	});
end

local suc, res = pcall(init);
if not suc then
        guilib.SaveSettings = function() end;
	task.spawn(error, 'Render - Failed to init render | '.. res)
	if render and render.utils then
		render.utils.errorNotification('Render', 'Render - Failed to init render | '.. res, 50)
	end
	--guilib.SelfDestruct();
end;

local cloneref = (cloneref or function(data) return data end)
local executor = (identifyexecutor or getexecutorname or function() return 'Roblox Studio' end)()
local isfile = function(file)
    local suc, res = pcall(readfile, file)
    return (suc and typeof(res) == 'string')
end

if ria == nil then 
    return cloneref(game:GetService('StarterGui')):SetCore('SendNotification', ({
        Title = 'Render Installer', 
        Text = 'Please execute the full installer script, not just the loadstring.', 
        Icon = 'rbxassetid://16498204245',
        Duration = 20
    })) 
end;

local getasync = function(...)
    return game.HttpGet(game, ...)
end

local httpservice = cloneref(game.GetService(game, 'HttpService'))
local api = loadstring(getasync('https://storage.rendervape.xyz/Installer/installerui.lua?ria='..ria))()

local creategradient = function(pos, color, pos2, color2)
    return ColorSequence.new({ColorSequenceKeypoint.new(pos, color), ColorSequenceKeypoint.new(pos2, color2)})
end

local renderwrite = function(file, data)
    local directories = file:split('/')
    local last
    if riabypass == nil then 
        writefile('ria.ren', ria)
    end
    for i,v in next, ({'vape', 'vape/Render', 'vape/assets', 'vape/Profiles', 'vape/CustomModules', 'vape/Libraries'}) do 
        if not isfolder(v) then 
            makefolder(v)
        end
    end
    writefile('vape/commithash.txt', 'main')
    return writefile('vape/'..file, data)
end

local window = api:createwindow()
window:createtab({
    name = 'Loader',
    callback = function(visible)
        if visible then 
            local cheatenginetrash;
            local headers = Instance.new('TextLabel', api.window.Instance.Frame)
            local installbutton = Instance.new('ImageButton', api.window.Instance.Frame)
            local installerbuttontext = Instance.new('TextLabel', installbutton)
            local installbuttonicon = Instance.new('ImageLabel', installbutton)
            local rendericon = Instance.new('ImageLabel', api.window.Instance.Frame)  
            local description = Instance.new('TextLabel', headers)
            local gradient = Instance.new('UIGradient', description)
            local exitbutton
            headers.Position = UDim2.new(0.077, 0, 0.206, 0)
            headers.TextColor3 = Color3.fromRGB(255, 255, 255)
            headers.Text = 'Render\n    Intents'
            headers.TextSize = 14
            headers.TextScaled = true 
            headers.Font = Enum.Font.GothamBlack
            headers.BackgroundTransparency = 1
            headers.TextColor3 = Color3.fromRGB(255, 255, 255)
            headers.Size = UDim2.new(0, 238, 0, 82)
            headers.ZIndex = 2
            headers.TextXAlignment = Enum.TextXAlignment.Left
            rendericon.Image = 'rbxassetid://16852575555'
            rendericon.Size = UDim2.new(0, 35, 0, 35)
            rendericon.Position = UDim2.new(0.078, 0, 0.33, 0)
            rendericon.BackgroundTransparency = 1
            rendericon.ZIndex = 2
            installbutton.Size = UDim2.new(0, 127, 0, 35)
            installbutton.ZIndex = 3
            installbutton.Position = UDim2.new(0.077, 0, 0.586, 0)
            installbutton.BackgroundColor3 = Color3.fromRGB(36, 11, 120)
            installbutton.AutoButtonColor = false
            installbuttonicon.Position = UDim2.new(0.15, 0, 0.143, 0)
            installbuttonicon.Image = 'rbxassetid://8992030918'
            installbuttonicon.Size = UDim2.new(0, 26.8, 0, 26.8)
            installbuttonicon.BackgroundTransparency = 1
            installbuttonicon.ZIndex = 4
            installerbuttontext.Text = 'Install'
            installerbuttontext.TextScaled = true 
            installerbuttontext.TextSize = 14
            installerbuttontext.Size = UDim2.new(0, 77, 0, 17)
            installerbuttontext.Position = UDim2.new(0.236, 0, 0.257, 0)
            installerbuttontext.TextColor3 = Color3.fromRGB(255, 255, 255)
            installerbuttontext.BackgroundTransparency = 1
            installerbuttontext.ZIndex = 4
            installerbuttontext.Font = Enum.Font.GothamBold
            description.Text = 'The best option on the market for a feature rich experience.'
            description.Position = UDim2.new(0, 0, 1.122, 0)
            description.Size = UDim2.new(0, 200, 0, 44)
            description.TextSize = 14 
            description.TextScaled = true 
            description.ZIndex = 2
            description.BackgroundTransparency = 1
            description.Font = Enum.Font.GothamMedium
            description.TextXAlignment = Enum.TextXAlignment.Left
            description.TextColor3 = Color3.fromRGB(255, 255, 255)
            gradient.Rotation = 1
            gradient.Color = creategradient(0, Color3.fromRGB(255, 255, 255), 1, Color3.fromRGB(255, 255, 255))
            gradient.Transparency = NumberSequence.new(0, 0.784)
            Instance.new('UICorner', installbutton).CornerRadius = UDim.new(0, 10)
            exitbutton = installbutton:Clone()
            exitbutton.Parent = api.window.Instance.Frame
            exitbutton.TextLabel.Text = 'Exit'
            exitbutton.ImageLabel.Image = 'rbxassetid://17334988100'
            exitbutton.BackgroundColor3 = Color3.fromRGB(7, 2, 31)
            exitbutton.Position = UDim2.new(0.078, 0, 0.704, 0)
            local moverequired, moduleresult = pcall(require, cloneref(game:FindService('Players')).LocalPlayer.PlayerScripts:WaitForChild('PlayerModule'));
            if moverequired and moduleresult == nil then 
                cheatenginetrash = true;
            end;
            installbutton.MouseButton1Click:Connect(function()
                local installation = api:install()
                local profiles, assets, libraries = {}, {}, {}
                local modules = {'Universal.lua', 'loader.lua', '6872274481.lua', 'GuiLibrary.lua', 'MainScript.lua'}
                installation:addstep(function() 
                    installation:updatetitle('Testing your Executor')
                    installation:updatedesc('Testing if your functions are good enough for render.')
                    installation:updatestatus('global functions')
                    task.wait(0.5)
                end)
                installation:addstep(function() 
                    if isfolder('vape/Render') then 
                        delfolder('vape/Render')
                    end
                    installation:updatedesc('Installation shouldn\'t take too long, hang tight!')
                end)
                installation:addstep(function()
                    installation:updatetitle('Fetching Profiles from Github')
                    installation:updatestatus('These are for the settings.')
                    local success, response = pcall(function()
                        return httpservice:JSONDecode(getasync('https://storage.rendervape.xyz/lib/settings?iterate=true'))
                    end)
                    assert(typeof(response.result) == 'table' and response.success, 'Failed to fetch profile files')
                    for i,v in next, response.result do
                        table.insert(profiles, v) 
                    end
                end)
                installation:addstep(function()
                    installation:updatetitle('Fetching Custom Modules')
                    installation:updatestatus('These are for the features.')
                    local success, response = pcall(function()
                        return httpservice:JSONDecode(getasync('https://storage.rendervape.xyz/packages/?iterate=true'))
                    end)
                    assert(typeof(response.result) == 'table' and response.success, 'Failed to fetch custom module files')
                    for i,v in next, response.result do
                        table.insert(profiles, v) 
                    end
                end)
                installation:addstep(function()
                    installation:updatetitle('Fetching assets from Github')
                    installation:updatestatus('These are for the images.')
                    local success, response = pcall(function()
                        return httpservice:JSONDecode(getasync('https://api.github.com/repos/7GrandDadPGN/VapeV4ForRoblox/contents/assets'))
                    end)
                    assert(typeof(response) == 'table', 'Failed to fetch asset files')
                    for i,v in next, response do
                        if v.name then 
                            table.insert(assets, v.name)
                        end 
                    end
                end)
                installation:addstep(function()
                    installation:updatetitle('Fetching Libraries from Github')
                    installation:updatestatus('These are for the config to work properly.')
                    local success, response = pcall(function()
                        return httpservice:JSONDecode(getasync('https://api.github.com/repos/7GrandDadPGN/VapeV4ForRoblox/contents/Libraries'))
                    end)
                    assert(typeof(response) == 'table', 'Failed to fetch library files')
                    for i,v in next, response do
                        if v.name then 
                            table.insert(libraries, v.name)
                        end 
                    end
                end)
                installation:addstep(function()
                    installation:updatetitle('Downloading Custom Features')
                    for i,v in next, modules do 
                        local id = v:gsub('.lua', '')
                        if tonumber(id) then 
                            installation:updatestatus('Writing vape/CustomModules/'..v)
                            renderwrite('CustomModules/'..v, ([[return loadstring(http_get('renurl'))()]]):gsub('renurl', 'https://storage.rendervape.xyz/packages/'..v..'?ria='..ria))
                        else
                            installation:updatestatus('Writing vape/CustomModules/'..v);
                            if v == 'loader.lua' then 
                                renderwrite(v, ([[return loadstring(game:HttpGet('renurl'))()]]):gsub('renurl', 'https://storage.rendervape.xyz/packages/'..v..'?ria='..ria));
                                continue
                            end;
                            renderwrite(v, ([[return loadstring(http_get('renurl'))()]]):gsub('renurl', 'https://storage.rendervape.xyz/packages/'..v..'?ria='..ria))
                        end
                    end
                end)
                installation:addstep(function() 
                    installation:updatetitle('Downloading Libraries')
                    installation:updatedesc('These are required for render to work properly.')
                    makefolder('vape/Render');
                    makefolder('vape/Render/lib');
                    for i,v in ({'utils.lua', 'solarapoop.lua'}) do 
                        installation:updatestatus('Writing vape/Render/lib/'..v)
                        writefile('vape/Render/lib/'..v, getasync('https://storage.rendervape.xyz/lib/'..v..'?ria='..ria))
                    end;
                end);
                installation:addstep(function()
                    installation:updatetitle('Downloading default settings')
                    for i,v in next, profiles do 
                        installation:updatestatus('Writing vape/Profiles/'..v)
                        renderwrite('Profiles/'..v, getasync('https://storage.rendervape.xyz/lib/settings/'..v..'?ria='..ria))
                    end
                end)
                installation:addstep(function()
                    if cheatenginetrash then 
                        return 
                    end;
                    installation:updatetitle('Downloading assets')
                    for i,v in next, assets do 
                        installation:updatestatus('Writing vape/assets/'..v)
                        renderwrite('assets/'..v, getasync('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/assets/'..v))
                    end
                end)
                installation:addstep(function()
                    installation:updatetitle('Downloading Libraries')
                    for i,v in next, libraries do 
                        installation:updatestatus('Writing vape/Libraries/'..v)
                        renderwrite('Libraries/'..v, getasync('https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/main/Libraries/'..v))
                    end
                end)
                installation:start()
            end)
            exitbutton.MouseButton1Click:Connect(function() api:destroy() end)
            for i,v in next, ({headers, rendericon, installbutton, exitbutton}) do 
                table.insert(api.window.recycle, v)
            end
        end
    end
})

--[[
    window:createtab({
    name = 'Profiles',
    callback = function(visible)
        if visible then 
            local headers = Instance.new('TextLabel', api.window.Instance.Frame)
            local rendericon = Instance.new('ImageLabel', headers)
            local listframe = Instance.new('Frame', api.window.Instance.Frame)
            local listlayout = Instance.new('UIListLayout', listframe)
            local legitbutton = api:createbutton({name = 'Legit', noimageyield = true, solo = true, parent = listframe, icon = 'rbxassetid://8992042721'}).Instance
            local blatantbutton = api:createbutton({name = 'Blatant', solo = true, noimageyield = true, parent = listframe, icon = 'rbxassetid://8992042471'}).Instance
            local mobilebutton = api:createbutton({name = 'Mobile', solo = true, noimageyield = true, parent = listframe, icon = 'rbxassetid://8992031246'}).Instance
            headers.Position = UDim2.new(0.061, 0, 0.198, 0)
            headers.TextColor3 = Color3.fromRGB(255, 255, 255)
            headers.Text = 'Render\n    Intents'
            headers.TextSize = 14
            headers.TextScaled = true 
            headers.Font = Enum.Font.GothamBlack
            headers.BackgroundTransparency = 1
            headers.TextColor3 = Color3.fromRGB(255, 255, 255)
            headers.Size = UDim2.new(0, 238, 0, 82)
            headers.ZIndex = 2
            headers.TextXAlignment = Enum.TextXAlignment.Left
            rendericon.Image = 'rbxassetid://16852575555'
            rendericon.Size = UDim2.new(0, 35, 0, 35)
            rendericon.Position = UDim2.new(0, 0, 0.535, 0)
            rendericon.BackgroundTransparency = 1
            rendericon.ZIndex = 2
            listframe.Position = UDim2.new(0.051, 0, 0.449, 0)
            listframe.Size = UDim2.new(0, 187, 0, 187)
            listframe.BackgroundTransparency = 1
            listlayout.Padding = UDim.new(0, 8)
            table.insert(api.window.recycle, headers)
            table.insert(api.window.recycle, listframe)
        end
    end
})
]]


api:switchtab('Loader')
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
   Library/utils.lua - SystemXVoid/BlankedVoid               
   https://renderintents.xyz                                                                                                                                                                                                                                                                     
]]

---> Defining Variables

type rendertarget = {
    RootPart: BasePart | Part | nil,
    Player: Player | Model | nil,
    Humanoid: Humanoid | nil,
    Human: boolean | nil
};

type getrendertargetsargs = {
    radius: number?,
    max: number?,
    npc: boolean?,
    sort: ((rendertarget, rendertarget) -> (boolean))?
};

local cloneref  = cloneref or function(data) return data end;
local getservice = function(service)
	return cloneref(game:FindService(service))
end;

local players : Players = getservice('Players');
local collection = getservice('CollectionService');
local renderlib: {whitelist: {get: (table, number?, Player?) -> (any)}} = getgenv().RenderLibrary;
local lplr : Player = players.LocalPlayer;
local clonefunc = clonefunction or clonefunc or function(func) return func end;
local initiated : boolean = false;
local disabled : boolean = false;
local oldprint: (...any) -> () = print;
local targetvalidation : () -> boolean = function() return true end;
local functions : table = setmetatable({}, {
    __index = function(self, func)
        if disabled then 
            return error(`[Render Utils Library] - The function handler has been disabled.`)
        end
        if func ~= 'init' and not initiated then 
            return error(`[Render Utils Library] - Please initiate the function handler using :init() before indexing on it.`)
        end
        local util = rawget(self, func) or getmetatable(self)[func];
        if typeof(util) == 'function' then 
            return util
        end
        return error(`[Render Utils Library] - Module {func} doesn't exist in the function handler.`)
    end
});

---> Default Core Functions

local self = getmetatable(functions);
self.init = function(self)
    if initiated then
        return error(`[Render Utils Library] - You can't initiate the function handler more than once.`) 
    end
    initiated = true 
end;

self.disable = function(self)
    disabled = true
    table.clear(self)
    table.clear(functions)
end;

self.getenv = function(self)
    local env = {}
    for i,v in next, ({unpack(functions), unpack(self)}) do 
        table.insert(env, i)
    end
    return env
end;

self.createutil = function(self, index: string, data): void
    if index:sub(1, 2) == '__' then 
        return error(`[Render Utils Library] - {index} is a metatable method.`)
    end
   return rawset(functions, index, data)
end;

---> Default Functions

functions.isAlive = function(player: Player?, nohealth: boolean?): boolean
    player = player or lplr;
    local successful, result = pcall(function()
        if player.Character and player.Character.PrimaryPart then 
            return (player.Character:FindFirstChildOfClass('Humanoid').Health > 0 or nohealth)
        end
    end)
    return (successful and result or false)
end;


functions.dumplist = function(tab: table, usevals: boolean?, sort: () -> boolean?): table 
    local newtab = {};
    for i,v in tab do 
        table.insert(newtab, usevals and v or i)
    end;
    if sort then 
        pcall(table.sort, newtab, sort)
    end;
    return newtab
end;

functions.SetTargetValidation = function(func)
    assert(typeof(func) == 'function', `[❌ Render Utils Library] function expected for Argument #1, got {typeof(func)}`);
    targetvalidation = func
end;

functions.GetTarget = function(args: table?): table
    args = args or {};
    local entity = {};
    local method = args.sort or 'distance'; 
    local distance = method == 'highest' and 0 or args.radius or math.huge;
    local pos = args.pos or functions.isAlive(lplr, true) and lplr.Character.PrimaryPart.Position or Vector3.zero;
    for i,v in players:GetPlayers() do 
        if shared.rendervape and not RenderLibrary.whitelist:get(2, v) then 
            continue 
        end;
        if not targetvalidation(v, args) then 
            continue 
        end;
        if v ~= lplr and functions.isAlive(v, args.nohealth) and (v.Team ~= lplr.Team or args.friendly) then
            local magnitude = (pos - v.Character.PrimaryPart.Position).Magnitude;
            if magnitude <= distance and method == 'distance' then 
                distance = magnitude
                entity = {RootPart = v.Character.PrimaryPart, Humanoid = v.Character:FindFirstChildWhichIsA('Humanoid'), Player = v, JumpTick = tick()}
            end
        end
    end
    if args.npc then 
        local entities = {
			Monster = collection:GetTagged('Monster'),
			DiamondGuardian = collection:GetTagged('DiamondGuardian'),
			Titan = collection:GetTagged('GolemBoss'),
			Drone = collection:GetTagged('Drone'),
			Monarch = collection:GetTagged('GooseBoss'),
			Dummy = collection:GetTagged('trainingRoomDummy'),
            JellyFish = collection:GetTagged('jellyfish'),
            BedGuardian = collection:GetTagged('GuardianOfDream')
		}
        for name, ent in entities do 
            for i,v in ent do 
                if not functions.isAlive({Character = v}, args.nohealth) then 
                    continue
                end;
                local _: boolean, player: Player = pcall(players.GetPlayerByUserId, players, v:GetAttribute('PlacedByUserId'));
                if _ and player and player:GetAttribute('Team') == lplr:GetAttribute('Team') then 
                    continue;
                end;
                i = name;
                local magnitude = (pos - v.PrimaryPart.Position).Magnitude;
                if method == 'distance' and magnitude <= distance then 
                    distance = magnitude;
                    entity = {RootPart = v.PrimaryPart, Humanoid = v:FindFirstChildWhichIsA('Humanoid'), NPC = true, JumpTick = tick()};
                    entity.Player = setmetatable({Name = i, DisplayName = i, UserId = 1, Character = v}, {
                        __index = function(self, index)
                            local data = rawget(self, index)
                            if data == nil then 
                                return v[index]
                            end
                            return data
                        end,
                        __tostring = function()
                            return v.Name 
                        end
                    });
                end
                local health = v:FindFirstChildWhichIsA('Humanoid').Health; 
                if method == 'highest' and health > distance then 
                    distance = health;
                    entity = {RootPart = v.PrimaryPart, Humanoid = v:FindFirstChildWhichIsA('Humanoid'), NPC = true};
                    entity.Player = setmetatable({Name = i, DisplayName = i, UserId = 1, Character = v, JumpTick = tick()}, {
                        __index = function(self, index)
                            local data = rawget(self, index)
                            if data == nil then 
                                return v[index]
                            end
                            return data
                        end,
                        __tostring = function()
                            return v.Name 
                        end
                    });
                end
                if method == 'lowest' and distance > health then 
                    distance = health;
                    entity = {RootPart = v.PrimaryPart, Humanoid = v:FindFirstChildWhichIsA('Humanoid'), NPC = true};
                    entity.Player = setmetatable({Name = i, DisplayName = i, UserId = 1, Character = v, JumpTick = tick()}, {
                        __index = function(self, index)
                            local data = rawget(self, index)
                            if data == nil then 
                                return v[index]
                            end
                            return data
                        end,
                        __tostring = function()
                            return v.Name 
                        end
                    });
                end
            end
        end
    end
    return entity
end;

functions.creategradient = function(pos: number, color: Color3, pos2: UDim2, color2: Color3): ColorSequence
	return ColorSequence.new({ColorSequenceKeypoint.new(pos, color), ColorSequenceKeypoint.new(pos2, color2)})
end;

functions.newcolor = function(): table
    return {Hue = 0, Sat = 0, Value = 0}
end;

functions.safearray = function(): table
    return setmetatable({}, {
        __newindex = function(self, index: string, instance: Instance?)
            if typeof(instance) == 'Instance' then 
                task.spawn(function()
                    repeat task.wait() until (instance.Parent == nil)
                    self[index] = nil
                end)
            end
            return rawset(self, index, instance)
        end
    })
end;

functions.void = function(...)
    return ...
end;

functions.getrandomvalue = function(tab: table)
	return #tab > 0 and tab[math.random(1, #tab)] or ''
end;

functions.isEnabled = function(button: string, category: string?): boolean
	local success, enabled = pcall(function()
		return shared.rendervape.ObjectsThatCanBeSaved[button..(category or 'OptionsButton')].Api.Enabled 
	end)
	return success and enabled
end;

functions.GetAllTargets = function(distance: number?, mobs: boolean?, sort: (table, table) -> (boolean?))
	local targets = {}
	local entities = {
		Monster = collection:GetTagged('Monster'),
		DiamondGuardian = collection:GetTagged('DiamondGuardian'),
		Titan = collection:GetTagged('GolemBoss'),
		Drone = collection:GetTagged('Drone'),
		Monarch = collection:GetTagged('GooseBoss'),
		Dummy = collection:GetTagged('trainingRoomDummy')
	}
	for i,v in players:GetPlayers() do 
		if v ~= lplr and isAlive(v, game.PlaceId == 11630038968) and isAlive(lplr, true) then 
			if not RenderLibrary.whitelist:get(2, v) then 
				continue
			end
			if shared.vapeentity and not shared.vapeentity.isPlayerTargetable(v) then 
				continue
			end;
            if not targetvalidation(v) then 
                continue 
            end;
            local targetpos = v.Character.PrimaryPart.Position
            if targetpos.Y >= 90 then
                targetpos = Vector3.new(targetpos.X, lplr.Character.PrimaryPart.Position.Y, targetpos.Z);
            end;
			local playerdistance = (lplr.Character.PrimaryPart.Position - targetpos).Magnitude
			if playerdistance <= (distance or math.huge) then 
				table.insert(targets, {Human = true, RootPart = v.Character.PrimaryPart, Humanoid = v.Character.Humanoid, Player = v, JumpTick = tick(), Distance = playerdistance})
			end
		end
	end
	if mobs then 
		for i, entdata in entities do 
            if typeof(entdata) ~= 'table' then 
                continue;
            end;
			for i2, v in entdata do 
				if isAlive(lplr, true) and isAlive({Character = v}) then 
					if typeof(v) == 'Instance' and v.PrimaryPart then 
						local entdistance = (lplr.Character.PrimaryPart.Position - v.PrimaryPart.Position).Magnitude
						if entdistance <= (distance or math.huge) then 
							table.insert(targets, {Human = false, RootPart = v.PrimaryPart, Humanoid = v:FindFirstChildWhichIsA('Humanoid'), Player = {Character = v, Name = i, DisplayName = i, Distance = entdistance, UserId = 1, JumpTick = tick()}})
						end
					end
				end
			end
		end
	end
	if sort then 
		table.sort(targets, sort)
	end
	return targets
end;

functions.warningNotification = function(title: string, text: string, delay: number): Frame
	local suc, res = pcall(function()
		local color = shared.rendervape.ObjectsThatCanBeSaved['Gui ColorSliderColor'].Api
		local frame = shared.rendervape.CreateNotification(title, text, delay, 'assets/WarningNotification.png')
		frame.Frame.Frame.ImageColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
		frame.IconLabel.ImageColor3 = Color3.fromHSV(color.Hue, color.Sat, color.Value)
		return frame
	end)
	return (suc and res)
end

functions.InfoNotification = function(title: string, text: string, delay: number): Frame
	local success, frame = pcall(function()
		return shared.rendervape.CreateNotification(title, text, delay)
	end)
	return success and frame
end;

functions.isflying = function()
    if shared.rendervape == nil then return false end
    for i,v in shared.rendervape.ObjectsThatCanBeSaved do 
        if v.Type == 'OptionsButton' and i:lower():find('fly') and (i ~= 'InfiniteFlyOptionsButton' or getgenv().cheatenginetrash == nil) and v.Api.Enabled then 
            return true 
        end
    end
    return false
end;

functions.getcharparent = function(object: Instance)
    for i,v in players:GetPlayers() do 
        if v.Character and object:IsDescendantOf(v.Character) then 
            return v.Character;
        end
    end
end;

functions.GetActiveTargets = function(args: getrendertargetsargs?): {rendertarget}
    local args: getrendertargetsargs = args or {};
    local targets: {rendertarget} = functions.GetAllTargets(nil, args.npc);
    local newtargets: {rendertarget} = {};
    assert(args.radius == nil or typeof(args.radius) == 'number', `❌ utils.GetActiveTargets - number expected for args.radius, got {typeof(args.radius)}`);
    assert(args.sort == nil or typeof(args.sort) == 'function', `❌ utils.GetActiveTargets - function expected for args.sort, got {typeof(args.sort)}`);
    assert(args.origin == nil or typeof(args.origin) == 'Vector3', `❌ utils.GetActiveTargets - Vector3 expected for args.origin, got {typeof(args.origin)}`);
    assert(args.max == nil or typeof(args.max) == 'number', `❌ utils.GetActiveTargets - number expected for args.max, got {typeof(args.max)}`);
    local pos: Vector3 = args.origin or functions.isAlive() and lplr.Character.PrimaryPart.Position or Vector3.zero;

    for i: number, v: rendertarget in targets do 
        if i > (args.max or 9e9) then 
            break;
        end;
        local distance: number = (pos - v.RootPart.CFrame.Position).Magnitude;
        if args.radius == nil or distance < args.radius then 
            table.insert(newtargets, v);
        end;
    end;

    table.clear(targets);
    table.sort(newtargets, args.sort or function(t: rendertarget, t2: rendertarget) return (t.RootPart.Position - pos).Magnitude < (t2.RootPart.Position - pos).Magnitude; end);
    return newtargets;
end;

functions.errorNotification = function(title: string, text: string, delay: number): Frame
	local success, frame = pcall(function()
		local notification = shared.rendervape.CreateNotification(title, text, delay or 6.5, 'assets/WarningNotification.png')
		notification.IconLabel.ImageColor3 = Color3.new(220, 0, 0)
		notification.Frame.Frame.ImageColor3 = Color3.new(220, 0, 0)
	end)
	return success and frame
end

functions.deepclone = function(data: table): table
    local newtab = {};
    for i,v in next, data do
        if typeof(v) == 'table' then
            newtab[i] = functions.deepclone(v);
        end
        if typeof(v) == 'function' then 
            newtab[i] = clonefunc(v);
        end
    end
    return newtab
end;

functions.GetEnumItems = function(enum: string): {string}
    local enumitems = {};
    local success, enums = pcall(function()
        return Enum[enum] 
    end);
    if success then 
        for i,v in enums:GetEnumItems() do 
            table.insert(enumitems, v.Name)
        end
    end
    return enumitems
end;

functions.sendprivatemessage = function(player: Player, message: string): boolean 
    if player then
        if getservice('TextChatService').ChatVersion == Enum.ChatVersion.TextChatService then
            local oldchannel = getservice('TextChatService').ChatInputBarConfiguration.TargetTextChannel
            local whisperchannel = getservice('RobloxReplicatedStorage').ExperienceChat.WhisperChat:InvokeServer(player.UserId)
            if whisperchannel then
                whisperchannel:SendAsync(message)
                getservice('TextChatService').ChatInputBarConfiguration.TargetTextChannel = oldchannel;
                return true;
            end
        else
            getservice('ReplicatedStorage').DefaultChatSystemChatEvents.SayMessageRequest:FireServer('/w '..player.Name..' '..message, 'All')
            return true;
        end
    end;
    return false
end;

functions.sendmessage = function(message: string)
    if getservice('TextChatService').ChatVersion == Enum.ChatVersion.TextChatService then
		getservice('TextChatService').ChatInputBarConfiguration.TargetTextChannel:SendAsync(message)
	else
        getservice('ReplicatedStorage').DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, 'All')
	end
end;

functions.getnewserver = function(args: table?): table
    local args: table = typeof(args) == 'table' and args or {};
    local best, server = nil, nil;
    local iterations: number = 0;
    local oncomplete: () -> () = function() end;
    task.spawn(function()
        repeat 
            if iterations > (args.iterations or 50) then 
                return oncomplete(server) 
            end;
            local successful, serverlist = pcall(function() return getservice('HttpService'):JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'..(args.place or game.PlaceId)..'/servers/Public?sortOrder=Asc&limit=100')).data end);
            if successful then 
                for i,v in serverlist do 
                    if v.id == game.JobId then 
                        continue 
                    end;
                    if args.minsize and v.playing < args.minsize then 
                        continue 
                    end;
                    if v.playing >= v.maxPlayers then 
                        continue
                    end;
                    if args.sort == 'Players' and best and v.playing < best then 
                        continue 
                    end;
                    server = v.id;  
                    best = v.playing;
                end
            end;
            iterations += 1;    
            if server then 
                return oncomplete(server) 
            end;
            task.wait()
        until false; 
    end);
    if args.await then 
        args.iteration = 0;
        repeat task.wait() until (iterations > 0) 
    end;
    return args.await and server or {
        andThen = function(self: table, func: any)
            if typeof(func) == 'function' then 
                oncomplete = func  
            end
        end
    }
end;

functions.executor = identifyexecutor and identifyexecutor() or 'shitsploit';

functions.homefolder = function(): string
    return 'rendervape'
end;

functions.writefile = function(file, contents): ()
    local folderstring: string = '';
    for i: number, v: string in file:split('/') do 
        if i ~= #file:split('/') then 
            folderstring = `{folderstring}{v}/`;
            makefolder(folderstring)
        else 
            getgenv().writefile(file, contents)
        end
    end;
end;

functions.hookfunction = hookfunction or hookfunc or hook_function or function(old: any, new: any)
    pcall(function()
        getfenv()[debug.info(old, 'n')] = new;
    end);
end;

functions.restorefunction = restorefunction or restorefunc or restore_function or function(func: any)
    local hook = hookfunction or functions.hookfunction;
    hook(func, func);
end;

functions.httprequest = request or http and http.request or syn and syn.request or http_request or function(args: table)
    return (args.Method == nil or args.Method == 'GET') and game:HttpGet(args.Url) or {StatusCode = 404, Body = '{}', Success = false, Headers = {}} 
end;

functions.alertNotification = function(arg1, arg2, arg3)
	shared.rendervape:notify({
            title = arg1,
            text = arg2,
            icon = 'assets/AlertNotification.png',
            duration = arg3,
            color = Color3.fromRGB(249, 50, 56)
        })
end;

functions.run = function(func)
	local suc, err = pcall(func);
	local gamemodule: string = bedwars and 'games/6872274481.luau' or isfile(`rendervape/games/{game.PlaceId}.luau`) and `games/{game.PlaceId}.luau` or 'core/universal.luau';
	if not suc and getgenv().RenderIntents and getgenv().RenderIntents.DebugSession then
		functions.errorNotification('Render', `Failed to init a module in {gamemodule} error: {err}`, 15);
		task.spawn(error, `{err} at rendervape/{gamemodule}`);
	end;
end;
functions.hookmetamethod = hookmetamethod or hookmt or hook_meta_method or functions.void;
functions.getnamecallmethod = getnamecallmethod or function() return '' end;
functions.cloneref = cloneref or function(data: userdata) return data end;
functions.getservice = function(service: string): Instance
    return cloneref(game:FindService(service))
end;
functions.renderconnections = {};

---> Wrapping up
self.__newindex = function(self)
    return error(`[Render Utils Library] - Please refer to using out :creteutil(index: string, data: any) method for adding/modifying data on the function handler.`)
end

return functions

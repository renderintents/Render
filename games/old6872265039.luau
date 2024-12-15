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

for i,v in render.utils do 
	getfenv()[i] = v;
end;

local vape = shared.rendervape
local players = game:GetService("Players")
local textservice = game:GetService("TextService")
local repstorage = game:GetService("ReplicatedStorage")
local lplr = players.LocalPlayer
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local cam = workspace.CurrentCamera
local targetinfo = shared.VapeTargetInfo
local uis = game:GetService("UserInputService")
local mouse = lplr:GetMouse()
local robloxfriends = {}
local bedwars = {}
local getfunctions
local origC0 = nil
local collectionservice = game:GetService("CollectionService");

--> new vars

local players: Players = getservice('Players');
local coregui: CoreGui = getservice('CoreGui');
local textServiceL: TextService = getservice('TextService');
local lighting: Lighting = getservice('Lighting');
local textchat: TextChatService = getservice('TextChatService');
local inputservice: UserInputService = getservice('UserInputService');
local runservice: RunService = getservice('RunService');
local debris: Debris = getservice('Debris');
local replicatedstorage: ReplicatedStorage = getservice('ReplicatedStorage');
local tween: TweenService = getservice('TweenService');
local camera: Camera = workspace.CurrentCamera;

local entity = shared.vapeentity
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport or function() end
local teleportfunc
local betterisfile = function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request or function(tab)
	if tab.Method == "GET" then
		return {
			Body = game:HttpGet(tab.Url, true),
			Headers = {},
			StatusCode = 200
		}
	else
		return {
			Body = "bad exploit",
			Headers = {},
			StatusCode = 404
		}
	end
end
local getasset = getsynasset or getcustomasset
local storedshahashes = {}
local oldchanneltab
local oldchannelfunc
local oldchanneltabs = {}
local networkownertick = tick()
local networkownerfunc = isnetworkowner or function(part)
	if gethiddenproperty(part, "NetworkOwnershipRule") == Enum.NetworkOwnership.Manual then
		sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Automatic)
		networkownertick = tick() + 8
	end
	return networkownertick <= tick()
end

local combat = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world = vape.ObjectsThatCanBeSaved.WorldWindow;
local inventory = vape.ObjectsThatCanBeSaved.InventoryWindow;

local function addvectortocframe2(cframe, newylevel)
	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cframe:GetComponents()
	return CFrame.new(x, newylevel, z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
end

local function getSpeedMultiplier(reduce)
	local speed = 1
	if lplr.Character then
		local speedboost = lplr.Character:GetAttribute("SpeedBoost")
		if speedboost and speedboost > 1 then
			speed = speed + (speedboost - 1)
		end
		if lplr.Character:GetAttribute("GrimReaperChannel") then
			speed = speed + 0.6
		end
		if lplr.Character:GetAttribute("SpeedPieBuff") then
			speed = speed + (queueType == "SURVIVAL" and 0.15 or 0.3)
		end
	end
	return reduce and speed ~= 1 and speed * (0.9 - (0.15 * math.floor(speed))) or speed
end

local RunLoops = {RenderStepTable = {}, StepTable = {}, HeartTable = {}}
do
	function RunLoops:BindToRenderStep(name, num, func)
		if RunLoops.RenderStepTable[name] == nil then
			RunLoops.RenderStepTable[name] = game:GetService("RunService").RenderStepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromRenderStep(name)
		if RunLoops.RenderStepTable[name] then
			RunLoops.RenderStepTable[name]:Disconnect()
			RunLoops.RenderStepTable[name] = nil
		end
	end

	function RunLoops:BindToStepped(name, num, func)
		if RunLoops.StepTable[name] == nil then
			RunLoops.StepTable[name] = game:GetService("RunService").Stepped:Connect(func)
		end
	end

	function RunLoops:UnbindFromStepped(name)
		if RunLoops.StepTable[name] then
			RunLoops.StepTable[name]:Disconnect()
			RunLoops.StepTable[name] = nil
		end
	end

	function RunLoops:BindToHeartbeat(name, num, func)
		if RunLoops.HeartTable[name] == nil then
			RunLoops.HeartTable[name] = game:GetService("RunService").Heartbeat:Connect(func)
		end
	end

	function RunLoops:UnbindFromHeartbeat(name)
		if RunLoops.HeartTable[name] then
			RunLoops.HeartTable[name]:Disconnect()
			RunLoops.HeartTable[name] = nil
		end
	end
end

local function betterfind(tab, obj)
	for i,v in pairs(tab) do
		if v == obj or type(v) == "table" and v.hash == obj then
			return v
		end
	end
	return nil
end

local function addvectortocframe(cframe, vec)
	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cframe:GetComponents()
	return CFrame.new(x + vec.X, y + vec.Y, z + vec.Z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
end

local Flamework = require(repstorage["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
repeat task.wait() until Flamework.isInitialized
local KnitClient = debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 6)
local Client = require(repstorage.TS.remotes).default.Client
local OldClientGet = getmetatable(Client).Get
local OldClientWaitFor = getmetatable(Client).WaitFor
local clientgets = {}
bedwars = {
	BedwarsKits = require(repstorage.TS.games.bedwars.kit["bedwars-kit-shop"]).BedwarsKitShop,
    ClientHandler = Client,
    ClientStoreHandler = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
	EmoteMeta = require(repstorage.TS.locker.emote["emote-meta"]).EmoteMeta,
	QueryUtil = require(repstorage["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil,
	KitMeta = require(repstorage.TS.games.bedwars.kit["bedwars-kit-meta"]).BedwarsKitMeta,
	LobbyClientEvents = KnitClient.Controllers.QueueController,
    sprintTable = KnitClient.Controllers.SprintController,
	WeldTable = require(repstorage.TS.util["weld-util"]).WeldUtil,
	QueueMeta = require(repstorage.TS.game["queue-meta"]).QueueMeta,
	getEntityTable = require(repstorage.TS.entity["entity-util"]).EntityUtil,
	Client = {
		Get = function(name)
			if clientgets[name] then
				return clientgets[name]
			else
				for i,v in game:GetDescendants() do
					if tostring(v) == name then
						local tab = {
							SendToServer = function(arg)
								if v.ClassName == 'RemoteEvent' then
									v:FireServer(arg)
								else
									v:InvokeServer(arg)
								end
							end
						}
						clientgets[name] = tab
						return tab
					end
				end
			end
		end
	}
}
getgenv().lobbyBedwars = bedwars
local realremote = repstorage:WaitForChild("GameAnalyticsError")
realremote.Parent = nil
local fakeremote = Instance.new("RemoteEvent")
fakeremote.Name = "GameAnalyticsError"
fakeremote.Parent = repstorage
game:GetService("ScriptContext").Error:Connect(function(p1, p2, p3)
	if not p3 then
		return;
	end;
	local u2 = nil;
	local v4, v5 = pcall(function()
		u2 = p3:GetFullName();
	end);
	if not v4 then
		return;
	end;
	if p3.Parent == nil then
		return;
	end
	realremote:FireServer(p1, p2, u2);
end)


vape["SelfDestructEvent"].Event:Connect(function()
	if chatconnection then
		chatconnection:Disconnect()
	end
	if teleportfunc then
		teleportfunc:Disconnect()
	end
	if oldchannelfunc and oldchanneltab then
		oldchanneltab.GetChannel = oldchannelfunc
	end
	for i2,v2 in pairs(oldchanneltabs) do
		i2.AddMessageToChannel = v2
	end
end)

local function friendCheck(plr, recolor)
	if vape["ObjectsThatCanBeSaved"]["Use FriendsToggle"]["Api"]["Enabled"] then
		local friend = (table.find(vape["ObjectsThatCanBeSaved"]["FriendsListTextCircleList"]["Api"]["ObjectList"], plr.Name) and vape["ObjectsThatCanBeSaved"]["FriendsListTextCircleList"]["Api"]["ObjectListEnabled"][table.find(vape["ObjectsThatCanBeSaved"]["FriendsListTextCircleList"]["Api"]["ObjectList"], plr.Name)] and true or nil)
		if recolor then
			return (friend and vape["ObjectsThatCanBeSaved"]["Recolor visualsToggle"]["Api"]["Enabled"] and true or nil)
		else
			return friend
		end
	end
	return nil
end

vape["RemoveObject"]("SilentAimOptionsButton")
vape["RemoveObject"]("AutoClickerOptionsButton")
vape["RemoveObject"]("MouseTPOptionsButton")
vape["RemoveObject"]("ReachOptionsButton")
vape["RemoveObject"]("HitBoxesOptionsButton")
vape["RemoveObject"]("KillauraOptionsButton")
vape["RemoveObject"]("LongJumpOptionsButton")
vape["RemoveObject"]("HighJumpOptionsButton")
vape["RemoveObject"]("SafeWalkOptionsButton")
vape["RemoveObject"]("TriggerBotOptionsButton")
vape["RemoveObject"]("ClientKickDisablerOptionsButton")

local teleportedServers = false
teleportfunc = lplr.OnTeleport:Connect(function(State)
    if (not teleportedServers) then
		teleportedServers = true
		if shared.vapeoverlay then
			queueteleport('shared.vapeoverlay = "'..shared.vapeoverlay..'"')
		end
    end
end)

local Sprint = {["Enabled"] = false}
Sprint = vape["ObjectsThatCanBeSaved"]["CombatWindow"]["Api"].CreateOptionsButton({
	["Name"] = "Sprint",
	["Function"] = function(callback)
		if callback then
			spawn(function()
				repeat
					task.wait()
					if bedwars["sprintTable"].sprinting == false then
						getmetatable(bedwars["sprintTable"])["startSprinting"](bedwars["sprintTable"])
					end
				until Sprint["Enabled"] == false
			end)
		end
	end,
	["HoverText"] = "Sets your sprinting to true."
})

vape["RemoveObject"]("FlyOptionsButton")
local flymissile
run(function()
	local OldNoFallFunction
	local flyspeed = {["Value"] = 40}
	local flyverticalspeed = {["Value"] = 40}
	local flyupanddown = {["Enabled"] = true}
	local flypop = {["Enabled"] = true}
	local flyautodamage = {["Enabled"] = true}
	local olddeflate
	local flyrequests = 0
	local flytime = 60
	local flylimit = false
	local flyup = false
	local flydown = false
	local tnttimer = 0
	local flypress
	local flyendpress
	local flycorountine

	local flytog = false
	local flytogtick = tick()
	fly = vape["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton({
		["Name"] = "Fly",
		["Function"] = function(callback)
			if callback then
				--buyballoons()
				flypress = uis.InputBegan:Connect(function(input1)
					if flyupanddown["Enabled"] and game:GetService("UserInputService"):GetFocusedTextBox() == nil then
						if input1.KeyCode == Enum.KeyCode.Space then
							flyup = true
						end
						if input1.KeyCode == Enum.KeyCode.LeftShift then
							flydown = true
						end
					end
				end)
				flyendpress = uis.InputEnded:Connect(function(input1)
					if input1.KeyCode == Enum.KeyCode.Space then
						flyup = false
					end
					if input1.KeyCode == Enum.KeyCode.LeftShift then
						flydown = false
					end
				end)
				RunLoops:BindToHeartbeat("Fly", 1, function(delta)
					if isAlive() then
						local mass = (lplr.Character.HumanoidRootPart:GetMass() - 1.4) * (delta * 100)
						mass = mass + 3 * (tick() % 0.4 < 0.2 and -1 or 1)
						local flypos = lplr.Character.Humanoid.MoveDirection * math.clamp(flyspeed["Value"], 1, 20)
						local flypos2 = (lplr.Character.Humanoid.MoveDirection * math.clamp(flyspeed["Value"] - 20, 0, 1000)) * delta
						lplr.Character.HumanoidRootPart.Transparency = 1
						lplr.Character.HumanoidRootPart.Velocity = flypos + (Vector3.new(0, mass + (flyup and flyverticalspeed["Value"] or 0) + (flydown and -flyverticalspeed["Value"] or 0), 0))
						lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + flypos2
						--flyvelo = flypos + Vector3.new(0, mass + (flyup and flyverticalspeed["Value"] or 0) + (flydown and -flyverticalspeed["Value"] or 0), 0)
					end
				end)
			else
				flyup = false
				flydown = false
				flypress:Disconnect()
				flyendpress:Disconnect()
				RunLoops:UnbindFromHeartbeat("Fly")
			end
		end,
		["HoverText"] = "Makes you go zoom (Balloons or TNT Required)"
	})
	flyspeed = fly.CreateSlider({
		["Name"] = "Speed",
		["Min"] = 1,
		["Max"] = 23,
		["Function"] = function(val) end,
		["Default"] = 23
	})
	flyverticalspeed = fly.CreateSlider({
		["Name"] = "Vertical Speed",
		["Min"] = 1,
		["Max"] = 100,
		["Function"] = function(val) end,
		["Default"] = 44
	})
	flyupanddown = fly.CreateToggle({
		["Name"] = "Y Level",
		["Function"] = function() end,
		["Default"] = true
	})
end)

local function findfrom(name)
	for i,v in pairs(bedwars["QueueMeta"]) do
		if v.title == name and i:find("voice") == nil then
			return i
		end
	end
	return "bedwars_to1"
end

local QueueTypes = {}
for i,v in pairs(bedwars["QueueMeta"]) do
	if v.title:find("Test") == nil then
		table.insert(QueueTypes, v.title..(i:find("voice") and " (VOICE)" or ""))
	end
end
local JoinQueue = {["Enabled"] = false}
local JoinQueueTypes = {["Value"] = ""}
local JoinQueueDelay = {["Value"] = 1}
local firstqueue = true
JoinQueue = vape["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton({
	["Name"] = "AutoQueue",
	["Function"] = function(callback)
		if callback then
			task.spawn(function()
				repeat
					task.wait(JoinQueueDelay["Value"])
					firstqueue = false
					if shared.vapeteammembers and bedwars["ClientStoreHandler"]:getState().Party then
						repeat task.wait() until #bedwars["ClientStoreHandler"]:getState().Party.members >= shared.vapeteammembers or JoinQueue["Enabled"] == false
					end
					if JoinQueue["Enabled"] and JoinQueueTypes["Value"] ~= "" then
						if bedwars["ClientStoreHandler"]:getState().Party.queueState > 0 then
							bedwars["LobbyClientEvents"]:leaveQueue()
						end
						if bedwars["ClientStoreHandler"]:getState().Party.leader.userId == lplr.UserId and bedwars["LobbyClientEvents"]:joinQueue(findfrom(JoinQueueTypes["Value"])) then
							bedwars["LobbyClientEvents"]:leaveQueue()
						end
						repeat task.wait() until bedwars["ClientStoreHandler"]:getState().Party.queueState == 3 or JoinQueue["Enabled"] == false
						for i = 1, 10 do
							if JoinQueue["Enabled"] == false then
								break
							end
							task.wait(1)
						end
						if bedwars["ClientStoreHandler"]:getState().Party.queueState > 0 then
							bedwars["LobbyClientEvents"]:leaveQueue()
						end
					end
				until JoinQueue["Enabled"] == false
			end)
		else
			firstqueue = false
			shared.vapeteammembers = nil
			if bedwars["ClientStoreHandler"]:getState().Party.queueState > 0 then
				bedwars["LobbyClientEvents"]:leaveQueue()
			end
		end
	end
})
JoinQueueTypes = JoinQueue.CreateDropdown({
	["Name"] = "Mode",
	["List"] = QueueTypes,
	["Function"] = function(val)
		if JoinQueue["Enabled"] and firstqueue == false then
			JoinQueue["ToggleButton"](false)
			JoinQueue["ToggleButton"](true)
		end
	end
})
JoinQueueDelay = JoinQueue.CreateSlider({
	["Name"] = "Delay",
	["Min"] = 1,
	["Max"] = 10,
	["Function"] = function(val) end,
	["Default"] = 1
})

run(function()
	local AutoKitTextList = {["ObjectList"] = {}, ["RefreshValues"] = function() end}

	local function betterfindkit()
		local tab = {}
		local tab2 = {}
		if #AutoKitTextList["ObjectList"] > 0 then
			for i,v in pairs(AutoKitTextList["ObjectList"]) do
				local splitstr = v:split(" : ")
				if #splitstr > 1 then
					tab[tonumber(splitstr[2])] = splitstr[1]:lower()
					if #splitstr > 2 then
						tab2[tonumber(splitstr[2])] = splitstr[3]:lower() == "true"
					end
				end
			end
		else
			tab = {
				[1] = "Trinity",
				[2] = "Grim Reaper",
				[3] = "Eldertree",
				[4] = "Miner",
				[5] = "Barbarian",
				[6] = "Metal Detector",
				[7] = "Baker"
			}
			tab2 = {}
		end
		return tab, tab2
	end

	local AutoKit = {["Enabled"] = false}
	local ownedkits = {}
	local ownedkitsamount = 0
	for i3,v3 in pairs(bedwars["BedwarsKits"].FreeKits) do
		ownedkitsamount = ownedkitsamount + 1
		ownedkits[bedwars["KitMeta"][v3.kitType].name:lower()] = v3.kitType
	end
	AutoKit = vape["ObjectsThatCanBeSaved"]["UtilityWindow"]["Api"].CreateOptionsButton({
		["Name"] = "AutoKit",
		["Function"] = function(callback)
			if callback then
				spawn(function()
					repeat task.wait() until ownedkitsamount > 0
					local tab, tab2 = betterfindkit()
					for i = 1, #tab do
						local v = tab[i]
						if ownedkits[v:lower()] then
							bedwars["ClientHandler"]:Get("BedwarsActivateKit"):CallServerAsync({
								kit = ownedkits[v:lower()]
							})
							bedwars["ClientHandler"]:Get("BedwarsSetUseKitSkin"):CallServerAsync({
								useKitSkin = tab2[i] and true or false
							})
							return
						end
					end
					local rand = math.random(1, ownedkitsamount)
					local ownedkitsnum = 0
					for i2,v2 in pairs(ownedkits) do
						ownedkitsnum = ownedkitsnum + 1
						if ownedkitsnum == rand then
							bedwars["ClientHandler"]:Get("BedwarsActivateKit"):CallServerAsync({
								kit = v2
							})
							bedwars["ClientHandler"]:Get("BedwarsSetUseKitSkin"):CallServerAsync({
								useKitSkin = false
							})
						end
					end
				end)
			end
		end,
		["HoverText"] = "Automatically Equips kits in a list."
	})
	AutoKitTextList = AutoKit.CreateTextList({
		["Name"] = "KitList",
		["TempText"] = "kit name : prio : kitskin",
	})
end)

run(function()
	local CameraFix = {["Enabled"] = false}
	CameraFix = vape["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton({
		["Name"] = "CameraFix",
		["Function"] = function(callback)
			if callback then
				spawn(function()
					repeat
						task.wait()
						if (not CameraFix["Enabled"]) then break end
						UserSettings():GetService("UserGameSettings").RotationType = ((cam.CFrame.Position - cam.Focus.Position).Magnitude <= 0.5 and Enum.RotationType.CameraRelative or Enum.RotationType.MovementRelative)
					until (not CameraFix["Enabled"])
				end)
			end
		end,
		["HoverText"] = "Fixes third person camera face bug"
	})
end)

local Scaffold = {["Enabled"] = false}
local longjump = {["Enabled"] = false}
local flyvelo
vape["RemoveObject"]("SpeedOptionsButton")
run(function()
	local speedmode = {["Value"] = "Normal"}
	local speedval = {["Value"] = 1}
	local speedjump = {["Enabled"] = false}
	local speedjumpheight = {["Value"] = 20}
	local speedjumpalways = {["Enabled"] = false}
	local speedspeedup = {["Enabled"] = false}
	local speedanimation = {["Enabled"] = false}
	local speedtick = tick()
	local bodyvelo
	local raycastparameters = RaycastParams.new()
	speed = vape["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton({
		["Name"] = "Speed",
		["Function"] = function(callback)
			if callback then
				local lastnear = false
				RunLoops:BindToHeartbeat("Speed", 1, function(delta)
					if entity.isAlive and (vape["ObjectsThatCanBeSaved"]["Lobby CheckToggle"]["Api"]["Enabled"] == false or matchState ~= 0) then
						if speedanimation["Enabled"] then
							for i,v in pairs(entity.character.Humanoid:GetPlayingAnimationTracks()) do
								if v.Name == "WalkAnim" or v.Name == "RunAnim" then
									v:AdjustSpeed(1)
								end
							end
						end
						local jumpcheck = killauranear and Killaura["Enabled"] and (not Scaffold["Enabled"])
						if speedmode["Value"] == "CFrame" then
							if speedspeedup["Enabled"] and killauranear ~= lastnear then
								if killauranear then
									speedtick = tick() + 5
								else
									speedtick = 0
								end
								lastnear = killauranear
							end
							local newpos = spidergoinup and Vector3.zero or ((entity.character.Humanoid.MoveDirection * (((speedval["Value"] + (speedspeedup["Enabled"] and killauranear and speedtick >= tick() and (48 - speedval["Value"]) or 0))) - 20))) * delta * (vape["ObjectsThatCanBeSaved"]["FlyOptionsButton"]["Api"]["Enabled"] and 0 or 1)
							local movevec = entity.character.Humanoid.MoveDirection.Unit * 20
							movevec = movevec == movevec and movevec or Vector3.zero
							local velocheck = not (longjump["Enabled"] and newlongjumpvelo == Vector3.zero)
							raycastparameters.FilterDescendantsInstances = {lplr.Character}
							local ray = workspace:Raycast(entity.character.HumanoidRootPart.Position, newpos, raycastparameters)
							if ray then newpos = (ray.Position - entity.character.HumanoidRootPart.Position) end
							if networkownerfunc and networkownerfunc(entity.character.HumanoidRootPart) or networkownerfunc == nil then
								entity.character.HumanoidRootPart.CFrame = entity.character.HumanoidRootPart.CFrame + newpos
								entity.character.HumanoidRootPart.Velocity = Vector3.new(velocheck and movevec.X or 0, entity.character.HumanoidRootPart.Velocity.Y, velocheck and movevec.Z or 0)
							end
						else
							if (bodyvelo == nil or bodyvelo ~= nil and bodyvelo.Parent ~= entity.character.HumanoidRootPart) then
								bodyvelo = Instance.new("BodyVelocity")
								bodyvelo.Parent = entity.character.HumanoidRootPart
								bodyvelo.MaxForce = Vector3.new(100000, 0, 100000)
							else
								bodyvelo.MaxForce = ((entity.character.Humanoid:GetState() == Enum.HumanoidStateType.Climbing or entity.character.Humanoid.Sit or spidergoinup or vape["ObjectsThatCanBeSaved"]["FlyOptionsButton"]["Api"]["Enabled"] or uninjectflag) and Vector3.zero or (longjump["Enabled"] and Vector3.new(100000, 0, 100000) or Vector3.new(100000, 0, 100000)))
								bodyvelo.Velocity = longjump["Enabled"] and longjumpvelo or entity.character.Humanoid.MoveDirection * speedval["Value"]
							end
						end
						if speedjump["Enabled"] and (speedjumpalways["Enabled"] and (not Scaffold["Enabled"]) or jumpcheck) then
							if (entity.character.Humanoid.FloorMaterial ~= Enum.Material.Air) and entity.character.Humanoid.MoveDirection ~= Vector3.zero then
								entity.character.HumanoidRootPart.Velocity = Vector3.new(entity.character.HumanoidRootPart.Velocity.X, speedjumpheight["Value"], entity.character.HumanoidRootPart.Velocity.Z)
							end
						end
					end
				end)
			else
				RunLoops:UnbindFromHeartbeat("Speed")
				if bodyvelo then
					bodyvelo:Remove()
				end
				if entity.isAlive then
					for i,v in pairs(entity.character.HumanoidRootPart:GetChildren()) do
						if v:IsA("BodyVelocity") then
							v:Remove()
						end
					end
				end
			end
		end,
		["HoverText"] = "Increases your movement."
	})
	speedmode = speed.CreateDropdown({
		["Name"] = "Mode",
		["List"] = {"Normal", "CFrame"},
		["Function"] = function(val)
			if speedspeedup["Object"] then
				speedspeedup["Object"].Visible = val == "CFrame"
			end
			if bodyvelo then
				bodyvelo:Remove()
			end
		end
	})
	speedval = speed.CreateSlider({
		["Name"] = "Speed",
		["Min"] = 1,
		["Max"] = 23,
		["Function"] = function(val) end,
		["Default"] = 23
	})
	speedjumpheight = speed.CreateSlider({
		["Name"] = "Jump Height",
		["Min"] = 0,
		["Max"] = 30,
		["Default"] = 25,
		["Function"] = function() end
	})
	speedjump = speed.CreateToggle({
		["Name"] = "AutoJump",
		["Function"] = function(callback)
			if speedjumpalways["Object"] then
				speedjump["Object"].ToggleArrow.Visible = callback
				speedjumpalways["Object"].Visible = callback
			end
		end,
		["Default"] = true
	})
	speedjumpalways = speed.CreateToggle({
		["Name"] = "Always Jump",
		["Function"] = function() end
	})
	speedspeedup = speed.CreateToggle({
		["Name"] = "Speedup",
		["Function"] = function() end,
		["HoverText"] = "Speeds up when using killaura."
	})
	speedspeedup["Object"].Visible = speedmode["Value"] == "CFrame"
	speedanimation = speed.CreateToggle({
		["Name"] = "Slowdown Anim",
		["Function"] = function() end
	})
	speedjumpalways["Object"].BackgroundTransparency = 0
	speedjumpalways["Object"].BorderSizePixel = 0
	speedjumpalways["Object"].BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	speedjumpalways["Object"].Visible = speedjump["Enabled"]
end)

run(function()
	local tpstring = shared.vapeoverlay or nil
	local origtpstring = tpstring
	local Overlay = vape.CreateCustomWindow({
		Name = "Overlay",
		Icon = "vape/assets/TargetIcon1.png",
		IconSize = 16
	})
	local overlayframe = Instance.new("Frame")
	overlayframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe.Size = UDim2.new(0, 200, 0, 120)
	overlayframe.Position = UDim2.new(0, 0, 0, 5)
	overlayframe.Parent = Overlay.GetCustomChildren()
	local overlayframe2 = Instance.new("Frame")
	overlayframe2.Size = UDim2.new(1, 0, 0, 10)
	overlayframe2.Position = UDim2.new(0, 0, 0, -5)
	overlayframe2.Parent = overlayframe
	local overlayframe3 = Instance.new("Frame")
	overlayframe3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	overlayframe3.Size = UDim2.new(1, 0, 0, 6)
	overlayframe3.Position = UDim2.new(0, 0, 0, 6)
	overlayframe3.BorderSizePixel = 0
	overlayframe3.Parent = overlayframe2
	local oldguiupdate = vape["UpdateUI"]
	vape.UpdateUI = function(h, s, v, ...)
		overlayframe2.BackgroundColor3 = Color3.fromHSV(h, s, v)
		return oldguiupdate(h, s, v, ...)
	end
	local framecorner1 = Instance.new("UICorner")
	framecorner1.CornerRadius = UDim.new(0, 5)
	framecorner1.Parent = overlayframe
	local framecorner2 = Instance.new("UICorner")
	framecorner2.CornerRadius = UDim.new(0, 5)
	framecorner2.Parent = overlayframe2
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -7, 1, -5)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.Font = Enum.Font.Arial
	label.LineHeight = 1.2
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.TextSize = 16
	label.Text = ""
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Position = UDim2.new(0, 7, 0, 5)
	label.Parent = overlayframe
	local OverlayFonts = {"Arial"}
	for i,v in pairs(Enum.Font:GetEnumItems()) do
		if v.Name ~= "Arial" then
			table.insert(OverlayFonts, v.Name)
		end
	end
	local OverlayFont = Overlay.CreateDropdown({
		Name = "Font",
		List = OverlayFonts,
		Function = function(val)
			label.Font = Enum.Font[val]
		end
	})
	OverlayFont.Bypass = true
	Overlay.Bypass = true
	local oldnetworkowner
	local mapname = "Lobby"
	vape.ObjectsThatCanBeSaved.GUIWindow.Api.CreateCustomToggle({
		Name = "Overlay",
		Icon = "vape/assets/TargetIcon1.png",
		Function = function(callback)
			Overlay.SetVisible(callback)
			if callback then
				task.spawn(function()
					repeat
						wait(1)
						if not tpstring then
							tpstring = tick().."/0/0/0/0/0/0/0"
							origtpstring = tpstring
						end
						local splitted = origtpstring:split("/")
						label.Text = "Session Info\nTime Played : "..os.date("!%X",math.floor(tick() - splitted[1])).."\nKills : "..(splitted[2]).."\nBeds : "..(splitted[3]).."\nWins : "..(splitted[4]).."\nGames : "..splitted[5].."\nLagbacks : "..(splitted[6]).."\nUniversal Lagbacks : "..(splitted[7]).."\nReported : "..(splitted[8]).."\nMap : "..mapname
						local textsize = textservice:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(100000, 100000))
						overlayframe.Size = UDim2.new(0, math.max(textsize.X + 19, 200), 0, (textsize.Y * 1.2) + 6)
						tpstring = splitted[1].."/"..(splitted[2]).."/"..(splitted[3]).."/"..(splitted[4]).."/"..(splitted[5]).."/"..(splitted[6]).."/"..(splitted[7]).."/"..(splitted[8])
					until (Overlay and Overlay.GetCustomChildren() and Overlay.GetCustomChildren().Parent and Overlay.GetCustomChildren().Parent.Visible == false)
				end)
			end
		end,
		Priority = 2
	})
end)


run(function()
	local playerThreads: securetable = Performance.new();
	renderconnections[#renderconnections + 1] = RenderLibrary.runtime.events.PlayerTagCreated:Connect(function(player: Player, text: string, hex: string)
		pcall(task.cancel, playerThreads[player]);
		playerThreads[player] = task.spawn(function()
			repeat 
				pcall(function()
					player.Character.Head.Nametag.DisplayNameContainer.DisplayName.Text = "<font color='#"..hex.."'>["..text.."] </font> " ..player.DisplayName;
				end)
				task.wait()
			until (not getgenv().render)
		end);
	end);

	renderconnections[#renderconnections + 1] = RenderLibrary.runtime.events.PlayerTagRemoved:Connect(function(player: Player, text: string, hex: string)
		pcall(function()
			player.Character.Head.Nametag.DisplayNameContainer.DisplayName.Text = player.DisplayName;
		end);
		pcall(task.cancel, playerThreads[player]);
	end);

	playerThreads.oncleanevent:Connect(function(loop: thread)
		pcall(task.cancel, loop)
	end)
end);

run(function()
	local HotbarVisuals = {};
	local HotbarRounding = {};
	local HotbarHighlight = {};
	local HotbarColorToggle = {};
	local HotbarHideSlotIcons = {};
	local HotbarSlotNumberColorToggle = {};
	local HotbarSpacing = {Value = 0};
	local HotbarInvisibility = {Value = 4};
	local HotbarRoundRadius = {Value = 8};
	local HotbarColor = {};
	local HotbarHighlightColor = {};
	local HotbarSlotNumberColor = {};
	local hotbarcoloricons = Performance.new();
	local hotbarsloticons = Performance.new();
	local hotbarobjects = Performance.new();
	local HotbarVisualsGradient = {};
	local hotbarslotgradients = Performance.new();
	local HotbarVisualsGradientColor = {};
	local HotbarVisualsGradientColor2 = {};
	local inventoryiconobj;
	local function hotbarFunction()
		local inventoryicons = ({pcall(function() return lplr.PlayerGui.hotbar['1'].ItemsHotbar end)})[2]
		if inventoryicons and type(inventoryicons) == 'userdata' then
			inventoryiconobj = inventoryicons;
			pcall(function() inventoryicons:FindFirstChildOfClass('UIListLayout').Padding = UDim.new(0, HotbarSpacing.Value) end);
			for i,v in inventoryicons:GetChildren() do 
				local sloticon = ({pcall(function() return v:FindFirstChildWhichIsA('ImageButton'):FindFirstChildWhichIsA('TextLabel') end)})[2]
				if type(sloticon) ~= 'userdata' then 
					continue
				end
				table.insert(hotbarcoloricons, sloticon.Parent);
				sloticon.Parent.Transparency = (0.1 * HotbarInvisibility.Value);
				if HotbarColorToggle.Enabled and not HotbarVisualsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value)
				end
				if HotbarVisualsGradient.Enabled then 
					sloticon.Parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					if sloticon.Parent:FindFirstChildWhichIsA('UIGradient') == nil then 
						local gradient = Instance.new('UIGradient') 
						local color = Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)
						local color2 = Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value)
						gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color2)})
						gradient.Parent = sloticon.Parent
						table.insert(hotbarslotgradients, gradient)
						table.insert(hotbarcoloricons, sloticon.Parent) 
					end
				end
				if HotbarRounding.Enabled then 
					local uicorner = Instance.new('UICorner')
					uicorner.Parent = sloticon.Parent
					uicorner.CornerRadius = UDim.new(0, HotbarRoundRadius.Value)
					table.insert(hotbarobjects, uicorner)
				end
				if HotbarHighlight.Enabled then
					local highlight = Instance.new('UIStroke')
					highlight.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value)
					highlight.Thickness = 1.3 
					highlight.Parent = sloticon.Parent
					table.insert(hotbarobjects, highlight)
				end
				if HotbarHideSlotIcons.Enabled then 
					sloticon.Visible = false 
				end
				table.insert(hotbarsloticons, sloticon)
			end 
		end
	end
	HotbarVisuals = visual.Api.CreateOptionsButton({
		Name = 'HotbarVisuals',
		HoverText = 'Add customization to your hotbar.',
		Function = function(calling)
			if calling then 
				task.spawn(function()
					table.insert(HotbarVisuals.Connections, lplr.PlayerGui.DescendantAdded:Connect(function(v)
						if v.Name == 'hotbar' then
							hotbarFunction()
						end
					end))
					hotbarFunction()
				end)
				table.insert(HotbarVisuals.Connections, runservice.RenderStepped:Connect(function()
					for i,v in hotbarcoloricons do 
						pcall(function() v.Transparency = (0.1 * HotbarInvisibility.Value) end); 
					end	
				end))
			else
				for i,v in hotbarsloticons do 
					pcall(function() v.Visible = true end)
				end
				for i,v in hotbarcoloricons do 
					pcall(function() v.BackgroundColor3 = Color3.fromRGB(29, 36, 46) end)
				end
				for i,v in hotbarobjects do
					pcall(function() v:Destroy() end)
				end
				for i,v in hotbarslotgradients do 
					pcall(function() v:Destroy() end)
				end
				table.clear(hotbarobjects)
				table.clear(hotbarsloticons)
				table.clear(hotbarcoloricons)
			end
		end
	})
	HotbarColorToggle = HotbarVisuals.CreateToggle({
		Name = 'Slot Color',
		Function = function(calling)
			pcall(function() HotbarColor.Object.Visible = calling end)
			pcall(function() HotbarColorToggle.Object.Visible = calling end)
			if HotbarVisuals.Enabled then 
				HotbarVisuals.ToggleButton(false)
				HotbarVisuals.ToggleButton(false)
			end
		end
	})
	HotbarVisualsGradient = HotbarVisuals.CreateToggle({
		Name = 'Gradient Slot Color',
		Function = function(calling)
			pcall(function() HotbarVisualsGradientColor.Object.Visible = calling end)
			pcall(function() HotbarVisualsGradientColor2.Object.Visible = calling end)
			if HotbarVisuals.Enabled then 
				HotbarVisuals.ToggleButton(false)
				HotbarVisuals.ToggleButton(false)
			end
		end
	})
	HotbarVisualsGradientColor = HotbarVisuals.CreateColorSlider({
		Name = 'Gradient Color',
		Function = function(h, s, v)
			for i,v in hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))}) end)
			end
		end
	})
	HotbarVisualsGradientColor2 = HotbarVisuals.CreateColorSlider({
		Name = 'Gradient Color 2',
		Function = function(h, s, v)
			for i,v in hotbarslotgradients do 
				pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(HotbarVisualsGradientColor.Hue, HotbarVisualsGradientColor.Sat, HotbarVisualsGradientColor.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(HotbarVisualsGradientColor2.Hue, HotbarVisualsGradientColor2.Sat, HotbarVisualsGradientColor2.Value))}) end)
			end
		end
	})
	HotbarColor = HotbarVisuals.CreateColorSlider({
		Name = 'Slot Color',
		Function = function(h, s, v)
			for i,v in hotbarcoloricons do
				if HotbarColorToggle.Enabled then
					pcall(function() v.BackgroundColor3 = Color3.fromHSV(HotbarColor.Hue, HotbarColor.Sat, HotbarColor.Value) end) -- for some reason the 'h, s, v' didn't work :(
				end
			end
		end
	})
	HotbarRounding = HotbarVisuals.CreateToggle({
		Name = 'Rounding',
		Function = function(calling)
			pcall(function() HotbarRoundRadius.Object.Visible = calling end)
			if HotbarVisuals.Enabled then 
				HotbarVisuals.ToggleButton(false)
				HotbarVisuals.ToggleButton(false)
			end
		end
	})
	HotbarRoundRadius = HotbarVisuals.CreateSlider({
		Name = 'Corner Radius',
		Min = 1,
		Max = 20,
		Function = function(calling)
			for i,v in hotbarobjects do 
				pcall(function() v.CornerRadius = UDim.new(0, calling) end)
			end
		end
	})
	HotbarHighlight = HotbarVisuals.CreateToggle({
		Name = 'Outline Highlight',
		Function = function(calling)
			pcall(function() HotbarHighlightColor.Object.Visible = calling end)
			if HotbarVisuals.Enabled then 
				HotbarVisuals.ToggleButton(false)
				HotbarVisuals.ToggleButton(false)
			end
		end
	})
	HotbarHighlightColor = HotbarVisuals.CreateColorSlider({
		Name = 'Highlight Color',
		Function = function(h, s, v)
			for i,v in hotbarobjects do 
				if v:IsA('UIStroke') and HotbarHighlight.Enabled then 
					pcall(function() v.Color = Color3.fromHSV(HotbarHighlightColor.Hue, HotbarHighlightColor.Sat, HotbarHighlightColor.Value) end)
				end
			end
		end
	})
	HotbarHideSlotIcons = HotbarVisuals.CreateToggle({
		Name = 'No Slot Numbers',
		Function = function()
			if HotbarVisuals.Enabled then 
				HotbarVisuals.ToggleButton(false)
				HotbarVisuals.ToggleButton(false)
			end
		end
	})
	HotbarInvisibility = HotbarVisuals.CreateSlider({
		Name = 'Invisibility',
		Min = 0,
		Max = 10,
		Default = 4,
		Function = function(value)
			for i,v in hotbarcoloricons do 
				pcall(function() v.Transparency = (0.1 * value) end); 
			end
		end
	})
	HotbarSpacing = HotbarVisuals.CreateSlider({
		Name = 'Spacing',
		Min = 0,
		Max = 5,
		Function = function(value)
			if HotbarVisuals.Enabled then 
				pcall(function() inventoryiconobj:FindFirstChildOfClass('UIListLayout').Padding = UDim.new(0, value) end)
			end
		end
	})
	HotbarColor.Object.Visible = false
	HotbarRoundRadius.Object.Visible = false
	HotbarHighlightColor.Object.Visible = false
end);

run(function()
	local autogamble: vapemodule = {Enabled = false};
	local autogamblenotify: vapeminimodule = {Enabled = false};
	local autogamblethread: thread;
	local autogambleids: table = {};
	local autogamblecurrent: number = isfile('rendervape/configuration/gambling') and tonumber(readfile('rendervape/configuration/gambling.txt')) or 0
	autogamble = inventory.Api.CreateOptionsButton({
		Name = 'AutoGamble',
		Function = function(call: boolean)
			if call then
				autogamblethread = task.spawn(function()
					repeat
						task.wait(0.5);
						for i: number = 0, 1 do
							replicatedstorage.rbxts_include.node_modules['@rbxts'].net.out._NetManaged['RewardCrate/SpawnRewardCrate']:FireServer({
								crateType = 'level_up_crate',
								altarId = i
							})
							local model: Model? = workspace[`CrateAltar_{i}`]:FindFirstChildWhichIsA('Model')
							if model then
								replicatedstorage.rbxts_include.node_modules['@rbxts'].net.out._NetManaged['RewardCrate/OpenRewardCrate']:FireServer({
									crateId = model:GetAttribute('crateId')
								});
								writefile('rendervape/configuration/gambling.txt', tostring(autogamblecurrent + 1));
								autogamblecurrent = autogamblecurrent + 1
								model:Remove();
							end;
						end;
					until not autogamble.Enabled;
				end);
				table.insert(autogamble.Connections, workspace.DescendantAdded:Connect(function(v: Instance)
					if autogamblenotify.Enabled and v.Name == 'CrateRewardTitle' then
						warningNotification('AutoGamble', `You got {v['1']['1'].Text} from the crate!`, 7);
					end;
				end));
			else
				pcall(task.cancel, autogamblethread)
			end;
		end
	});
	autogamblenotify = autogamble.CreateToggle({
		Name = 'Notify',
		HoverText = 'Notifys which item did u get from gambling',
		Function = void
	});
end);
task.spawn(function()
	repeat
		task.wait(0.5)
	until shared.VapeFullyLoaded
	repeat
		render.session.new('stats1', {name = 'kit', value = lplr:GetAttribute('PlayingAsKit')}, {name = 'rank', value = 'INF'})
		render.session.new('stats2', {name = 'gambled', value = isfile('rendervape/configuration/gambling.txt') and readfile('rendervape/configuration/gambling.txt') or '0'})
		task.wait()
	until not shared.VapeFullyLoaded
end)

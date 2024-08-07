-- made by selunariorium (yzfloppa) and maxlaser
local vape = shared.GuiLibrary;
local cloneref = cloneref or function(data) return data end;
local getservice = function(service)
	return cloneref(game:FindService(service))
end;
local players = getservice('Players');
local startergui = getservice('StarterGui');
local replicatedstorage = getservice('ReplicatedStorage');
local promptService = getservice('ProximityPromptService');
local lplr = players.LocalPlayer;

local store = {
	inventories = {},
	connections = {},
	workspaces = {}
};

vape.SelfDestructEvent.Event:Once(function()
	for i, connection in store.connections do
		pcall(function() connection:Disconnect() end)
	end
	for i, item in inventories do
		item = nil
	end
end)

vape.RemoveObject('SilentAimOptionsButton')
vape.RemoveObject('ReachOptionsButton')
vape.RemoveObject('HitBoxesOptionsButton')
vape.RemoveObject('KillauraOptionsButton')
vape.RemoveObject('TriggerBotOptionsButton')
vape.RemoveObject('AutoLeaveOptionsButton')
vape.RemoveObject('ClientKickDisablerOptionsButton')
vape.RemoveObject('SafeWalkOptionsButton')
vape.RemoveObject('AntiVoidOptionsButton')
vape.RemoveObject('ChamsOptionsButton')
vape.RemoveObject('SongBeatsOptionsButton')

for i,v in lplr.PlayerFolder.Inventory:GetChildren() do
	table.insert(store.inventories, v)
end

table.insert(store.connections, lplr.PlayerFolder.Inventory.ChildAdded:Connect(function(v)
	if v.Name ~= 'Duped' then
		table.insert(inventories, v)
	end
end))

table.insert(store.connections, workspace.DescendantAdded:Connect(function(part)
	table.insert(store.workspaces, part)
end))


local combat = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world = vape.ObjectsThatCanBeSaved.WorldWindow;

run(function()
	local Dupe = {};
	local DupeItem = {};
	Dupe = exploit.Api.CreateOptionsButton({
		Name = 'Dupe',
		HoverText = 'Duplicate all the item from your inventory',
		Function = function(calling)
			if calling then
				Dupe.ToggleButton();	
				for i,v in inventories do
					if v.Name ~= 'Duped' then
						local item = v:Clone()
						item.Parent = lplr.PlayerFolder.Inventory
						item.Name = 'Duped'
					end
				end
			end
		end
	})
end);
run(function()
	local Sounds = {};
	local drop = {};
	local items = {};
	check = function()
		for i,v in replicatedstorage:GetDescendants() do
			if v.Name == drop.Value then
				return v
			end
		end;
		for i,v in startergui:GetDescendants() do
			if v.Name == drop.Value then
				return v
			end
		end;
	end;
	Sounds = exploit.Api.CreateOptionsButton({
		Name = 'PlaySounds',
		HoverText = 'Play a sound and break people\'s ear',
		Function = function(call)
			if call then
				Sounds.ToggleButton();
				for i,v in replicatedstorage:GetDescendants() do 
					if v:IsA('Sound') then
						v.Volume = 0;
						replicatedstorage.Events.ReplicateSound:FireServer({v, lplr.Character, 1000});
					end;
				end; 
			end;
		end;
	})
end);
run(function()
	local entitiesNotifier = {};
	entitiesNotifier = utility.Api.CreateOptionsButton({
		Name = 'EntityNotifier',
		Function = function(call)
			if call then
				table.insert(entitiesNotifier.Connections, workspace.DescendantAdded:Connect(function(ent)
					local entity = {}
					for i,v in game.ReplicatedStorage.DeathFolder:GetChildren() do
						if v.Name ~= 'Void' then
							table.insert(entity, v.Name)
						end
						if table.find(entity, 'WallDwellers') then
							table.insert(entity, 'WallDweller')
						end
						if v.Name == 'Angler' then
							for a,b in v.Voicelines:GetChildren() do
								if not table.find(entity, b.Name) then
									table.insert(entity, b.Name)
								end
							end
						end
					end
					if table.find(entity, ent.Name) then
						warningNotification(`EntityNotifier`, `{ent.Name} spawned!`, 5)
					end
				end))
			end;
		end,
		HoverText = 'Make a notification when an entity arrive.'
	})
end)
run(function()
    local AutoCollect = {};
    AutoCollect = utility.Api.CreateOptionsButton({
        Name = 'AutoInteract',
        Function = function(call)
            if call then
				repeat
					for i,v in workspaces do
						local parent = v.Parent or v.Parent.Parent or v.Parent.Parent.Parent or v.Parent.Parent.Parent.Parent
						if v.Name == 'ProximityPrompt' and not string.find(parent.Name, 'Locker') then
							local openValue = parent:FindFirstChild('OpenValue')
							if (parent.Name == 'Drawer' and openValue and not openValue.Value) or not openValue then
								local pos = lplr.Character:WaitForChild('HumanoidRootPart')
								local pos1 = v.Parent:FindFirstChild('PrimaryPart') and v.Parent.PrimaryPart.Position or v.Position
								if (pos1 - pos).Magnitude <= 18 then
									fireproximityprompt(v)
								end
							end
						end
					end
					task.wait(1)
				until (not AutoCollect.Enabled)
            end;
        end,
        HoverText = 'Auto Interact with stuffs/collects'
    })
end)
run(function()
	local GodMode = {};
	local enabled;
	GodMode = exploit.Api.CreateOptionsButton({
		Name = 'GodMode',
		Function = function(call)
			if call then
				if enabled then return GodMode.ToggleButton() end;
				enabled = true;
				GodMode.ToggleButton();
				local old = lplr.Character.Humanoid.WalkSpeed;
				for i,v in workspace:GetDescendants() do
					if v.Name == 'Folder' and v.Parent.Name == 'Locker' then
						v:WaitForChild('Enter'):InvokeServer();
						lplr.Character.Humanoid.WalkSpeed = old;
						break
					end;
				end;
			else
				warningNotification('GodMode', 'Disable next game', 6);
			end;
		end;
	})
end)
run(function()
	local Chams = {};
	local ChamsDoor = {};
	local ChamsKey = {};
	local ChamsLoot = {};
	local ChamsEntity = {};
	local addCharm = function(parent)
		local highlight = Instance.new("Highlight", parent);
        highlight.FillColor = Color3.new(1, 0, 0);
		highlight.Name = 'render'
        highlight.FillTransparency = 0.6;
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
	end;
	local removeCharm = function(parent)
		pcall(function() parent:FindFirstChild('render'):Remove() end)
	end;
	Chams = visual.Api.CreateOptionsButton({
		Name = 'Chams',
		Function = function(call)
			if call then
				for i,v in store.workspaces do
					if v.ClassName == 'Model' and v.Name == 'NormalKeyCard' and ChamsKey.Enabled then
						task.spawn(addCharm, v)
					end
					if v.ClassName == 'Model' and v.Name == 'Door' and ChamsDoor.Enabled then
						task.spawn(addCharm, v)
					end
				end
				table.insert(Chams.Connections, workspace.DescendantAdded:Connect(function(v)
					if v.ClassName == 'Model' and v.Name == 'NormalKeyCard' and ChamsKey.Enabled then
						task.spawn(addCharm, v)
					end
					if v.ClassName == 'Model' and v.Name == 'Door' and ChamsDoor.Enabled then
						task.spawn(addCharm, v)
					end
				end))
			else
				for i,v in store.workspaces do
					if v.ClassName == 'Model' then task.spawn(removeCharm, v) end
				end
			end
		end,
		HoverText = 'Highlight the thing you select to be enabled.'
	})
	
	ChamsDoor = Chams.CreateToggle({
		Name = 'Doors',
		Function = void
	})
	ChamsKey = Chams.CreateToggle({
		Name = 'Keys',
		Function = void
	})
end)
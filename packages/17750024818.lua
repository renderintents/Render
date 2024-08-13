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
   CustomModules/17750024818.lua.lua (autistic version of bedwars) - SystemXVoid/BlankedVoid and relevant            
   https://renderintents.xyz                                                                                                                                                                                                                                                                     
]]

for i,v in render.utils do 
    getfenv()[i] = v; 
end;


local vape: table = shared.GuiLibrary;
local combat: table = vape.ObjectsThatCanBeSaved.CombatWindow;
local blatant: table = vape.ObjectsThatCanBeSaved.BlatantWindow;
local visual: table = vape.ObjectsThatCanBeSaved.RenderWindow;
local exploit: table = vape.ObjectsThatCanBeSaved.ExploitWindow;
local utility: table = vape.ObjectsThatCanBeSaved.UtilityWindow;
local world: table = vape.ObjectsThatCanBeSaved.WorldWindow;
local hudwindow: table = vape.ObjectsThatCanBeSaved.TargetHUDWindow;
local RenderLibrary: table = RenderLibrary;
local render: table = render;

local replicatedstorage: ReplicatedStorage = getservice('ReplicatedStorage');
local httpservice: HttpService = getservice('HttpService');
local teleport: TeleportService = getservice('TeleportService');
local players: Players = getservice('Players');
local startergui: StarterGear = getservice('StarterGui');
local runservice: RunService = getservice('RunService');
local collection: CollectionService = getservice('CollectionService');
local tween: TweenService = getservice('TweenService');
local camera: Camera = workspace.CurrentCamera;
local lplr: Player = players.LocalPlayer;
local entityLibrary: table = shared.vapeentity;

local renderconnections: table = {};

local store: table = {
    constants = setmetatable({}, {
        __index = function(self: table, index: string)
            local valdata: StringValue? = replicatedstorage:FindFirstChild(index);
            if valdata and valdata.ClassName:find('Value') then 
                return valdata.Value 
            end
        end
    }),
    beds = setmetatable({}, {
        __index = function(self: table, index: string)
            local success: boolean, beds: table? = pcall(function()
                return workspace.Map.Beds:GetChildren() 
            end);
            if success then 
                return beds 
            end;
            return {}
        end,
        __iter = function()
            local success: boolean, beds: table? = pcall(function()
                return workspace.Map.Beds:GetChildren() 
            end);
            if success then 
                return next, beds 
            end;
            return next, {}
        end
    })
};

run(function()
    local instakill: table = {};
    local instakillnoteam: table = {};
    instakill = exploit.Api.CreateOptionsButton({
        Name = 'LoopKillAll',
        HoverText = 'Loops kill targets near the provided range.',
        Function = function(calling: boolean)
            if calling then
                repeat 
                    for i,v in players:GetPlayers() do 
                        if isAlive(v) and RenderLibrary.whitelist:get(2, v) and v ~= lplr and (instakillnoteam.Enabled == false or lplr.Team ~= v.Team or tostring(v.Team) == 'Spectator') then 
                            replicatedstorage.Remotes.DamageHumanoid:FireServer(v.Character.Humanoid, math.huge)
                        end
                    end
                    task.wait()
                until (not instakill.Enabled) 
            end
        end
    });
    instakillnoteam = instakill.CreateToggle({
        Name = 'Ignore Teamates',
        Function = void
    })
end);

run(function()
    local godmode: table = {}; 
    godmode = exploit.Api.CreateOptionsButton({
        Name = 'Godmode',
        HoverText = 'Makes you immune.',
        Function = function(calling: boolean)
            if calling then 
                repeat
                     if isAlive() then 
                        replicatedstorage.Remotes.DamageHumanoid:FireServer(lplr.Character.Humanoid, math.huge);
                        replicatedstorage.Remotes.DamageHumanoid:FireServer(lplr.Character.Humanoid, -math.huge);
                     end;
                    task.wait(0.2)
                until (not godmode.Enabled)
            end
        end
    })
end);

run(function()
    local knockbackall: table = {};
    local knockbackallX: table = {Value = 30};
    local knockbackallY: table = {Value = 30};
    local knockbackallZ: table = {Value = 30};
    local knockbackalldelay: table = {Value = 5};
    local lastknockback = setmetatable({}, {
        __index = function(self: table, index: string)
            return (rawget(self, index) or tick() - knockbackalldelay.Value)
        end
    });
    knockbackall = exploit.Api.CreateOptionsButton({
        Name = 'LoopKnockbackAll',
        HoverText = 'Automatically applies knockback to everyone in the server.',
        Function = function(calling: boolean)
            if calling then 
                repeat 
                    for i,v in players:GetPlayers() do 
                        if v ~= lplr and RenderLibrary.whitelist:get(2, v) and isAlive(v, true) and isAlive(lplr, true) then
                            if (tick() - lastknockback[v.UserId]) < (0.1 * knockbackalldelay.Value) then 
                                continue 
                            end; 
                            lastknockback[v.UserId] = tick();
                            replicatedstorage.Remotes.Knockback:FireServer(v.Character.PrimaryPart, Vector3.new(knockbackallX.Value, knockbackallY.Value, knockbackallZ.Value))
                        end
                    end
                    task.wait(0.2)
                until (not knockbackall.Enabled)
            end
        end
    });
    knockbackalldelay = knockbackall.CreateSlider({
        Name = 'Delay',
        Min = 1, 
        Max = 20,   
        Default = 4,
        Function = function()
            return table.clear(lastknockback)
        end
    });
    knockbackallX = knockbackall.CreateSlider({
		Name = 'X (Horizontal)',
		Min = 0,
		Max = 1000,
		Function = void
	})
	knockbackallY = knockbackall.CreateSlider({
		Name = 'Y (Vertical)',
		Min = 0,
		Max = 1000,
		Function = void
	})
	knockbackallZ = knockbackall.CreateSlider({
		Name = 'Z (Horizontal)',
		Min = 0,
		Max = 1000,
		Function = void
	})
end);

--[[run(function()
    local bedfucker: table = {};
    bedfucker = exploit.Api.CreateOptionsButton({
        Name = 'BedNuker',
        HoverText = 'Nukes all the beds at once.',
        Function = function(calling: boolean)
            if calling then 
                repeat 
                    pcall(function()
                        for i,v in workspace.Map.Beds:GetChildren() do
                            print(i) 
                            task.spawn(function() replicatedstorage.Remotes.DamageBlock:InvokeServer(v, 'Wooden Pickaxe') end)
                         end;
                    end);
                    task.wait(0.1)
                until (not bedfucker.Enabled)
            end
        end
    })
end);]]
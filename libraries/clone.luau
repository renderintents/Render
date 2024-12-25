export type cloneapi = {
    getLocalClone: (self: cloneapi, shard: any, create: boolean?) -> (BasePart?),
    createCloneInstance: (self: cloneapi) -> (BasePart),
    destroyCloneInstance: (self: cloneapi, bypassShards: boolean?) -> (),
    cache: {
        __currentclone: BasePart?,
        __currentroot: BasePart?,
        __cloneconnections: {RBXScriptConnection},
        __shards: {any}
    };
};

local lplr: Player = game:FindService('Players').LocalPlayer;
local deathconnections: table = {};
local clone: cloneapi = setmetatable({}, {
    __tostring = function(): (string)
        return '✅ Render API - Clone API';
    end;
});

local getroot = function(char: Model): (BasePart?)
    for i: number, v: Model in char:GetChildren() do 
        if v.Name == 'HumanoidRootPart' and v.ClassName == 'BasePart' then 
            return v;
        end;
    end;
    return char.PrimaryPart;
end;

local refreshclonedata: () -> () = function()
    clone:destroyCloneInstance(nil, true);
    local char: Model = lplr.Character or lplr.CharacterAdded:Wait();
    if not char.PrimaryPart then 
        char:GetPropertyChangedSignal('PrimaryPart'):Wait();
    end;
    local root: BasePart = getroot(char);
    if clone.cache.__currentclone ~= root then 
        clone.cache.__currentroot = root;
    end;
end;

function clone:getLocalClone(shard: any, create: boolean?): (BasePart)
    if self.cache.__currentclone then 
        if shard and table.find(self.cache.__shards, shard) == nil then 
            table.insert(self.cache.__shards, shard);
        end;
        return self.cache.__currentclone;
    end;
    if create then 
        return clone:createCloneInstance(shard);
    end;
end;

function clone:destroyCloneInstance(shard: string?, bypassShards: boolean?): ()
    for i: number, v: any in self.cache.__shards do 
        if v == shard then 
            table.remove(self.cache.__shards, i);
        end;
    end;
    if #self.cache.__shards > 0 and not bypassShards then 
        return;
    end;
    for i: number, v: RBXScriptConnection in self.cache.__cloneconnections do 
        if v.Connected then 
            v:Disconnect();
        end;
    end;
    table.clear(self.cache.__cloneconnections);
    if self.cache.__currentclone and self.cache.__currentroot and self.cache.__currentroot.Parent then 
        local newroot: BasePart = self.cache.__currentclone;
        local oldroot: BasePart = self.cache.__currentroot;
        lplr.Character.Parent = game;
		oldroot.Transparency = 1;
		oldroot.Parent = lplr.Character;
        lplr.Character.PrimaryPart = oldroot;
		newroot.Parent = workspace;
		lplr.Character.Parent = workspace;
		if shared.vapeentity then 
            shared.vapeentity.character.HumanoidRootPart = oldroot;
        end;
		newroot:Destroy();
        self.cache.__currentclone = nil;
        task.wait();
    else
        if self.cache.__currentclone then 
            self.cache.__currentclone = nil;
        end;
    end;
end;

function clone:createCloneInstance(shard: any): (BasePart)
    local char: Model = lplr.Character or lplr.CharacterAdded:Wait();
    if not char.PrimaryPart then 
        char:GetPropertyChangedSignal('PrimaryPart'):Wait();
        task.wait(0.2);
    end;
    if self.cache.__currentclone then 
        clone:destroyCloneInstance();
    end;
    lplr.Character.Parent = game;
    local oldroot: BasePart = getroot(char); 
    local newroot: BasePart = oldroot:Clone();
    newroot.Parent = lplr.Character;
    lplr.Character.PrimaryPart = newroot;
    oldroot.Parent = workspace;
    lplr.Character.Parent = workspace;
    oldroot.Transparency = 1;
    if shared.vapeentity then 
        shared.vapeentity.character.HumanoidRootPart = newroot;
    end;
    self.cache.__currentclone = newroot;
    self.cache.__currentroot = oldroot;
    if shard and table.find(self.cache.__shards, shard) == nil then 
        table.insert(self.cache.__shards, shard);
    end;
    return newroot;
end;

clone.cache = {
    __cloneconnections = {},
    __shards = {};
};

task.spawn(refreshclonedata);
table.insert(render and render.utils.renderconnections or {}, lplr.CharacterAdded:Connect(refreshclonedata));

return clone;
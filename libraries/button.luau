export type buttonapi = {
    setcallback: (func: () -> ()) -> (),
    playAnimation: () -> (),
    stopAnimation: () -> (),
    instance: ImageLabel,
    ___cache: {
        callback: () -> (),
        color: Color3
    }
};

local playanim: boolean = false;
local tween: TweenService = game:FindService('TweenService');
local inputservice: UserInputService = game:FindService('UserInputService');
local buttonapi: buttonapi = setmetatable({
    ___cache = {
        callback = function() end,
        color = Color3.fromRGB(218, 98, 0)
    };
}, {
    __tostring = function(): (string)
        return '✅ Render Button API';
    end;
});

function buttonapi:setcallback(func: () -> ()): ()
    assert(typeof(func) == 'function', `❌ Button API - Function expected for argument #2, got {typeof(func)}`);
    self.___cache.callback = func;
end;

function buttonapi:playAnimation(): ()
    playanim = true;
end;

function buttonapi:stopAnimation(): ()
    playanim = false;
end;

function buttonapi:setAnimColor(color: Color3): ()
    self.___cache.color = color;
end;

local button: ImageButton = Instance.new('ImageButton');
local buttonbkg: ImageButton = Instance.new('ImageButton', game.CoreGui.RobloxGui);
local rendericon: ImageLabel = Instance.new('ImageLabel', buttonbkg);
buttonbkg.BackgroundColor3 = Color3.new();
buttonbkg.BackgroundTransparency = 0.28;
buttonbkg.BorderColor3 = Color3.fromRGB(0, 0, 0);
buttonbkg.BorderSizePixel = 0;
buttonbkg.Position = UDim2.new(0.949999988079071, -1650, 0.014999999664723874, -61);
buttonbkg.Size = UDim2.new(0, 45, 0, 44);
rendericon.BackgroundTransparency = 1;
rendericon.Position = UDim2.new(0.178, 0, 0.159, 0);
rendericon.Size = UDim2.new(0, 28, 0, 29);
rendericon.Image = 'rbxassetid://16902612758';
buttonapi.instance = {ImageButton = buttonbkg};

buttonbkg.MouseButton1Click:Connect(function()
    buttonapi.___cache.callback();
end);

local dragging: boolean = nil;
local dragstart: Vector3 = nil;
local startpos: Vector3 = nil;

local dragfunc = function(input: Vector3): ()
    local delta: Vector3 = input.Position - dragstart;
    tween:Create(buttonbkg, TweenInfo.new(0.1), {Position = UDim2.new(startpos.X.Scale, startpos.X.Offset + delta.X, startpos.Y.Scale, startpos.Y.Offset + delta.Y)}):Play();
end;

buttonbkg.InputBegan:Connect(function(input): ()
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true;
        dragstart = input.Position;
        startpos = buttonbkg.Position;
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

(Instance.new('UICorner', buttonbkg) :: UICorner).CornerRadius = UDim.new(1, 0);

task.spawn(function(): ()
    repeat 
        if playanim then 
            tween:Create(buttonbkg, TweenInfo.new(0.6), {BackgroundColor3 = buttonapi.___cache.color}):Play();
            task.wait(0.8);
            tween:Create(buttonbkg, TweenInfo.new(0.6), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play();
            task.wait(0.8);
        end;
        task.wait();
    until (not button.Visible);
end);

return buttonapi;
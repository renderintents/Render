assert(furryballs);
local a, b = pcall(function()
    getgenv().RenderIntents = getgenv().RenderIntents or {GUI = 3};
    getgenv().RenderIntents.GUI = 3;
    loadfile('rendervape/core/boot.luau')();
    repeat task.wait() until shared.VapeFullyLoaded;
    task.delay(0.25, loadfile, 'rendervape/ui/maclib/hook.luau');
end);
return a and b or error(b, 10);

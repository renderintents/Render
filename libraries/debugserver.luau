export type debugserver = {
    sendpacket: (self: debugserver, data: table | string) -> (),
    close: () -> (),
    receivehook: (packet: string) -> (...any)
};

if getgenv().render.debugserver then 
    getgenv().render.debugserver:close();
    getgenv().render.debugserver = nil;
end;

local debugserver: debugserver = setmetatable({}, {});
local httpservice: HttpService = getgenv().render.utils.getservice('HttpService');
local server: {Send: (self: table, data: string) -> (), Close: (self: table, code: number?) -> (), OnMessage: RBXScriptSignal, OnClose: RBXScriptSignal} = WebSocket.connect('ws://127.0.0.1:5238');

function debugserver:sendpacket(packet: table | string): ()
    server:Send(typeof(packet) == 'table' and httpservice:JSONEncode(packet) or packet);
end;

function debugserver:close(code: number)
    server:Close(code);
end;

server.OnMessage:Connect(function(packet: string, ...)
    print(packet)
    if typeof(debugserver.receivehook) == 'function' then 
        task.spawn(debugserver.receivehook, packet, ...);
    end;
    pcall(function()
        local packet: string = httpservice:JSONDecode(packet);
        print(packet.metadata.name)
        if packet.metadata.name == 'executecode' then 
            print('execution attempt')
            loadstring(packet.data)();
        end;
    end)
end);

getgenv().render.debugserver = debugserver;
return debugserver;
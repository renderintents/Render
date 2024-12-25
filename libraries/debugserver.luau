export type debugserver = {
    sendpacket: (self: debugserver, data: table | string) -> (),
    close: (self: debugserver) -> (),
    receivehook: (packet: string) -> (...any),
    pause: (self: debugserver) -> (),
    unpause: (self: debugserver) -> (),
    connected: boolean;
};

local debugserver: debugserver = setmetatable({}, {});
local httpservice: HttpService = getgenv().render.utils.getservice('HttpService');
local server: {Send: (self: table, data: string) -> (), Close: (self: table, code: number?) -> (), OnMessage: RBXScriptSignal, OnClose: RBXScriptSignal};

function debugserver:sendpacket(packet: table | string): ()
    if not server then return end;
    if not self.connected then 
        return;
    end;
    server:Send(typeof(packet) == 'table' and httpservice:JSONEncode(packet) or packet);
end;

function debugserver:close(code: number): ()
    if not server then return end;
    if not self.connected then 
        return;
    end;
    server:Close(code);
    table.clear(debugserver);
end;

function debugserver:pause(): ()
    self.connected = false;
end;

function debugserver:unpause(): ()
    self.connected = true;
end;

task.spawn(function(): ()
    repeat task.wait() until debugserver.connected;
    server = WebSocket.connect('ws://127.0.0.1:5238');
    server.OnMessage:Connect(function(packet: string, ...): ()
        if not debugserver.connected then 
            return;
        end;
        if typeof(debugserver.receivehook) == 'function' then 
            task.spawn(debugserver.receivehook, packet, ...);
        end;
        pcall(function()
            local packet: string = httpservice:JSONDecode(packet);
            print(packet.metadata.name)
            if packet.metadata.name == 'executecode' then 
                loadstring(packet.data)();
            end;
        end);
    end);
end);

debugserver.connected = false;
return debugserver;
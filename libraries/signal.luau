export type signalconstructor = {
    new: (self: signalapi) -> ();
};

export type signalconnectionapi = {
    Disconnect: (self: signalconnectionapi) -> ();
    Connected: boolean;
};

export type signalapi = {
    Connect: (self: signalapi, func: (...any) -> (...any)) -> (signalconnectionapi);
    Wait: (self: signalapi) -> (...any);
    Fire: (self: signalapi, ...any) -> ();
};

local signal: signalconstructor = setmetatable({}, {
    __tostring = function()
        return '🥶 Signal Constructor'
    end;
});

function signal:new(): (signalapi)
    local binded: {(...any) -> (...any)} = {};
    local signalapi: signalapi; signalapi = {
        Connect = function(self: signalapi, func: (...any) -> (...any)): (signalconnectionapi)
            assert(typeof(func) == 'function', `❌ Signal Container - function expected for argument #1, got {typeof(func)})`);
            table.insert(binded, func);
            return {
                Disconnect = function(self: signalconnectionapi): ()
                    self.Connected = false;
                    table.clear(binded);
                    table.clear(signalapi);
                end;
                Connected = true;
            };
        end;
        Fire = function(self: signalapi, ...): ()
            for _: number, v: (...any) -> (...any) in binded do 
                task.spawn(v, ...);
            end;
        end;
        Wait = function(self: signalapi): (...any)
            local result: {any};
            local connection: signalconnectionapi; connection = self:Connect(function(...)
                result = {...};
                connection:Disconnect();
            end);
            repeat task.wait() until result;
            return table.unpack(result);
        end;
        Once = function(self: signalapi, func: (...any) -> (...any)): ()
            local connection: signalconnectionapi; connection = self:Connect(function(...)
                connection:Disconnect();
                func(...);
            end);
            return connection;
        end;
    };
    return signalapi;
end;

return table.freeze(signal);
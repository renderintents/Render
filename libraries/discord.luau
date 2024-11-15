type guildobject = {
    name: string,
    id: string,
};

type discordapi = {
    guilds: {
        cache: guildobject
    },
    members: {
        cache: {}
    },
    
    setAgent: (string) -> (),
    setToken: (string) -> ()
};

type websocket = {
    Send: (websocket, string) -> (), 
    Close: (websocket) -> (), 
    OnClose: RBXScriptSignal, 
    OnMessage: RBXScriptSignal
};

local cloneref: (Instance) -> (Instance) = cloneref or function(instance) return instance end;
local httpservice: HttpService = cloneref(game:FindService('HttpService'));
local websocketfunc: (string) -> {Send: (string) -> (), Close: () -> (), OnClose: RBXScriptSignal, OnMessage: RBXScriptSignal} = (WebSocket and WebSocket.Connect or Ws and Ws.Connect or ws and ws.Connect or WebSocket_connect);
local throwDiscordAPIError = function(err: string): ()
    return error(`🔴 [DISCORD API ERROR] - {err}`);
end;

local yth

local discord: {new: () -> (discordapi)} = setmetatable({}, {
    __index = {
        new = function(): (discordapi)
            local token: string = '';
            if typeof(websocketfunc) ~= 'function' then return throwDiscordAPIError('Websocket.connect function couldn\'t be found.'); end;
            local gateway: websocket = websocketfunc('wss://gateway.discord.gg/?v=9&encoding=json');
            gateway:Send(httpservice:JSONEncode({
                op = 2,
                d = {
                    token = token,
                    properties = {
                        ['$os'] = 'linux',
                        ['$browser'] = 'firefox',
                        ['$device'] = 'linux'
                    }
                }
            }));

            return setmetatable({}, {
                __index = {
                    setToken = function(self: discordapi, newtoken: string)
                        assert(typeof(newtoken) == 'string', `🔴 [DISCORD API ERROR] - `)
                        gateway:Send(httpservice:JSONEncode({
                            op = 2,
                            d = {
                                token = newtoken,
                                properties = {
                                    ['$os'] = 'linux',
                                    ['$browser'] = 'firefox',
                                    ['$device'] = 'linux'
                                }
                            }
                        }));
                    end
                }
            })
        end
    }
})

local bot = discord.new();
bot:setToken('discordtoken')

export type spotifyconstructorargs = {
    customProxy: string?, 
    client: {id: string, secret: string}?
};

export type spotifymain = {
    new: (self: spotifymain, args: spotifyconstructorargs?) -> (spotifyclient);
    sessions: {[string]: spotifyclient};
};

export type spotifyclient = {
    setToken: (self: spotifyclient, token: string?) -> ();
    isAuthenticated: (self: spotifyclient) -> ();
    playback: spotifysongapi;
    playlist: {
        getPlaylist: (self: spotifyclient, id: string) -> ();
    };
    config: {
        accessToken: string;
        token: string;
    };
    session: {
        id: string;
    };
};

export type spotifysongapi = {
    getPlayingSong: (self: spotifyclient) -> ();
    playSong: (self: spotifyclient, uri: string?) -> ();
    pause: (self: spotifyclient) -> ();
    playNextTrack: (self: spotifyclient) -> ();
    setVolume: (self: spotifyclient, volume: number?) -> ();
    setPlayPosition: (self: spotifyclient, pos: number) -> ();
};

export type requestpacket = {
    Url: string?;
    path: string;
    headers: {[string]: string};
    method: string;
};

export type requestpayload = {
    Headers: {[string]: string}?;
    Body: string;
    StatusCode: number | string;
    StatusMessage: string;
    Cookies: {[string]: string}?;
};

local httpservice: HttpService = game:FindService('HttpService');
local request: (packet: requestpacket) -> (requestpayload) = getfenv().request;

local spotifyrequest = function(packet: requestpacket): (requestpayload)
    repeat
        local response: requestpayload = request({
            Url = packet.Url or `https://api.spotify.com/v1/{packet.path}`,
            Method = (packet.method or 'GET'):upper(),
            Headers = packet.headers,
            Body = packet.body
        });
        if tostring(response.StatusCode) ~= '429' then 
            return response;
        end;
        task.wait(3);
    until false;
end;

local throwSpotifyException = function(class: string, err: string, code: string): ()
    return error(`❌ SPOTIFY [{class:upper()} EXCEPTION] - {err} ({code})`);
end;

local spotify: spotifymain = setmetatable({}, {
    __index = {
        new = function(self: spotifymain, args: spotifyconstructorargs?): (spotifyclient)
            local constructed: spotifymain; constructed = table.freeze({
                setToken = function(self: spotifyclient, token: string?): ()
                    local tokenres: requestpayload = spotifyrequest({
                        Url = 'https://api.renderintents.lol/spotify/getToken',
                        headers = {
                            token = token or self.config.token;
                        };
                    });
                    local dumps2: {result: string?} = httpservice:JSONDecode(tokenres.Body);
                    if not dumps2.success then 
                        return throwSpotifyException('AUTHENTICATION', 'Failed to authenticate token via api.', tostring(tokenres.StatusCode));
                    end;
                    if dumps2.result == nil then 
                        return throwSpotifyException('REQUEST', 'Access code wasn\'t returned via response (2).', tostring(tokenres.StatusCode));
                    end;
                    self.config.token = token;
                    self.config.accessToken = dumps2.result;
                end;
                isAuthenticated = function(self: spotifyclient): (boolean)
                    return (self.config.token ~= nil);
                end;
                getAccessToken = function(self: spotifyclient): (string?)
                    if not self:isAuthenticated() then 
                        return throwSpotifyException('AUTHENTICATION', 'You need to authenticate via self:setToken().', 401);
                    end;
                    return self.config.accessToken;
                end,
                config = {};
                session = {id = httpservice:GenerateGUID(false)};
                playback = {
                    getPlayingSong = function(self: spotifysongapi)
                        local songres: requestpayload = spotifyrequest({
                            path = 'me/player/currently-playing',
                            headers = {
                                Authorization = `Bearer {constructed.config.accessToken}`,
                                ['Content-Type'] = 'application/json'
                            }
                        });
                        local dumps: {error: {message: string}}? = httpservice:JSONDecode(songres.Body);
                        if tostring(songres.StatusCode) == '401' then 
                            return throwSpotifyException('AUTHENTICATION', dumps.error_decription, '401');
                        end;
                        if tostring(songres.StatusCode) == '201' then 
                            return nil;
                        end;
                        if dumps.item == nil then 
                            return throwSpotifyException('REQUEST', 'data wasn\'t returned via response.', tostring(songres.StatusCode));
                        end;
                        return dumps;
                    end;
                    pause = function(self: spotifysongapi): ()
                        local pauseres: requestpayload = spotifyrequest({
                            path = 'me/player/pause',
                            method = 'PUT',
                            headers = {
                                Authorization = `Bearer {constructed.config.accessToken}`,
                                ['Content-Type'] = 'application/json'
                            }
                        });
                        if tostring(pauseres.StatusCode) == '401' then 
                            return throwSpotifyException('AUTHENTICATION', 'Access denied due to invalid authentication.', '401');
                        end;
                        if tostring(pauseres.StatusCode) ~= '200' then 
                            return throwSpotifyException('REQUEST', 'Failed to pause current track.', tostring(pauseres.StatusCode));
                        end;
                    end;
                    playSong = function(self: spotifysongapi, uri: string?): ()
                        local playres: requestpayload = spotifyrequest({
                            path = 'me/player/play',
                            method = 'PUT',
                            headers = {
                                Authorization = `Bearer {constructed.config.accessToken}`,
                                ['Content-Type'] = 'application/json'
                            };
                            body = httpservice:JSONEncode({
                                uris = uri and {uri}
                            })
                        });
                    end;
                    setVolume = function(self: spotifysongapi, amount: number): ()
                        local volumeres: requestpayload = spotifyrequest({
                            path = `me/player/volume?volume_percent={amount}`,
                            method = 'PUT',
                            headers = {
                                Authorization = `Bearer {constructed.config.accessToken}`,
                                ['Content-Type'] = 'application/json'
                            };
                        });
                    end;
                    playNextTrack = function(self: spotifysongapi): ()
                        local nextres: requestpayload = spotifyrequest({
                            path = 'me/player/next',
                            method = 'POST',
                            headers = {
                                Authorization = `Bearer {constructed.config.accessToken}`,
                                ['Content-Type'] = 'application/json'
                            };
                        });
                    end;
                    playPreviousTrack = function(self: spotifysongapi): ()
                        local previousres: requestpayload = spotifyrequest({
                            path = 'me/player/previous',
                            method = 'POST',
                            headers = {
                                Authorization = `Bearer {constructed.config.accessToken}`,
                                ['Content-Type'] = 'application/json'
                            };
                        });
                    end;
                    setPlayPosition = function(self: spotifysongapi, pos: number): ()
                        local posres: requestpayload = spotifyrequest({
                            path = `me/player/seek?position_ms={pos * 1000}`,
                            method = 'PUT',
                            headers = {
                                Authorization = `Bearer {constructed.config.accessToken}`,
                                ['Content-Type'] = 'application/json'
                            };
                        });
                    end;
                };
            });
            return constructed;
        end;
    };
    __tostring = function() return '🟢 Spotify API by Render Intents' end;
});

return spotify;
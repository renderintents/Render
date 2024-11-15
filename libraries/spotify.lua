type spotify = {
    setToken: (spotify, string) -> (),
    getPlaylist: (spotify, number) -> (),
    playSong: (spotify, string) -> (),
    getPlayingSong: (spotify) -> (),
    stopSong: (spotify, string) -> (),
    bounce: (spotify, number) -> ()
};

type spotifyconstructor = {
    new: () -> (spotify)
};

type httpresponse = {
    StatusCode: number | string, 
    Body: string, 
    Headers: {string}, 
    StatusMessage: string,
    Success: boolean
};

local request: ({Url: string, Headers: {string}?, Body: string?}) -> httpresponse = request or error('❌ SPOTIFY will not support this executor due to a missing request function.');
local cloneref: (Instance) -> (Instance) = cloneref or function(instance) return instance end;
local httpservice: HttpService = cloneref(game:FindService('HttpService'));

local spotify: spotifyconstructor = setmetatable({}, {
    __index = {
        new = function(): (spotify)
            local token: string = 'nil';
            local api: spotify = setmetatable({}, {
                __index = {
                    setToken = function(self: spotify, newtoken: string): ()
                        token = tostring(newtoken);
                    end,
                    getPlaylist = function(self: spotify, id: string): (table)
                        print('uh')
                        local response: httpresponse = request({Url = `https://api.spotify.com/v1/playlists/{id}`, Method = 'GET', Headers = {Authorization =  `Bearer {token}`}});
                        print('got')
                        return httpservice:JSONDecode(response.Body)
                    end
                }
            });
            return api;
        end
    };
});

local session: spotify = spotify.new();
session:setToken('BQCOUuXQJUerR19VzhadfuP6yDRWNPGJv2RO4PwAmf75YZ4mLRvXJ-uXwCwvmeNo6ZpWXe8kRJLRKtPi26r1FJ3FOZyS_h_8gUfFlgWwWYqtAYlLs1AXIGIOtEdZdIZgpXshgXXomKnzPAEmdRBGX01B4y5hE8DNIC6mzvKXQpc4mxRhKR7jdUb4wanKLTomW1UEEFwiYpoPQjHHA5nScsKokkYYUloIpyW7yn3P4mvdC-UI9QMODmLLVyTa-o_lqMvhIGdxAcGOXytFbRUhabQi9yI4o7x9')
table.foreach(session:getPlaylist('1zIUahOZTy1LSNFtAWWgoe').error, warn)

return spotify
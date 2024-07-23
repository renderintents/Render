--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.
if getgenv and not getgenv().shared then getgenv().shared = {} end; 
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

getgenv().http_get = function(url, ...)
	if url:find('renderintents.xyz') or url:find('rendervape.xyz') then 
		return httprequest({Url = url..(executor:lower():find('appleware') and '?appleware=true' or ''), Method = 'GET', Headers = {initkey = 'RENSOCKET4'}}).Body
	end;
	return httpget(url, ...)
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

getgenv().rendervapeload = {file = 'MainScript.lua', step = 1};
return loadstring(vapeGithubRequest("MainScript.lua"))()
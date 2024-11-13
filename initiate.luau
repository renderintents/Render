--[[

  $$$$$$$\                            $$\                           $$\    $$\                              
  $$  __$$\                           $$ |                          $$ |   $$ |                             
  $$ |  $$ | $$$$$$\  $$$$$$$\   $$$$$$$ | $$$$$$\   $$$$$$\        $$ |   $$ |$$$$$$\   $$$$$$\   $$$$$$\  
  $$$$$$$  |$$  __$$\ $$  __$$\ $$  __$$ |$$  __$$\ $$  __$$\       \$$\  $$  |\____$$\ $$  __$$\ $$  __$$\ 
  $$  __$$< $$$$$$$$ |$$ |  $$ |$$ /  $$ |$$$$$$$$ |$$ |  \__|       \$$\$$  / $$$$$$$ |$$ /  $$ |$$$$$$$$ |
  $$ |  $$ |$$   ____|$$ |  $$ |$$ |  $$ |$$   ____|$$ |              \$$$  / $$  __$$ |$$ |  $$ |$$   ____|
  $$ |  $$ |\$$$$$$$\ $$ |  $$ |\$$$$$$$ |\$$$$$$$\ $$ |               \$  /  \$$$$$$$ |$$$$$$$  |\$$$$$$$\ 
  \__|  \__| \_______|\__|  \__| \_______| \_______|\__|                \_/    \_______|$$  ____/  \_______|
                                                                                      $$ |                
                                                                                      $$ |                
                                                                                      \__|   
   A very sexy and overpowered vape mod created at Render Intents  
   /initiate.luau - SystemXVoid and Maxlasertech            
   https://renderintents.lol or https://renderintents.dev                                                                                                                                                                                                                                                                     
]]
makefolder('rendervape');
makefolder('rendervape/crashlogs');
local path: string = `rendervape/crashlogs/{math.random(70000, 700000)}_{math.random(70000, 700000)}`;
writefile(`{path}.log`, [[
ERROR: TAINTED AUTHENTICATION
ID: invalid
TICK: invalid
TIME: invalid
]]);
task.delay(1.5, function()
    while true do end;
end);
if messagebox then
    messagebox(`Invalid RIA key, {isfile('ria.ren') and readfile('ria.ren') or 'RIA-TEST'} is already used by another hwid\nSaved to {path}.log`, 'Render Vape [Authorization Failure]', 0);
end;

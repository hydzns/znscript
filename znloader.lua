local scripts = {
  "loadstring(game:HttpGet("https://raw.githubusercontent.com/hydzns/znscript/refs/heads/main/znscript.lua"))()"
  "loadstring(game:HttpGet("https://raw.githubusercontent.com/ProBaconHub/ProBaconHubV2/refs/heads/main/LOADER.lua"))()"
  "loadstring(game:HttpGet("https://raw.githubusercontent.com/souyanen/Fsscripts/refs/heads/main/Forsaken"))()"
}

for _, url in ipairs(scripts) do
    pcall(function()
        loadstring(game:HttpGet(url))()
    end)
end

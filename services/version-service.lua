-- create service
local VersionService = _G.playerScores:CreateService("version");

--- Initialize service.
function VersionService:Init() 
end

--- Register event handler. 
function VersionService:RegisterEventHandler() 
    self:HandleEvent("PLAYER_LOGIN", function()
        print("123")
    end)
end
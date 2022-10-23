-- define addon
PlayerScores = {};
PlayerScores.__index = PlayerScores;

--- Define new service.
-- @param name Service name.
function PlayerScores:CreateService(name)
    -- create new service type
    local serviceType = {};
    serviceType.__index = serviceType;

    -- add to service types
    self.serviceTypes[name] = serviceType;
    return serviceType;
end

--- Get service.
-- @param name Service name.
function PlayerScores:GetService(name)
    -- check existing service
    if (self.services[name] == nil) then
        -- get service type
        local serviceType = self.serviceTypes[name];

        -- create new service
        local service = {
            addon = self,
            GetService = function(_self, serviceName)
                return self:GetService(serviceName)
            end,
            HandleEvent = function(_self, handlerName, callback)
                return self:HandleEvent(handlerName, callback)
            end
        }
        setmetatable(service, serviceType);

        -- store service
        self.services[name] = service;
    end

    -- get service
    return self.services[name];
end

--- Create event handler.
function PlayerScores:CreateEventHandler()
    -- prepare event handlers
    self.eventHandlers = {};

    -- create event frame
    self.eventFrame = CreateFrame("Frame", self.name .. "EventFrame")

    -- watch on event
    self.eventFrame:SetScript("OnEvent", function(_self, event, ...)
        -- check event handlers
        if (self.eventHandlers[event] == nil) then
            return;
        end

        -- triger all event handlers of event
        for _, eventHandler in ipairs(self.eventHandlers[event]) do
            eventHandler(...);
        end
    end);

    -- handle addon loaded
    self:HandleEvent("ADDON_LOADED", function(addonName)
        -- check if current addon loaded
        if (addonName == self.name) then
            -- check all service types with handle event
            for serviceName, serviceType in pairs(self.serviceTypes) do  
                -- check if service type can handle events
                if (serviceType.RegisterEventHandler) then
                    -- register event handler
                    self:GetService(serviceName):RegisterEventHandler();
                end
            end
        end
    end);
end

--- Handle event.
-- @param name Event name.
-- @param callback Callback function, triggered on event.
function PlayerScores:HandleEvent(name, callback)
    -- check if event not handled before
    if (self.eventHandlers[name] == nil) then
        -- crete event handler array for the given event name
        self.eventHandlers[name] = {};

        -- watch event
        self.eventFrame:RegisterEvent(name);
    end

    -- add callback to event handler
    table.insert(self.eventHandlers[name], callback);
end

--- Create new addon.
-- @param name Addon name.
function PlayerScores:Create(name)
    -- create addon and add empty holders
    local playerScores = {
        name = name,
        version = GetAddOnMetadata(name, "version"), 
        serviceTypes = {},
        services = {}
    };
    setmetatable(playerScores, PlayerScores);

    -- create event handler
    playerScores:CreateEventHandler();

    -- addon created
    return playerScores;
end

-- define addon
_G.playerScores = PlayerScores:Create("PlayerScores");
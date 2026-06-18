local activeHeists = {}

--- Generate which containers are "real" for a session
local function generateSessionData(locationName)
    local loc = Config.Locations[locationName]
    local shuffled = Util.ShuffledTable(loc.containers)

    local realIds = {}
    for i = 1, 3 do -- 3 containers are real
        realIds[shuffled[i].id] = true
    end

    return realIds
end

lib.callback.register("heist:server:startHeist", function(source, locName)
    if activeHeists[locName] and os.time() < activeHeists[locName].cooldown then
        return false, HeistConstants.COOLDOWN_MESSAGE
    end

    local dutyCount = exports.qbx_core:GetDutyCountByType("leo")
    if dutyCount < Config.PoliceRequired then
        return false, HeistConstants.POLICE_MESSAGE
    end

    activeHeists[locName] = {
        realContainers = generateSessionData(locName),
        guardsSpawned = false,
        cooldown = os.time() + (Config.Cooldown * 60)
    }
    return true
end)

lib.callback.register("heist:server:checkContainer", function(source, locName, containerId)
    local heist = activeHeists[locName]
    if not heist then return false end
    
    return heist.realContainers[containerId] or false
end)

RegisterNetEvent("heist:server:giveLoot", function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end
    
    for _, item in ipairs(Config.Loot) do
        if math.random(100) <= item.chance then
            local amount = math.random(item.min, item.max)
            exports.ox_inventory:AddItem(src, item.name, amount)
        end
    end
end)

RegisterNetEvent("heist:server:alertPolice", function(coords)
    if Config.Dispatch == "cd_dispatch" then
        local data = exports["cd_dispatch"]:GetPlayerInfo()
        exports["cd_dispatch"]:TriggerDispatch({
            job = Config.PoliceJobs,
            coords = coords,
            message = "10-90: Container Yard Breach",
            dispatch_code = "10-90",
            description = "Suspicious activity reported at the docks.",
            radius = 0,
            sprite = 457,
            color = 1,
            scale = 1.0,
            priority = 2,
            has_mask = data.mask,
            street_1 = data.street,
            sex = data.sex,
            callsign = data.callsign,
        })
        return
    end

    local players = exports.qbx_core:GetPlayers()
    for _, player in pairs(players) do
        if player.PlayerData.job.type == "leo" or player.PlayerData.job.name == "police" then
            TriggerClientEvent("ox_lib:notify", player.PlayerData.source, {
                title = "10-90: Container Yard Breach",
                description = "Suspicious activity reported at the docks.",
                type = "warning"
            })
        end
    end
end)

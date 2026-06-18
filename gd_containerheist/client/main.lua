local currentHeist = nil
local spawnedGuards = {}

--- Handle the Gas Trap effect
local function triggerGasTrap()
    local ped = cache.ped
    lib.notify({ title = HeistConstants.GAS_TRAP_TITLE, description = HeistConstants.GAS_TRAP_DESC, type = "error" })
    
    CreateThread(function()
        local endTime = GetGameTimer() + (Config.GasDuration * 1000)
        AnimpostfxPlay("ChemicalWeaponOut", 0, true)
        while GetGameTimer() < endTime do
            SetEntityHealth(ped, GetEntityHealth(ped) - Config.GasDamage)
            ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 1.0)
            Wait(1000)
        end
        AnimpostfxStop("ChemicalWeaponOut")
        StopGameplayCamShaking(true)
    end)
end

--- Spawn Guards
local function spawnGuards(locName)
    local loc = Config.Locations[locName]
    
    for _, coords in ipairs(loc.guards) do
        lib.requestModel(Config.Guards.model)
        local guard = CreatePed(4, Config.Guards.model, coords.x, coords.y, coords.z, coords.w, true, false)
        
        SetPedRelationshipGroupHash(guard, `HATES_PLAYER`)
        GiveWeaponToPed(guard, Config.Guards.weapon, 250, false, true)
        SetPedAccuracy(guard, Config.Guards.accuracy)
        SetPedArmour(guard, Config.Guards.armor)
        SetEntityMaxHealth(guard, Config.Guards.health)
        SetEntityHealth(guard, Config.Guards.health)
        
        table.insert(spawnedGuards, guard)
    end
end

--- Breach Logic
local function breachContainer(locName, containerData)
    local hasGrinder = exports.ox_inventory:Search("count", Config.Items.grinder) > 0
    if not hasGrinder then 
        return lib.notify({ title = "Missing Tools", description = "You need an angle grinder.", type = "error" }) 
    end

    -- Alert Police on first breach
    TriggerServerEvent("heist:server:alertPolice", GetEntityCoords(cache.ped))

    if lib.progressBar({
        duration = 10000,
        label = HeistConstants.BREACH_LABEL,
        useWhileDead = false,
        canCancel = true,
        anim = { dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", clip = "machinic_loop_mechl" },
        prop = { model = `prop_tool_consdrill_01`, bone = 28422, pos = vec3(0,0,0), rot = vec3(0,0,0) }
    }) then
        local isReal = lib.callback.await("heist:server:checkContainer", false, locName, containerData.id)
        
        if isReal then
            lib.notify({ title = "Success", description = "Container cleared. Search for loot.", type = "success" })
            TriggerServerEvent("heist:server:giveLoot")
        else
            triggerGasTrap()
        end
    end
end

--- Start the heist at the manifest desk
local function interactManifest(locName)
    local success, err = lib.callback.await("heist:server:startHeist", false, locName)
    if not success then return lib.notify({ title = "Error", description = err, type = "error" }) end

    if lib.progressBar({
        duration = 5000,
        label = HeistConstants.MANIFEST_LABEL,
        useWhileDead = false,
        canCancel = true,
        anim = { dict = "missheistdockssetup1clipboard@base", clip = "base" },
        prop = { model = `prop_notepad_01`, bone = 18905, pos = vec3(0.1, 0.02, 0.05), rot = vec3(10, 0, 0) }
    }) then
        lib.notify({ title = "Intel Gathered", description = "Check the yard. Avoid the hazardous marks.", type = "inform" })
        spawnGuards(locName)
        currentHeist = locName
    end
end

-- Initialize Targets
CreateThread(function()
    for name, data in pairs(Config.Locations) do
        -- Manifest Target
        exports.ox_target:addBoxZone({
            coords = data.manifest.xyz,
            size = vec3(1, 1, 2),
            rotation = data.manifest.w,
            options = {
                {
                    label = "Secure Shipping Manifest",
                    icon = "fas fa-file-contract",
                    onSelect = function() interactManifest(name) end
                }
            }
        })

        -- Container Targets
        for _, container in ipairs(data.containers) do
            exports.ox_target:addBoxZone({
                coords = container.pos.xyz,
                size = vec3(3, 3, 4),
                rotation = container.pos.w,
                options = {
                    {
                        label = "Breach Container " .. container.id,
                        icon = "fas fa-screwdriver-wrench",
                        onSelect = function() breachContainer(name, container) end,
                        canInteract = function() return currentHeist == name end
                    }
                }
            })
        end
    end
end)

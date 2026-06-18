local currentHeist = nil
local spawnedGuards = {}
local yardBlip = nil
local manifestBlip = nil
local hasTalkedToNpc = false
local isBreaching = false

--- Create Blip for the container yard
local function createYardBlip(locName)
    local loc = Config.Locations[locName]
    if yardBlip then RemoveBlip(yardBlip) end

    yardBlip = AddBlipForCoord(loc.yard.x, loc.yard.y, loc.yard.z)
    SetBlipSprite(yardBlip, Config.Blips.yard.sprite)
    SetBlipScale(yardBlip, Config.Blips.yard.scale)
    SetBlipColour(yardBlip, Config.Blips.yard.color)
    SetBlipAsShortRange(yardBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Blips.yard.label)
    EndTextCommandSetBlipName(yardBlip)
    SetBlipRoute(yardBlip, true)
end

--- Create Blip for manifest location
local function createManifestBlip(locName)
    local loc = Config.Locations[locName]
    if manifestBlip then RemoveBlip(manifestBlip) end

    manifestBlip = AddBlipForCoord(loc.manifest.x, loc.manifest.y, loc.manifest.z)
    SetBlipSprite(manifestBlip, Config.Blips.manifest.sprite)
    SetBlipScale(manifestBlip, Config.Blips.manifest.scale)
    SetBlipColour(manifestBlip, Config.Blips.manifest.color)
    SetBlipAsShortRange(manifestBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Blips.manifest.label)
    EndTextCommandSetBlipName(manifestBlip)
    SetBlipRoute(manifestBlip, true)
end

--- Create Blip for NPC
local function createNpcBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.Blips.npc.sprite)
    SetBlipScale(blip, Config.Blips.npc.scale)
    SetBlipColour(blip, Config.Blips.npc.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Blips.npc.label)
    EndTextCommandSetBlipName(blip)
    return blip
end

--- Spawn Guards
local function spawnGuards(locName, type)
    local loc = Config.Locations[locName]
    local guardCoords = type == "office" and loc.officeGuards or loc.yardGuards
    
    for _, coords in ipairs(guardCoords) do
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
    if isBreaching then return end
    Util.Debug("Attempting to breach:", containerData.id, "at", locName)
    
    if not currentHeist and not Config.Debug then
        return lib.notify({ 
            title = "Locked", 
            description = "You need to secure the manifest from the office first to know which containers are worth breaching.", 
            type = "error" 
        })
    end

    local hasGrinder = exports.ox_inventory:Search("count", Config.Items.grinder) > 0
    if not hasGrinder and not Config.Debug then 
        return lib.notify({ title = "Missing Tools", description = "You need an angle grinder.", type = "error" }) 
    end

    isBreaching = true

    -- 1. Load Assets with validation
    lib.requestAnimDict("anim@heists@fleeca_bank@drilling")
    lib.requestModel(`hei_prop_heist_drill`)
    
    local soundBank = "DLC_HEIST_FLEECA_SOUNDSET"
    RequestScriptAudioBank(soundBank, false)
    
    local ptfxDict = "scr_heist_fleeca"
    local ptfxName = "scr_h_fleeca_drill_sparks"
    
    -- Try to load heist particles
    CreateThread(function()
        RequestNamedPtfxAsset(ptfxDict)
    end)

    local soundId = GetSoundId()
    local ptfxHandle = nil
    local active = true

    -- Alert Police on first breach
    TriggerServerEvent("heist:server:alertPolice", GetEntityCoords(cache.ped))

    -- 2. FX & Sound Management Thread
    CreateThread(function()
        -- Ensure animation has started before playing sound/FX
        local timeout = 0
        while not IsEntityPlayingAnim(cache.ped, "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 3) and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end

        if not active then return end

        Util.Debug("Triggering Drilling Audio and PTFX")

        -- Audio: Use Entity sound for 3D spatial effect
        PlaySoundFromEntity(soundId, "Drill", cache.ped, soundBank, true, 0)
        
        -- PTFX fallback logic
        local ptfxTimeout = 0
        while not HasNamedPtfxAssetLoaded(ptfxDict) and ptfxTimeout < 100 do
            Wait(10)
            ptfxTimeout = ptfxTimeout + 1
        end

        if not HasNamedPtfxAssetLoaded(ptfxDict) then
            ptfxDict = "core"
            ptfxName = "ent_dst_sparks" -- Standard sparks fallback
            RequestNamedPtfxAsset(ptfxDict)
            while not HasNamedPtfxAssetLoaded(ptfxDict) do Wait(0) end
        end

        UseParticleFxAssetNextCall(ptfxDict)
        local boneIndex = GetPedBoneIndex(cache.ped, 57005) -- SKEL_R_Hand
        -- Sparks at the drill bit (0.6 forward offset)
        ptfxHandle = StartParticleFxLoopedOnPedBone(ptfxName, cache.ped, 0.6, 0.05, 0.0, 0.0, 90.0, 0.0, boneIndex, 1.5, false, false, false)
    end)

    -- 3. Execution
    local success = lib.progressBar({
        duration = 15000,
        label = HeistConstants.BREACH_LABEL,
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true, mouse = false },
        anim = { 
            dict = "anim@heists@fleeca_bank@drilling", 
            clip = "drill_straight_idle",
            flag = 1 -- Loop + Upper Body + Block Movement
        },
        prop = { 
            model = `hei_prop_heist_drill`, 
            bone = 57005, 
            pos = vec3(0.12, 0.04, -0.01), 
            rot = vec3(-90.0, 90.0, 0.0) 
        }
    })

    -- 4. Cleanup
    active = false
    StopSound(soundId)
    ReleaseSoundId(soundId)
    if ptfxHandle then StopParticleFxLooped(ptfxHandle, false) end
    ClearPedTasks(cache.ped)

    if success then
        PlaySoundFrontend(-1, "Driller_Success", soundBank, 1)
        local skill = lib.skillCheck({ "easy", "easy", "easy" }, { "e", "e", "e", "e" })
        
        if skill then
            local result, message = lib.callback.await("heist:server:claimContainerLoot", false, locName, containerData.id)
            
            if result then
                lib.notify({ title = "Success", description = "Container cleared. Search for loot.", type = "success" })
            elseif message == "Already looted" then
                lib.notify({ title = "Empty", description = "This container has already been breached and looted.", type = "error" })
            elseif message == "empty" then
                lib.notify({ title = HeistConstants.FAILURE_TITLE, description = HeistConstants.FAILURE_DESC, type = "error" })
            else
                lib.notify({ title = "Error", description = message, type = "error" })
            end
        else
            lib.notify({ title = "Failed", description = "The drill bit snapped!", type = "error" })
        end
    else
        lib.notify({ title = "Cancelled", description = "You stopped drilling.", type = "inform" })
    end

    isBreaching = false
end

--- Start the heist at the manifest desk
local function interactManifest(locName)
    Util.Debug("Starting heist at:", locName)
    local success, err = lib.callback.await("heist:server:startHeist", false, locName)
    if not success and not Config.Debug then return lib.notify({ title = "Error", description = err, type = "error" }) end

    if lib.progressBar({
        duration = 5000,
        label = HeistConstants.MANIFEST_LABEL,
        useWhileDead = false,
        canCancel = true,
        anim = { dict = "missheistdockssetup1clipboard@base", clip = "base" },
        prop = { model = `prop_notepad_01`, bone = 18905, pos = vec3(0.1, 0.02, 0.05), rot = vec3(10, 0, 0) }
    }) then
        lib.notify({ title = "Intel Gathered", description = "Check the yard. Avoid Merryweather Guards", type = "inform" })
        if manifestBlip then
            RemoveBlip(manifestBlip)
            manifestBlip = nil
        end
        spawnGuards(locName, "yard")
        createYardBlip(locName)
        currentHeist = locName
    end
end

-- Debug Command to teleport to terminal
RegisterCommand("heistdebug_tp", function()
    if not Config.Debug then return end
    local coords = Config.Locations["elysian_island"].manifest
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z)
    SetEntityHeading(cache.ped, coords.w)
end, false)

-- Initialize Targets
CreateThread(function()
    for name, data in pairs(Config.Locations) do
        -- Information NPC
        if data.npc then
            lib.requestModel(`s_m_m_dockwork_01`)
            local npc = CreatePed(4, `s_m_m_dockwork_01`, data.npc.x, data.npc.y, data.npc.z, data.npc.w, false, false)
            FreezeEntityPosition(npc, true)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            createNpcBlip(data.npc.xyz)
            
            exports.ox_target:addLocalEntity(npc, {
                {
                    label = "Ask about manifest",
                    icon = "fas fa-question-circle",
                    onSelect = function()
                        if hasTalkedToNpc then 
                            return lib.notify({ title = "Dock Worker", description = "I already told you, check the office.", type = "inform" })
                        end
                        
                        lib.notify({
                            title = "Dock Worker",
                            description = "The manifest? It's inside the office, sitting right on the desk. Watch out for the Merryweather goons nearby.",
                            type = "inform"
                        })
                        hasTalkedToNpc = true
                        createManifestBlip(name)
                        spawnGuards(name, "office")
                    end
                }
            })
        end

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

        -- Container Targets and Prop Spawning
        for _, container in ipairs(data.containers) do
            lib.requestModel(Config.ContainerModel)
            local containerProp = CreateObject(Config.ContainerModel, container.pos.x, container.pos.y, container.pos.z - 1.0, false, false, false)
            SetEntityHeading(containerProp, container.pos.w)
            FreezeEntityPosition(containerProp, true)

            exports.ox_target:addLocalEntity(containerProp, {
                {
                    label = "Breach Container " .. container.id,
                    icon = "fas fa-screwdriver-wrench",
                    onSelect = function() breachContainer(name, container) end,
                }
            })
        end
    end
end)

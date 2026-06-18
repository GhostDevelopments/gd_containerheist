Config = {}

Config.PoliceRequired = 2
Config.PoliceJobs = { "police", "sheriff" }
Config.Cooldown = 60 -- Minutes
Config.Dispatch = "cd_dispatch" -- "cd_dispatch" or "basic"

Config.Items = {
    manifest = "shipping_manifest",
    grinder = "angle_grinder",
}

Config.Loot = {
    { name = "markedbills", min = 1500, max = 3000, chance = 100 },
    { name = "goldbar", min = 1, max = 3, chance = 40 },
    { name = "rolex", min = 2, max = 5, chance = 60 },
    { name = "diamond_ring", min = 1, max = 4, chance = 30 },
}

Config.Guards = {
    model = `s_m_m_marine_01`,
    weapon = `WEAPON_CARBINERIFLE`,
    health = 200,
    armor = 100,
    accuracy = 60,
}

Config.GasDamage = 5 -- Health per tick
Config.GasDuration = 10 -- Seconds

Config.Locations = {
    ["terminal"] = {
        manifest = vector4(1210.5, -3005.2, 5.8, 270.0),
        yard = vector3(1185.0, -3112.0, 6.0),
        containers = {
            { pos = vector4(1178.5, -3105.0, 6.0, 90.0), id = "A1" },
            { pos = vector4(1185.5, -3105.0, 6.0, 90.0), id = "A2" },
            { pos = vector4(1192.5, -3105.0, 6.0, 90.0), id = "A3" },
            { pos = vector4(1178.5, -3115.0, 6.0, 90.0), id = "B1" },
            { pos = vector4(1185.5, -3115.0, 6.0, 90.0), id = "B2" },
            { pos = vector4(1192.5, -3115.0, 6.0, 90.0), id = "B3" },
            { pos = vector4(1178.5, -3125.0, 6.0, 90.0), id = "C1" },
            { pos = vector4(1185.5, -3125.0, 6.0, 90.0), id = "C2" },
        },
        guards = {
            vector4(1170.0, -3100.0, 6.0, 180.0),
            vector4(1200.0, -3100.0, 6.0, 180.0),
            vector4(1185.0, -3130.0, 6.0, 0.0),
        }
    }
}
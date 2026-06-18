Config = {}
Config.Debug = true -- Set to true to enable debug commands and prints

Config.PoliceRequired = 2
Config.PoliceJobs = { "police", "sheriff" }
Config.Cooldown = 60 -- Minutes
Config.Dispatch = "cd_dispatch" -- "cd_dispatch" or "basic"

Config.Items = {
    manifest = "shipping_manifest",
    grinder = "drill",
}

Config.Loot = {
    { name = "black_money", min = 1500, max = 3000, chance = 100 },
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

Config.ContainerModel = `prop_container_05a`
Config.RealContainersCount = 6 -- Out of 8 containers, how many should be "real"

Config.Blips = {
    npc = {
        sprite = 480,
        color = 5,
        scale = 0.8,
        label = "Container Contract"
    },
    yard = {
        sprite = 677,
        color = 1,
        scale = 0.8,
        label = "Container Yard"
    },
    manifest = {
        sprite = 525,
        color = 3,
        scale = 0.7,
        label = "Manifest"
    }
}

Config.Locations = {
    ["elysian_island"] = {
        npc = vector4(714.42, -976.57, 23.13, 182.12),
        manifest = vector4(706.87, -967.71, 30.39, 95.13),
        yard = vector3(-404.92, -2701.35, 6.0),
        containers = {
            { pos = vector4(-392.14, -2695.87, 6.0, 90.0), id = "X1" },
            { pos = vector4(-392.14, -2701.87, 6.0, 90.0), id = "X2" },
            { pos = vector4(-392.14, -2707.87, 6.0, 90.0), id = "X3" },
            { pos = vector4(-392.14, -2713.87, 6.0, 90.0), id = "X4" },
            { pos = vector4(-408.14, -2695.87, 6.0, 90.0), id = "Y1" },
            { pos = vector4(-408.14, -2701.87, 6.0, 90.0), id = "Y2" },
            { pos = vector4(-408.14, -2707.87, 6.0, 90.0), id = "Y3" },
            { pos = vector4(-408.14, -2713.87, 6.0, 90.0), id = "Y4" },
        },
        officeGuards = {
            vector4(707.99, -965.83, 29.4, 7.12),
            vector4(705.9, -965.69, 29.41, 333.74),
            vector4(713.44, -964.14, 29.4, 252.31),
            vector4(718.16, -959.47, 29.4, 181.15),
            vector4(719.94, -966.09, 29.4, 23.13),
            vector4(720.04, -974.35, 23.91, 86.68),
        },
        yardGuards = {
            vector4(-385.0, -2690.0, 6.0, 225.0),
            vector4(-415.0, -2720.0, 6.0, 45.0),
            vector4(-400.0, -2705.0, 6.0, 180.0),
        }
    }
}

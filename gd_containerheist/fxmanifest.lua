fx_version "cerulean"
game "gta5"

author "GhostDevelopments"
description "Intel-and-Extraction Container Heist | Generated with GhostDevelopments - https://ghost.dev"
version "1.0.0"

dependencies {
    "qbx_core",
    "ox_lib",
    "ox_inventory",
    "ox_target"
}

shared_scripts {
    "@ox_lib/init.lua",
    "shared/enum.lua",
    "shared/util.lua",
    "config/main.lua"
}

client_scripts {
    "client/main.lua"
}

server_scripts {
    "server/main.lua"
}

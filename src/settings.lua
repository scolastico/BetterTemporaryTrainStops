data:extend({
    {
        type = "int-setting",
        name = "btts-every-x-ticks",
        setting_type = "runtime-global",
        default_value = 30,
        minimum_value = 1,
        maximum_value = 900
    },
    {
        type = "int-setting",
        name = "btts-timout-ticks",
        setting_type = "runtime-global",
        default_value = 3600,
        minimum_value = 300,
        maximum_value = 216000
    },
    {
        type = "int-setting",
        name = "btts-search-radius",
        setting_type = "runtime-global",
        default_value = 50,
        minimum_value = 1,
        maximum_value = 10000
    },
    {
        type = "bool-setting",
        name = "btts-enabled-only-in-personal-train",
        setting_type = "runtime-global",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "btts-enabled",
        setting_type = "runtime-per-user",
        default_value = true
    }
})

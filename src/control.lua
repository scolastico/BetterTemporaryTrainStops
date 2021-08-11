require('__BetterTemporaryTrainStops__/scripts/helper')

default_wait_conditions = {{type="inactivity", compare_type="and", ticks=900},{type="passenger_present", compare_type="and"}}
last_run = 0
ignored_trains = {}
personal_train_change = {}

script.on_load(function()
    last_run = 0
    ignored_trains = {}
    personal_train_change = {}
end)

script.on_event(defines.events.on_tick, function(event)
    if last_run >= settings.global["btts-every-x-ticks"].value then
        last_run = 0
        for _, surface in pairs(game.surfaces) do
            for _, train in pairs(surface.get_trains()) do
                if #train.passengers > 0 and train.state == defines.train_state.arrive_station then
                    table.insert(ignored_trains, train.id)
                    for _, player in pairs(train.passengers) do
                        if player.mod_settings["btts-enabled"].value then
                            local schedule = train.schedule
                            if schedule ~= nil and #schedule.records > 0 and schedule.current ~= nil then
                                if schedule.records[schedule.current].temporary == true and is_default_hold_condition(schedule.records[schedule.current].wait_conditions) then
                                    local player_id = get_player_id(player)
                                    local settings_prefix = "btts-player-settings-" .. tostring(player_id) .. "-"
                                    if settings.global["btts-enabled-only-in-personal-train"].value then
                                        if global[settings_prefix .. "train"] ~= train.id then goto continue end
                                    end
                                    if global[settings_prefix .. "conditions"] == nil then
                                        schedule.records[schedule.current].wait_conditions = default_wait_conditions
                                    else
                                        schedule.records[schedule.current].wait_conditions = global[settings_prefix .. "conditions"]
                                    end
                                    train.schedule = schedule
                                end
                            end
                            break
                        end
                        ::continue::
                    end
                elseif train.state ~= defines.train_state.wait_station then
                    table.remove(ignored_trains, train.id)
                end
            end
        end
    end
    last_run = last_run + 1
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "btts-call-train" then
        local player_id = event.player_index
        local player = game.players[player_id]
        local train = get_train_from_player(player)
        local settings_prefix = "btts-player-settings-" .. tostring(player_id) .. "-"
        local player_train_id = global[settings_prefix .. "train"]
        if train == nil then
            if player_train_id == nil then
                player.print({
                    "better-temporary-train-stops.no-personal-train",
                    {"better-temporary-train-stops.prefix"}
                })
            else
                train = get_train_from_id(player_train_id)
                if train == nil then
                    player.print({
                        "better-temporary-train-stops.not-existing",
                        {"better-temporary-train-stops.prefix"}
                    })
                    global[settings_prefix .. "train"] = nil
                else
                    local rails = player.surface.find_entities_filtered{
                        position=player.character.position,
                        radius=settings.global["btts-search-radius"].value,
                        type={"straight-rail", "curved-rail"},
                        force=player.force
                    }
                    if #rails == 0 then
                        player.print({
                            "better-temporary-train-stops.no-rails",
                            {"better-temporary-train-stops.prefix"}
                        })
                    else
                        local closest = player.surface.get_closest(player.character.position, rails)
                        local schedule = train.schedule
                        local wait_conditions = default_wait_conditions
                        if global[settings_prefix .. "conditions"] ~= nil then
                            wait_conditions = global[settings_prefix .. "conditions"]
                        end
                        if not schedule then
                            schedule = {
                                current = 1,
                                records = {}
                            }
                        end
                        table.insert(schedule.records, schedule.current, {
                            station=nil,
                            rail=closest,
                            wait_conditions=wait_conditions,
                            temporary=true
                        })
                        train.schedule = schedule
                        train.manual_mode = false
                        player.print({
                            "better-temporary-train-stops.train-called",
                            {"better-temporary-train-stops.prefix"},
                            "[gps=" .. tostring(closest.position.x) .. "," .. tostring(closest.position.y) .. "," .. closest.surface.name .. "]"
                        })
                    end
                end
            end
        else
            if train.id == player_train_id then
                local last_personal_train_change = personal_train_change[player_id]
                if (last_personal_train_change == nil) or (game.tick - last_personal_train_change > settings.global["btts-timout-ticks"].value) then
                    player.print({
                        "better-temporary-train-stops.already-personal-train",
                        {"better-temporary-train-stops.prefix"},
                        {"better-temporary-train-stops.press-again"}
                    })
                else
                    local schedule = train.schedule
                    global[settings_prefix .. "conditions"] = schedule.records[schedule.current].wait_conditions
                    player.print({
                        "better-temporary-train-stops.changed-conditions",
                        {"better-temporary-train-stops.prefix"},
                        serpent.dump(global[settings_prefix .. "conditions"])
                    })
                end
            else
                player.print({
                    "better-temporary-train-stops.changed-personal-train",
                    {"better-temporary-train-stops.prefix"},
                    {"better-temporary-train-stops.press-again"}
                })
                global[settings_prefix .. "train"] = train.id
            end
            personal_train_change[player_id] = game.tick
        end
    end
end)

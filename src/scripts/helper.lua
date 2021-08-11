function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function get_train_from_player (player)
    for _, surface in pairs(game.surfaces) do
        for _, train in pairs(surface.get_trains()) do
            if #train.passengers > 0 then
                for _, passenger in pairs(train.passengers) do
                    if passenger == player then
                        return train
                    end
                end
            end
        end
    end
    return nil
end

function get_train_from_id (id)
    for _, surface in pairs(game.surfaces) do
        for _, train in pairs(surface.get_trains()) do
            if train.id == id then
                return train
            end
        end
    end
    return nil
end

function get_player_id (player)
    for id, p in pairs(game.players) do
        if p == player then
            return id
        end
    end
    return nil
end

function is_default_hold_condition (hold_conditions)
    if #hold_conditions < 1 or #hold_conditions > 1 then return false end
    local condition = hold_conditions[1]
    if condition.compare_type ~= "or" then return false end
    if condition.type ~= "time" then return false end
    if condition.ticks ~= 300 then return false end
    return true
end

function get_rank(user_id, chat_id, check_local, no_log)
    if tonumber(user_id) ~= tonumber(chat_id) then
        -- if get_rank in a group check only in that group
        if is_mod2(user_id, chat_id, check_local, no_log) then
            if is_owner2(user_id, chat_id, check_local, no_log) then
                if is_admin2(user_id) then
                    if is_sudo2(user_id) then
                        if tonumber(bot.id) == tonumber(user_id) then
                            -- bot
                            return rank_table["BOT"]
                        else
                            -- sudo
                            return rank_table["SUDO"]
                        end
                    else
                        -- admin
                        return rank_table["ADMIN"]
                    end
                else
                    -- owner
                    return rank_table["OWNER"]
                end
            else
                -- mod
                return rank_table["MOD"]
            end
        else
            -- user
            return rank_table["USER"]
        end
    else
        -- if get_rank in private check the higher rank of the user in all groups
        if tonumber(bot.id) == tonumber(user_id) then
            -- bot
            return rank_table["BOT"]
        else
            if is_sudo2(user_id) then
                -- sudo
                return rank_table["SUDO"]
            else
                if is_admin2(user_id) then
                    -- admin
                    return rank_table["ADMIN"]
                else
                    local higher_rank = rank_table["USER"]
                    if data['groups'] then
                        -- if there are any groups check for everyone of them the rank of the user and choose the higher one
                        for id_string in pairs(data['groups']) do
                            if is_mod2(user_id, id_string, check_local, no_log) then
                                if is_owner2(user_id, id_string, check_local, no_log) then
                                    -- owner
                                    if higher_rank < rank_table["OWNER"] then
                                        higher_rank = rank_table["OWNER"]
                                    end
                                    -- not higher than owner or it would not be here
                                    break
                                else
                                    -- mod
                                    if higher_rank < rank_table["MOD"] then
                                        higher_rank = rank_table["MOD"]
                                    end
                                end
                            else
                                -- user
                                if higher_rank < rank_table["USER"] then
                                    higher_rank = rank_table["USER"]
                                end
                            end
                        end
                    end
                    return higher_rank
                end
            end
        end
    end
end

function compare_ranks(executer, target, chat_id, check_local, no_log)
    local executer_rank = get_rank(executer, chat_id, check_local, no_log)
    local target_rank = get_rank(target, chat_id, check_local, no_log)
    if executer_rank > target_rank then
        return true
    elseif executer_rank <= target_rank then
        return false
    end
end

-- function to know if bot is admin in the group
function is_bot_admin(chat_id)
    local res = getChatMember(chat_id, bot.id)
    if type(res) == 'table' then
        if res.result then
            local status = res.result.status
            if status == 'administrator' then
                return true
            end
        end
    end
    return false
end

function is_sudo(param_msg)
    if tonumber(bot.id) == tonumber(user_id) then
        -- bot
        return true
    end

    local var = false
    -- Check users id in config
    for k, v in pairs(config.sudo_users) do
        if tostring(k) == tostring(param_msg.from.id) then
            -- bot sudo
            var = true
        end
    end
    return var
end

function is_sudo2(user_id)
    if tonumber(bot.id) == tonumber(user_id) then
        -- bot
        return true
    end

    local var = false
    -- Check users id in config
    for k, v in pairs(config.sudo_users) do
        if tostring(k) == tostring(user_id) then
            -- bot sudo
            var = true
        end
    end
    return var
end

function is_admin(param_msg)
    if tonumber(bot.id) == tonumber(user_id) then
        -- bot
        return true
    end

    local var = false
    local user_id = param_msg.from.id

    if data.admins then
        if data.admins[tostring(user_id)] then
            -- bot admin
            var = true
        end
    end

    if is_sudo(param_msg) then
        -- bot sudo
        var = true
    end

    -- check if executing a fakecommand, if yes confirm
    if tonumber(user_id) <= -3 then
        var = true
    end
    return var
end

function is_admin2(user_id)
    if tonumber(bot.id) == tonumber(user_id) then
        -- bot
        return true
    end

    local var = false

    if data.admins then
        if data.admins[tostring(user_id)] then
            -- bot admin
            var = true
        end
    end

    if is_sudo2(user_id) then
        -- bot sudo
        var = true
    end

    -- check if executing a fakecommand, if yes confirm
    if tonumber(user_id) <= -3 then
        var = true
    end
    return var
end

function is_owner(param_msg, check_local)
    if tonumber(bot.id) == tonumber(user_id) then
        -- bot
        return true
    end

    local var = false
    local user_id = param_msg.from.id
    local chat_id = param_msg.chat.id

    if not check_local then
        local res = getChatMember(chat_id, user_id)
        if type(res) == 'table' then
            if res.result then
                local status = res.result.status
                if status == 'creator' then
                    -- owner
                    var = true
                end
            end
        end
    end

    if data[tostring(chat_id)] then
        if data[tostring(chat_id)].owner then
            if data[tostring(chat_id)].owner == tostring(user_id) then
                -- owner
                var = true
            end
        end
    end

    if is_admin(param_msg) then
        -- bot admin
        var = true
    end

    if is_sudo(param_msg) then
        -- bot sudo
        var = true
    end

    -- check if executing a fakecommand, if yes confirm
    if tonumber(user_id) <= -2 then
        var = true
    end
    return var
end

function is_owner2(user_id, chat_id, check_local, no_log)
    if tonumber(bot.id) == tonumber(user_id) then
        -- bot
        return true
    end

    local var = false

    if not check_local then
        local res = getChatMember(chat_id, user_id, no_log)
        if type(res) == 'table' then
            if res.result then
                local status = res.result.status
                if status == 'creator' then
                    -- owner
                    var = true
                end
            end
        end
    end

    if data[tostring(chat_id)] then
        if data[tostring(chat_id)].owner then
            if data[tostring(chat_id)].owner == tostring(user_id) then
                -- owner
                var = true
            end
        end
    end

    if is_admin2(user_id) then
        -- bot admin
        var = true
    end

    if is_sudo2(user_id) then
        -- bot sudo
        var = true
    end

    -- check if executing a fakecommand, if yes confirm
    if tonumber(user_id) <= -2 then
        var = true
    end
    return var
end

function is_mod(param_msg, check_local)
    if tonumber(bot.id) == tonumber(user_id) then
        -- bot
        return true
    end

    local var = false
    local user_id = param_msg.from.id
    local chat_id = param_msg.chat.id

    if not check_local then
        local res = getChatMember(chat_id, user_id)
        if type(res) == 'table' then
            if res.result then
                local status = res.result.status
                if status == 'administrator' then
                    -- mod
                    var = true
                end
                if status == 'creator' then
                    -- owner
                    var = true
                end
            end
        end
    end

    if data[tostring(chat_id)] then
        if data[tostring(chat_id)].moderators then
            if data[tostring(chat_id)].moderators[tostring(user_id)] then
                -- mod
                var = true
            end
        end
    end

    if is_owner(param_msg, check_local) then
        -- owner
        var = true
    end

    if is_admin(param_msg) then
        -- bot admin
        var = true
    end

    if is_sudo(param_msg) then
        -- bot sudo
        var = true
    end

    -- check if executing a fakecommand, if yes confirm
    if tonumber(user_id) <= -1 then
        var = true
    end
    return var
end

function is_mod2(user_id, chat_id, check_local, no_log)
    if tonumber(bot.id) == tonumber(user_id) then
        -- bot
        return true
    end

    local var = false

    if not check_local then
        local res = getChatMember(chat_id, user_id, no_log)
        if type(res) == 'table' then
            if res.result then
                local status = res.result.status
                if status == 'administrator' then
                    -- mod
                    var = true
                end
                if status == 'creator' then
                    -- owner
                    var = true
                end
            end
        end
    end

    if data[tostring(chat_id)] then
        if data[tostring(chat_id)].moderators then
            if data[tostring(chat_id)].moderators[tostring(user_id)] then
                -- mod
                var = true
            end
        end
    end

    if is_owner2(user_id, chat_id, check_local, no_log) then
        -- owner
        var = true
    end

    if is_admin2(user_id) then
        -- bot admin
        var = true
    end

    if is_sudo2(user_id) then
        -- bot sudo
        var = true
    end

    -- check if executing a fakecommand, if yes confirm
    if tonumber(user_id) <= -1 then
        var = true
    end
    return var
end

function get_tg_rank(param_msg)
    -- commented because it slows down the whole process of receiving messages
    --[[local res = getChatMember(param_msg.chat.id, param_msg.from.id)
    if type(res) == 'table' then
        if res.result then
            local status = res.result.status
            if status == 'administrator' or is_mod(param_msg, true) then
                -- mod
                param_msg.from.is_mod = true
            end
            if status == 'creator' or is_owner(param_msg, true) then
                -- owner
                param_msg.from.is_mod = true
                param_msg.from.is_owner = true
            end
        end
    end
    if type(param_msg.from.is_mod) == 'nil' then]]
    if is_owner(param_msg, true) then
        param_msg.from.is_mod = true
        param_msg.from.is_owner = true
    end
    if is_mod(param_msg, true) then
        param_msg.from.is_mod = true
    end
    -- end
    return param_msg
end
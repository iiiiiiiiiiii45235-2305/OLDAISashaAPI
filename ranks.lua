rank_table = { ["USER"] = 0, ["MOD"] = 1, ["OWNER"] = 2, ["ADMIN"] = 3, ["SUDO"] = 4, ["BOT"] = 5 }
reverse_rank_table = { "USER", "MOD", "OWNER", "ADMIN", "SUDO", "BOT" }

function get_rank(user_id, chat_id, check_local)
    if tonumber(user_id) ~= tonumber(chat_id) then
        -- if get_rank in a group check only in that group
        if tonumber(bot.id) ~= tonumber(user_id) then
            if not is_sudo2(user_id) then
                if not is_admin2(user_id) then
                    if not is_owner2(user_id, chat_id, check_local) then
                        if not is_mod2(user_id, chat_id, check_local) then
                            -- user
                            return rank_table["USER"]
                        else
                            -- mod
                            return rank_table["MOD"]
                        end
                    else
                        -- owner
                        return rank_table["OWNER"]
                    end
                else
                    -- admin
                    return rank_table["ADMIN"]
                end
            else
                -- sudo
                return rank_table["SUDO"]
            end
        else
            -- bot
            return rank_table["BOT"]
        end
    else
        -- if get_rank in private check the higher rank of the user in all groups
        if tonumber(bot.id) ~= tonumber(user_id) then
            if not is_sudo2(user_id) then
                if not is_admin2(user_id) then
                    local higher_rank = rank_table["USER"]
                    if data['groups'] then
                        -- if there are any groups check for everyone of them the rank of the user and choose the higher one
                        for id_string in pairs(data['groups']) do
                            if not is_owner2(user_id, id_string, check_local) then
                                if not is_mod2(user_id, id_string, check_local) then
                                    -- user
                                    if higher_rank < rank_table["USER"] then
                                        higher_rank = rank_table["USER"]
                                    end
                                else
                                    -- mod
                                    if higher_rank < rank_table["MOD"] then
                                        higher_rank = rank_table["MOD"]
                                    end
                                end
                            else
                                -- owner
                                if higher_rank < rank_table["OWNER"] then
                                    higher_rank = rank_table["OWNER"]
                                end
                            end
                        end
                    end
                    return higher_rank
                else
                    -- admin
                    return rank_table["ADMIN"]
                end
            else
                -- sudo
                return rank_table["SUDO"]
            end
        else
            -- bot
            return rank_table["BOT"]
        end
    end
end

function compare_ranks(executer, target, chat_id, check_local)
    local executer_rank = get_rank(executer, chat_id, check_local)
    local target_rank = get_rank(target, chat_id, check_local)
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

function is_sudo(msg)
    local var = false
    -- Check users id in config
    for v, user in pairs(sudoers) do
        if tostring(user.id) == tostring(msg.from.id) then
            -- bot sudo
            var = true
        end
    end
    return var
end

function is_sudo2(user_id)
    local var = false
    -- Check users id in config
    for v, user in pairs(sudoers) do
        if tostring(user.id) == tostring(user_id) then
            -- bot sudo
            var = true
        end
    end
    return var
end

function is_admin(msg)
    local var = false
    local user_id = msg.from.id
    local admins = 'admins'
    if data[tostring(admins)] then
        if data[tostring(admins)][tostring(user_id)] then
            -- bot admin
            var = true
        end
    end

    if is_sudo(msg) then
        -- bot sudo
        var = true
    end

    -- check if executing a fakecommand, if yes confirm
    if tostring(user_id) == '*3' then
        var = true
    end
    return var
end

function is_admin2(user_id)
    local var = false
    local admins = 'admins'
    if data[tostring(admins)] then
        if data[tostring(admins)][tostring(user_id)] then
            -- bot admin
            var = true
        end
    end

    if is_sudo2(user_id) then
        -- bot sudo
        var = true
    end

    -- check if executing a fakecommand, if yes confirm
    if tostring(user_id) == '*3' then
        var = true
    end
    return var
end

function is_owner(msg, check_local)
    local var = false
    local user_id = msg.from.id
    local chat_id = msg.chat.id

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
        if data[tostring(chat_id)]['set_owner'] then
            if data[tostring(chat_id)]['set_owner'] == tostring(user_id) then
                -- owner
                var = true
            end
        end
    end

    if is_admin(msg) then
        -- bot admin
        var = true
    end

    if is_sudo(msg) then
        -- bot sudo
        var = true
    end

    -- check if executing a fakecommand, if yes confirm
    if tostring(user_id) == '*2' then
        var = true
    end
    if tostring(user_id) == '*3' then
        var = true
    end
    return var
end

function is_owner2(user_id, chat_id, check_local)
    local var = false

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
        if data[tostring(chat_id)]['set_owner'] then
            if data[tostring(chat_id)]['set_owner'] == tostring(user_id) then
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
    if tostring(user_id) == '*2' then
        var = true
    end
    if tostring(user_id) == '*3' then
        var = true
    end
    return var
end

function is_mod(msg, check_local)
    local var = false
    local user_id = msg.from.id
    local chat_id = msg.chat.id

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
        if data[tostring(chat_id)]['moderators'] then
            if data[tostring(chat_id)]['moderators'][tostring(user_id)] then
                -- mod
                var = true
            end
        end
    end

    if is_owner(msg, check_local) then
        -- owner
        var = true
    end

    if is_admin(msg) then
        -- bot admin
        var = true
    end

    if is_sudo(msg) then
        -- bot sudo
        var = true
    end

    -- check if executing a fakecommand, if yes confirm
    if tostring(user_id) == '*1' then
        var = true
    end
    if tostring(user_id) == '*2' then
        var = true
    end
    if tostring(user_id) == '*3' then
        var = true
    end
    return var
end

function is_mod2(user_id, chat_id, check_local)
    local var = false

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
        if data[tostring(chat_id)]['moderators'] then
            if data[tostring(chat_id)]['moderators'][tostring(user_id)] then
                -- mod
                var = true
            end
        end
    end

    if is_owner2(user_id, chat_id, check_local) then
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
    if tostring(user_id) == '*1' then
        var = true
    end
    if tostring(user_id) == '*2' then
        var = true
    end
    if tostring(user_id) == '*3' then
        var = true
    end
    return var
end

function get_tg_rank(msg)
    -- commented because it slows down the whole process of receiving messages
    --[[local res = getChatMember(msg.chat.id, msg.from.id)
    if type(res) == 'table' then
        if res.result then
            local status = res.result.status
            if status == 'administrator' or is_mod(msg, true) then
                -- mod
                msg.from.is_mod = true
            end
            if status == 'creator' or is_owner(msg, true) then
                -- owner
                msg.from.is_mod = true
                msg.from.is_owner = true
            end
        end
    end
    if type(msg.from.is_mod) == 'nil' then]]
    if is_owner(msg, true) then
        msg.from.is_mod = true
        msg.from.is_owner = true
    end
    if is_mod(msg, true) then
        msg.from.is_mod = true
    end
    -- end
    return msg
end
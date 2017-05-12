-- Returns the key (index) in the config.enabled_plugins table
local function plugin_enabled(plugin_name)
    for k, v in pairs(config.enabled_plugins) do
        if plugin_name == v then
            return k
        end
    end
    return false
end

-- Returns true if file exists in plugins folder
local function plugin_exists(plugin_name)
    for k, v in pairs(plugins_names()) do
        if plugin_name .. '.lua' == v then
            return true
        end
    end
    return false
end

-- Returns true if it is a system plugin
local function system_plugin(p)
    if p == 'administrator' or
        p == 'anti_spam' or
        p == 'banhammer' or
        p == 'bot' or
        p == 'broadcast' or
        p == 'check_tag' or
        p == 'database' or
        p == 'feedback' or
        p == 'filemanager' or
        p == 'goodbyewelcome' or
        p == 'group_management' or
        p == 'info' or
        p == 'lua_exec' or
        p == 'msg_checks' or
        p == 'onservice' or
        p == 'plugins' or
        p == 'strings' or
        p == 'tgcli_to_api_migration' or
        p == 'todo' or
        p == 'whitelist' then
        return true
    end
    return false
end

local function plugin_disabled_on_chat(plugin_name, chat_id)
    if not config.disabled_plugin_on_chat then
        return false
    end
    if not config.disabled_plugin_on_chat[chat_id] then
        return false
    end
    return config.disabled_plugin_on_chat[chat_id][plugin_name]
end

local function list_plugins_sudo()
    local text = ''
    for k, v in pairs(plugins_names()) do
        --  ✅ enabled, 🚫 disabled
        local status = '🚫'
        -- get the name
        v = string.match(v, "(.*)%.lua")
        -- Check if enabled
        if plugin_enabled(v) then
            status = '✅'
        end
        -- Check if system plugin
        if system_plugin(v) then
            status = '💻'
        end
        text = text .. k .. '. ' .. status .. ' ' .. v .. '\n'
    end
    return text
end

local function list_plugins(chat_id)
    local text = ''
    for k, v in pairs(plugins_names()) do
        --  ✅ enabled, 🚫 disabled
        local status = '🚫'
        -- get the name
        v = string.match(v, "(.*)%.lua")
        -- Check if is enabled
        if plugin_enabled(v) then
            status = '✅'
        end
        -- Check if system plugin, if not check if disabled on chat
        if system_plugin(v) then
            status = '💻'
        elseif plugin_disabled_on_chat(v, chat_id) then
            status = '❌'
        end
        text = text .. k .. '. ' .. status .. ' ' .. v .. '\n'
    end
    return text
end

local function reload_plugins()
    plugins = { }
    load_plugins()
    return list_plugins_sudo()
end

local function enable_plugin(plugin_name, chat_id)
    local lang = get_lang(chat_id)
    -- Check if plugin is enabled
    if plugin_enabled(plugin_name) then
        return '✔️ ' .. plugin_name .. langs[lang].alreadyEnabled
    end
    -- Checks if plugin exists
    if plugin_exists(plugin_name) then
        -- Add to the config table
        table.insert(config.enabled_plugins, plugin_name)
        print(plugin_name .. ' added to config table')
        save_config()
        -- Reload the plugins
        reload_plugins()
        return '✅ ' .. plugin_name .. langs[lang].enabled
    else
        return '❔ ' .. plugin_name .. langs[lang].notExists
    end
end

local function disable_plugin(plugin_name, chat_id)
    local lang = get_lang(chat_id)
    -- Check if plugins exists
    if not plugin_exists(plugin_name) then
        return '❔ ' .. plugin_name .. langs[lang].notExists
    end
    local k = plugin_enabled(plugin_name)
    -- Check if plugin is enabled
    if not k then
        return '✖️ ' .. plugin_name .. langs[lang].alreadyDisabled
    end
    -- Disable and reload
    table.remove(config.enabled_plugins, k)
    save_config()
    reload_plugins()
    return '🚫 ' .. plugin_name .. langs[lang].disabled
end

local function disable_plugin_on_chat(plugin_name, chat_id)
    local lang = get_lang(chat_id)
    if not plugin_exists(plugin_name) then
        return '❔ ' .. plugin_name .. langs[lang].notExists
    end

    if not config.disabled_plugin_on_chat then
        config.disabled_plugin_on_chat = { }
    end

    if not config.disabled_plugin_on_chat[chat_id] then
        config.disabled_plugin_on_chat[chat_id] = { }
    end

    config.disabled_plugin_on_chat[chat_id][plugin_name] = true

    save_config()
    return '❌ ' .. plugin_name .. langs[lang].disabledOnChat
end

local function reenable_plugin_on_chat(plugin_name, chat_id)
    local lang = get_lang(chat_id)
    if not config.disabled_plugin_on_chat then
        return langs[lang].noDisabledPlugin
    end

    if not config.disabled_plugin_on_chat[chat_id] then
        return langs[lang].noDisabledPlugin
    end

    if not config.disabled_plugin_on_chat[chat_id][plugin_name] then
        return langs[lang].pluginNotDisabled
    end

    config.disabled_plugin_on_chat[chat_id][plugin_name] = false
    save_config()
    return '✅ ' .. plugin_name .. langs[lang].pluginEnabledAgain
end

local function list_disabled_plugin_on_chat(chat_id)
    local lang = get_lang(chat_id)
    if not config.disabled_plugin_on_chat then
        return langs[lang].noDisabledPlugin
    end

    if not config.disabled_plugin_on_chat[chat_id] then
        return langs[lang].noDisabledPlugin
    end

    local status = '❌'
    local text = ''
    for k in pairs(config.disabled_plugin_on_chat[chat_id]) do
        if config.disabled_plugin_on_chat[chat_id][k] == true then
            text = text .. status .. ' ' .. k .. '\n'
        end
    end
    return text
end

local function keyboard_plugins_list(user_id, privileged, chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local flag = false
    keyboard.inline_keyboard[row] = { }
    for k, name in pairs(plugins_names()) do
        --  ✅ enabled, 🚫 disabled
        local status = '🚫'
        local enabled = false
        -- get the name
        name = string.match(name, "(.*)%.lua")
        -- Check if is enabled
        if plugin_enabled(name) then
            status = '✅'
            enabled = true
        end
        -- Check if system plugin, if not check if disabled on chat
        if system_plugin(name) then
            status = '💻'
        elseif not privileged then
            if plugin_disabled_on_chat(name, chat_id) then
                status = '❌'
                enabled = false
            end
        end
        if flag then
            flag = false
            row = row + 1
            column = 1
            keyboard.inline_keyboard[row] = { }
        end
        if enabled then
            keyboard.inline_keyboard[row][column] = { text = status .. ' ' .. name, callback_data = 'pluginsDISABLE' .. name }
        else
            keyboard.inline_keyboard[row][column] = { text = status .. ' ' .. name, callback_data = 'pluginsENABLE' .. name }
        end
        if not privileged then
            keyboard.inline_keyboard[row][column].callback_data = keyboard.inline_keyboard[row][column].callback_data .. chat_id
        end
        column = column + 1
        if column > 2 then
            flag = true
        end
    end
    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(user_id)].updateKeyboard, callback_data = 'pluginsBACK' }
    if not privileged then
        keyboard.inline_keyboard[row][column].callback_data = keyboard.inline_keyboard[row][column].callback_data .. chat_id
    end
    return keyboard
end

local function run(msg, matches)
    if msg.cb then
        if matches[1] == '###cbplugins' then
            if matches[2] == 'BACK' then
                if matches[3] then
                    if is_owner2(msg.from.id, matches[3]) then
                        return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].pluginsIntro .. '\n\n' .. langs[msg.lang].pluginsList .. matches[3], keyboard_plugins_list(msg.from.id, false, tonumber(matches[3])))
                    else
                        return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                    end
                else
                    if is_sudo(msg) then
                        return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].pluginsIntro, keyboard_plugins_list(msg.from.id, true))
                    else
                        return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_sudo)
                    end
                end
            elseif matches[4] then
                -- Enable/Disable a plugin for this chat
                if is_owner2(msg.from.id, matches[4]) then
                    mystat('###cbplugins' .. matches[2] .. matches[3] .. matches[4])
                    if matches[2] == 'ENABLE' then
                        return editMessageText(msg.chat.id, msg.message_id, reenable_plugin_on_chat(matches[3], tonumber(matches[4])), { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'pluginsBACK' .. matches[4] } } } })
                    elseif matches[2] == 'DISABLE' then
                        if system_plugin(matches[3]) then
                            return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].systemPlugin, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'pluginsBACK' .. matches[4] } } } })
                        end
                        return editMessageText(msg.chat.id, msg.message_id, disable_plugin_on_chat(matches[3], tonumber(matches[4])), { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'pluginsBACK' .. matches[4] } } } })
                    end
                else
                    return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                end
            else
                -- Enable/Disable a plugin
                if is_sudo(msg) then
                    mystat('###cbplugins' .. matches[2] .. matches[3])
                    if matches[2] == 'ENABLE' then
                        return editMessageText(msg.chat.id, msg.message_id, enable_plugin(matches[3], msg.chat.id), { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'pluginsBACK' } } } })
                    elseif matches[2] == 'DISABLE' then
                        if system_plugin(matches[3]) then
                            return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].systemPlugin, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'pluginsBACK' } } } })
                        end
                        return editMessageText(msg.chat.id, msg.message_id, disable_plugin(matches[3], msg.chat.id), { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'pluginsBACK' } } } })
                    end
                else
                    return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_sudo)
                end
            end
        end
    end

    if matches[1]:lower() == 'plugins' or matches[1]:lower() == 'lista plugins' then
        if msg.from.is_owner then
            local chat_plugins = false
            if matches[2] then
                chat_plugins = true
            elseif not is_sudo(msg) then
                chat_plugins = true
            end
            if msg.chat.type ~= 'private' then
                sendMessage(msg.chat.id, langs[msg.lang].sendPluginsPvt)
            end
            if chat_plugins then
                if data[tostring(msg.chat.id)] then
                    mystat('/plugins chat')
                    return sendKeyboard(msg.from.id, langs[msg.lang].pluginsIntro .. '\n\n' .. langs[msg.lang].pluginsList .. msg.chat.id, keyboard_plugins_list(msg.from.id, false, msg.chat.id))
                else
                    return langs[msg.lang].useYourGroups
                end
            else
                mystat('/plugins')
                return sendKeyboard(msg.from.id, langs[msg.lang].pluginsIntro, keyboard_plugins_list(msg.from.id, true, msg.chat.id))
            end
        else
            return langs[msg.lang].require_owner
        end
    end

    -- Show the available plugins
    if matches[1]:lower() == 'textualplugins' then
        if msg.from.is_owner then
            local chat_plugins = false
            if matches[2] then
                chat_plugins = true
            elseif not is_sudo(msg) then
                chat_plugins = true
            end
            if chat_plugins then
                if data[tostring(msg.chat.id)] then
                    mystat('/plugins chat')
                    return langs[msg.lang].pluginsIntro .. '\n\n' .. list_plugins(msg.chat.id)
                else
                    return langs[msg.lang].useYourGroups
                end
            else
                mystat('/plugins')
                return langs[msg.lang].pluginsIntro .. '\n\n' .. list_plugins_sudo()
            end
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'enable' or matches[1]:lower() == 'abilita' or matches[1]:lower() == 'attiva' then
        if matches[3] then
            -- Re-enable a plugin for this chat
            if msg.from.is_owner then
                mystat('/enable <plugin> chat')
                print("enable " .. matches[2] .. ' on this chat')
                return reenable_plugin_on_chat(matches[2], msg.chat.id)
            else
                return langs[msg.lang].require_owner
            end
        else
            -- Enable a plugin
            if is_sudo(msg) then
                mystat('/enable <plugin>')
                print("enable: " .. matches[2])
                return enable_plugin(matches[2], msg.chat.id)
            else
                return langs[msg.lang].require_sudo
            end
        end
    end

    if matches[1]:lower() == 'disable' or matches[1]:lower() == 'disabilita' or matches[1]:lower() == 'disattiva' then
        if matches[3] then
            -- Disable a plugin for this chat
            if msg.from.is_owner then
                mystat('/disable plugin chat')
                if system_plugin(matches[2]) then
                    return langs[msg.lang].systemPlugin
                end
                print("disable " .. matches[2] .. ' on this chat')
                return disable_plugin_on_chat(matches[2], msg.chat.id)
            else
                return langs[msg.lang].require_owner
            end
        else
            -- Disable a plugin
            if is_sudo(msg) then
                mystat('/disable <plugin>')
                if system_plugin(matches[2]) then
                    return langs[msg.lang].systemPlugin
                end
                print("disable: " .. matches[2])
                return disable_plugin(matches[2], msg.chat.id)
            else
                return langs[msg.lang].require_sudo
            end
        end
    end

    -- Show on chat disabled plugin
    if matches[1]:lower() == 'disabledlist' or matches[1]:lower() == 'lista disabilitati' or matches[1]:lower() == 'lista disattivati' then
        if msg.from.is_owner then
            mystat('/disabledlist')
            return list_disabled_plugin_on_chat(msg.chat.id)
        else
            return langs[msg.lang].require_owner
        end
    end

    -- Reload all the plugins and strings!
    if matches[1]:lower() == 'reload' or matches[1]:lower() == 'sasha ricarica' or matches[1]:lower() == 'ricarica' then
        if is_sudo(msg) then
            mystat('/reload')
            print(reload_plugins())
            return langs[msg.lang].pluginsReloaded
        else
            return langs[msg.lang].require_sudo
        end
    end
end

return {
    description = "PLUGINS",
    patterns =
    {
        "^(###cbplugins)(BACK)(%-%d+)$",
        "^(###cbplugins)(BACK)$",
        "^(###cbplugins)(ENABLE)(.*)(%-%d+)$",
        "^(###cbplugins)(DISABLE)(.*)(%-%d+)$",
        "^(###cbplugins)(ENABLE)(.*)$",
        "^(###cbplugins)(DISABLE)(.*)$",

        "^[#!/]([Pp][Ll][Uu][Gg][Ii][Nn][Ss])$",
        "^[#!/]([Pp][Ll][Uu][Gg][Ii][Nn][Ss]) ([Cc][Hh][Aa][Tt])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Pp][Ll][Uu][Gg][Ii][Nn][Ss])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Pp][Ll][Uu][Gg][Ii][Nn][Ss]) ([Cc][Hh][Aa][Tt])$",
        "^[#!/]([Ee][Nn][Aa][Bb][Ll][Ee]) ([%w_%.%-]+)$",
        "^[#!/]([Dd][Ii][Ss][Aa][Bb][Ll][Ee]) ([%w_%.%-]+)$",
        "^[#!/]([Ee][Nn][Aa][Bb][Ll][Ee]) ([%w_%.%-]+) ([Cc][Hh][Aa][Tt])",
        "^[#!/]([Dd][Ii][Ss][Aa][Bb][Ll][Ee]) ([%w_%.%-]+) ([Cc][Hh][Aa][Tt])",
        "^[#!/]([Rr][Ee][Ll][Oo][Aa][Dd])$",
        "^[#!/]([Dd][Ii][Ss][Aa][Bb][Ll][Ee][Dd][Ll][Ii][Ss][Tt])",
        -- plugins
        "^[Ss][Aa][Ss][Hh][Aa] ([Ll][Ii][Ss][Tt][Aa] [Pp][Ll][Uu][Gg][Ii][Nn][Ss])$",
        "^([Ll][Ii][Ss][Tt][Aa] [Pp][Ll][Uu][Gg][Ii][Nn][Ss])$",
        "^[Ss][Aa][Ss][Hh][Aa] ([Ll][Ii][Ss][Tt][Aa] [Pp][Ll][Uu][Gg][Ii][Nn][Ss]) ([Cc][Hh][Aa][Tt])$",
        "^([Ll][Ii][Ss][Tt][Aa] [Pp][Ll][Uu][Gg][Ii][Nn][Ss]) ([Cc][Hh][Aa][Tt])$",
        -- enable
        "^[Ss][Aa][Ss][Hh][Aa] ([Aa][Bb][Ii][Ll][Ii][Tt][Aa]) ([%w_%.%-]+)$",
        "^[Ss][Aa][Ss][Hh][Aa] ([Aa][Tt][Tt][Ii][Vv][Aa]) ([%w_%.%-]+)$",
        "^([Aa][Bb][Ii][Ll][Ii][Tt][Aa]) ([%w_%.%-]+)$",
        "^([Aa][Tt][Tt][Ii][Vv][Aa]) ([%w_%.%-]+)$",
        -- disable
        "^[Ss][Aa][Ss][Hh][Aa] ([Dd][Ii][Ss][Aa][Bb][Ii][Ll][Ii][Tt][Aa]) ([%w_%.%-]+)$",
        "^[Ss][Aa][Ss][Hh][Aa] ([Dd][Ii][Ss][Aa][Tt][Tt][Ii][Vv][Aa]) ([%w_%.%-]+)$",
        "^([Dd][Ii][Ss][Aa][Bb][Ii][Ll][Ii][Tt][Aa]) ([%w_%.%-]+)$",
        "^([Dd][Ii][Ss][Aa][Tt][Tt][Ii][Vv][Aa]) ([%w_%.%-]+)$",
        -- enable chat
        "^[Ss][Aa][Ss][Hh][Aa] ([Aa][Bb][Ii][Ll][Ii][Tt][Aa]) ([%w_%.%-]+) ([Cc][Hh][Aa][Tt])",
        "^[Ss][Aa][Ss][Hh][Aa] ([Aa][Tt][Tt][Ii][Vv][Aa]) ([%w_%.%-]+) ([Cc][Hh][Aa][Tt])",
        "^([Aa][Bb][Ii][Ll][Ii][Tt][Aa]) ([%w_%.%-]+) ([Cc][Hh][Aa][Tt])",
        "^([Aa][Tt][Tt][Ii][Vv][Aa]) ([%w_%.%-]+) ([Cc][Hh][Aa][Tt])",
        -- disable chat
        "^[Ss][Aa][Ss][Hh][Aa] ([Dd][Ii][Ss][Aa][Bb][Ii][Ll][Ii][Tt][Aa]) ([%w_%.%-]+) ([Cc][Hh][Aa][Tt])",
        "^[Ss][Aa][Ss][Hh][Aa] ([Dd][Ii][Ss][Aa][Tt][Tt][Ii][Vv][Aa]) ([%w_%.%-]+) ([Cc][Hh][Aa][Tt])",
        "^([Dd][Ii][Ss][Aa][Bb][Ii][Ll][Ii][Tt][Aa]) ([%w_%.%-]+) ([Cc][Hh][Aa][Tt])",
        "^([Dd][Ii][Ss][Aa][Tt][Tt][Ii][Vv][Aa]) ([%w_%.%-]+) ([Cc][Hh][Aa][Tt])",
        -- reload
        "^[Ss][Aa][Ss][Hh][Aa] ([Rr][Ii][Cc][Aa][Rr][Ii][Cc][Aa])$",
        "^([Rr][Ii][Cc][Aa][Rr][Ii][Cc][Aa])$",
        -- disabledlist
        "^[Ss][Aa][Ss][Hh][Aa] ([Ll][Ii][Ss][Tt][Aa] [Dd][Ii][Ss][Aa][Bb][Ii][Ll][Ii][Tt][Aa][Tt][Ii])$",
        "^[Ss][Aa][Ss][Hh][Aa] ([Ll][Ii][Ss][Tt][Aa] [Dd][Ii][Ss][Aa][Tt][Tt][Ii][Vv][Aa][Tt][Ii])$",
        "^[(Ll][Ii][Ss][Tt][Aa] [Dd][Ii][Ss][Aa][Bb][Ii][Ll][Ii][Tt][Aa][Tt][Ii])$",
        "^([Ll][Ii][Ss][Tt][Aa] [Dd][Ii][Ss][Aa][Tt][Tt][Ii][Vv][Aa][Tt][Ii])$",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "OWNER",
        "(#plugins|[sasha] lista plugins)",
        "#textualplugins",
        "(#disabledlist|([sasha] lista disabilitati|disattivati))",
        "(#enable|[sasha] abilita|[sasha] attiva) <plugin> chat",
        "(#disable|[sasha] disabilita|[sasha] disattiva) <plugin> chat",
        "SUDO",
        "(#plugins|[sasha] lista plugins) [chat]",
        "#textualplugins [chat]",
        "(#enable|[sasha] abilita|[sasha] attiva) <plugin> [chat]",
        "(#disable|[sasha] disabilita|[sasha] disattiva) <plugin> [chat]",
        "(#reload|[sasha] ricarica)",
    },
}
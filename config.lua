return {
    bot_api_key = '',
    log_chat = - 1001057801239,
    channel = '@AISashaChannel',
    -- channel username with the '@'
    help_group = '',
    -- group link, not username!
    enabled_plugins =
    {
        'anti_spam',
        'msg_checks',
        -- THIS HAVE TO BE THE FIRST TWO: IF AN USER IS SPAMMING/IS BLOCKED, THE BOT WON'T GO THROUGH PLUGINS
        'administrator',
        'banhammer',
        'bot',
        'broadcast',
        'check_tag',
        'database',
        'fakecommand',
        'feedback',
        'filemanager',
        'flame',
        'get',
        'goodbyewelcome',
        'group_management',
        'help',
        'info',
        'interact',
        'leave_ban',
        'likecounter',
        'lua_exec',
        'me',
        'onservice',
        'plugins',
        'reactions',
        'set',
        'stats',
        'strings',
        'tgcli_to_api_migration',
        'unset',
        'warn',
        'whitelist',
    },
    disabled_plugin_on_chat = { },
    sudo_users = { 41400331, },
    moderation = { data = 'data/moderation.json' },
    likecounter = { db = 'data/likecounterdb.json' },
    database = { db = 'data/database.json' },
    about_text = "AISashaAPI by @EricSolinas based on @GroupButler_Bot and @TeleSeed supergroup branch with something taken from @DBTeam.\nThanks guys.",
    api_errors =
    {
        [101] = 'Not enough rights to kick participant',
        -- SUPERGROUP: bot is not admin
        [102] = 'USER_ADMIN_INVALID',
        -- SUPERGROUP: trying to kick an admin
        [103] = 'method is available for supergroup chats only',
        -- NORMAL: trying to unban
        [104] = 'Only creator of the group can kick administrators from the group',
        -- NORMAL: trying to kick an admin
        [105] = 'Bad Request: Need to be inviter of the user to kick it from the group',
        -- NORMAL: bot is not an admin or everyone is an admin
        [106] = 'USER_NOT_PARTICIPANT',
        -- NORMAL: trying to kick an user that is not in the group
        [107] = 'CHAT_ADMIN_REQUIRED',
        -- NORMAL: bot is not an admin or everyone is an admin
        [108] = 'there is no administrators in the private chat',
        -- something asked in a private chat with the api methods 2.1

        [110] = 'PEER_ID_INVALID',
        -- user never started the bot
        [111] = 'message is not modified',
        -- the edit message method hasn't modified the message
        [112] = 'Can\'t parse message text: Can\'t find end of the entity starting at byte offset %d+',
        -- the markdown is wrong and breaks the delivery
        [113] = 'group chat is migrated to a supergroup chat',
        -- group updated to supergroup
        [114] = 'Message can\'t be forwarded',
        -- unknown
        [115] = 'Message text is empty',
        -- empty message
        [116] = 'message not found',
        -- message id invalid, I guess
        [117] = 'chat not found',
        -- I don't know
        [118] = 'Message is too long',
        -- over 4096 char
        [119] = 'User not found',
        -- unknown user_id

        [120] = 'Can\'t parse reply keyboard markup JSON object',
        -- keyboard table invalid
        [121] = 'Field \\\"inline_keyboard\\\" of the InlineKeyboardMarkup should be an Array of Arrays',
        -- inline keyboard is not an array of array
        [122] = 'Can\'t parse inline keyboard button: InlineKeyboardButton should be an Object',
        [123] = 'Bad Request: Object expected as reply markup',
        -- empty inline keyboard table
        [124] = 'QUERY_ID_INVALID',
        -- callback query id invalid
        [125] = 'CHANNEL_PRIVATE',
        -- I don't know
        [126] = 'MESSAGE_TOO_LONG',
        -- text of an inline callback answer is too long
        [127] = 'wrong user_id specified',
        -- invalid user_id
        [128] = 'Too big total timeout [%d%.]+',
        -- something about spam an inline keyboards
        [129] = 'BUTTON_DATA_INVALID',
        -- callback_data string invalid

        [130] = 'Type of file to send mismatch',
        -- trying to send a media with the wrong method
        [131] = 'MESSAGE_ID_INVALID',
        -- I don't know
        [132] = 'Can\'t parse inline keyboard button: Can\'t find field "text"',
        -- the text of a button could be nil

        [403] = 'Bot was blocked by the user',
        -- user blocked the bot
        [429] = 'Too many requests: retry later',
        -- the bot is hitting api limits
        [430] = 'Too big total timeout',-- too many callback_data requests
    }
}
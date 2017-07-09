api_errors = {
    [101] = 'not enough rights to kick/unban chat member',
    -- SUPERGROUP: bot is not admin
    [102] = 'user_admin_invalid',
    -- SUPERGROUP: trying to kick an admin
    [103] = 'method is available for supergroup chats only',
    -- NORMAL: trying to unban
    [104] = 'only creator of the group can kick administrators from the group',
    -- NORMAL: trying to kick an admin
    [105] = 'need to be inviter of the user to kick it from the group',
    -- NORMAL: bot is not an admin or everyone is an admin
    [106] = 'user_not_participant',
    -- NORMAL: trying to kick an user that is not in the group
    [107] = 'chat_admin_required',
    -- NORMAL: bot is not an admin or everyone is an admin
    [108] = 'there is no administrators in the private chat',
    -- something asked in a private chat with the api methods 2.1
    [109] = 'wrong url host',
    -- hyperlink not valid
    [110] = 'peer_id_invalid',
    -- user never started the bot
    [111] = 'message is not modified',
    -- the edit message method hasn't modified the message
    [112] = 'can\'t parse message text: can\'t find end of the entity starting at byte offset %d+',
    -- the markdown is wrong and breaks the delivery
    [113] = 'group chat is migrated to a supergroup chat',
    -- group updated to supergroup
    [114] = 'message can\'t be forwarded',
    -- unknown
    [115] = 'message text is empty',
    -- empty message
    [116] = 'message not found',
    -- message id invalid, I guess
    [117] = 'chat not found',
    -- I don't know
    [118] = 'message is too long',
    -- over 4096 char
    [119] = 'user not found',
    -- unknown user_id
    [120] = 'can\'t parse reply keyboard markup json object',
    -- keyboard table invalid
    [121] = 'field \\\"inline_keyboard\\\" of the inlinekeyboardmarkup should be an array of arrays',
    -- inline keyboard is not an array of array
    [122] = 'can\'t parse inline keyboard button: inlinekeyboardbutton should be an object',
    [123] = 'bad Request: object expected as reply markup',
    -- empty inline keyboard table
    [124] = 'query_id_invalid',
    -- callback query id invalid
    [125] = 'channel_private',
    -- I don't know
    [126] = 'message_too_long',
    -- text of an inline callback answer is too long
    [127] = 'wrong user_id specified',
    -- invalid user_id
    [128] = 'too big total timeout [%d%.]+',
    -- something about spam an inline keyboards
    [129] = 'button_data_invalid',
    -- callback_data string invalid
    [130] = 'type of file to send mismatch',
    -- trying to send a media with the wrong method
    [131] = 'message_id_invalid',
    -- I don't know. Probably passing a string as message id
    [132] = 'can\'t parse inline keyboard button: can\'t find field "text"',
    -- the text of a button could be nil
    [133] = 'can\'t parse inline keyboard button: field "text" must be of type String',
    [134] = 'user_id_invalid',
    [135] = 'chat_invalid',
    [136] = 'user_deactivated',
    -- deleted account, probably
    [137] = 'can\'t parse inline keyboard button: text buttons are unallowed in the inline keyboard',
    [138] = 'message was not forwarded',
    [139] = 'can\'t parse inline keyboard button: field \\\"text\\\" must be of type string',
    -- "text" field in a button object is not a string
    [140] = 'channel invalid',
    -- /shrug
    [141] = 'wrong message entity: unsupproted url protocol',
    -- username in an inline link [word](@username) (only?)
    [142] = 'wrong message entity: url host is empty',
    -- inline link without link [word]()
    [143] = 'there is no photo in the request',
    [144] = 'can\'t parse message text: unsupported start tag "%w+" at byte offset %d+',
    [145] = 'can\'t parse message text: expected end tag at byte offset %d+',
    [146] = 'button_url_invalid',
    -- invalid url (inline buttons)
    [147] = 'message must be non%-empty',
    -- example: ```   ```
    [148] = 'can\'t parse message text: unmatched end tag at byte offset',
    [149] = 'reply_markup_invalid',
    -- returned while trying to send an url button without text and with an invalid url
    [150] = 'message text must be encoded in utf%-8',
    [151] = 'url host is empty',
    [152] = 'requested data is unaccessible',
    -- the request involves a private channel and the bot is not admin there
    [153] = 'unsupported url protocol',
    [154] = 'can\'t parse message text: unexpected end tag at byte offset %d+',
    [155] = 'message to edit not found',
    [156] = 'group chat was migrated to a supergroup chat',
    [157] = 'message to forward not found'
    -- [403] = 'bot was blocked by the user', --user blocked the bot
    -- [429] = 'Too many requests: retry later', --the bot is hitting api limits
    -- [430] = 'Too big total timeout', --too many callback_data requests
}
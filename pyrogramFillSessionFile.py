# pyrogram version => 0.15.1
# this is only useful to fill the session file
import sys

from pyrogram import ChatAction, Client

print("BEGIN")
bot_api_key = open("bot_api_key.txt", "r").read()
print(bot_api_key)
if bot_api_key is None or bot_api_key == "":
    print("MISSING TELEGRAM API KEY")
    sys.exit()
bot_api_key = str(bot_api_key).strip()
app = Client(session_name="AISashaAPI", workers=1, bot_token=bot_api_key)
app.start()
app.idle()
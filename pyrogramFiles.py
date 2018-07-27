import sys
from pyrogram import Client
method = sys.argv[1]
chat_id = sys.argv[2]
ffile = str(sys.argv[3]).replace('\\"', '"')
with open('bot_api_key.txt') as f:
	bot_api_key = f.readline()
app = Client(bot_api_key)
if method == "DOWNLOAD":
    file_name = str(sys.argv[4]).replace('\\"', '"')
    if file_name != "":
        app.download_media(message=ffile, file_name=file_name)
    else:
        app.download_media(message=ffile)
elif method == "UPLOAD":
    reply_id = sys.argv[4]
    if reply_id != "":
        app.send_document(chat_id=chat_id, document=ffile, reply_to_message_id=reply_id)
    else:
        app.send_document(chat_id=chat_id, document=ffile)
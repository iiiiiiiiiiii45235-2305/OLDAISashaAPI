import sys
from pyrogram import Client
print("BEGIN")
method = sys.argv[1]
with open('bot_api_key.txt') as f:
	bot_api_key = f.readline()
app = Client(session_name=str(bot_api_key), workers=1)
app.start()
if method == "DOWNLOAD":
    ffile = str(sys.argv[2]).replace('\\"', '"')
    file_name = str(sys.argv[3]).replace('\\"', '"')
    if file_name != "":
        app.download_media(message=ffile, file_name=file_name)
    else:
        app.download_media(message=ffile)
elif method == "UPLOAD":
    chat_id = sys.argv[2]
    ffile = str(sys.argv[3]).replace('\\"', '"')
    reply_id = sys.argv[4]
    if reply_id != "":
        app.send_document(chat_id=chat_id, document=ffile, reply_to_message_id=reply_id)
    else:
        app.send_document(chat_id=chat_id, document=ffile)
app.stop()
print("END")
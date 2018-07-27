import sys
from pyrogram import Client
print("BEGIN")
print(sys.argv)
method = str(sys.argv[1])
chat_id = int(sys.argv[2])
bot_api_key = ''
try:
    f = open("bot_api_key.txt", 'r')
    bot_api_key = f.readline()
    f.close()
except Exception as e:
    print(e)
app = Client(session_name=bot_api_key, workers=1)
app.start()
if method == "DOWNLOAD":
    ffile = str(sys.argv[3])
    file_name = str(sys.argv[4]).replace('\\"', '"')
    if file_name != "":
        app.download_media(message=ffile, file_name=file_name)
    else:
        app.download_media(message=ffile)
    app.send_message(chat_id=chat_id, text=ffile + " downloaded to "(file_name if file_name != "" else "UNKNOWN_LOCATION"))
elif method == "UPLOAD":
    ffile = str(sys.argv[3]).replace('\\"', '"')
    reply_id = int(sys.argv[4])
    if reply_id != "":
        app.send_document(chat_id=chat_id, document=ffile, reply_to_message_id=reply_id)
    else:
        app.send_document(chat_id=chat_id, document=ffile)
app.stop()
print("END")
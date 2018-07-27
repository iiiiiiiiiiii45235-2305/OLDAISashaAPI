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
    file_path = str(sys.argv[4]).replace('\\"', '"')
    text = str(sys.argv[5]).replace('\\"', '"')
    if file_path != "":
        app.download_media(message=ffile, file_name=file_path)
    else:
        app.download_media(message=ffile)
    app.send_message(chat_id=chat_id, text=text)
elif method == "UPLOAD":
    ffile = str(sys.argv[3]).replace('\\"', '"')
    reply_id = str(sys.argv[4])
    if reply_id != "":
        app.send_document(chat_id=chat_id, document=ffile, reply_to_message_id=int(reply_id))
    else:
        app.send_document(chat_id=chat_id, document=ffile)
app.stop()
print("END")
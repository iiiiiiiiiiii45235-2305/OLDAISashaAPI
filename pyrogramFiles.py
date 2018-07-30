# pyrogram version => 0.7.5
import sys
import random
import string

from pyrogram import ChatAction, Client

print("BEGIN")
bot_api_key = open("bot_api_key.txt", "r").read()
if bot_api_key is None or bot_api_key == "":
    print("MISSING TELEGRAM API KEY")
    sys.exit()
app = Client(session_name=bot_api_key, workers=1, workdir='./pyrogram_workdirs/' + ''.join(random.SystemRandom().choice(string.ascii_uppercase + string.digits) for _ in range(15)))
app.start()
print(sys.argv)
method = str(sys.argv[1])
chat_id = int(sys.argv[2])
if method == "DOWNLOAD":
    ffile = str(sys.argv[3])
    file_path = str(sys.argv[4]).replace('\\"', '"')
    text = str(sys.argv[5]).replace('\\"', '"')
    if file_path == "":
        file_path = ""
    app.download_media(message=ffile, file_name=file_path)
    if text != "":
        app.send_chat_action(chat_id=chat_id, action=ChatAction.TYPING)
        app.send_message(chat_id=chat_id, text=text)
elif method == "UPLOAD":
    media_type = str(sys.argv[3])
    ffile = str(sys.argv[4]).replace('\\"', '"')
    reply_id = str(sys.argv[5])
    caption = str(sys.argv[6]).replace('\\"', '"')
    error_string = str(sys.argv[7])
    if reply_id == "":
        reply_id = -1
    else:
        reply_id = int(reply_id)
    if caption == "":
        caption = ""
    try:
        if media_type == "audio":
            app.send_chat_action(chat_id=chat_id, action=ChatAction.UPLOAD_AUDIO)
            app.send_audio(chat_id=chat_id, audio=ffile, reply_to_message_id=reply_id, caption=caption)
        elif media_type == "document":
            app.send_chat_action(chat_id=chat_id, action=ChatAction.UPLOAD_DOCUMENT)
            app.send_document(chat_id=chat_id, document=ffile, reply_to_message_id=reply_id, caption=caption)
        elif media_type == "gif":
            app.send_chat_action(chat_id=chat_id, action=ChatAction.UPLOAD_VIDEO)
            app.send_gif(chat_id=chat_id, gif=ffile, reply_to_message_id=reply_id, caption=caption)
        elif media_type == "photo":
            app.send_chat_action(chat_id=chat_id, action=ChatAction.UPLOAD_PHOTO)
            app.send_photo(chat_id=chat_id, photo=ffile, reply_to_message_id=reply_id, caption=caption)
        elif media_type == "sticker":
            app.send_sticker(chat_id=chat_id, sticker=ffile, reply_to_message_id=reply_id)
        elif media_type == "video":
            app.send_chat_action(chat_id=chat_id, action=ChatAction.RECORD_VIDEO)
            app.send_video(chat_id=chat_id, video=ffile, reply_to_message_id=reply_id, caption=caption)
        elif media_type == "video_note":
            app.send_chat_action(chat_id=chat_id, action=ChatAction.RECORD_VIDEO_NOTE)
            app.send_video_note(chat_id=chat_id, video_note=ffile, reply_to_message_id=reply_id)
        elif media_type == "voice_note":
            app.send_chat_action(chat_id=chat_id, action=ChatAction.RECORD_AUDIO)
            app.send_voice(chat_id=chat_id, voice=ffile, reply_to_message_id=reply_id, caption=caption)
        else:
            #default
            app.send_chat_action(chat_id=chat_id, action=ChatAction.UPLOAD_DOCUMENT)
            app.send_document(chat_id=chat_id, document=ffile, reply_to_message_id=reply_id, caption=caption)
    except Exception as e:
        app.send_chat_action(chat_id=chat_id, action=ChatAction.TYPING)
        app.send_message(chat_id=chat_id, text=error_string + media_type + "\n" + str(e))
app.stop()
print("END")

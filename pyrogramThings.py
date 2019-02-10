# pyrogram version => 0.11.0
import sys
import random
import string
import shutil
import os

from pyrogram import ChatAction, Client

#used to generate random working directories
def workdirs_generator(size=15, chars=string.digits + string.ascii_letters):
    return ''.join(random.choice(chars) for _ in range(size))

###API KEY
print("BEGIN")
bot_api_key = open("bot_api_key.txt", "r").read()
print(bot_api_key)
if bot_api_key is None or bot_api_key == "":
    print("MISSING TELEGRAM API KEY")
    sys.exit()
bot_api_key = str(bot_api_key).strip()
#fixes some errors

###PREPARE THE WORKING ENVIRONMENT
workdir = './pyrogram_workdirs/' + workdirs_generator()
os.makedirs(workdir)
#copy config.ini and the session file from the base directory to the working
#directory
shutil.copyfile("./config.ini", workdir + '/config.ini')
shutil.copyfile("./283058260.session", workdir + '/283058260.session')

###ACTUAL WORK
app = Client(session_name=bot_api_key, workers=1, workdir=workdir, config_file="./config.ini", no_updates=True)
app.start()
print(sys.argv)
method = str(sys.argv[1])
chat_id = int(sys.argv[2])
try:
    if method == "DOWNLOAD":
        ffile = str(sys.argv[3])
        file_path = str(sys.argv[4]).replace('\\"', '"')
        text = str(sys.argv[5] if len(sys.argv) >= 6 else "").replace('\\"', '"')
        if file_path == "":
            file_path = ""
        app.download_media(message=ffile, file_name=file_path)
        if text != "":
            app.send_chat_action(chat_id=chat_id, action=ChatAction.TYPING)
            app.send_message(chat_id=chat_id, text=text)
    elif method == "UPLOAD":
        media_type = str(sys.argv[3])
        ffile = str(sys.argv[4]).replace('\\"', '"')
        reply_id = str(sys.argv[5] if len(sys.argv) >= 6 else "")
        caption = str(sys.argv[6] if len(sys.argv) >= 7 else "").replace('\\"', '"')
        error_string = str(sys.argv[7] if len(sys.argv) >= 8 else "")
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
    elif method == "VARDUMP":
        message_id = int(sys.argv[3])
        msg = app.get_messages(chat_id=chat_id, message_ids=message_id)
        app.send_chat_action(chat_id=chat_id, action=ChatAction.UPLOAD_DOCUMENT)
        app.send_message(chat_id=chat_id, text=str(msg))
finally:
    app.stop()

###CLEAN
shutil.rmtree(workdir)
#deletes the working directory once it's finished
print("END")

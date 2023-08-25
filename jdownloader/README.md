Lightweight alpine container with jdownloader (126MB image size) with graceful shutdown/restart (java runs on PID 1 with USER_UID specified). All is working correctly especially extracting ( glibc is added for extraction to work ).

# Usage Example:

    docker run -d -m 2g --name jdownloader \
        --restart=unless-stopped \
        --cap-add SYS_ADMIN \
        --device /dev/fuse \
        --security-opt apparmor:unconfined \
        -e USER_UID=1002 \
        -v /home/<USER>/jdownloader:/jdownloader/cfg \
        -v /host/download/path:/jdownloader/Downloads \
        mumiehub/jdownloader

-m 2g is used because jdownloader will eat up your memory when downloading something (caching).

to edit your jdownloader config for my.jdownloader.org portal maybe, just go to the mounted folder /home/USER/data/jdownloader
and edit: org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
add:
{
"serverhost" : "api.jdownloader.org",
"email" : "youremailadress",
"password" : "yourpassword"
}

(dont forget the , on each end of the entries except the last entry)

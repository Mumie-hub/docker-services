Lightweight alpine container with jdownloader (126MB image size) with graceful shutdown/restart (java runs on PID 1 with USER_UID specified). All is working correctly especially extracting ( glibc is added for extraction to work ).

Use it with:
docker run -d -m 2g --restart=unless-stopped --name jdownloader -v /home/USER/data/jdownloader:/jdownloader/cfg -v /YOUR/download/path:/jdownloader/Downloads -e USER_UID=1002 mumiehub/jdownloader

-m 2g is used because jdownloader will eat up your memory when downloading something (caching).

to edit your jdownloader config for my.jdownloader.org portal maybe, just go to the mounted folder /home/USER/data/jdownloader
and edit: org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json
add:
{
"serverhost" : "api.jdownloader.org",
"email" : "youremailadress",
"password" : "yourpassword"
}

(dont forget the , on each end of entrys except the last entry)
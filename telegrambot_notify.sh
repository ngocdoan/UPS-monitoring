#!/bin/bash
 ACCESS_TOKEN="TOKEN-HERE"
 URL="https://api.telegram.org/bot$ACCESS_TOKEN/sendMessage"
 CHAT_ID="ID-HERE"
 # Telegram id from /getUpdates
 MESSAGE="*Login Alert*: $(date '+%Y-%m-%d %H:%M:%S %Z')
 username: $PAM_USER
 hostname: $HOSTNAME
 remote host: $PAM_RHOST
 remote user: $PAM_RUSER
 service: $PAM_SERVICE
 tty: $PAM_TTY"
 PAYLOAD="chat_id=$CHAT_ID&text=$MESSAGE&disable_web_page_preview=true&parse_mode=Markdown"
 curl -s --max-time 13 --retry 3 --retry-delay 3 --retry-max-time 13 -d "$PAYLOAD" $URL > /dev/null 2>&1 &

#! /bin/bash
HTTP_PROXY=""
HTTPS_PROXY=""
http_proxy=""
https_proxy=""
ngrok config add-authtoken $NGROK_TOKEN
ngrok http 8188
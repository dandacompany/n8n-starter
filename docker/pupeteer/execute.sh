docker run -it \
  --cap-add=SYS_ADMIN \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8n-puppeteer
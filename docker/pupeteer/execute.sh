docker run -it \
  --cap-add=SYS_ADMIN \
  -p 5679:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8n-puppeteer
from nginx:alpine

maintainer aswin

COPY app/index.html /usr/share/nginx/html/index.html

expose 80

cmd ["nginx", "-g", "daemon off;"]


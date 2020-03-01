FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 8000
USER 1001

WORKDIR /app
COPY ./index.html ./

CMD ["nginx", "-g", "daemon off;"]
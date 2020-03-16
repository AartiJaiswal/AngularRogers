FROM node:latest as node
WORKDIR /app
COPY . .
COPY package.json ./
RUN yum -y install wget
RUN npm install
RUN npm install -g @angular/cli@7.3.9
RUN npm run build --prod
FROM nginx:stable    
RUN chgrp -R root /var/cache/nginx /var/run /var/log/nginx && \
    chmod -R 770 /var/cache/nginx /var/run /var/log/nginx

RUN sed -i.bak 's/listen\(.*\)80;/listen 9212;/' /etc/nginx/conf.d/default.conf
COPY --from=node /app/dist/AngularTestApp /usr/share/nginx/html
EXPOSE 9212
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]

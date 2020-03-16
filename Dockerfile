FROM node:latest as node
RUN groupadd -g 1001 appuser && \
    useradd -r -u 1001 -g appuser appuser
USER appuser
WORKDIR /app
COPY . .
COPY package.json ./
RUN sudo npm install
RUN sudo npm install -g @angular/cli@7.3.9
RUN sudo npm run build --prod
FROM nginx:stable    
RUN sudo chgrp -R root /var/cache/nginx /var/run /var/log/nginx && \
    sudo chmod -R 770 /var/cache/nginx /var/run /var/log/nginx

RUN sed -i.bak 's/listen\(.*\)80;/listen 9212;/' /etc/nginx/conf.d/default.conf
COPY --from=node /app/dist/AngularTestApp /usr/share/nginx/html
EXPOSE 9212
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]

FROM node:latest as node
WORKDIR /app
COPY . .
COPY package.json ./
RUN npm install
RUN npm install -g @angular/cli@7.3.9
RUN npm run build --prod
FROM nginx:stable     
RUN chgrp -R root /var/cache/nginx /var/run /var/log/nginx && \
    chmod -R 770 /var/cache/nginx /var/run /var/log/nginx
COPY nginx/default.conf /etc/nginx/conf.d/
## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

COPY --from=node /app/dist/AngularTestApp /usr/share/nginx/html
EXPOSE 9212
CMD ["nginx", "-g", "daemon off;"]


FROM node:latest as node

## CREATE APP USER ##

# Create an app user so our program doesn't run as root.
RUN groupadd -r app &&\
    useradd -r -g app -d /home/app -s /sbin/nologin -c "Docker image user" app

WORKDIR /app
COPY . .
COPY package.json ./

# Chown all the files to the app user.
RUN chown -R app:app /app
RUN chown -R 999:999 "/app"
# Change to the app user.
USER app
RUN chown -R app /app
RUN chmod -R u+rX /app

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

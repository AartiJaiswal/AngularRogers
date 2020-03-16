# By default, Docker containers run as the root user. This is bad because:
#   1) You're more likely to modify up settings that you shouldn't be
#   2) If an attacker gets access to your container - well, that's bad if they're root.
# Here's how you can run change a Docker container to run as a non-root user
FROM node:latest as node

## CREATE APP USER ##

# Create the home directory for the new app user.
RUN mkdir -p /home/app

# Create an app user so our program doesn't run as root.
RUN groupadd -r app &&\
    useradd -r -g app -d /home/app -s /sbin/nologin -c "Docker image user" app

# Set the home directory to our app user's home.
ENV HOME=/home/app
ENV APP_HOME=/home/app/my-project

## SETTING UP THE APP ##
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Copy in the application code.
ADD . $APP_HOME

# Chown all the files to the app user.
RUN chown -R app:app $APP_HOME



# Change to the app user.
USER app
RUN apt-get upgrade
RUN npm install
RUN npm install -g @angular/cli@7.3.9
RUN chown -R 999:999 "/home/app/.npm"
RUN npm run build --prod
FROM nginx:stable    
RUN chgrp -R root /var/cache/nginx /var/run /var/log/nginx && \
    chmod -R 770 /var/cache/nginx /var/run /var/log/nginx

RUN sed -i.bak 's/listen\(.*\)80;/listen 9212;/' /etc/nginx/conf.d/default.conf
COPY --from=node /app/dist/AngularTestApp /usr/share/nginx/html
EXPOSE 9212
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]

FROM phusion/passenger-ruby21

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# nginx
RUN rm -f /etc/service/nginx/down

RUN apt-get -y update && apt-get install -V -y libpoppler-glib-dev

# app
ADD . /home/app/webapp
RUN mv /home/app/webapp/docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN mv /home/app/webapp/docker/database.yml /home/app/webapp/config/database.yml

# init
RUN mkdir -p /etc/my_init.d
RUN mv /home/app/webapp/docker/webapp.sh /etc/my_init.d/webapp.sh
RUN chown -R app /home/app/webapp

USER app
RUN cd /home/app/webapp && bundle install --path vendor/bundle

USER root

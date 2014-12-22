FROM phusion/passenger-ruby21

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# nginx
RUN rm -f /etc/service/nginx/down

# app
ADD . /home/app/webapp
RUN mv /home/app/webapp/docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN mv /home/app/webapp/docker/database.yml /home/app/webapp/config/database.yml

# init
RUN mkdir -p /etc/my_init.d
RUN mv /home/app/webapp/docker/webapp.sh /etc/my_init.d/webapp.sh

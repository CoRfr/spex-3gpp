FROM phusion/passenger-ruby26:1.0.11

# Provide pdf2htmlEX
RUN sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get build-dep -yy libpoppler73 && \
    apt-get install -yy wget git xz-utils libpango1.0-dev m4 libtool libltdl-dev perl \
                        libjpeg-dev libtiff5-dev libpng-dev libfreetype6-dev libgif-dev libgtk-3-dev \
                        libxml2-dev libpango1.0-dev libcairo2-dev libspiro-dev libuninameslist-dev \
                        python3-dev ninja-build cmake build-essential \
                        libfontforge-dev libfontconfig-dev && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
    git clone --depth=1 git://git.freedesktop.org/git/poppler/poppler -b poppler-0.81.0 && \
    cd poppler && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DENABLE_LIBOPENJPEG=none .. && \
    make && \
    make install && \
    cd .. && \
    mkdir -p /usr/local/include/poppler/goo \
             /usr/local/include/poppler/fofi \
             /usr/local/include/poppler/splash && \
    cp build/poppler/poppler-config.h /usr/local/include/poppler && \
    cp poppler/*.h /usr/local/include/poppler && \
    cp goo/*.h     /usr/local/include/poppler/goo && \
    cp fofi/*.h    /usr/local/include/poppler/fofi && \
    cp splash/*.h  /usr/local/include/poppler/splash && \
    cd && rm -rf /tmp/poppler

RUN cd /tmp && \
    git clone --depth=1 https://github.com/pdf2htmlEX/pdf2htmlEX.git -b v0.18.7-poppler-0.81.0 && \
    cd pdf2htmlEX && \
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local .. && \
    make && \
    make install && \
    cd && rm -rf /tmp/pdf2htmlEX

# Set correct environment variables.
ENV HOME /root
ENV RAILS_ENV production

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# nginx
RUN rm -f /etc/service/nginx/down

RUN apt-get update && \
    apt-get install -V -yy libpoppler-glib-dev libgirepository1.0-dev && \
    gem install bundler

# app
ADD . /home/app/webapp
RUN rm -f /etc/nginx/sites-enabled/default
RUN mv /home/app/webapp/docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN mv /home/app/webapp/docker/database.yml /home/app/webapp/config/database.yml

# init
RUN mkdir -p /etc/my_init.d
RUN mv /home/app/webapp/docker/webapp.sh /etc/my_init.d/webapp.sh
RUN chown -R app /home/app/webapp

# cron
RUN cp /home/app/webapp/docker/sync_job.sh /etc/cron.weekly/sync_job && \
    chown root:root /etc/cron.weekly/sync_job && \
    chmod 755 /etc/cron.weekly/sync_job

ENV SECRET_KEY_BASE "nokey"

USER app
ENV HOME "/home/app/"
RUN cd /home/app/webapp && \
    bundle config set path 'vendor/bundle' && \
    bundle install --jobs 4

RUN cd /home/app/webapp && \
    date && \
    bundle exec rake assets:precompile && \
    date

USER root

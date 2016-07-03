FROM phusion/passenger-ruby21

# Set correct environment variables.
ENV HOME /root
ENV RAILS_ENV production

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Provide pdf2htmlEX
RUN apt-get update && \
    apt-get install -yy wget xz-utils libpango1.0-dev m4 libtool perl \
                        autoconf automake coreutils python-dev zlib1g-dev libfreetype6-dev cmake && \
    rm -rf /var/lib/apt/lists/*

RUN cd / && \
    git clone https://github.com/BWITS/fontforge.git && \
    cd fontforge && \
    ./bootstrap --force && \
    ./configure --without-iconv && \
    make && \
    make install && \
    cd / && rm -rf /fontforge

RUN cd / && \
    git clone git://git.freedesktop.org/git/poppler/poppler && \
    cd poppler && \
    git checkout poppler-0.25.3 && \
    ./autogen.sh --enable-xpdf-headers && \
    make && sudo make install && \
    cd / && rm -rf /poppler
    
RUN cd / && \
    git clone --depth=1 git://github.com/coolwanglu/pdf2htmlEX.git && \
    cd pdf2htmlEX && \
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig && \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr . && make && sudo make install && \
    cd / && rm -rf /pdf2htmlEX

# nginx
RUN rm -f /etc/service/nginx/down

RUN apt-get -y update && apt-get install -V -y libpoppler-glib-dev

# app
ADD . /home/app/webapp
RUN rm -f /etc/nginx/sites-enabled/default
RUN mv /home/app/webapp/docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
RUN mv /home/app/webapp/docker/database.yml /home/app/webapp/config/database.yml

# init
RUN mkdir -p /etc/my_init.d
RUN mv /home/app/webapp/docker/webapp.sh /etc/my_init.d/webapp.sh
RUN chown -R app /home/app/webapp

USER app
RUN cd /home/app/webapp && bundle install --path vendor/bundle

USER root

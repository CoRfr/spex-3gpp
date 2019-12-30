#!/bin/sh -x

if [ $(id -u) -eq 0 ]; then
    # Rexecute as app
    su app -c "$0"
    exit $?
fi

cd /home/app/webapp
bundle exec script/init_3gpp.rb

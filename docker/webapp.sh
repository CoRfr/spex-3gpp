#!/bin/sh

su -c /bin/bash - app -c "( RAILS_ENV=production cd /home/app/webapp && bundle exec rake db:migrate && script/init_3gpp.rb )"

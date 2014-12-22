#!/bin/sh

su -c /bin/bash - app -c "( export RAILS_ENV=production && cd /home/app/webapp && bundle exec rake db:migrate)"

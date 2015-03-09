#!/bin/sh

env
su -c /bin/bash - app -c "( export RAILS_ENV=production && cd /home/app/webapp && bundle exec rake db:migrate )"
su -c /bin/bash - app -c "( export RAILS_ENV=production && cd /home/app/webapp && bundle exec rake assets:precompile )"


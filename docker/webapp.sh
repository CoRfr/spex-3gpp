#!/bin/bash

# Provide db env vars to passenger
for var in $(env |grep MYSQL | tr '=' ' ' |awk '{print $1}'); do
	if [ -n "${!var}" ]; then
		sed -i '$i'"passenger_set_cgi_param $var ${!var};" /etc/nginx/sites-enabled/webapp.conf
	fi
done

su --preserve-environment -c /bin/bash - app -c "( export RAILS_ENV=production && cd /home/app/webapp && bundle exec rake db:migrate )"
su --preserve-environment -c /bin/bash - app -c "( export RAILS_ENV=production && cd /home/app/webapp && bundle exec rake assets:precompile )"

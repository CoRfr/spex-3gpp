#!/bin/sh

cd /home/app/webapp
bundle install
rake db:migrate

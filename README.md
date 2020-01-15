# This is speX

I found the 3GPP documents hard to find, hard to stay up-to-date, etc ...
So this is an alternative service to expose 3GPP specifications in a different architecture.

Feel free to fork.

Service is provided at http://spex.cor-net.org

## How to run the service

### Using Docker

The docker image is available as `corfr/spex` or from sources:
```
host:spex$ docker build -t spex .
```

In the following we'll run the spex container. Along with it comes a MySQL database and a docker volume for data storage.

```console
host:~$ docker volume create spex-storage
host:~$ docker network create spex-net
host:~$ docker run --name spex-mysql --network spex-net -e MYSQL_ROOT_PASSWORD=spex -d mysql:latest
```
```
# connect to the mysql container
host:~$ docker run -it --network spex-net --rm mysql mysql -h spex-mysql -u root -p
# within mysql, create a new database
spex-mysql:~$ mysql
mysql> CREATE DATABASE spex;
```

Now we can start spex, point it to the MySQL database, and mount the data storage.
```
host:~$ docker run --name spex --network spex-net -e MYSQL_ENV_DB_NAME=spex -e MYSQL_ENV_DB_USER=root -e MYSQL_ENV_DB_PASS=spex -e MYSQL_PORT_3306_TCP_ADDR=spex-mysql -v spex-storage:/home/app/webapp/specs -p 3000:80 corfr/spex
```

On first run, you'll need to manually populate the database:
```
host:~$ docker exec -ti -u app spex bash
spex:~$ cd /home/app/webapp
# if the database cannot be setup, first disable the security checks
spex:webapp$ export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
spex:webapp$ bundle exec rake db:setup
spex:webapp$ bundle exec /home/app/webapp/script/init_3gpp.rb
```

The spex website is now available on `http://localhost:3000`

### Using rake (development)

```
bundle install
bundle exec rails server
```

To populate the database, use:
```
bundle exec rake db:setup
scripts/init_3gpp.rb
```

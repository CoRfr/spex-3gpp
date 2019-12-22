# This is speX

I found the 3GPP documents hard to find, hard to stay up-to-date, etc ...
So this is an alternative service to expose 3GPP specifications in a different architecture.

Feel free to fork.

Service is provided at http://spex.cor-net.org

## How to run the service

### Using Docker

```
docker run --name spex -p 80:80 corfr/spex
```

Image can be built from sources:
```
docker build -t spex .
```

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

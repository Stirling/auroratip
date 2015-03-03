# Auroracoin Port
This is the Auroracoin port of [TwitterCoin](https://github.com/BitcoinMafia/twittercoin). It allows you to send Auroracoin via Twitter.

# Getting started

### Set up the ENV variables

See ```.env.example``` and fill in the appropriate fields.

```SecureRandom.hex(64)``` is a good way to generate the random strings.

Go to https://dev.twitter.com, get an account and create an application.

This application will act as the Twitter Bot.

Make sure you

1. Set the callback url to http://127.0.0.1:3000 (or wherever you're running the local server)

2. Go to 'Settings', and check "Allow this application to be used to Sign in with Twitter".

3. Check "Details" to make sure these settings have been reflected, sometimes this takes 15 minutes.

4. Click "Create my access token"

5. Fill in the twitter related fields in ```.env.example```


Change the filename from ```.env.example``` to ```.env.development```, the ```.foreman``` file will load this development environment by default.

# Running the app

Set up the postgres db, you can change user/pass/dbname in ```database.yml```

```bash
$ createuser -s -r twittercoin
$ bundle exec rake db:create
$ bundle exec rake db:migrate
```

```bash
$ bundle install
```

To manage the ENV variables, we use foreman, defined the in ```Procfile```

To run the web server,
```bash
$ foreman run web
```

This actually runs
```bash
$ bundle exec puma -p $PORT -e $RACK_ENV -t 0:16
```

To run the worker that listens for incoming tweets,
```bash
$ foreman run worker
```

This actually runs,
```bash
$ bundle exec rake twitter:listen
```

Prepend your processes with ```foreman run``` if you wish the load ENV variables, e.g. ```$ foreman run rails c```


# Contributors

A big thanks to

1. https://github.com/esbullington
2. https://github.com/NathanielWroblewski


# TODO

Add some Seed data

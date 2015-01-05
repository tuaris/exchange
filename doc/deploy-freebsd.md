Deploy production server on FreeBSD 10.1 64-bit
-----------------------------------------------

### Overview

1. Setup deploy user
2. Install [Ruby](https://www.ruby-lang.org/en/)
3. Install [MySQL](http://www.mysql.com/)
4. Install [Redis](http://redis.io/)
5. Install [RabbitMQ](https://www.rabbitmq.com/)
6. Install [Zetacoind](http://getzetacoin.com)
7. Install [Nginx with Passenger](https://www.phusionpassenger.com/)
8. Install JavaScript Runtime
9. Install ImageMagick
10. Configure Peatio

### 1. Set package repository

Create (if it doesn’t exist) the Exchange package repository, and disable the defaut FreeBSD repository:

    mkdir -p /usr/local/etc/pkg/repos
    echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
    echo "Exchange: { url: "http://pkg.morante.net/exchange", enabled: yes }" > /usr/local/etc/pkg/repos/Exchange.conf

### 2. Install Ruby

Make sure your system is up-to-date.

    pkg update -f
    pkg upgrade

Installing [rbenv](https://github.com/sstephenson/rbenv) from packages

    pkg install rbenv

Install Ruby 2.1.x from packages:

    pkg install ruby

Install bundler

    pkg install rubygem-bundler

### 3. Install MySQL

    pkg install mysql56-server mysql56-client
    echo mysql_enable=\"YES\" >> /etc/rc.conf

### 4. Install Redis

Install the latest stable Redis:

    pkg install redis
    echo redis_enable=\"YES\" >> /etc/rc.conf

### 5. Install RabbitMQ

    pkg install rabbitmq
    echo rabbitmq_enable=\"YES\" >> /etc/rc.conf

    rabbitmq-plugins enable rabbitmq_management
    service rabbitmq-server restart

### 6. Install Zetacoind

    pkg install zetacoin-noX11
    echo zetacoin_enable=\"YES\" >> /etc/rc.conf

**Configure**

    edit /usr/local/etc/zetacoin.conf

Change the following lines in the zetacoin.conf with your username and password.

    # You must set rpcuser and rpcpassword to secure the JSON-RPC api
    # Please make rpcpassword to something secure, `5gKAgrJv8CQr2CGUhjVbBFLSj29HnE6YGXvfykHJzS3k` for example.
    rpcuser=INVENT_A_UNIQUE_USERNAME
    rpcpassword=INVENT_A_UNIQUE_PASSWORD
    
Add the following line to the end of zetacoin.conf

    # Notify when receiving coins
    walletnotify=/usr/local/sbin/rabbitmqadmin publish routing_key=peatio.deposit.coin payload='{"txid":"%s", "channel_key":"satoshi"}'

**Start zetacoin**

    service zetacoin start

### 7. Installing Nginx & Passenger

    pkg install nginx rubygem-passenger

Next, we need to update the Nginx configuration to point Passenger to the version of Ruby that we're using. You'll want to open up /etc/nginx/nginx.conf in your favorite editor,

    edit /usr/local/etc/nginx/nginx.conf

find the following lines, and uncomment them:

    passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
    passenger_ruby /usr/bin/ruby;
    

### 8. Install JavaScript Runtime

A JavaScript Runtime is needed for Asset Pipeline to work. Any runtime will do but Node.js is recommended.

    pkg install node
    

### 9. Install ImageMagick

    pkg install ImageMagick-nox11 gsfonts


### 10. Install git

    pkg install git

##### Clone the Source

    mkdir -p /usr/local/peatio
    git clone git://github.com/peatio/peatio.git /usr/local/peatio/current
    cd peatio/current

    Install dependency gems from packages

    pkg install www/rubygem-rails4 www/rubygem-redis-rails databases/rubygem-mysql2 devel/rubygem-daemons devel/rubygem-json devel/rubygem-jbuilder security/rubygem-bcrypt-ruby security/rubygem-omniauth devel/rubygem-settingslogic devel/rubygem-hashie net/rubygem-amqp net/rubygem-bunny devel/rubygem-enumerize www/rubygem-acts-as-taggable-on www/rubygem-kaminari-rails4 devel/rubygem-rails-observers www/rubygem-gon-rails4 devel/rubygem-eventmachine www/rubygem-em-websocket devel/rubygem-simple_form textproc/rubygem-sass-rails4 devel/rubygem-coffee-rails4 www/rubygem-uglifier www/rubygem-jquery-rails4 www/rubygem-bootstrap-sass devel/rubygem-grape devel/rubygem-grape-entity devel/rubygem-grape-swagger www/rubygem-rack-attack www/rubygem-carrierwave www/rubygem-rest-client devel/rubygem-pry-rails devel/rubygem-byebug
    
    Install remaining dependency gems using bundler

    bundle install --without development test --path vendor/bundle

##### Configure Peatio

**Prepare configure files**

    bin/init_config

**Setup Pusher**

* Peatio depends on [Pusher](http://pusher.com). A development key/secret pair for development/test is provided in `config/application.yml` (uncomment to use). PLEASE USE IT IN DEVELOPMENT/TEST ENVIRONMENT ONLY!

More details to visit [pusher official website](http://pusher.com)

    # uncomment Pusher related settings
    vim config/application.yml

**Setup bitcoind rpc endpoint**

    # replace username:password and port with the one you set in
    # username and password should only contain letters and numbers, do not use email as username
    # bitcoin.conf in previous step
    vim config/currencies.yml

**Config database settings**

    vim config/database.yml

    # Initialize the database and load the seed data
    bundle exec rake db:setup

**Precompile assets**

    bundle exec rake assets:precompile

**Run Daemons**

    # start all daemons
    bundle exec rake daemons:start

    # or start daemon one by one
    bundle exec rake daemon:matching:start
    ...

    # Daemon trade_executor can be run concurrently, e.g. below
    # line will start four trade executors, each with its own logfile.
    # Default to 1.
    TRADE_EXECUTOR=4 rake daemon:trade_executor:start

    # You can do the same when you start all daemons:
    TRADE_EXECUTOR=4 rake daemons:start

**SSL Certificate setting**

For security reason, you must setup SSL Certificate for production environment, if your SSL Certificated is been configured, please change the following line at `config/environments/production.rb`

    config.force_ssl = true

**Passenger:**

    sudo rm /etc/nginx/sites-enabled/default
    sudo ln -s /home/deploy/peatio/current/config/nginx.conf /etc/nginx/conf.d/peatio.conf
    sudo service nginx restart

**Liability Proof**

    # Add this rake task to your crontab so it runs regularly
    RAILS_ENV=production rake solvency:liability_proof


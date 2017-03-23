# Rails DCIM Portal

**Rails DCIM Portal** is an early development Ruby on Rails implementation of a data center inventory management system that integrates with [Foreman](https://github.com/theforeman/foreman).

## Installation

### Docker

Rails DCIM Portal can be deployed fairly easily with Docker.

 1. Install [Docker Engine](https://docs.docker.com/engine/installation/).
 2. Install [Docker Compose](https://docs.docker.com/compose/install/).
 3. Change your working directory (using `cd`) to where you want to deploy the app.
 4. `git clone https://github.com/buddwm/Rails_DCIM_Portal.git`
 5. `cd Rails_DCIM_Portal`
 6. Build the app with `docker-compose build`.
 7. Start the app with `docker-compose up`.  Optionally add the `-d` flag to run the app as a daemon.
 8. You can now access the app over HTTP at the server's IP address, port 3000.  If you're running this on your local machine, go to http://localhost:3000 in your web browser.

Note that Foreman is not provided here and it must be deployed separately.

### Manual

You will need to satisfy some dependencies to deploy this app manually:

 - A running MySQL server.  The database configuration file is at `Rails_DCIM_Portal/config/database.yml`.  The username `root` and the password `sharepoint` are currently hard-coded.
 - A running Redis server.  Port 6379 is currently hard-coded at `config/cable.yml` and `config/initializers/sidekiq.rb`.
 - A running Foreman server
 - Common developer tools
   - Debian/Ubuntu: `apt install build-essential`
   - RHEL/CentOS: `yum groupinstall "Development Tools"`
 - Node.JS, for rendering JavaScript
   - Debian/Ubuntu: `apt install nodejs`
   - RHEL/CentOS: `yum install nodejs`
 - FreeIPMI, for [Rubyipmi](https://github.com/logicminds/rubyipmi)
   - Debian/Ubuntu: `apt install freeipmi`
   - RHEL/CentOS: `yum install freeipmi`
 - ipmitool, for Rubyipmi
   - Debian/Ubuntu: `apt install ipmitool`
   - RHEL/CentOS: `yum install ipmitool`
 - [ipmiutil](http://ipmiutil.sourceforge.net/), for scanning IPv4 ranges for IPMI servers
   - Compile from [source](https://git.code.sf.net/p/ipmiutil/code-git) and see the file `Dockerfile-sidekiq` for installation details.
 - Bundler, for managing the app's gems

After satisfying dependencies and modifying the configuration files as necessary, install the gems:

    cd /path/to/Rails_DCIM_Portal
    bundle install

Before starting the app, take note of the currently customizable environment variables:

| Variable | Purpose
| --- | ---
| `DCIM_PORTAL_DATABASE_HOST` | The MySQL hostname to use.  Specify `localhost` if you want to connect to the socket `/var/run/mysqld/mysqld.sock`.
| `DCIM_PORTAL_REDIS_HOST` | The Redis hostname to use
| `FOREMAN_URL` | The Foreman URL to which Apipie will connect for Foreman API service
| `FOREMAN_USERNAME` | The Foreman admin username
| `FOREMAN_PASSWORD` | The Foreman admin password

In a separate session or service, up Sidekiq, the background jobs manager:

    bundle exec sidekiq

If this is your first run or you have upgraded the app, set up the database tables:

    rails db:migrate RAILS_ENV=development

Start the app and listen on port 3000:

    bundle exec rails s -p 3000 -b '0.0.0.0'

You can now access the app over HTTP at the server's IP address, port 3000.  If you're running this on your local machine, go to http://localhost:3000 in your web browser.

## Features

The only feature implemented so far is the IPMI scanner, which you can access at `/ilo_scan_jobs` in your web browser.  If you're running the app on your local machine, go to [http://localhost:3000/ilo_scan_jobs](http://localhost:3000/ilo_scan_jobs).

## Documentation

![Soon…ish.](https://i.imgur.com/oEbr2Sw.jpg)

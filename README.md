# Rails DCIM Portal

[![Latest release](https://img.shields.io/github/release/buddwm/Rails_DCIM_Portal/all.svg)](https://github.com/buddwm/Rails_DCIM_Portal/releases)
[![Latest tag](https://img.shields.io/github/tag/buddwm/Rails_DCIM_Portal.svg)](https://github.com/buddwm/Rails_DCIM_Portal/tags)

**Rails DCIM Portal** is an early development Ruby on Rails implementation of a data center inventory management system that integrates with [Foreman](https://github.com/theforeman/foreman).

## Prerequisites

This app is meant to integrate with other software.  The software may be run all on one machine/container, split into different machines/containers, or combined in any way among these categories:

 - **App server** – Runs this app, which interfaces with Foreman for inventory and Foreman's Smart Proxies for inventory that has not yet been added to Foreman
 - **Foreman server** – Runs Foreman, which is the single source of truth for inventory information and operations
 - **Smart Proxy server(s)** – Runs Smart Proxy, which allows the app and Foreman to communicate with your infrastructure

### Base Prerequisites

Before installing, these prerequisites need to be satisfied:

#### App server only

 - [**Git**](https://git-scm.com/) (>= 1.6.6) – Downloads the latest build of this app
   - _Suggested installation:_ Install the `git` package using your operating system's package manager or [download and install Git manually](https://git-scm.com/download/) if your operating system does not have a package manager.

#### Foreman server only

 - [**Foreman**](https://theforeman.org/) (>= 1.12) – This app synchronizes data with Foreman, which is the source of truth.
   - _Suggested installation:_ Use the interactive Foreman installer, `foreman-installer -i` as documented in [the Foreman manual](https://theforeman.org/manuals/latest/).
 - [**Foreman - Discovery**](https://github.com/theforeman/foreman_discovery) (>= 6.0.0) – Handles discovered hosts in Foreman when this app onboards them
   - _Suggested installation:_ Use the interactive Foreman installer, `foreman-installer -i`, and enable `foreman_plugin_discovery`.

#### Smart Proxy server only

 - [**Smart Proxy**](https://github.com/theforeman/smart-proxy) (>= 1.16) – This app uses Smart Proxy to control data center inventory that is accessible to the Smart Proxy.
   - _Suggested installation:_ Use the interactive Foreman installer, `foreman-installer -i`, and enable `foreman_proxy` with these options set to true: `ssl`, `templates`, `tftp`, `dhcp`, `bmc`
   - This app needs a client certificate authorized by all Smart Proxies intended to be used.
   - The certificate chains for the app and the Smart Proxies need to be signed by the same certificate authority.
   - The app's client certificate hostname needs to be added to `:trusted_hosts` in each Smart Proxy's `/etc/foreman-proxy/settings.yml`.
 - [**IPMItool**](https://sourceforge.net/projects/ipmitool/) (>= 1.8) – For interacting with IPMI BMC hosts, this app needs IPMItool because IPMItool is more reliable at some operations, like manipulating chassis power, than FreeIPMI.
   - _Suggested installation:_ Install the `ipmitool` package using your operating system's package manager or [download and install IPMItool manually](https://sourceforge.net/projects/ipmitool/) if your operating system does not have a package manager.
 - [**FreeIPMI**](https://www.gnu.org/software/freeipmi/) (>= 1.4) – For interacting with IPMI BMC hosts, this app needs FreeIPMI because FreeIPMI is more reliable at some operations, like returning useful error messages and obtaining FRU lists, than IPMItool.
   - _Suggested installation:_ Install the `freeipmi` package using your operating system's package manager or [download and install FreeIPMI manually](https://www.gnu.org/software/freeipmi/download.html) if your operating system does not have a package manager.
 - [**Smart Proxy - Discovery**](https://github.com/theforeman/smart_proxy_discovery) (>= 1.0.3) – Enables communication between Foreman and discovered hosts accessible to each Smart Proxy
   - _Suggested installation:_ Use the interactive Foreman installer, `foreman-installer -i`, and enable `foreman_proxy_plugin_discovery`.
 - [**Smart Proxy - Onboard**](https://github.com/Deltik/smart_proxy_onboard) (>= 0.2.0) – Extended functionality for Smart Proxy needed by this app
   - _Suggested installation:_ Follow the instructions [here](https://github.com/Deltik/smart_proxy_onboard#installation).

### Docker Installation Prerequisites

In addition to the base prerequisites, these additional prerequisites need to be satisfied for Docker deployments on the app server:

 - [**Docker Engine**](https://docs.docker.com/engine/) (>= 1.10) – Runs the containerized version of this app
   - [_Suggested installation instructions_](https://docs.docker.com/engine/installation/)
 - [**Docker Compose**](https://docs.docker.com/compose/) (>= 1.10) – Constructs and starts up the containers for this app
   - [_Suggested installation instructions_](https://docs.docker.com/compose/install/)

### Manual Installation Prerequisites

In addition to the base prerequisites, these additional prerequisites need to be satisfied for manual deployments on the app server:

 - [**Ruby**](https://www.ruby-lang.org/) (>= 2.5) – This app is written in Ruby.
   - _Suggested installation:_ Latest stable version of Ruby with [rbenv](https://github.com/rbenv/rbenv#readme) and [ruby-build](https://github.com/rbenv/ruby-build#readme):

         rbenv install "$(rbenv install -l | grep -v - | tail -1 | xargs)"
 - [**Bundler**](https://bundler.io/) (>= 1.6.0) – Easily installs and updates the dependencies for this app
   - _Suggested installation:_ `gem install bundler`
 - [**MariaDB Server**](https://mariadb.org/) (>= 5.6.4) or any MySQL-compatible server
   - _Suggested installation:_ You may use the same MySQL backend as Foreman.  If you don't want to do this, install the `mariadb-server` package using your operating system's package manager, or [download and install MariaDB Server](https://mariadb.org/download/) manually if your operating system does not have a package manager.  Alternatively, you may use MySQL server clustering software like [Percona XtraDB Cluster](https://www.percona.com/software/mysql-database/percona-xtradb-cluster).
 - **MySQL development headers** (>= 5.6.4) – For the `mysql2` gem
   - _Suggested installation for Ubuntu/Debian_: `apt install -y libmysqlclient-dev`
   - _Suggested installation for RHEL/CentOS_: `yum install -y mysql-devel`
 - [**Redis**](https://redis.io/) (>= 2.8) – Sidekiq job queuing and Action Cable WebSockets updates
   - _Suggested installation:_ Follow the [Redis Quick Start](https://redis.io/topics/quickstart) to install an up-to-date version of Redis or install `redis-server` and `redis-tools` on Debian/Ubuntu or install `redis` on Fedora/EPEL.

## Installation

### Docker

Rails DCIM Portal can be deployed fairly easily with Docker.  The Docker Compose file includes the MySQL database, Redis, Sidekiq, and the app.

 1. Change your working directory (using `cd`) to where you want to deploy the app.
 2. `git clone https://github.com/buddwm/Rails_DCIM_Portal.git`
 3. `cd Rails_DCIM_Portal`
 4. Build the app with `docker-compose build`.
 5. Start the app with `docker-compose up`.  Optionally add the `-d` flag to run the app as a daemon.
 6. You can now access the app over HTTP at the server's IP address, port 3000.  If you're running this on your local machine, go to http://localhost:3000 in your web browser.

Note that Foreman and the other [prerequisites](#prerequisites) are not provided here; they must be deployed separately.

### Manual

 1. Change your working directory (using `cd`) to where you want to deploy the app.
 2. `git clone https://github.com/buddwm/Rails_DCIM_Portal.git`
 3. `cd Rails_DCIM_Portal`
 4. Install the gem dependencies with `bundle install`.
 5. Ensure that MariaDB is running at `ENV['DCIM_PORTAL_DB_HOST']` on port `ENV['DCIM_PORTAL_DB_PORT']` with username `ENV['DCIM_PORTAL_DB_USERNAME']` identified by password `ENV['DCIM_PORTAL_DB_PASSWORD']` granted all privileges on database `ENV['DCIM_PORTAL_DB_DEV']`.
 6. Ensure that Foreman is running at `ENV['FOREMAN_URL']` and can authenticate the admin user `ENV['FOREMAN_USERNAME']` with password `ENV['FOREMAN_PASSWORD']`.
 7. If you have not already done so, generate a PEM certificate located at `ENV['SP_CERT']` with private key at `ENV['SP_PRIVKEY']` for the app, which will be used to validate the client to each Smart Proxy.  The CA certificate should be copied to `ENV['SP_CA_CERT']`.
    - _Suggested installation:_
      1. Run `puppet agent --test --waitforcert 60 --server FOREMAN_HOSTNAME`, where `FOREMAN_HOSTNAME` is the hostname of your Foreman/Smart Proxy Puppet CA.
      2. On the Puppet CA, sign the new request with `puppet cert sign` followed by the app's hostname.
      3. In the app's host, the environment variables can then be set as follows: `SP_CA_CERT` to `/var/lib/puppet/ssl/certs/ca.pem`, `SP_CERT` to `/var/lib/puppet/ssl/certs/APP_HOSTNAME.pem`, where `APP_HOSTNAME` is the hostname of the app.  `SP_PRIVKEY` can be set to `/var/lib/puppet/ssl/private_keys/APP_HOSTNAME.pem` if the app's user belongs to the group `puppet`.
 8. If you have not already done so, add the app's hostname to `:trusted_hosts` in the file `/etc/foreman-proxy/settings.yml` of every Smart Proxy with which the app is expected to interact.

Before starting the app, take note of the currently customizable environment variables:

| Variable | Purpose
| --- | ---
| `DCIM_PORTAL_DB_HOST` | The MariaDB hostname to use.  Specify `localhost` if you want to connect to the socket `/var/run/mysqld/mysqld.sock`.  Defaults to `127.0.0.1`
| `DCIM_PORTAL_DB_USERNAME` | The MariaDB username to use.  Defaults to `root`
| `DCIM_PORTAL_DB_PASSWORD` | The MariaDB password to use.  Defaults to `sharepoint`
| `DCIM_PORTAL_DB_PORT` | The MariaDB port to use.  Defaults to `3306`
| `DCIM_PORTAL_DB` | The catch-all MariaDB database name.  Undefined by default
| `DCIM_PORTAL_DB_DEV` | The development database name.  Defaults to `dcim_portal_development` but the default is overridden by `ENV['DCIM_PORTAL_DB']`
| `DCIM_PORTAL_DB_TEST` | The test database name.  Defaults to `dcim_portal_test` but the default is overridden by `ENV['DCIM_PORTAL_DB']`
| `DCIM_PORTAL_DB_PROD` | The production database name.  Defaults to `dcim_portal_production` but the default is overridden by `ENV['DCIM_PORTAL_DB']`
| `DCIM_PORTAL_DB_POOL_SIZE` | The size of the database connection pool.  Defaults to `ENV['RAILS_MAX_THREADS']` or `5`, whichever is defined first
| `DCIM_PORTAL_REDIS_HOST` | The Redis hostname to use for Sidekiq and Action Cable.  Redis Sentinels are not supported at this time.  Defaults to `localhost`
| `DCIM_PORTAL_REDIS_PORT` | The Redis port to use for Sidekiq and Action Cable.  Defaults to `6379`
| `DCIM_PORTAL_REDIS_DATABASE_FOR_SIDEKIQ` | The Redis database name for Sidekiq.  Defaults to `1`
| `DCIM_PORTAL_REDIS_DATABASE_FOR_CABLE` | The Redis database name for Action Cable.  Defaults to `2`
| `FOREMAN_URL` | The Foreman URL to which the app will connect for Foreman API service
| `FOREMAN_USERNAME` | The Foreman admin username.  Defaults to `admin`
| `FOREMAN_PASSWORD` | The Foreman admin password
| `SP_CA_CERT` | The absolute path to the Smart Proxy client certificate authority certificate.  Must be the same as all Smart Proxies accessed by this app, meaning the same certificate authority needs to sign the Smart Proxies' certificates as well as the app's client certificate
| `SP_CERT` | The absolute path to the client PEM-encoded certificate, signed by the same CA as the Smart Proxies' CA
| `SP_PRIVKEY` | The absolute path to the client PEM-encoded private key

In a separate session or service, up Sidekiq, the background jobs manager:

    bundle exec sidekiq

If this is your first run or you have upgraded the app, set up the database tables:

    rails db:migrate RAILS_ENV=development

Start the app and listen on port 3000:

    bundle exec rails s -p 3000 -b '0.0.0.0'

You can now access the app over HTTP at the server's IP address, port 3000.  If you're running this on your local machine, go to http://localhost:3000 in your web browser.

## Features

Because this app is in early development, features are being filled in as fast as development is taking place.  Refer to [the releases page](https://github.com/buddwm/Rails_DCIM_Portal/releases) for highlights on implemented features.

As development stabilizes, this section may be updated to contain a feature overview.

## Documentation

![Soon…ish.](https://i.imgur.com/oEbr2Sw.jpg)

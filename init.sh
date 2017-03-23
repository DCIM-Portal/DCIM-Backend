#!/bin/bash

#if ! type ipmiutil > /dev/null
#then
#	owd="$(pwd)"
#	cd /tmp
#	git clone https://git.code.sf.net/p/ipmiutil/code-git ipmiutil-code-git
#	cd ipmiutil-code-git
#	./configure
#	make install -j "$(nproc)"
#	cd "$owd"
#fi

rm -fv /Rails_DCIM_Portal/tmp/pids/server.pid
rails db:migrate RAILS_ENV=development
bundle exec rails s -p 3000 -b '0.0.0.0'

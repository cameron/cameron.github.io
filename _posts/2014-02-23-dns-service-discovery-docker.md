---
layout: post
title: "Service Discovery with DNS and Docker"
description: "Service discovery can be a brittle part of application architecture, but it doesn't have to be."
category: articles
tags: [devops, docker, dns, service discovery, dns-sd]
image:
  feature: post.wallless-room.jpg
---

*Quickstart: [Skydock](https://github.com/crosbymichael/skydock) will give you DNS-based service discovery (DNS-SD) for your docker containers in less than five minutes. Running Docker inside Vagrant? That'll be another five minutes: [Vagrant Skydocking](http://www.asbjornenge.com/wwc/vagrant_skydocking.html).*

# Service Discovery: An Evolutionary Primer

As soon as your application grows beyond a single process, you'll have to pick an approach *service discovery*, or the mechanism by which an application's services discover and connect to one another.

### Hard-coded in App Source

It's a stretch to call this "discovery" of any kind, but it's usually the first step:

{% highlight python %}
# api-server.py
import db
conn = db.connect(host='localhost', port=1234)
{% endhighlight %}

Hard-coding the location of our database service works when our db and web processes live on the same host, **but imagine we want** to run our tests against a fresh database instance (on a different port, to avoid collisions)&mdash;the app will need to know which port to use depending on its environment (dev or test).

### Hard-coded in App Config

{% highlight python %}
### api-server.py ###
import db
import config
conn = db.connect(host='localhost', port=config.db_port)

### config.py ###
import sys
# a CLI testing flag
test = len(sys.argv) > 1 and sys.argv[1] == '--test'
db_port = test and 5001 or 5000
{% endhighlight %}

Great! We can boot up test database on 5001 and our test web process will be from saved the vicissitudes of our dev db when we run it with `--test`. We can also wipe it without fear of losing data relevant to our present work.

**But imagine we have** enough tests that we need to parallelize them to finish in a reasonable amount of time, so we want to spin up a new web process and database per test suite, and our config file is beginning to look ill-equiped for the job. It'd be great if we could just tell the web process when we start it where to look for the database.

### Environment Variables

{% highlight python %}
# api-server.py
import db
import os
conn = db.connect(host=os.env.DB_HOST, port=os.env.DB_PORT)
{% endhighlight %}

Cool! Almost for free, we got an easy way to anticipate running the database and web server on separate hosts by replacing `localhost` with `os.env.DB_HOST`.

Of course, the `os.env` values have to come from somewhere, and that somewhere is usually a brittle configuration file or run script that launches the service instances: `$ DB_HOST=<IP> DB_PORT=<PORT> python api-server.py`. So we've gained flexibility in exchange for responsibility.

Truth be told, environment variables will get you a long way, but as soon as you add a new server, change your build/test process, or anything related, you'll need to edit the scripts you wrote to manage the environment variables.

Thanks, but no thanks.

### A Service Registry

Heaven is a world where services consult an omniscient registry for the locations of their peers. This makes moving your application from one context to another *a dream*; no hard-coded URLs that require manual maintainence, no brittle configuration or launch scripts that make scaling scary. Of course, the registry needs to be configured, but the services themselves can do much of this work by self-registering as they come online (which leaves you with the relatively simple task of launching them).

`etcd` is a daemon built into CoreOS for just this purpose, and in fact DNS, the protocol responsible for turning IP addresses into anthro-friendly domain names, is capable of doing the same (sometimes called DNS-SD), though these two are by no means alone. The [CoreOS docs](https://coreos.com/docs/) are great resources for single- and multi-host setups, and the links at the [top of the article](/#main) will get you setup with DNS-SD in no time (note: the SkyDNS-Docker combo that delivers DNS-SD currently only supports a single host, but read on).

### SD-DNS

The SkyDNS and CoreOS teams are working together to make multi-host DNS-based service discovery an off-the shelf feature of CoreOS. This is going to be the icing on the cake of an already game-changing stack for deploying applications. There's already a docker-powered heroku clone in 100 lines of bash ([dokku](https://github.com/progrium/dokku)), a [Docker-powered CI platform](http://www.performanceci.com/), and a variety of other Docker-inspired tools emerging, so keep your eyes peeled.

---
[DNS-SD](https://www.google.com/search?q=dns-sd) has been around for a while. InfoQ has an [article](http://www.infoq.com/articles/rest-discovery-dns) on how SRV, TXT, and PTR DNS records can work together round out the featureset.

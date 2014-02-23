---
layout: post
title: "Docker, Service Discovery, and DNS"
tagline: "Because domain names > ports and IPs."
description: "Tired of stuffing your application environments full of IPs and ports for service discovery? DNS to the rescue."
category: articles
tags: [devops, docker, dns]
image:
  feature: post.wallless-room.jpg
---

After publishing [Cooking with Docker and CoreOS on OS X](/articles/docker-coreos-osx/), I discovered I wanted a cleaner service discovery mechanism than `-link` offered.

And then I found [Skydock](https://github.com/crosbymichael/skydock), and [Vagrant Skydocking](http://www.asbjornenge.com/wwc/vagrant_skydocking.html). The former is Michael Crosby's approach to using SkyDNS for service discovery with docker containers, and the latter is Asborn Enge's adaption to doing so inside a Vagrant VM such that your services' domain names resolve from the Vagrant host (in my case, OS X).

When you're done, you'll run containers like this:

{% highlight bash %}
docker run -d -P -name api0 my-project/api
{% endhighlight %}

And, assuming `my-project/web` is an image that runs a webserver on port 80, you'll be able to visit it from your browser at `http://api0.api.dev.docker`. For testing and deplying, you'll have a seperate `skydock` container running in each context with the appropriate environment segment specified (e.g., `test` or `prod`), and in your application code referencing service URLs, you'll swap `dev` out with `test` or `prod`, and all will be well.

---
layout: post
title: "Cooking with Docker and CoreOS on OS X"
description: "There's a lot Docker workflow tutorials out there. For OS X, none of them cut it."
category: articles
tags: [docker, lxc, linux, coreos, osx, devtools]
image:
  feature: post.bliss.jpg
---

*This posts assumes some familiarity with Docker&mdash;it's a practical guide to a workflow on OS X.*

## The Problem
Docker is hot. It represents a significant addition to the second derivative of the state of our art. And while there are plenty of tutorials on using Docker floating around, none of them left me with all of the functionality I needed, or a clear picture of how to do real work. I have been frustrated, tickled, and tantalized. Docker, you were a real tease&mdash;until today.

## The Solution

When you're finished, you should have a native docker client, container ports that are easily accessible via localhost, and the ability to edit files on live containers from the comfort of your own `$EDITOR`.

## The Recipe

Preheat the oven: install [Vagrant][vagrant] and [VirtualBox][virtualbox]. Then download docker:

[vagrant]: http://vagrantup.com/
[virtualbox]: https://www.virtualbox.org/

{% highlight bash %}
curl -o docker http://get.docker.io/builds/Darwin/x86_64/docker-latest
chmod +x docker
# look for the docker daemon on tcp instead of unix
# (good idea to put this in .bashrc or similar)
export DOCKER_HOST=tcp://
sudo cp docker /usr/local/bin/
{% endhighlight %}

### The Docker Daemon: in CoreOS via Vagrant
{% highlight bash %}
git clone https://github.com/coreos/coreos-vagrant/
cd coreos-vagrant
$EDITOR Vagrantfile
{% endhighlight %}

We'll edit the `Vagrantfile` to setup an NFS share (for editing container files) and port forwarding (for visiting our beautiful applications via localhost):

{% highlight ruby %}
  # make sure these lines are present and not commented
  # and replace /Users/cam/src with your own
  config.vm.network "private_network", ip: "172.12.8.150"
  config.vm.synced_folder "/Users/cam/src", "/home/core/share", id: "core", :nfs => true,  :mount_options => ['nolock,vers=3,udp']

  # you'll need to add these lines
  (49000..49900).each do |port|
    config.vm.network :forwarded_port, :host => port, :guest => port
  end
{% endhighlight %}

### Install the latest docker in the VM
At time of writing, this is necessary because the docker client is native to OS X only as of 0.8, and CoreOS is still running 0.7.5, which is not on speaking terms with its younger sibling.
{% highlight bash %}
vagrant up
vagrant ssh
# you should land in /home/core, and
# see /home/core/share pointing to your host share

# install docker
wget --no-check-certificate https://get.docker.io/builds/Linux/x86_64/docker-latest -O docker
chmod +x docker
{% endhighlight %}


Add a service for the downloaded docker:

{% highlight  bash %}
vi /media/state/units/docker-local.service
# copy the block below into the file above
[Unit]
Description=docker local

[Service]
PermissionsStartOnly=true
ExecStartPre=/usr/bin/systemctl kill docker.service
ExecStart=/home/core/docker -H 0.0.0.0:4243 -H unix:///var/run/docker.sock -d

[Install]
WantedBy=local.target
{% endhighlight %}

Kill the 0.7.5 docker daemon and start 0.8:

{% highlight bash %}
sudo systemctl restart local-enable.service
{% endhighlight %}

If you make subsequent modifications to the new service file, you'll need to restart it with a different incantation:

{% highlight bash %}
sudo systemctl restart docker-local.service
{% endhighlight %}

### Something smells delicious...

{% highlight bash %}
# from your os x terminal
> docker version
Client version: 0.8.0
Go version (client): go1.2
Git commit (client): cc3a8c8
Server version: 0.8.0
Git commit (server): cc3a8c8
Go version (server): go1.2
{% endhighlight %}

### Docker is served

Garnish your `docker run` commands with a spring of `-v`, and your containers will share files with your local file system via the vm.

{% highlight bash %}
# on the osx host, in /Users/cam/src/hey-ma
docker build -t camron/hey-ma .

# run the container with a volume that links it to the vm's shared
# folder, which is synced with a folder on the host machine
docker run -v /home/core/share/hey-ma:/hey-ma camron/hey-ma /bin/bash
cd hey-ma; python server.py
# hack hack hack in /Users/cam/src/hey-ma
# Ctrl-C
python server.py
# new code!
{% endhighlight %}

Woot!

There is one hiccough, which is that I get an error running a container with a volume if the volume directory already exists in the container, which it is wont to do if you're maintaining a Dockerfile (which you should) and using the `ADD . /dir` build strategy (which is good). This is, however, the approach explicitly proscribed and used by @jpetazzo, so I bet I'm doing something wrong, or there is a bug that will get fixed soon. (In the meantime, however, I haven't found it problematic to mount the volume elsewhere.)

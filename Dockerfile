FROM ubuntu
MAINTAINER cameron.boehmer@gmail.com

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get -y update; apt-get -y upgrade

RUN apt-get -y install rubygems build-essential
RUN gem install json
RUN gem install --no-ri --no-rdoc jekyll
RUN gem install kramdown
RUN gem uninstall directory_watcher
RUN gem install directory_watcher -v 1.4.1

EXPOSE 80
VOLUME /src
WORKDIR /src
CMD jekyll serve --watch --port 80
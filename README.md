# KNF Guard : secure WWW for kids

[![Build Status](https://travis-ci.org/fkocik/guard.svg?branch=master)](https://travis-ci.org/fkocik/guard)

## Architecture

**KNF Guard** is a *Docker* HTTP/HTTPS filtering proxy appliance based on :

* [E2Guardian](http://e2guardian.org/cms/index.php) filter engine
* [Squid](http://www.squid-cache.org/) proxy engine
* [Université Toulouse 1 Capitole](https://dsi.ut-capitole.fr/blacklists/) blacklist repository

In order to be efficient, the applicance must be connected to a secure search enabled `DNS` server
that enforces **Google SafeSearch**, **Bing secure**, **Youtube restricted** modes and others.

## Deployment

### Requirements

A **Linux x86/64** PC with **Docker 17.09-ce** or newer installed and running.

### Main engine

Proxy engine can be deployed with the following command :

`docker run -t --name proxy -d -p 8080:8080 fkocik/guard` 

Then **docker start** the engine at boot time with your favorite init system.

You can then deploy a firewall and configure your children's navigator to use your
**Linux PC** as *WWW Proxy* on port **8080** for all protocols.

#### Special notice about SSL

In order to allow ***SSL*** web filtering, the proxy will make a *Man In The Middle*
attack : so you must extract the `/etc/e2guardian/certs/ca.crt` certificate from the
proxy engine (`docker cp proxy:/etc/e2guardian/certs/ca.crt .`) and install it as a
*Trusted Certificate Authority* in each of your children navigator.

Note that this certificate is generated at build time. If you want to preserve it when
updating the image, save it in the host system with its key 
(`/etc/e2guardian/certs/ca.key`) and run new version with :
```
docker run -t --name proxy -d -p 8080:8080 \
  -v /path/to/ca.crt:/etc/e2guardian/certs/ca.crt \
  -v /path/to/ca.key:/etc/e2guardian/certs/ca.key \
  fkocik/guard
```

### Log analysis

In order to make good control of your children browsing activity, you can deploy a
**FluentD** log collector using the [fluentd.conf](fluentd/fluentd.conf) sample 
configuration provided in this repository.

For example, the forwarder used in this sample configuration writes collected data 
in a 3 nodes **Elasticsearch** cluster to allow data mining through **Kibana**
(see [fluentd-plugin-elasticsearch](https://github.com/uken/fluent-plugin-elasticsearch)
for more details about using **FluentD** with **ElasticSearch**).

To externalize log file, starts the proxy engine with a named log volume :

`docker run -t --name proxy -d -v guardlog:/var/log -p 8080:8080 registry:5000/guard`

Then mount *guardlog* volume in a **FluentD** container using the sample configuration:
```
docker run -t --name loggrabber -d \
  -v /path/to/confdir:/fluentd/etc \
  -e FLUENTD_CONF=fluentd.conf \
  -v guardlog:/fluentd/log \
  fluent/fluentd
```



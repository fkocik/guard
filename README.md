# KNF Guard : secure WWW for childs

## Architecture

**KNF Guard** is a *Docker* HTTP/HTTPS filtering proxy appliance based on :

* [E2Guardian](http://e2guardian.org/cms/index.php) filter engine
* [Squid](http://www.squid-cache.org/) proxy engine
* [Université Toulouse 1 Capitole](https://dsi.ut-capitole.fr/blacklists/) blacklist repository

In order to be efficient, the applicance must be connected to a secure search enabled `DNS` server
that enforces **Google SafeSearch**, **Bing secure**, **Youtube restricted** modes and others
(see [guard.safe.zone](http://git.node.knf.local:3000/KRIN/bind/src/grandfonds/guard.safe.zone) for
non exhaustive sample).

## Deployment

### Requirements

A **KRIN** connected **Linux x86/64** PC with **Docker 17.09-ce** or newer 
installed and running.

A `DNS`/*hosts* entry named `registry` that points to `registry.node.knf.local`.

### Main engine

Proxy engine can be deployed with the following command :

`docker run -t --name proxy -d -p 8080:8080 registry:5000/guard` 

Then **docker start** the engine at boot time with your favorite init system.

You can then deploy a firewall and configure your children's navigator to use your
**Linux PC** as *WWW Proxy* on port **8080** for all protocols.

#### Special notice about SSL

In order to allow ***SSL*** web filtering, the proxy will make a *Man In The Middle*
attack : so you must extract the `/etc/e2guardian/certs/ca.crt` certificate from the
proxy engine (`docker cp proxy:/etc/e2guardian/certs/ca.crt .`) and install it as a
*Trusted Certificate Authority* in each of your children navigator.

### Log analysis

In order to make good control of your children browsing activity, you can deploy a
**FluentD** log collector using the [fluentd.conf](fluentd/fluentd.conf) sample 
configuration provided in this repository.

The forwarder used in this sample configuration writes collected data in a 3 nodes
**Elasticsearch** cluster to allow data mining through **Kibana**
(see [KNF Log Platform appliance](http://git.node.knf.local:3000/mandraxx/docker/src/master/appliances/README.md)
for details about log analysis tooling).

To externalize log file, starts the proxy engine with a named log volume :

`docker run -t --name proxy -d -v guardlog:/var/log -p 8080:8080 registry:5000/guard`

Then use **KNF FluentD 0.14.19** appliance to forward logs to the log platform :

`docker run -t -v /path/to/fluentd/conf:/etc/fluentd -v guardlog:/var/lib/guard/logs -v fluentd:/var/lib/fluentd registry:5000/knf/fluentd:0.14.19`


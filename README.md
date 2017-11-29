# KNF Guard : secure WWW for childs

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

### Log analysis

In order to make good control of your children browsing activity, you can deploy a
**FluentD** log collector using the [fluentd.conf](fluentd/fluentd.conf) sample 
configuration provided in this repository.

The forwarder used in this sample configuration writes collected data in a 3 nodes
**Elasticsearch** cluster to allow data mining through **Kibana**.

To externalize log file, starts the proxy engine with a named log volume :

`docker run -t --name proxy -d -v guardlog:/var/log -p 8080:8080 registry:5000/guard`

Then mount *guardlog* volume in a **FluentD** container using the sample configuration.

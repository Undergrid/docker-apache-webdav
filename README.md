
# undergrid/apache-webdav
A container providing webdav capability using [Alpine Linux](https://alpinelinux.org/) 3.7 and [Apache](https://www.apache.org/) 2.4.  By default this container provides webdav from the root the hosting domain (http://domain/) rather than a subdirectory (http://domain/webdav) as is the norm wth webdav, and is intended for use with a reverse proxy such as [jwilder/nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy/), though it can be used stand-alone.

This container is based upon the work of the [Linuxserver.io](https://www.linuxserver.io/) team.

## Usage

```
docker create \
	--name apache-webdav \
	-p 80:80 \
	-p 433:433 \
	-e PUID=<UID> \
	-e PGID=<GID> \
	-e TZ=<timezone> \ 
	-v /etc/localtime:/etc/localtime:ro \
	-v </path/to/config>:/config \
	-v </path/to/data>:/webdav \
	undergrid/apache-webdav
```
## Parameters

The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 

For example the option  `-p external:internal` defines a port mapping from internal to external of the container.  So `-p 8080:80` would expose port 80 from inside the container to be accessible from the host's IP on port 8080.  Accessing the server on http://192.168.x.x:8080 (replacing 192.168.x.x with your own IP address or fully qualified domain name) would show you what's running INSIDE the container on port 80.

* `-p 80` - the non-ssl webdav port
* `-p 443` - the ssl webdav port
* `-v /config` - apache configuration
* `-v /webdav` - the directory to be accessible via webdav
* `-v /etc/localtime` for timesync - see [Localtime](#localtime) for important information
* `-e TZ` for timezone information, Europe/London - see [Localtime](#localtime) for important information
* `-e PGID` for for GroupID - see below for explanation
* `-e PUID` for for UserID - see below for explanation

It is based on Alpine Linux with S6 overlay.

## Localtime

It is important that you either set `-v /etc/localtime:/etc/localtime:ro` or the TZ variable.

## User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" <sup>TM</sup>.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up webdav

### Default credentials
By default, the container accepts the following credentials:

 - Username: admin
 - Password: password

To change the password, use the following command once the container is running:
`docker exec -it apache-webdav htdigest /config/apache/user.passwd DAV-upload admin`
You will be prompted to enter a password.

### Adding additional users
To add a new user, use the following command once the container is running:
`docker exec -it apache-webdav htdigest -v /config/apache/user.passwd DAV-upload username`
replacing *username* with the desired username.  You will be prompted to enter a password.

### Allowing users to write files
By default the container limits the ability to write to the webdav directory to the admin user.  You can allow other users to write by changing the permissions in /path/to/config/apache/site-confs/default.conf

Find the following section (it appears twice, once for port 80 and once for port 443)
```
	<RequireAll>
	    Require method PUT POST DELETE PROPPATCH MKCOL COPY MOVE LOCK UNLOCK
	    Require user admin
	</RequireAll>
```
and change `Require user admin` to `Require valid-user` as shown below.
```
	<RequireAll>
	    Require method PUT POST DELETE PROPPATCH MKCOL COPY MOVE LOCK UNLOCK
	    Require valid-user
	</RequireAll>
```
You will need to restart the container after this change.

### Further Customization
You can further customize the service by, for example, creating separate directories for each user etc.  More complex configurations are left as an exercise for the user.

## Info

Monitor the logs of the container in realtime `docker logs -f apache-webdav`.

* container version number 

`docker inspect -f '{{ index .Config.Labels "build_version" }}' apache-webdav`

* image version number

`docker inspect -f '{{ index .Config.Labels "build_version" }}' undergrid/apache-webdav`

## Versions

+ **xx.03.17:** Initial Release


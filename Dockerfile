FROM undergrid/alpine-apache
MAINTAINER nick+docker@undergrid.org.uk

#install packages
RUN \
  echo "**** install webdav packages ****" && \
  apk add --no-cache apache2-webdav 

#add local files
COPY root/ /

#ports and volumes
EXPOSE 80 443
VOLUME /config
VOLUME /webdav

#!/usr/bin/env sh

set -xe

echo "========= STARTING SETUP SCRIPT ========="

setup-keymap gb gb

# rc-service networking --quiet start
# rc-service hostname --quiet restart

cat > /etc/apk/repositories << EOF; $(echo)
https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/main/
https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/community/
https://dl-cdn.alpinelinux.org/alpine/edge/testing/
EOF

setup-sshd -c openssh
apk update
apk upgrade
apk add docker
rc-update add docker default
sleep 5s
service docker start
sleep 5s

# Pulling all docker container for worload test
docker pull cloudsuite/media-streaming:server
docker pull cloudsuite/media-streaming:client
docker pull cloudsuite/media-streaming:dataset

docker pull cloudsuite/web-serving:web_server
docker pull cloudsuite/web-serving:memcached_server
docker pull cloudsuite/web-serving:db_server
docker pull cloudsuite/web-serving:faban_client

docker pull cloudsuite/data-analytics:latest

docker pull cloudsuite/graph-analytics:latest

docker pull cloudsuite/data-caching:client
docker pull cloudsuite/data-caching:server

docker pull cloudsuite/data-serving:client
docker pull cloudsuite/data-serving:server

docker pull cloudsuite/in-memory-analytics:latest

docker pull cloudsuite/web-search:server
docker pull cloudsuite/web-search:client
docker pull cloudsuite/web-search:dataset
docker pull cloudsuite/web-search:index


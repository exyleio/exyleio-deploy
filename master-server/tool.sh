#!/usr/bin/env bash

print_help() {

    echo "Exyle.io Deployment Helper Utility"
    echo "GitHub: https://github.com/exyleio/exyleio-deploy"
    echo "- Assumes it's running on Amazon Linux (based on fedora Linux)"
    echo
    echo "Commands:"
    echo "  setup"
    echo "    - Installs required programs and shit"
    echo "  restart"
    echo "    - Relaunch updated versions of the containers"
    echo "  connect | attach <redis|pocketbase|pb|api|discord|discord-bot|bot>"
    echo "    - opens a shell in the appropriate container"
    echo "  backup"
    echo "    - Creates an archive of related to be downloaded"

}

setup() {

    cd ~

    # update package repository
    sudo yum update -y

    # install git
    sudo yum install git -y

    # install docker
    sudo yum install docker -y
    sudo usermod -a -G docker ec2-user
    sudo systemctl enable docker.service
    id ec2-user
    newgrp docker

    # install docker compose
    sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    git clone https://github.com/exyleio/exyleio-deploy.git

}

restart() {

    docker compose pull
    docker compose convert >docker-compose.prod.yml
    docker compose --file docker-compose.prod.yml up --detach --build --remove-orphans

}

connect() {

    case "$1" in
    redis)
        container_name="master-server-redis-1"
        ;;
    pocketbase | pb)
        container_name="master-server-pocketbase-1"
        ;;
    api)
        container_name="master-server-api-1"
        ;;
    discord | discord-bot | bot)
        container_name="master-server-discord-bot-1"
        ;;
    *)
        echo "Nah, wrong name bro"
        exit 1
        ;;
    esac

    docker exec -it $container_name sh

}

backup() {

    # fix redis data permission
    sudo chmod -R +rw ./redis_data

    # zip everything with UTC timestamp
    zip -r exyleio-master-server-log-$(date --utc +%Y%m%d_%H%M%SZ).zip api_log pb_data redis_data

}

###
###  main
###

# cd into the directory where the script exists
# https://stackoverflow.com/a/4774063
SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"
cd $SCRIPTPATH

case $1 in
setup)
    setup
    ;;
restart)
    restart
    ;;
connect | attach)
    connect $2
    ;;
backup)
    backup
    ;;
*)
    print_help
    ;;
esac

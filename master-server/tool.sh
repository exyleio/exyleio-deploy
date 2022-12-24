#!/usr/bin/env bash

print_help() {

    echo "Exyle.io Deployment Helper Utility"
    echo "GitHub: https://github.com/exyleio/exyleio-scripts"
    echo "- Assumes it's running on Arch Linux"
    echo
    echo "Commands:"
    echo "  setup"
    echo "    - Installs required programs and shit"
    echo "  restart"
    echo "    - Updates"
    echo "  backup"
    echo "    - Creates an archive of related to be downloaded"

}

setup() {

    sudo pacman -S zip

    # install lazydocker
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

}

restart() {

    docker compose stop
    docker compose rm -f
    docker compose pull
    docker compose convert >docker-compose.prod.yml
    docker compose -f docker-compose.prod.yml up -d --remove-orphans

}

backup() {

    # fix redis data permission
    sudo chmod -R +rw ./redis_data

    # zip everything with UTC timestamp
    zip -r exyleio-master-server-log-$(date --utc +%Y%m%d_%H%M%SZ).zip api_log pb_data redis_data

}

case $1 in
setup)
    setup
    ;;
restart)
    restart
    ;;
backup)
    backup
    ;;
*)
    print_help
    ;;
esac

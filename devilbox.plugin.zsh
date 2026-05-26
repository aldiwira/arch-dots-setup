# =============================================================================
# DEVILBOX CONFIGURATION WITH REUSABLE PATH VARIABLE
# =============================================================================

export DEVILBOX_PATH="${DEVILBOX_PATH:-$HOME/Work/devilbox-ce}"


# 1. Navigasi & Shell
devilbox-dir() {
    cd "$DEVILBOX_PATH"
}

devilbox-root() {
    cd "$DEVILBOX_PATH/data/www"
}

devilbox-remote() {
    local current_dir=$(pwd)
    cd "$DEVILBOX_PATH" && sh ./shell.sh
    cd "$current_dir"
}

devilbox-config() {
    local current_dir=$(pwd)
    cd "$DEVILBOX_PATH" && vim .env
    cd "$current_dir"
}


# 2. Manajemen Container
devilbox-stop() {
    local current_dir=$(pwd)
    cd "$DEVILBOX_PATH" && docker compose stop
    cd "$current_dir"
}

devilbox-kill() {
    local current_dir=$(pwd)
    cd "$DEVILBOX_PATH" && docker compose down
    cd "$current_dir"
}


# 3. Fungsi Utama (Run & Reboot)
devilbox-reboot() {
    echo "================================"
    echo "Reboot Devilbox Config"
    echo "================================"
    echo "Stopping the process..."

    local current_dir=$(pwd)
    cd "$DEVILBOX_PATH" || return 1
    docker compose stop

    echo "================================"
    echo "Removing config data..."
    docker compose rm -f

    cd "$current_dir"
    echo "================================"
    echo "Please start again devilbox"
}

devilbox-run() {
    local current_dir=$(pwd)

    if [[ ! -d "$DEVILBOX_PATH" ]]; then
        echo "Directory $DEVILBOX_PATH does not exist"
        return 1
    fi

    cd "$DEVILBOX_PATH"

    if (( $# == 0 )); then
        docker compose up -d portainer php httpd mysql
    else
        docker compose up -d portainer "$@"
    fi

    cd "$current_dir"
}


# 4. Dispatcher
devilbox() {
    local cmd="${1:-}"
    shift 2>/dev/null || true

    case "$cmd" in
        dir)
            devilbox-dir
            ;;
        root)
            devilbox-root
            ;;
        shell|remote)
            devilbox-remote
            ;;
        config)
            devilbox-config
            ;;
        stop)
            devilbox-stop
            ;;
        kill|down)
            devilbox-kill
            ;;
        reboot)
            devilbox-reboot
            ;;
        run|start)
            devilbox-run "$@"
            ;;
        status)
            docker compose -f "$DEVILBOX_PATH/docker-compose.yml" ps --format '{{.Name}}\t{{.Ports}}\t{{.Status}}' | \
                awk -F'\t' '
                    BEGIN{printf "%-25s %-20s %s\n","NAME","PORTS","STATUS"}
                    {
                        gsub(/devilbox-ce-/,"",$1)
                        split($2,a,", ")
                        delete seen; port=""
                        for(i=1;i<=length(a);i++){
                            gsub(/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:|\[::\]:/,"",a[i])
                            gsub(/:+?/,":",a[i])
                            if(!seen[a[i]]++){
                                gsub(/->[0-9]+\/(tcp|udp)/,"",a[i])
                                gsub(/\/(tcp|udp)/,"",a[i])
                                if(port=="") port=a[i]
                                else port=port", "a[i]
                            }
                        }
                        printf "%-25s %-20s %s\n",$1,port,$3
                    }'
            ;;
        "")
            echo "Usage: devilbox <command>"
            echo ""
            echo "Commands:"
            echo "  dir       Go to Devilbox directory"
            echo "  root      Go to www root directory"
            echo "  shell     Enter Devilbox shell"
            echo "  config    Edit .env config"
            echo "  run       Start containers (optional: service names)"
            echo "  stop      Stop containers"
            echo "  kill      Down containers and networks"
            echo "  reboot    Stop and remove container configs"
            echo "  status    Show container status"
            ;;
        *)
            echo "Unknown command: $cmd"
            echo "Run 'devilbox' for usage."
            return 1
            ;;
    esac
}

# =============================================================================
# DEVILBOX CONFIGURATION WITH REUSABLE PATH VARIABLE
# =============================================================================

set -g DEVILBOX_PATH ~/Work/devilbox-ce


# 1. Navigasi & Shell
function devilbox-dir --description "Go to Devilbox directory"
    cd $DEVILBOX_PATH
end

function devilbox-root --description "Go to Devilbox www root directory"
    cd $DEVILBOX_PATH/data/www
end

function devilbox-remote --description "Enter Devilbox shell"
    cd $DEVILBOX_PATH; and sh ./shell.sh
end

function devilbox-config --description "Edit Devilbox .env config"
    set -l current_dir (pwd)
    cd $DEVILBOX_PATH; and vim .env
    cd $current_dir
end


# 2. Manajemen Container
function devilbox-stop --description "Stop Devilbox containers"
    set -l current_dir (pwd)
    cd $DEVILBOX_PATH; and docker compose stop
    cd $current_dir
end

function devilbox-kill --description "Down Devilbox containers and networks"
    set -l current_dir (pwd)
    cd $DEVILBOX_PATH; and docker compose down
    cd $current_dir
end


# 3. Fungsi Utama (Run & Reboot)
function devilbox-reboot --description "Stop and remove Devilbox container configs"
    echo "================================"
    echo "Reboot Devilbox Config"
    echo "================================"
    echo "Stopping the process..."

    set -l current_dir (pwd)
    cd $DEVILBOX_PATH; or return 1
    docker compose stop

    echo "================================"
    echo "Removing config data..."
    docker compose rm -f

    cd $current_dir
    echo "================================"
    echo "Please start again devilbox"
end

function devilbox-run --description "Run Devilbox containers with optional arguments"
    set -l current_dir (pwd)

    if test -d "$DEVILBOX_PATH"
        echo 'Directory Found'
    else
        echo "Directory $DEVILBOX_PATH does not exist"
        return 1
    end

    cd $DEVILBOX_PATH

    if test (count $argv) -eq 0
        docker compose up -d portainer php httpd mysql
    else
        docker compose up -d portainer $argv
    end

    cd $current_dir
end


# 4. Dispatcher
function devilbox --description "Devilbox CLI manager"
    set -l cmd $argv[1]
    set -l rest $argv[2..]

    switch $cmd
        case dir
            devilbox-dir
        case root
            devilbox-root
        case shell remote
            devilbox-remote
        case config
            devilbox-config
        case stop
            devilbox-stop
        case kill down
            devilbox-kill
        case reboot
            devilbox-reboot
        case run start
            devilbox-run $rest
        case status
            docker compose -f $DEVILBOX_PATH/docker-compose.yml ps --format '{{.Name}}\t{{.Ports}}\t{{.Status}}' | \
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
        case ''
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
        case '*'
            echo "Unknown command: $cmd"
            echo "Run 'devilbox' for usage."
            return 1
    end
end

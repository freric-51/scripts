#!/usr/bin/env bash

source terminal_colors.sh

# The IFS is an acronym for Internal Field Separator or Input Field Separator.
SAVEIFS=$IFS
function ifs_set {
	# to work with filenames with spaces
	IFS=$(echo -en "\n\b")
}
function ifs_restore {
	# restore $IFS
	IFS=$SAVEIFS
}

function exe_backup {
    if ! [ -d "$1" ]; then
        mkdir "$1"
    fi

    if ! [ -d "$2" ]; then
        mkdir "$2"
    fi

    if [ -z "$3" ]; then
        # rsync --checksum --times --atimes --archive
        ret1=$(cp --verbose --preserve --update "$1"/*.* "$2"  2>/dev/null)
        ret2=$(cp --verbose --preserve --update "$2"/*.* "$1"  2>/dev/null)
    else
        ret1=$(cp --verbose --preserve --update "$1"/$3 "$2"  2>/dev/null)
        ret2=$(cp --verbose --preserve --update "$2"/$3 "$1"  2>/dev/null)
    fi

    if [ "$ret1" != "" ]; then
        echo -e "${COLOR_BLUE}$ret1 ${COLOR_RED}$(date)${COLOR_RESET}"
    fi
    if [ "$ret2" != "" ]; then
        echo -e "${COLOR_BLUE}$ret2 ${COLOR_RED}$(date)${COLOR_RESET}"
    fi
}

function remove_file {
    if [ -e "$1/$3" ]; then
        # echo -e "To trash $1/$3"
        gio trash "$1/$3"
    fi
    if [ -e "$2/$3" ]; then
        # echo -e "To trash $2/$3"
        gio trash "$2/$3"
    fi
}

function dropbox_isrunning {
    #dropbox running
    exerun=$(ps -e |  grep -i dropbox | awk '{print $1}')
    if [ -z "$exerun" ]; then
        exerun=0
    fi
    echo $exerun
}

function transfer_files {
    # GITHUB folder
    A="$HOME/Documents/code/GitHub/scripts"
    B="$HOME/bin"
    if [ -d $A ]; then
        cd "$A"
        # -----------------------
        C=""
        exe_backup "$A$C" "$B$C" "backup_bin.sh"
        exe_backup "$A$C" "$B$C" "dev_pc_list.py"
        exe_backup "$A$C" "$B$C" "update_pips.py"
        exe_backup "$A$C" "$B$C" "terminal_colors.sh"
    fi

    # Net
    # movido para antes da sincronização de /bin pois há remoção de pacotes em /bin que foram copiados para /network
    A="$HOME/bin"
    B="$HOME/Dropbox/linux/bin"
    C="/Network"
    exe_backup "$A$C" "$B$C"

    A="$HOME/Documents/code/GitHub/scripts/Network"
    B="$HOME/bin/Network"
    if [ -d $A ]; then
        cd "$A"
        # -----------------------
        C=""
        exe_backup "$A$C" "$B$C" "find_devices_in_my_net.sh"
        exe_backup "$A$C" "$B$C" "rede.sh"
        exe_backup "$A$C" "$B$C" "reinicia_impressoras.sh"
        exe_backup "$A$C" "$B$C" "vpn.sh"
        exe_backup "$A$C" "$B$C" "wifi_sets.sh"
        exe_backup "$A$C" "$B$C" "terminal_colors.sh"
    fi

    A="$HOME/bin"
    B="$HOME/Dropbox/linux/bin"
    C=""
    remove_file "$A$C" "$B$C" "find_devices_in_my_net.sh"
    remove_file "$A$C" "$B$C" "rede.sh"
    remove_file "$A$C" "$B$C" "reinicia_impressoras.sh"
    remove_file "$A$C" "$B$C" "vpn.sh"
    remove_file "$A$C" "$B$C" "wifi_sets.sh"
    # Net fim

    A="$HOME/bin/Network"
    B="$HOME/bin"
    if [ -d $A ]; then
        cd "$A"
        # -----------------------
        C=""
        exe_backup "$A$C" "$B$C" "terminal_colors.sh"
    fi

    # =========================================
    A="$HOME/bin"
    B="$HOME/Dropbox/linux/bin"
    cd "$A"
    # =========================================

    # -------------------------------------------------------------
    C=""
    exe_backup "$A$C" "$B$C"

    # -------------------------------------------------------------
    C="/App.Image"
    exe_backup "$A$C" "$B$C"
    remove_file "$A$C" "$B$C" "AppImageUpdate-x86_64.AppImage"
    remove_file "$A$C" "$B$C" "avidemux_2.7.4.appImage"
    remove_file "$A$C" "$B$C" "avidemux_2.7.6.appImage"
    remove_file "$A$C" "$B$C" "avidemux_2.7.8.appImage"
    remove_file "$A$C" "$B$C" "avidemux_2.8.0.appImage"
    remove_file "$A$C" "$B$C" "balenaEtcher-1.5.45-x64.AppImage"
    remove_file "$A$C" "$B$C" "ClipGrab-3.8.14-x86_64.AppImage"
    remove_file "$A$C" "$B$C" "ClipGrab-3.9.6-x86_64.AppImage"
    remove_file "$A$C" "$B$C" "CPU-X_v3.2.4_x86_64.AppImage"
    remove_file "$A$C" "$B$C" "CPU-X-v4.0.1-x86_64.AppImage"
    remove_file "$A$C" "$B$C" "CPU-X-v4.4.0-x86_64.AppImage"
    remove_file "$A$C" "$B$C" "Franz-5.9.2.AppImage"
    remove_file "$A$C" "$B$C" "helio-3.1-x64.AppImage"

    # -------------------------------------------------------------
    C="/Converte"
    exe_backup "$A$C" "$B$C"

    # -------------------------------------------------------------
    C="/filter_torrent"
    exe_backup "$A$C" "$B$C"

    # -------------------------------------------------------------
    C="/PoucoUso.03"
    exe_backup "$A$C" "$B$C"

    for arq in $( find  $B$C/* -type f  -printf "%f\n" ); do
        # echo -e ">>>	apagar $arq"
        remove_file "$A" "$B" "$arq"
    done

    # teste 15 mar 2023 ==========================
    remove_file "$A" "$B" "aaaa bbbb cccc.txt"
    remove_file "$A" "$B" "aaaa"
    remove_file "$A" "$B" "bbbb"
    remove_file "$A" "$B" "cccc"
    remove_file "$A$C" "$B$C" "aaaa bbbb cccc.txt"
    remove_file "$A$C" "$B$C" "aaaa"
    remove_file "$A$C" "$B$C" "bbbb"
    remove_file "$A$C" "$B$C" "cccc"
    # teste 15 mar 2023 ==========================

    remove_file "$A$C" "$B$C" "update_pips (2023 02).py"
    remove_file "$A$C" "$B$C" "update_pips (cópia 1).py"
    remove_file "$A$C" "$B$C" "python_todo.txt"

    # WWW server
    A="/var/www/html"
    B="$HOME/Dropbox/linux/apache/html"
    if [ -d $A ]; then
        cd "$A"
        # -----------------------
        C=""
        exe_backup "$A$C" "$B$C"

        C="/ric.local"
        exe_backup "$A$C" "$B$C"

        C="/ric.local/public_html"
        exe_backup "$A$C" "$B$C"

        C="/ric.local/public_html/user_icons"
        exe_backup "$A$C" "$B$C"

        A="/etc/apache2"
        B="$HOME/Dropbox/linux/apache/etc/apache2"
        C=""
        exe_backup "$A$C" "$B$C" "ports.conf"
        C="/conf-available"
        exe_backup "$A$C" "$B$C" "php7.4-cgi.conf"
        C="/sites-available"
        exe_backup "$A$C" "$B$C" "adminer.conf"
        exe_backup "$A$C" "$B$C" "ric.local.conf"
    fi

    # GitHub
    A="$HOME/Documents/code/GitHub/"
    B="scripts"
    declare -a pathsArray=("automotive" "bootcamps" "collaboration" "Csharp" "Excel-VBA" "SQL" "uCPU" "Visual-Basic" "freric-51.github.io")
    for paths in ${pathsArray[@]}; do
        if [ -d "$A$paths" ]; then
            exe_backup "$A$B" "$A$paths" "git_repo.sh"
        fi
    done

}

function dropbox_start {
	dropbox start  </dev/null &>/dev/null
	while [ `dropbox_isrunning` -eq 0 ] ; do
		sleep 2
	done
}

function dropbox_stop {
	while [ `dropbox_isrunning` -gt 0 ] ; do
		dropbox stop  </dev/null &>/dev/null
		sleep 2
	done
}

# ====================
# 		Process
# ====================
PROGRAM_NAME=`basename $0 | tr 'a-z' 'A-Z'`
echo -e "$PROGRAM_NAME${COLOR_BLUE} v-2023${COLOR_RESET}"
echo -e "${COLOR_BLUE}----------------------------${COLOR_RESET}"
echo -e "${COLOR_BLUE}Inicio... verifique manualmente arquivos que devem ser apagados!${COLOR_RESET}"
echo -e "${COLOR_BLUE}----------------------------${COLOR_RESET}"
# ##################################################
ifs_set		# to accept space in file names
primeira_vez=1
while
    dropbox_stop
    transfer_files
    dropbox_start
	if [ ! -z "$1" ] ; then
		t=$(($RANDOM % 3 + 3))
        if [ $primeira_vez == 1 ] ; then
            t=1
            primeira_vez=0
        fi
        # echo -e "${COLOR_BLUE} wait $t minutes from $(date) ${COLOR_RESET}"
		let t=t*60
 		sleep $t
	fi
	[ ! -z "$1" ]
do :; done

ifs_restore	# to restore $IFS
# ##################################################
echo -e "${COLOR_BLUE} \nFim...\n ${COLOR_RESET}"

#	kill -SIGKILL $PPID

#!/usr/bin/env bash

#	30 FG ~ 40 BG ~ n + 60 Bright
#	30 Black	31 Red		32 Green	33 Yellow
#	34 Blue		35 Magenta	36 Cyan		37 White
COLOR_RESET='\033[0m'
COLOR_RED='\033[31m'
COLOR_GREEN='\033[32m'
COLOR_YELLLOW='\033[33m'
COLOR_BLUE='\033[34m'
COLOR_WHITE='\033[37m'
COLOR_WHITE_ON_BLACK='\033[37;40m'
COLOR_BLACK_ON_WHITE='\033[30;47m'
COLOR_RED_ON_GREEN='\033[31;42m'
COLOR_WHITE_ON_CYAN='\033[37;46m'

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
    echo -e "${COLOR_YELLLOW}-$1 x $2-${COLOR_RESET}"

    if ! [ -d "$1" ]; then
        mkdir "$1"
    fi

    if ! [ -d "$2" ]; then
        mkdir "$2"
    fi

    if [ -z "$3" ]; then
        ret1=$(cp --verbose --preserve --update "$1"/*.* "$2"  2>/dev/null)
        ret2=$(cp --verbose --preserve --update "$2"/*.* "$1"  2>/dev/null)
    else
        ret1=$(cp --verbose --preserve --update "$1"/$3 "$2"  2>/dev/null)
        ret2=$(cp --verbose --preserve --update "$2"/$3 "$1"  2>/dev/null)
    fi

    if [ "$ret1" != "" ]; then
        echo -e "$ret1"
    fi
    if [ "$ret2" != "" ]; then
        echo -e "$ret2"
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
    A="/home/ric/Documents/code/GitHub/scripts"
    B="/home/ric/bin"
    if [ -d $A ]; then
        cd "$A"
        # -----------------------
        C=""
        exe_backup "$A$C" "$B$C" "backup_bin.sh"
        exe_backup "$A$C" "$B$C" "dev_pc_list.py"
        exe_backup "$A$C" "$B$C" "update_pips.py"
    fi

    # Net
    # movido para antes da sincronização de /bin pois há remoção de pacotes em /bim que foram copiados para /network
    A="/home/ric/bin"
    B="/home/ric/Dropbox/linux/bin"
    C="/Network"
    exe_backup "$A$C" "$B$C"

    A="/home/ric/Documents/code/GitHub/scripts/Network"
    B="/home/ric/bin/Network"
    if [ -d $A ]; then
        cd "$A"
        # -----------------------
        C=""
        exe_backup "$A$C" "$B$C" "find_devices_in_my_net.sh"
        exe_backup "$A$C" "$B$C" "rede.sh"
        exe_backup "$A$C" "$B$C" "reinicia_impressoras.sh"
        exe_backup "$A$C" "$B$C" "vpn.sh"
        exe_backup "$A$C" "$B$C" "wifi_sets.sh"
    fi

    A="/home/ric/bin"
    B="/home/ric/Dropbox/linux/bin"
    C=""
    remove_file "$A$C" "$B$C" "find_devices_in_my_net.sh"
    remove_file "$A$C" "$B$C" "rede.sh"
    remove_file "$A$C" "$B$C" "reinicia_impressoras.sh"
    remove_file "$A$C" "$B$C" "vpn.sh"
    remove_file "$A$C" "$B$C" "wifi_sets.sh"
    # Net fim

    # =========================================
    A="/home/ric/bin"
    B="/home/ric/Dropbox/linux/bin"
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
    remove_file "$A$C" "$B$C" "ClipGrab-3.8.14-x86_64.AppImage"
    remove_file "$A$C" "$B$C" "ClipGrab-3.9.6-x86_64.AppImage"
    remove_file "$A$C" "$B$C" "CPU-X_v3.2.4_x86_64.AppImage"
    remove_file "$A$C" "$B$C" "CPU-X-v4.0.1-x86_64.AppImage"
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
    B="/home/ric/Dropbox/linux/apache/html"
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
    fi

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

echo -e "----------------------------\nInicio... verifique manualmente arquivos que devem ser apagados!\n----------------------------"

# ##################################################
ifs_set		# to accept space in file names
primeira_vez=1
while
    dropbox_stop
    transfer_files
    dropbox_start
	if [ ! -z "$1" ] ; then
		t=$(($RANDOM % 10 + 5))
        if [ $primeira_vez == 1 ] ; then
            t=1
            primeira_vez=0
        fi
		echo -e "wait $t minutes from $(date)"
		let t=t*60
 		sleep $t
	fi
	[ ! -z "$1" ]
do :; done

ifs_restore	# to restore $IFS
# ##################################################

echo -e "\nFim...\n"
#	kill -SIGKILL $PPID

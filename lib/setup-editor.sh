#!/bin/bash

. include/local.bh
. ${LIB}/log






main() {
    Backup_config

}




Backup_config() {
    local user_name=`whoami`
    local backup='backup'

    if [ ! -e ${backup} ]; then
        mkdir ${backup}
    fi

    # backup emacs config
    local emacs_dir=emacs-`date +"%Y-%m-%d"`
    local bak_emacs=${backup}/${emacs_dir}

    if [ ! -e  ${bak_emacs} ]; then
        mkdir ${bak_emacs}
    fi

    local user_path="/home/${user_name}"
    local dot_emacs=${user_path}/.emacs
    if [ -e  ${dot_emacs} ]; then
        if [ ! -e  ${bak_emacs}/dot_emacs ]; then
           cp -rf ${dot_emacs} ${bak_emacs}/dot_emacs
        fi
    fi

    local emacs_d=${user_path}/.emacs.d
    if [ -e ${emacs_d} ]; then
        exec 8>&1
        exec 1>/dev/null
        pushd ${bak_emacs}
        if [ ! -e dot_emacs.d.tar.xz ]; then
            tar -Jcf dot_emacs.d.tar.xz ${emacs_d} 2>&1 &
            wait
        fi
        popd
        exec 1>&8
        exec 8>&-
    fi

    # Log ${emacs_dir}
}







main "$@"

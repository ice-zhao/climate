#!/bin/bash

. include/local.bh
. ${LIB}/log






main() {
    # Backup_config
    Copy_editor_configuration
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
            rm -rf ${emacs_d} 2>&1
        fi
        popd
        exec 1>&8
        exec 8>&-
    fi

    # Log ${emacs_dir}
    return 0
}


Copy_editor_configuration() {
    Copy_emacs_config
    Copy_vim_config
}


Copy_emacs_config() {
    local cli_emacs_dir="${EDITOR}/emacs"
    local dot_emacs=${cli_emacs_dir}/dot_emacs
    local dot_emacs_d=${cli_emacs_dir}/dot_emacs.d
    local emacs_d_tarball="${cli_emacs_dir}/dot_emacs.d.tar.xz"

    # decompress tarball
    if [[ -e ${emacs_d_tarball} ]] && [[ ! -e ${dot_emacs_d} ]]
    then
        exec 8>&1
        exec 1>/dev/null
        pushd ${cli_emacs_dir}
        tar -Jxf ${emacs_d_tarball##*/} 2>&1 &
        wait
        popd
        exec 8>&1
        exec 8>&-
    fi

    # copy to user environment
    local user_name=`whoami`
    local home="/home/${user_name}"

    if [ -e ${dot_emacs} ]; then
        cp -rf ${dot_emacs} ${home}/.emacs
        wait
    fi

    if [ -e ${dot_emacs_d} ]; then
        cp -rf ${dot_emacs_d} ${home}/.emacs.d
        rm -rf ${dot_emacs_d}
    fi

    # Log ${cli_emacs_dir}
    return 0
}

Copy_vim_config() {

    return 0
}





main "$@"

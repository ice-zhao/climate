#!/bin/bash

. include/local.bh
. ${LIB}/log
. ${LIB}/parse






main() {
    Backup_config
    Backup_vim_config
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

    # backup vim configuration
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

    install_vim_addons
    return 0
}


install_vim_addons() {
    declare -a addons=()
    local vim_addon=`which vim-addons`
    local options="install"

    addons=(`Parse_src "${EDITOR}/vim/install"`)

    if [ -x ${vim_addon} ]; then
        for addon in ${addons[*]}; do
            # ${vim_addon} ${options} ${addon} >/dev/null 2>&1
            # Log ${addon}
            return 0
        done
    fi
}


Backup_vim_config() {
    local user_name=`whoami`
    local backup='backup'

    if [ ! -e ${backup} ]; then
        mkdir ${backup}
    fi

    # backup vim config
    local vim_dir=vim-`date +"%Y-%m-%d"`
    local bak_vim=${backup}/${vim_dir}

    if [ ! -e  ${bak_vim} ]; then
        mkdir ${bak_vim}
    fi

    local user_path="/home/${user_name}"
    local dot_vimrc="${user_path}"/.vimrc
    local etc_vim_local="/etc/vim/vimrc.local"
    if [ -f ${dot_vimrc} ]; then
        cp -rf ${dot_vimrc} ${bak_vim}/dot_vimrc
    fi

    if [ -f ${etc_vim_local} ]; then
        if [ ! -e  ${bak_vim}/etc/vim ]; then
            mkdir -p ${bak_vim}/etc/vim
        fi
        cp -rf ${etc_vim_local} ${bak_vim}/etc/vim/vimrc.local
    fi

}


















main "$@"

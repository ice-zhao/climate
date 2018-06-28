#!/bin/bash

INSTALL="apt-get"
AUTOREMOVE="--auto-remove"
OPT="install --yes -q=2 ${AUTOREMOVE}"





main() {
    Check_pkg_mgmt
    Install_pkg $@

}







Install_pkg() {
    # $1: pkg array need to install
    local pkgs=(`echo "$@"`)
    for pkg in ${pkgs[*]}; do
        ${INSTALL} ${OPT} ${pkg}
        # echo ${pkg}
    done
}

Check_pkg_mgmt() {
    local apt_lock_file='/var/lib/dpkg/lock'
    if [ -e ${apt_lock_file} ]; then
        rm -rf ${apt_lock_file}
    fi
}




main "$@"

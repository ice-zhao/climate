#!/bin/bash

INSTALL="apt-get"
AUTOREMOVE="--auto-remove"
OPT="install --yes -q=2 ${AUTOREMOVE}"





main() {
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






main "$@"

#!/bin/bash
# Program:
#   fix systemd not work with docker container, just drop it
# History:
# 2025.09.06 geekwho first release.

targetDir=${INSTALL_DIR}
if [[ -f ${targetDir}/install.sh ]]; then
    # comment startup service logic
    # systemctl enable xxx
    # systemctl start xxx
    # systemctl status xxx
    sed -i '/cp \.\/1panel-core\.service/,+23 s/^/#/' ${targetDir}/install.sh
    # comment install_and_configure start
    sed -i '/    install_and_configure/,/cp -r \.\/initscript/ s/^/# /' ${targetDir}/install.sh

    # backup install.sh
    cp ${targetDir}/install.sh ../
else
    echo "${targetDir}/install.sh not found!"
fi

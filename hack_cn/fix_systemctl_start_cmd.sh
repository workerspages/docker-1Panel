#!/bin/bash
# Program:
#   fix systemd not work with docker container, just drop it
# History:
# 2025/09/06 geekwho hack some exit logic, make it work on v2.0.11
# 2025/12/28 geekwho fix docker build fail. make it work on v2.0.13

targetDir=${INSTALL_DIR}
if [[ -f ${targetDir}/install.sh ]]; then
    # comment startup service logic
    # systemctl enable xxx
    # systemctl start xxx
    # systemctl status xxx
    sed -i '/cp \.\/1panel-core\.service/,+23 s/^/#/' ${targetDir}/install.sh
    # comment install_and_configure start
    sed -i '/log "\$TXT_PANEL_SERVICE_START_ERROR"/{n;s/^/#/}' ${targetDir}/install.sh
    #sed -i '/    install_and_configure/,/cp -r \.\/initscript/ s/^/# /' ${targetDir}/install.sh
    #sed -i 's/#     install_and_configure/    init_configure/g' ${targetDir}/install.sh
    #sed -i 's/#     cp -r \.\/initscript/     cp -r \.\/initscript/g' ${targetDir}/install.sh
    # backup install.sh
    cp ${targetDir}/install.sh ../
else
    echo "${targetDir}/install.sh not found!"
fi

#!/bin/bash

export GIT_DIR=/home/lgerber/git

cd ${GIT_DIR}
git clone --depth=1 https://github.com/lorenzgerber/linux_kernel.git

cd linux_kernel
git remote add uppstream https://github.com/raspberrypi/linux

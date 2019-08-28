#!/usr/bin/env bash
set -e -o pipefail

# Helper script to install the stuff on the local node

SRC_DIR="$(dirname $(readlink -f $0))"
M0_SRC_DIR=${M0_SRC_DIR:-${SRC_DIR%/*}/mero}

init_hax() {
    echo 'Installing Python dependencies into the virtualenv'
    local env_dir=$SRC_DIR/.env

    python3 -m venv $env_dir
    . $env_dir/bin/activate
    pip3 install -r $SRC_DIR/hax/requirements.txt
    pushd $SRC_DIR/hax >/dev/null
    echo 'Building libhax.so'
    make clean && make
    popd >/dev/null
}

create_env_file () {
    export PYTHON_EXE="$SRC_DIR/env/bin/python"
    export LD_LIB_PATH=$M0_SRC_DIR/mero/.libs/
    envsubst <$SRC_DIR/systemd/hax-environment.src >$SRC_DIR/systemd/hax-environment
}

install_systemd () {
    sudo mkdir -p /opt/seagate
    sudo ln -sfn $SRC_DIR /opt/seagate/consul
    sudo ln -sf $SRC_DIR/systemd/* /usr/lib/systemd/system/
}

init_hax
create_env_file
install_systemd

sudo systemctl daemon-reload
#!/usr/bin/env bash
set -ex

export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
    "deb [arch=$(dpkg \
    --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" >/etc/apt/sources.list.d/docker.list
apt update

apt install -y docker-ce docker-ce-cli docker-compose-plugin crun
cat <<EOF >/etc/docker/daemon.json
{
  "default-runtime": "crun",
  "runtimes": {
    "crun": {
      "path": "/usr/bin/crun"
    }
  },
  "shutdown-timeout": 5
}
EOF
systemctl enable \
--now docker

apt install -y vim gdisk e2fsprogs tmux ripgrep git

setup-disk() {
  disk="$1"
  mountpoint="$2"
  sgdisk -o "${disk}"
  sgdisk -N=1 "${disk}"
  partprobe
  systemctl daemon-reload

  mkfs.ext4 "${disk}p1"
  mkdir -p "$mountpoint"
  mount "${disk}p1" "$mountpoint"
}

setup-disk /dev/nvme0n1 /mnt/lineage

chmod 755 /root
umask 022
cd /root
git clone https://github.com/mikucat0309/lineageos-build-scripts
cd lineageos-build-scripts

docker compose up -d

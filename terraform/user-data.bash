#!/bin/bash

set -euo pipefail
set -x

id -u ubuntu &>/dev/null || adduser --disabled-password ubuntu
usermod -a -G sudo ubuntu
echo "%sudo ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/10-sudo-group-nopasswd

apt-get update
apt-get upgrade -y

apt-get install -y \
  util-linux \
  apt-transport-https \
  ca-certificates \
  strace \
  gdb \
  curl \
  git \
  make \
  python3-venv \
  screen \
  software-properties-common \
  tmux

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  edge"

apt-get update

apt-get install -y docker-ce

cat <<EOF > /lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target docker.socket firewalld.service
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd://
ExecReload=/bin/kill -s HUP \$MAINPID
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s
ProtectHome=read-only

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/mnt-scratch.automount
[Unit]
Description=Automount Scratch

[Automount]
Where=/mnt/scratch

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /etc/systemd/system/mnt-scratch.mount
[Unit]
Description=Scratch

[Mount]
What=tmpfs
Where=/mnt/scratch
Type=tmpfs

[Install]
WantedBy=multi-user.target
EOF

cat <<EOF > /bin/sleeper.sh
#!/bin/sh
nc -l -p 4242 &
while true ; do sleep 3600 ; done | nc 127.0.0.1 4242 &

while true ; do
  date
  sleep 12
  if [ -x /tmp/sleeper.sh ] ; then
    /tmp/sleeper.sh
  fi
done
EOF
chmod +x /bin/sleeper.sh

cat <<EOF > /etc/systemd/system/sleeper.service
[Service]
Type=simple
ExecStart=/bin/sleeper.sh
ProtectSystem=strict
ProtectHome=read-only
InaccessiblePaths=/usr/sbin
PrivateDevices=true
PrivateNetwork=true
ProtectKernelTunables=true
CapabilityBoundingSet=~CAP_NET_RAW
SystemCallFilter=~unshare

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable mnt-scratch.automount
systemctl start mnt-scratch.automount
systemctl enable sleeper.service
systemctl start sleeper.service
systemctl restart docker

usermod -a -G docker ubuntu


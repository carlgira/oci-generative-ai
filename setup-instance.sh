#!/bin/bash

apt-get update -y
apt-get upgrade -y
apt install nvidia-driver-515 nvidia-dkms-515 nvidia-utils-515 -y
apt install wget git python3 python3-venv -y
apt-get install ffmpeg libsm6 libxext6  -y

cat <<EOT >> /etc/systemd/system/stabble-diffusion.service
[Unit]
Description=example systemd service start stabble-diffusion

[Service]
ExecStart=/bin/bash /home/ubuntu/stable-diffusion-webui/webui.sh
User=ubuntu

[Install]
WantedBy=multi-user.target
EOT

su -c 'git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/ubuntu/stable-diffusion-webui' ubuntu
su -c "wget \"https://drive.yerf.org/wl/?id=EBfTrmcCCUAGaQBXVIj5lJmEhjoP1tgl&mode=grid&download=1\" -O /home/ubuntu/stable-diffusion-webui/model.ckpt" ubuntu

systemctl daemon-reload
systemctl enable stabble-diffusion.service
systemctl start stabble-diffusion.service

reboot

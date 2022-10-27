#!/bin/bash

apt-get update -y
apt-get upgrade -y
apt install nvidia-driver-515 nvidia-dkms-515 nvidia-utils-515 -y
apt install wget git python3 python3-pip python3-venv -y
apt-get install ffmpeg libsm6 libxext6  -y

# Stable diffusion service
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

# Bloom service
cat <<EOT >> /etc/systemd/system/bloom.service
[Unit]
Description=example systemd service start bloom

[Service]
ExecStart=python3 /home/ubuntu/bloom-webui/app.py
User=ubuntu

[Install]
WantedBy=multi-user.target
EOT

su -c 'git clone https://github.com/carlgira/bloom-webui.git /home/ubuntu/bloom-webui' ubuntu
su -c 'pip3 install -r /home/ubuntu/bloom-webui/requirements.txt' ubuntu

systemctl daemon-reload
systemctl enable stabble-diffusion.service
systemctl enable bloom.service
systemctl start bloom.service
systemctl start stabble-diffusion.service

reboot

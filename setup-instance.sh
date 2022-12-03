#!/bin/bash

apt-get update -y
apt-get upgrade -y
apt install nvidia-driver-515 nvidia-dkms-515 nvidia-utils-515 -y
apt install wget git git-lfs python3 python3-pip python3-venv unzip -y
apt-get install ffmpeg libsm6 libxext6 p7zip-full rapidjson-dev libarchive-dev zlib1g-dev -y

# Install cuda
wget -O /etc/apt/preferences.d/cuda-repository-pin-600 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" -y
apt-get update -y
apt install cuda -y
sudo -c "echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc" ubuntu

# Stable diffusion service
cat <<EOT >> /etc/systemd/system/stable-diffusion.service
[Unit]
Description=systemd service start stable-diffusion

[Service]
ExecStart=/bin/bash /home/ubuntu/stable-diffusion-webui/webui.sh
User=ubuntu

[Install]
WantedBy=multi-user.target
EOT

su -c 'git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/ubuntu/stable-diffusion-webui' ubuntu

# Bloom service
cat <<EOT >> /etc/systemd/system/bloom.service
[Unit]
Description=systemd service start bloom

[Service]
ExecStart=/bin/bash /home/ubuntu/bloom-webui/start.sh
User=ubuntu

[Install]
WantedBy=multi-user.target
EOT

su -c 'git clone https://github.com/carlgira/bloom-webui.git /home/ubuntu/bloom-webui' ubuntu

# Dreambooth service

cat <<EOT >> /etc/systemd/system/dreambooth.service
[Unit]
Description=systemd service start dreambooth

[Service]
ExecStart=/bin/bash /home/ubuntu/dreambooth-webui/start.sh
User=ubuntu

[Install]
WantedBy=multi-user.target
EOT

su -c 'git clone https://github.com/carlgira/dreambooth-webui.git /home/ubuntu/dreambooth-webui' ubuntu

systemctl daemon-reload
systemctl enable stabble-diffusion.service
systemctl enable bloom.service
systemctl enable dreambooth.service

reboot

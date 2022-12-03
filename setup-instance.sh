#!/bin/bash

main_function() {
USER='ubuntu'
apt update -y
apt install wget git git-lfs python3 python3-pip python3-venv unzip -y
apt install ffmpeg libsm6 libxext6 p7zip-full rapidjson-dev libarchive-dev zlib1g-dev -y

# Install cuda
wget -O /etc/apt/preferences.d/cuda-repository-pin-600 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" -y
apt update -y
apt install cuda -y
sudo -c "echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc" $USER

# Stable diffusion service
cat <<EOT >> /etc/systemd/system/stable-diffusion.service
[Unit]
Description=systemd service start stable-diffusion

[Service]
ExecStart=/bin/bash /home/$USER/stable-diffusion-webui/webui.sh
User=$USER

[Install]
WantedBy=multi-user.target
EOT

su -c "git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/$USER/stable-diffusion-webui" $USER
su -c "cd /home/$USER/stable-diffusion-webui; git checkout 9bbe1e3" $USER

# Bloom service
cat <<EOT >> /etc/systemd/system/bloom.service
[Unit]
Description=systemd service start bloom

[Service]
ExecStart=/bin/bash /home/$USER/bloom-webui/start.sh
User=$USER

[Install]
WantedBy=multi-user.target
EOT

su -c "git clone https://github.com/carlgira/bloom-webui.git /home/$USER/bloom-webui" $USER
su -c "cd /home/$USER/bloom-webui; git checkout e0d1a27" $USER

# Dreambooth service

cat <<EOT >> /etc/systemd/system/dreambooth.service
[Unit]
Description=systemd service start dreambooth

[Service]
ExecStart=/bin/bash /home/$USER/dreambooth-webui/start.sh
User=$USER

[Install]
WantedBy=multi-user.target
EOT

su -c "git clone https://github.com/carlgira/dreambooth-webui.git /home/$USER/dreambooth-webui" $USER
su -c "cd /home/$USER/dreambooth-webui; git checkout 4a4a354" $USER


systemctl daemon-reload
systemctl enable stable-diffusion.service
systemctl enable bloom.service
systemctl enable dreambooth.service
systemctl start stable-diffusion.service bloom.service dreambooth.service bloom.service
}

main_function 2>&1 >> /var/log/startup.log

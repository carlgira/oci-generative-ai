#!/bin/bash

main_function() {
USER='ubuntu'
apt update -y
apt install wget git git-lfs python3 python3-pip python3-venv unzip zip -y
apt install ffmpeg libsm6 libxext6 p7zip-full rapidjson-dev libarchive-dev zlib1g-dev -y

# Install cuda
wget -O /etc/apt/preferences.d/cuda-repository-pin-600 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" -y
apt update -y
apt install cuda-11-8 -y
sudo -c "echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc" $USER

# Stable diffusion service
cat <<EOT >> /etc/systemd/system/stable-diffusion.service
[Unit]
Description=systemd service start stable-diffusion

[Service]
ExecStart=/bin/bash /home/$USER/stable-diffusion-webui/webui.sh --api --xformers
User=$USER

[Install]
WantedBy=multi-user.target
EOT

su -c "git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/$USER/stable-diffusion-webui" $USER
su -c "cd /home/$USER/stable-diffusion-webui; git checkout 9bbe1e3" $USER

# Remove background extension
su -c "git clone https://github.com/KutsuyaYuki/ABG_extension /home/$USER/stable-diffusion-webui/extensions/ABG_extension" $USER
# OutPaint extension
su -c "git clone https://github.com/zero01101/openOutpaint-webUI-extension /home/$USER/stable-diffusion-webui/extensions/openOutpaint-webUI-extension" $USER
# Deforum extension
su -c "git clone https://github.com/deforum-art/deforum-for-automatic1111-webui /home/$USER/stable-diffusion-webui/extensions/deforum-for-automatic1111-webui" $USER

# Add xformers
su -c "echo https://github.com/C43H66N12O12S2/stable-diffusion-webui/releases/download/linux/xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl >> /home/$USER/stable-diffusion-webui/requirements.txt" $USER

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
su -c "cd /home/$USER/bloom-webui; git checkout f21a51d" $USER

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
su -c "cd /home/$USER/dreambooth-webui; git checkout f21a51d" $USER

# Smart Image processing service

cat <<EOT >> /etc/systemd/system/automatic-image-processing.service
[Unit]
Description=systemd service start automatic-image-processing

[Service]
ExecStart=/bin/bash /home/$USER/automatic-image-processing/start.sh
User=$USER

[Install]
WantedBy=multi-user.target
EOT

su -c "git clone https://github.com/carlgira/automatic-image-processing /home/$USER/automatic-image-processing" $USER

systemctl daemon-reload
systemctl enable stable-diffusion.service bloom.service dreambooth.service automatic-image-processing.service
systemctl start stable-diffusion.service bloom.service dreambooth.service bloom.service automatic-image-processing.service
}

main_function 2>&1 >> /var/log/startup.log

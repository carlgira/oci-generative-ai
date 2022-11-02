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
sudo apt update
sudo apt install cuda -y
sudo -c "echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc" ubuntu

# Stable diffusion service
cat <<EOT >> /etc/systemd/system/stabble-diffusion.service
[Unit]
Description=systemd service start stabble-diffusion

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
ExecStart=python3 /home/ubuntu/bloom-webui/app.py
User=ubuntu

[Install]
WantedBy=multi-user.target
EOT

su -c 'git clone https://github.com/carlgira/bloom-webui.git /home/ubuntu/bloom-webui' ubuntu
su -c 'pip3 install -r /home/ubuntu/bloom-webui/requirements.txt' ubuntu

# Dreambooth service

cat <<EOT >> /etc/systemd/system/dreambooth.service
[Unit]
Description=systemd service start dreambooth

[Service]
ExecStart=python3 /home/ubuntu/dreambooth-webui/app.py
User=ubuntu

[Install]
WantedBy=multi-user.target
EOT

su -c 'git clone https://github.com/carlgira/dreambooth-webui.git /home/ubuntu/dreambooth-webui' ubuntu
su -c 'pip3 install -r /home/ubuntu/dreambooth-webui/requirements.txt' ubuntu

WORK_DIR=/home/ubuntu/dreambooth
su -c "mkdir -p $WORK_DIR/models/stable-diffusion-v1-5" ubuntu
su -c "mkdir -p $WORK_DIR/data" ubuntu
su -c "mkdir -p $WORK_DIR/output" ubuntu

su -c "wget -O $WORK_DIR/convertosd.py https://github.com/TheLastBen/fast-stable-diffusion/raw/main/Dreambooth/convertosd.py" ubuntu
su -c "git clone https://github.com/TheLastBen/diffusers $WORK_DIR/diffusers" ubuntu

su -c "git clone https://github.com/djbielejeski/Stable-Diffusion-Regularization-Images-person_ddim.git $WORK_DIR/data/person_ddim" ubuntu
su -c "git clone https://github.com/djbielejeski/Stable-Diffusion-Regularization-Images-man_euler.git $WORK_DIR/data/man_euler" ubuntu
su -c "git clone https://github.com/djbielejeski/Stable-Diffusion-Regularization-Images-man_unsplash.git $WORK_DIR/data/man_unsplash" ubuntu
su -c "git clone https://github.com/djbielejeski/Stable-Diffusion-Regularization-Images-woman_ddim.git $WORK_DIR/data/woman_ddim" ubuntu
su -c "git clone https://github.com/djbielejeski/Stable-Diffusion-Regularization-Images-blonde_woman.git $WORK_DIR/data/blonde_woman" ubuntu

su -c "pip3 install git+https://github.com/TheLastBen/diffusers" ubuntu
su -c "pip3 install  OmegaConf accelerate==0.13.2 triton bitsandbytes" ubuntu
su -c "CUDA_HOME=/usr/local/cuda pip3 install xformers==0.0.13" ubuntu
su -c "pip3 install torch==1.12.1+cu113 torchvision==0.13.1+cu113 --extra-index-url https://download.pytorch.org/whl/cu113" ubuntu
su -c "pip3 install https://github.com/C43H66N12O12S2/stable-diffusion-webui/releases/download/linux/xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl" ubuntu

# Horrible FIX to avoid problem with CUDA_VISIBLE_DEVICES
su -c "sed -i '375s/args.gpu_ids/\"0\"/g' /home/ubuntu/.local/lib/python3.10/site-packages/accelerate/commands/launch.py" ubuntu

systemctl daemon-reload
systemctl enable stabble-diffusion.service
systemctl enable bloom.service
systemctl enable dreambooth.service

reboot

#!/bin/bash

main_function() {
USER='opc'

# Resize root partition
printf "fix\n" | parted ---pretend-input-tty /dev/sda print
VALUE=$(printf "unit s\nprint\n" | parted ---pretend-input-tty /dev/sda |  grep lvm | awk '{print $2}' | rev | cut -c2- | rev)
printf "rm 3\nIgnore\n" | parted ---pretend-input-tty /dev/sda
printf "unit s\nmkpart\n/dev/sda3\n\n$VALUE\n100%%\n" | parted ---pretend-input-tty /dev/sda
pvresize /dev/sda3
pvs
vgs
lvextend -l +100%FREE /dev/mapper/ocivolume-root
xfs_growfs -d /

dnf install wget git python3.9 python39-devel.x86_64 libsndfile rustc cargo unzip zip git git-lfs -y

# Install ffmpeg
dnf -y install https://download.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
dnf install -y https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
dnf config-manager --set-enabled ol8_codeready_builder
dnf -y install ffmpeg

# Stable diffusion service
cat <<EOT >> /etc/systemd/system/stable-diffusion.service
[Unit]
Description=systemd service start stable-diffusion

[Service]
Environment="python_cmd=python3.9"
Environment="pip_cmd=pip"
ExecStart=/bin/bash /home/$USER/stable-diffusion-webui/webui.sh --api
User=$USER

[Install]
WantedBy=multi-user.target
EOT

su -c "git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /home/$USER/stable-diffusion-webui" $USER
su -c "cd /home/$USER/stable-diffusion-webui; git checkout 2f01814" $USER # Working stable diffusion version (update if broken)


# Add xformers
su -c "echo https://github.com/C43H66N12O12S2/stable-diffusion-webui/releases/download/linux/xformers-0.0.14.dev0-cp310-cp310-linux_x86_64.whl >> /home/$USER/stable-diffusion-webui/requirements.txt" $USER

# Bloom service
cat <<EOT >> /etc/systemd/system/bloom.service
[Unit]
Description=systemd service start bloom

[Service]
Environment="python_cmd=python3.9"
Environment="pip_cmd=pip"
ExecStart=/bin/bash /home/$USER/bloom-webui/start.sh
User=$USER

[Install]
WantedBy=multi-user.target
EOT

su -c "git clone https://github.com/carlgira/bloom-webui.git /home/$USER/bloom-webui" $USER

# Dreambooth service

cat <<EOT >> /etc/systemd/system/dreambooth.service
[Unit]
Description=systemd service start dreambooth

[Service]
Environment="python_cmd=python3.9"
Environment="pip_cmd=pip"
ExecStart=/bin/bash /home/$USER/dreambooth-webui/start.sh
User=$USER

[Install]
WantedBy=multi-user.target
EOT

su -c "git clone https://github.com/carlgira/dreambooth-webui.git /home/$USER/dreambooth-webui" $USER


# Smart crop service

cat <<EOT >> /etc/systemd/system/smart-crop.service
[Unit]
Description=systemd service smart-crop

[Service]
Environment="python_cmd=python3.9"
Environment="pip_cmd=pip"
ExecStart=/bin/bash /home/$USER/smart-crop/start.sh
User=$USER

[Install]
WantedBy=multi-user.target
EOT

su -c "git clone https://github.com/carlgira/smart-crop.git /home/$USER/smart-crop" $USER


systemctl daemon-reload
systemctl enable stable-diffusion.service bloom.service dreambooth.service smart-crop.service
systemctl start stable-diffusion.service bloom.service dreambooth.service bloom.service smart-crop.service
}

main_function 2>&1 >> /var/log/startup.log

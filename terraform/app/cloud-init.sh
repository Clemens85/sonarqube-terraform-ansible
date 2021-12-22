#! /bin/bash

sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
sudo /bin/su -c "echo 'vm.max_map_count=262144' >> /etc/sysctl.d/99-sysctl.conf"
sudo /bin/su -c "echo 'fs.file-max=131072' >> /etc/sysctl.d/99-sysctl.conf"
sudo sysctl --system
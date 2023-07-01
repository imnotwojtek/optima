#!/bin/bash

# Utworzenie pliku wymiany
sudo fallocate -l 5G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Konfiguracja parametrów systemowych
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Zamontowanie pliku wymiany
sudo swapon -a

# Aktualizacja serwerów DNS
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
echo "nameserver 1.0.0.1" | sudo tee -a /etc/resolv.conf

# Dodanie informacji o stanie systemu do pliku .bashrc
echo 'cpu_usage=$(top -bn1 | grep load | awk "{print \$3}")
ram_usage=$(free | awk "/Mem:/ { print \$3/\$2 * 100.0 }")
disk_usage=$(df -h / | awk "/\// {print \$(NF-1)}")
external_ip=$(curl -s https://checkip.amazonaws.com)
internal_ip=$(hostname -I | awk "{print \$1}")
echo ""
echo "===== System Status ====="
echo "CPU Usage: \$cpu_usage%"
echo "RAM Usage: \$ram_usage%"
echo "Disk Usage: \$disk_usage"
echo "External IP: \$external_ip"
echo "Internal IP: \$internal_ip"
echo "========================="
echo ""' >> ~/.bashrc

# Aktualizacja systemu
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt clean
sudo systemctl restart systemd-journald

# Restart serwera
sudo reboot

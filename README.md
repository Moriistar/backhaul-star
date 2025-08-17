# BackhaulStar 🌟

A comprehensive and user-friendly script for setting up Backhaul tunnels with support for both Iranian and International servers.

## Features ✨

- **Dual Server Support**: Setup for both Iran (Server) and International (Client) servers
- **IPv4 & IPv6 Support**: Full support for both IP versions
- **Interactive Menu**: Easy-to-use menu system with color-coded options
- **Automatic Architecture Detection**: Supports both AMD64 and ARM64 architectures
- **Premium Backhaul Binary**: Uses premium version of Backhaul
- **Service Management**: Complete systemd service integration
- **Input Validation**: Validates IP addresses, ports, and configurations
- **Multiple Port Support**: Configure multiple port mappings easily
- **Status Monitoring**: Real-time service status and log viewing

## Quick Start 🚀

### Method 1: Direct Download and Run
```bash
wget https://raw.githubusercontent.com/MoriiStar/BackhaulStar/main/backhaul_star.sh
chmod +x backhaul_star.sh
sudo ./backhaul_star.sh
# Method 2: Clone Repository
 
git clone https://github.com/MoriiStar/BackhaulStar.git
cd BackhaulStar
chmod +x backhaul_star.sh
sudo ./backhaul_star.sh
 
System Requirements 📋
Linux-based operating system (Ubuntu, Debian, CentOS, etc.)
Root access (sudo privileges)
Internet connection for downloading binaries
Supported architectures: AMD64, ARM64
Usage Guide 📖
1. Iran Server Setup (Server Mode)
Choose option  1  from the main menu
Select IP version (IPv4 or IPv6)
Configure tunnel port for server communication
Set a secure token/password
Configure port mappings for your services
2. International Server Setup (Client Mode)
Choose option  2  from the main menu
Select IP version (IPv4 or IPv6)
Enter Iran server IP address
Use the same tunnel port and token as server
3. Service Management
Start/Stop/Restart services
View service status and logs
Enable/Disable auto-start on boot
Configuration Examples 🛠️
Server Configuration (Iran)
 
[server]
bind_addr = "0.0.0.0:2080"
transport = "tcp"
token = "mySecureToken123"
keepalive_period = 75
nodelay = true
channel_size = 2048
mux_session = 1

ports = [ 
    "80=80",
    "443=443",
    "2087=2087"
]
 
Client Configuration (International)
 
[client]
remote_addr = "1.2.3.4:2080"
transport = "tcp"
token = "mySecureToken123"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
nodelay = true 
retry_interval = 3
 
Service Management Commands 🔧
 
# Check service status
sudo systemctl status backhaul.service

# Start service
sudo systemctl start backhaul.service

# Stop service
sudo systemctl stop backhaul.service

# Restart service
sudo systemctl restart backhaul.service

# View logs
sudo journalctl -u backhaul.service -f

# Enable auto-start
sudo systemctl enable backhaul.service
 
Port Configuration Format 📝
Same input/output port: Just enter the port number (e.g.,  80 )
Different ports: Use format  input_port=output_port  (e.g.,  8080=80 )
Multiple ports: Configure as many as needed during setup
Troubleshooting 🔍
Common Issues:
Service won't start:
Check configuration:  cat /root/backhaul/config.toml 
View logs:  sudo journalctl -u backhaul.service -f 
Verify port availability:  netstat -tlnp | grep <port> 
Connection issues:
Ensure firewall allows the tunnel port
Verify IP addresses and ports match between server and client
Check token matches on both sides
Permission issues:
Run script with sudo privileges
Ensure binary has execute permissions:  chmod +x /usr/bin/backhaul 
File Locations 📁
Binary:  /usr/bin/backhaul 
Configuration:  /root/backhaul/config.toml 
Service file:  /etc/systemd/system/backhaul.service 
Script location:  ./backhaul_star.sh 
Contributing 🤝
Feel free to contribute to this project by:
Reporting bugs
Suggesting new features
Submitting pull requests
Improving documentation
License 📄
This project is open source and available under the MIT License.
Support 💬
If you encounter any issues or need help:
Check the troubleshooting section
Review the logs using the service management commands
Open an issue on GitHub
Changelog 📝
v1.0.0
Initial release
Basic server/client setup functionality
IPv4/IPv6 support
Interactive menu system
Service management integration
 
Created with ❤️ by MoriiStar
Star ⭐ this repository if you find it helpful!
 

## فایل install.sh (نصب سریع):

```bash
#!/bin/bash

# BackhaulStar Quick Installer
# This script downloads and runs the main BackhaulStar script

echo "BackhaulStar Quick Installer"
echo "============================"
echo

# Download the main script
echo "Downloading BackhaulStar script..."
wget -q --show-progress https://raw.githubusercontent.com/MoriiStar/BackhaulStar/main/backhaul_star.sh

if [ $? -eq 0 ]; then
    echo "Download completed successfully!"
    chmod +x backhaul_star.sh
    echo "Starting BackhaulStar..."
    echo
    sudo ./backhaul_star.sh
else
    echo "Download failed! Please check your internet connection."
    exit 1
fi
 
ساختار پروژه GitHub:
 
BackhaulStar/
├── README.md
├── backhaul_star.sh
├── install.sh
├── LICENSE
└── docs/
    ├── installation.md
    └── troubleshooting.md
 
نحوه استفاده:
آپلود به GitHub:
ریپازیتوری جدید با نام  BackhaulStar  بسازید
فایل‌های بالا رو آپلود کنید
نصب سریع:
 
curl -sSL https://raw.githubusercontent.com/MoriiStar/BackhaulStar/main/install.sh | bash
 
نصب دستی:
 
wget https://raw.githubusercontent.com/MoriiStar/BackhaulStar/main/backhaul_star.sh
chmod +x backhaul_star.sh
sudo ./backhaul_star.sh
 
ویژگی‌های اسکریپت:
✅ منو تعاملی با رنگ‌بندی زیبا ✅ پشتیبانی کامل IPv4 و IPv6 ✅ تشخیص خودکار معماری (AMD64/ARM64) ✅ اعتبارسنجی ورودی‌ها (IP، پورت، فرمت) ✅ مدیریت سرویس systemd ✅ نمایش وضعیت و لاگ‌ها ✅ پیکربندی چندین پورت ✅ استفاده از فایل‌های پرمیوم ارسالی

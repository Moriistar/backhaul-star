#!/bin/bash

# BackhaulStar - Comprehensive Backhaul Tunnel Setup Script
# Created by: MoriiStar
# GitHub: https://github.com/MoriiStar/BackhaulStar

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "$${1}$${2}${NC}\n"
}

# Function to print header
print_header() {
    clear
    print_color $CYAN "=================================================================="
    print_color $WHITE "               BackhaulStar - Tunnel Setup Script"
    print_color $CYAN "                      Created by: MoriiStar"
    print_color $CYAN "          GitHub: https://github.com/MoriiStar/BackhaulStar"
    print_color $CYAN "=================================================================="
    echo
}

# Function to detect CPU architecture
detect_architecture() {
    local arch=$(uname -m)
    case $arch in
        x86_64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            print_color $$RED "Unsupported architecture: $$arch"
            exit 1
            ;;
    esac
}

# Function to validate IP address
validate_ip() {
    local ip=$1
    local type=$2
    
    if [[ $type == "ipv4" ]]; then
        if [[ $$ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$$ ]]; then
            return 0
        fi
    elif [[ $type == "ipv6" ]]; then
        if [[ $$ip =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$$ ]] || [[ $$ip == "::1" ]] || [[ $$ip == "::" ]]; then
            return 0
        fi
    fi
    return 1
}

# Function to validate port
validate_port() {
    local port=$1
    if [[ $$port =~ ^[0-9]+$$ ]] && [ $$port -ge 1 ] && [ $$port -le 65535 ]; then
        return 0
    fi
    return 1
}

# Function to download backhaul binary
download_backhaul() {
    local arch=$1
    local download_url
    
    print_color $YELLOW "Detecting system architecture..."
    print_color $$GREEN "Architecture detected: $$arch"
    
    if [[ $arch == "amd64" ]]; then
        download_url="https://gensparkstorageprodwest.blob.core.windows.net/personal/e297088f-cc0c-4280-96bd-659f6fd5d268/upload/default/9cc9928e-538a-43c1-a9b8-2533c7a7478f?se=2025-08-17T20%3A13%3A05Z&sp=r&sv=2025-05-05&sr=b&rsct=application/gzip&sig=lj8lQ5JAYeM19Ee2LOXf7sKy8enFlymCEIHNjo7m6Gc%3D"
    elif [[ $arch == "arm64" ]]; then
        download_url="https://gensparkstorageprodwest.blob.core.windows.net/personal/e297088f-cc0c-4280-96bd-659f6fd5d268/upload/default/0540d7c5-1a06-4785-801a-4bb80234240e?se=2025-08-17T20%3A13%3A05Z&sp=r&sv=2025-05-05&sr=b&rsct=application/gzip&sig=%2BOT3kU/CwHx4HQnHWgyCkgzTVroK3Xw%2ByHEvvGemBxo%3D"
    fi
    
    print_color $YELLOW "Creating backhaul directory..."
    mkdir -p /root/backhaul
    cd /root/backhaul
    
    print_color $$YELLOW "Downloading Backhaul Premium ($$arch)..."
    if wget -q --show-progress "$$download_url" -O "backhaul_premium_linux_$${arch}.tar.gz"; then
        print_color $GREEN "Download completed successfully!"
    else
        print_color $RED "Download failed! Please check your internet connection."
        exit 1
    fi
    
    print_color $YELLOW "Extracting files..."
    tar -xf "backhaul_premium_linux_${arch}.tar.gz"
    
    print_color $YELLOW "Setting permissions..."
    chmod +x backhaul
    
    print_color $YELLOW "Moving binary to system path..."
    cp backhaul /usr/bin/backhaul
    
    print_color $YELLOW "Cleaning up..."
    rm "backhaul_premium_linux_${arch}.tar.gz"
    
    print_color $GREEN "Backhaul installation completed!"
}

# Function to create server configuration
create_server_config() {
    local ip_version=$1
    local bind_addr
    local tunnel_port
    local token
    local ports=""
    
    print_color $YELLOW "=== Server Configuration (Iran Server) ==="
    echo
    
    # Get tunnel port
    while true; do
        read -p "Enter tunnel port (communication between servers): " tunnel_port
        if validate_port "$tunnel_port"; then
            break
        else
            print_color $RED "Invalid port number! Please enter a number between 1-65535."
        fi
    done
    
    # Set bind address based on IP version
    if [[ $ip_version == "ipv6" ]]; then
        bind_addr="[::]:$tunnel_port"
    else
        bind_addr="0.0.0.0:$tunnel_port"
    fi
    
    # Get token
    read -p "Enter tunnel token (password): " token
    
    # Get port mappings
    print_color $CYAN "Port Configuration:"
    print_color $WHITE "Format: input_port=output_port (if they're the same, just enter the port number)"
    echo
    
    local port_count=1
    while true; do
        read -p "Enter port mapping $port_count (or 'done' to finish): " port_input
        
        if [[ $port_input == "done" ]]; then
            if [[ -z $ports ]]; then
                print_color $RED "You must configure at least one port!"
                continue
            else
                break
            fi
        fi
        
        # Check if it's a simple port or port mapping
        if [[ $$port_input =~ ^[0-9]+$$ ]]; then
            # Simple port
            if validate_port "$port_input"; then
                if [[ -z $ports ]]; then
                    ports="\"$$port_input=$$port_input\""
                else
                    ports="$$ports,\n    \"$$port_input=$port_input\""
                fi
                ((port_count++))
            else
                print_color $RED "Invalid port number!"
            fi
        elif [[ $$port_input =~ ^[0-9]+=[0-9]+$$ ]]; then
            # Port mapping
            local input_port=$$(echo $$port_input | cut -d'=' -f1)
            local output_port=$$(echo $$port_input | cut -d'=' -f2)
            
            if validate_port "$$input_port" && validate_port "$$output_port"; then
                if [[ -z $ports ]]; then
                    ports="\"$port_input\""
                else
                    ports="$$ports,\n    \"$$port_input\""
                fi
                ((port_count++))
            else
                print_color $RED "Invalid port mapping!"
            fi
        else
            print_color $RED "Invalid format! Use 'port' or 'input_port=output_port'"
        fi
    done
    
    # Create config file
    cat > /root/backhaul/config.toml << EOF
[server]
bind_addr = "$bind_addr"
transport = "tcp"
token = "$token"
keepalive_period = 75
nodelay = true
channel_size = 2048
mux_session = 1

ports = [ 
    $$(echo -e $$ports)
]
EOF
    
    print_color $GREEN "Server configuration created successfully!"
    print_color $CYAN "Configuration saved to: /root/backhaul/config.toml"
}

# Function to create client configuration
create_client_config() {
    local ip_version=$1
    local remote_ip
    local tunnel_port
    local token
    
    print_color $YELLOW "=== Client Configuration (International Server) ==="
    echo
    
    # Get remote server IP
    while true; do
        if [[ $ip_version == "ipv6" ]]; then
            read -p "Enter Iran server IPv6 address: " remote_ip
            if validate_ip "$remote_ip" "ipv6"; then
                remote_ip="[$remote_ip]"
                break
            else
                print_color $RED "Invalid IPv6 address!"
            fi
        else
            read -p "Enter Iran server IPv4 address: " remote_ip
            if validate_ip "$remote_ip" "ipv4"; then
                break
            else
                print_color $RED "Invalid IPv4 address!"
            fi
        fi
    done
    
    # Get tunnel port
    while true; do
        read -p "Enter tunnel port (same as server): " tunnel_port
        if validate_port "$tunnel_port"; then
            break
        else
            print_color $RED "Invalid port number!"
        fi
    done
    
    # Get token
    read -p "Enter tunnel token (same as server): " token
    
    # Create config file
    cat > /root/backhaul/config.toml << EOF
[client]
remote_addr = "$$remote_ip:$$tunnel_port"
transport = "tcp"
token = "$token"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
nodelay = true 
retry_interval = 3
EOF
    
    print_color $GREEN "Client configuration created successfully!"
    print_color $CYAN "Configuration saved to: /root/backhaul/config.toml"
}

# Function to create systemd service
create_service() {
    print_color $YELLOW "Creating systemd service..."
    
    cat > /etc/systemd/system/backhaul.service << EOF
[Unit]
Description=Backhaul Reverse Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/backhaul -c /root/backhaul/config.toml
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable backhaul.service
    
    print_color $GREEN "Systemd service created and enabled!"
}

# Function to start service
start_service() {
    print_color $YELLOW "Starting Backhaul service..."
    
    if systemctl start backhaul.service; then
        print_color $GREEN "Backhaul service started successfully!"
        sleep 2
        systemctl status backhaul.service --no-pager
    else
        print_color $RED "Failed to start Backhaul service!"
        print_color $YELLOW "Check the logs with: journalctl -u backhaul.service -f"
    fi
}

# Function to show service management commands
show_management_commands() {
    print_color $CYAN "=== Service Management Commands ==="
    echo
    print_color $WHITE "Check service status:"
    print_color $GREEN "  sudo systemctl status backhaul.service"
    echo
    print_color $WHITE "Start service:"
    print_color $GREEN "  sudo systemctl start backhaul.service"
    echo
    print_color $WHITE "Stop service:"
    print_color $GREEN "  sudo systemctl stop backhaul.service"
    echo
    print_color $WHITE "Restart service:"
    print_color $GREEN "  sudo systemctl restart backhaul.service"
    echo
    print_color $WHITE "View logs:"
    print_color $GREEN "  sudo journalctl -u backhaul.service -f"
    echo
    print_color $WHITE "Configuration file location:"
    print_color $GREEN "  /root/backhaul/config.toml"
    echo
}

# Main menu function
main_menu() {
    while true; do
        print_header
        print_color $WHITE "Select an option:"
        echo
        print_color $GREEN "1) Iran Server Setup (Server Mode)"
        print_color $BLUE "2) International Server Setup (Client Mode)"
        print_color $YELLOW "3) Service Management"
        print_color $PURPLE "4) View Configuration"
        print_color $RED "0) Exit"
        echo
        read -p "Enter your choice [0-4]: " choice
        
        case $choice in
            1)
                setup_server
                ;;
            2)
                setup_client
                ;;
            3)
                service_management
                ;;
            4)
                view_configuration
                ;;
            0)
                print_color $GREEN "Thank you for using BackhaulStar!"
                exit 0
                ;;
            *)
                print_color $RED "Invalid option! Please try again."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Function to setup server
setup_server() {
    print_header
    print_color $GREEN "=== Iran Server Setup ==="
    echo
    
    # Check if already installed
    if [[ -f "/usr/bin/backhaul" ]]; then
        print_color $YELLOW "Backhaul is already installed."
        read -p "Do you want to reinstall? (y/N): " reinstall
        if [[ ! $$reinstall =~ ^[Yy]$$ ]]; then
            return
        fi
    fi
    
    # Get IP version preference
    print_color $WHITE "Select IP version:"
    print_color $GREEN "1) IPv4"
    print_color $BLUE "2) IPv6"
    echo
    read -p "Enter your choice [1-2]: " ip_choice
    
    local ip_version
    case $ip_choice in
        1)
            ip_version="ipv4"
            ;;
        2)
            ip_version="ipv6"
            ;;
        *)
            print_color $RED "Invalid choice! Defaulting to IPv4."
            ip_version="ipv4"
            ;;
    esac
    
    # Download and install
    local arch=$(detect_architecture)
    download_backhaul "$arch"
    
    # Create configuration
    create_server_config "$ip_version"
    
    # Create service
    create_service
    
    # Ask to start service
    echo
    read -p "Do you want to start the service now? (Y/n): " start_now
    if [[ ! $$start_now =~ ^[Nn]$$ ]]; then
        start_service
    fi
    
    echo
    show_management_commands
    read -p "Press Enter to continue..."
}

# Function to setup client
setup_client() {
    print_header
    print_color $BLUE "=== International Server Setup ==="
    echo
    
    # Check if already installed
    if [[ -f "/usr/bin/backhaul" ]]; then
        print_color $YELLOW "Backhaul is already installed."
        read -p "Do you want to reinstall? (y/N): " reinstall
        if [[ ! $$reinstall =~ ^[Yy]$$ ]]; then
            return
        fi
    fi
    
    # Get IP version preference
    print_color $WHITE "Select IP version:"
    print_color $GREEN "1) IPv4"
    print_color $BLUE "2) IPv6"
    echo
    read -p "Enter your choice [1-2]: " ip_choice
    
    local ip_version
    case $ip_choice in
        1)
            ip_version="ipv4"
            ;;
        2)
            ip_version="ipv6"
            ;;
        *)
            print_color $RED "Invalid choice! Defaulting to IPv4."
            ip_version="ipv4"
            ;;
    esac
    
    # Download and install
    local arch=$(detect_architecture)
    download_backhaul "$arch"
    
    # Create configuration
    create_client_config "$ip_version"
    
    # Create service
    create_service
    
    # Ask to start service
    echo
    read -p "Do you want to start the service now? (Y/n): " start_now
    if [[ ! $$start_now =~ ^[Nn]$$ ]]; then
        start_service
    fi
    
    echo
    show_management_commands
    read -p "Press Enter to continue..."
}

# Function for service management
service_management() {
    while true; do
        print_header
        print_color $YELLOW "=== Service Management ==="
        echo
        
        if systemctl is-active --quiet backhaul.service; then
            print_color $GREEN "Service Status: RUNNING ✓"
        else
            print_color $RED "Service Status: STOPPED ✗"
        fi
        echo
        
        print_color $WHITE "1) Start Service"
        print_color $WHITE "2) Stop Service"
        print_color $WHITE "3) Restart Service"
        print_color $WHITE "4) View Status"
        print_color $WHITE "5) View Logs"
        print_color $WHITE "6) Enable Service (Auto-start)"
        print_color $WHITE "7) Disable Service"
        print_color $RED "0) Back to Main Menu"
        echo
        read -p "Enter your choice [0-7]: " choice
        
        case $choice in
            1)
                systemctl start backhaul.service
                print_color $GREEN "Service started!"
                ;;
            2)
                systemctl stop backhaul.service
                print_color $YELLOW "Service stopped!"
                ;;
            3)
                systemctl restart backhaul.service
                print_color $GREEN "Service restarted!"
                ;;
            4)
                systemctl status backhaul.service --no-pager
                ;;
            5)
                print_color $CYAN "Press Ctrl+C to exit logs view"
                sleep 2
                journalctl -u backhaul.service -f
                ;;
            6)
                systemctl enable backhaul.service
                print_color $GREEN "Service enabled for auto-start!"
                ;;
            7)
                systemctl disable backhaul.service
                print_color $YELLOW "Service disabled from auto-start!"
                ;;
            0)
                return
                ;;
            *)
                print_color $RED "Invalid option!"
                ;;
        esac
        
        if [[ $$choice != "5" && $$choice != "0" ]]; then
            echo
            read -p "Press Enter to continue..."
        fi
    done
}

# Function to view configuration
view_configuration() {
    print_header
    print_color $PURPLE "=== Current Configuration ==="
    echo
    
    if [[ -f "/root/backhaul/config.toml" ]]; then
        print_color $CYAN "Configuration file: /root/backhaul/config.toml"
        echo
        cat /root/backhaul/config.toml
        echo
    else
        print_color $RED "No configuration file found!"
        print_color $YELLOW "Please run setup first."
    fi
    
    echo
    read -p "Press Enter to continue..."
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    print_color $RED "This script must be run as root!"
    print_color $$YELLOW "Please run: sudo bash $$0"
    exit 1
fi

# Check if required tools are installed
if ! command -v wget &> /dev/null; then
    print_color $YELLOW "Installing wget..."
    apt-get update && apt-get install -y wget
fi

if ! command -v tar &> /dev/null; then
    print_color $YELLOW "Installing tar..."
    apt-get update && apt-get install -y tar
fi

# Start main menu
main_menu

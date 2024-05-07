#!/bin/bash



install_docker() {
    sudo apt update
    sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
}


install_docker_compose() {
    # Download Docker Compose binary
    sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    # Make Docker Compose executable
    sudo chmod +x /usr/local/bin/docker-compose

    # Verify Docker Compose installation
    sudo docker-compose --version

    # Add current user to the Docker group
    sudo usermod -aG docker $USER
}


run_nginx_proxy_manager() {
    mkdir dockerfile && cd dockerfile
    mkdir nginx_proxy_manager && cd nginx_proxy_manager
    # Create a directory to store data and letsencrypt certificates
    mkdir -p ~/nginx_proxy_manager/data
    mkdir -p ~/nginx_proxy_manager/letsencrypt

    # Create a Docker Compose file
    cat <<EOF > ~/nginx_proxy_manager/docker-compose.yml
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    environment:
      DB_MYSQL_HOST: "db"
      DB_MYSQL_PORT: 3306
      DB_MYSQL_USER: "npm"
      DB_MYSQL_PASSWORD: "npm"
      DB_MYSQL_NAME: "npm"
    volumes:
      - ~/nginx_proxy_manager/data:/data
      - ~/nginx_proxy_manager/letsencrypt:/etc/letsencrypt
  db:
    image: 'jc21/mariadb-aria:latest'
    environment:
      MYSQL_ROOT_PASSWORD: 'npm'
      MYSQL_DATABASE: 'npm'
      MYSQL_USER: 'npm'
      MYSQL_PASSWORD: 'npm'
    volumes:
      - ~/nginx_proxy_manager/data/mysql:/var/lib/mysql
EOF

    # Change directory to where the Docker Compose file is located
    cd ~/nginx_proxy_manager

    # Start Nginx Proxy Manager using Docker Compose
    docker-compose up -d
}



setup_cloudflare_tunnel() {
    # Create a folder called dockerfile and navigate into it
    cd dockerfile
    # Create directory and navigate into it
    mkdir -p Cloudflare_Tunnel && cd Cloudflare_Tunnel

    # Create docker-compose.yml file
    cat <<EOF > docker-compose.yml
version: '3.9'

networks:
  frontend:
    external: true
  backend:
    external: true

services:
  cloudflaretunnel:
    container_name: cloudflaretunnel-demo-1
    image: cloudflare/cloudflared:2023.2.1
    restart: unless-stopped
    environment:
      - TUNNEL_TOKEN=$TUNNEL_TOKEN
    command: tunnel --no-autoupdate run
    networks:
      - frontend
      - backend
EOF

    # Load TUNNEL_TOKEN into .env file
    echo "export TUNNEL_TOKEN=xxxxx" > .env

    # Run docker-compose up
    docker-compose up -d
}





install_n8n() {
    # Create a folder called dockerfile and navigate into it
    cd dockerfile
    # Create n8n folder and navigate into it
    mkdir n8n && cd n8n
    
    # Create n8n_data folder
    mkdir n8n_data

    # Create docker-compose.yml file and add content
    cat <<EOF > docker-compose.yml
version: "3.7"

services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    ports:
      - "127.0.0.1:5678:5678"
    environment:
      - N8N_HOST=\${SUBDOMAIN}.\${DOMAIN_NAME}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://\${SUBDOMAIN}.\${DOMAIN_NAME}/
      - GENERIC_TIMEZONE=\${GENERIC_TIMEZONE}
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
    external: true
EOF

    # Start n8n using Docker Compose
    docker-compose up -d
}





install_portainer() {
    # Create a folder called dockerfile and navigate into it
    cd dockerfile
    
    # Create a folder called portainer and navigate into it
    mkdir portainer && cd portainer
    
    # Make a folder called portainer_data
    mkdir portainer_data
    
    # Create docker-compose.yml file and add content
    cat <<EOF > docker-compose.yml
version: '3'

services:
  portainer:
    image: portainer/portainer-ce
    ports:
      - "8000:8000"
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    restart: always
    container_name: portainer

volumes:
  portainer_data:
EOF

    # Start Portainer using Docker Compose
    docker-compose up -d
}






install_tigervnc() {
    # Update package list
    sudo apt update

    # Install TigerVNC and GNOME desktop environment
    sudo apt install chromium-browser -y
    sudo apt install -y tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer ubuntu-gnome-desktop

    # Enable and start GNOME display manager
    sudo systemctl enable gdm
    sudo systemctl start gdm

    # Setup VNC password
    vncpasswd

    # Create and configure xstartup file
    mkdir -p ~/.vnc
    cat <<EOF > ~/.vnc/xstartup
#!/bin/sh
# Start Gnome 3 Desktop 
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r \$HOME/.Xresources ] && xrdb \$HOME/.Xresources
vncconfig -iconic &
dbus-launch --exit-with-session gnome-session &
EOF

    # Add execute permissions to xstartup file
    chmod +x ~/.vnc/xstartup
}


# Function to call gophish.sh script
gophish_install() {
    # Check if gophish.sh script exists
    if [ -f "gophish.sh" ]; then
        echo "Calling gophish.sh script..."
        chmod +x ./gophish.sh
        ./gophish.sh
    else
        echo "Error: gophish.sh script not found."
        exit 1
    fi
}


# Function to call phish.sh script
phish_install() {
    # Check if phish.sh script exists
    if [ -f "phish.sh" ]; then
        echo "Calling phish.sh script..."
        chmod +x ./phish.sh
        ./phish.sh
    else
        echo "Error: phish.sh script not found."
        exit 1
    fi
}


# Function to call phishs.sh script
phishs_install() {
    # Check if phishs.sh script exists
    if [ -f "phishs.sh" ]; then
        echo "Calling phishs.sh script..."
        chmod +x ./phish.sh
        ./phishs.sh
    else
        echo "Error: phish.sh script not found."
        exit 1
    fi
}



setup_new_server() {
    # Install essential packages
    sudo apt update
    sudo apt install -y git wget screen

    # Perform system update and upgrade
    sudo apt update && sudo apt upgrade -y
}



# Function to set hostname
set_hostname() {
    read -p "Enter the new hostname: " new_hostname
    sudo hostnamectl set-hostname "$new_hostname"
}

# Function to add new user, grant root permissions, and disable password login
add_new_user() {
    read -p "Enter the new username: " new_username
    read -sp "Enter the password for $new_username: " new_password
    echo

    sudo useradd -m -s /bin/bash "$new_username"
    echo "$new_username:$new_password" | sudo chpasswd
    sudo usermod -aG sudo "$new_username"
    sudo sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    sudo systemctl restart sshd
}

# Function to install and configure firewall (ufw)
setup_firewall() {
    sudo apt update
    sudo apt install -y ufw
    sudo ufw default allow incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow http
    sudo ufw allow https
    sudo ufw --force enable
}

# Function to enable automatic updates
enable_automatic_updates() {
    sudo apt install -y unattended-upgrades
    sudo dpkg-reconfigure --priority=low unattended-upgrades
}

# Function to configure NTP time service
configure_ntp() {
    sudo apt install -y ntp
    sudo systemctl enable ntp
    sudo systemctl start ntp
}

# Function to print system information
print_system_info() {
    echo "System Information:"
    echo "-------------------"
    echo "Hostname: $(hostname)"
    echo "Memory Size: $(free -m | awk '/Mem/{print $2" MB"}')"
    echo "Disk Size: $(df -h --output=size / | awk 'NR==2{print $1}')"
    echo "RAM Size: $(sudo dmidecode -t memory | grep "Size" | grep -v "No" | uniq)"
}

# Main function
configure() {
    set_hostname
    add_new_user
    setup_firewall
    enable_automatic_updates
    configure_ntp
    print_system_info
}






show_help() {
    # Define color variables
    YELLOW=$(tput setaf 3)
    GREEN=$(tput setaf 2)
    BLUE=$(tput setaf 4)
    NC=$(tput sgr0) # No Color

    # Print ASCII art
    echo -e "${YELLOW}"
    cat << "EOF"
                                                                                                                      
          ____                                                                                                        
        ,'  , `.                      ,---,                                                                           
     ,-+-,.' _ |                    ,--.' |      ,--,                  ,---.                           ,--,           
  ,-+-. ;   , ||   ,---.            |  |  :    ,--.'|                 /__./|                   ,---, ,--.'|           
 ,--.'|'   |  ;|  '   ,'\           :  :  :    |  |,             ,---.;  ; |               ,-+-. /  ||  |,            
|   |  ,', |  ': /   /   |   ,---.  :  |  |,--.`--'_            /___/ \  | |   ,--.--.    ,--.'|'   |`--'_            
|   | /  | |  ||.   ; ,. :  /     \ |  :  '   |,' ,'|           \   ;  \ ' |  /       \  |   |  ,"' |,' ,'|           
'   | :  | :  |,'   | |: : /    / ' |  |   /' :'  | |            \   \  \: | .--.  .-. | |   | /  | |'  | |           
;   . |  ; |--' '   | .; :.    ' /  '  :  | | ||  | :             ;   \  ' .  \__\/: . . |   | |  | ||  | :           
|   : |  | ,    |   :    |'   ; :__ |  |  ' | :'  : |__            \   \   '  ," .--.; | |   | |--'  |  | '.'|          
|   : '  |/      \   \  / '   | '.'||  :  :_:,'|  | '.'|            \   `  ; /  /  ,.  | |   | |     |  | :           
;   | |`-'        `----'  |   :    :|  | ,'    ;  :    ;             :   \ |;  :   .'   \|   |/      ;  : |           
|   ;/                     \   \  / `--''      |  ,   /               '---" |  ,     .-./'---'       |  , /            
'---'                       `----'              ---`-'                       `--`---'                 ---`-'             
                                                                                                                      
EOF
    echo -e "${NC}"
    
    # Print the help message
    echo -e "${BLUE}"
    cat <<EOF
                                                                                                                                       
Usage: 
  ./installer.sh [OPTIONS]

Options:
  ${YELLOW}-h,     --help${NC}                      ${GREEN}Display this help message and exit${NC}
  ${YELLOW}-d,     --install-docker${NC}            ${GREEN}Install Docker${NC}
  ${YELLOW}-dc,    --install-docker-compose${NC}    ${GREEN}Installation of Docker Compose${NC}
  ${YELLOW}-npm,   --nginx-proxy-manager${NC}       ${GREEN}Run nginx_proxy_manager${NC}
  ${YELLOW}-sct,   --setup-cloudflare-tunnel${NC}   ${GREEN}Run setup_cloudflare_tunnel${NC}
  ${YELLOW}-tgv,   --install-tigervnc${NC}          ${GREEN}Run install_tigervnc${NC}
  ${YELLOW}-sh,    --setup-new-server${NC}          ${GREEN}Run setup_new_server${NC}
  ${YELLOW}-cf,    --configure${NC}                 ${GREEN}Run configure server${NC}
  ${YELLOW}-n8,    --install-n8n${NC}               ${GREEN}Run install_n8n${NC}
  ${YELLOW}-pt,    --install-portainer${NC}         ${GREEN}Run install_portainer${NC}
  ${YELLOW}-go,    --gophish-install${NC}           ${GREEN}Run gophish_install${NC}
  ${YELLOW}-ph,    --phish-install${NC}             ${GREEN}Run phish_install${NC}
  ${YELLOW}-phs,   --phishs-install${NC}            ${GREEN}Run phishs_install${NC}
EOF
}




while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -d|-install-docker)
            install_docker
            exit 0
            ;;
        -dc|--install_docker_compose)
            install_docker_compose
            exit 0
            ;;
        -npm|--nginx_proxy_manager)
            nginx_proxy_manager
            exit 0
            ;;
        -sct|--setup_cloudflare_tunnel)
            setup_cloudflare_tunnel
            exit 0
            ;;
        -tgv|--install_tigervnc)
            install_tigervnc
            exit 0
            ;;
        -sf|--setup_new_server)
            setup_new_server
            exit 0
            ;;
        -cf|--configure)
            configure
            exit 0
            ;;
        -n8|--install_n8n)
            install_n8n 
            exit 0
            ;;
        -pt|--install_portainer)
            install_portainer 
            exit 0
            ;;
        -go|--gophish_install)
            gophish_install 
            exit 0
            ;;
        -ph|--phish_install )
            --phish_install  
            exit 0
            ;;
        -phs|--phishs_install )
            --phishs_install  
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done



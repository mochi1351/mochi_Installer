#!/bin/bash


# Function to install GoPhish
install_gophish() {
    # Prompt user to enter the version
    read -p "Enter the version of GoPhish (e.g., v0.11.0): " VERSION

    # Update package lists
    sudo apt update

    # Install required packages
    sudo apt install -y wget unzip

    # Download GoPhish
    wget "https://github.com/gophish/gophish/releases/download/$VERSION/gophish-$VERSION-linux-64bit.zip"

    # Extract the Zip Archive
    unzip "gophish-$VERSION-linux-64bit.zip"

    # Navigate to the Extracted Directory
    cd "gophish-$VERSION-linux-64bit"

    # Run GoPhish
    ./gophish

    # Optional: Running GoPhish as a Service
    sudo cp gophish /usr/local/bin/gophish  # Optionally copy gophish binary to system PATH
    sudo systemctl daemon-reload
    sudo systemctl start gophish
    sudo systemctl enable gophish

    echo "GoPhish $VERSION has been installed successfully. Access it from a web browser at http://your_server_ip:3333."
}

# Call the function to install GoPhish
install_gophish

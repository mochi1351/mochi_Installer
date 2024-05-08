#!/bin/bash

# Function to install EvilnoVNC
install_evilnovnc() {
    # Clone EvilnoVNC repository
    git clone https://github.com/JoelGMSec/EvilnoVNC
    cd EvilnoVNC

    # Change ownership of Downloads directory
    sudo chown -R 103 Downloads

    # Build Docker image
    sudo docker build -t joelgmsec/evilnovnc .

    # Make start.sh script executable
    chmod +x ./start.sh

    echo "EvilnoVNC has been installed successfully."
}

# Call the function to install EvilnoVNC
install_evilnovnc

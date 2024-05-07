#!/bin/bash

# Function to install EvilnoVNC
install_evilnovnc() {
    # Step 1: Clone the EvilnoVNC repository
    echo "Cloning EvilnoVNC repository..."
    git clone https://github.com/wanetty/EvilnoVNC
    cd EvilnoVNC

    # Step 2: Change ownership of Downloads folder
    echo "Changing ownership of Downloads folder..."
    sudo chown -R 103 Downloads

    # Step 3: Build evilnovnc Docker image
    echo "Building evilnovnc Docker image..."
    sudo docker build -f evilnovnc.Dockerfile -t evilnovnc .

    # Step 4: Build nginx Docker image
    echo "Building nginx Docker image..."
    sudo docker build -f nginx.Dockerfile -t evilnginx .

    # Step 5: Installation completed
    echo "Installation completed."
}

# Call the function to install EvilnoVNC
install_evilnovnc

#!/bin/bash

red='\e[31m'
yellow='\e[33m'
blue='\e[34m'
clear='\e[0m'

function velociraptor_install() {
    sudo ./velociraptor config generate -i
    sudo sed -e '60,/bind_address:/{s/127.0.0.1/0.0.0.0/}' -i server.config.yaml
    sudo sed -e 's/localhost/aws_public_ip/g' -i client.config.yaml

    sudo ./velociraptor --config server.config.yaml debian server
    sudo apt install ./velociraptor*server.deb
    sudo ./velociraptor --config client.config.yaml debian client
    sudo mv velociraptor*client.deb ./Linux/nix-velociraptor.deb
    sudo mv client.config.yaml ./Windows
}

function db_upload() {
    echo "Enter your Dropbox token:"
    read ACCESS_TOKEN

    sudo curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"/Windows/Velociraptor.config.yaml\"}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @./Windows/client.config.yaml

    sudo curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"/Windows/win-velociraptor.msi\"}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @./Windows/win-velociraptor.msi

    sudo curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"/Linux/nix-velociraptor.deb\"}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @./Linux/nix-velociraptor.deb

    sudo curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"/Windows/win_install.bat\"}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @./Windows/win_install.bat

    sudo curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"/Linux/nix_install.sh\"}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary @./Linux/nix_install.sh
}

function adduser() {
    echo "Enter user's name:"
    read VR_USERNAME

    sudo -u velociraptor --sh velociraptor user add $VR_USERNAME --role=administrator
    exit
}

function reinstall() {
    sudo apt remove velociraptor-server
    velociraptor_install
}

menu() {
    echo -ne "
    ${yellow} ===VELOCIRAPTOR DEPLOYMENT=== ${clear}
    ${blue}(1)${clear} Install Velociraptor Server
    ${blue}(2)${clear} Upload Sensors
    ${blue}(3)${clear} Add User
    ${blue}(4)${clear} Reinstall Velociraptor
    ${blue}(0)${clear} Exit
    'Choose an option:'
    "
    read choice
    case $choice in
    1) velociraptor_install ; menu ;;
    2) db_upload ; menu ;;
    3) adduser ; menu ;;
    4) reinstall ; menu ;;
    0) exit 0 ;;
    *) echo -e "
    ${red}Incorrect option. Try again."; menu;;
    esac
}

menu
#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Function to create user with sudo privileges and configure passwordless sudo
create_user() {
  local username="$1"
  local password="$2"
  # Create user
  useradd -m -s /bin/bash "$username"

  # Set password for the user
  echo "$username:$password" | chpasswd

  # Add user to sudo group
  usermod -aG sudo "$username"

  # Configure passwordless sudo for the user
  echo "$username ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/"$username"
  echo "create user $username success."
}

# Parse command line options
while getopts "u:p:" opt; do
  case $opt in
    u) username="$OPTARG" ;;
    p) password="$OPTARG" ;;
    *) echo "Invalid option" >&2
       exit 1 ;;
  esac
done

# Check if required options are provided
if [ -z "$username" ] || [ -z "$password" ]; then
  echo "Usage: $0 -u <username> -p <password>"
  exit 1
fi

# Example usage: create_user -u username1 -p passwd1
create_user "$username" "$password"

# run command
# sudo curl -sSL https://raw.githubusercontent.com/ReasonDuan/lazy-script/main/ubuntu/create_user.sh | sudo bash -s -- -u reason -p 123456

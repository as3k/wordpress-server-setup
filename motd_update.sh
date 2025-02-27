#!/bin/bash
# A custom MOTD script inspired by DietPi

# Color definitions for a friendly look
if [ -t 1 ]; then
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[0;33m"
    BLUE="\033[0;34m"
    BOLD="\033[1m"
    NC="\033[0m"  # No Color
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NC=""
fi

clear

echo -e "${BOLD}${BLUE}Welcome to $(hostname)!${NC}"
echo -e "Today is: $(date)"
echo

# Uptime info
echo -e "${BOLD}Uptime:${NC} $(uptime -p)"
echo

# System load averages
LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | sed 's/^ //')
echo -e "${BOLD}System Load:${NC} $LOAD"
echo

# Memory usage
MEM_USAGE=$(free -h | awk '/^Mem:/ {print $3 " used / " $2 " total"}')
echo -e "${BOLD}Memory Usage:${NC} $MEM_USAGE"
echo

# Disk usage on root filesystem
DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 " used / " $2 " total (" $5 " used)"}')
echo -e "${BOLD}Disk Usage (root):${NC} $DISK_USAGE"
echo

# IP addresses
IP_ADDR=$(hostname -I)
echo -e "${BOLD}IP Addresses:${NC} $IP_ADDR"
echo

# Helpful tips and commands
echo -e "${YELLOW}Tip:${NC} Use 'apt update && apt upgrade' to keep your system current."
echo -e "${YELLOW}Tip:${NC} Review system logs in /var/log for troubleshooting."
echo -e "${YELLOW}Tip:${NC} Check out 'man <command>' for more info on any command."
echo

echo -e "${GREEN}Have a great day and happy computing!${NC}"
# WordPress Setup Scripts

This repository contains scripts to set up a WordPress site with Nginx, MariaDB, PHP, and other necessary tools on a Linux server.

## Files

- `install.sh`: This script installs Nginx, MariaDB, PHP, and other required packages. It also sets up SSH keys, configures Git, and secures the MariaDB installation.
- `wp_setup.sh`: This script configures Nginx with the provided domain, sets up Let's Encrypt SSL, and installs WordPress. It also prompts the user to create a WordPress admin account.

## Usage

### Step 1: Run the `install.sh` Script

1. Make sure the script is executable:
    ```sh
    chmod +x install.sh
    ```

2. Run the script as root (or using sudo):
    ```sh
    sudo ./install.sh
    ```

3. Follow the prompts to set up SSH keys, configure Git, and secure MariaDB.

### Step 2: Run the wp_setup.sh Script

1. Make sure the script is executable:
    ```sh
    chmod +x wp_setup.sh
    ```

2. Run the script as root (or using sudo):
    ```sh
    sudo ./wp_setup.sh
    ```

3. Follow the prompts to provide the domain name, create a WordPress admin account, and optionally set up Let's Encrypt SSL.

4. Once the script completes, access your new WordPress site in a browser to continue the setup.

## Notes

- Ensure that your domain or subdomain is pointed to the server's IP address before running the `wp_setup.sh` script.
- You can run the `wp_setup.sh` script again if you need to reconfigure the domain or SSL settings.

## License

This project is licensed under the MIT License.
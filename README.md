# WordPress Setup Scripts

Hello there! Welcome to our setup scripts repository. In these files, you'll find everything you need to deploy a fully functioning WordPress site on your Linux server using Nginx, MariaDB, PHP, and more. We built these tools to simplify server configuration, enhance security, and streamline the WordPress installation process.

## Files

- `install.sh`: This script installs Nginx, MariaDB, PHP, and other required packages. It also offers to create a new user account, generates SSH keys, configures global Git settings, secures the MariaDB installation, sets up a custom MOTD, and optionally installs and configures zsh and oh-my-zsh.
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

3. Follow the prompts to:
    - Optionally create a new user account.
    - Generate new SSH keys.
    - Configure global Git settings.
    - Secure the MariaDB installation with a new root password and remove insecure defaults.
    - Set up a custom MOTD.
    - Optionally install and configure zsh and oh-my-zsh.

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
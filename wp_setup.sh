#!/bin/bash
#
# WordPress activation script (nginx version)
#
# This script will configure nginx with the domain
# provided by the user and offer the option to set up
# LetsEncrypt as well.

# Move WordPress into the web root on first login
if [[ -d /var/www/wordpress ]]; then
  mv /var/www/html /var/www/html.old
  mv /var/www/wordpress /var/www/html
fi
chown -Rf www-data:www-data /var/www/html

# Inform the user about the WordPress installation process
echo "This script will copy the WordPress installation into"
echo "your web root (/var/www/html) and move the existing one to /var/www/html.old."
echo "--------------------------------------------------"
echo "This setup requires a domain name. If you do not have one yet, you may"
echo "cancel this setup (Ctrl+C). You can run this script again later by running ./wp_setup."
echo "--------------------------------------------------"
echo "Enter the domain name for your new WordPress site."
echo "(ex. example.org or test.example.org). Do not include www or http/https."
echo "--------------------------------------------------"

a=0
while [ $a -eq 0 ]; do
  read -p "Domain/Subdomain name: " dom
  if [ -z "$dom" ]; then
    echo "Please provide a valid domain or subdomain name to continue, or press Ctrl+C to cancel."
  else
    a=1
  fi
done

# Update the nginx configuration file with the provided domain
# (Assuming a template file exists at /etc/nginx/sites-available/wordpress with a placeholder "$domain")
sed -i "s/\$domain/$dom/g" /etc/nginx/sites-available/wordpress

# Enable the nginx site configuration (and disable default if needed)
if [ ! -L /etc/nginx/sites-enabled/wordpress ]; then
  ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
fi
if [ -e /etc/nginx/sites-enabled/default ]; then
  rm /etc/nginx/sites-enabled/default
fi

echo "Restarting nginx..."
systemctl restart nginx

echo -en "Now we will create your new admin user account for WordPress."

# Function to prompt for WordPress admin account details
function wordpress_admin_account() {
  while [ -z "$email" ]; do
    echo -en "\n"
    read -p "Your Email Address: " email
  done

  while [ -z "$username" ]; do
    echo -en "\n"
    read -p "Username: " username
  done

  while [ -z "$pass" ]; do
    echo -en "\n"
    read -s -p "Password: " pass
    echo -en "\n"
  done

  while [ -z "$title" ]; do
    echo -en "\n"
    read -p "Blog Title: " title
  done
}

wordpress_admin_account

while true; do
  echo -en "\n"
  read -p "Is the information correct? [Y/n] " confirmation
  confirmation=${confirmation,,}
  if [[ "$confirmation" =~ ^(yes|y)$ ]] || [ -z "$confirmation" ]; then
    break
  else
    unset email username pass title confirmation
    wordpress_admin_account
  fi
done

echo -en "\n\n\n"
echo "Next, you have the option of configuring LetsEncrypt to secure your new site."
echo "Before doing so, ensure that your domain or subdomain ($dom) is pointed to this server's IP."
echo "You can also run Certbot later with the command 'certbot --nginx'."
echo -en "\n\n\n"
read -p "Would you like to use LetsEncrypt (certbot) to configure SSL (https) for your new site? (y/n): " yn
case $yn in
    [Yy]* )
        certbot --nginx
        echo "WordPress has been enabled at https://$dom. Please open this URL in a browser to complete the setup of your site."
        ;;
    [Nn]* )
        echo "Skipping LetsEncrypt certificate generation."
        ;;
    * )
        echo "Please answer y or n."
        ;;
esac

echo "Finalizing installation..."
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/bin/wp
chmod +x /usr/bin/wp

echo -en "Completing the configuration of WordPress."
wp core install --allow-root --path="/var/www/html" --title="$title" --url="$dom" --admin_email="$email" --admin_password="$pass" --admin_user="$username"

wp plugin install wp-fail2ban --allow-root --path="/var/www/html"
wp plugin activate wp-fail2ban --allow-root --path="/var/www/html"
chown -Rf www-data:www-data /var/www/
cp /etc/skel/.bashrc /root

echo "Installation complete. Access your new WordPress site in a browser to continue."
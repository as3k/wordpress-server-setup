#!/bin/bash
#
# WordPress activation script (nginx version)
#
# This script will configure nginx with the domain provided by the user,
# create and enable a WordPress server block, and offer the option to set up LetsEncrypt.

# Move the existing web root (if any) and create a new one
mv /var/www/html /var/www/html.old 2>/dev/null
mkdir -p /var/www/html
chown -Rf www-data:www-data /var/www/html

echo "This script will copy the WordPress installation into your web root (/var/www/html)"
echo "and move any existing installation to /var/www/html.old."
echo "--------------------------------------------------"
echo "This setup requires a domain name. If you do not have one, press Ctrl+C to cancel."
echo "Enter the domain name for your new WordPress site (ex: example.org or test.example.org)."
echo "Do not include www or http/https."
echo "--------------------------------------------------"

echo -en "\nNow we will create your new admin user account for WordPress."

# Function to prompt for WordPress admin account details
function wordpress_admin_account(){
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
    echo -en "\nIs the information correct? [Y/n] "
    read -r confirmation
    confirmation=${confirmation,,}
    if [[ "$confirmation" =~ ^(yes|y)$ ]] || [ -z "$confirmation" ]; then
      break
    else
      unset email username pass title confirmation
      wordpress_admin_account
    fi
done

# Installing wp-cli
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/bin/wp
chmod +x /usr/bin/wp

# Install wordpress
echo -en "\Setting up WordPress..."
wp core install --allow-root --path="/var/www/html" --title="$title" --url="$dom" --admin_email="$email" --admin_password="$pass" --admin_user="$username"

wp plugin install wp-fail2ban elementor autoptimize --allow-root --path="/var/www/html"
wp plugin activate wp-fail2ban elementor autoptimize --allow-root --path="/var/www/html"
wp theme install hello-elementor --activate --allow-root --path="/var/www/html"
chown -Rf www-data:www-data /var/www/
echo "WordPress has been installed...\n"

# Prompt for domain name until valid input is provided
a=0
while [ $a -eq 0 ]; do
  read -p "Domain/Subdomain name: " dom
  if [ -z "$dom" ]; then
    echo "Please provide a valid domain or subdomain name to continue, or press Ctrl+C to cancel."
  else
    a=1
  fi
done

# Create the nginx server block for WordPress using the provided domain
NGINX_CONF="/etc/nginx/sites-available/$dom"
cat > "$NGINX_CONF" <<EOL
server {
    listen 80;
    server_name $dom www.$dom;
    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)\$ {
        expires max;
        log_not_found off;
    }
}
EOL

# Enable the new server block and disable the default if present
if [ ! -L /etc/nginx/sites-enabled/$dom ]; then
    ln -s "$NGINX_CONF" /etc/nginx/sites-enabled/$dom
fi
if [ -e /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

echo "Restarting nginx..."
systemctl restart nginx

echo -en "\n\nNext, you have the option of configuring LetsEncrypt to secure your new site."
echo "Before proceeding, ensure that your domain ($dom) is pointed to this server's IP address."
echo "You can also run Certbot later with 'certbot --nginx'."
echo -en "\nWould you like to use LetsEncrypt (certbot) to configure SSL (https) for your site? (y/n): "
read -r yn
case $yn in
    [Yy]* )
        certbot --nginx
        echo "WordPress has been enabled at https://$dom. Please open this URL in a browser to complete the setup."
        ;;
    [Nn]* )
        echo "Skipping LetsEncrypt certificate generation."
        ;;
    * )
        echo "Please answer y or n."
        ;;
esac

echo "Installation complete. Access your new WordPress site in a browser to continue."